# Changelog

All notable changes to this project are documented here. This project uses [Semantic Versioning](https://semver.org/).

---

## [2.1.0] — 2026-05-07

**v2.1 — Objective-First FSM + Team-Composition Framing + Stub Markers + Symlink Removal**

### Added

- **Objective-first wizard FSM (ADR-029):** CLAUDE.md Phase 1 rewritten as "Phase 1 — Objective & Team". The wizard now opens with "What do you need help with? Tell me what you want this workspace to do for you — I'll assemble the right team." Three routing branches (fits one area / spans areas / novel) all emit named team members with objective-specific roles, not a category list.
- **WIZARD.md §Phase 1 Uncertainty Fallback (ADR-029):** New section inserted before the existing fallback — three angles (Learning / Shipping / Writing) for users who reply "not sure". Referenced by CLAUDE.md Phase 1 final line.
- **WIZARD.md §Phase 1 Role-Generation Rule (ADR-030, AC-W2-9):** Verbatim-fallback rule encoded: if a generated role line does not contain at least one keyword from the source skill's `description` field, fall back to verbatim `description` (truncated to ≤12 words).
- **Resume-after-interrupt with objective context (ADR-031):** WIZARD.md Fallback section rewritten to read `Objective:` from `cowork-profile.md`. v2.0.x profiles (no Objective field) trigger one extra question before resuming. Partial-install detection checks `<workspace>/.claude/skills/` for already-installed team members.
- **`cowork-profile.md` Objective field (ADR-031):** Optional `Objective:` line added to WIZARD.md Step 1 template, after `Goal preset:`. Absence in v2.0.x profiles is non-error (backward-compatible).
- **Stub depth markers (ADR-030):** `depth: stub` and `expansion: v2.2+` YAML frontmatter added to all 12 stub SKILL.md files: writing (editing-pass, outline-generator, voice-matching), creative (creative-brief, feedback-synthesizer, ideation-partner), business-admin (email-drafting, doc-summary, action-items), personal-assistant (daily-briefing, follow-up-tracker, spend-awareness).

### Changed

- **`presets/` symlink removed (ADR-032, ADR-026):** The `presets/` backward-compat symlink (pointing to `examples/`) is removed. `examples/` is the sole canonical path from v2.1.0. All CI, CONTRIBUTING.md, and SETUP-CHECKLIST.md references updated to `examples/`. Upgrade note in SETUP-CHECKLIST.md §Upgrading from v2.0.x.
- **CLAUDE.md word count:** 363 → 397 words (hard cap 400; 3-word buffer). Phase 1 block replaced (81 words → 115 words per ADR-029 verbatim contract).

### Documentation

- **ADR-028** (doc-only): Second trust anchor (content_sha256 pinned-digest) contract frozen for v2.2+ implementation.
- **ADR-033** (codified): Release-artifact completeness checklist (VERSION + CHANGELOG + README badge + Next-up teaser) as a mandatory single Phase 4 sub-step.

---

## [2.0.4] — 2026-05-06

**Hotfix — fetch loop subshell scope fix + allowlist alignment (#28).**

**Fixed:**
- **#28-A BLOCKER** — Replaced `echo "$CATEGORY_LISTING" | jq -r '...' | while read` pipe pattern with a JSONL accumulator pattern in `sync-agency.yml`. The pipe spawned a subshell; `NEW_FILES_JSON` mutations were invisible to the parent shell, producing `Files fetched: 0` and an empty `cowork.lock.json` regardless of upstream content. The accumulator writes one JSON line per file via `jq -nc --arg/--argjson` (no string interpolation — S1 mitigation), then composes the final array with `jq -s '.'` after the loop completes. Accumulator filename includes `${GITHUB_RUN_ID}` suffix to prevent cross-run `/tmp` collision (E3). `trap EXIT` cleanup prevents accumulator file leak on mid-run failure (E1).
- **#28-B BLOCKER** — Trimmed `.cowork-allowlist.json` `.allowed_categories` from 13 entries to the vetted 10-entry subset matching real upstream `agency-agents/specialized/` directories: `academic, design, engineering, finance, marketing, product, project-management, sales, support, testing`. Removed 6 phantom entries (`business, content-creation, customer-success, data-analysis, hr, legal`) that silently produced empty lock sections because no matching upstream directory exists.

**Added:**
- **JSONL accumulator regression gate** in `sync-agency-dry-run` CI job (`quality.yml` step 3). Fetches 2 sample files from `academic/`, builds a JSONL accumulator exactly as `sync-agency.yml` does, then asserts `jq -s '.' | length >= 1`. Catches subshell-class regressions at PR time before any sync-agency edit ships broken to main.

---

## [2.0.3] — 2026-05-07

**Hotfix — sync-agency authentication + dry-run CI gate.**

**Fixed:**
- **#25 BLOCKER** — Added `Authorization: bearer ${GITHUB_TOKEN}` to all `api.github.com` curl calls in `sync-agency.yml` (HEAD-SHA fetch + per-category content listing). Without auth, GitHub Actions runner anonymous-IP pool rate-limits caused `curl -sf` to fail silently, blocking the workflow at "Fetch upstream latest HEAD SHA". Authenticated calls use the 5000-req/hr pool. `raw.githubusercontent.com` calls do NOT require auth (separate pool, anonymous-friendly).

**Added:**
- **`sync-agency-dry-run` CI job** in `quality.yml` — runs on every PR that touches `sync-agency.yml`, the THIRD-PARTY-NOTICES template, the allowlist, or the lock file. Simulates the first three critical workflow steps (fetch HEAD SHA via auth, fetch LICENSE, content-scan regex compile-check) at PR time, catching auth/rate-limit/regex/structural BLOCKERs BEFORE merge instead of post-merge. Closes the 3-cycle pattern (v2.0 #12 YAML, v2.0.1 envsubst, v2.0.2 SPDX/regex, v2.0.3 #25 auth). Pinned with `permissions: { contents: read }` for fork-PR safety (S1 Phase 2 finding).

**Process improvement:**
- Pattern P3 (action SHA hallucination) and the new dry-run gate together close the post-merge BLOCKER recurrence pattern observed across v2.0.0 → v2.0.2.

---

## [2.0.2] — 2026-05-07

**Hardening Bundle — 10 security, compliance, and documentation fixes from v2.0/v2.0.1 carry-forward.**

**Fixed:**
- **#23 BLOCKER** — Corrected hallucinated `peter-evans/create-pull-request` SHA in `sync-agency.yml`. Previous SHA (271a8d0...) was not a real commit; replaced with verified v7.0.6 SHA (67ccf78...). Without this fix, the PR-creation step in `/sync-agency` fails silently.
- **#13** — Added per-file SPDX comparison step to `sync-agency.yml`. Reads OLD `.files[].spdx` from the pre-update lock file, compares to NEW entries from the fetch. If any SPDX field changes: adds `legal-review-required` label AND fails CI until @compliance acknowledges. Bootstrap-tolerant (skips when old lock has no `.files[]` entries). Closes ADR-022 compliance gap (v2.0 Phase 5 C8).
- **#14** — Created `.github/PULL_REQUEST_TEMPLATE.md` with Summary, Test plan, and Agency-Sync Checklist sections. Checklist (collapsible, agency-sync-only) requires lock file diff review, ≥3 file sample-audit per category, nexus-strategy.md absence check, SPDX acknowledgment, and 24h soak rule. Closes v2.0 Phase 6 A3 finding.
- **#15** — Added `verbatim-attribution-rule-check` job to `quality.yml`. Greps `CLAUDE.md` and `WIZARD.md` for the exact 4-sentence non-overridable attribution rule (ADR-024). Fails CI if the literal string is absent from either file. Closes G3 finding from v2.0 Phase 5.
- **#16** — Closed as superseded by ADR-027. ADR-027 (template extraction, v2.0.1) eliminates the heredoc delimiter surface that issue #16 proposed randomizing.
- **#17** — Changed fetch loop staging path from `/tmp/fetched-files/${filename}` to `/tmp/fetched-files/${category}/${filename}` with `mkdir -p` guard. Prevents filename collisions across categories. Closes A6 finding from v2.0 Phase 6.
- **#18** — Added `permissions: read-all` at workflow top level in `sync-agency.yml`. Job-level `contents: write, pull-requests: write` explicit grants remain. Closes A7 finding from v2.0 Phase 6.
- **#19** — Added Windows symlink note to `SETUP-CHECKLIST.md` explaining `presets/ → examples/` symlink behavior. Three workarounds documented: (a) Developer Mode, (b) `git clone -c core.symlinks=true`, (c) use `examples/` directly. Notes symlink removed in v2.1.0 (ADR-026). Closes A8 finding from v2.0 Phase 6.
- **#20** — ADR-023 amendment block recording live 13-category enumeration from `.cowork-allowlist.json` written to `docs/architecture.md` by @architect Phase 1. Closes v2.0 Phase 5 B2 (ADR-023 placeholder drift). Live categories: `academic`, `business`, `content-creation`, `customer-success`, `data-analysis`, `design`, `engineering`, `finance`, `hr`, `legal`, `marketing`, `product`, `support`.
- **#21** — Added `concurrency: { group: sync-agency, cancel-in-progress: false }` at workflow top level in `sync-agency.yml`. Prevents concurrent sync-agency runs; in-progress runs are preserved when a new push queues. Closes A4 finding from v2.0 Phase 6.
- **P3 baseline** — Extended `CONTRIBUTING.md` CI Workflow Quality Baseline with Check 3: every `uses:` SHA MUST be verified via `gh api repos/<owner>/<repo>/git/refs/tags/<tag>` at Phase 5. Hallucinated SHAs are blocking. Codifies P3 pattern from v2.0 retrospective.

**YAML validation:** `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/sync-agency.yml'))"` and `yaml.safe_load(open('.github/workflows/quality.yml'))` both pass.

---

## [2.0.0] — 2026-05-07

**Dynamic Workspace Architect — upstream content integration via msitarzewski/agency-agents.** Major supply-chain infrastructure: SHA-pinned lock file, fail-closed allowlist, monthly sync CI, prompt-injection content scan, attribution injection (ADR-024 full MIT block), THIRD-PARTY-NOTICES.md. All 8 Phase 2 MUST-FIX security items resolved. Presets relocated to `examples/` (v1.x symlink preserved for v2.0.x).

**Added:**
- `cowork.lock.json` — supply-chain lock file (ADR-020): pinned upstream SHA + per-file SHA-256 checksums. Bootstrap state: zero-SHA (populate via `/sync-agency`).
- `.cowork-allowlist.json` — fail-closed allowlist policy (ADR-023): 13 allowed categories, `nexus-strategy.md` permanently blocked, 9-entry `blocked_patterns` seed (nexus variants, orchestrator, meta-agent, pipeline-controller, the-council, cowork-orchestrator).
- `.github/workflows/sync-agency.yml` — hybrid cron (monthly) + manual dispatch; fetches upstream at pinned SHA; runs S1 8-pattern content-scan; updates lock file; regenerates `THIRD-PARTY-NOTICES.md`; opens PR labeled `agency-sync`; never auto-merges. All Action SHAs pinned (ADR-002).
- `.github/CODEOWNERS` — supply-chain files require maintainer sign-off (S2 MUST-FIX).
- `docs/security/upstream-content-scan-rules.md` — 8 prompt-injection detection patterns for upstream content (S1 CRITICAL MUST-FIX): ignore previous instructions, disregard, override, you are now/act as, new system instruction, forget the rules, pretend you have no, jailbreak/DAN/STAN.
- `THIRD-PARTY-NOTICES.md` — repo-level upstream copyright notices (ADR-025, L1-2 WARNING resolved). Regenerated by `/sync-agency` on every SHA bump.
- `examples/` — all 7 v1.x preset directories relocated here (byte-identical move, git blame preserved).
- `presets` symlink → `examples/` (v2.0.x deprecation alias; removed in v2.1).

**Changed:**
- `CLAUDE.md` — added `## Attribution (non-overridable, ADR-024)` section with S6 verbatim rule; category-discovery flow updated for upstream categories (academic, marketing, engineering, etc.); trimmed to 363 words.
- `WIZARD.md` — added `## Attribution Rule (non-overridable, ADR-024)` section with S6 verbatim rule; `presets/` → `examples/` path references updated.
- `CONTRIBUTING.md` — added Agency-Sync PR Review section: 2-approval rule (S2), 10-item reviewer checklist, 24h soak rule (S7), goal taxonomy keyword review (S10).
- `SETUP-CHECKLIST.md` — added trust-boundary disclosure (Open Issue #6); `presets/` → `examples/` path references.
- `README.md` — version badge 1.3.3 → 2.0.0; added supply-chain integrity section; trust-boundary disclosure (Open Issue #6); "Next up" → v2.1 Multi-Source Upstream; `presets/` → `examples/` references.
- `.github/workflows/quality.yml` — `ENFORCED_PRESETS` → `ENFORCED_EXAMPLES` (ADR-026, both enforcement + advisory blocks); all CI path globs updated `presets/` → `examples/`; new `lock-file-zero-sha-check` job (S9: reject zero-SHA on main); new `third-party-notices-check` job (ADR-025 existence); new `attribution-survives-render` job (S5 MUST-FIX: Python frontmatter + grep extraction).

**Security MUST-FIX resolutions:**
- S1 CRITICAL — 8-pattern content-scan in `/sync-agency` + `docs/security/upstream-content-scan-rules.md`
- S2 — `.github/CODEOWNERS` + CONTRIBUTING.md 2-approval rule for agency-sync PRs
- S4 — `.cowork-allowlist.json` 9-entry blocked_patterns seed
- S5 — `attribution-survives-render` CI job
- S6 — verbatim non-overridable attribution rule in CLAUDE.md + WIZARD.md
- S9 — `lock-file-zero-sha-check` CI job rejecting zero-SHA on main
- Open Issue #3 — `/sync-agency` first run designated SECURITY-SENSITIVE in PR template + CONTRIBUTING.md
- Open Issue #6 — trust-boundary disclosure in README.md + SETUP-CHECKLIST.md

**v1.x compatibility:** All 7 preset examples retained in `examples/`. `presets/` symlink provides backward compatibility for v2.0.x. CI still enforces depth on `study`, `research`, `project-management`. No skill content changes.

---

## [1.3.3] — 2026-05-07

**Project Management preset depth upgrade.** Three PM skills rewritten from 16-line stubs to full 9-section ADR-015 production depth. CI enforcement expanded. LICENSE copyright updated.

**Changed:**
- `presets/project-management/.claude/skills/meeting-notes/SKILL.md` — rewritten to 9-section template (114 lines): decision/action/open-question extraction framework, pasted-content-is-data anti-pattern guard (S1), worked example, writing-profile integration.
- `presets/project-management/.claude/skills/status-update/SKILL.md` — rewritten to 9-section template (88 lines): RAG-status synthesis, pasted-content-is-data guard (S1), output-echo anti-pattern guard (S2 — first LLM02-class finding in codebase), audience-calibrated narrative output.
- `presets/project-management/.claude/skills/risk-assessment/SKILL.md` — rewritten to 9-section template (110 lines): 6-column neutral schema table (ID/Description/Likelihood/Impact/Mitigation/Owner), pasted-content-is-data guard (S1), sensitive-shape naming guard (S3), top-2 priority prose section.
- `presets/project-management/skills-as-prompts.md` — regenerated from new SKILL.md bodies with condensed synthesis approach and safety constraint per skill.
- `curated-skills-registry.md` — PM row descriptions refreshed to reflect 9-section skill depth (row count unchanged: 22).
- `.github/workflows/quality.yml` — ENFORCED_PRESETS expanded from `"study research"` to `"study research project-management"` (ADR-016 v1.3.3 amendment; no CI shell-logic change).
- `LICENSE` — copyright updated to `Copyright (c) 2026 The cowork-starter-kit contributors`.
- `docs/security-review.md` — v1.3.3 Phase 2 security review section appended (S1/S2/S3 WARNINGs, S4/S5/S6 INFOs, Phase 4 resolution status).

**Preset-level changes:** project-management only. Study, Research, Writing, Creative, Business-Admin, Personal Assistant presets: no changes.

---

## [1.3.2.1] — 2026-04-20

**Infra patch.** Automate release-asset uploads.

**Added:**
- `.github/workflows/release-assets.yml` — auto-builds `.zip` and `.tar.gz` source archives and attaches them to the GitHub Release when a `v*` tag is pushed. Uses SHA-pinned actions (checkout v4.2.2, softprops/action-gh-release v3.0.0).

**Changed:**
- Future releases automatically include trackable download assets. Prior releases (v1.1.0–v1.3.2) were backfilled manually on 2026-04-20.

---

## [1.3.2] — 2026-04-19

> **Note:** This release was initially tagged as v1.4.0 (2026-04-19) but was renamed to v1.3.2 to align with the v1.3.x preset-rollout versioning lane. Content is identical to the original v1.4.0 release.

**Personal Assistant Preset (7th preset) + Security Posture.** Adds a new goal preset for daily personal life management, introducing the first sensitive-personal-data surface in cowork-starter-kit history and the ADR-019 Data-Locality Rule pattern.

**Added:**

- 7th preset `presets/personal-assistant/` — full scaffold: README, folder-structure (Calendar/, Finances/, Tasks/, People/, Documents/), writing-profile, connector-checklist, context/ (5 files), project-instructions-starter.txt, cowork-profile-starter.md, skills-as-prompts.md
- 3 stub skills for Personal Assistant preset:
  - `presets/personal-assistant/.claude/skills/daily-briefing/SKILL.md` — 16-line stub; morning briefing from local Calendar/, Tasks/, People/ folders
  - `presets/personal-assistant/.claude/skills/follow-up-tracker/SKILL.md` — 16-line stub; logs commitments owed and pending from conversations and inbox
  - `presets/personal-assistant/.claude/skills/spend-awareness/SKILL.md` — 16-line stub; paste-based transaction summarizer; descriptive only (no investment advice, budgeting recommendations, or savings plans)
- ADR-019 "Instruction-Surface Security Posture" — 4-element contract for data-category constraints (exact heading, grep phrase, placement, setup-surface reinforcement); explicit scope limitation: NOT appropriate as sole control for regulated data (HIPAA PHI, PCI, GDPR Art. 9); bold callout block added to architecture.md per S7
- ADR-015 v1.3.2 amendment — Trigger 1 direct-invocation exempt from proactive-mapping requirement with global-instructions.md; codifies v1.3.1 Phase 6 implicit behavior
- Data Locality Rule in `presets/personal-assistant/global-instructions.md` — 6 sensitive-data categories (financial amounts, calendar events, contact details, health information, physical addresses, authentication credentials); decline-and-redirect rule; pasted-content-as-data rule; placed BEFORE proactive trigger rules per ADR-019
- New persona: Life Admin Juggler (v1.3.2 PRD)
- `presets/personal-assistant/connector-checklist.md` — finance paste-only prohibition with explicit naming of prohibited connectors (Plaid, Yodlee, bank APIs)
- S4 note in ADR-019 Consequences: redaction escape-valve scoped to PA preset in v1.3.2; community preset authors must revisit before broadening

**Changed:**

- `WIZARD.md` Q1 — Personal Assistant added as 7th goal option; Q3 — preset-specific question added for Personal Assistant; fallback message updated "6 options" → "7 options"
- `CLAUDE.md` — `personal-assistant` alias added to preset enumeration (350 words maintained via compensating trim of "sample" in Step 6 phrasing — non-semantic trim)
- `curated-skills-registry.md` — Personal Assistant section added; 3 new rows (daily-briefing, follow-up-tracker, spend-awareness); total 19 → 22 entries
- `README.md` — version badge 1.3.1 → 1.3.2; preset table updated to 7 presets; "Six goal presets" → "Seven goal presets"; Next up teaser updated
- `docs/security-review.md` — v1.3.2 Phase 2 security review appended (0 CRITICAL / 3 WARNING / 6 INFO; classification SECURITY-SENSITIVE; data-locality verdict ACCEPT WITH REFINEMENT; all 6 @architect open issues resolved)

**Security:**

- First SECURITY-SENSITIVE cycle since v1.2; first sensitive-personal-data surface in cowork-starter-kit history
- 9 MUST-FIX carry-forwards from Phase 2 absorbed: S1 (data-category extension), S2 (pasted-content-as-data rule), S3 (CLAUDE.md word-count preserved), S4 (ADR-019 S4 note), S5 (spend-awareness anti-pattern line), S6 (finance connector prohibition), S7 (ADR-019 scope bold callout), S8 (WIZARD.md "7 options"), Issue 5 (IP boundary grep — 0 hits confirmed)

---

## [1.3.1.1] — 2026-04-18

**Documentation patch.** No functional changes.

**Changed:**
- README.md version badge corrected 1.2.0 → 1.3.1 (stale since v1.3.0 release)
- README.md "Next up" teaser updated from shipped v1.3.0 to upcoming v1.3.2 Writing preset depth
- templates/skill-template/SKILL.md CONTRIBUTOR NOTICE block — removed stale "(arriving in v1.3.0 B2 commit)" future-tense reference; placeholder authoring rules are now live

---

## [1.3.1] — 2026-04-18

**Research Preset Depth + Carry-Forward Hygiene** — rewrites all 3 Research preset skills to the full 9-section ADR-015 template, expands skill-depth CI enforcement to include the Research preset, and resolves all 3 Phase 2 v1.3.1 security carry-forwards.

**Added:**

- 3 Research preset skills rewritten to full depth:
  - `presets/research/.claude/skills/literature-review/SKILL.md` — thematic matrix + gap analysis framework; theme/source count header; 7 quality criteria; 7 anti-patterns; four-tier writing-profile rule (cells terse, count-line neutral, synthesis adapts, gaps adapt); BibTeX-aware extension
  - `presets/research/.claude/skills/source-analysis/SKILL.md` — 7-field evaluation card (source type, authority, methodology, evidence quality, limitations, bias, bottom line); citation recommendation as Bottom line; two-tier writing-profile rule (fields 1–6 terse, Bottom line adapts)
  - `presets/research/.claude/skills/research-synthesis/SKILL.md` — Research preset variant (ADR-018); always peer-review-rigor; 7-column matrix (claim, method, evidence, limitations, authority, recency, citation-network); four synthesis sections (Agreements, Disagreements, Gaps, Synthesis); four-tier writing-profile rule; intentionally distinct from Study variant
- `presets/research/skills-as-prompts.md` — regenerated from the 3 new Research SKILL.md files; replaces v1.0 stubs with full 9-section prose content for each skill; preserves ADR-003 dual-path fallback usability

**Changed:**

- `presets/research/global-instructions.md` — trigger rules expanded to cover all 4 modes per Research skill (literature-review: academic survey + thesis chapter; source-analysis: citation vetting + claim-specific evaluation; research-synthesis: peer-review prep + systematic review + meta-analysis framing)
- `curated-skills-registry.md` — Research preset descriptions updated to match v1.3.1 SKILL.md frontmatter; new `research-synthesis` Research entry added (ADR-018 dual-file; 19 total rows); vetting dates updated to 2026-04-18
- `.github/workflows/quality.yml` — `skill-depth-check` job: `ENFORCED_PRESETS` expanded from `"study"` to `"study research"`
- `CONTRIBUTING.md` — v1.3.1: B10 input-session template section added (full 6-Q schema, defaults+clarify pattern for skills 2+); After Phase 7 push-and-PR checklist added; PR reviewer checklist item 19 added (cross-preset slug-divergence check per ADR-018)
- `CLAUDE.md` — trimmed to 350 words (carry-forward from v1.2 audit A3; target met)

**Security (Phase 2 carry-forwards resolved):**

- S1 (MUST-FIX): CONTRIBUTING.md B10 section documents 3 worked-example authoring rules (real sources only; forbidden imperative token scan; user-written expected output); all 3 Research SKILL.md `## Example` sections cite real peer-reviewed sources (Miller 1956, Baddeley 2000, Cowan 2001) with no imperative tokens outside code fences
- S2 (SHOULD-FIX): CONTRIBUTING.md PR reviewer checklist item 19 added for cross-preset slug-divergence verification (ADR-018 enforcement by review, not CI)
- S3 (MUST-FIX): `presets/research/global-instructions.md` updated so all 4 trigger modes per Research skill map to "offer automatically when" firing conditions; `## Triggers` sections in B1/B2/B3 are a subset-or-extend of the updated global rules

---

## [1.3.0] — 2026-04-18

**Preset Skills Depth — Study Preset Pilot** — rewrites all 3 Study preset skills to the full 9-section ADR-015 template, adds skill-depth CI enforcement, and resolves all 4 Phase 2 v1.3 security carry-forwards.

**Added:**

- 9-section skill template (ADR-015): `## When to use`, `## Triggers`, `## Instructions`, `## Output format`, `## Quality criteria`, `## Anti-patterns`, `## Example`, `## Writing-profile integration`, `## Example prompts` — enforced via CI for the Study preset pilot
- `skill-depth-check` CI job (ADR-016): validates each Study preset skill has all 9 required section headings and meets the 60-line floor; path allowlist prevents false positives on non-skill files
- 3 Study preset skills rewritten to full depth:
  - `presets/study/.claude/skills/flashcard-generation/SKILL.md` — Anki-ready output with human-readable + TSV blocks, 6 quality criteria, 6 anti-patterns, writing-profile integration, spaced-repetition atomicity rules
  - `presets/study/.claude/skills/note-taking/SKILL.md` — 4-framework auto-selection (Cornell / Outline / Zettelkasten / Lightweight), 11-step instructions, 7 quality criteria, 7 anti-patterns, 3-tier writing-profile rule
  - `presets/study/.claude/skills/research-synthesis/SKILL.md` — source-count mode auto-selection (1/2/≥3), full matrix + synthesis output, BibTeX-aware extension, 7 quality criteria, 7 anti-patterns
- Retro-template carry-forward workflow (B8): `docs/retro.md` v1.3.0 section added with carry-forward surfacing process
- README "Next up" teaser (B9): `## Next up` section added describing v1.4 Research preset pilot
- CONTRIBUTING.md v1.3: checklist items 12–17 added (skill-depth-check CI requirements); placeholder-authoring rules: 5 rules stating when placeholder content is acceptable (no undeclared gaps, examples must be real)
- `.gitignore` guard: patterns added for `.claude/projects/` and `skill-inputs/` directories to prevent accidental commit of local pipeline state and user skill-input files (S4 carry-forward)

**Changed:**

- `curated-skills-registry.md`: Study preset descriptions updated to match v1.3.0 SKILL.md frontmatter (`description:` field) for all 3 entries; vetting dates updated to 2026-04-18
- `presets/study/skills-as-prompts.md`: regenerated from the three v1.3.0 SKILL.md files; replaces 16-line v1.2 stubs with full 9-section prose content for each skill; preserves ADR-003 dual-path fallback usability as a single pasteable prompt
- `.github/workflows/quality.yml` `registry-url-check` job: tightened URL validation to require `https://github.com/` prefix for non-builtin entries (was any HTTPS URL)

**Security (Phase 2 carry-forwards resolved):**

- S1: CI advisory notice added — `skill-depth-check` job comments warn when a skill file is near the CI floor; CONTRIBUTING.md v1.3 documents the fail-open rationale
- S2: CONTRIBUTING.md v1.3 item 16 added: SHA-pin all GitHub Action versions before publishing community skills
- S3: Inline negative test added to `skill-depth-check` CI job: verifies the check correctly rejects a synthetic 59-line stub
- S4: `.gitignore` guard added for `skill-inputs/` and `.claude/projects/` — prevents local user input files from being committed to the public repo

---

## [1.2.0] - 2026-04-17

**Dynamic Workspace Architect** — the wizard now discovers your goal before proposing a workspace, adds a universal writing profile step for all presets, and ships a curated skills registry for goal-matched skill discovery.

**All 6 presets updated.**

**New files:**

- `curated-skills-registry.md` — Tier 1 curated skills registry at repo root; 18 vetted entries (3 per preset); Tier 2 community section with opt-in instructions; community PR process for additions
- `templates/writing-profile-template.md` — canonical writing profile template with 5 sections; used by contributors for new presets; CI-enforced
- `presets/*/context/writing-profile.md` (6 new files) — goal-appropriate writing profile defaults for each preset; not blank; user fills in personal details

**Updated files (all presets):**

- `project-instructions-starter.txt` (6 files) — rewritten with dynamic wizard flow: open-ended goal discovery, suggestion branch for uncertain users, preset detection + accelerator offer, novel-goal handling, writing profile step (3–4 questions), fast-track pause; ≤400 words each
- `global-instructions.md` (6 files) — added writing profile trigger rule: reference `writing-profile.md` when generating content ≥100 words

**Infrastructure:**

- `CLAUDE.md` — rewritten with full dynamic wizard (same as starter files); replaces v1.1.1 preset-selector content; Layer 1a universal entry point per ADR-010
- `CONTRIBUTING.md` — PR checklist updated to v1.2 (11 items); added CLAUDE.md high-impact guidance, registry entry requirements, SHA-pinning guidance, writing-profile.md requirements
- `.github/workflows/quality.yml` — 3 new CI jobs: `claude-md-word-count-check` (≤400 words), `writing-profile-template-check` (template + required sections), `registry-url-check` (HTTPS-only source_url)
- `VERSION` — bumped to 1.2.0

---

## [1.1.1] - 2026-04-16

**Zero-paste setup** — adds `CLAUDE.md` at repo root so Cowork auto-runs the onboarding wizard when you open the project. No copy-paste required.

**New files:**

- `CLAUDE.md` — project instructions auto-loaded by Cowork; contains preset-agnostic onboarding state machine and safety rule

**Updated files:**

- `README.md` — Quick Start simplified to 3 steps (download, open, talk)
- `SETUP-CHECKLIST.md` — paste step demoted to optional; wizard starts automatically
- `.github/workflows/quality.yml` — new CI job: `claude-md-safety-rule-check`
- `VERSION` — bumped to 1.1.1

---

## [1.1.0] - 2026-04-16

**Wizard Architecture Redesign** — fixes the v1.0 root cause failure where Cowork's intent classifier intercepted WIZARD.md before it could be read.

**All 6 presets updated.**

**New files (all presets):**

- `project-instructions-starter.txt` — paste into Project Settings > Custom Instructions BEFORE any conversation; contains state machine check + abbreviated onboarding interview + ongoing behavior rules; primary trigger path
- `.claude/skills/<skill-name>/SKILL.md` — all skills converted from flat `.md` to `folder/SKILL.md` format with YAML frontmatter for auto-discovery as `/slash-commands`

**Updated files (all presets):**

- `global-instructions.md` — rewritten from passive skill list to proactive trigger rules format; explicit trigger conditions and offer phrases for each skill
- `context/about-me.md` — added `Upcoming deadlines:` field for session-start deadline surfacing

**Infrastructure:**

- `.claude/skills/setup-wizard/SKILL.md` — root-level /setup-wizard skill for explicit fallback invocation; includes reset confirmation guard
- `WIZARD.md` — marked documentation-only with top note; no longer a runtime path
- `SETUP-CHECKLIST.md` — Step 3 is now paste `project-instructions-starter.txt` (before any conversation)
- `README.md` — updated flow diagram and Quick Start with new architecture
- `CONTRIBUTING.md` — PR checklist updated to v1.1 (7 items including starter file, word count, safety rule in starter, skill format)
- `templates/preset-template/` — added `project-instructions-starter.txt` template and `example-skill/SKILL.md`
- `docs/OUTPUT-STRUCTURE.md` — updated to show `project-instructions-starter.txt` as primary output artifact
- `.github/workflows/quality.yml` — 3 new CI jobs: `starter-file-check`, `starter-safety-rule-check`, `skill-format-check`
- `VERSION` — bumped to 1.1.0

---

## [1.0.0] - 2026-04-15

Initial release.

**Presets included:**

- Study — research, note-taking, flashcard generation
- Research — literature review, source analysis, synthesis
- Writing — voice matching, editing, outlining
- Project Management — status updates, meeting notes, risk assessment
- Creative — ideation, creative briefs, feedback synthesis
- Business/Admin — email drafting, report summary, action items

**Infrastructure:**

- WIZARD.md — Cowork-as-wizard primary delivery
- SETUP-CHECKLIST.md — manual fallback path
- scripts/setup-folders.sh — bash folder creation (macOS)
- scripts/setup-folders.ps1 — PowerShell folder creation (Windows)
- templates/preset-template/ — contributor scaffold
- templates/global-instructions-base.md — safety rule source of truth
- .github/workflows/quality.yml — CI: markdown lint, link check, shellcheck, safety-rule enforcement
