# Product Spec — Claude Cowork Config (v2.5)

> **Cycle:** v3.0-Gate Prep — ADR-028 + tools: frontmatter + First Upstream Contribution
> **Version bump:** v2.4.0 → v2.5.0 (minor — new feature surface: `tools:` frontmatter field + first upstream contribution PR)
> **Status:** Phase 0 — Requirements
> **Date:** 2026-05-09T12:00:00Z
> **Replaces:** v2.4 spec (Dynamic Workspace Architect)
> **Classification:** SECURITY-SENSITIVE + COMPLIANCE-SENSITIVE
> **Routing:** Phase 2 `/review` (@security FULL pass) + Phase 2 `/legal` (@compliance) required before `/design`. See Classification section.
> **Cycle-fit verdict:** PASS — one cycle. See One-Cycle-Fit section.

---

## Strategic Context

v2.5 is a v3.0 gate-prep cycle. The decision memo (internal, Council-side) recommends deferring the full Model C Hybrid pivot to v3.0 and shipping v2.5 as a focused structural seam-layer. Three v3.0 triggers are encoded as ACs below; all three must be green before `/spec v3.0` is invoked.

**Binding carry-forwards this cycle:** CF-v2.4-A, -B, -D (re-deferred), -E (re-deferred), -F, -G.

---

## Problem

v2.4 shipped the Dynamic Workspace Architect — a complete end-to-end wizard with goal routing, pool-based install, and CI vocabulary gates. Four structural gaps survived as deferred carry-forwards and continue to accumulate cycle cost:

1. **ADR-028 (PROPOSED since v2.3.0):** `cowork.lock.json` records per-file `sha256` at fetch time but does NOT verify that hash on subsequent syncs. If an upstream file is silently replaced between pinned commits (a poisoned-fetch scenario), `sync-agency.yml` will import modified content without detection. This is a supply-chain integrity gap that has been deferred three times.

2. **`tools:` frontmatter absent:** SKILL.md files have no machine-readable signal for which agentic tool each skill targets. The wizard cannot make tool-aware recommendations. As Cowork grows toward multi-tool reach (Copilot, Cursor, Windsurf — v3.0 scope), the absence of `tools:` becomes a blocker. Adding it now is a low-risk seam that enables v3.0 without requiring a rework cycle.

3. **CI hardening gap (CF-v2.4-B + CF-v2.4-G):** MF-1/MF-2 `grep -c || true` masking can silently pass on empty awk pipeline output. MF-2 awk uses positional `$7` rather than header-name lookup — column reordering in `curated-skills-registry.md` breaks the gate silently. Both gaps are non-exploitable in v2.4 (upstream checks catch structural failure first) but represent preventable false-pass scenarios.

4. **No upstream contribution signal:** v3.0 Model C Hybrid requires confidence that the upstream community will engage with Cowork contributions. Without a test PR, this is a pure assumption. One contribution PR (small scope, clean format, project-management category) establishes the relationship and starts the 60-day acknowledgment clock.

5. **P-COWORK-1 (4-cycle carry):** Local markdownlint configuration is absent. Contributors run locally, CI catches failures post-push. A pre-commit hook closes this gap.

---

## Target Users

**Primary: Alex — University Student (20, biochemistry)**
v2.5 gain: `tools:` frontmatter tells the wizard Alex is on Claude Code — skill recommendations stay relevant without multi-tool confusion from future Copilot/Cursor skills added to the pool.

**Secondary: Maria — Knowledge Worker (35, research analyst)**
v2.5 gain: Per-file integrity verification means the `meeting-notes` skill Maria installs is byte-verified against the pinned upstream commit. Silent content tampering is detected before install.

**Tertiary: Sam — The Creator (28, freelance writer)**
v2.5 gain: Unblocked; v2.5 is infrastructure. Sam sees no surface-level change.

**New contributor**
v2.5 gain: `scripts/install-pre-commit.sh` + CONTRIBUTING.md instructions give contributors the same markdownlint gate as CI locally, reducing surprise CI failures.

---

## Core Features (MVP)

### F1 — ADR-028 Implementation: `content_sha256` Per-File Integrity Field

**What it does:** Adds a `content_sha256` field to each `files[]` entry in `cowork.lock.json`. On every `sync-agency.yml` execution (both auto-sync and PR-triggered), the workflow fetches each pinned-commit file, computes its SHA-256, and compares it to the stored `content_sha256`. A mismatch fails the workflow with `::error::` and blocks merge.

**Why now:** ADR-028 has been PROPOSED-not-implemented since v2.3.0 (three deferrals). The field `sha256` already exists in `cowork.lock.json` per-file entries and is populated at fetch time by `sync-agency.yml` lines 216-243. The gap is that `sync-agency.yml` never verifies against the stored value on subsequent fetches — it only writes. This feature closes that gap.

