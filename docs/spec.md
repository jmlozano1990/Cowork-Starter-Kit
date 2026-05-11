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

### v2.5.2 modifications

*Populated by @architect at v2.5.2 Phase 1 close — 2026-05-10T00:00:00Z.*

- AC: AC-ZD-4 (`docs/architecture.md` git diff empty) → Re-interpreted as "no new ADRs, no ADR mutations, no rewrite of existing ADR sections; append-only Phase 1 design record permitted." — Reason: Project pipeline convention from v2.0 onward appends a per-cycle Phase 1 design record under a `## v<cycle> Phase 1` heading (precedents: v2.0, v2.0.2, v2.0.3, v2.3.0, v2.3.1, v2.5.1). Strict literal AC-ZD-4 verification (empty `git diff`) conflicts with this established record-keeping. The literal interpretation would suppress the architectural ledger that downstream agents bind against. Phase 4 verification: `awk '/^## ADR-[0-9]+/{print}' docs/architecture.md` returns 32 entries (ADRs and amendments matching `^## ADR-`); count and ID set unchanged from v2.5.1 HEAD); the only diff is the appended `## v2.5.2 Phase 1 — Quality Loop Design` section. See `docs/architecture.md` v2.5.2 Phase 1 § 2 for the full re-interpretation contract.

No other v2.5.2 modifications. All 21 v2.5.2 spec ACs achievable as-written.

### v2.5.3 modifications

*Populated by @architect at v2.5.3 Phase 1 close — 2026-05-10T15:00:00Z.*

- AC: AC-ZD-3 ("No new ADRs added. No existing ADR sections modified.") → Re-interpreted as "no new ADRs, no ADR mutations, no rewrite of existing ADR sections; append-only Phase 1 design record under a new top-level `## v2.5.3 Phase 1 — v43 Framework Application Design` heading is permitted." — Reason: Established convention since v2.0 (precedents v2.0, v2.0.2, v2.0.3, v2.3.0, v2.3.1, v2.5.1, v2.5.2); strict literal verification suppresses the architectural ledger that downstream agents bind against. Phase 4 verification: `awk '/^## ADR-[0-9]+/{print}' docs/architecture.md` returns 32 entries (count and ID set unchanged from v2.5.2 HEAD `b31ccce`); the only diff is the appended Phase 1 section. See `docs/architecture.md` v2.5.3 Phase 1 § 2.
- AC: AC-A7 (release body template location: NEW file `templates/public-artifact/release-body.md` vs. section in CONTRIBUTING.md) → Bound to NEW file `templates/public-artifact/release-body.md`. — Reason: Cowork repo's existing convention is `templates/<purpose>/<file>` (`templates/preset-template/`, `templates/skill-template/`, `templates/global-instructions-base.md`, `templates/writing-profile-template.md`). CONTRIBUTING.md scope is contributor process (DCO, CI, PR conventions); folding authorial templates there would muddle concerns. The directory `templates/public-artifact/` does not currently exist (verified 2026-05-10); @dev creates it with the file.
- AC: Scope B path binding (Path 1 workflow tail-preserve vs. Path 2 template-embed) → Bound to **Path 1**. — Reason: Marker-driven semantics preserve the v2.5.2 DO-NOT-REGENERATE marker contract (Path 2 silently deletes its semantic role); lower attack-surface delta (Path 1 = 1 file diff in `.github/workflows/sync-agency.yml`; Path 2 = 2 file diff including `.github/templates/THIRD-PARTY-NOTICES.template.md`); no secret-handling change in either path; Path 1 generalizes for future hand-maintained entries. See `docs/architecture.md` v2.5.3 Phase 1 § 6 for full rationale and threat model.

No other v2.5.3 modifications. All 24 v2.5.3 spec ACs achievable as-written.

---

## Proposed Changes

*Reserved for /spec --revise cycles. Not applicable at initial Phase 0.*

---

---

# Product Spec — Claude Cowork Config (v2.5.1)

> **Cycle:** Extended Thinking + Opus Onboarding Docs
> **Version bump:** v2.5.0 → v2.5.1 (patch — doc-only)
> **Status:** Phase 0 — Requirements
> **Date:** 2026-05-09T00:00:00Z
> **Prior cycle:** v2.5.0 MERGED sha:7a85ae6, tag v2.5.0, PR #44. Retro DONE 2026-05-09T23:30:00Z.
> **Classification:** STANDARD (doc-only, no security/compliance surface)
> **Mode:** quick

---

## Problem

Every user who opens the cowork-starter-kit today and does not enable Extended Thinking, or who runs on Sonnet instead of Opus, is leaving measurable quality on the table. The kit's onboarding (README Quick-start, SETUP-CHECKLIST, WIZARD) never instructs users to flip these two decisive quality knobs. This gap was identified from studying how experienced Claude users approach model quality — both Extended Thinking and Opus selection are consistently cited as the highest-leverage session-setup steps.

---

## Target Users

**Primary:** First-time kit users following the Quick-start or SETUP-CHECKLIST. They need the two setup instructions on screen before they type their first prompt.

**Secondary:** Returning users who open WIZARD.md for model guidance. They need Opus + Extended Thinking framing to replace the vague "Sonnet or higher" prior recommendation.

---

## Core Features (MVP)

### D-1a — README.md Quick-start Leading Bullets

Add two leading bullets at the top of the Quick-start section (before existing steps):
- "Toggle Extended Thinking ON in Cowork before you start"
- "Select Opus 4.x in the model dropdown"

- AC: AC-D1-1: `grep -ic "extended thinking" README.md` >= 1
- AC: AC-D1-4: `grep -ic "opus" README.md` >= 1 (model selection guidance)

### D-1b — SETUP-CHECKLIST.md "Before you start" Preface

Add a "Before you start" section above the existing 10-step checklist containing the same two items (Extended Thinking toggle + Opus selection).

- AC: AC-D1-2: `grep -ic "extended thinking" SETUP-CHECKLIST.md` >= 1
- AC: AC-D1-5: `grep -ic "opus" SETUP-CHECKLIST.md` >= 1
- AC: AC-D1-7: SETUP-CHECKLIST.md contains a "Before you start" section header at the top

### D-1c — WIZARD.md Model Guidance Update

Replace the current "Sonnet or higher" model recommendation with explicit Opus + Extended Thinking guidance. The existing `opusplan` notes for cost-sensitive presets (Research / Writing / Project-Management) are preserved — they remain valid cost-sensitive guidance.

- AC: AC-D1-3: `grep -ic "extended thinking" WIZARD.md` >= 1
- AC: AC-D1-6: `grep -ic "opus" WIZARD.md` >= 1
- AC: AC-D1-8: WIZARD.md does NOT contain the verbatim string "Sonnet or higher" (replaced)

---

## Out of Scope (v2.5.1)

- No new files
- No skill changes (skills/ pool untouched)
- No global-instructions.md changes (per-preset files untouched)
- No CI/quality.yml changes
- No CLAUDE.md word-count changes
- No cowork.lock.json changes
- No "Next up" teaser rewrite (stays v2.6 multi-tool)
- D-2 (prompt-gate skill) and D-3 (correcting-course rule) deferred to v2.5.2

---

## Technical Constraints

- **Stack:** Markdown + bash scripts. No application runtime.
- **CLAUDE.md word count:** Untouched. Must remain at 397 words (v2.5.0 value per AC-ZD-3 baseline).
- **"Next up" teaser:** README.md teaser pointing to v2.6 multi-tool authoring is UNCHANGED. Published commitment is binding.
- **cowork.lock.json:** Byte-unchanged (zero-diff).
- **skills/ pool:** Byte-unchanged (zero-diff).
- **ADR-033 release pattern:** VERSION + CHANGELOG + README badge + "Next up" teaser as atomic release commit.
- **Branch:** release/v2.5.1

---

## User Stories

- As a first-time user reading the README Quick-start, I see a reminder to toggle Extended Thinking ON and select Opus before I begin, so I get the best quality output from my first session.
- As a user running through the SETUP-CHECKLIST, I encounter a "Before you start" preface with Extended Thinking and Opus guidance before the 10-step checklist begins, so I configure the session correctly before proceeding.
- As a user consulting WIZARD.md for model guidance, I see explicit Opus + Extended Thinking instructions rather than a vague "Sonnet or higher" recommendation, so I know exactly what to set.

---

## Acceptance Criteria

| ID | Surface | Criterion | Verification |
|----|---------|-----------|--------------|
| AC-D1-1 | README.md | Extended Thinking mentioned | `grep -ic "extended thinking" README.md` >= 1 |
| AC-D1-2 | SETUP-CHECKLIST.md | Extended Thinking mentioned | `grep -ic "extended thinking" SETUP-CHECKLIST.md` >= 1 |
| AC-D1-3 | WIZARD.md | Extended Thinking mentioned | `grep -ic "extended thinking" WIZARD.md` >= 1 |
| AC-D1-4 | README.md | Opus mentioned (model selection) | `grep -ic "opus" README.md` >= 1 |
| AC-D1-5 | SETUP-CHECKLIST.md | Opus mentioned | `grep -ic "opus" SETUP-CHECKLIST.md` >= 1 |
| AC-D1-6 | WIZARD.md | Opus mentioned | `grep -ic "opus" WIZARD.md` >= 1 |
| AC-D1-7 | SETUP-CHECKLIST.md | "Before you start" section header at top | `grep -ic "before you start" SETUP-CHECKLIST.md` >= 1 |
| AC-D1-8 | WIZARD.md | "Sonnet or higher" string removed | `grep -c "Sonnet or higher" WIZARD.md` = 0 |
| AC-REL-1 | VERSION | Patch bump applied | `cat VERSION` = `2.5.1` |
| AC-REL-2 | CHANGELOG.md | v2.5.1 entry present | `head CHANGELOG.md \| grep -c '## \[2.5.1\]'` = 1 |
| AC-REL-3 | README.md | Badge updated | `grep -c 'version-2.5.1-green' README.md` = 1 |
| AC-REL-4 | README.md | "Next up" teaser unchanged | `grep -c 'Next up (v2.6)' README.md` >= 1 |
| AC-ZD-1 | cowork.lock.json | Byte-unchanged | `cmp` exit 0 vs v2.5.0 HEAD |
| AC-ZD-2 | skills/ pool | No SKILL.md edits | `cmp` exit 0 for all skills/ |
| AC-ZD-3 | CLAUDE.md | Word count unchanged | `wc -w CLAUDE.md` = 397 |
| AC-ZD-4 | Changed files | Only 5 files changed | `git diff main..release/v2.5.1 --stat` shows ONLY: README.md, SETUP-CHECKLIST.md, WIZARD.md, VERSION, CHANGELOG.md |

**Total: 8 D1 ACs + 4 REL ACs + 4 ZD ACs = 16 ACs**

---

## Edge Cases

**EC-1 — opusplan notes preservation:** WIZARD.md cost-sensitive preset notes referencing `opusplan` must NOT be removed. Verify `grep -c "opusplan" WIZARD.md` equals v2.5.0 baseline count post-edit.

**EC-2 — "Next up" teaser integrity:** README.md teaser line must contain "v2.6" literally. Any accidental edit during badge bump fails AC-REL-4.

**EC-3 — Section placement in SETUP-CHECKLIST.md:** "Before you start" must appear ABOVE the existing numbered checklist. If placed below, AC-D1-7 passes but the user intent (pre-checklist setup gate) is defeated. @qa verifies section ordering by line number during Phase 5.

**EC-4 — WIZARD.md partial replacement:** If "Sonnet or higher" is removed but Extended Thinking / Opus guidance is NOT added in its place, AC-D1-8 passes but AC-D1-3/D1-6 fail. @qa must verify all three WIZARD.md ACs together.

---

## Success Metrics

- **Primary:** 5-file diff on first push to release/v2.5.1. CI green. Zero rework.
- **Secondary:** All 16 ACs verified by @qa at Phase 5. No findings.
- **Tertiary:** "Before you start" guidance visible within the first screen of SETUP-CHECKLIST.md — user encounters Extended Thinking + Opus framing before reading any setup step.

---

## Assumptions

- **[CONFIRMED]** v2.5.0 shipped 2026-05-09. Retro complete. Cycle-reset marker absent — new cycle starts clean.
- **[CONFIRMED]** "Next up (v2.6): Multi-tool skill authoring" is publicly committed in README.md. This teaser stays unchanged.
- **[CONFIRMED]** WIZARD.md contains the string "Sonnet or higher" at v2.5.0 HEAD — to be replaced.
- **[CONFIRMED]** D-2 (prompt-gate skill) and D-3 (correcting-course rule) are deferred to v2.5.2 per approved plan at ~/.claude/plans/self-is-working-in-immutable-meerkat.md.
- **[ESTIMATED]** Doc edits to three files take less than 30 minutes of @dev time.
- **[UNTESTED]** Users who follow the "Before you start" guidance see measurably better output quality. No user data yet — this is the hypothesis.

