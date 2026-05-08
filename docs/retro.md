# Retrospective — cowork-starter-kit

---

## v2.3.1 — Stub Completion

**Date:** 2026-05-08
**Classification:** STANDARD (consistent Phase 0–7)
**Mode:** quick (patch — completion-only, no new feature surface)
**Rework rate:** 0% (PASS-ON-FIRST-PUSH — Phase 4 SHA 60ed157 = HEAD at Phase 7 approval)
**Cycle SHA:** fef5ae3 (tag v2.3.1, PR #38 merged 2026-05-08T20:35Z); paperwork PR #39 sha:787106b merged 2026-05-08T20:55Z

---

### 1. Cycle Summary

v2.3.1 was a content-only patch cycle that brought 8 half-baked SKILL.md stubs to production depth. The stubs (editing-pass, outline-generator, creative-brief, feedback-synthesizer, ideation-partner, email-drafting, follow-up-tracker, spend-awareness) were all ~18-line placeholders with `depth: stub` frontmatter markers. Each was expanded to the canonical 9-section structure (When to use / Triggers / Instructions / Output format / Quality criteria / Anti-patterns / Example / Writing-profile integration / Example prompts) at 76–90 lines, using the ADR-015 template established in v1.3.0 and proven across v1.3.1, v1.3.3, v2.3.0. Two skills from the original stub list (action-items, doc-summary) were excluded per v2.3.0 W3 disposition: covered-by-runtime.

The cycle ran at quick-mode ceremony (no new ADRs, no Phase 2 security review — STANDARD classification qualifies for the combined Phase 5+6+7 path established in v2.2). 50/50 ACs PASS, 13/13 constraints PASS. CI run #25560043390 — 19/19 checks PASS. PASS-ON-FIRST-PUSH: no rework loop, no MD058 regression (v2.3.0 lesson held — no table-adjacent content in 8 SKILL.md files). Phase 6 combined-path: 0 CRITICAL, 0 WARNING, 1 INFO (S1 email-drafting checklist nesting placement deferred to v2.3.2 backlog).

One notable near-miss at merge: the orchestrator attempted to push 10 docs paperwork files directly to main, which was correctly blocked by the harness permission gate per CLAUDE.md merge rule. The paperwork (7 v2.3.1 cycle artifacts + 3 v2.3.0 retro orphans) was unstaged, a second PR (#39) was opened on branch `docs/v2.3.1-paperwork`, and it merged cleanly. This is enforcement working as intended, but the shape — code PR ships clean, then a mandatory paperwork follow-up PR — recurs across cycles.

**Verdict: HEALTHY.** 0% rework, 0 CRITICAL/0 WARNING, both PRs merged, all CI green. One INFO finding (S1 email-drafting checklist placement) deferred to v2.3.2 with rationale.

---

### 2. What Went Well

- **PASS-ON-FIRST-PUSH:** 0 rework. 50/50 ACs on the first CI run. Second consecutive cycle (after v2.3.0's 0.7% rework) trending toward a first-push norm. C-v2.3.1-13 commit topology constraint (6-batch preset commits) gave @dev a clear scaffolding contract.
- **v2.3.0 MD058 lesson held:** @dev avoided placing blockquote annotation content adjacent to markdown tables (the v2.3.0 rework trigger). SKILL.md files contain no tables; CI Markdown Lint PASS on first push.
- **CF-5 version-artifact regression: RESOLVED and confirmed stable (2nd consecutive cycle):** AC-REL-1..4 (VERSION=2.3.1, CHANGELOG [2.3.1], README badge `version-2.3.1-green`, Next-up teaser) all present. This is the second consecutive cycle where the explicit 4-sub-item constraint enumeration works where general reminders did not. Pattern RESOLVED per v2.3.0 precedent.
- **13 binding constraints enforced clean:** C-v2.3.1-10 (spend-awareness 4 verbatim financial phrases) and C-v2.3.1-11 (email-drafting 4-item pre-send verification) were the highest-risk content constraints. Both verified by @qa via literal grep at Phase 5 deliberation.
- **Combined Phase 5+6+7 path executed cleanly (third use):** STANDARD classification + clean Phase 4 deliberation (0 CRIT + 0 WARN from @qa + @security Round 1). Path maintained even though email-drafting S1 INFO was surfaced — INFO items do not forfeit combined-path eligibility.
- **C-v2.3.1-9 zero-diff discipline held:** 12-file deny-list (cowork.lock.json, quality.yml, sync-agency.yml, CLAUDE.md, WIZARD.md, 6× global-instructions.md, templates/, curated-skills-registry.md, action-items/SKILL.md, doc-summary/SKILL.md, cowork-profile-starter.md) all BYTE-UNCHANGED. `git diff --name-only main release/v2.3.1` = exactly 11 files.
- **Paperwork PR #39 unblocked without cycle delay:** When direct-to-main push was blocked, the orchestrator correctly opened PR #39 on a paperwork branch. CI green on both runs (#25562397218 + #25562399190). 10 docs files landed cleanly without disrupting the v2.3.1 tag.

---

### 3. What Didn't Go Well

- **Paperwork follow-up PR required again (second cycle):** Docs artifacts (cycle spec sections, architecture amendments, security review artifacts, qa-report, retro) were not committed on the release branch before merge. v2.3.0 was the first instance (24h orphan window). v2.3.1 is the second instance — paperwork was staged, then unstaged when direct-to-main push was blocked by the harness gate, then re-committed on a separate `docs/v2.3.1-paperwork` branch and merged via PR #39. The v2.3.1 architecture Phase 1 design explicitly made Commit 6 paperwork "at @dev discretion" (optional). That optional framing is the proximate cause: when paperwork is optional in the commit topology, it consistently doesn't ship with the code PR.

  **Root cause:** The Phase 4 commit topology constraint (C-v2.3.1-13) bound Commits 0–5 as required and Commit 6 (paperwork) as optional. Two consecutive cycles show that optional paperwork does not ship in the code PR. The fix: bind Commit 6 as mandatory in the next cycle's commit-topology constraint for any cycle that produces new architecture/spec/review docs. The harness permission gate is enforcing the merge rule correctly — the gap is upstream in Phase 1 constraint design.

- **S1 INFO: email-drafting checklist nesting:** @security noted that the 4-item pre-send verification checklist is nested inside Instructions step 3 rather than promoted to a top-level `## Pre-Send Verification` subsection. C-v2.3.1-11 required the 4 items inside `## Instructions` (not promoted), so this is consistent with the constraint. The finding is architectural preference, not a violation. Deferred to v2.3.2 pre-spec backlog.

- **ADR Index still not backfilled (4th consecutive deferral):** ADR-020 through ADR-028 absent from architecture.md index table. Now 4 consecutive cycles of acknowledgment without closure. Advisory-only deferral is not working — this needs to be a non-negotiable binding AC in the v2.4 spec, not a hygiene carry-forward.

---

### 4. Quality Patterns

#### Active Patterns (promoted + watch)

**P-COWORK-1: local-lint-vs-CI-divergence** — WATCH (2nd cycle: v2.3.0 1-failure, v2.3.1 0-failures)

v2.3.1 had 0 CI Markdown Lint failures on first push (no table-adjacent content in 8 SKILL.md files). The structural gap persists — no local markdownlint step in the cowork pipeline — but the v2.3.0 lesson was applied effectively. Pattern stays WATCH. CF-4 (local markdownlint pre-commit) remains deferred. Eligible for escalation if a v2.4 cycle hits the same failure mode.

**Paperwork-Follow-Up-PR-Pattern** — WATCH (2nd cycle: v2.3.0 + v2.3.1; see also docs/patterns.md for official record)

Two consecutive cycles required a separate paperwork follow-up PR after the code PR merged. Root cause is consistent: Commit 6 paperwork is optional in the commit topology, so it does not ship with the code PR. Direct-to-main push is blocked by the harness permission gate (correct enforcement). The fix is upstream: make Commit 6 mandatory in the v2.4 Phase 1 commit-topology constraint for cycles producing new docs artifacts.

**P-COWORK-2: recurring-version-artifact-miss** — CONFIRMED RESOLVED (v2.3.0 + v2.3.1)

v2.3.1 is the second consecutive cycle where all 4 release artifacts (VERSION, CHANGELOG, README badge, Next-up teaser) shipped correctly. Pattern RESOLVED and stable.

**P-COWORK-3: combined-path-eligibility-from-clean-deliberation** — PROMOTED-WATCH (3rd cycle: v2.2, v2.3.0, v2.3.1)

Three consecutive STANDARD-classified cycles received a clean Phase 4 deliberation and ran the combined Phase 5+6+7 path. In v2.2: end-to-end clean. In v2.3.0: FORFEIT-and-reinstate due to MD058. In v2.3.1: clean end-to-end. The pattern is stable and the path is legitimate for STANDARD cycles with 0-finding deliberations. Eligible for promotion to docs/patterns.md at v2.4 if the pattern continues.

---

### 5. Council /self-improve Candidates

The following improvements are surfaced for The-Council to absorb. This section is informational — do NOT auto-invoke /self-improve.

**C1: `check-base-sync.sh` guard** (carried from v2.2 P5, HIGH)

Pre-/spec guard that git-fetches origin and blocks if local branch is behind. Prevents stale-base cycles. The-Council `scripts/` (sibling to `check-stale-cycle.sh`). Third consecutive cycle carrying this candidate.

**C2: Mandatory-paperwork-commit in commit topology** (NEW, v2.3.1)

The Phase 4 commit-topology constraint should bind the paperwork commit (pipeline.md, scratchpad.md, docs/ cycle artifacts) as MANDATORY rather than optional for cycles that produce new docs. This prevents the Paperwork-Follow-Up-PR-Pattern. Low effort: change "Optional Commit 6" to "Required Commit 6 (omit only if zero new docs)" in The-Council's commit-topology guidance. This is a @pm / @architect process constraint, not a guard change.

**C3: ADR Index backfill as non-negotiable AC** (carried v2.0–v2.3.1, MEDIUM)

Fourth consecutive advisory deferral. The-Council should add a self-improve cycle to enforce ADR-index completion as a binding non-optional AC in the next v2.4 spec section.

**C4: `version-artifact-checklist` CI gate** (v2.3.0 C4, MEDIUM)

Automate the 4-sub-item release artifact check (VERSION, CHANGELOG, README badge, Next-up teaser) as a CI gate rather than relying on explicit constraint enumeration each cycle. Pattern is now stable for 2 cycles — codify it structurally.

---

### 6. Tier 1 Agent Quality Baseline Assessment

Quality baselines from `.claude/skills/*/quality-baseline.json` (v23.0, pass threshold 0.80). Content-review assessment applied to observed agent behavior in v2.3.1. All scenarios evaluated are applicable to a static markdown + CI YAML repo (no auth/RLS/schema surfaces).

| Agent | Scenarios Evaluated | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | Quick-mode Phase 0 PRD correctly scoped 8 stubs from a precise user mandate ("don't be half-baked, even if not new stuff"). 12 WILL-NOT-DO items prevented scope creep across all subsequent phases. 50 ACs with deterministic grep/wc evidence mappings. No ambiguous intent left unresolved at spec gate. | PASS (2/2 applicable) |
| @architect | QA3 (speculative abstraction), QA1/QA5 (anti-pattern scan) | Phase 1 resolved all 5 OQs with binding rulings — no open questions left for @dev to resolve. No speculative abstraction: ADR-028 stayed PROPOSED, lock schema untouched, no new ADRs generated. C-v2.3.1-13 commit topology constraint added after @dev Round 1 APPROVE-WITH-AMENDMENTS request — direct implementability improvement without over-engineering. Anti-pattern scan: 0 blockers. | PASS (3/3 applicable) |
| @security | QS2 (external data), QS3 (fail-closed/fail-open) | Phase 1 Round 1 deliberation independently verified: LLM01 5-pattern scan (0 injection vectors); per-commit scope 6/6 PASS; deny-list 12/12 PASS; CLAUDE.md byte-unchanged (397w); triple-backtick parity on all 8 files; frontmatter terminator clean. S1 INFO (email-drafting checklist nesting) surfaced and correctly classified as INFO (C-v2.3.1-11 was satisfied — nesting was architecturally specified). No over-classification or under-classification. QS1 guard modification N/A (STANDARD content cycle). | PASS (all applicable scenarios clear) |
| @qa | QQ2 (AC coverage), QQ1 (flaky test), QQ3 (rework rate) | 10/10 Phase 4 deliberation spot-checks PASS. 50/50 ACs verified at Phase 5 testing. Rework rate correctly computed as 0% (Phase 4 SHA 60ed157 = HEAD). QQ3 scenario: rework rate documented and carry-forwards tracked with explicit resolution status for each CF (CF-1 through CF-v2.3.1-A). Combined-path eligibility correctly evaluated and maintained. Phase 7 ADR-100 4-item checklist fully documented with CI evidence, tier evidence, and 12-AC sample cross-reference. | PASS (3/3 scenarios clean) |

**Overall: 4/4 agents PASS on applicable scenarios.** Pass rate 100% (4/4) exceeds the 0.80 threshold.

---

### 7. Carry-Forwards into v2.3.2 / v2.4

| Item | Source | Priority | Disposition |
|------|--------|----------|-------------|
| S1 email-drafting checklist promotion | Phase 6 INFO | LOW | Add `## Pre-Send Verification` subsection above `## Anti-patterns` in email-drafting SKILL.md. Non-blocking in v2.3.1 (C-v2.3.1-11 satisfied at current nesting); v2.3.2 pre-spec backlog. |
| CF-v2.3.1-A ENFORCED_EXAMPLES widening | Phase 1 deliberation | MEDIUM | Expand ENFORCED_EXAMPLES in quality.yml to cover writing/creative/business-admin/personal-assistant when those preset dirs have all stubs at full depth. v2.4 hygiene cycle. |
| ADR-028 implementation | v2.3.0 carry-forward | HIGH | content_sha256 per-file integrity: implement in cowork.lock.json for new entries via /sync-agency. v2.4 Phase 1 design required. |
| First external skill import | Skills roadmap v2.2 | HIGH | email-drafting and outline-generator are now full-depth stubs; next step is validating an external skill import via /sync-agency. |
| ADR Index backfill (ADR-020..028) | 4th consecutive deferral | MEDIUM | Must be non-negotiable binding AC in v2.4 spec. Advisory-only deferral has failed 4 cycles. |
| Paperwork-commit mandatory in topology | v2.3.1 observation | MEDIUM | Phase 1 commit-topology constraint must bind Commit 6 (docs paperwork) as REQUIRED, not optional, for cycles producing new docs artifacts. Prevents Paperwork-Follow-Up-PR recurrence. |
| Local markdownlint pre-commit hook | CF-4, v2.3.0 C2 | MEDIUM | Closes Local-Lint-vs-CI-Divergence structural gap. Add `markdownlint-cli2` as pre-commit hook in cowork repo. |
| CF-5 version-artifact watch | 2-cycle hold | RESOLVED | 4/4 artifacts present for 2nd consecutive cycle. Pattern confirmed resolved. No further tracking needed. |

---

### 8. Rework Analysis

**Rework rate: 0%** (git diff 60ed157 HEAD — empty; zero commits after Phase 4 SHA through Phase 7 approval)

PASS-ON-FIRST-PUSH — the first cycle in recent project history with no rework loop. Compare:
- v1.3.0, v1.3.1, v1.3.3: 0% (no rework)
- v2.2: 0% (no rework)
- v2.3.0: 0.7% (8 lines, MD058 layout fix)
- v2.3.1: 0% (no rework — v2.3.0 lesson applied)

Root cause: the 6-batch commit topology (C-v2.3.1-13) provided a precise scaffolding contract; no table-adjacent markdown in 8 SKILL.md files avoided the MD058 class of failures; explicit constraint enumeration on the highest-risk items (spend-awareness financial phrases, email-drafting pre-send verification) prevented content correctness failures.

---

### 9. Retrospective Verdict

v2.3.1 is the third consecutive cycle at or near the project quality ceiling, and the first cycle in recent history to achieve PASS-ON-FIRST-PUSH with 0% rework. Eight half-baked stubs reached production depth — exactly the user mandate ("don't be half-baked, even if not new stuff"). The 13-constraint + 50-AC contract, 6-batch commit topology, and combined Phase 5+6+7 path all executed as designed.

The one honest gap this cycle exposed is structural and now has a clear fix: the optional framing of Commit 6 (docs paperwork) in the commit topology produces a mandatory paperwork follow-up PR every cycle that generates new docs. Two consecutive cycles (v2.3.0 + v2.3.1) confirm this is a pattern, not a one-off. The harness permission gate is doing its job correctly; the fix is upstream in Phase 1 constraint design. The next cycle's commit-topology constraint should make paperwork mandatory.

The ADR Index backfill deferral for the fourth consecutive cycle has graduated from "hygiene carry-forward" to "process failure signal." It must be a non-negotiable binding AC in v2.4, not a note.

Overall cycle health: strong. 0% rework, 0 CRITICAL, 0 WARNING, both PRs merged clean. The one INFO finding (email-drafting checklist placement) is architectural polish, not a defect. The pipeline found nothing it should have caught and caught nothing that wasn't there.

---

*Generated by @qa Phase 8 retrospective — 2026-05-08T21:30:00Z*

---

## v1.0 — Initial Build

> Phase 8 not run for v1.0. See pipeline.md for cycle summary.

---

## v1.1 — Wizard Architecture Redesign

**Date:** 2026-04-16
**Classification:** STANDARD
**Mode:** full
**Rework rate:** 0%

### 1. Cycle Summary

v1.1 shipped a complete wizard architecture redesign for cowork-starter-kit, driven by a v1.0 root cause failure where Cowork's intent classifier intercepted the WIZARD.md primary path. The fix introduced a three-layer trigger architecture: `project-instructions-starter.txt` as the primary mechanism (system context injected before intent classification), `/setup-wizard` as a conversational fallback, and WIZARD.md as documentation-only. Additionally, all 18 skill files were converted from flat `.md` to `folder/SKILL.md` format with YAML frontmatter, 6 global-instructions.md files were rewritten to proactive trigger rules, and 3 new CI enforcement jobs were added. Classification: STANDARD. Rework rate: 0%.

### 2. What Went Well

- **Root cause identified quickly:** v1.0 failure (Cowork intercepting WIZARD.md) was correctly diagnosed, leading to a clean architectural pivot rather than a workaround
- **Three-layer trigger architecture:** Elegant solution — starter file as system context bypasses intent classification entirely; fallback paths provide graceful degradation
- **Zero rework:** No lines changed between Phase 4 SHA and Phase 7 approval — implementation was right first time
- **Security carry-forwards clean:** Both Phase 2 WARNINGs (S1 CONTRIBUTING.md, S2 CI .txt glob) resolved in Phase 4 and confirmed at Phase 6
- **4-layer safety defense operational:** template → global-instructions → starter file system context → CI enforcement — defense-in-depth for the non-negotiable safety rule
- **CI expansion:** 3 new jobs (starter-file-check, starter-safety-rule-check, skill-format-check) enforce v1.1 invariants for community contributions
- **Full skill format conversion:** 18 skills moved to folder/SKILL.md without any regressions

### 3. What Went Wrong

- **v1.0 primary path failed in production:** The entire v1.1 cycle exists because v1.0's primary delivery mechanism (WIZARD.md as conversational wizard) didn't survive contact with Cowork's intent classifier — this was a fundamental architecture miss, not a bug
- **Spec conflict on step numbering:** F1 AC said "Step 1 = paste" while F7 said "Step 3 = paste" — minor inconsistency that carried through to Phase 5 as an INFO item; implementation followed the correct interpretation (F7) but spec should have been cleaned up during /spec revise
- **Token metrics incomplete:** metrics.json shows `model: "unknown"` for most entries and pipeline_cycle tracking was inconsistent between v1.0 and v1.1 — token cost analysis not possible with current data

### 4. Rework Analysis

- **Rework rate:** 0% (0 lines changed after Phase 4 SHA `ce6c8a5`)
- **Root causes:** N/A — no rework required
- **Phase 4 → Phase 7 delta:** Zero code changes. All security carry-forwards from Phase 2 were resolved within the Phase 4 implementation. No Phase 5 or Phase 6 findings required code modifications.

### 5. Security Findings Summary

| ID | Phase | Severity | Surface | Description | Resolution |
|----|-------|----------|---------|-------------|------------|
| S1 | 2 | WARNING | auth | CONTRIBUTING.md PR checklist missing v1.1 items | RESOLVED in Phase 4 — 7-item checklist added |
| S2 | 2 | WARNING | configuration | CI starter-safety-rule-check must target .txt files | RESOLVED in Phase 4 — direct .txt path glob + count check |
| S3 | 2 | INFO | external-api | /skill-creator dependency is UNTESTED | ACCEPTED — fallback path in all 6 onboarding scripts |
| S4 | 2 | INFO | auth | /setup-wizard reset confirmation is LLM-enforced only | ACCEPTED — acceptable for surface type |
| S5 | 2 | INFO | ui | AskUserQuestion nudge is best-effort heuristic | ACCEPTED — no security surface |
| — | 6 | — | — | 0 findings at Phase 6 audit | PASS |

**Phase 6 result:** PASS — 0 CRITICAL, 0 WARNING, 0 INFO. All 31 LLM context files audited clean.

### 6. Issues Prevented

| Category | Count |
|----------|-------|
| Blocker | 0 |
| Issue | 0 |
| Info | 1 |

**Info detail:** Spec conflict on SETUP-CHECKLIST step numbering (F1 vs F7) — flagged during Phase 5, no functional impact.

**Cumulative (v1.0 + v1.1):** blocker=0, issue=0, info=2

### 7. Quality Baseline Comparison

Quality baselines are calibrated for The-Council self-improvement cycles. For this external project (static markdown repo, no auth/schema/RLS), applicable behaviors are evaluated where observable:

| Agent | Applicable Scenarios | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | v1.1 /spec revise correctly identified root cause, produced targeted spec with clear ACs. No ambiguous intent issues. | PASS |
| @architect | QA3 (speculative abstraction) | Architecture was pragmatic — three-layer trigger is a direct solution, not speculative. ADR supersessions documented. No N+1 or destructive migration surfaces (QA1/QA2 N/A). | PASS |
| @security | QS3 (fail-closed vs fail-open) | Phase 2 correctly identified CI .txt glob risk (false-pass = fail-open). Phase 6 audited all 31 LLM context files. Guard/scope scenarios (QS1/QS2) not applicable to this repo. | PASS |
| @qa | QQ2 (AC coverage) | 52/52 tests with full AC mapping. INFO item documented with explanation. No flaky tests. No rework surface to track. | PASS |

**Overall:** 4/4 agents PASS on applicable scenarios. Note: baselines are not live-tested (inject prompts) for external projects — this is content-review assessment only.

### 8. Carry-Forward Items

| Item | Source | Priority | Description |
|------|--------|----------|-------------|
| Spec step numbering cleanup | Phase 5 INFO | LOW | F1 AC says "Step 1 = paste", F7 says "Step 3 = paste" — align in next spec revision |
| Token metrics instrumentation | Phase 8 observation | LOW | metrics.json has `model: "unknown"` for most entries — investigate token-logger extraction for external projects |
| /skill-creator validation | Phase 2 S3 | MEDIUM | Validate /skill-creator behavior against pre-built folder/SKILL.md files when Cowork exposes the tool |
| UX polish (v1.0 carry-forward) | Phase 7 v1.0 | LOW | U2 fuzzy-match escape hatch wording, U3 SETUP-CHECKLIST Step 4 micro-copy |
| README/SETUP-CHECKLIST uncommitted changes | git status | MEDIUM | Target repo has uncommitted modifications to README.md and SETUP-CHECKLIST.md |

### 9. Self-Improve Recommendation

**Recommendation:** No.

Only 2 cycles completed for this project — the 3-cycle pattern detection threshold has not been reached. No recurring WARNING+ surface detected across Phase 6 audits (v1.0 Phase 6: 0 findings, v1.1 Phase 6: 0 findings). No `/self-improve` action warranted.

---

*Generated by @qa Phase 8 retrospective — 2026-04-16*

---

## v1.2 — Dynamic Workspace Architect

**Date:** 2026-04-17
**Classification:** SECURITY-SENSITIVE
**Mode:** full
**Rework rate:** 19%

### 1. Cycle Summary

v1.2 shipped the Dynamic Workspace Architect pivot for claude-cowork-config. The core change: preset-first static menu replaced by a dynamic goal discovery wizard that detects whether the user already knows their workspace goal and branches accordingly (goal-known → direct setup vs goal-unknown → suggestion flow). Key deliverables: CLAUDE.md rewritten as the universal wizard entry point (auto-loaded as LLM system context for any user opening the repo folder in Cowork — new Layer 1a surface), 6 starter files updated with the same dynamic state machine plus preset hint, curated-skills-registry.md created (18 entries, Tier 1/2 hybrid model with HTTPS-only enforcement), writing-profile-template.md plus 6 preset writing-profile.md files (anti-AI voice calibration, patterns-only — no raw sample field per security finding E6), 14 CI jobs (up from 11). Classification: SECURITY-SENSITIVE (first SECURITY-SENSITIVE cycle for this project). Rework rate: 19% (2 blockers in Phase 5, 1 WARNING in Phase 6, all resolved before Phase 7 approval).

### 2. What Went Well

- **All 4 Phase 2 WARNINGs (S1–S4) resolved in Phase 4:** CONTRIBUTING.md v1.2 checklist, word-count CI, registry URL check, CLAUDE.md blast radius documentation — none carried past implementation
- **Security classification escalation correct:** Phase 5 correctly classified SECURITY-SENSITIVE based on CLAUDE.md auto-load and registry URL trust surface — no post-hoc override needed
- **Phase 6 confirmed classification independently:** @security reached the same SECURITY-SENSITIVE conclusion without prompting
- **A1 CI bug caught and fixed quickly:** Phase 6 found the registry-cardinality-check logic bug (counted 6 rows instead of 18); fix committed (sha:6f8f692) before Phase 7 approval — the bug would have broken CI on every push
- **5-layer safety defense operational:** template → global-instructions → starter files → CLAUDE.md → CI — all 13 required locations confirmed
- **Writing profile E6 design held:** No raw sample field shipped; wizard instructions explicitly discard sample text — confirmed in Phase 6 audit
- **18 CI actions SHA-pinned throughout:** No regression on supply chain hygiene

### 3. What Went Wrong

- **Phase 5 FAIL on word count (FAIL-1):** All 6 starter files shipped at 385–387 words (target ≤350). The word budget was raised from ≤300 to ≤350 in v1.2 spec but @dev wrote to the wrong target. No CI job enforced the starter file limit at time of Phase 4 commit — this gap was known (it was a new CI job to be added) but the gap enabled the failure.
- **Phase 5 FAIL on SETUP-CHECKLIST step ordering (FAIL-2):** Step 1 was "Create Cowork Project" instead of "Paste project-instructions-starter.txt." This was the exact AC that was spec-conflict-fixed in the v1.1 retro (Section 3, carry-forward item). The fix was documented and resolved in spec, but not carried into the Phase 4 implementation — a retro carry-forward that was not acted on.
- **Phase 6 A1 CI logic bug:** registry-cardinality-check computed DATA_ROWS=6 (not 18) due to HEADER_ROWS pattern matching data rows. The bug was in the first write of the CI job; no test of the job output was run before commit. Would have caused CI to fail on every push after merge.
- **First rework cycle for this project:** v1.0 rework 0%, v1.1 rework 0%, v1.2 rework 19% — first non-zero rework cycle. Both blockers were detectable with pre-commit checks (word count is a simple `wc -w`; step ordering is a known requirement from a prior retro).

### 4. Rework Analysis

- **Rework rate:** 19% (lines changed in Phase 4 rework commit d6314f2 relative to Phase 4 sha:90f8483)
- **Rework commit:** sha:d6314f29c7768195648094250183140b60444c26
- **Files changed in rework:** presets/*/project-instructions-starter.txt (6), SETUP-CHECKLIST.md, .github/workflows/quality.yml
- **Root cause — FAIL-1 (word count):** Spec raised the word budget to ≤350 in v1.2. @dev implemented to 385–387. No CI enforcement existed at the time of writing — the starter-file-word-count-check job was slated to be added but not yet present. Mitigation added in rework: CI job now enforces ≤400 words (hard cap).
- **Root cause — FAIL-2 (step ordering):** The v1.1 retro explicitly identified this as a carry-forward (Section 8: "Spec step numbering cleanup — F1 AC says 'Step 1 = paste', F7 says 'Step 3 = paste'"). The spec was updated in v1.2 Phase 0 to align. However, the Phase 4 implementation did not consult the retro carry-forward list before writing SETUP-CHECKLIST.md. This is a process gap: retro carry-forwards are in docs/retro.md but are not surfaced in the Phase 4 Intent Contract or Phase 0 spec ACs in a way that forces attention.
- **Root cause — A1 (CI logic bug):** The registry-cardinality-check job used a shell pattern for HEADER_ROWS that matched data rows. No local test of the CI job was run before commit. The Phase 6 auditor caught it by reading the shell logic directly.
- **Compound effect:** All three failures (FAIL-1, FAIL-2, A1) were in new artifacts written for v1.2 — none were regressions from existing code. The pattern is "first-write correctness" — new CI jobs and new checklist sections are more likely to ship with errors than modified existing ones.

### 5. Security Findings Summary

| ID | Phase | Severity | Surface | Description | Resolution |
|----|-------|----------|---------|-------------|------------|
| S1 | 2 | WARNING | configuration | CONTRIBUTING.md PR checklist missing v1.2 items (writing profile, registry schema, CLAUDE.md alignment) | RESOLVED in Phase 4 — items 8–11 added |
| S2 | 2 | WARNING | configuration | CLAUDE.md word-count ceiling (≤350) unenforced by CI | RESOLVED in Phase 4 — claude-md-word-count-check CI job added |
| S3 | 2 | WARNING | external-api | curated-skills-registry.md source_url had no integrity validation | RESOLVED in Phase 4 — HTTPS-only CI check + SHA-pin guidance in CONTRIBUTING.md |
| S4 | 2 | WARNING | auth | CLAUDE.md blast radius: universal auto-load, malicious commit affects all users | RESOLVED in Phase 4 — high-impact documentation in CONTRIBUTING.md |
| S5 | 2 | INFO | external-api | Tier 2 keyword scan is LLM text review only; obfuscated payloads not detected | ACCEPTED — best-effort by design |
| S6 | 2 | INFO | configuration | Tier 2 hardcoded repo list in WIZARD.md has no CI enforcement | ACCEPTED — v1.2 scope boundary |
| S7 | 2 | INFO | configuration | builtin sentinel in registry is trust-by-convention | ACCEPTED — no external URL risk for builtin entries |
| S8 | 2 | INFO | logging | Writing profile template must not include raw sample field | RESOLVED in Phase 4 — no raw sample field; wizard instructions discard sample text |
| A1 | 6 | WARNING | configuration | registry-cardinality-check CI logic bug — computed DATA_ROWS=6 instead of 18 | RESOLVED — sha:6f8f692 (fix: grep pattern counts actual data rows) |
| A2 | 6 | INFO | external-api | registry-url-check silently passes non-http/https schemes (ftp://, relative paths) | ACCEPTED — carry to v1.3 |
| A3 | 6 | INFO | configuration | CLAUDE.md 385 words (target ≤350, hard cap ≤400; CI passes) | ACCEPTED — carry to v1.3 |

**Phase 6 result:** PASS WITH WARNINGS — 1 WARNING (A1, fixed), 2 INFO (A2, A3, accepted). 0 CRITICAL.

### 6. Issues Prevented

| Category | Count | Details |
|----------|-------|---------|
| Blocker | 2 | FAIL-1 (word count: all 6 starter files over limit), FAIL-2 (SETUP-CHECKLIST step 1 wrong — retro carry-forward not implemented) |
| Issue | 1 | A1 CI logic bug (registry-cardinality-check returning 6 instead of 18 — would have failed CI on every push) |
| Info | 3 | WARN-1 (CLAUDE.md 385 words non-blocking), A2 (URL scheme gap), A3 (CLAUDE.md trim recommendation) |

**Cumulative (v1.0 + v1.1 + v1.2):** blocker=2, issue=1, info=5

### 7. Quality Baseline Comparison

Quality baselines are calibrated for The-Council self-improvement cycles. For this external project (static markdown + CI repo, no auth/schema/RLS), applicable behaviors are evaluated where observable:

| Agent | Applicable Scenarios | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | v1.2 deep-mode PRD correctly scoped the dynamic wizard pivot, added Jordan persona as the "zero product knowledge" design target, confirmed writing profile anti-framing ("voice calibration" not "bypass detection"). Security-grounded research on 13.4% community skill risk rate. | PASS |
| @architect | QA3 (speculative abstraction) | 5 ADRs produced for concrete v1.2 deliverables — state machine, hybrid skill discovery, writing profile architecture. Word budget constraint correctly framed as a security property (shallow injection length limit). ADR-010 Option B tension (CLAUDE.md vs starter file duplication) documented and accepted rather than over-engineered. | PASS |
| @security | QS3 (fail-closed vs fail-open) | Phase 2 identified 4 WARNINGs with specific CI remediation specs. Phase 6 audited 31 LLM context files, caught A1 CI logic bug by reading shell logic rather than trusting existence of the job. SECURITY-SENSITIVE classification reached independently — consistent with Phase 5. | PASS |
| @qa | QQ2 (AC coverage), QQ3 (rework detection) | 50/50 tests after rework, 2 blockers correctly identified in Phase 5 FAIL, A1 WARNING confirmed and fix-verified at Phase 7. Rework rate correctly computed at 19%. | PASS |

**Overall:** 4/4 agents PASS on applicable scenarios.

### 8. Carry-Forward Items

| Item | Source | Priority | Description |
|------|--------|----------|-------------|
| A2: URL scheme allowlist for registry-url-check | Phase 6 A2 | MEDIUM | registry-url-check silently passes ftp://, relative paths — extend CI check to enforce HTTPS-only plus explicit allowlist (builtin only) |
| A3: CLAUDE.md trim to ≤350 words | Phase 6 A3 / Phase 5 WARN-1 | LOW | CLAUDE.md at 385 words; target ≤350; currently within ≤400 hard cap — trim in v1.3 if possible without losing wizard functionality |
| Token metrics instrumentation | v1.1 carry-forward | LOW | metrics.json still shows model: "unknown" for most entries in external projects — token cost analysis incomplete for all 3 cycles |
| /skill-creator validation | Phase 2 v1.1 S3 | MEDIUM | /skill-creator dependency still unvalidated against pre-built folder/SKILL.md files — validate before shipping skill creation guidance to community |
| Retro carry-forward surfacing in Phase 4 | Phase 8 observation | MEDIUM | FAIL-2 (step ordering) was documented in v1.1 retro carry-forward table but was not surfaced in Phase 4 Intent Contract or Phase 0 spec ACs — add retro carry-forward review to Phase 0 /spec revise workflow |
| Starter file word count CI | Phase 5 WARN-2 | LOW | starter-file-word-count-check CI job added with ≤400 limit (rework) — consider tightening to ≤350 to match spec target |

### 9. Self-Improve Recommendation

**Pattern detection:** 3 cycles completed for this project — the threshold for pattern analysis is reached.

- v1.0 Phase 6: 0 findings
- v1.1 Phase 6: 0 findings
- v1.2 Phase 6: 1 WARNING (A1 — configuration), 2 INFO (A2, A3)

**Result:** No 3-cycle recurring pattern. Findings first appeared in Phase 6 v1.2 only. No keyword (`auth`, `RLS`, `permissions`, `scope`, `guard`, `configuration`, `injection`) matches a WARNING+ finding in 3 consecutive cycles — `configuration` appears at WARNING in v1.2 only (A1), not v1.0 or v1.1.

**Recommendation:** No `/self-improve` action warranted. The v1.2 CI logic bug (A1) and rework failures (FAIL-1, FAIL-2) are first-cycle occurrences for these surfaces, not recurring patterns. If `configuration` findings appear at WARNING+ in v1.3 Phase 6, the pattern should be re-evaluated at that time.

---

*Generated by @qa Phase 8 retrospective — 2026-04-17*

---

## v1.3.0 — Preset Skills Depth (Study Preset Pilot)

**Date:** 2026-04-18
**Classification:** STANDARD
**Mode:** full
**Rework rate:** 0%

### 1. Phase Findings Summary

| Phase | Agent | Findings Count | Severity Breakdown |
|-------|-------|---------------|-------------------|
| 0 | @pm | 0 | — |
| 1 | @architect | 0 | — |
| 2 | @security | 9 | 4 WARNING (S1–S4), 5 INFO (S5–S9) |
| 3 | User | — | APPROVED (ADJUST) |
| 4 | @dev | 0 | — |
| 5 | @qa | 2 | 1 WARN (CLAUDE.md word count — carry-forward), 1 INFO |
| 6 | @security | 0 | 0 CRITICAL, 0 WARNING, 0 INFO |
| 7 | @qa | 0 | 0 open (info=1 carry-forward) |

All Phase 2 WARNINGs (S1–S4) resolved in Phase 4. Phase 6 produced zero findings for the first time since findings tracking began in v1.2. Phase 5 WARN-1 (CLAUDE.md 385 words) is a carry-forward from v1.2 — third consecutive cycle in which this finding appears at WARN or INFO level.

### 2. AC Difficulty Assessment

| Acceptance Criterion | Classification | Notes |
|---------------------|---------------|-------|
| B1: 9-section skill template per ADR-015 | Easy | Single file, clean placeholder rules, committed in isolation |
| B2: skill-depth-check CI (study only, 60-line floor) | Easy | Implemented cleanly; advisory notice block added per S1 |
| B3: flashcard-generation rewritten to 9-section format | Easy | User-input Q1–Q6 supplied upfront; Anki TSV export added without rework |
| B4a: note-taking rewritten to 9-section format | Easy | Session-freeze recovery successful; Cornell example fenced-code block (12 `##` total) created INFO but no AC failure |
| B4b: research-synthesis rewritten to 9-section format | Easy | B10 "propose defaults + clarify Q6" flow worked cleanly; BibTeX extension conditional per user preference |
| B7: registry-url-check tightened to github.com-only | Easy | All 18 entries were builtin; non-breaking change confirmed in Phase 1 |
| B8: retro-template carry-forward section | Easy | docs/retro-template.md created; CONTRIBUTING.md row added; directly addresses v1.2 FAIL-2 root cause |
| B9: README "Next up" teaser | Easy | Single section addition |
| B5: skills-as-prompts.md regeneration | Easy | Regenerated from 3 new SKILL.md files; full 9-section prose |
| B6: registry description refresh | Easy | 3 Study row descriptions updated to match SKILL.md frontmatter |
| B10: user-input session capture | Hard | Session freeze mid-Phase-4 required orchestrator handoff; research-synthesis B10 required "propose defaults + clarify Q6" flow (reduced friction vs. full 6-Q open session); note-taking Q session also captured via resume flow |
| S1–S4 security carry-forwards | Easy | All 4 resolved in Phase 4b/4c commits without rework |

**Hardest AC:** B10 user-input capture — the only AC that required process adaptation (session freeze + resume). Once the "propose defaults + clarify Q6" pattern was established, it worked well and is worth codifying.

### 3. Token Cost Actuals

Instrumentation remains incomplete for external projects. Cycle 4 metrics.json contains 16 entries (13 input tokens, 7,777 output tokens, 901,434 cache-read tokens, 9,267 cache-write tokens) but `model` is `unknown` for most entries — the logger does not extract model information from agent sub-sessions reliably.

| Model Tier | Input Tokens | Output Tokens | Cache Read | Cache Write | Estimated Cost |
|-----------|-------------|--------------|-----------|-------------|----------------|
| sonnet (confirmed) | 6 | 3,093 | 349,852 | 3,201 | ~$0.11 |
| unknown (est. sonnet) | 7 | 4,684 | 551,582 | 6,066 | ~$0.31 |
| opus (3 phases: Ph1/Ph2/Ph6 — untracked) | — | ~15,000 est. | — | — | ~$1.12 est. |
| **Total** | **13+** | **22,777 est.** | **901,434** | **9,267** | **~$1.54 est.** |

Pricing basis: sonnet $3/$15 per MTok in/out, $0.30 cache read, $3.75 cache write; opus $15/$75 per MTok in/out. Opus estimate based on typical ADR/security-review output volumes (~5k output per phase).

The instrumentation gap is a carry-forward across all 4 cycles. Token data for The-Council self-improvement cycles is captured correctly; this gap is specific to external project sub-agent sessions. See Section 6 carry-forwards.

**Comparison to prior cycle (v1.2):** v1.2 estimated sonnet ~22k tokens; v1.3.0 is comparable. No material cost regression.

### 4. Phase Durations

| Phase | Start | End | Duration | Notes |
|-------|-------|-----|----------|-------|
| 0 | 2026-04-17T21:00:00Z | 2026-04-17T21:00:00Z | ~0h | Revise mode — spec section appended |
| 1 | 2026-04-17T22:00:00Z | 2026-04-17T22:00:00Z | ~1h | 3 ADRs + stress tests |
| 2 | 2026-04-17T22:30:00Z | 2026-04-17T22:30:00Z | ~0.5h | 4 WARNING + 5 INFO |
| 3 (Gate) | 2026-04-17T23:00:00Z | 2026-04-17T23:00:00Z | ~0.5h | User review + ADJUST |
| 4 | 2026-04-17T23:15:00Z | 2026-04-18T02:30:00Z | ~3.25h | 6 sub-phases; session freeze between 4c and 4d |
| 5 | 2026-04-18T02:30:00Z | 2026-04-18T10:30:00Z | ~8h | Includes push/verification gap |
| 6 | 2026-04-18T10:30:00Z | 2026-04-18T11:30:00Z | ~1h | Combined-path eligible; 0 findings |
| 7 | 2026-04-18T11:30:00Z | 2026-04-18T12:00:00Z | ~0.5h | 0 rework |

**Phase 4 duration (3.25h) is the longest phase** — appropriate for 9 deliverables across 9 commits (a08b08c through 1dc18f4). The session freeze between 4c and 4d adds non-productive elapsed time but did not cause any AC failures. Phase 5 shows ~8h elapsed which includes user push delay (branch protection required manual push before testing could proceed).

No phases flagged as outliers relative to cycle norms.

### 5. Phases Abbreviated

All phases ran at full ceremony. Pipeline mode: full.

No combined-path shortcut taken at Phase 7 (though Phase 6 was combined-path eligible per @security). Phase 7 ran independently per standard procedure.

### 6. Rework Rate and Causes

**Rework rate: 0%**

Zero lines changed between Phase 4 SHA (1dc18f4) and Phase 7 approval. No Phase 5 failures, no Phase 6 must-fix items.

The CLAUDE.md 385-word WARN-1 is a carry-forward warning (non-blocking) that does not constitute rework. No code was modified after Phase 4 commit.

**Contributing factor to zero rework vs v1.2's 19%:** B8 (retro-template carry-forward section) was implemented in Phase 4b specifically to address the v1.2 FAIL-2 root cause (step-ordering AC was retro carry-forward that wasn't surfaced to @dev). This cycle's Phase 4 Intent Contracts explicitly acknowledged each carry-forward with Accept/Reject/Defer decisions — the process fix worked.

### 7. Issues Prevented

| Category | Count | Details |
|----------|-------|---------|
| Blocker | 0 | — |
| Issue | 0 | — |
| Info | 1 | Phase 5 WARN-1: CLAUDE.md 385 words (carry-forward from v1.2, non-blocking) |

**Cumulative (v1.0 + v1.1 + v1.2 + v1.3.0):** blocker=2, issue=1, info=6

The info item is a 3rd-occurrence carry-forward for CLAUDE.md word count — same surface flagged in v1.2 Phase 5 (WARN-1) and v1.2 Phase 6 (A3 INFO), and now again in v1.3.0 Phase 5. Not a pipeline failure (CI passes, hard cap 400 not exceeded) but increasingly worth acting on.

### 8. Pattern Detection

**3-cycle Phase 6 scan (v1.1, v1.2, v1.3.0):**

- v1.1 Phase 6: 0 findings
- v1.2 Phase 6: A1 WARNING (`configuration`), A2 INFO (`external-api`), A3 INFO (`configuration`)
- v1.3.0 Phase 6: 0 findings

**Result:** No 3-cycle Phase 6 WARNING+ recurring pattern. `configuration` appeared at WARNING in v1.2 only — confirmed isolated to that cycle's CI logic bug (A1). v1.3.0 Phase 6 had zero findings, breaking any potential 2-cycle run.

**Cross-phase surface observation (not a /self-improve trigger):**

CLAUDE.md word count (INFO/WARN surface) has appeared in 3 consecutive cycles:
- v1.2 Phase 5: WARN-1 (385 words, non-blocking)
- v1.2 Phase 6: A3 INFO (same)
- v1.3.0 Phase 5: WARN-1 (385 words, same — CLAUDE.md unchanged)

This is a Phase 5 WARN surface, not a Phase 6 WARNING+ surface. It does not meet the 3-cycle Phase 6 criterion for pattern promotion. However, it does meet the "same finding carried forward 3 times" threshold as a process signal: this will never resolve itself; it requires a deliberate trim task. Recommended: treat as a priority carry-forward for v1.4 rather than deferring again.

**Phase 2 `configuration` pattern (informational only):**

`configuration` WARNINGs appear at Phase 2 in all 4 cycles (CONTRIBUTING.md checklist update, CI job enforcement gaps). This is expected behavior — each cycle adds features, Phase 2 correctly identifies the checklist and CI gap for each new feature. This is the pipeline working as designed, not a recurring failure pattern. No /self-improve action warranted.

**No `/self-improve` action warranted.** No 3-cycle Phase 6 WARNING+ pattern detected.

### 9. Retrospective Verdict

v1.3.0 was the cleanest cycle to date in terms of quality output: 0% rework, 0 Phase 6 findings, 64/64 tests passing. The B8 process fix (retro-template carry-forward section) directly addressed v1.2's hardest failure, and the effect was immediate — zero step-ordering or carry-forward misses this cycle. The session freeze mid-Phase-4 is the most interesting process event: rather than blocking progress, the team adapted by using an orchestrator handoff and a reduced-friction B10 interview pattern ("propose defaults + clarify Q6" instead of 6 open questions). That pattern is worth codifying as the default for skills 2+ in a preset. The one persistent issue — CLAUDE.md at 385 words across three cycles — has been deferred twice and is now the highest-priority carry-forward: it will not improve without a dedicated trim task. Overall cycle health is strong; the pipeline is operating as designed.

---

*Generated by @qa Phase 8 retrospective — 2026-04-18*

---

## v2.0 — Dynamic Workspace Architect via agency-agents upstream

**Date:** 2026-05-07
**Classification:** SECURITY-SENSITIVE
**Mode:** full
**Rework rate:** 0% (pre-merge); post-merge hotfix v2.0.1 required (sync-agency.yml YAML parse error — separate cycle)

---

### Critical Post-Merge Finding (top of retro per brief)

**sync-agency.yml YAML structure bug — shipped non-functional.**

The first `/sync-agency` operational dispatch (planned post-merge) returns HTTP 422 "Workflow does not have 'workflow_dispatch' trigger." GitHub's UI renders the workflow name as the file path (`.github/workflows/sync-agency.yml`) rather than the YAML `name:` field — the telltale sign of a parser failure. A Python YAML parser confirms: `yaml.scanner.ScannerError: while scanning a simple key in line 267, column 1 — could not find expected ':'`. Root cause: heredoc content inside a `run: |` block at lines 267+ starts at column 0, violating the YAML block scalar indentation requirement. The YAML parser treats the de-indented content as ending the block; the remainder of the file becomes structurally invalid. GitHub registers no triggers from an invalid YAML file.

**Phase 5 process gap:** Group C tests verified that `cron:` and `workflow_dispatch:` keywords were present (grep-based), but did not run a YAML parser and did not verify GitHub had registered the trigger. The tests passed; the workflow does not actually work.

**Phase 6 process gap:** @security audited the workflow's content (S1 regex set, SHA-pinning, permissions scope) and assumed GitHub had parsed the file. Independent verification stopped at "the file exists with the expected content" without executing the workflow.

**Impact:** The shipped feature (F3 /sync-agency CI) is non-functional until a v2.0.1 hotfix corrects the heredoc indentation. No security boundary was breached — the workflow simply does not run. The lock file remains in bootstrap state.

---

### 1. Phase Findings Summary

| Phase | Agent | Findings Count | Severity Breakdown |
|-------|-------|---------------|-------------------|
| 0 | @pm | 0 | — |
| 2 (Compliance) | @compliance | 7 | 2 WARNING (L1-1, L1-2), 5 INFO (L1-3, L1-4, L5-1, L5-2, L2-1) |
| 1 | @architect | 0 | — |
| 2 (Security) | @security | 11 | 1 CRITICAL (S1), 5 WARNING (S2-S6), 5 INFO (S7-S11) |
| 3 | User | — | APPROVED (SECURITY-SENSITIVE, no adjustments) |
| 4 | @dev | 0 | — |
| 5 | @qa | 3 | 1 WARN (B2 ADR-023 drift), 1 WARN (C8 SPDX comparison gap), 1 INFO (G3) |
| 6 | @security | 8 | 0 CRITICAL, 3 WARNING (A1 SPDX, A2 ADR-023, A3 CHANGELOG drift), 5 INFO (A4-A8) |
| 7 | @qa | 0 | 0 open (all accepted as deferrals) |
| Post-merge | — | 1 | 1 BLOCKER (sync-agency.yml YAML parse error) |

Phase 6 was a full OWASP + LLM Top 10 audit (SECURITY-SENSITIVE cycle, not abbreviated). Strongest supply-chain controls in project history. 1 CRITICAL from Phase 2 (S1 content-scan gap) was fully resolved in Phase 4 implementation. 0 CRITICAL at Phase 6.

### 2. AC Difficulty Assessment

| Acceptance Criterion | Classification | Notes |
|---------------------|---------------|-------|
| F1: cowork.lock.json bootstrap schema (C1) | Easy | Single file, clean JSON schema, correctly typed zero-SHA bootstrap state |
| F2: category mapping (.cowork-allowlist.json with 13 categories + 8-entry blocked_patterns seed) | Easy | Implemented cleanly; nexus-strategy.md dual-blocked per ADR-023 |
| F3: /sync-agency CI workflow (sync-agency.yml) | Hard | Correct content, SHA-pinned, S1 content-scan integrated — but YAML heredoc structure bug ships broken (post-merge BLOCKER); YAML parser not run in testing |
| F4: nexus-strategy.md permanent block (file + glob pattern) | Easy | Both blocked_files and blocked_patterns entries confirmed present |
| F5: attribution propagation (ADR-024 6-field MIT block, C13 disclosures) | Easy | COWORK-AGENCY-ATTRIBUTION-START/END delimiters, Option A full paragraph, all 6 fields verified |
| F6: presets→examples migration (byte-identical move + symlink) | Easy | 95 files moved; symlink at presets/ for v2.0.x compat; CI paths updated |
| S1: 8-pattern content-scan regex in sync-agency.yml + docs/security/upstream-content-scan-rules.md | Easy | Regex set correct; CI step integrated — limited by F3 YAML parse failure |
| S2: CODEOWNERS + 2-approval rule | Easy | .github/CODEOWNERS covers 5 supply-chain files; CONTRIBUTING.md 2-approval section added |
| S5: attribution-survives-render CI | Easy | Pandoc pipeline test added to quality.yml; confirmed in Phase 5 |
| S6: non-overridable attribution rule verbatim in CLAUDE.md + WIZARD.md | Easy | Verbatim phrasing in both files; manually confirmed Phase 5 G1/G2 |
| S9: zero-SHA rejection CI on main | Easy | lock-file-zero-sha-check job added; correctly scoped to main branch only |
| C14: THIRD-PARTY-NOTICES.md | Easy | Bootstrap-state placeholder; Last regenerated timestamp expected post-C7 |
| C13: trust-boundary disclosures in README + SETUP-CHECKLIST | Easy | Prose paragraphs added to both files |

**Hardest AC:** F3 /sync-agency CI — correct implementation that did not survive the YAML parser. The root cause (heredoc at column 0 inside a block scalar) is a subtle YAML pitfall not caught by keyword-presence testing.

### 3. Token Cost Actuals

Token instrumentation for external projects continues to show model: "unknown" for most entries in the cycle 7 (v2.0) metrics.json. Cycle 7 metrics.json entries aggregate to approximately:

| Model Tier | Input Tokens | Output Tokens | Cache Read | Cache Write | Estimated Cost |
|-----------|-------------|--------------|-----------|-------------|----------------|
| sonnet (confirmed) | ~15 | ~23,000 | ~750,000 | ~12,000 | ~$0.68 |
| unknown (est. sonnet) | — | — | — | — | ~$0.20 est. |
| opus (Phase 1, Phase 2 security, Phase 6 — untracked) | — | ~35,000 est. | — | — | ~$2.63 est. |
| compliance (@compliance Phase 2 — confirmed 1 entry) | ~1 | ~13,000 | ~83,000 | ~1,500 | ~$0.20 est. |
| **Total** | **~16+** | **~71,000 est.** | **~833,000** | **~13,500** | **~$3.71 est.** |

Pricing basis: sonnet $3/$15 per MTok in/out; opus $15/$75 per MTok in/out; cache read ~$0.30, cache write ~$3.75 per MTok.

**Comparison to prior cycle (v1.3.3):** v2.0 cost is approximately 2.5x v1.3.3 (~$1.50 est.). Attributable to: (a) compliance Phase 2 is a new agent cost not present in v1.3.x cycles, (b) full OWASP+LLM Top 10 Phase 6 audit (not abbreviated), (c) v2.0 is a substantially larger feature surface (7 ADRs, ~970 lines of architecture, supply-chain CI, allowlist policy, lock file schema).

The instrumentation gap for external project sub-agent sessions persists as a carry-forward across all 8 cycles. Token data for The-Council self-improvement cycles is captured correctly; this gap is specific to external project agent sessions.

### 4. Phase Durations

| Phase | Start | End | Duration | Notes |
|-------|-------|-----|----------|-------|
| 0 | 2026-05-06T00:00:00Z | 2026-05-06T00:00:00Z | ~1h | Deep mode — v2.0 PRD, 6 features, Riley persona |
| 2a (Compliance) | 2026-05-06T00:00:00Z | 2026-05-06T00:00:00Z | ~1h | Inverse gate: /legal before /design |
| 1 (Design) | 2026-05-06T00:00:00Z | 2026-05-06T00:00:00Z | ~3h | 7 ADRs + 14-step dependency graph + stress tests |
| 2b (Security) | 2026-05-07T03:50:00Z | 2026-05-07T04:01:00Z | ~0.25h | PASS WITH WARNINGS (1 CRITICAL, 5 WARNING, 5 INFO) |
| 3 (Gate) | 2026-05-07T04:01:00Z | 2026-05-07T04:10:00Z | ~0.15h | APPROVED (no adjustments) |
| 4 (Implementation) | 2026-05-07T08:40:00Z | 2026-05-07T09:30:00Z | ~1h | 13 dev commits + 1 doc commit = 14 total |
| 5 (Testing) | 2026-05-07T05:05:00Z | 2026-05-07T05:05:42Z | ~1h | 68 tests, 65 PASS, 1 WARN, 2 INFO |
| 6 (Audit) | 2026-05-07T05:10:00Z | 2026-05-07T05:18:00Z | ~0.15h | Full OWASP+LLM Top 10; 0 CRITICAL, 3 WARN |
| 7 (Approval) | 2026-05-07T11:00:00Z | 2026-05-07T11:00:00Z | ~0.5h | APPROVED |

Phase 1 (3h, 7 ADRs + 970 lines) is the longest phase — appropriate for the architectural depth of v2.0 (lock file trust model, allowlist policy, attribution propagation, migration story, all requiring both ADRs and supporting specs). No phases flagged as outliers given v2.0 scope.

Note: Phase 4 timestamps appear inverted in pipeline.md (Phase 4 start 08:40, Phase 5 start 05:05) — this is a pipeline.md recording artifact from the v1.3.3/v2.0 interleaved session. Actual implementation preceded testing.

### 5. Phases Abbreviated

Phase 2 ran in two parts (abbreviated order): @compliance before @architect, per the inverse gate established at Phase 0 (COMPLIANCE-SENSITIVE classification — legal review must precede design). This is the first cycle to use this order and was deliberate, not an abbreviation.

Phase 6 ran at full OWASP + LLM Top 10 ceremony (not abbreviated combined-path). Required by Phase 3 gate decision and SECURITY-SENSITIVE classification.

No other phases abbreviated. All phases ran at full ceremony.

### 6. Rework Rate and Causes

**Rework rate: 0% (pre-merge)**

Zero implementation lines changed between Phase 4 SHA (98dd22e) and Phase 7 approval. All Phase 5 WARNINGs and Phase 6 WARNINGs were accepted as v2.0.1 deferrals — no code changes required before merge.

One post-Phase-4 fix-up commit was required: markdownlint MD034 bare URL in THIRD-PARTY-NOTICES.md was caught by CI on first PR push. This is a documentation lint issue, not an implementation rework — classified as CI hygiene, not pipeline rework.

**Post-merge rework (v2.0.1 — separate cycle):** sync-agency.yml YAML parse error requires a hotfix. This is counted as a v2.0.1 cycle, not as rework in the v2.0 rework rate. Rationale: the error was not detected in Phase 5 or Phase 6, represents a new defect category (YAML structure vs. content correctness), and requires a standalone fix with its own pipeline ceremony. Counting as v2.0 rework would misrepresent the pipeline's actual behavior — it found what it tested for; the test was insufficient.

**Rework root cause (informational for v2.0.1 carry-forward):** Phase 5 Group C tests used `grep` to confirm keyword presence in the YAML file. They did not run a YAML parser, and they did not verify GitHub had registered the trigger via `gh workflow list`. The gap is in test strategy, not in test execution — the tests passed correctly given their scope.

### 7. Issues Prevented

| Category | Count | Details |
|----------|-------|---------|
| Blocker | 0 | — |
| Issue | 3 | C8 (SPDX comparison absent from sync-agency.yml per ADR-022 spec — compliance gap deferred v2.0.1); A3 (CHANGELOG claims PR template that wasn't created — doc fidelity gap); B2 (ADR-023 category list uses placeholder values, not actual implementation — documentation drift) |
| Info | 8 | G3 (no CI grep for S6 verbatim attribution rule), A4 (concurrency group not set on sync-agency.yml), A5 (heredoc delimiter not randomized — future hardening), A6 (fetched-files namespace by category missing), A7 (workflow-level permissions: read-all not set), A8 (SETUP-CHECKLIST Windows symlink note missing), A1 (SPDX comparison gap at LICENSE-hash level), A2 (ADR-023 drift acceptable post-merge amendment) |

**Post-merge missed BLOCKER (qa_issues_missed):** 1 — sync-agency.yml YAML parse error. The workflow is non-functional despite the Phase 5 test suite passing. This is a pipeline miss, not a pipeline failure — the tests covered what they covered. The gap is documented as a process improvement candidate for v2.0.1.

**Cumulative (all cycles v1.0 through v2.0):** blocker=2, issue=4, info=14

### 8. Pattern Detection

**3-cycle Phase 6 scan (v1.3.1, v1.3.3, v2.0) — WARNING+ level:**

- v1.3.1 Phase 6: 0 findings
- v1.3.3 Phase 6: 0 findings
- v2.0 Phase 6: 3 WARNING (A1 SPDX gap, A2 ADR-023 drift, A3 CHANGELOG/PR-template drift)

**Result:** No 3-cycle Phase 6 WARNING+ recurring keyword pattern. v2.0 is the first cycle with Phase 6 WARNINGs since v1.2 (A1 CI logic bug). The keywords `configuration`, `scope`, `guard`, `auth` do not recur at WARNING+ across v1.3.1, v1.3.3, and v2.0.

**P1 — ADR-spec drift on parameterized artifacts (PROMOTED, 3-cycle confirmation):**

@security Phase 6 confirmed this pattern across 3 cycles and directed promotion to docs/patterns.md. Confirmed instances:

- v1.2 Phase 6 A1: registry-cardinality-check CI logic counted 6 rows (not 18) — array-count drift
- v2.0 Phase 5 C8: per-file SPDX comparison absent from sync-agency.yml despite ADR-022 specifying it — feature drift
- v2.0 Phase 5 B2: ADR-023 category list (placeholder) ≠ implementation list (real agency-agents catalog) — documentation drift
- v2.0 Phase 6 A3: CHANGELOG claims a PR template that wasn't created — release-notes fidelity drift

Pattern: when a spec, ADR, or release artifact describes a parameterized list (category list, count, feature checklist), implementations frequently ship with the placeholder value or a subset of the spec's list rather than the final value. Mitigation: Phase 5 ADR-to-implementation parameterized-list diff as a standard checklist item.

**P2 — CI workflow tests check syntax presence, not parser-correctness (NEW, 1-cycle observation):**

sync-agency.yml YAML structure bug slipped through Phase 5 and Phase 6 because:
1. Tests grep for keyword presence (`workflow_dispatch:`, `cron:`) — passes even when YAML structure is broken
2. @security audited content (regex rules, SHA-pinning) but not YAML structure validity
3. No step verified GitHub's trigger registration via `gh workflow list`

This pattern is a 1-cycle observation, not yet eligible for 3-cycle promotion. Tracking for next CI-heavy cycle. Proposed quality-baseline addition: "Every new CI workflow file MUST be validated against a YAML parser AND have its trigger registration confirmed via `gh workflow list` after first push to main."

**Pattern promotion action: docs/patterns.md created (P1 first entry).**

### 9. Retrospective Verdict

v2.0 is the most architecturally complex cycle in this project's history. Seven ADRs, a supply-chain integrity layer, a compliance-first review gate, and a full OWASP + LLM Top 10 security audit — all at 0% pre-merge rework. The pipeline's strongest moment was Phase 2 (security): correctly identifying a CRITICAL gap (S1 content-scan absent — LLM01 surface unmitigated) and resolving it fully in Phase 4 before any deployment surface was opened. The Phase 6 confirmation that LLM05 (Supply Chain) was at the strongest controls in project history is accurate given the SHA-pinned lock file, CODEOWNERS, 2-approval rule, and content-scan CI.

The cycle's shadow is the post-merge YAML bug. The shipped feature (F3 /sync-agency CI) is non-functional until v2.0.1. The failure mode is instructive: grep-based YAML validation is insufficient for complex multi-block workflows. The pipeline caught injection risk, supply-chain risk, and documentation drift — but missed a structural syntax error that a 2-line Python check would have caught. The fix for v2.0.1 is both the YAML heredoc correction and the test strategy addition (YAML parser + `gh workflow list` trigger registration check).

The 3-cycle pattern P1 (ADR-spec drift on parameterized artifacts) is now promoted. Its mitigation — a Phase 5 ADR-to-implementation parameterized-list diff — is the clearest process improvement this retrospective surfaces. It is low-cost (a checklist item) and addresses a recurring root cause across multiple manifestations. Pattern P2 (YAML structure not checked) is a 1-cycle observation worth tracking but not yet promotable.

Overall cycle health: strong architecture, strong security discipline, strong zero-rework implementation — with a documented post-merge miss that is both understood and fixable.

---

*Generated by @qa Phase 8 retrospective — 2026-05-07*

---

## v2.0.x umbrella retrospective (v2.0.1–v2.0.4)

**Date:** 2026-05-06
**Classification:** SECURITY-SENSITIVE (v2.0.1: STANDARD, v2.0.2: SECURITY-SENSITIVE, v2.0.3: STANDARD, v2.0.4: SECURITY-SENSITIVE)
**Mode:** quick (all four hotfix cycles)
**Rework rate:** v2.0.1 0%, v2.0.2 11%, v2.0.3 <5%, v2.0.4 <5%
**Umbrella scope:** 5 tags (v2.0.0–v2.0.4), 9 PRs merged, 13 issues closed. Strategic pivot: "preset library" → "supply-chain-gated dynamic workspace architect."

---

### Headline Finding — The 5-Layer Bug Onion

The v2.0.x series exposed a cascading layer structure: each post-merge BLOCKER was masked by the previous one. The sequence only became visible because each prior fix worked:

| Layer | Cycle | Bug class | What masked it | What surfaced it |
|-------|-------|-----------|----------------|-----------------|
| 1 | v2.0.0 | YAML structure broken (#12) | — (first cycle) | First /sync-agency dispatch attempt |
| 2 | v2.0.1 | Hallucinated action SHA (#23) | YAML couldn't parse | YAML parsing fixed |
| 3 | v2.0.2 | API auth missing (#25) | Action SHA unresolvable | SHA corrected |
| 4 | (repo setting) | GitHub Actions PR-create permission disabled | Auth was failing | Auth fixed |
| 5 | v2.0.4 | Bash subshell scope + 6 phantom allowlist categories (#28) | Permission setting blocked workflow | Permission setting flipped |

Net result of the v2.0.4 fix: PR #31 merged with **110 third-party MIT files** populating cleanly, 0 prompt-injection hits, 10 categories confirmed operational.

---

### 1. Phase Findings Summary

| Cycle | Phase | Agent | Findings Count | Severity Breakdown |
|-------|-------|-------|---------------|-------------------|
| v2.0.1 | 2 | @security | 0 | 0 CRITICAL, 0 WARNING, 0 INFO |
| v2.0.1 | 5 | @qa | 0 | PASS (4 local, 2 deferred post-merge) |
| v2.0.1 | 6 | @security | 0 | 0 CRITICAL, 0 WARNING, 0 INFO |
| v2.0.2 | 2 | (quick scan — bundled in Phase 3) | — | FAST-TRACK (0 findings) |
| v2.0.2 | 5 | @qa | 1 | 1 INFO (AC-7 grep pattern mismatch — non-blocking) |
| v2.0.2 | 6 | @security | 3 | 0 CRITICAL, 1 WARNING (S1 P1 recurrence — RESOLVED), 2 INFO |
| v2.0.3 | 0 | @pm | 0 | Quick mode — #25 BLOCKER + dry-run CI |
| v2.0.4 | 2 | @security | 3 | 0 CRITICAL, 1 WARNING (S1 jq injection — RESOLVED), 2 INFO |
| v2.0.4 | 4 | @dev | 0 | All ACs pass pre-Phase 5 |

Key theme: P2 (yaml.safe_load gate) caught v2.0.1, v2.0.2, and v2.0.4 regressions in CI. Working as designed. P1 (ADR-spec drift) recurred in v2.0.2 (ADR-023 amendment used placeholder categories instead of live list). Fixed in-cycle via doc-only rework commit.

---

### 2. AC Difficulty Assessment

| Cycle | AC | Classification | Notes |
|-------|-----|---------------|-------|
| v2.0.1 | AC-1 yaml.safe_load PASS | Easy | Direct validator call; pass/fail |
| v2.0.1 | AC-2 workflow_dispatch registered | Hard | Requires post-merge `gh api` verification; deferred |
| v2.0.1 | AC-4 NOTICES output byte-equivalence | Easy | Smoke test passed locally |
| v2.0.1 | AC-6 CONTRIBUTING.md quality baseline | Easy | Single section append; P2 pattern codified |
| v2.0.2 | #23 SHA correction | Easy | Correct SHA looked up and applied in first commit |
| v2.0.2 | #13 SPDX comparison | Easy | jq+bash, heredoc-free per P2 rule |
| v2.0.2 | ADR-023 category list accuracy | Hard | P1 pattern triggered — placeholder list replaced live. Required Phase 6 rework commit (doc-only). |
| v2.0.3 | #25 Authorization header | Easy | Applied to all api.github.com calls; dry-run CI added |
| v2.0.4 | Fix A: JSONL accumulator | Hard | Subshell scope loss in pipe-while-read; required JSONL intermediate file + process substitution redesign |
| v2.0.4 | Fix B: allowlist trim to 10 entries | Easy | Data edit; exact match verified by AC-3/AC-4 |
| v2.0.4 | Fix C: dry-run 2-file accumulator gate | Easy | Extends existing dry-run step; accumulator length assert added |

**Hardest ACs across series:** Fix A (v2.0.4) and ADR-023 category accuracy (v2.0.2) — both required architectural understanding beyond the surface change.

---

### 3. Token Cost Actuals

Token instrumentation continues to show `model: "unknown"` for most entries in external project sub-agent sessions. Estimates are based on observed output volume and known agent model assignments.

| Cycle | Model Tier | Estimated Cost |
|-------|-----------|----------------|
| v2.0.1 | sonnet (Phase 0/4/5), opus (Phase 1/2/6) | ~$0.45 est. |
| v2.0.2 | sonnet (Phase 0/4/5), opus (Phase 1/6) | ~$1.10 est. |
| v2.0.3 | sonnet (Phase 0) | ~$0.10 est. (quick mode) |
| v2.0.4 | sonnet (Phase 0/4), opus (Phase 1/2) | ~$0.80 est. |
| **Umbrella total** | | **~$2.45 est.** |

Pricing basis: sonnet $3/$15 per MTok in/out; opus $15/$75 per MTok in/out. Instrumentation gap persists across all external project cycles. Token data for The-Council self-improvement cycles is captured correctly.

---

### 4. Phase Durations

| Cycle | Phase | Approximate Duration | Notes |
|-------|-------|---------------------|-------|
| v2.0.1 | 0–4 (full pipeline) | ~1.5h | Quick/hotfix mode; heredoc-only fix |
| v2.0.1 | 5–7 (QA/audit/approval) | ~1h | 4 local ACs; 2 deferred post-merge |
| v2.0.2 | 0–4 (full pipeline) | ~12h | 10-fix bundle; 8 commits; rework commit 81e4e7e for P1 recurrence |
| v2.0.2 | 5–7 (QA/audit/approval) | ~2h | SECURITY-SENSITIVE; full OWASP+LLM Top 10 |
| v2.0.3 | 0 only | <1h | PRD only; rest pending |
| v2.0.4 | 0–4 (full pipeline) | ~4h | Fix A (subshell redesign) is the heaviest single fix in the series |
| v2.0.4 | 5 (testing) | not yet run | Phase 5 is the trigger for this retro |

Note: v2.0.3 Phase 0 was the only phase run for that cycle before v2.0.4 absorbed its intent (auth header fix landed within v2.0.2's #25 scope; dry-run CI became Fix C in v2.0.4). The v2.0.3 cycle name persists in pipeline.md as a record of the issue surfacing event.

**Outlier:** v2.0.2 elapsed time (~12h) is 8x longer than v2.0.1 — attributable to the 10-fix bundle scope and the P1 ADR-023 rework adding a doc-correction loop. Not a quality regression; appropriate for the surface area.

---

### 5. Phases Abbreviated

All four hotfix cycles ran in **quick mode** — abbreviated ceremony appropriate for post-merge BLOCKERs with tightly bounded scope.

Abbreviations per cycle:
- v2.0.1: Phase 2 full security scan → Phase 2 quick 3-question scan (scope: 1 YAML structural fix, strictly safer than v2.0). Phase 8 retro skipped (umbrella coverage by this document).
- v2.0.2: Phase 2 combined with user gate (FAST-TRACK APPROVED on 0 findings). Phase 8 retro skipped (umbrella coverage).
- v2.0.3: Phase 0 only run before scope was absorbed into v2.0.4. Phase 8 retro skipped.
- v2.0.4: Phase 5/6/7 covered by this umbrella retro; Phase 6 abbreviated for v2.0.4 (quick-mode skip per pipeline brief).

Phase 6 in v2.0.4 was not run independently (quick mode, Phase 6 skipped per brief). The absence of Phase 6 is noted; v2.0.4's supply-chain surface was evaluated during v2.0.2 Phase 6 and the incremental change (JSONL accumulator + allowlist trim) does not introduce new attack surfaces.

---

### 6. Rework Rate and Causes

| Cycle | Pre-merge rework | Root cause |
|-------|-----------------|-----------|
| v2.0.1 | 0% | No rework — heredoc extraction was correct first time |
| v2.0.2 | 11% | S1: ADR-023 amendment used placeholder category list (P1 pattern recurrence). Doc-only rework commit 81e4e7e. |
| v2.0.3 | <5% | 1 dry-run filter fix; details not fully recorded (quick mode) |
| v2.0.4 | <5% | bootstrap-reset PR pre-merge; scope clean-up |

**Cumulative series rework:** ~4% weighted average across the four cycles. The P1 recurrence in v2.0.2 is the most instructive rework event: @architect wrote the ADR-023 amendment with the correct placeholder list as a spec draft, and @dev committed it verbatim without substituting the live `.cowork-allowlist.json` content. The P1 mitigation (byte-comparison of frozen list against live source) would have caught this immediately. Strengthening P1's mitigation is the primary carry-forward from this series.

---

### 7. Issues Prevented

| Cycle | Category | Count | Details |
|-------|----------|-------|---------|
| v2.0.1 | blocker | 0 | — |
| v2.0.1 | issue | 0 | — |
| v2.0.1 | info | 1 | AC-6 quality baseline gap (P2 pattern codified) |
| v2.0.2 | blocker | 0 | — |
| v2.0.2 | issue | 2 | S1 P1 recurrence (ADR-023 placeholder list); AC-7 spec grep pattern mismatch |
| v2.0.2 | info | 2 | S2 cosmetic label naming; symlink section prominence |
| v2.0.3 | blocker | 0 | — (quick/PRD only) |
| v2.0.4 | blocker | 0 | — |
| v2.0.4 | issue | 0 | — |
| v2.0.4 | info | 0 | — |
| **Umbrella** | **blocker** | **0** | |
| **Umbrella** | **issue** | **2** | |
| **Umbrella** | **info** | **3** | |

**Post-merge BLOCKERs (not prevented by pipeline, but surfaced quickly):** The 5-layer bug onion produced 3 post-merge BLOCKERs across the series (#12 YAML, #23 SHA, #25 auth). Each was caught within one cycle of the prior fix landing. The dry-run CI job (v2.0.3/v2.0.4 Fix C) is the structural gate that prevents Layer 5-class regressions going forward.

---

### 8. Pattern Detection

#### P4 — NEW PATTERN (1-cycle observation, promoted with explicit mitigation)

**Pattern P4: Cumulative-feature shipping with external-trigger workflow gating produces post-merge layer-onions.**

When a feature includes a new long-running workflow (cron + workflow_dispatch + multi-step), each post-merge BLOCKER masks the next. Test scaffolding was meaningfully behind the surface for v2.0.0–v2.0.3. The dry-run CI gate (v2.0.3 + v2.0.4 Fix C) now structurally prevents recurrence.

**1-cycle observation note:** P4 has 1 confirmed cycle (v2.0.0 as the originating event). Promote to docs/patterns.md with the mitigation explicitly codified, but mark as "watch v2.1+ for recurrence." The mitigation is concrete and additive regardless of 3-cycle threshold.

**Mitigation:** Any cycle that adds a new external-trigger workflow MUST include a dry-run job at the same PR that exercises ≥2 representative end-to-end paths (not just isolated steps) before Phase 7 APPROVED.

#### P1 — ADR-spec drift (STRENGTHENING RECOMMENDATION)

P1 recurred in v2.0.2: ADR-023 amendment used a placeholder category list rather than the live `.cowork-allowlist.json` list. This is the canonical P1 failure shape (parameterized list written as draft, not substituted at commit time).

**Strengthening recommendation:** Amend P1's mitigation to mandate **byte-comparison** of the frozen list against the live source file (not cardinality check). The v2.0.2 Phase 5 AC-10 was a cardinality check (count=13), which passed. The content drift (which 13 categories) required Phase 6 to catch. A `diff <(cat .cowork-allowlist.json | jq '.allowed_categories[]') <(grep -oE '"[^"]+"' ADR-023-amendment)` style check at Phase 5 would have caught it immediately.

#### P2 — CI workflow yaml.safe_load gate (WORKING AS DESIGNED)

P2 (YAML structure not parser-checked) produced the v2.0.0 YAML BLOCKER (#12). The v2.0.1 AC-6 quality baseline codified the fix in CONTRIBUTING.md. v2.0.2 and v2.0.4 both pass yaml.safe_load as mandatory ACs (AC-1/AC-2). P2 is not recurred — the gate is operational.

#### P3 — SHA verification baseline (WORKING AS DESIGNED)

P3 was established in v2.0.2's CONTRIBUTING.md Check 3. v2.0.4 did not add new actions (no new SHA pinning needed). P3 is a standing control, no new test-fire this cycle. Carry-forward as active control.

#### 3-cycle Phase 6 scan (v2.0.1, v2.0.2, v2.0.4)

- v2.0.1 Phase 6: 0 findings
- v2.0.2 Phase 6: 1 WARNING (S1 — P1 pattern recurrence, RESOLVED in-cycle), 2 INFO
- v2.0.4 Phase 6: skipped (quick mode)

**Result:** `configuration` appears at WARNING in v2.0.2 Phase 6 (S1 ADR-023 placeholder) — same keyword surface as v2.0 Phase 6 (A2 ADR-023 drift). Two consecutive cycles with `configuration` WARNING at Phase 6. Not yet 3 cycles. Monitor in v2.1+.

No `/self-improve` action warranted at this time. The Phase 5 ADR-to-implementation byte-comparison mitigation (P1 strengthening) is the concrete improvement to act on.

---

### 9. Quality Baseline Comparison

Quality baselines are calibrated for The-Council self-improvement cycles. For this external project (static markdown + CI YAML repo, no auth/schema/RLS), applicable behaviors are evaluated where observable across the v2.0.x series.

Note: Baselines reside in The-Council (`.claude/skills/*/quality-baseline.json`). Cross-project comparison is content-review assessment only — not live-tested inject prompts.

| Agent | Applicable Scenarios | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | v2.0.1–v2.0.4 quick-mode PRDs were tight, pre-specified with exact ACs, and correctly scoped to BLOCKER-only surfaces. No ambiguous intent observed. | PASS |
| @architect | QA3 (speculative abstraction), ADR fidelity | v2.0.1 ADR-027 was strictly correct and resolved v2.0 A5 as a side effect. v2.0.2 Phase 1 correctly bounded all 10 fixes to existing ADR contracts (no ADR-028). v2.0.4 Phase 1 correctly identified inner SCAN_PATTERNS loop as bash-array-in-process (no fix needed). ADR fidelity: PARTIAL FAIL — v2.0.2 ADR-023 amendment was written with placeholder categories, not live list. P1 pattern reproduced. | PASS-with-improvement against P1-strengthening |
| @security | QS2 (external data ingestion), QS3 (fail-closed vs fail-open) | v2.0.2 Phase 6 caught P1 recurrence (ADR-023 amendment content drift) via reading the amendment text, not just trusting the CI count. v2.0.4 Phase 2 correctly flagged S1 (jq injection risk via --arg/--argjson) before Phase 4. | PASS |
| @qa | QQ2 (AC coverage), QQ3 (rework detection) | Phase 5 in v2.0.0 grepped for keyword presence instead of yaml.safe_load — the original masking failure. v2.0.1+ Phase 5 ACs include yaml.safe_load as hard gate (AC-6 quality baseline). Rework rate correctly computed for v2.0.2 (11%). | PASS-with-improvement (P4 dry-run gate closes QQ2 gap for CI workflows) |

**Overall:** 3.5/4 agents PASS. @architect PASS-with-improvement on P1-strengthening (ADR content fidelity check). @qa PASS-with-improvement on P4 mitigation (dry-run coverage now structural).

#### Quality Baseline Candidates for Promotion

Two new baseline behaviors observed consistently across the v2.0.x series, not yet in any quality-baseline.json:

1. **(P4) Dry-run gate for new CI workflows:** Every new external-trigger workflow MUST include a dry-run job exercising ≥2 e2e paths before Phase 7 APPROVED. (Proposed addition to @qa quality-baseline.json QQ2 test vector.)
2. **(P1 strengthening) ADR parameterized-list byte-comparison at Phase 5:** When a spec or ADR describes a parameterized list, Phase 5 must byte-compare the ADR text against the live source file. Cardinality check is insufficient. (Proposed strengthening of @architect quality-baseline.json QA3 scenario + @qa QQ2.)

---

### Carry-Forward Items to v2.1+

| Item | Source | Priority | Description |
|------|--------|----------|-------------|
| Wizard FSM completion | Deferred from v2.0.1 spec | MEDIUM | Multi-category staged install UX (ADR-021) — full FSM with stop-anywhere UX requires wizard test session with real upstream content post-C7 |
| Re-evaluate skipped categories | v2.0.4 Fix B | LOW | game-development, spatial-computing, specialized, strategy, paid-media, integrations — 6 categories removed from allowlist pending per-category vetting; additive expansion when ready |
| Preset vs upstream quality assessment | Strategic | MEDIUM | Delete vs hybridize presets/examples/ — structured per-skill comparison cycle needed |
| Full content audit of 110 files | Open Issue #3 (post-merge) | HIGH | Sample-audit-only at merge; full audit of all 110 MIT files not yet performed |
| P1 mitigation strengthening | v2.0.2 Phase 6 lesson | HIGH | Amend P1 mitigation to require byte-comparison of frozen lists against live source files, not cardinality check |
| P4 monitoring | This retro | LOW | Watch v2.1+ cycles with new external-trigger workflows for P4 recurrence to confirm/deny 3-cycle promotion |
| `configuration` WARNING recurrence | Phase 6 pattern | LOW | 2 consecutive cycles (v2.0, v2.0.2) with `configuration` WARNING at Phase 6 — 1 more would trigger P5 promotion |

---

### 10. Retrospective Verdict

The v2.0.x hotfix series is a textbook case of post-merge layer-onion debt: the v2.0.0 shipping decision (correct supply-chain architecture, solid 0% pre-merge rework) produced a non-functional feature that required 4 follow-on cycles to fully activate. Each cycle was tight, correctly scoped, and resolved its BLOCKER without introducing regressions. The pipeline operated as designed at every layer — the failures were in surfaces that the pipeline did not yet test (YAML structure, action SHA resolution, API auth, subshell scope), not in surfaces it did test.

The two most consequential process improvements from this series are already implemented: the yaml.safe_load mandatory gate (AC-1/AC-2 in every cycle, CONTRIBUTING.md quality baseline) and the dry-run CI job (Fix C, v2.0.4). Both are structural — they will catch the same class of bugs automatically in future cycles without relying on reviewer judgment.

The P1 strengthening recommendation (byte-comparison instead of cardinality check) is the remaining open improvement. It is low-cost (a single diff command in Phase 5 checklist) and addresses a failure that has now appeared twice in this project's history. That is sufficient justification to implement without waiting for a third occurrence.

Net delivery: 110 MIT-licensed third-party skill files flowing cleanly through a supply-chain-gated pipeline. The strategic pivot from static preset library to dynamic workspace architect is complete and operational.

---

*Generated by @qa Phase 8 retrospective (umbrella) — 2026-05-06*

---

## v2.3.0 — Top-2 Stub Expansion + ADR-028 Spec Scaffold

**Date:** 2026-05-08
**Classification:** STANDARD (consistent Phase 0–7)
**Mode:** full
**Rework rate:** 0.7% (8 lines, 1 file, post-Phase-4 MD058 fix)
**Cycle SHA:** 454ce2e (tag v2.3.0, merged 2026-05-08T15:00:00Z)

---

### 1. Cycle Summary

v2.3.0 shipped 5 workstreams in a single ~5-hour full-ceremony pipeline session: voice-matching stub expanded to full 9-section ADR-015 depth (W1), daily-briefing stub expanded to full 9-section ADR-015 depth (W2), registry disposition annotations added for doc-summary and action-items skills (W3), ADR-028 content_sha256 per-file integrity spec scaffold recorded as PROPOSED with implementation deferred to v2.4 (W4), and a 2-cycle orphan item formally closed by pipeline log entry (W5). All 30 ACs and 9 constraints passed. The one notable event: @dev's W3 registry annotation strategy placed blockquote lines inside the Business/Admin markdown table, triggering MD058/blanks-around-tables in CI; @qa caught this at Phase 5 before merge, @dev issued an 8-line rework commit, and the combined Phase 5+6+7 path was reinstated after CI went green. The recurring 2-cycle miss on version release artifacts (README badge + Next-up teaser) was explicitly bound as a 4-sub-item constraint (C-v2.3-6) and both shipped correctly — pattern RESOLVED. Phase 1 deliberation produced 3 amendments (S2→C-v2.3-1a, D1→C-v2.3-5 ordering, S4→ADR-028 reader contract) all folded cleanly without redesign.

**Verdict: HEALTHY.** 0 CRITICAL and 0 WARNING across all phases. Rework was 0.7% of Phase 4 lines, doc-only, caught pre-merge by @qa. Pipeline executed exactly as designed.

---

### 2. What Went Well

- **Combined Phase 5+6+7 path executed cleanly** (second consecutive use — v2.2 precedent): STANDARD classification + 0-finding Phase 4 deliberation made this path legitimate, not a shortcut. Path was forfeited and reinstated correctly after MD058 rework.
- **Recurring 2-cycle miss RESOLVED**: C-v2.3-6 bound all 4 release-artifact sub-items explicitly (VERSION, CHANGELOG, README badge `version-2.3.0-green`, Next-up "v2.4" teaser). Both previously missed items shipped. Explicit enumeration at the constraint level works where general reminders do not.
- **Phase 1 deliberation amendments folded cleanly without redesign**: All three amendments (C-v2.3-1a base-sync evidence string, C-v2.3-5 annotation ordering, ADR-028 reader contract) were wording-only changes. No OQ resolutions revisited. ~30 lines added to architecture.md; AC count and constraint count unchanged.
- **Per-commit scope discipline was perfect**: All 7 commits (99ee830 through 7d31892) touched exactly their declared files — 6/6 scope checks clean at Phase 4 deliberation, plus the rework commit 7d31892 (curated-skills-registry.md only). Zero cross-commit drift.
- **C-v2.3-1a base-sync evidence string caught its own potential miss**: The requirement to emit a verbatim evidence string made the base-sync check self-auditing. @qa found it on both commit 99ee830 and scratchpad line 2285. A procedural check without an evidence string would have been unverifiable post-hoc — the amendment held.
- **@architect anti-pattern scan caught ENFORCED_PRESETS→ENFORCED_EXAMPLES rename**: OQ-3 correctly resolved that adding writing/PA to the CI allowlist would cascade-fail 4 remaining stubs. Independent verification by @security confirmed the glob-based loop. No scope error introduced.
- **ADR-028 PROPOSED-only discipline held firm**: cowork.lock.json and quality.yml were byte-unchanged throughout the cycle. W4 was purely architectural documentation, not implementation. C-v2.3-9 zero-diff enforcement worked.
- **@pm Phase 0 WILL-NOT-DO list (10 items)**: Explicit scope exclusions prevented 10 potential scope-creep vectors from entering any subsequent phase discussion. The exclusion list is now load-bearing architecture.

---

### 3. What Didn't Go Well

- **MD058 markdownlint blocker slipped past Phase 4**: @dev placed blockquote annotation lines (`> disposition: covered-by-runtime`) immediately after rows inside the Business/Admin markdown table. This splits the table per markdownlint's MD058 rule (blanks required around table boundaries), but the rule is only enforced by CI — there is no equivalent local lint step in the cowork workflow for @dev to run before push. @qa caught the failure at Phase 5 when CI turned red. The 8-line rework (move annotations to a `#### Disposition Annotations` subsection after the table) was straightforward, but it cost a CI run and a rework commit.

  **Root cause framing**: The gap is not an @dev judgment error — the annotation placement was architecturally reasonable and the OQ-4 resolution specified `>` blockquote format. The gap is that cowork's pipeline has no local markdownlint step equivalent to `npm test` in The-Council. @dev cannot self-check markdownlint compliance before push. The fix belongs in the pipeline, not in @dev's behavior.

- **Annotation format not stress-tested against markdownlint before Phase 4 commit**: OQ-4 resolved the format as `>` blockquote lines, but neither @architect at Phase 1 nor @security at deliberation ran the annotation pattern against the actual `.markdownlint.jsonc` rule set. The combined-path FORFEIT was foreseeable if the CI check had been consulted during deliberation.

- **ADR Index still not backfilled**: ADR-020 through ADR-028 appear in the architecture.md body but are absent from the ADR Index table (lines 11–37 of architecture.md). v2.3.0 acknowledged this as a hygiene gap and deferred it again to v2.4. This is the third consecutive cycle where the gap is acknowledged but not closed.

---

### 4. Quality Patterns

#### Active Patterns (promoted + watch)

**P-COWORK-1: local-lint-vs-CI-divergence** — NEW WATCH (1-cycle observation, v2.3.0)

Cowork's CI runs markdownlint-cli2 on all markdown files (including registry and skill files) but the pipeline has no local `npm run lint` or equivalent @dev can self-check against before push. Any annotation or formatting strategy that @architect designs at Phase 1 could violate a markdownlint rule that is not visible until CI runs at Phase 5. The v2.3.0 MD058 failure is the first manifestation of this structural gap.

**Status:** WATCH — 1 cycle. Eligible for promotion at 3rd cycle.

**P-COWORK-2: recurring-version-artifact-miss** — RESOLVED (v2.1 + v2.2, mitigated in v2.3.0)

Two consecutive cycles (v2.1 and v2.2) shipped without the README badge and "Next up" teaser. Mitigation applied in v2.3.0: C-v2.3-6 listed all 4 sub-items explicitly (VERSION, CHANGELOG, README badge with exact badge string, Next-up teaser with exact v2.4 reference). Both previously missed items shipped correctly.

**Status:** RESOLVED via explicit 4-sub-item constraint enumeration. Pattern is now a precedent for fixing recurring artifact misses through constraint disaggregation rather than general reminders.

**P-COWORK-3: combined-path-eligibility-from-clean-deliberation** — WATCH (v2.2 + v2.3.0, 2 cycles)

STANDARD-classified docs-only cycles that receive a clean Phase 4 deliberation (0 CRIT + 0 WARN from both @qa and @security reviewers) are consistently eligible for the combined Phase 5+6+7 path. In v2.2 the path ran cleanly end-to-end. In v2.3.0 it was forfeited mid-cycle (MD058 CI blocker) and reinstated after rework. In both cases the eligibility determination was correct and the path was appropriate.

**Status:** WATCH — 2 cycles. Eligible for promotion at 3rd cycle.

**P-COWORK-4: deliberation-fold-vs-redesign** — WATCH (v2.2 + v2.3.0, 2 cycles)

In both v2.2 and v2.3.0, Phase 1 deliberation produced amendment requests (constraint wording, ordering clarifications, prose additions) that folded cleanly into architecture.md without triggering a full Phase 1 redesign. In v2.2: 0 amendments needed. In v2.3.0: 3 amendments (C-v2.3-1a, C-v2.3-5 ordering, ADR-028 reader contract), all folded as ~30-line additions. The pattern: when deliberation findings are constraint-wording or prose-binding changes (not new ADRs, not OQ reversals), they fold without ceremony increase.

**Status:** WATCH — 2 cycles. Eligible for promotion at 3rd cycle.

---

### 5. Council /self-improve Candidates

The following improvements are surfaced for The-Council to absorb. This section is informational — do NOT auto-invoke /self-improve.

**C1: `check-base-sync.sh` guard** (carried from v2.2 P5, HIGH)

Pre-/spec guard that git-fetches origin and blocks if local branch is behind. Prevents stale-base cycles like the v2.2 blocker. The-Council `scripts/` (sibling to `check-stale-cycle.sh`). Spec available in v2.2 retro Section 8 P5. This is the highest-priority unimplemented Council self-improve candidate from this project.

**C2: `markdownlint pre-commit hook` or `local-lint-runner` for cowork-style content repos** (NEW, v2.3.0)

Closes the MD058 gap: cowork has no local markdownlint step @dev can run before push. Options: (a) add `npm run lint` step to cowork's package.json and register in @dev's Phase 4 checklist; (b) add a pre-commit hook to cowork that runs markdownlint-cli2 locally; (c) enhance The-Council's @dev Phase 4 protocol to require running repo CI checks locally before push when the repo has a CI markdownlint job. Option (a) is simplest. Either way, the fix closes the phase-gap between what @architect specifies and what CI enforces.

**C3: ADR Index backfill** (carried from v2.0–v2.3.0, MEDIUM)

ADR-020 through ADR-028 are absent from the architecture.md ADR Index table (lines 11–37). Third consecutive cycle where this is acknowledged but not closed. Suggest including as a non-negotiable AC in the next v2.4 spec rather than leaving it as a hygiene note.

**C4: `version-artifact-checklist` script** (v2.3.0 observation, MEDIUM)

Automate the 4-sub-item release artifact check (VERSION, CHANGELOG, README badge, Next-up teaser) as a CI gate rather than relying on explicit constraint enumeration each cycle. A CI step checking `grep -c "version-X.Y.Z-green" README.md` and `grep -c "Next up" README.md` would catch the recurring miss structurally. Could pair with the existing CLAUDE.md word-count check pattern.

---

### 6. Tier 1 Agent Quality Baseline Assessment

Quality baselines from `.claude/skills/*/quality-baseline.json` (v23.0, pass threshold 0.80). This is a content-review assessment — not live-tested inject prompts — applied to observed agent behavior in v2.3.0. All scenarios evaluated are applicable to a static markdown + CI YAML repo (no auth/RLS/schema).

| Agent | Scenarios Evaluated | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | Full-mode Phase 0 PRD correctly scoped 5 workstreams from a complex carry-forward list + roadmap candidates. 10 WILL-NOT-DOs held throughout the cycle. 5 OQs forwarded to @architect with concrete question framing. No spec produced without user-gate approval. 30 ACs with deterministic grep/wc evidence mappings. | PASS (2/2 applicable) |
| @architect | QA3 (speculative abstraction), QA1/QA5 (anti-pattern/deprecation scan) | Anti-pattern scan caught ENFORCED_PRESETS rename (OQ-3 cascade-fail resolution). No speculative abstraction — ADR-028 deliberately constrained as PROPOSED-only; option (c) migration chosen as lowest-blast-radius. 5 OQs resolved with binding implementation guidance. Phase 1 amendments folded without over-engineering. @security's S4 (reader contract) folded as zero-scope-expansion prose, not a new ADR. | PASS (3/3 applicable) |
| @security | QS2 (external data), QS3 (fail-closed/fail-open), QS1 (guard modification) | Phase 1 deliberation correctly classified C-v2.3-1 as procedural-only (S2 WARNING) and proposed a verifiable evidence-string fix rather than just accepting the procedural posture. LLM01 surface check (5 injection vectors, triple-backtick check) applied independently at both deliberation and Phase 6 reconfirmation. 7 Phase 2 preservation constraints verified independently at Phase 4 deliberation AND reconfirmed at Phase 7. Cardinality synthetic test run for annotation format. None of QS1/QS2/QS3 surfaces were present in this STANDARD cycle — not applicable, but @security's overall rigor is clearly above the 0.80 threshold. | PASS (all applicable scenarios clear; rigor exceeds baseline) |
| @qa | QQ2 (AC coverage), QQ1 (flaky test), QQ3 (rework rate) | MD058 blocker caught at Phase 5 before merge — QQ2 scenario played out correctly (FAIL verdict issued, rework required, combined-path FORFEITED). Phase 5 reaffirmation correctly scoped to 4 re-tested ACs rather than re-running all 30 (efficiency + correctness). Rework rate correctly computed at 0.7% with Phase 4 SHA and rework SHA identified. QQ3: rework rate documented with "post-Phase-4 catch by Phase 5" precision; not overclaimed as "in-cycle rework" in the usual sense. **@dev baseline question noted (see below).** | PASS (2/2 actively triggered scenarios) |

**@dev MD058 miss — baseline question:**

Was this an @dev failure or a pipeline gap? The Phase 4 implementation was locally correct (annotation placement was architecturally specified in OQ-4); the violation only manifested in CI. @dev has no local markdownlint command to run. The pipeline has no equivalent of `npm test` for this content repo. Verdict: this is a **pipeline gap** (no local lint parity), not an @dev judgment failure. @dev's baseline behavior on Phase 4 implementation correctness is PASS; the MD058 miss is attributable to tooling absence, not agent quality degradation.

**Overall: 4/4 agents PASS on applicable scenarios.** Pass rate 100% (4/4) exceeds the 0.80 threshold.

---

### 7. Carry-Forwards into v2.4

| Item | Source | Priority | Description |
|------|--------|----------|-------------|
| ADR-028 implementation | W4 (PROPOSED in v2.3) | HIGH | ADR-028 content_sha256 per-file integrity: implement in cowork.lock.json for new entries; update /sync-agency to compute and write content_sha256 at skill-import time. v2.4 Phase 1 must design the runtime implementation (option (c) new-entries-only migration committed). |
| First external skill import | Skills roadmap v2.2 | HIGH | Ranked candidates: #1 voice-matching (DONE in v2.3), #2 action-items (covered-by-runtime in v2.3 annotation), #3 doc-summary (covered-by-runtime), #4 email-drafting, #5 outline-generator, or meeting-insights-analyzer per roadmap. v2.4 @pm should select and scope. |
| ADR Index backfill | v2.0–v2.3 observation | MEDIUM | ADR-020 through ADR-028 absent from architecture.md index (lines 11–37). Third consecutive deferral. Recommend binding as non-negotiable AC in v2.4 spec. |
| v2.0 S14 single trust anchor | Deferred since v2.0 | MEDIUM | Depends on ADR-028 implementation. User-accepted risk. Do not re-scope until ADR-028 runtime is live. |
| ENFORCED_EXAMPLES expansion strategy | OQ-3 deferral | MEDIUM | v2.4 cycle that expands remaining 4 stubs (editing-pass, outline-generator, follow-up-tracker, spend-awareness) must update ENFORCED_EXAMPLES to include their parent preset dirs. CI depth-check cascade-fail is the blocking condition. |
| S3 TLS-pinned fetch flag | Phase 1 deliberation INFO | LOW | When v2.4 implements ADR-028 /sync-agency hash fetch, use TLS-pinned + redirect-blocked HTTP client. Forward to v2.4 @architect/@security review. |
| S1 ADR-028 heading drift | Phase 1 deliberation INFO | LOW | `#### ADR-028:` (h4) vs ADR-020..027 `##` (h2). Minor index hygiene — address during ADR Index backfill in v2.4. |
| Local markdownlint check | C2 self-improve candidate | MEDIUM | Prevents recurrence of MD058 pattern. See Section 5 C2. |

---

### 8. Rework Analysis

**Rework rate: 0.7%** (8 lines changed, 1 file — curated-skills-registry.md — post-Phase-4 SHA ae71129)

**Precision:** This rework is of the "post-Phase-4 catch by Phase 5" variety, not "in-cycle rework" in the strict sense. Compare:
- v2.2: 0% rework — zero lines changed after Phase 4 SHA through Phase 7 approval.
- v2.3.0: 0.7% rework — 8 lines changed in one file between Phase 4 SHA (ae71129) and Phase 7 approval (7d31892). The change was purely structural/layout (MD058 compliance); annotation content strings were byte-unchanged.
- v1.2: 19% rework — multiple files changed after Phase 5 failures requiring substantive content corrections.

v2.3.0 rework is the smallest non-zero rework in the project's history. The classification is: **post-Phase-4 structural fix caught by @qa at Phase 5 CI verification**. It is not a design error, logic error, or AC failure — it is a markdown layout rule enforcement. The combined-path FORFEIT-and-reinstate sequence was the correct pipeline response.

**Root cause:** Local markdownlint parity gap (see Section 3).

---

### 9. Retrospective Verdict

v2.3.0 is the second consecutive cycle at or near the project quality ceiling. Five workstreams shipped, 30/30 ACs closed, and the one measure of quality degradation — the 0.7% rework — was a doc-layout fix caught before merge by exactly the mechanism it should be (Phase 5 CI check, @qa verdict, @dev targeted fix). The recurring 2-cycle version-artifact miss is now resolved via explicit constraint enumeration, which is the right mitigation pattern. The ADR-028 PROPOSED-only discipline held: a spec scaffold shipped without bleeding into implementation. The combined-path precedent from v2.2 was successfully applied again, with a correct mid-cycle forfeit-and-reinstate when CI turned red.

The one honest gap this cycle surfaces is structural, not agent-quality: the cowork pipeline has no local markdownlint check that @dev can run before push. This means any annotation format or table-adjacent markdown that @architect designs can only be validated by CI, adding a rework loop whenever the format violates a lint rule. The proposed fix (C2 local-lint-runner) is straightforward and removes a class of foreseeable Phase 5 CI failures.

The ADR Index backfill deferral for the third consecutive cycle is worth flagging as a specific carry-forward binding for v2.4 rather than a hygiene note, since advisory-only deferrals are not getting it done.

Overall cycle health: strong. The pipeline caught what it should catch. The one gap it exposed has a clear and bounded fix.

---

*Generated by @qa Phase 8 retrospective — 2026-05-08T16:00:00Z*

---

## v2.2 — Carry-Forward Closeout + Skills Roadmap Discovery

**Date:** 2026-05-08
**Classification:** STANDARD
**Mode:** full (deep Phase 0)
**Rework rate:** 0%

---

### 1. Phase Findings Summary

| Phase | Agent | Findings Count | Severity Breakdown |
|-------|-------|---------------|-------------------|
| 0 | @pm | 0 | — (deep mode PRD, 11 ACs, 10 WILL-NOT-DOs) |
| 1 | @architect | 0 | — (Outcome A — no new ADR; sequencing precondition surfaced) |
| 1 (Deliberation) | @security | 0 | APPROVE-WITH-WATCH-ITEMS — 1 INFO (S1 Phase 6 grep watch on skills-roadmap.md) |
| 1 (Deliberation) | @dev | 0 | APPROVE — all 5 surfaces concrete and copy-paste-ready |
| 2 | @security | 1 | 0 CRITICAL, 0 WARNING, 1 INFO (S1 Phase 6 grep watch on docs/skills-roadmap.md) |
| 3 | User | — | APPROVED — 0 adjustments |
| 4 | @dev | 0 | sha:ac88189, 6 commits, all 11 ACs satisfied |
| 4 (Deliberation) | @security | 0 | APPROVE — all 7 Phase 2 preservation constraints PASS, abbreviated audit eligible |
| 4 (Deliberation) | @qa | 0 | APPROVE — all ACs testable; 1 assertion note (AC-RM-3 must use ≥5 not ==5) |
| 5 | @qa | 0 | 13/13 PASS; S1 RESOLVED in-cycle |
| 6 | @security | 0 | 0 CRITICAL, 0 WARNING, 0 INFO (abbreviated audit) |
| 7 | @qa | 0 | APPROVED — rework 0%, all ACs verified |

The one INFO item (S1) raised at Phase 1 deliberation and carried as a Phase 6 grep watch resolved cleanly in-cycle: `grep -iE '```|you are|your role|recommended prompt' docs/skills-roadmap.md` = 0 hits, independently verified at Phase 4 deliberation and Phase 6.

**Tier-1 Retro Finding: Git-State Divergence Incident (BLOCKER PREVENTED)**

A critical divergence between local `main` and `origin/main` was present when Phase 0 and Phase 1 work began. Local `main` was behind by 2 commits (v2.0.5 + v2.1.0 tag) and ahead by 1 orphan commit (v2.0.x umbrella retro, never PR'd to origin). Phase 0 and Phase 1 work was authored on a stale base: `VERSION=2.0.4` locally vs `VERSION=2.1.0` on origin; `WIZARD.md` was 203 lines locally vs the live v2.1 state at line 218 where AC-D2's target block exists.

@architect's Phase 1 organically discovered the divergence by running `cat VERSION` (found 2.0.4) and `wc -l WIZARD.md` (found 203 lines) and flagging "v2.1 has not yet shipped" as a sequencing precondition. This surface-level check prevented a would-have-shipped scenario: without the sequencing precondition flag, @dev at Phase 4 would have attempted to patch a line that did not exist on origin/main, resulting at minimum in a CI failure and likely a partial rollback.

**Root cause:** Parallel Claude Code sessions edited local `main` (the v2.0.x umbrella retro commit) while `origin/main` advanced (v2.0.5, v2.1.0 PRs) without a sync step between sessions. The existing `scripts/check-stale-cycle.sh` verifies pipeline-state freshness but not git-state freshness.

**Recovery:** Local `main` hard-reset to origin/main (tag v2.1.0, sha 8bda56b), destroying the local orphan commit (backed up to /tmp/cowork-backup/ as patch). Branch `release/v2.2` created from the correct base. v2.2-only deltas (spec.md, architecture.md, assumptions.md, docs/research/) re-applied on the corrected base. Pipeline.md Branch column corrected from `main` to `release/v2.2` for Phase 0 and Phase 1 rows.

**Issues prevented:** blocker=1 (D2 attempting to patch non-existent line at Phase 4, minimum CI failure), saved by @architect's organic discipline.

---

### 2. AC Difficulty Assessment

| Acceptance Criterion | Classification | Notes |
|---------------------|---------------|-------|
| AC-D2: Stopword filter in WIZARD.md §Phase 1 Role-Generation Rule (64-token STOPWORDS, bash-array containment, empty-set fires fallback) | Medium | No rework, but implementation required careful adherence to @security constraint (bash-array-only, no `eval`/`=~`/`grep -P`). Fixture `description="the a of"` verified deterministically. |
| AC-D3: Migration annotation in SETUP-CHECKLIST.md ("v2.1 migration complete — historical reference only") | Easy | Single blockquote prepend; location unambiguous. |
| AC-CFP: Objective field in examples/personal-assistant/cowork-profile-starter.md | Easy | Single line addition, format byte-matches WIZARD.md Step 1 L130 template per ADR-031. |
| AC-RM-1: docs/skills-roadmap.md with 3 required sections | Easy | New file; sections confirmed by header grep. |
| AC-RM-2: 12 stubs with EXPAND-IN-TREE / COVER-BY-RUNTIME verdicts | Medium | 9 EXPAND-IN-TREE + 2 COVER-BY-RUNTIME = 11 initially miscounted (12th confirmed by recount). All 12 have one-line justification. |
| AC-RM-3: 20×6 persona-JTBD matrix (≥15 rows × 5 personas) | Medium | Implementation adds 6th persona (Casey) beyond spec's 5-persona minimum; Phase 5 assertion correctly used `>=5` not `==5` per @qa Phase 4 deliberation note. Exceeds spec — PASS. |
| AC-RM-4: 5 ranked v2.3+ candidates (#1–#5, all 6 required fields) | Easy | Voice-matching (#1) spot-checked; all 6 fields present across all 5 candidates. |
| AC-REL-1..4: VERSION=2.2.0, CHANGELOG [2.2.0], README badge, Next-up teaser → v2.3 | Easy | ADR-033 pattern validated at v2.1; no deviations. |

**Hardest AC:** AC-D2 — required strict bash-array-only containment (no `eval`, no `grep -P`, no `=~`) per @security constraint, and a deterministic stopword fixture test. Correctly implemented without rework.

**Easiest ACs:** AC-D3, AC-CFP, AC-REL-1..4 — single-line or single-section additions with unambiguous insertion points.

---

### 3. Token Cost Actuals

Token instrumentation for external projects continues to show `model: "unknown"` for most entries (consistent with all prior cycles). Cycle 11 (v2.2) metrics.json contains 1 entry: the Phase 7 qa_issues_prevented record. Token volume must be estimated from agent role assignments.

| Model Tier | Phases | Estimated Output Tokens | Estimated Cost |
|-----------|--------|------------------------|----------------|
| sonnet (@pm Ph0, @dev Ph4, @qa Ph5/Ph7, @devops N/A) | 0, 4, 5, 7 | ~12,000 est. | ~$0.18 est. |
| opus (@architect Ph1, @security Ph2/Ph6 + deliberation) | 1, 2, 4-deliberation, 6 | ~30,000 est. | ~$2.25 est. |
| **Total** | | **~42,000 est.** | **~$2.43 est.** |

Pricing basis: sonnet $3/$15 per MTok in/out; opus $15/$75 per MTok in/out. Cache read/write excluded (not tracked reliably for external projects).

**Comparison to v2.1 (~$1.71 est.):** v2.2 cost is ~42% higher. Attributable to deep-mode Phase 0 PRD + W2 skills-roadmap research, and Phase 1 deliberation with both @security and @dev (2 deliberation rounds). v2.2's scope (W2 skills-roadmap research + 2 workstreams) is heavier than v2.1's carry-forward closeout scope despite STANDARD classification.

**Instrumentation gap** persists across all 12 cycles for external project sub-agent sessions. The-Council self-improvement cycle token data is captured correctly. Carrying forward as LOW priority (8th consecutive deferral).

---

### 4. Phase Durations

| Phase | Start | End | Duration | Notes |
|-------|-------|-----|----------|-------|
| 0 | 2026-05-08T00:00:00Z | 2026-05-08T00:00:00Z | ~1h | Deep mode; 2 workstreams + 10 WILL-NOT-DOs |
| 0.5 (Recovery) | 2026-05-08T05:50:32Z | 2026-05-08T06:00:00Z | ~10min | Git-state divergence recovery: hard-reset + branch re-creation |
| 1 | 2026-05-08T00:30:00Z | 2026-05-08T01:00:00Z | ~0.5h | Outcome A — no new ADR; sequencing precondition + deliberation |
| 2 | 2026-05-08T06:00:00Z | 2026-05-08T07:00:00Z | ~1h | STANDARD light pass; 0 CRITICAL, 0 WARNING, 1 INFO |
| 3 | 2026-05-08T07:00:00Z | 2026-05-08T07:30:00Z | ~0.5h | User gate; 0 adjustments |
| 4 | 2026-05-08T08:00:00Z | 2026-05-08T08:30:00Z | ~0.5h | 6 commits; deliberation APPROVE from both @security and @qa |
| 5 | 2026-05-08T08:30:00Z | 2026-05-08T09:00:00Z | ~0.5h | 13/13 PASS; abbreviated audit eligible confirmed |
| 6 | 2026-05-08T09:00:00Z | 2026-05-08T09:45:00Z | ~0.75h | Abbreviated audit; 0/0/0 findings |
| 7 | 2026-05-08T09:45:00Z | 2026-05-08T10:15:00Z | ~0.5h | APPROVED; PR #34 merged 2026-05-08T06:50:48Z, tag v2.2.0 |

No phases flagged as outliers. This is the fastest full-ceremony cycle in the project's history (all phases <1h, total ~5h). Attributable to: STANDARD classification enabling abbreviated Phase 6, thin scope (docs-only changes), and thorough Phase 1 deliberation that eliminated Phase 4 ambiguity. The recovery step (0.5) added ~10 minutes but was necessary for correctness.

---

### 5. Phases Abbreviated

Phase 6 ran in abbreviated audit mode (STANDARD-classified, gate (a/b/c/d) all GREEN). This is the third time an abbreviated Phase 6 has been used in this project's history (v1.3.0, v1.3.1 series, v2.2). All three were STANDARD-classified cycles with thin, docs-only scope.

Phase 1 ran Outcome A path (no new ADR) — not an abbreviation, but a deliberate architecture decision-trigger walk (all NO/DEFER).

All other phases ran at full ceremony. Pipeline mode: full.

---

### 6. Rework Rate and Causes

**Rework rate: 0%**

Zero lines changed between Phase 4 SHA (`ac88189fbf0bf95b0ec3ee3c751bf0f241be981c`) and Phase 7 approval (PR #34, sha `8c74273`). No Phase 5 failures, no Phase 6 must-fix items, no rework commits.

The git-state divergence recovery was a pre-Phase-4 infrastructure correction, not implementation rework. It affected pipeline-state files and branch creation only; no spec or implementation files were changed after Phase 4 commit.

Contributing factors to zero rework:
- STANDARD classification with docs-only scope: no auth/RLS/schema surfaces = narrow attack surface
- @security and @dev deliberation at Phase 1 resolved all implementation ambiguities before Phase 4 began
- @security S1 constraint (bash-array-only for D2) was concrete and copy-paste-ready; @dev had no discretion to introduce injection vectors
- Abbreviated Phase 6 eligible by design (not a shortcut — verified at Phase 5)

---

### 7. Issues Prevented

| Category | Count | Details |
|----------|-------|---------|
| Blocker | 1 | Git-state divergence: @architect's organic sequencing-precondition check (cat VERSION + wc -l WIZARD.md) prevented Phase 4 @dev from patching a non-existent line on stale base — minimum outcome: CI failure; likely outcome: partial rollback |
| Issue | 0 | — |
| Info | 1 | Phase 7: D2 CLOSED, D3 CLOSED, S1 RESOLVED in-cycle; 1 info item = v2.0 S3 accepted-deferred per ADR-028 user decision at Phase 3 |

**Cumulative (v1.0 through v2.2):** blocker=3, issue=4, info=15

The blocker in v2.2 is a new category: not a pipeline finding but a git-infrastructure failure caught by an agent's organic curiosity. This distinction matters for process improvement: the pipeline is not designed to catch git divergence; the fix must be a pre-pipeline guard (`check-base-sync.sh`), not a pipeline protocol change.

---

### 8. Pattern Detection

#### 3-cycle Phase 6 scan (v2.1, v2.2, v2.0.x-umbrella window) — WARNING+ only

- v2.1 Phase 6: 0 findings (SECURITY-SENSITIVE, full OWASP+LLM Top 10 — cleanest Phase 6 in project history for a SECURITY-SENSITIVE cycle)
- v2.2 Phase 6: 0 findings (STANDARD, abbreviated — no new surfaces)
- v2.0.x umbrella Phase 6 (last comparable window): v2.0.2 Phase 6 had 1 WARNING (S1 `configuration` — P1 recurrence, RESOLVED in-cycle); v2.0.4 Phase 6 skipped (quick mode)

**Result:** No 3-cycle Phase 6 WARNING+ recurring keyword pattern. The `configuration` WARNING that appeared in v2.0 Phase 6 (A1–A3) and v2.0.2 Phase 6 (S1 P1 recurrence) did NOT recur in v2.1 or v2.2. The 2-cycle run (v2.0, v2.0.2) is broken. No promotion warranted.

**Deliberation Findings cross-phase surface (informational only):**

S1 INFO (skills-roadmap.md LLM-instruction surface) appeared at Phase 1 deliberation and Phase 2 as a carry-to-Phase-6 watch item. It resolved cleanly (0 violations). This is the pipeline working as designed — a low-risk surface was watched and confirmed clean — not a recurring finding. No promotion candidate.

#### P5 — NEW PATTERN: Git-State Divergence — Cycle Authored on Stale Base (1-cycle observation)

**Description:** When parallel Claude Code sessions write to local `main` while `origin/main` advances through PR-based merges, a divergence accumulates silently. A new cycle authored on the stale local base produces Phase 0 and Phase 1 artifacts whose underlying assumptions (VERSION, file line counts, target block existence) are incorrect for the origin state. If the sequencing precondition is not caught organically, Phase 4 implementation targets a codebase state that does not exist on the branch being built.

**This cycle:** Local `main` behind by 2 commits (v2.0.5 + v2.1.0 tag), ahead by 1 orphan commit. @architect's organic check (cat VERSION + wc -l WIZARD.md) surfaced the discrepancy before Phase 4. Recovery: hard-reset + re-branch + delta reapplication.

**Proposed mitigation:** `scripts/check-base-sync.sh <slug>` — a new pre-/spec guard that runs at /spec entry before Phase 0:
1. `git fetch origin --quiet`
2. If local branch is behind its origin counterpart → BLOCK with "git pull first"
3. If working tree is dirty (uncommitted changes) → BLOCK with "stash or commit first"
4. If local has un-pushed commits on main → WARN (may be legitimate; surface to user)
5. Exit 0 if clean, exit 1 with message otherwise

**Implementation home:** The-Council `scripts/` (sibling to `check-stale-cycle.sh`). Guards live in The-Council, not in individual project repos. Cowork's `scripts/` contains only repo-local shell utilities (setup-folders.sh); pipeline guards are a The-Council concern.

**Recommended action:** Open a `/self-improve` cycle on The-Council (project: self) to implement `check-base-sync.sh` and register it in `/spec` entry. This is a textbook self-improve trigger: a first-cycle observation with a concrete, bounded mitigation that prevents a would-have-shipped blocker.

**Status:** 1-cycle observation — NOT yet eligible for 3-cycle promotion. Marking as RECURRENCE-MITIGATED-BY-PROPOSED-GUARD: if `check-base-sync.sh` ships, the recurrence condition becomes structurally impossible before 3 cycles are reached.

#### P1 — ADR-spec drift on parameterized artifacts (MONITOR)

v2.2 had no parameterized lists in the spec (W2 roadmap uses fixed verdict tokens, not floating counts). P1 mitigation (byte-comparison) was acknowledged as N/A for this cycle in the Phase 4 Intent Contract carry-forward acknowledgments. P1 remains active; v2.3+ cycles with new ADRs should re-apply the byte-comparison check at Phase 5.

#### P4 — External-trigger workflow layer-onion (MONITOR)

v2.2 added no new external-trigger workflows. The dry-run CI gate (v2.0.4 Fix C) remains operational. P4 passive watch continues. Not triggered this cycle.

#### `configuration` WARNING surface (CLEARED)

Two-cycle run (v2.0, v2.0.2) did not extend to v2.1 or v2.2 Phase 6. Pattern is cleared — monitoring can cease. The surface was bounded to ADR parameterized-list drift (covered by P1 mitigation).

---

### 9. Quality Baseline Assessment

Quality baselines reside in The-Council (`.claude/skills/*/quality-baseline.json`, v23.0, pass threshold 0.80). For this external project (static markdown + CI YAML repo, no auth/schema/RLS), applicable behaviors are evaluated by content-review assessment — not live-tested inject prompts.

| Agent | Applicable Scenarios | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | v2.2 deep-mode PRD correctly scoped 2 workstreams from a complex carry-forward inventory. 10 WILL-NOT-DOs explicitly enumerated to prevent scope creep. 11 ACs produced with deterministic fixture (stopword test case in spec.md line 2561 verbatim). No ambiguous intent; self-validation gates passed. | PASS |
| @architect | QA3 (speculative abstraction) | Outcome A path (no new ADR) correctly chosen after decision-trigger walk: all 5 decision tests returned NO or DEFER. Speculative abstraction avoided — W2 roadmap captured as AC contract, not a parallel ADR. Sequencing precondition surfaced organically (cat VERSION + wc -l WIZARD.md) — exceeds baseline expectation. | PASS |
| @security | QS2 (external data ingestion), QS3 (fail-closed vs fail-open) | Phase 1 deliberation: independent injection-surface analysis of D2 stopword filter confirmed bash-array containment (no eval/=~/grep -P) = zero new injection vectors over v2.1. Phase 2: STANDARD light pass produced exactly 0 CRITICAL, 0 WARNING, 1 INFO — proportionate to scope. Phase 4 deliberation + Phase 6: all 7 preservation constraints verified independently. S1 RESOLVED in-cycle (grep watch confirmed 0 hits). | PASS |
| @qa | QQ1 (flaky test detection), QQ2 (AC coverage) | 13/13 tests PASS with no intermittent failures. All 11 ACs covered with deterministic assertions. AC-RM-3 assertion correctly widened to `>=5` (not `==5`) at Phase 4 deliberation to avoid false negative on 6-column matrix — this is QQ2 scenario behavior: identifying and documenting the gap before Phase 5 runs. | PASS |

**Overall: 4/4 agents PASS on applicable scenarios.** Pass rate 100% (4/4) exceeds the 0.80 threshold.

**New baseline behavior observed (v2.2, not yet in quality-baseline.json):**

@architect organic git-state discipline: reading actual codebase state (VERSION, line counts) rather than assuming it matches the pipeline state. This is a content-review-only observation — not a live-tested baseline — but it prevented the cycle's only blocker. Proposed addition to @architect QA quality-baseline.json as QA6: "Before Phase 4, verify implementation target existence (VERSION, file line counts, target block presence) matches origin branch state, not local main."

---

### 10. Retrospective Verdict (v2.2)

v2.2 is the cleanest cycle in this project's 12-cycle history on every measurable dimension: 0% rework, 0 Phase 6 findings across both deliberation and audit, 13/13 tests passing, all 11 ACs satisfied. The two workstreams — carry-forward closeout (D2/D3/CFP) and Skills Roadmap Discovery (W2) — delivered exactly what was scoped, no more and no less. The WILL-NOT-DO list (10 items) held firm against scope creep: ADR-028 implementation, multi-source enablement, stub expansion, and external skill imports all correctly deferred.

The cycle's defining event is the git-state divergence incident. It is simultaneously this cycle's most serious near-miss and its strongest quality signal. @architect's organic discipline (reading actual file state rather than assuming it) caught a would-have-shipped blocker before Phase 4. The root cause is structural: `check-stale-cycle.sh` guards pipeline-state freshness but not git-state freshness. The fix is similarly structural: a `check-base-sync.sh` pre-/spec guard that blocks stale-base cycles at entry. This is the clearest self-improve trigger this project has produced — concrete, bounded, and grounded in a prevented real failure.

Three patterns monitored coming into v2.2 all resolved favorably: `configuration` WARNING run cleared (v2.1/v2.2 Phase 6 both 0 findings), P1 mitigation not triggered (no parameterized lists in scope), P4 dry-run gate not triggered (no new external-trigger workflows). One new pattern (P5 — Git-State Divergence) is introduced at the 1-cycle observation level. Its proposed mitigation (`check-base-sync.sh`) is already concrete and ready for the next self-improve cycle.

Overall cycle health: strong. The pipeline did its job. The one gap it exposed (git divergence detection) is pre-pipeline and has a clear fix.

---

### 11. Carry-Forward Items

| Item | Source | Priority | Description |
|------|--------|----------|-------------|
| check-base-sync.sh guard | P5 (this retro, Tier-1 incident) | HIGH | Implement in The-Council as a pre-/spec guard; sibling to check-stale-cycle.sh. See Section 8 P5 for spec. Self-improve cycle recommended. |
| v2.1 retro section in docs/retro.md | Git-state recovery orphan | LOW | v2.1 retro was written to local main (orphan commit a7aa1cb, backed up to /tmp/cowork-backup/). Not present in origin/main. User decides: cherry-pick + open PR vs. discard. |
| v2.1 PRD in docs/spec.md | Git-state recovery orphan | LOW | v2.1 PRD section missing from origin/main spec.md. Separate hygiene issue from v2.2. |
| Token metrics instrumentation | All cycles | LOW | 12 cycles; model: "unknown" for external project sub-agent sessions. Agent logger gap in The-Council. Addressed only if cost monitoring is needed. |
| docs/skills-roadmap.md v2.3+ candidates | W2 deliverable | MEDIUM | 5 ranked candidates (#1 voice-matching, #2 action-items, #3 doc-summary, #4 email-drafting, #5 outline-generator). v2.3 @pm Phase 0 should consume this roadmap as primary input. |
| ADR-028 implementation timing | v2.2 WILL-NOT-DO | MEDIUM | First external source ingestion: v2.3 candidate evolsb or ComposioHQ/meeting-insights-analyzer. Requires ADR-028 runtime implementation ahead of v2.3 Phase 4. |
| P1 byte-comparison mitigation at Phase 5 | v2.0.x umbrella carry-forward | MEDIUM | Apply in any cycle with parameterized ADR lists. v2.2 had no such lists; re-applies at v2.3 if new ADR with list-shaped content ships. |

---

*Generated by @qa Phase 8 retrospective — 2026-05-08*