**Scope:**
- Add `content_sha256` field to all existing `files[]` entries in `cowork.lock.json` (initial values computed from currently-fetched content at pinned commit `783f6a72`).
- Extend `sync-agency.yml` verify step: after fetching each file, compute SHA-256 of fetched content and compare to `cowork.lock.json` `content_sha256`. Fail step on mismatch.
- Update ADR-028 status from PROPOSED to ACCEPTED in `docs/architecture.md` with implementation record.
- CI fault-injection test: a `.github/workflows/` fixture or quality.yml step that verifies the check fires correctly when a file's content is poisoned (mutated byte in the fetched content vs. stored hash). The fault-injection must produce a non-zero exit.

**Preservation constraint:** `cowork.lock.json` schema version stays `"1.0"` — `content_sha256` is an additive field, not a breaking change. ADR-020 lock contract semantics are preserved.

**ACs:**
- **AC-F1-1:** `cowork.lock.json` contains a `content_sha256` field on every entry in the `files[]` array. `grep -c '"content_sha256"' cowork.lock.json` equals the number of entries in `files[]`.
- **AC-F1-2:** `sync-agency.yml` contains a verify step that fetches each pinned-commit file and compares its computed SHA-256 to the `content_sha256` stored in `cowork.lock.json`. Grep confirms: `grep -c "content_sha256" .github/workflows/sync-agency.yml` >= 2 (read step + verify step).
- **AC-F1-3:** Fault-injection test fires: when any single `content_sha256` value in the fixture is mutated to a wrong hash and `sync-agency.yml` verify runs against it, the step exits non-zero. Fault injection documented in `docs/architecture.md` ADR-028 implementation record.
- **AC-F1-4 (zero-diff):** `cowork.lock.json` `$schema_version` remains `"1.0"`. `jq -r '."$schema_version"' cowork.lock.json` = `1.0`. ADR-020 lock contract schema version unchanged.
- **AC-F1-5 (zero-diff):** `sync-agency.yml` SCAN_PATTERNS block (lines 143+220) byte-unchanged from v2.4 HEAD. `cmp` exit 0 on lines 143 and 220 before and after the PR.

---

### F2 — `tools:` SKILL.md Frontmatter Field

**What it does:** Adds an optional `tools:` YAML frontmatter field to every SKILL.md in `skills/`. Declares which agentic tools the skill's content is known to work with. Default when absent: `[claude-code]`. CI validates token vocabulary against an explicit allow-list.

**Vocabulary (closed at v2.5):** `claude-code`, `copilot`, `cursor`, `windsurf`. No other tokens are permitted. Wizard reads the field as informational at v2.5. Tool-aware routing is v3.0 scope.

**Why the closed vocabulary matters:** The allow-list locks down tool names at this layer. If a skill author writes `copilot-chat` or `github-copilot`, CI rejects it. This prevents vocabulary drift that would require a rework sweep at v3.0.

**Scope:**
- Add `tools:` field to all 20 SKILL.md files in `skills/`. All 20 receive `tools: [claude-code]` as the v2.5 default (reflecting current validated support).
- Add CI vocabulary gate (new step in `quality.yml`): validate `tools:` field in every `skills/*/SKILL.md` frontmatter against the allow-list `[claude-code, copilot, cursor, windsurf]`. Unknown tokens fail CI.
- New ADR in `docs/architecture.md` documenting the `tools:` field contract, vocabulary allow-list, default rule, and v3.0 routing intent.

**Preservation constraint:** `tools:` is an additive frontmatter field. ADR-007 (Skill File Format) receives an amendment block. Existing SKILL.md 9-section body structure is unchanged (ADR-015 preserved). No pool count change (still 20 skills).

**ACs:**
- **AC-F2-1:** All 20 SKILL.md files contain a `tools:` frontmatter field. `grep -rl "^tools:" skills/ | wc -l` = 20.
- **AC-F2-2:** All 20 skills have `tools:` set to `[claude-code]` at v2.5. `grep -c "tools: \[claude-code\]" skills/*/SKILL.md` = 20.
- **AC-F2-3:** CI vocabulary gate present in `quality.yml`. New step name contains `tools` or `tools-vocab`. Gate fails on invalid token: fault-inject `tools: [unknown-tool]` into any SKILL.md fixture → CI exits non-zero.
- **AC-F2-4:** New ADR documented in `docs/architecture.md` with: (a) field name `tools:`, (b) closed vocabulary list, (c) default-when-absent rule, (d) v3.0 routing intent marked explicitly. `grep -c "tools:" docs/architecture.md` >= 4 (ADR title + field name + vocabulary + default rule).
- **AC-F2-5 (zero-diff):** Skill pool count unchanged: `ls skills/ | wc -l` = 20. ADR-015 9-section body structure preserved: skill-depth-check passes on all 20 skills.