---

## v2.5.2 Cycle — Quality Loop (D-2 + D-3)

> **Cycle:** v2.5.2 — Quality Loop
> **Version bump:** v2.5.1 → v2.5.2 (PATCH — opt-in new skill; see Patch-Level Exception note)
> **Status:** Phase 0 — Requirements
> **Date:** 2026-05-10T00:00:00Z
> **Replaces:** v2.5.1 spec (doc-only patch)
> **Classification:** COMPLIANCE-SENSITIVE
> **Routing:** Phase 2 `/legal` (@compliance) REQUIRED before `/design` — prompt-gate skill traces to external MIT-licensed pattern (addyosmani/agent-skills). Attribution preservation must be verified by @compliance before architecture is finalized.
> **Mode:** full

---

### Problem

Two quality-of-interaction gaps exist for every user who opens the kit:

1. **Vague prompts get generic answers.** When a user types an ambiguous or context-thin request, Claude has no automated path to enrich that request before executing. The `context/about-me.md`, `writing-profile.md`, and `working-rules.md` files exist precisely to inform execution — but Claude only reads them if the user or a SKILL.md rule directs it to. No automated gate bridges the gap between a vague prompt and those context files.

2. **Output corrections require full retyping.** When a user says "this is off" or "not quite right," the current behavior is to ask the user to re-describe what they want — forcing them to reproduce context they already provided. This is friction. A structured correction form with chips (tone / scope / format / depth / sources) lets users steer without retyping.

Both gaps compound over every session. A kit user who gets consistently generic answers from vague prompts is a kit user who stops using the kit.

---

### Scope

**D-2 — `skills/prompt-gate/SKILL.md` (NEW)**

A Cowork-native port of The-Council's prompt-gate pattern. Four-phase workflow:

1. **Context check** — read `context/about-me.md`, `writing-profile.md`, `working-rules.md`. If any file is missing OR contains unfilled template placeholders AND is clearly relevant to the requested task → emit AskUserQuestion with chips "Fill now" / "Skip" / "Run the wizard". If the file is irrelevant to the task → silently skip.
2. **Workspace research** — scan PROJECTS/TEMPLATES and any cowork-profile.md for context relevant to the request.
3. **Clarify** — emit 1–3 AskUserQuestion items grounded in Phase 1 + Phase 2 findings. Never ask a question answerable from the context files.
4. **Execute** — proceed with enriched understanding. Do not re-surface resolved questions.

Self-evaluation gate: the skill must decide whether to fire at all. Trivial prompts (clear intent, bounded scope, no context dependency) proceed directly to Phase 4. The `*` prefix bypass is preserved (Council convention: `*` prefix = skip evaluation, execute directly).

Wired into all 7 presets' `global-instructions.md` — kit auto-loading carries the rule into every session without user paste.

**D-3 — `prompts/correcting-course.md` (NEW) + global-instructions injection**

A correction-handling rule: "When the user says output is off, do not ask them to re-type. Generate an AskUserQuestion form with concrete adjustment chips (tone / scope / format / depth / sources). Free-text remains the escape hatch via an 'Other' chip."

Stored as `prompts/correcting-course.md` and injected by reference into all 7 presets' `global-instructions.md`.

**Release artifacts**

- `VERSION` bump: 2.5.1 → 2.5.2
- `README.md` badge: version badge value rotates 2.5.1 → 2.5.2
- `CHANGELOG.md` [2.5.2] entry: lists prompt-gate + correcting-course in user terms; includes Patch-Level Exception note
- `README.md` "Next up (v2.6)" teaser: UNCHANGED (locked — multi-tool is publicly committed)
- GitHub release body: cites prompt-gate + correcting-course in plain language; flags patch exception

**Patch-Level Exception note (required in release artifacts):**
> "A new opt-in skill (prompt-gate) ships at patch level here because the v2.6 minor slot is publicly committed to multi-tool skill authoring. The skill is auto-loaded via global-instructions but can be removed from any preset's global-instructions.md without other changes. Future new-skill cycles default back to minor version bumps."

---

### Acceptance Criteria

**D-2 — prompt-gate skill**

- **AC-D2-1:** `skills/prompt-gate/SKILL.md` exists and passes the existing CI `skill-depth-check` gate (9-section structure, ≥60 line floor, `tools: [claude-code]` frontmatter field present). `grep -c "tools:" skills/prompt-gate/SKILL.md` = 1.
- **AC-D2-2:** Prompt-gate 4-phase workflow is present in SKILL.md: Phase 1 context check, Phase 2 workspace research, Phase 3 clarify (1–3 questions), Phase 4 execute. Each phase heading appears as a heading in the file.
- **AC-D2-3:** `*` prefix bypass is documented in SKILL.md: a section or note explicitly states that prompts beginning with `*` skip evaluation and execute directly.
- **AC-D2-4:** Missing/placeholder file detection is documented: SKILL.md specifies that if `context/about-me.md`, `writing-profile.md`, or `working-rules.md` is absent OR contains unfilled template placeholders AND is relevant to the task, the skill emits an AskUserQuestion with chips "Fill now" / "Skip" / "Run the wizard".
- **AC-D2-5:** Self-evaluation gate is documented: SKILL.md includes guidance on when NOT to fire (trivial prompts — clear intent, bounded scope, no context dependency).
- **AC-D2-6:** Attribution block is present in SKILL.md tracing the 4-phase pattern to the MIT-licensed source (addyosmani/agent-skills), matching the format used in The-Council's prompt-gate SKILL.md.
- **AC-D2-7:** All 7 presets' `global-instructions.md` files contain a prompt-gate reference block. `grep -rl "prompt-gate" examples/*/global-instructions.md | wc -l` = 7.
- **AC-D2-8:** `curated-skills-registry.md` contains a row for `prompt-gate` under an appropriate section (all goal_tags, Tier 1, source_url = builtin). `grep -c "prompt-gate" curated-skills-registry.md` = 1.
- **AC-D2-9 (edge case — irrelevant file):** SKILL.md documents that if a context file exists but is irrelevant to the task (e.g., writing-profile.md exists but the task is a math calculation), the skill silently skips that file rather than surfacing it.
- **AC-D2-10 (edge case — all context present):** SKILL.md documents behavior when all context files are present and filled: skip Phase 1 bootstrap offer entirely, proceed to Phase 2.
- **AC-D2-11 (edge case — trivial prompt):** SKILL.md documents what constitutes a trivial prompt that bypasses enrichment (example: "What time is it?", "Summarize this paragraph:" with content attached).

**D-3 — correcting-course**

- **AC-D3-1:** `prompts/correcting-course.md` exists. File defines the correction-handling rule: when user says output is off, do not ask for retyping; emit AskUserQuestion form with adjustment chips covering at minimum: tone, scope, format, depth, sources.
- **AC-D3-2:** An "Other" free-text escape chip is documented in `prompts/correcting-course.md`.
- **AC-D3-3:** All 7 presets' `global-instructions.md` files contain a correcting-course reference block. `grep -rl "correcting-course" examples/*/global-instructions.md | wc -l` = 7.
- **AC-D3-4 (edge case — cascading correction):** `prompts/correcting-course.md` documents behavior for multiple consecutive corrections: each correction generates a fresh AskUserQuestion form; prior unanswered form chips do not persist.

**Release artifacts**

- **AC-REL-1:** `VERSION` file contains exactly `2.5.2`. `cat VERSION` = `2.5.2`.
- **AC-REL-2:** `README.md` version badge URL value contains `2.5.2`. `grep "version-2.5.2" README.md` returns a match.
- **AC-REL-3:** `README.md` "Next up (v2.6)" line is byte-identical to HEAD v2.5.1. `grep "Next up" README.md` = `**Next up (v2.6):** Multi-tool skill authoring (v3.0 routing intent) — individual skills validated for Copilot/Cursor/Windsurf and widened beyond \`claude-code\`.` (exact).
- **AC-REL-4:** `CHANGELOG.md` contains a `## [2.5.2]` section prepended above `## [2.5.1]`. Section mentions prompt-gate and correcting-course by name.
- **AC-REL-5:** `CHANGELOG.md` [2.5.2] section contains the Patch-Level Exception note explaining why a new skill ships at patch level.
- **AC-REL-6 (edge case — ordering):** `CHANGELOG.md` version order is: [2.5.2] above [2.5.1] above [2.5.0]. No version entry is out of sequence.

**Preservation invariants (zero-diff)**

- **AC-ZD-1:** `cowork.lock.json` is byte-unchanged from v2.5.1 HEAD. `cmp cowork.lock.json <v2.5.1-HEAD-cowork.lock.json>` exits 0.
- **AC-ZD-2:** `CLAUDE.md` word count ≤ 400. `wc -w CLAUDE.md` ≤ 400.
- **AC-ZD-3:** No existing preset's core content files (other than `global-instructions.md`) are modified. Only `global-instructions.md` changes in each preset folder.
- **AC-ZD-4:** `docs/architecture.md` is unchanged (no new ADRs this cycle — prompt-gate is a skill, not an architectural decision requiring an ADR). `git diff HEAD -- docs/architecture.md` is empty.
- **AC-ZD-5:** CI workflow files (`.github/workflows/`) are unchanged except for any strictly required update to register the new skill in the CI depth-check `POOL` loop if `skills/prompt-gate/SKILL.md` is not auto-detected. If a CI change IS required: it is limited to adding `prompt-gate` to the POOL allowlist only. No other CI changes.

---

### Will-Not-Do (v2.5.2)

- v2.6 multi-tool skill authoring work — any change that widens the `tools:` vocabulary or adds Copilot/Cursor/Windsurf validation
- v2.5.3 v43 framework application (deferred — separate cycle)
- Any fix for open Issues #18–23 (separate cycles; these are v2.0.1 tech-debt and hallucinated SHA items)
- Changes to `cowork.lock.json`, `docs/architecture.md` (no new ADRs), or CI workflow files beyond the strict minimum in AC-ZD-5
- Changes to any preset's core content files other than `global-instructions.md`
- Any prompt-gate behavior that modifies user files without explicit user confirmation
- Adding a new `prompts/` directory if it requires CLAUDE.md changes beyond the word-count ceiling

---

### Classification

**COMPLIANCE-SENSITIVE.**

External content detection fired: The-Council's prompt-gate SKILL.md carries an attribution block tracing the 4-phase context-enrichment pattern to `addyosmani/agent-skills` (`skills/context-engineering/SKILL.md` @ commit `9534f44c5448086fcc0046f9d83752c654c81930`, MIT License). Porting this pattern to cowork's `skills/prompt-gate/SKILL.md` carries forward the same attribution obligation.

**Both repos (The-Council + cowork-starter-kit) are owned by the same author.** This is not a third-party import. However:
1. The underlying pattern is MIT-licensed from a third party (Addy Osmani).
2. The MIT License requires attribution preservation in any derived work.
3. Per `docs/pipeline-policy.md#ThirdPartyContentImport`, @compliance must verify attribution format before architecture is finalized.

**Required action:** Run `/legal` (Phase 2 @compliance) before `/design`. @compliance must confirm: (a) attribution block format in SKILL.md is sufficient for MIT license compliance, (b) `docs/ATTRIBUTIONS.md` in cowork should reference the same upstream source, and (c) no additional license obligations apply.

Classification is NOT SECURITY-SENSITIVE. The prompt-gate is opt-in via global-instructions, introduces no auth/RLS/schema/external-API surface, and handles no sensitive data. Standard STANDARD-tier security checks apply at Phase 6.

---

### Technical Constraints

- **Stack:** Markdown-only. No code, no dependencies, no package manager.
- **Skill format:** Must pass existing CI `skill-depth-check` gate: 9-section SKILL.md structure, ≥60 lines, `tools: [claude-code]` frontmatter.
- **Preset injection:** `global-instructions.md` is auto-loaded by Cowork when the preset folder is opened as a project. Injection must be additive (append new sections) — existing proactive-skill sections and session-start behaviors are not modified.
- **`prompts/` directory:** Does not currently exist. @architect must decide whether to create it as a bare directory or document its convention in `docs/architecture.md`. See AC-ZD-4 (no ADR required — prompt directory is a convention, not an architectural decision; a comment in CONTRIBUTING.md is sufficient).
- **CI impact:** The existing `skill-depth-check` CI job validates all `skills/*/SKILL.md` files. `prompt-gate` must either auto-pass or require only a minimal POOL allowlist addition (see AC-ZD-5).
- **Attribution:** The Cowork SKILL.md's attribution block must match the format used in The-Council's `docs/ATTRIBUTIONS.md` and the inline attribution in The-Council's prompt-gate SKILL.md.
- **Word budget:** `CLAUDE.md` must stay ≤ 400 words (AC-ZD-2). Prompt-gate and correcting-course are referenced from `global-instructions.md`, not CLAUDE.md — no CLAUDE.md changes expected.