---

### F3 — First Upstream Contribution PR

**What it does:** Submits ONE Cowork-original skill to an upstream community skills repository as a PR in the upstream flat persona-centric format. Tracks the acknowledgment outcome. Starts the 60-day v3.0 trigger clock.

**Upstream contribution candidate: `meeting-notes`**

Rationale for `meeting-notes` over alternatives:
- Lowest Cowork-specific entanglement: 1 optional writing-profile reference (line 108, contextual — easily stripped for upstream format). `risk-assessment` (2 refs) and `status-update` (2 refs) have more entanglement.
- Maps to the upstream's `project-management/` category — clean landing zone.
- Universal utility: meeting-notes extraction is tool-agnostic and persona-agnostic. The upstream community benefits broadly.
- 114 lines in Cowork format → reformatted to upstream flat persona-centric format (~60-80 lines estimated). Within one-cycle scope for manual rewrite.
- No Data Locality Rule (ADR-019) or wizard-runtime dependencies — safe to decouple from Cowork infrastructure.

**Format bridge (manual rewrite required — not scriptable):**
The upstream format is persona-centric (identity + capabilities + workflow + deliverables). Cowork's format is procedural (instructions + triggers + output + quality + anti-patterns + example). This requires a structural rewrite, not a text transformation. @dev authors the upstream-format version from scratch using the Cowork skill's content as the source of truth for substance.

**Upstream format target:**
```
---
name: Meeting Notes Specialist
description: [one-line]
tools: Read, Write, Edit
color: blue
emoji: [emoji]
vibe: [personality hook]
---
# Meeting Notes Specialist
## [Identity section]
## [Core Mission section]
## [Critical Rules section]
## [Technical Deliverables section]
## [Workflow Process section]
## [Communication Style section]
## [Learning and Memory section]
## [Success Metrics section]
```

**Cowork attribution survival:** The upstream PR description (not the skill file body) attributes Cowork as the source. The skill file itself follows upstream's format conventions — no Cowork-specific attribution block injected (ADR-024 applies to wizard install, not upstream contributions). @compliance confirms attribution survival approach at Phase 2 `/legal`.

**Output deliverables:**
1. `upstream-contribution/meeting-notes-upstream.md` — upstream-format version of the skill, committed to the Cowork repo as a tracked artifact. This is the file submitted as a PR to the upstream community repo.
2. CHANGELOG v2.5.0 entry records the PR URL once opened (format: `Upstream contribution: [PR URL] — meeting-notes skill submitted to project-management category`).
3. `docs/architecture.md` records the PR URL and open date under a new implementation note.

**v3.0 trigger clock starts:** PR open date recorded. 60-day acknowledgment window begins. Result feeds v3.0 gate review.

**Re-defer rationale (CF-v2.4-D):** CF-v2.4-D (preset community PR contribution workflow) is explicitly re-deferred to v2.6+. Rationale: F3 is the upstream relationship test. If F3 returns a signal (acknowledged/merged/rejected), v2.6 scopes the community workflow with evidence. If F3 returns silence, community PR workflow has no upstream benefit to enable.

**ACs:**
- **AC-F3-1:** `upstream-contribution/meeting-notes-upstream.md` exists in the repo at v2.5.0 HEAD. File uses upstream flat persona-centric YAML frontmatter (fields: `name`, `description`, `tools`, `color`, `emoji`, `vibe`) and 8-section persona body. `grep -c "^---" upstream-contribution/meeting-notes-upstream.md` = 2 (open and close frontmatter fences).
- **AC-F3-2:** CHANGELOG v2.5.0 section contains a line starting with `Upstream contribution:` followed by the PR URL. `grep -c "Upstream contribution:" CHANGELOG.md` >= 1.
- **AC-F3-3:** `upstream-contribution/meeting-notes-upstream.md` does NOT contain Cowork-specific terms: `grep -ciE "WIZARD|ADR-|cowork\.lock|selection-preset|skill-depth|sync-agency|writing-profile" upstream-contribution/meeting-notes-upstream.md` = 0.
- **AC-F3-4:** PR URL recorded in `docs/architecture.md` under the F3 implementation note. `grep -c "agency-agents/pull/" docs/architecture.md` >= 1.
- **AC-F3-5 (v3.0 trigger):** PR opened and URL is a valid GitHub PR URL (format `https://github.com/[owner]/[repo]/pull/[N]`). @qa verifies at Phase 5 that the URL returns HTTP 200 or 3xx — not by verifying PR state (open/merged/closed).

**v3.0 trigger encoding (informational — not blocking ACs for v2.5):**
The three v3.0 gates (to be evaluated after v2.5 ships):
1. Upstream PR acknowledged (reviewed, merged, or constructive feedback) within 60 days of open date.
2. Upstream still active (last commit within 90 days of gate review date).
3. v2.5 CI clean (all checks green, 0 CRITICAL/WARNING findings in Phase 6 audit).

These gates are not ACs for v2.5 (they are prospective). They are recorded here for the v3.0 spec author.

---

### F4 — MF-1/MF-2 grep-c Hardening + MF-2 awk Column Fix

**What it does:** Bundles CF-v2.4-B and CF-v2.4-G. Two targeted hardening changes to `quality.yml`:

**Change 1 (CF-v2.4-G):** Replace `grep -c ... || true` masking in MF-1 and MF-2 steps with an explicit empty-pipeline assertion. The `|| true` pattern causes `BAD` to be empty (not `0`) when `grep` finds no matches on an empty pipeline, and `${BAD:-0}` silently defaults to 0. Replace the pattern with either:
- `set -o pipefail` before the pipeline, OR
- An explicit post-pipeline check: `if [ -z "${BAD}" ]; then BAD=0; fi` (explicit, readable, no pipefail side effects elsewhere).

**Change 2 (CF-v2.4-B):** Replace positional `$7` in the MF-2 awk expression with a column-name-based lookup. Current: `awk -F'|' '/^\| / && NR>2 { print $7 }'`. Replace with: awk reads the header row (NR==2), maps column name `goal_tags` to its column index, then uses that index for data rows. If `goal_tags` column is not found in the header, the gate must exit non-zero (fail-closed) rather than silently pass.

**Regression test fixture:** A CI step or test fixture that verifies MF-2 fires correctly when `goal_tags` column is reordered. Fixture: a `curated-skills-registry.md` copy with columns in a different order → gate must still find `goal_tags` by name and apply the vocabulary check.

**ACs:**
- **AC-F4-1:** MF-1 step in `quality.yml` no longer contains `|| true` on the `grep -c` line. Replaced with explicit empty-check or `set -o pipefail`.
- **AC-F4-2:** MF-2 step in `quality.yml` no longer contains `|| true` on the `grep -c` line. Same verification as AC-F4-1 for MF-2 step context.
- **AC-F4-3:** MF-2 awk expression uses column-name lookup, not positional `$7`. `grep -c '\$7' .github/workflows/quality.yml` = 0 (no positional `$7` references remain in quality.yml).
- **AC-F4-4:** MF-2 awk contains a header-scan clause: `grep -c "goal_tags" .github/workflows/quality.yml` >= 2 (header-scan definition + usage). If `goal_tags` header is absent, gate exits non-zero.
- **AC-F4-5:** Fault-injection regression test present for column reorder scenario. A fixture or inline test demonstrates MF-2 still fires `BAD=1` when `goal_tags` column is in a non-standard position.

---

### F5 — Local Markdownlint Pre-Commit Hook

**What it does:** Ships an opt-in `scripts/install-pre-commit.sh` that installs a local `.git/hooks/pre-commit` applying the same markdownlint ruleset as CI. Closes CF-v2.4-F and P-COWORK-1 (4th consecutive cycle carry).

**Opt-in design:** The hook is NOT installed automatically. Contributors run `scripts/install-pre-commit.sh` to opt in. This is consistent with the project's zero-forced-tooling posture (no npm, no package.json, no mandatory setup). Script documented in CONTRIBUTING.md as a recommended first-time setup step.

**Ruleset consistency:** The pre-commit hook uses the same `.markdownlintrc` or inline ruleset as the `markdown-lint` CI step in `quality.yml`. If the CI ruleset changes, the script must reference the same config source — not a copy.

**Scope:**
- `scripts/install-pre-commit.sh` — writes `.git/hooks/pre-commit` that runs `markdownlint` on staged `.md` files using repo ruleset.
- CONTRIBUTING.md updated to document the script under a new "Local Development" section.
- CI `quality.yml` `markdown-lint` step updated to note the pre-commit hook as the local equivalent (comment only — no behavioral change).

**Out of scope for v2.5:** Husky, lint-staged, or any npm-based pre-commit framework. Shell script only.

**ACs:**
- **AC-F5-1:** `scripts/install-pre-commit.sh` exists. `ls -la scripts/install-pre-commit.sh` exits 0.
- **AC-F5-2:** The script invokes `markdownlint` using the same ruleset reference as the CI `markdown-lint` step. `grep -c "markdownlint" scripts/install-pre-commit.sh` >= 1.
- **AC-F5-3:** CONTRIBUTING.md contains a "Local Development" section (or equivalent heading) that references `scripts/install-pre-commit.sh`. `grep -c "install-pre-commit" CONTRIBUTING.md` >= 1.
- **AC-F5-4:** Pre-commit hook, when installed and run against a staged file with a markdownlint violation, exits non-zero and blocks the commit. Verified by @qa via local test during Phase 5, or by a documented manual test procedure in `docs/architecture.md`.