---

### User Stories

- As a Cowork user opening a preset workspace with an unfilled context file, I want an automatic offer to fill it before my first task runs, so I don't get generic output because I forgot to configure my profile.
- As a Cowork user typing a vague request, I want Claude to ask 1–3 grounded clarifying questions before executing, so the output matches what I actually needed.
- As a Cowork user whose output missed the mark, I want a structured correction form with preset chips, so I can steer the next output without retyping my full context.
- As a Cowork user who knows exactly what they want, I want to prefix my message with `*` to skip the enrichment gate entirely, so I'm never blocked by a gate I don't need.
- As a Cowork preset user, I want prompt-gate and correcting-course behavior automatically loaded into every session, so I don't have to paste or configure anything.

---

### Success Metrics

- **Primary:** Prompt-gate fires on vague prompts in all 7 presets without user configuration (verified by AC-D2-7 grep pass).
- **Secondary:** Zero rework commits post-Phase-4 (target: 0% rework rate, consistent with v2.5.1 clean cycle).
- **Secondary:** CI passes on first push (42+ PASS / 0 FAIL target, consistent with v2.5.1 baseline).
- **Lagging (post-launch, unmeasured):** [UNTESTED] Users who receive a prompt-gate clarification form report better output relevance than users who do not. No measurement tooling exists yet.

---

### Risks

- **R1 [MEDIUM]:** Prompt-gate fires on trivial prompts, generating friction for experienced users. Mitigation: explicit self-evaluation gate in SKILL.md (AC-D2-5) + `*` prefix bypass (AC-D2-3). @security review at Phase 6 to verify no prompt-injection surface is introduced by AskUserQuestion chip options.
- **R2 [LOW]:** CI `skill-depth-check` rejects `prompt-gate` due to unrecognized structure or POOL allowlist gap. Mitigation: AC-ZD-5 explicitly scopes the allowed CI change. @dev must verify CI locally before pushing.
- **R3 [LOW]:** `prompts/` directory creation triggers an unexpected CI lint failure (new directory pattern not covered by existing gates). Mitigation: @architect assesses CI impact at Phase 1.
- **R4 [LOW-MEDIUM]:** Attribution block format in cowork's SKILL.md is insufficient for MIT license compliance (different repo context, no ATTRIBUTIONS.md equivalent yet). Mitigation: @compliance verifies at Phase 2 `/legal` before @architect finalizes the SKILL.md template.

---

### Assumptions

- **[CONFIRMED]** v2.5.1 Phase 8 complete. Cycle-reset marker present. Pipeline unblocked for v2.5.2.
- **[CONFIRMED]** The-Council prompt-gate SKILL.md carries attribution to `addyosmani/agent-skills` MIT License — porting requires attribution preservation. @compliance review mandatory.
- **[CONFIRMED]** All 7 preset folders are: `business-admin`, `creative`, `personal-assistant`, `project-management`, `research`, `study`, `writing`. Each has a `global-instructions.md`.
- **[CONFIRMED]** `prompts/` directory does not exist in the repo at v2.5.1 HEAD.
- **[CONFIRMED]** `README.md` "Next up (v2.6)" teaser is publicly committed and must be preserved byte-identical.
- **[CONFIRMED]** Existing CI `skill-depth-check` validates `skills/*/SKILL.md` pool. New `prompt-gate` skill must pass or require only POOL allowlist addition.
- **[ESTIMATED]** Prompt-gate and correcting-course rules together take @dev ≤ 2 hours to implement (markdown files, no code).
- **[UNTESTED]** The prompt-gate self-evaluation gate reliably skips trivial prompts without user instruction. Requires manual behavioral testing at Phase 5.

---

## v2.5.3 Cycle — v43 Framework Application + O-1 Guard