---

## Out of Scope (v2.5)

- **v3.0 work.** No fork of the upstream skills repository. No multi-tool wizard step. No bulk SKILL.md reformatting beyond adding the `tools:` field. No Copilot/Cursor/Windsurf install path.
- **CF-v2.4-D (preset community PR contribution workflow).** Re-deferred to v2.6+. Rationale above under F3.
- **CF-v2.4-E (LLM-based goal matching).** Backlog. Activate only if keyword-match <80% in field data. No field data yet.
- **ADR-020 supply-chain changes.** Lock contract semantics preserved. `content_sha256` is additive. No schema_version bump.
- **New skill additions.** Pool remains at 20 skills. Only the `tools:` field is added to existing files.
- **`tools:` routing logic in wizard.** Wizard reads `tools:` as informational only at v2.5. Routing branch is v3.0 scope.
- **Bulk upstream contribution.** Only `meeting-notes` is reformatted and submitted. Other 19 skills remain in Cowork-only format.
- **Naming/rebranding review.** Deferred to v3.0 naming review.

---

## Technical Constraints

- **Stack:** No application runtime. Markdown + bash scripts. Delivered as a public GitHub repo (ZIP-downloadable). All CI via GitHub Actions.
- **Lock contract (ADR-020):** `cowork.lock.json` schema version `"1.0"` preserved. `content_sha256` is additive. ADR-020 semantics unchanged.
- **Supply chain (ADR-022):** `sync-agency.yml` SCAN_PATTERNS (lines 143+220) byte-unchanged. All 8 SCAN_PATTERNS preserved. F1 adds a verify step; it does not modify the SCAN_PATTERNS block.
- **Skill format (ADR-007/ADR-015):** SKILL.md 9-section body structure preserved. `tools:` is a frontmatter-only change. skill-depth-check passes on all 20 skills post-F2.
- **Attribution (ADR-024):** Attribution injection in WIZARD.md Step 5 is byte-unchanged. The upstream contribution (F3) does NOT use the ADR-024 attribution block — upstream files follow upstream's format. This distinction is @compliance's verification surface at Phase 2 `/legal`.
- **THIRD-PARTY-NOTICES.md (ADR-025):** The upstream community skills repository is already named in `THIRD-PARTY-NOTICES.md`. No new third-party entries required for F3 (outbound contribution, not inbound import). @compliance confirms at Phase 2.
- **Public-copy hygiene rule:** Internal repository names, tool names, and upstream maintainer identifiers MUST NOT appear in README, CHANGELOG promotional copy, SETUP-CHECKLIST, or any user-facing surface. They MAY appear in `docs/architecture.md`, `docs/spec.md`, `THIRD-PARTY-NOTICES.md`, and internal pipeline docs.
- **Cycle envelope:** v2.4 was ~47 files / +3827/-652 delta. v2.5 estimated: ~35 files / ~950 lines net. Within normal yardstick.
- **markdownlint:** No MD058 violations in F2 additions. F5 pre-commit script uses same ruleset. CI must pass on first push (0% rework rate norm holds).
- **Commit topology (ADR-033 / v2.4 F7 pattern):** Phase 0/1/2 docs (spec, architecture, security-review) must be committed in PR #N Commit 6 (REQUIRED label per F7 mandatory-paperwork-commit topology).

---

## User Stories

- As Alex (student, Claude Code user), I can trust that the skills installed by the wizard are byte-verified against the upstream pinned commit, so my workspace is not silently corrupted by an upstream content swap.
- As Maria (knowledge worker), I can see that each skill in my workspace is tagged for my tool, so I know which skills are validated for my setup when multi-tool support ships in a future version.
- As a contributor, I can run `bash scripts/install-pre-commit.sh` once to get the same markdownlint gate locally as CI, so I catch markdown formatting failures before pushing.
- As the project maintainer, I can submit a Cowork-original skill to an upstream skills community so that the upstream relationship is established before v3.0 and the acknowledgment outcome informs the v3.0 gate decision.

---

## Classification

**SECURITY-SENSITIVE.**
- F1 (lock integrity): extends the supply-chain trust model (ADR-020/022 surface). Combined-path NOT eligible. Phase 2 `/review` (@security FULL OWASP+LLM Top 10 pass) required. Phase 6 `/audit` FULL pass required.
- F3 (first outbound contribution): first-time external-repository interaction from Cowork. Exposes repo identity. Governance handoff surface.

**COMPLIANCE-SENSITIVE.**
- F3 triggers external content detection: outbound contribution to a third-party MIT-licensed repo with structural reformatting of Cowork content. Per pipeline-policy.md §ThirdPartyContentImport, @compliance must run at Phase 2 (`/legal`) AND Phase 6.
- Key compliance questions for @compliance at Phase 2:
  1. Does contributing a reformatted Cowork skill to an MIT repo require any attribution survival in the skill file, or is PR-description attribution sufficient?
  2. Does ADR-024 attribution block apply to outbound contributions, or only to inbound installs? (Architecture says inbound only — @compliance to confirm.)
  3. Is `THIRD-PARTY-NOTICES.md` (ADR-025) updated to reflect outbound contribution, or does it only track inbound third-party content?
  4. Are there any GitHub Terms of Service concerns with the upstream repo accepting PRs?

**Combined-path:** NOT eligible (SECURITY-SENSITIVE lock, same as v2.4). @security must run FULL audit at Phase 2 and Phase 6 independently.

---

## Open Questions for @architect

**OQ-v2.5-1 (F1 — verify step placement):** Should the `content_sha256` verify step in `sync-agency.yml` run inside the existing fetch job or as a new dedicated job/step? Recommendation needed before @dev implements to avoid topology ambiguity. Binding decision in ADR-028 implementation record.

**OQ-v2.5-2 (F1 — initial hash population):** When `content_sha256` is added to `cowork.lock.json` for the first time, the values must be computed from the actual files at pinned commit `783f6a72`. Strategy: (a) @dev runs a one-time local computation script and commits the values, or (b) the first `sync-agency.yml` run after merge computes and writes them. Which approach is correct given the lock file's update cadence and the no-force-push constraint?

**OQ-v2.5-3 (F2 — CI gate placement):** Should the `tools:` vocabulary gate be a new dedicated step in `quality.yml` or an extension of the existing MF-1 step? MF-1 targets `selection-presets.md`; the new gate targets `skills/*/SKILL.md` frontmatter. Separate step is recommended for clarity — @architect to confirm.

**OQ-v2.5-4 (F3 — upstream-contribution/ directory CI exclusion):** Should `upstream-contribution/meeting-notes-upstream.md` be excluded from the `skill-depth-check` CI gate? If not excluded, the gate fires because the file does not follow the 9-section Cowork template. @architect to issue binding constraint.

**OQ-v2.5-5 (F4 — pipefail scope):** If `set -o pipefail` is adopted to replace `|| true` in MF-1/MF-2, does this affect other pipeline steps in the same `run:` block that legitimately use `|| true` for non-error paths? @architect to confirm scope of fix — pipefail per-step vs. explicit empty-check approach.

---

## Acceptance Criteria — Full List

| ID | Feature | Criterion | Verification method |
|----|---------|-----------|---------------------|
| AC-F1-1 | F1 | `content_sha256` on every lock file entry | `grep -c '"content_sha256"' cowork.lock.json` = file entry count |
| AC-F1-2 | F1 | `sync-agency.yml` verify step present | `grep -c "content_sha256" .github/workflows/sync-agency.yml` >= 2 |
| AC-F1-3 | F1 | Fault-injection test fires on poisoned hash | Fault-inject wrong hash → verify step exits non-zero |
| AC-F1-4 | F1 | schema_version = "1.0" | `jq -r '."$schema_version"' cowork.lock.json` = `1.0` |
| AC-F1-5 | F1 | SCAN_PATTERNS byte-unchanged | `cmp` exit 0 on sync-agency.yml lines 143 and 220 |
| AC-F2-1 | F2 | `tools:` field in all 20 skills | `grep -rl "^tools:" skills/ \| wc -l` = 20 |
| AC-F2-2 | F2 | All 20 set to `[claude-code]` | `grep -c "tools: \[claude-code\]" skills/*/SKILL.md` = 20 |
| AC-F2-3 | F2 | CI vocab gate fires on invalid token | Fault-inject `[unknown-tool]` → CI exits non-zero |
| AC-F2-4 | F2 | New ADR in architecture.md | `grep -c "tools:" docs/architecture.md` >= 4 |
| AC-F2-5 | F2 | Pool count = 20, 9-section depth preserved | `ls skills/ \| wc -l` = 20; skill-depth-check passes all |
| AC-F3-1 | F3 | Upstream-format file exists with correct frontmatter | `grep -c "^---" upstream-contribution/meeting-notes-upstream.md` = 2 |
| AC-F3-2 | F3 | CHANGELOG records PR URL | `grep -c "Upstream contribution:" CHANGELOG.md` >= 1 |
| AC-F3-3 | F3 | No Cowork-specific terms in upstream file | grep pattern = 0 |
| AC-F3-4 | F3 | PR URL in architecture.md | `grep -c "agency-agents/pull/" docs/architecture.md` >= 1 |
| AC-F3-5 | F3 | PR URL is valid GitHub PR URL | URL returns HTTP 200/3xx |
| AC-F4-1 | F4 | MF-1 `|| true` removed | 0 matches in MF-1 step context in quality.yml |
| AC-F4-2 | F4 | MF-2 `|| true` removed | 0 matches in MF-2 step context in quality.yml |
| AC-F4-3 | F4 | No positional `$7` in quality.yml | `grep -c '\$7' .github/workflows/quality.yml` = 0 |
| AC-F4-4 | F4 | MF-2 awk has header-scan clause | `grep -c "goal_tags" .github/workflows/quality.yml` >= 2 |
| AC-F4-5 | F4 | Column-reorder regression test present | Fixture or inline test documented |
| AC-F5-1 | F5 | Script exists | `ls -la scripts/install-pre-commit.sh` exits 0 |
| AC-F5-2 | F5 | Script invokes markdownlint | `grep -c "markdownlint" scripts/install-pre-commit.sh` >= 1 |
| AC-F5-3 | F5 | CONTRIBUTING.md references script | `grep -c "install-pre-commit" CONTRIBUTING.md` >= 1 |
| AC-F5-4 | F5 | Hook blocks commit on violation | Manual test or documented procedure |