> **Cycle:** v2.5.3 — Public Artifact + THIRD-PARTY-NOTICES Guard
> **Version bump:** v2.5.2 → v2.5.3 (PATCH)
> **Status:** Phase 0 — Requirements
> **Date:** 2026-05-10T14:30:00Z
> **Predecessor:** v2.5.2 SHIPPED (PR #46, tag v2.5.2, retro `c71b208`). Phase 8 DONE. Cycle-reset marker present.
> **Classification:** SECURITY-SENSITIVE (Scope B: sync-agency.yml is a supply-chain workflow with `contents: write` + `pull-requests: write` permissions; any modification requires full Phase 2 /review + Phase 6 audit)
> **Routing:** Phase 2 `/review` (@security FULL) required. Scope A is STANDARD (public artifact polish, read-mostly) — combined classification takes the higher: **SECURITY-SENSITIVE**.
> **Cycle-fit verdict:** PASS — one cycle. Scope A ~5 files (markdown polish); Scope B ~1–2 files (workflow + optional template).

---

### Problem

Two carry-forward issues from v2.5.2 require resolution before the next non-patch release:

**Problem A — Public artifact quality gap:** The v43 Public Artifact Strategy framework shipped in The-Council (v43/v43.1) but has not been applied to cowork-starter-kit's public-facing artifacts. The README, SETUP-CHECKLIST, CONTRIBUTING, GitHub release body template, and repo metadata (description/topics) were last refreshed at v2.4 and have not been evaluated against the `how-to` profile IA or the Tier 1 SEO signal checklist. Specifically:
- README first 250 chars begins with `# cowork-starter-kit` (H1 title) then a blockquote value prop — this fails the S4 "no title block before positioning" constraint per the `how-to` profile.
- No "Who is this for" section exists within the first 300 words (S5 gap).
- Current H2 section order (`The problem` → `How it works` → `Quick start` → `What can you build?` → `Seven goal presets`) does not match the `how-to` prescribed IA (value prop → Who is this for → Demo → Quick start → What's included → How to extend → Credits).
- GitHub repo description and Topics are unverified against Tier 1 SEO standards (skipped — github.enabled=false for cowork; surfaced for manual check).
- Release body template not yet codified per the v43 release body structure.

**Problem B — DO-NOT-REGENERATE marker not honored by workflow (O-1):** `THIRD-PARTY-NOTICES.md` contains a `<!-- DO-NOT-REGENERATE: ... -->` marker at line 61 protecting the `## Direct Pattern Incorporations` section added in v2.5.2. The marker is present and documented, but `sync-agency.yml` step "Regenerate THIRD-PARTY-NOTICES.md" (lines 338–356) uses `envsubst` + `awk` to write the file from `.github/templates/THIRD-PARTY-NOTICES.template.md` — it replaces the entire file. The next upstream SHA bump will wipe the `addyosmani/agent-skills` MIT entry. The defense-in-depth (Option A embedded attribution in `skills/prompt-gate/SKILL.md`) mitigates the MIT compliance risk, but the NOTICES file state will silently regress. This must be fixed before any upstream sync run.

---

### Scope A — v43 Public Artifact Framework Application

#### Profile assignment

cowork-starter-kit maps to **Profile 1: `how-to`** per `docs/public-artifact-strategy.md` §2 and §8 (confirmed: primary user accomplishes a task quickly; non-technical README audience; not an inhabited daily system; not internal infra).

#### Surface checklist (extracted from G1 + strategy doc)

All surfaces subject to v43 framework standards. Scope A applies the framework — it does not require new Council deliverables.

| Surface | Location | Work required |
|---------|----------|---------------|
| README positioning (S4) | `README.md` lines 1–6 | Remove H1 title block; move value proposition to first visible text (≤160 chars). No badge block before the prop. |
| "Who is this for" section (S5) | `README.md` | Add H2 section within first 300 words; 3 bullets max, ≤200 words total. Audience: Alex (student), Sam (knowledge worker), Jordan (project manager). No competitor naming. |
| IA section order | `README.md` | Reorder top sections to match `how-to` prescribed order: (1) value prop text, (2) Who is this for, (3) Demo/flow diagram, (4) Quick start, (5) What's included, (6) How to extend, (7) Credits/Attribution. Existing content preserved; reordering only (no rewrites unless S4/S5 require new copy). |
| README version badge | `README.md` | Bump `version-2.5.2-green` → `version-2.5.3-green`. "Next up (v2.6)" teaser: BYTE-IDENTICAL (AC-REL-3 carry-forward). |
| SETUP-CHECKLIST narrative | `SETUP-CHECKLIST.md` | Audit against `how-to` tone guidance: warm, practical, "you" framing. Update header to reflect v2.5.3 as current version. No structural changes unless tone is materially off. |
| CONTRIBUTING positioning | `CONTRIBUTING.md` | Add 1–2 sentences at top framing contributor value (trust signal). Existing checklist content byte-unchanged. |
| GitHub release body template | `templates/public-artifact/release-body.md` (NEW — if not already present) OR `CHANGELOG.md` release note guidance | Codify the v43 release body structure per `docs/public-artifact-strategy.md §7` for future releases. Either create `templates/public-artifact/release-body.md` with the template or add a `## Release notes guidance` section to CONTRIBUTING.md. @architect decides at Phase 1 which location fits the repo's existing template convention. |
| Repo description (S1/S2) | GitHub repo settings | SKIPPED in-cycle (github.enabled=false). Document proposed description in spec for manual application post-merge: "Configure your Claude Cowork workspace in 15 minutes — goal-based preset wizard, 20 curated skills, no code required." |
| GitHub Topics (S3) | GitHub repo settings | SKIPPED in-cycle. Proposed topics for manual application: `claude-ai`, `claude-project`, `ai-workspace`, `productivity`, `prompt-engineering`, `workflow`, `no-code`, `starter-kit`, `anthropic` |
| SEO/positioning copy | README, SETUP-CHECKLIST | Apply `how-to` vocabulary register: plain English, no jargon without inline definition, "you" framing, active voice. |

#### IA drift baseline (pre-v2.5.3)

Current README H2 order vs. prescribed `how-to` order:

| Slot | Prescribed | Current | Match? |
|------|-----------|---------|--------|
| 1 | Value prop (text, no heading) | H1 title + blockquote | FAIL (S4) |
| 2 | Who is this for | (absent) | FAIL (S5) |
| 3 | Demo / flow diagram | How it works | Partial (content matches but placement wrong) |
| 4 | Quick start | Quick start | PASS |
| 5 | What's included | What can you build? + Seven goal presets | Partial |
| 6 | How to extend | (absent) | MISS |
| 7 | Credits / Attribution | License | Partial (no explicit Credits H2) |

IA Drift score: **0/3** matching top headings against prescribed profile order. Correction required.

---

### Scope B — O-1 sync-agency.yml THIRD-PARTY-NOTICES Guard

#### Current state

- `THIRD-PARTY-NOTICES.md` contains a `<!-- DO-NOT-REGENERATE: hand-maintained section; sync-agency.yml regeneration must preserve below this marker -->` comment at line 61.
- `sync-agency.yml` step "Regenerate THIRD-PARTY-NOTICES.md" (line 338) uses:
  ```
  envsubst '$NOW $NEW_SHA $NEW_LICENSE_SHA256' < .github/templates/THIRD-PARTY-NOTICES.template.md > /tmp/notices-stage1.md
  awk '/<<LICENSE_TEXT>>/{system("cat /tmp/upstream-LICENSE"); next} {print}' /tmp/notices-stage1.md > THIRD-PARTY-NOTICES.md
  ```
  This unconditionally replaces the entire output file from the template. The marker in `THIRD-PARTY-NOTICES.md` is NOT read by the workflow — it exists as documentation only.
- `.github/templates/THIRD-PARTY-NOTICES.template.md` is the authoritative source for the regeneration step. The `## Direct Pattern Incorporations` section is NOT present in this template.

#### Implementation paths (architect binds one at Phase 1)

**Path 1 — Patch sync-agency.yml to preserve tail content below marker.**
Modify the "Regenerate THIRD-PARTY-NOTICES.md" step to:
1. Run the existing `envsubst` + `awk` pipeline into `/tmp/notices.md` (no change).
2. Extract preserved content: `awk '/<!-- DO-NOT-REGENERATE/{found=1} found{print}' THIRD-PARTY-NOTICES.md > /tmp/notices-tail.md`
3. Concatenate: `cat /tmp/notices.md /tmp/notices-tail.md > THIRD-PARTY-NOTICES.md`
- Pros: marker-driven, single source of truth is the live file, works for any future hand-maintained entries.
- Cons: workflow complexity increases; tail extraction must handle marker absent case gracefully (fallback: no-op tail append).
- Security note: no new external data ingestion; operates only on repo-internal files. Minimal attack surface change.

**Path 2 — Add the Direct Pattern Incorporations section to `.github/templates/THIRD-PARTY-NOTICES.template.md`.**
Add the `## Direct Pattern Incorporations` block verbatim (as it appears in the live file below the marker) to the template. The workflow regeneration then produces the correct output including the addyosmani entry.
- Pros: no workflow logic change; simpler; template is the single source.
- Cons: future hand-maintained entries require a template edit AND a workflow run to round-trip; the DO-NOT-REGENERATE marker loses its function (must be removed or reframed). Any new `## Direct Pattern Incorporations` entry requires both a template edit and a cycle.
- Security note: no workflow change; same attack surface as today.

**Recommended default:** @architect should prefer Path 1 if the workflow's `set -e` discipline and step isolation can cleanly absorb the tail-extraction logic. Path 2 is acceptable if @architect judges Path 1 adds excessive workflow complexity. Either path resolves the O-1 gap.

#### Acceptance criteria — Scope B

- **AC-B1:** After the patch, a simulated regeneration (running the patched workflow step locally or in CI) produces a `THIRD-PARTY-NOTICES.md` that contains the `## Direct Pattern Incorporations` section intact below the DO-NOT-REGENERATE marker.
- **AC-B2:** The `addyosmani/agent-skills` entry (source, license, copyright, pinned commit, full MIT text) is present and byte-identical to the v2.5.2 committed version in the output of AC-B1 simulation.
- **AC-B3:** The auto-generated header section (`## msitarzewski/agency-agents`, timestamps, SHA) is still regenerated correctly by the workflow — hand-maintained section preservation does not corrupt the upstream-generated content.
- **AC-B4:** If Path 1: the workflow step handles the case where the DO-NOT-REGENERATE marker is absent from the current `THIRD-PARTY-NOTICES.md` without error (no-op: produce only the generated section, no tail append).
- **AC-B5:** CI passes — `quality.yml` and `sync-agency-dry-run` (if applicable) remain green after the patch.
- **AC-B6:** `sync-agency.yml` retains its `permissions: read-all` at workflow level; per-job grants (`contents: write`, `pull-requests: write`) are unchanged.

---

### Acceptance Criteria — Scope A

- **AC-A1:** `README.md` first 250 characters begin with the positioning statement — no H1 title, no badge, no blockquote wrapper. The value proposition text is the first visible content.
- **AC-A2:** A `## Who is this for` section (or equivalent audience-clarity H2) appears within the first 300 words of `README.md`. Contains 3 bullets max identifying primary user types by context (not competitor naming).
- **AC-A3:** README H2 section order matches the `how-to` prescribed IA for the top 3 sections: (1) value prop text, (2) audience section, (3) demo/flow. `IA Drift ≥ 2/3` against `how-to` profile (target: 3/3).
- **AC-A4:** README version badge reads `version-2.5.3-green`. The "Next up (v2.6)" teaser line is byte-identical to the v2.5.2 committed version.
- **AC-A5:** `SETUP-CHECKLIST.md` header or introductory paragraph references v2.5.3 as the current version (or references the Releases page dynamically). Tone audit: at least 3 "you"-framed sentences in the first 10 steps.
- **AC-A6:** `CONTRIBUTING.md` first section includes a contributor value statement (1–2 sentences). Existing checklist content is byte-unchanged.
- **AC-A7:** A v43-compliant release body template is available in the repo — either as `templates/public-artifact/release-body.md` (new file) or as a documented section in CONTRIBUTING.md. The template contains the required structure: project name, positioning statement placeholder, "What changed" (2–3 bullets), "Breaking changes", "Full changelog" link, "What's next" teaser. All `[REPLACE:*]` markers are present and named.
- **AC-A8:** No competing tools, vaults, or creators are named in any public copy added or modified by this cycle (per `feedback_no_competitor_naming_public`).
- **AC-A9:** `CHANGELOG.md` prepends a `## [2.5.3] — 2026-05-10` entry with "Changed" subsection summarizing Scope A/B changes. VERSION file reads `2.5.3`.

---

### Combined Acceptance Criteria — Release artifacts

- **AC-REL-1:** VERSION file reads `2.5.3`.
- **AC-REL-2:** CHANGELOG prepends `## [2.5.3] — <date>` with Scope A + Scope B summaries.
- **AC-REL-3:** README "Next up (v2.6)" line is BYTE-IDENTICAL to v2.5.2 committed version (hard lock — carry-forward from v2.5.2).
- **AC-REL-4:** README CI badge URL references the correct workflow path (unchanged from v2.5.2).

---

### Zero-Diff Constraints (will-not-do this cycle)

- **AC-ZD-1:** `cowork.lock.json` is byte-unchanged. No SHA bumps, no field additions.
- **AC-ZD-2:** `CLAUDE.md` is unchanged. No wizard flow edits.
- **AC-ZD-3:** No new ADRs added. No existing ADR sections modified.
- **AC-ZD-4:** `examples/*/global-instructions.md`, `skills/*/SKILL.md`, `selection-presets.md`, `curated-skills-registry.md` are byte-unchanged.
- **AC-ZD-5:** `prompts/correcting-course.md` and `skills/prompt-gate/SKILL.md` are byte-unchanged.

---

### Will-Not-Do (v2.5.3)

- v2.6 multi-tool work (reserved for v2.6 cycle)
- Any new ADR additions (v2.5.3 is application, not authoring)
- Issues #18–23 fixes (separate cycles per scope lock)
- Any change to v2.5.2 prompt-gate skill or correcting-course rule
- `cowork.lock.json` byte changes
- Competitive intelligence or positioning research (cowork public copy must not name competitors per `feedback_no_competitor_naming_public`)
- ADR-025 amendment (deferred until a third hand-maintained THIRD-PARTY-NOTICES entry — O-4 carry from v2.5.2)

---

### Technical Constraints

- **Stack:** GitHub-hosted repo, no Next.js/Supabase. All files are Markdown, YAML, JSON, shell scripts.
- **Workflow constraint:** `sync-agency.yml` runs on `ubuntu-latest` with `permissions: read-all` (workflow level). Any patch to the regeneration step must NOT change the workflow-level permissions block (AC-B6).
- **CI:** `quality.yml` + `sync-agency-dry-run` (PR-only). V45-A3: run local CI smoke before push.
- **Worktree:** Phase 4 work in a release branch (not main). Orchestrator pre-updates registry before Phase 4 per "Worktree path mismatch" watch pattern.
- **Classification:** SECURITY-SENSITIVE — full Phase 2 /review + Phase 6 audit required. @security must produce a Guard Change Summary for the sync-agency.yml patch (analogous to the guard PR rule; workflow file = supply-chain surface).
- **Scope B path binding:** @architect binds Path 1 or Path 2 at Phase 1. Both are valid; spec does not constrain the choice.

---

### Edge Cases

1. **DO-NOT-REGENERATE marker absent from template:** If Path 1 is chosen and a future regeneration runs against a `THIRD-PARTY-NOTICES.md` that has no marker (e.g., file was reset), the tail-extraction must produce no output (no-op) rather than erroring. AC-B4 covers this.
2. **README reorder breaks existing anchor links:** If external sites link to specific README section anchors, reordering H2s will break those links. Mitigation: verify no inbound anchor links in GitHub Issues, external docs, or SETUP-CHECKLIST before committing reorder. Low risk for a PATCH cycle on a config repo.
3. **"Who is this for" copy inadvertently names a competing tool:** Reviewer must check all new copy against `feedback_no_competitor_naming_public`. Three user personas (student, knowledge worker, project manager) are safe archetypes.
4. **Template file path conflict:** If `templates/public-artifact/release-body.md` already exists (created in a prior cycle), @dev must read it before overwriting. Verify with `ls templates/public-artifact/` at Phase 4 start.
5. **sync-agency.yml SHA hallucination (Issue #23):** Issue #23 flagged a hallucinated `peter-evans/create-pull-request` SHA — this is already at `67ccf781d68cd99b580ae25a5c18a1cc84ffff1f` in the current file (verified at v2.5.2). The Scope B patch must NOT alter the SHA or any other existing step. Any accidental SHA change must be caught at Phase 5.

---

### Risks

- **R1 [MEDIUM]:** README reorder degrades discoverability if the reordered content loses keyword density in the first 250 chars. Mitigation: the new positioning statement must contain the top 2–3 keyword phrases from the proposed repo description ("Claude Cowork workspace", "15 minutes", "no code").
- **R2 [LOW]:** Path 1 tail-extraction logic introduces a shell bug (e.g., marker grep mismatch, file encoding issue). Mitigation: @qa must simulate regeneration in Phase 5 — run the patched step against the current THIRD-PARTY-NOTICES.md and diff the output.
- **R3 [LOW]:** `templates/public-artifact/` directory does not exist in the cowork repo (The-Council has it; cowork may not). @dev must check at Phase 4 start and create if absent.
- **R4 [INFO]:** github.enabled=false for cowork means S1/S2/S3 signals (repo description, topics) cannot be auto-verified by G1. Proposed description and topics are documented in this spec for manual application post-merge by the operator.

---

### Classification

**SECURITY-SENSITIVE** — Scope B modifies `.github/workflows/sync-agency.yml`, a supply-chain workflow with `contents: write` + `pull-requests: write` job-level permissions. Per the Council's guard PR rule analog and `docs/pipeline-policy.md`, any modification to this workflow requires:
- Phase 2 `/review` (@security FULL OWASP pass on the workflow diff)
- Phase 6 `/audit` (@security code audit)
- @security must produce a plain-language Guard Change Summary (what changed, what could break, what's protected, what to verify after merge) — attached to the PR description before user approves merge.

Scope A is STANDARD (public artifact markdown polish, no auth/RLS/workflow/dependency surface). Combined classification: SECURITY-SENSITIVE.

---

### Success Metrics

- **Primary:** G1 audit score improves from 0/3 IA drift to ≥2/3 after v2.5.3 ships. Measurable by running `/refresh-public claude-cowork-config` post-merge.
- **Secondary:** O-1 carry-forward resolved — `sync-agency.yml` regeneration produces correct `THIRD-PARTY-NOTICES.md` with `## Direct Pattern Incorporations` section intact (verified by AC-B1 simulation at Phase 5).
- **Secondary:** CI passes on first push (42+ PASS / 0 FAIL — V45-A3 discipline).
- **Lagging (post-merge, manual):** Operator applies proposed repo description and topics via `gh repo edit` — S1/S2/S3 signals become PASS on next `/refresh-public` run.

---

### Assumptions

- **[CONFIRMED]** v2.5.2 Phase 8 complete. Cycle-reset marker present. Pipeline unblocked for v2.5.3.
- **[CONFIRMED]** `THIRD-PARTY-NOTICES.md` DO-NOT-REGENERATE marker is at line 61 and the `## Direct Pattern Incorporations` section is hand-maintained below it (verified at v2.5.2 HEAD).
- **[CONFIRMED]** sync-agency.yml uses `.github/templates/THIRD-PARTY-NOTICES.template.md` as the sole template for regeneration (lines 347–348 confirmed). The template does NOT contain the `## Direct Pattern Incorporations` section.
- **[CONFIRMED]** cowork-starter-kit maps to `how-to` profile per v43 public artifact strategy. Profile-1 IA is the binding standard.
- **[CONFIRMED]** README current IA Drift score is 0/3 (top 3 H2 headings: `The problem`, `How it works`, `Quick start` — none match the prescribed `how-to` top 3 positions).
- **[CONFIRMED]** `templates/public-artifact/` exists in The-Council but its presence in cowork repo is unverified. @dev must check at Phase 4 start.
- **[CONFIRMED]** github.enabled=false for cowork — S1/S2/S3 signals skipped in-cycle; documented for manual application.
- **[ESTIMATED]** Scope A (README reorder + copy polish + SETUP/CONTRIBUTING touches) takes @dev ≤ 2 hours. Scope B (workflow patch) takes @dev ≤ 1 hour.
- **[UNTESTED]** README reorder does not break any inbound anchor links. Reviewer must check before merge.

---

## v2.5.4 Cycle — Pivot Framing Realignment

> **Cycle:** v2.5.4 — Pivot Framing Realignment (copy-only hotfix)
> **Version bump:** 2.5.3 → 2.5.4 (PATCH)
> **Status:** Phase 0 — Requirements
> **Date:** 2026-05-10T23:30:00Z
> **Mode:** Quick
> **Classification:** STANDARD (copy-only; no auth/schema/compliance/CI surface)

---

### Problem

v2.4.0 shipped the Dynamic Workspace Architect pivot ("open-ended goal discovery replaces preset menus"). The functional implementation is complete and aligned across all 14 files audited. However, two surface-level artifacts were not updated in the pivot cycle:

1. **README line 1 (hero):** still reads "goal-based preset wizard" — contradicts the v2.4 pivot where presets are *suggestions*, not menus.
2. **SETUP-CHECKLIST.md Step 1 sequencing:** presents preset-paste as the primary action before goal discovery, inverting the v2.4 mental model.

The GitHub repo description already reads correctly: "Build a Claude workspace from your goal — the Dynamic Wizard maps it to vetted agents." The README hero must match this tone. Everything else (CLAUDE.md, WIZARD.md, CONTRIBUTING.md, all 20 skills, CHANGELOG, selection-presets.md) is confirmed aligned — no changes needed.

---

### Scope

**TIER 1 — README hero rewrite (1 line)**
- Replace `/home/user/claude-cowork-config/README.md` line 1 from "goal-based preset wizard" framing to dynamic-architect-first framing.
- Match GitHub repo description tone: "Build a Claude workspace from your goal — the Dynamic Wizard maps it to vetted agents from the unified skill pool."
- Preserve "20 curated skills, no code required" if it still fits naturally.
- No other README lines changed.

**TIER 2 — SETUP-CHECKLIST sequencing fix**
- `/home/user/claude-cowork-config/SETUP-CHECKLIST.md` Step 1 (~line 18) and any subsequent step that implies preset-selection-before-goal-discovery: reframe so goal discovery is presented as the primary action, with preset-paste as the optional accelerator for the manual fallback path.
- @architect picks exact line edits at Phase 1.

**TIER 3 — GitHub topic swap (manual post-merge)**
- Document for user to run post-merge:
  `gh repo edit jmlozano1990/Cowork-Starter-Kit --remove-topic templates --add-topic dynamic-workspace`
- github.enabled=false in registry — in-cycle automation skipped (same pattern as v2.5.3 S1/S2/S3). Command goes in CHANGELOG only.

**Release artifacts:**
- VERSION: 2.5.3 → 2.5.4
- README version badge: 2.5.3 → 2.5.4
- CHANGELOG: [2.5.4] entry citing "v2.4.0 pivot framing realignment" so future readers understand why
- "Next up (v2.6)" in README: VERIFY byte-identical (no change)

---

### Acceptance Criteria

1. **AC-1 (TIER 1):** `head -1 README.md` contains no instance of "preset wizard"; contains "goal" or "Dynamic Workspace" or equivalent dynamic-architect framing.
2. **AC-2 (TIER 1):** `head -1 README.md` preserves "20 curated skills" and "no code required" (or equivalent preserved value prop).
3. **AC-3 (TIER 2):** SETUP-CHECKLIST.md Step 1 heading and body do not imply preset selection precedes goal articulation; goal discovery or "describe your goal" language appears before any preset reference.
4. **AC-4 (TIER 2):** SETUP-CHECKLIST.md retains functional equivalence — all steps still present, manual fallback path still navigable.
5. **AC-5 (Release):** `cat VERSION` = `2.5.4`.
6. **AC-6 (Release):** `grep "version-2.5.4" README.md` returns 1 hit (badge).
7. **AC-7 (Release):** `grep "\[2.5.4\]" CHANGELOG.md` returns 1 hit; entry body references "v2.4.0 pivot framing realignment".
8. **AC-8 (Release):** `grep "Next up" README.md` returns a line referencing v2.6 (byte-identical to v2.5.3 "Next up" teaser — no v2.6 scope change).

---

### Will-Not-Do (v2.5.4)

- v2.6 multi-tool work
- Any change to WIZARD.md, CLAUDE.md, CONTRIBUTING.md, skill descriptions, examples/<preset>/ contents, selection-presets.md
- Any new ADRs (copy-only cycle — no architectural decisions)
- Any change to cowork.lock.json
- Any change to .github/workflows/
- Competitor naming in public copy (per feedback_no_competitor_naming_public)

---

### Technical Constraints

- Stack: markdown/plain-text only (no build step, no schema, no CI changes)
- github.enabled=false — TIER 3 gh command documented in CHANGELOG only; not automated in-cycle
- Zero deny-list violations: WIZARD.md, CLAUDE.md, CONTRIBUTING.md, quality.yml, sync-agency.yml, cowork.lock.json, all 20 SKILL.md files, selection-presets.md — all BYTE-UNCHANGED

---

### Risks

- LOW. Copy-only changes to 2 files + release artifacts. No functional logic touched.
- [CONFIRMED] v2.5.3 is the latest shipped tag. All 4 prior v2.5.x cycles shipped clean.
- [UNTESTED] New hero wording does not introduce any competitor names (per no-competitor-naming-public rule — @dev self-verify before commit).

---

### Classification

STANDARD — copy-only, no auth/RLS/schema/CI/guard/settings/API/compliance surface.
- **[UNTESTED]** Path 1 tail-extraction logic handles all edge cases (marker absent, marker at EOF, encoding variants). @qa must simulate at Phase 5.

---

## v2.6.0 Cycle — Dynamic Preset Scaffolds (RE-SCOPED)

> **Cycle:** v2.6.0 — Dynamic Preset Scaffolds (RE-SCOPED 2026-05-10)
> **Version bump:** 2.5.4 → 2.6.0 (MINOR — new feature surface: tiered skill schema + runtime swap affordance)
> **Status:** Phase 0 — Requirements (DONE)
> **Date:** 2026-05-10T00:00:00Z
> **Mode:** DEEP
> **Classification:** STANDARD (preliminary — confirmed at Phase 1; no auth/schema/CI/compliance surface identified in requirements)
> **Routing:** `/design` next. No `/legal` trigger detected (no external content derivation; all skills and presets are existing Cowork-owned content).

---

### Strategic Context

v2.6 was publicly committed in the README "Next up" teaser as "Multi-tool skill authoring (v3.0 routing intent) — individual skills validated for Copilot/Cursor/Windsurf and widened beyond claude-code." On 2026-05-10, the user elected to flip the v2.6 slot to address an audit finding instead. Multi-tool authoring is deferred to v2.7+.

**The audit finding (2026-05-10):** All 7 preset skill bundles were composed in a single v2.4.0 commit and have never been re-evaluated against the full 21-skill pool. Three presets have documented MINOR-GAPS; the pool has grown by 3 skills since the v2.4 lock-in; and the 3-skill cap per preset has never been validated as a UX constraint.

**The user's strategic framing (verbatim):** "I have the guess that the presets are outdated based in the old version and is not counting all the possibilities we have now, we should assess new combinations based on all the pool and then be creating those preset templates that can be dynamically adjusted by user interaction."

**What v2.6 ships:** A tiered skill schema (`core` / `optional` / `cross_cutting`), recomposed bundles across all 7 presets based on full-pool JTBD analysis, and a runtime swap/add/drop affordance that makes presets starting scaffolds rather than fixed configurations.

---

### Problem

The 7 Cowork preset skill bundles were composed at v2.4.0 against a 20-skill pool and have never been updated. Since then, the pool has grown (action-items, doc-summary, prompt-gate added), making the v2.4 compositions an incomplete map of available capabilities.

Three specific capability gaps have been identified by domain-JTBD analysis:
- **Study:** `editing-pass` absent (students write assignments; the current bundle stops at research and notes)
- **Project Management:** `action-items` absent (meeting-notes output feeds directly into action-item extraction; the two are used together by the same persona on the same trigger)
- **Business/Admin:** `meeting-notes` absent from the proactive-offer layer (the bundle's global-instructions does not mention it as a proactively offered skill)

Beyond gaps, the deeper problem is architectural: presets are currently fixed bundles. Once installed, a user cannot add a skill mid-session without starting the wizard again. This creates hard domain boundaries that do not match how knowledge workers actually work — a project manager needs to draft an email; a student needs to polish an essay; a personal assistant needs to extract action items from meeting notes. The current architecture treats these as different "workspaces" when they are all the same work session.

---

### Target Users

**Primary persona served by this cycle:**
All 7 preset personas benefit, but the highest-impact change is for Jordan (Project Management) and Casey (Personal Assistant), who both have clear optional-tier gaps from the audit finding. Alex (Study) benefits from `editing-pass` addition to optional tier.

**Backwards-compat concern:** Existing v2.5.x users with installed workspaces. The schema migration strategy must not break existing skill bundle files.

---

### Core Features (MVP)

#### F1 — Tiered Skill Schema in `selection-presets.md`

**What it does:** Extends the `selection-presets.md` preset block format to support three tiers per preset:
- `core_skills` (always loaded, replaces current `skill_bundle:`) — 2-4 skills per preset
- `optional_skills` (available for swap-in during wizard F4 or runtime; suggested proactively by preset-specific global-instructions) — 1-3 additional skills per preset
- `cross_cutting_skills` (shared across presets; surfaces as "also useful" suggestions) — pool-level annotation

The legacy `skill_bundle:` field is deprecated but still parsed by the wizard during a transition window (A-v2.6-10). Wizard reads `core_skills` if present; falls back to `skill_bundle:` if absent.

**Recomposed bundles (full-pool JTBD analysis — Phase 0 output):**

| Preset | Core skills (core tier) | Optional skills | Notes |
|--------|------------------------|-----------------|-------|
| Study | flashcard-generation, note-taking, research-synthesis | editing-pass, outline-generator | Unchanged core; editing-pass + outline-generator added as optional |
| Research | literature-review, source-analysis, research-synthesis | note-taking, doc-summary | Unchanged core; note-taking + doc-summary added as optional |
| Writing | voice-matching, outline-generator, editing-pass | research-synthesis, feedback-synthesizer | Unchanged core; research-synthesis + feedback-synthesizer added as optional |
| Project Management | meeting-notes, status-update, risk-assessment | action-items, follow-up-tracker | Unchanged core; action-items + follow-up-tracker added as optional |
| Creative | ideation-partner, creative-brief, feedback-synthesizer | outline-generator, voice-matching | Unchanged core; outline-generator + voice-matching added as optional |
| Business/Admin | email-drafting, doc-summary, action-items | meeting-notes, follow-up-tracker | action-items promoted to core (from optional); meeting-notes added as optional |
| Personal Assistant | daily-briefing, follow-up-tracker, spend-awareness | action-items, doc-summary | Unchanged core; action-items + doc-summary added as optional |

**Cross-cutting skills (available across all presets as suggestions):**

| Skill | Rationale |
|-------|-----------|
| action-items | Used situationally by PM, business-admin, personal-assistant, and study personas |
| meeting-notes | Used situationally by PM, business-admin, and personal-assistant personas |
| doc-summary | Used situationally by research, business-admin, and personal-assistant personas |
| voice-matching | Used situationally by writing and creative personas; crossover to business-admin for exec emails |
| research-synthesis | Bridges study, research, and writing domains |

**ACs:**
- **AC-F1-1:** `selection-presets.md` contains `core_skills:` and `optional_skills:` fields on all 7 preset blocks. `grep -c "core_skills:" selection-presets.md` = 7.
- **AC-F1-2:** All 7 presets retain `skill_bundle:` field for backwards-compat (parser fallback). `grep -c "skill_bundle:" selection-presets.md` = 7.
- **AC-F1-3:** Each preset's `core_skills:` count is between 2 and 4. No preset has more than 4 core skills.
- **AC-F1-4:** Each preset's `optional_skills:` count is between 1 and 3.
- **AC-F1-5:** A `cross_cutting_skills:` annotation block exists at the bottom of `selection-presets.md` listing the 5 cross-cutting skills identified in Phase 0 analysis.
- **AC-F1-6:** `quality.yml` skill-depth-check continues to pass on all skills in the pool (no skill-depth regressions from schema changes). `grep -c "PASS" quality-check-output` = pool count.

---

#### F2 — Runtime Skill Swap Affordance (Wizard + Global Instructions)

**What it does:** Adds a runtime skill swap/add/drop path that allows users to modify their active skill set during a session without re-running the full wizard. The affordance surfaces at two points:
1. **At bundle confirmation (F4 in WIZARD.md):** After the wizard presents the `core_skills` bundle, it proactively offers the `optional_skills` as a "you might also want" list with chips. User can add any optional skill to the session before confirming.
2. **Mid-session (global-instructions.md):** Each preset's `global-instructions.md` gains a "Skill swap" section specifying that when the user asks for a capability not in their current bundle (e.g., a PM user says "can you help me polish this email?"), the AI offers the closest matching optional or cross-cutting skill rather than saying it is unavailable.

**WIZARD.md changes:** F4 (bundle customization) updated to distinguish between `core_skills` (pre-selected, user can remove) and `optional_skills` (pre-listed as "also available", user can add). The prompt changes from "Want to add or remove anything?" to "Your core bundle: [core_skills]. Also available for your workspace type: [optional_skills]. Add any, or keep core only?"

**global-instructions.md changes:** All 7 preset `global-instructions.md` files updated to:
1. Reference `optional_skills` in the proactive-offer trigger section (new triggers for each optional skill)
2. Add a "Skill swap" section with instructions for when user requests a skill outside the current bundle

**ACs:**
- **AC-F2-1:** WIZARD.md F4 section distinguishes `core_skills` from `optional_skills` in the bundle-confirmation prompt. `grep -c "optional_skills\|optional skills\|Also available" WIZARD.md` >= 1.
- **AC-F2-2:** All 7 preset `global-instructions.md` files contain proactive-offer trigger blocks for each skill in their `optional_skills` tier. For each `optional_skills` entry, a matching "offer automatically when" block exists in the corresponding `global-instructions.md`.
- **AC-F2-3:** Each preset's `global-instructions.md` contains a "Skill swap" section (or equivalent heading) instructing the AI to offer the closest optional or cross-cutting skill when the user requests a capability outside the current bundle.
- **AC-F2-4:** The existing proactive-offer blocks for `core_skills` in all 7 `global-instructions.md` files are byte-unchanged. Only new blocks are added; existing blocks are not modified or reordered.
- **AC-F2-5:** WIZARD.md F4 backwards-compat: if a preset block only has `skill_bundle:` (no `core_skills:`), the wizard falls back to presenting `skill_bundle:` contents as the proposed bundle. `grep -c "skill_bundle" WIZARD.md` >= 1 (fallback reference preserved).

---

#### F3 — Release Artifact Updates

**What it does:** Updates public-facing artifacts to reflect the v2.6.0 changes:
- README "Next up" teaser: replace v2.6 multi-tool teaser with "v2.7+ multi-tool skill authoring" (per `feedback_version_bump_completeness` — "Next up" must be updated)
- README version badge: bump 2.5.4 → 2.6.0
- VERSION file: 2.5.4 → 2.6.0
- CHANGELOG.md: prepend [2.6.0] entry
- SETUP-CHECKLIST.md: update any version references

**ACs:**
- **AC-F3-1:** README version badge reads `2.6.0`. `grep -c "2.6.0" README.md` >= 1.
- **AC-F3-2:** README "Next up" line reads "v2.7+" (not v2.6). `grep -c "v2.7" README.md` >= 1. `grep -c "v2.6.*multi-tool\|multi-tool.*v2.6" README.md` = 0.
- **AC-F3-3:** VERSION file contains `2.6.0`. `cat VERSION` = `2.6.0`.
- **AC-F3-4:** CHANGELOG.md `[2.6.0]` section is the first entry (prepended). `head -5 CHANGELOG.md | grep -c "2.6.0"` >= 1.
- **AC-F3-5:** README contains no competitor names (deny-list: competitor names per internal docs). `grep -ciE "(cursor|windsurf|copilot|notion|gpt|openai)" README.md` (in marketing copy positions) = 0.

---

### Out of Scope (v2.6)

- **Multi-tool skill authoring.** Deferred to v2.7+. No `tools:` field changes beyond v2.5 baseline.
- **`goal_tags` SKILL.md enrichment.** Deferred to v2.7+. Cross-cutting skill mapping is maintained manually in `selection-presets.md` at v2.6.
- **New skill additions.** Pool remains at 21 skills (20 original + prompt-gate). No new SKILL.md files.
- **Automated skill inference / LLM-based routing.** CF-v2.4-E (LLM goal matching). Still in backlog.
- **Upstream contribution.** v2.5.0 F3 submitted `meeting-notes`. No additional upstream contribution this cycle.
- **Any CI gate changes.** `quality.yml` and `sync-agency.yml` are BYTE-UNCHANGED this cycle unless @architect identifies a structural requirement at Phase 1.
- **Persona profile wizard expansion.** `WIZARD.md` Q1-Q5 flow is unchanged except F4 bundle-confirmation step. No new questions added.
- **`cowork-profile.md` schema changes.** User profile file format is unchanged.

---

### Technical Constraints

- **Stack:** Markdown + bash scripts. No build step. No schema. No CI changes (preliminary).
- **File format (backwards-compat):** `selection-presets.md` must parse cleanly with both legacy (`skill_bundle:`) and new (`core_skills:` + `optional_skills:`) keys. Wizard must support both formats during the transition window (A-v2.6-10).
- **Deny-list (BYTE-UNCHANGED unless @architect overrides):** `WIZARD.md` Q1/Q2/Q3/Q4/Q5 sections (only F4 changes), all 21 SKILL.md files, `cowork.lock.json`, `quality.yml`, `sync-agency.yml`, `curated-skills-registry.md`.
- **No new skills added to the pool.** The recomposition uses the existing 21-skill pool only. `ls skills/ | wc -l` = 21 at Phase 5.
- **ADR-024 attribution injection:** Byte-unchanged. No new upstream installs.
- **No competitor names in public copy.** README, CHANGELOG promotional copy, SETUP-CHECKLIST, release bodies must contain no competitor names (internal docs exempt per `feedback_no_competitor_naming_public`).
- **markdownlint:** 0 violations on all new and modified `.md` files. CI must pass on first push.
- **Commit topology (ADR-033):** Phase 0/1/2 docs (spec, architecture, security-review) in mandatory-paperwork commit alongside implementation.

---

### User Stories

- As Alex (student), I want `editing-pass` available in my Study workspace so I can polish a lab report mid-session without switching workspaces.
- As Jordan (project manager), I want `action-items` available as a one-tap addition after meeting-notes runs so I can feed the task board without a manual copy-paste step.
- As Casey (personal assistant), I want to add `doc-summary` when I receive a long HOA notice in the middle of a personal-assistant session so I can get the key decision without opening a separate workspace.
- As Sam (freelance writer), I want `research-synthesis` available as an optional skill in my Writing workspace so I can compare competitor angles for a client brief without leaving the session.
- As any Cowork user, I want the wizard to show me what optional skills are available for my workspace type so I can make an informed choice at setup, not discover capabilities by accident later.
- As any Cowork user with an existing workspace, I want my current skill bundle to continue working after v2.6.0 so that updating the repo does not break my configuration.
- As Priya (creative strategist), I want `outline-generator` available as an optional skill in my Creative workspace so I can structure a strategy deck without switching to a writing workspace.
- As Chris (business-admin), I want the AI to proactively offer `meeting-notes` when I paste meeting content so I can get a full structured record, not just action items.

---

### Acceptance Criteria — Full List

| ID | Feature | Criterion | Verification method |
|----|---------|-----------|---------------------|
| AC-F1-1 | F1 | `core_skills:` on all 7 presets | `grep -c "core_skills:" selection-presets.md` = 7 |
| AC-F1-2 | F1 | `skill_bundle:` retained on all 7 presets | `grep -c "skill_bundle:" selection-presets.md` = 7 |
| AC-F1-3 | F1 | Core tier count 2-4 per preset | Manual review: no preset has >4 core skills |
| AC-F1-4 | F1 | Optional tier count 1-3 per preset | Manual review: no preset has >3 optional skills |
| AC-F1-5 | F1 | cross_cutting_skills block exists | `grep -c "cross_cutting_skills:" selection-presets.md` >= 1 |
| AC-F1-6 | F1 | Skill-depth-check passes all 21 skills | CI quality.yml: skill-depth-check step PASS |
| AC-F2-1 | F2 | WIZARD.md F4 distinguishes core/optional | `grep -c "optional_skills\|Also available" WIZARD.md` >= 1 |
| AC-F2-2 | F2 | All 7 global-instructions.md have optional-skill proactive-offer blocks | Manual review: each optional_skill has matching "offer automatically when" block |
| AC-F2-3 | F2 | All 7 global-instructions.md have "Skill swap" section | `grep -rc "Skill swap\|skill-swap\|swap a skill" examples/*/global-instructions.md | grep -c ":"` = 7 |
| AC-F2-4 | F2 | Existing core-skill proactive-offer blocks byte-unchanged | `git diff HEAD~1 examples/*/global-instructions.md | grep -c "^-.*offer automatically"` = 0 |
| AC-F2-5 | F2 | WIZARD.md retains `skill_bundle:` fallback reference | `grep -c "skill_bundle" WIZARD.md` >= 1 |
| AC-F3-1 | F3 | README badge = 2.6.0 | `grep -c "2.6.0" README.md` >= 1 |
| AC-F3-2 | F3 | README "Next up" references v2.7+ not v2.6 | `grep -c "v2.7" README.md` >= 1; no v2.6 multi-tool reference |
| AC-F3-3 | F3 | VERSION = 2.6.0 | `cat VERSION` = `2.6.0` |
| AC-F3-4 | F3 | CHANGELOG [2.6.0] prepended | `head -5 CHANGELOG.md | grep -c "2.6.0"` >= 1 |
| AC-F3-5 | F3 | No competitor names in README | deny-list grep = 0 in marketing copy positions |

---

### Edge Cases

1. **Empty optional tier at runtime:** User is in a session and asks for a skill not in core or optional tier. Global-instructions "Skill swap" section must respond with the closest cross-cutting match (not "I can't do that"). If no cross-cutting match exists, the AI must say explicitly: "That skill is not in your current workspace — want to add it or start fresh?"

2. **Backwards-compat fallback triggers:** A user with a v2.4.x or v2.5.x `selection-presets.md` (containing only `skill_bundle:`, no `core_skills:`) opens the wizard. The wizard must parse `skill_bundle:` and present the full bundle as core — no error, no partial install.

3. **Core and optional tier overlap:** If a skill listed in `core_skills:` is also listed in `optional_skills:` (authoring error), the wizard must de-duplicate and count the skill as core only. No double-install.

4. **Cross-cutting skill already in core:** If a cross-cutting skill (e.g., `action-items`) is also listed as a `core_skills:` entry for a preset, the cross-cutting annotation must not cause a second install. De-duplication logic applies.

5. **global-instructions.md proactive-offer for optional skill when user has not added it:** The proactive offer in global-instructions triggers even if the user has not added the optional skill to their session. The AI should offer to add it ("Want me to add this skill to your session?") rather than attempting to use it silently.

6. **User adds a cross-cutting skill mid-session:** The AI must acknowledge the addition ("I've added `action-items` to your session — it extracts owned action items from meeting transcripts or threads. Paste your meeting notes to use it.") rather than silently activating it.

7. **Max optional tier reached:** If a user adds all optional and cross-cutting skills to their session (extreme edge), the session should remain functional. There is no enforced maximum — the user's configuration choice is respected.

8. **Preset name collision:** If a future skill addition to the pool uses a name identical to an existing cross-cutting skill slug, the cross-cutting annotation must not create an ambiguous reference. CI skill-name uniqueness check must be enforced.

---

### Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| global-instructions.md proactive-offer update missed for a new optional skill | HIGH | AC-F2-2 requires verification for every optional_skills entry across all 7 presets at Phase 5. @qa to automate check. |
| Backwards-compat fallback not tested under CI (existing users get broken parse) | HIGH | Phase 5 @qa creates test fixture with legacy `skill_bundle:`-only preset blocks; wizard must handle gracefully. |
| skill_bundle: retained creates permanent maintenance debt (two schema versions in flight) | MEDIUM | @architect to evaluate at Phase 1 whether the transition window should have an end date (e.g., deprecated-in-v2.7). |
| Cross-cutting tier creates user confusion ("is this skill in my workspace or not?") | MEDIUM | Global-instructions "Skill swap" section must explicitly acknowledge mid-session additions. UX phrasing review at Phase 5 @ux. |
| README "Next up" update reveals v2.6 scope change publicly (original teaser was multi-tool) | LOW | Changelog entry explains the slot flip to preset-recomposition without referencing original multi-tool commitment by name. User decides framing. |

---

### Open Questions for @architect (Phase 1)

**OQ-v2.6-1 (F1 — schema format):** Should `core_skills:` and `optional_skills:` use YAML list syntax (`core_skills: [a, b, c]`) consistent with the existing `skill_bundle:` field, or a multi-line block (`core_skills:\n  - a\n  - b`)? Parser must handle both if the format is ambiguous.

**OQ-v2.6-2 (F2 — swap affordance implementation):** The "Skill swap" section in global-instructions tells the AI to offer a skill when the user requests a capability outside the bundle. Should this be implemented as a markdown instruction block (current pattern) or as a structured trigger format (new pattern consistent with existing "offer automatically when" blocks)? The two formats must not conflict.

**OQ-v2.6-3 (F2 — runtime install mechanism):** When a user adds an optional skill mid-session via the "Skill swap" offer, does the skill SKILL.md file need to be physically installed to `.claude/skills/` at that point, or does the AI operate from the skill's Instructions inline (loaded from WIZARD.md F6 skill-as-prompts fallback)? The answer determines whether the swap affordance requires file-system access at runtime.

**OQ-v2.6-4 (F1 — backwards-compat duration):** Should the `skill_bundle:` legacy key be formally deprecated in this cycle (marked as deprecated, planned for removal at v2.7.0) or left as permanent dual-parse? Recommendation needed before ADR documenting the schema change.

**OQ-v2.6-5 (F2 — cross-cutting display):** In the WIZARD.md F4 bundle-confirmation prompt, should the `cross_cutting_skills` be presented separately from `optional_skills`, or merged into a single "also available" list? The distinction may be useful for advanced users but confusing for casual ones.

---

### Success Metrics

- **Primary:** Percentage of Cowork sessions where at least one optional or cross-cutting skill is added mid-session (target: measurable by user report; no telemetry in v2.6). Proxy: absence of "can you do X in this workspace?" questions that terminate sessions.
- **Secondary:** Zero post-release reports of legacy workspace breakage (backwards-compat maintained). Tracked via GitHub issues.
- **Leading indicator:** All 7 presets' optional-tier additions are proactively offered in their `global-instructions.md` at Phase 5 @qa verification (AC-F2-2 PASS).

---

### Assumptions in This Cycle

| ID | Assumption | Confidence | In scope |
|----|-----------|-----------|---------|
| A-v2.6-1 | Users want runtime skill edit affordance | [UNTESTED] | YES |
| A-v2.6-2 | 3-skill cap is suboptimal | [ESTIMATED] | YES |
| A-v2.6-3 | Cross-domain skills under-represented | [CONFIRMED] | YES |
| A-v2.6-4 | 3-tier schema more discoverable | [ESTIMATED] | YES |
| A-v2.6-5 | v2.5.x users need backwards-compat | [ESTIMATED] | YES |
| A-v2.6-6 | prompt-gate stays implicit | [ESTIMATED] | YES |
| A-v2.6-7 | Edit affordance should be proactive at bundle-confirm | [UNTESTED] | YES |
| A-v2.6-8 | goal_tags enrichment not in scope | [CONFIRMED] | NO |
| A-v2.6-9 | global-instructions.md must reflect bundle recomposition | [CONFIRMED] | YES |
| A-v2.6-10 | Backwards-compat file format preferable | [ESTIMATED] | YES — decision to @architect |

---

## Architectural Modifications (v2.6.0)

The following spec items were modified during Phase 1 architecture design (2026-05-10T19:30:00Z) to conform to the 8 user decisions locked at the Phase 0 → Phase 1 gate. All modifications are user-elected (not architect overrides). See `docs/architecture.md` § "v2.6.0 Phase 1 — Dynamic Preset Scaffolds Design" and ADR-034 for full rationale.

- **AC-F1-2** (originally: `skill_bundle:` retained on all 7 presets — `grep -c "skill_bundle:" selection-presets.md` = 7) → **INVERTED to: `skill_bundle:` REMOVED on all 7 presets — `grep -c "^skill_bundle:" selection-presets.md` = 0.** Reason: D4 hard-break (user override at gate). The `skill_bundle:` field is removed in v2.6.0; new `core_skills:` schema is the only schema. Clone-once template means no live-state migration is needed; legacy parser would be dead code.

- **AC-F2-5** (originally: WIZARD.md retains `skill_bundle:` fallback reference — `grep -c "skill_bundle" WIZARD.md` >= 1) → **INVERTED to: WIZARD.md contains zero `skill_bundle:` references — `grep -c "skill_bundle" WIZARD.md` = 0.** Reason: D4 hard-break (user override at gate). Same rationale as AC-F1-2 inversion — no parser fallback exists.

- **OQ-v2.6-1** (schema format question) → **RESOLVED: comma-separated single-line list (consistent with existing `match_signals:` format).** Not YAML inline arrays, not multi-line block lists. Rationale: preserves existing line-scanner parser shape; avoids adding YAML parser surface (which would also widen the OI-v2.6-S2 threat model).

- **OQ-v2.6-3** (runtime install mechanism question) → **RESOLVED: instruction-only swap, no file copy at runtime (D8 binding).** AI loads optional/cross-cutting skill instructions inline from the pool; does NOT write to `.claude/skills/` mid-session. `skills-as-prompts.md` continues to operate from the install-time bundle (core + user-confirmed optional adds at F4).

- **OQ-v2.6-4** (backwards-compat duration question) → **RESOLVED: hard break, no deprecation cycle planned (D4 binding).** There is no `skill_bundle:` field left to deprecate post-v2.6.0.

- **OQ-v2.6-5** (cross-cutting display question) → **RESOLVED: cross_cutting_skills are presented separately from optional_skills in WIZARD.md F4 prose.** F4 prompt has three add-source bullets: optional tier (preset-specific), cross-cutting (pool-level), full pool (free-text suggestion match). See `docs/architecture.md` § WIZARD.md Prose Changes Diff Block 2.

- **Classification re-run** (originally STANDARD per Phase 0 preliminary) → **CONFIRMED SECURITY-SENSITIVE at Phase 1.** Triggers: CI gate edit (`quality.yml` ADR-016 v2.6 amendment), new AI-instruction surface (Skill swap prose in 7 files), hard-break schema migration. Phase 2 (@security) review is mandatory; combined-path skip is NOT eligible.

- **Spec § Out of Scope amendment:** "Any CI gate changes" originally listed `quality.yml` as BYTE-UNCHANGED unless @architect identifies a structural requirement. Architect identified a structural requirement (the parser-update lock-step). `quality.yml` receives 2 targeted edits (CMP step parser + MF-1 regex) per ADR-016 v2.6 amendment. All other CI workflow files (`sync-agency.yml`) remain BYTE-UNCHANGED.

- **Spec § Risks amendment:** the risk row "skill_bundle: retained creates permanent maintenance debt" is rendered moot by D4 hard-break and is replaced by the new risk: "CI gate parser lock-step missed, byte-mirror silently no-ops" — captured as ADR-034 §Consequences and as Guard Change Summary §I "What could break" item 1. Mitigation: ADR-016 v2.6 amendment is committed in lock-step with ADR-034.

---

# Product Spec — v2.6.1 — Release Archive Hygiene

> **Cycle:** v2.6.1 — Release Archive Hygiene
> **Version bump:** 2.6.0 → 2.6.1 (patch — no new product surface)
> **Status:** Phase 0 — Requirements DONE
> **Date:** 2026-05-11T00:00:00Z
> **Mode:** quick
> **Classification:** STANDARD
> **Routing:** Phase 1 `/design` after Phase 0 sign-off.

---

## Problem

Users who download the release ZIP from the GitHub release page receive every tracked file in the repository — dev tooling, CI workflows, contributor guides, internal docs, tests, and template scaffolding — mixed in with the actual product content. The `release-assets.yml` workflow uses plain `git archive` with no `.gitattributes` `export-ignore` rules, which defaults to including all tracked files. A user installing Cowork from the archive must manually sift product files from tooling, and risks placing contributor-only files (CONTRIBUTING.md, CI configs, test fixtures) into their Claude working environment.

**Goal:** The release ZIP and tar.gz contain only files a user needs to set up and run Cowork — nothing else.

---

## Target Users

**Primary: Alex — University Student (20, biochemistry).** Downloads the release ZIP to bootstrap a new Claude project. Expects a clean, usable folder — not a dev repo dump.

**Secondary: Maria — Knowledge Worker (35, research analyst).** May download a versioned release as a stable reference point. Same expectation.

---

## Core Features (MVP)

### F1 — `.gitattributes` Export-Ignore Rules

Author a `.gitattributes` file at the repo root. Add `export-ignore` attributes for every file and folder in the DROP list. `git archive` respects these attributes natively; no changes to `release-assets.yml` workflow logic are required beyond the sanity check in F2.

**AC-F1-1:** `.gitattributes` exists at the repo root. `test -f .gitattributes` exits 0.

**AC-F1-2:** Every DROP-list entry appears in `.gitattributes` with the `export-ignore` attribute. Verified by the sanity check script in F2.

### F2 — CI Sanity Check (Release Archive Regression Guard)

Add a step to `.github/workflows/release-assets.yml` (or a standalone `scripts/verify-release-archive.sh` called from CI) that: (1) extracts the built archive to a temp directory, (2) asserts that none of the DROP-list entries are present, (3) fails the CI step if any DROP-list file is found. This prevents silent regressions if a new tracked file is added without a corresponding `export-ignore` entry.

**AC-F2-1:** CI sanity check step exists in `release-assets.yml`. `grep -c "verify" .github/workflows/release-assets.yml` >= 1 (or `scripts/verify-release-archive.sh` exists).

**AC-F2-2:** When run against a locally-built archive at HEAD, the sanity check exits 0.

**AC-F2-3:** When run against a test archive that includes a DROP-list file (e.g., `.github/` injected), the sanity check exits non-zero (regression guard fires).

### F3 — Version Bump and Release Artifacts

Bump VERSION 2.6.0 → 2.6.1, add `[2.6.1]` entry to CHANGELOG.md (Keep a Changelog format, date 2026-05-11), update README badge, update "Next up" teaser if applicable.

**AC-F3-1:** `cat VERSION` = `2.6.1`.

**AC-F3-2:** `head -8 CHANGELOG.md | grep -c "2.6.1"` >= 1 ([2.6.1] is in the first 8 lines).

**AC-F3-3:** `grep "2.6.1" README.md` >= 1 (badge updated).

**AC-F3-4:** No product functionality regressed — install setup wizard flow (`WIZARD.md`, `SETUP-CHECKLIST.md`, `CLAUDE.md`, `skills/`, `selection-presets.md`) byte-unchanged from v2.6.0 HEAD. `git diff HEAD~1 -- WIZARD.md CLAUDE.md skills/ selection-presets.md` = 0 lines (or confirms only no-content changes).

---

## KEEP / DROP Classification

> **Revision notes (2026-05-11, Phase 1 REVISION 2 + post-amendment 15:30:00Z):** The Phase-1 Revision-1 classification originally DROP'd 5 files that user-facing docs reference by path. **3 misclassifications were corrected to KEEP** (`CLAUDE.md`, `scripts/setup-folders.{sh,ps1}`, `docs/architecture.md`) — these are user-instructed setup artifacts whose absence from the archive would break setup. **2 originally-DROP items (`CHANGELOG.md`, `CONTRIBUTING.md`) STAY DROP** per the user's explicit confirmation at the Revision-2 gate review: both files remain readable on GitHub, and the user's stated intent is that the release archive be lean product surface, not a dev/contributor mirror. To prevent the Rev-1 broken-link failure mode while honoring that intent, **@dev's implementation now includes a link-rewrite task**: README.md (lines 5, 141, 169, 175, 191) and SETUP-CHECKLIST.md (line 149) relative links to `CHANGELOG.md` / `CONTRIBUTING.md` MUST be rewritten to absolute `https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/...` GitHub URLs. Revision 2 binds **file-granularity** classification for `scripts/` and `docs/`. **Cross-check method:** for every DROP candidate, `grep -l "<file>" README.md SETUP-CHECKLIST.md WIZARD.md CLAUDE.md THIRD-PARTY-NOTICES.md` — path-reference hits force EITHER reclassification to KEEP (default) OR a link-rewrite task (when user explicitly elects DROP, as with CHANGELOG.md and CONTRIBUTING.md). The corrected table below is the binding ruleset for @dev. The Revision-2 design memo in `docs/architecture.md` contains the full evidence trail (R2.1 + R2.2 tables), the verbatim `.gitattributes` ruleset (§R2.4), and the @dev implementation checklist for the link-rewrite task (§R2.5.5).

Classification rationale: **KEEP** = a user cloning for product use needs this file to set up or run Cowork, OR a user-facing doc references it by path (broken-link prevention). **DROP** = contributor tooling, CI infrastructure, internal docs, tests, or upstream-management artifacts the end user has no reason to touch, AND no user-facing doc references the file by path.

| Entry | Class | Reason |
|-------|-------|--------|
| `CLAUDE.md` | **KEEP** (was DROP in Rev-1) | Primary AI instruction file — referenced from README + SETUP-CHECKLIST + WIZARD. Claude Code reads it in the installed workspace (wizard/onboarding/safety/attribution instructions) |
| `WIZARD.md` | KEEP | Setup wizard — core product UX |
| `SETUP-CHECKLIST.md` | KEEP | Post-install checklist — user-facing setup guide |
| `README.md` | KEEP | Product intro — users read this before downloading |
| `LICENSE` | KEEP | Required legal artifact for distribution |
| `THIRD-PARTY-NOTICES.md` | KEEP | Required attribution for upstream content (supply-chain transparency for users) |
| `VERSION` | KEEP | Machine-readable version (referenced by CI and scripts) |
| `selection-presets.md` | KEEP | Preset definitions — read by wizard at setup |
| `.cowork-allowlist.json` | KEEP | Upstream content allow/block list — consumed by install-time wizard logic |
| `cowork.lock.json` | KEEP | Supply-chain lock file — consumed by `sync-agency.yml` CI at install; SHA pins are the trust anchor described in README + SETUP-CHECKLIST |
| `curated-skills-registry.md` | KEEP | Skill discovery registry — read by wizard |
| `skills/` | KEEP | All product skills — installed into user environment |
| `examples/` | KEEP | Preset example environments — the product's deliverable structure |
| `prompts/` | KEEP | AI prompt library — product content |
| `templates/` | KEEP | Skill and writing-profile templates — product scaffolding |
| `.claude/` | KEEP | Setup wizard skill — `.claude/skills/setup-wizard/SKILL.md` is product content |
| `CHANGELOG.md` | **DROP** (post-amendment 2026-05-11T15:30:00Z) | Readable on GitHub — user's stated intent is that the release archive be lean product surface, not a dev/contributor mirror. README:5 badge href + README:169 + SETUP-CHECKLIST:149 references **MUST be rewritten** to `https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CHANGELOG.md` absolute GitHub URLs by @dev (see architecture.md §R2.5.5 implementation checklist). Without the link rewrite this row would re-trigger the Rev-1 broken-link failure mode |
| `CONTRIBUTING.md` | **DROP** (post-amendment 2026-05-11T15:30:00Z) | Readable on GitHub — user's stated intent (same rationale as CHANGELOG.md). README:141/175/191 references **MUST be rewritten** to `https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CONTRIBUTING.md` absolute GitHub URLs by @dev (see architecture.md §R2.5.5 implementation checklist) |
| `docs/architecture.md` | **KEEP** (was folder-DROP in Rev-1) | README:142 + THIRD-PARTY-NOTICES.md:8,53,73 reference ADRs by file path |
| `scripts/setup-folders.sh` | **KEEP** (was folder-DROP in Rev-1) | SETUP-CHECKLIST.md:38 — "run `scripts/setup-folders.sh` (macOS)" verbatim user instruction |
| `scripts/setup-folders.ps1` | **KEEP** (was folder-DROP in Rev-1) | SETUP-CHECKLIST.md:38 — "or `scripts/setup-folders.ps1` (Windows)" verbatim user instruction |
| `.github/` | DROP | CI workflows, PR templates, CODEOWNERS — all CI/contributor tooling. THIRD-PARTY-NOTICES mentions `.github/workflows/sync-agency.yml` only as the regeneration source for itself; users do not run workflows from the extracted archive |
| `docs/` (all files except `architecture.md`) | DROP each | Internal pipeline docs — ADRs, retros, QA reports, security reviews, specs, competitive analysis, compliance reviews, dev deliberations, personas, OUTPUT-STRUCTURE, skills-roadmap, UX reviews, plus `docs/research/` + `docs/security/` subtrees. None referenced by path from user-facing docs. **Per-file enumeration required** because `gitattributes(5)` does NOT support negation (verified empirically — see architecture.md R2.3) |
| `scripts/install-pre-commit.sh` | DROP | Contributor pre-commit hook installer — not referenced by user-facing docs |
| `tests/` | DROP | CI test fixtures and checklists — not user-facing |
| `upstream-contribution/` | DROP | Upstream PR drafts — contributor artifact, not user content |
| `.gitignore` | DROP | Repo hygiene file — irrelevant to users installing from archive |
| `.markdownlint.jsonc` | DROP | Contributor linting config — CI tooling |
| `.markdownlintignore` | DROP | Contributor linting config — CI tooling |
| `.gitattributes` | DROP (self) | Packaging-config file; users have no use for it in the extracted archive |

**`cowork.lock.json` verdict: KEEP** (unchanged). The lock file is referenced in both README.md and SETUP-CHECKLIST.md as the "trust anchor" and "integrity anchor for upstream content." `quality.yml` has a CI gate that checks its presence and its `pinned_commit_sha` field. More critically, `sync-agency.yml` reads it at every upstream-sync run, and the architecture (ADR-028) specifies it as a required file at the repo root.

**`docs/` verdict (REVISED): file-granularity DROP.** All 40 internal-doc files in `docs/` plus the `docs/research/` and `docs/security/` subtrees are DROP'd via explicit per-file `export-ignore` lines in `.gitattributes`. `docs/architecture.md` is the sole survivor — referenced by path from README and THIRD-PARTY-NOTICES. Per `gitattributes(5)` negation limitation (verified empirically — git warns "Negative patterns are ignored in git attributes"), folder-level DROP with negation IS NOT a viable strategy. See architecture.md R2.4 for the verbatim `.gitattributes` ruleset.

**`scripts/` verdict (REVISED): file-granularity DROP.** `scripts/install-pre-commit.sh` is contributor tooling (DROP via single explicit entry). `scripts/setup-folders.sh` and `scripts/setup-folders.ps1` are KEEP because SETUP-CHECKLIST.md instructs users to run them by name from the extracted archive. No `scripts/` folder-level entry — only the one surgical DROP line.

**`.claude/` verdict: KEEP (unchanged).** Contains only `skills/setup-wizard/SKILL.md`. Product content — the wizard skill itself. `.gitignore` already excludes `.claude/projects/` so no pipeline state leaks.

**Positive-assertion list update (CI sanity check):** the F2 sanity check's KEEP-list MUST positive-assert all 10 of: `VERSION`, `README.md`, `LICENSE`, `WIZARD.md`, `SETUP-CHECKLIST.md`, `cowork.lock.json`, `CLAUDE.md`, `scripts/setup-folders.sh`, `scripts/setup-folders.ps1`, `docs/architecture.md`. (Expanded from the original 6-file list to cover the 4 reclassified KEEP files: `CLAUDE.md`, both `setup-folders.*`, `docs/architecture.md`. **`CHANGELOG.md` and `CONTRIBUTING.md` are NOT in the positive-assertion list** — they are DROP per post-amendment 2026-05-11T15:30:00Z and are exercised as DROP canaries in the negative-assertion `DROP_PATHS` set instead.) Positive-assertion list stays at 10 KEEP files. See architecture.md R2.5 for the verbatim updated CI step and R2.5.5 for the @dev link-rewrite implementation checklist.

---

## Out of Scope (v2.6.1)

- Renaming, restructuring, or refactoring any product file
- Changing `release-assets.yml` beyond adding the export-ignore mechanism and sanity check step
- New product features or capabilities
- Breaking changes (patch only)
- Modifying the release body or GitHub release notes generation (separate cycle)
- Per-file granular `docs/` export (e.g., keeping `docs/OUTPUT-STRUCTURE.md` while dropping retros) — entire folder drops for simplicity; `OUTPUT-STRUCTURE.md` content belongs in README or WIZARD if user-facing

---

## Technical Constraints

- Stack: Bash, GitHub Actions, `git archive` (no new tooling dependencies)
- `.gitattributes` `export-ignore` is the standard mechanism — no custom archive script needed
- Sanity check must use only tools available on `ubuntu-latest` GitHub Actions runner (bash, tar, unzip, grep)
- `release-assets.yml` minimal change: add sanity check step only; do not restructure the workflow
- `sync-agency.yml` and `quality.yml` BYTE-UNCHANGED (not in scope)

---

## Acceptance Criteria

- [ ] **AC1 (gitattributes):** `.gitattributes` exists at repo root. All DROP-list entries have `export-ignore` attribute. `test -f .gitattributes` exits 0.
- [ ] **AC2 (clean archive):** Built release archive (zip + tar.gz from `git archive`) contains ONLY files in the KEEP list. No DROP-list entry (`CHANGELOG.md`, `CONTRIBUTING.md`, `.github/`, `docs/`, `tests/`, `scripts/`, `upstream-contribution/`, `.gitignore`, `.markdownlint.jsonc`, `.markdownlintignore`) is present in the extracted archive.
- [ ] **AC3 (CI regression guard):** Sanity check step in CI exits non-zero if any DROP-list file appears in the archive. Verified via test with an injected DROP-list file in the archive before the check step.
- [ ] **AC4 (version):** `cat VERSION` = `2.6.1`. `head -8 CHANGELOG.md | grep -c "2.6.1"` >= 1. `grep -c "2.6.1" README.md` >= 1.
- [ ] **AC5 (no regression):** Product files (`WIZARD.md`, `CLAUDE.md`, `skills/`, `selection-presets.md`, `examples/`, `prompts/`, `templates/`, `.cowork-allowlist.json`, `cowork.lock.json`) byte-unchanged from v2.6.0. `git diff HEAD~1 -- WIZARD.md CLAUDE.md skills/ selection-presets.md examples/ prompts/ templates/ .cowork-allowlist.json cowork.lock.json` = 0 lines.
- [ ] **AC6 (link-rewrite, post-amendment 2026-05-11T15:30:00Z):** `README.md` and `SETUP-CHECKLIST.md` contain ZERO remaining relative-link references to `CHANGELOG.md` or `CONTRIBUTING.md`. `grep -nE '\((CHANGELOG\.md\|CONTRIBUTING\.md)\)' README.md SETUP-CHECKLIST.md` returns zero matches. All previously-relative links are rewritten to absolute `https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/...` URLs. Verified by archive extraction: `git archive --format=zip HEAD > /tmp/test.zip && unzip -q -d /tmp/test /tmp/test.zip && grep -RnE '\((CHANGELOG\.md\|CONTRIBUTING\.md)\)' /tmp/test --include='*.md'` returns zero matches.

---

## Edge Cases

1. **New tracked file added after this cycle without an `export-ignore` rule:** CI sanity check catches it on next release tag push. Regression guard prevents silent product bloat.
2. **`.gitattributes` applied to a `git clone` (not archive):** `export-ignore` rules have no effect on clones — contributor workflow is unaffected.
3. **`docs/` partial keep request:** Out of scope for this patch. If a specific doc is needed user-side, add it to README inline or via a link; don't carve out exceptions in `.gitattributes` (complexity risk).

---

## Risks

| Risk | Likelihood | Severity | Mitigation |
|------|-----------|----------|------------|
| `cowork.lock.json` is a runtime requirement missed in audit | LOW — verified via grep + README/SETUP-CHECKLIST references | HIGH — archive users couldn't run `/sync-agency` | KEEP classification; AC5 byte-unchanged guard |
| `.gitattributes` rule silently ignored (e.g., wrong glob syntax) | LOW — git archive rule is well-established | HIGH — archive would still include DROP files | AC2 explicitly extracts and inspects archive contents |
| New file added to repo after this cycle without export-ignore | MEDIUM — likely over time | LOW — minor bloat | AC3 CI regression guard catches on next tag push |
| `docs/` drop breaks a user flow relying on a specific doc | LOW — no user-facing doc in `docs/` is a setup requirement | LOW — discoverable via GitHub | Not in scope; treat as known acceptable tradeoff |

---

## Rollback

Revert the `.gitattributes` commit. The `release-assets.yml` sanity check is additive and safe to leave. No product files are modified by this cycle — rollback risk is zero for user functionality.

---

## Success Metrics

- **Primary:** Release archive contains zero DROP-list entries (AC2 green on CI).
- **Secondary:** CI regression guard fires correctly on injected test (AC3 green).
- **Tertiary:** No user-reported "what is CONTRIBUTING.md for" confusion in install feedback after v2.6.1 ships.

---

## Assumptions

- [CONFIRMED] `git archive` respects `.gitattributes` `export-ignore` rules — standard git behavior.
- [CONFIRMED] `cowork.lock.json` is required for `sync-agency.yml` CI and is referenced in user-facing README/SETUP-CHECKLIST — KEEP.
- [ESTIMATED] No user has built a workflow that depends on `docs/` being present in the archive.
- [UNTESTED] The sanity check approach (extract + grep) will not add meaningful CI time (expected < 10s on ubuntu-latest).