**Zero-diff constraints (preservation):**

| ID | Surface | Constraint |
|----|---------|-----------|
| AC-ZD-1 | `cowork.lock.json` | `$schema_version` = `"1.0"` (jq verified) |
| AC-ZD-2 | `sync-agency.yml` | SCAN_PATTERNS L143+L220 byte-unchanged (cmp exit 0) |
| AC-ZD-3 | `CLAUDE.md` | Word count <= 400 (unchanged from v2.4) |
| AC-ZD-4 | `.cowork-allowlist.json` | 10-entry seed unchanged (cmp exit 0) |

**Release artifact ACs (ADR-033 pattern):**

| ID | Surface | Constraint |
|----|---------|-----------|
| AC-REL-1 | `VERSION` | `cat VERSION` = `2.5.0` |
| AC-REL-2 | `CHANGELOG.md` | `## [2.5.0]` section present at top |
| AC-REL-3 | `README.md` | Version badge updated to `2.5.0` |
| AC-REL-4 | `CHANGELOG.md` | "Next up" teaser line present under v2.5.0 section header |

---

## Edge Cases

**EC-1 (F1 — empty files[] array):** If `cowork.lock.json` `files[]` is empty, the verify step must succeed gracefully (0 files to verify = 0 mismatches) rather than failing with a shell error. @architect to address in ADR-028 implementation note.

**EC-2 (F1 — network fetch failure):** If `sync-agency.yml` cannot fetch a file from GitHub during the verify step (network timeout, 404), the step must exit non-zero (fail-closed), not silently pass. Distinct failure message from "hash mismatch" required.

**EC-3 (F2 — tools: field absent from future skill):** A new skill added post-v2.5 without a `tools:` field must fail CI. The default rule applies at wizard runtime; CI enforces presence. @architect to confirm this interpretation.

**EC-4 (F3 — upstream PR rejected before Phase 7):** If the upstream PR is rejected before Phase 5 closes, AC-F3-5 (valid PR URL) still passes — rejection is a valid PR state. The v3.0 trigger evaluation handles outcomes. @qa must not fail v2.5 Phase 7 due to PR rejection.

**EC-5 (F4 — goal_tags column absent from header):** If the `goal_tags` column header is missing from `curated-skills-registry.md`, the MF-2 awk column-name lookup must exit non-zero (fail-closed). The gate cannot silently skip the vocabulary check because the column is not found.

**EC-6 (F5 — markdownlint not installed locally):** If a contributor runs the pre-commit hook and `markdownlint` is not installed, the hook must exit with a clear error message and block the commit. Must not silently succeed.

---

## Success Metrics

- **Primary:** v2.5 CI green on first push to release/v2.5.0 (0% rework rate — 4-cycle PASS-ON-FIRST-PUSH norm holds).
- **Secondary — v3.0 trigger evaluation readiness:**
  - F3 PR opened within 5 days of v2.5.0 tag.
  - AC-F1-3 fault-injection fires correctly at ship time.
  - All 20 skills pass `tools:` vocabulary gate.
- **Tertiary — carry-forward reduction:**
  - CF-v2.4-A resolved (ADR-028 ACCEPTED).
  - CF-v2.4-B + CF-v2.4-G bundled and resolved (MF-1/MF-2 hardening).
  - CF-v2.4-F resolved (P-COWORK-1 pattern closes after 4 cycles).
  - CF-v2.4-D re-deferred with explicit rationale. CF-v2.4-E backlogged with condition.

---

## Assumptions

- **[CONFIRMED]** `cowork.lock.json` `files[]` entries already contain a `sha256` field. F1 adds `content_sha256` as a second integrity field. No field rename required.
- **[CONFIRMED]** A meeting-notes equivalent does not exist in the upstream's `project-management/` category. Contribution is additive, not a duplicate.
- **[CONFIRMED]** MIT license at upstream pinned commit allows PRs and derivative works without relicensing. @compliance confirms F3 attribution at Phase 2.
- **[ESTIMATED]** Writing upstream-format `meeting-notes-upstream.md` from scratch requires approximately 2-3 hours of structured rewrite. Within one-cycle scope for @dev.
- **[ESTIMATED]** MF-2 awk column-name refactor adds approximately 10-15 lines to the quality.yml step. No architectural change required.
- **[UNTESTED]** Upstream maintainer acknowledges PR within 60 days. No prior interaction history. v3.0 gate review handles the unknown.
- **[UNTESTED]** Pre-commit hook works on contributor machines without `markdownlint` installed at the global path. EC-6 covers the failure mode.

---

## Re-defer Rationale

**CF-v2.4-D (preset community PR contribution workflow):** Explicitly re-deferred to v2.6+. The community PR workflow's design depends on whether Cowork has an upstream relationship (Model C) or stays internal-only (Model A fallback). F3's outcome determines this. Designing the workflow before F3 returns a signal would require a rework cycle.

**CF-v2.4-E (LLM-based goal matching):** Backlog. Activation condition: keyword matching produces less than 80% accuracy in field testing data. No field testing data exists yet. Condition not met.

---

## One-Cycle-Fit Verdict: PASS

**Analysis:**
- F1: approximately 8 files, 150 lines (lock file population + sync-agency.yml verify step + ADR-028 implementation note + fault-injection fixture).
- F2: approximately 22 files, 600 lines (20 SKILL.md frontmatter line additions + quality.yml vocabulary gate step + ADR amendment).
- F3: approximately 5 files, 120 lines (upstream-format file ~70L + CHANGELOG entry + architecture.md F3 note + upstream-contribution/ directory).
- F4: approximately 2 files, 30 lines (quality.yml MF-1/MF-2 hardening + regression fixture).
- F5: approximately 3 files, 50 lines (install script + CONTRIBUTING.md update + quality.yml comment).

**Estimated total:** approximately 35 files, 950 lines net additions. Well within normal cycle yardstick (20-50 files, 2000-3000 line delta). No split required.

---

## WILL-NOT-DO List (v2.5)

1. Fork the upstream skills repository — deferred to v3.0 gate review outcome.
2. Multi-tool wizard step — v3.0 scope.
3. Bulk SKILL.md reformatting beyond `tools:` field addition — v3.0 scope.
4. Any SKILL.md body changes (9-section structure preserved per ADR-015).
5. `schema_version` bump in `cowork.lock.json` — F1 is additive.
6. New skills added to pool — pool stays at 20.
7. Copilot/Cursor/Windsurf install paths — v3.0 scope.
8. Preset community PR contribution workflow (CF-v2.4-D) — re-deferred with explicit rationale.
9. LLM-based goal matching (CF-v2.4-E) — condition not met.
10. ADR-020/022 supply-chain architecture changes — SCAN_PATTERNS and lock contract preserved.
11. Upstream repository names, tool names, or maintainer identifiers in any public-facing copy.
12. npm/Node.js toolchain addition for pre-commit — shell script only per zero-toolchain posture.

---

## Architectural Modifications

*Populated by @architect at Phase 1 close — 2026-05-09T20:00Z.*

- AC: AC-F1-5 (`cmp` exit 0 on sync-agency.yml lines 143 and 220 before/after PR) → Verifier mechanism amended to `git diff` regex over SCAN_PATTERNS+accumulator regions — Reason: F1 verify step is INSERTED between line 143 (SCAN_PATTERNS start) and line 220 (accumulator append region), displacing line numbers downstream of the insertion point. A frozen-line `cmp` would falsely fail on byte-identical content. Verifier semantics preserved (no SCAN_PATTERNS or accumulator drift); mechanism amended. See C-v2.5-5 in architecture.md.
- AC: AC-F2-4 (`grep -c "tools:" docs/architecture.md` >= 4) → Numerically unchanged but @architect notes the verifier counts ANY `tools:` literal across architecture.md (including ADR-029 prose). Practical floor at v2.5 is much higher. No AC change required.

No other modifications. All 33 spec ACs achievable as-written.

---

## Proposed Changes

*Reserved for /spec --revise cycles. Not applicable at initial Phase 0.*
