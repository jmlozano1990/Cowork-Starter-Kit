# QA Report — Cowork Starter Kit v2.12.0 "Skill Studio — Increment 2a (Discoverability)"

## Phase: 5+6+7 (combined) + 8 filing
## Date: 2026-07-19
## Verdict: APPROVED (on re-review of 214393b; original 5406cb9 REJECTED)

> **Filing note:** @qa ran fully pin-inheritance-guard-blocked this cycle (author-and-return), so this per-version report was filed by the orchestrator at retro time from @qa's returned content + the pipeline Phase Log + the security-review Phase-5 addendum — closing the artifact-per-version convention gap the retro flagged. The authoritative QA narrative is `docs/retro.md` §[v2.12.0].

## Headline

The independent Phase-5 @qa gate **REJECTED** the first Phase-4 tree (`5406cb9`) on a genuine security BLOCKER (QA-1) that the mandatory Phase-2 review, the Phase-4 build, AND the orchestrator's independent Phase-4 re-verification all missed — then **APPROVED** the fix (`214393b`) after re-verifying with the exact fixtures that broke the prior gate. `qa_issues_prevented: blocker=1 (caught+fixed), issue=0, info=2 (closed)`.

## Findings

| ID | Severity | Status | Summary |
|----|----------|--------|---------|
| QA-1 | BLOCKER | FIXED (214393b) | AC-SEC-S1 slug gate `grep -qE '^…$'` is line-oriented; a two-line slug (`decision-log`\n`x -->evil<!--`) passes (first line matches) then breaks out of the AC-P1-1 marker → injects visible text into the auto-loaded `CLAUDE.md`. Fix: whole-string `[[ "$slug" =~ ^[a-z0-9][a-z0-9-]*$ ]]`. Downstream AC-SAFE-2 corruption now structurally unreachable. |
| QA-2 | INFO | CLOSED (214393b) | AC-SURF-4: 6/8 AC-SAFE items had a dedicated "Safety this loop enforces" bullet; AC-SAFE-2 (idempotency) + AC-SAFE-4 (surfaced-trigger) bullets added → fully satisfied. |
| QA-3 | INFO | CLOSED (214393b) | AC-P1-5 overclaimed `CLAUDE.md` proactive-block inclusion for a setup-hook-generated skill; wording corrected — the block lands on standalone re-invoke (CLAUDE.md doesn't exist mid-interview when the hook fires), generic installed-skills line only at setup completion. |

## AC-by-AC (26 numbered ACs + WS-SEC + WS-PHASE1)

24 PASS · AC-SURF-4 PARTIAL→PASS after QA-2 fix · AC-SEC-S1 FAIL→PASS after QA-1 fix. WS-SETUP-HOOK ×5 PASS; WS-SURFACING ×5 PASS (SURF-4 after fix); WS-SAFETY ×8 PASS; WS-RELEASE ×7 PASS; WS-PHASE1 AC-P1-1/2/3/5 PASS, AC-P1-4 DEFERRED (sound — Step-7a population would widen the AC-SEC-S7 non-regression envelope; @qa concurred); WS-SEC AC-SEC-S1 (fixed) + S2–S7 PASS.

## MUST-VERIFY functional simulations (own fixtures, real bash)

- **AC-SEC-S1 (fixed):** shipped `[[ =~ ]]` gate rejects `decision-log`\n`x -->evil<!--`, `good123`\n`rm -rf /`, and all single-line malicious cases; accepts `decision-log`/`good123`. Orchestrator + @qa both re-verified with fresh fixtures.
- **AC-SEC-S2:** block-body scan = 1 on a dirty block; range-exclude anti-implementation = 0 (the check-that-cannot-fail variant); clean block = 0.
- **AC-SEC-S3:** literal-string compose of `$(touch /tmp/probe)` → probe absent; eval negative control → probe created.
- **AC-SEC-S4:** kit-checkout (`WIZARD.md` at root) → guard refuses, root `CLAUDE.md` word count unchanged (CI green); non-kit → proceeds.
- **AC-SEC-S5:** confirm-before-write + never-auto-invoke + no-raw-goal-echo instructions present (grep ≥1). Honest limit: grep proves instruction presence, not LLM runtime honoring (deferred v2.13 eval loop).
- **AC-SEC-S6:** absent `CLAUDE.md` → bound string `No CLAUDE.md workspace-instructions file found` emitted, 0 files created.
- **AC-SAFE-2:** two runs for the same slug → marker count = 1 (update-in-place); naive append → 2.

## Non-regression / CI-blockers (all PASS)

markdownlint 0; version-consistency `2.12.0` (VERSION == README badge == topmost dated CHANGELOG header); `git diff main...HEAD -- WIZARD.md` confined to the Path C zero-coverage branch (Attribution-rule count = 1); `git diff -- CLAUDE.md .github/workflows/` = 0 (root CLAUDE.md untouched, its safety-rule + word-count CI jobs stay green); README "Next up" byte-unchanged; skill-studio not globbed by skill-depth-check/wizard-consistency-check (CI-exemption LIVE, Skill Depth Check green on PR #71). PR #71 CI: 50 pass / 2 skip / 0 fail.

## Quality baseline (this cycle)

- @pm PASS — 25 ACs pre-bound with positive-check + negative-control per the directive.
- @architect PASS — 2 ADRs with §Maturation Path; decisive KDQ-1 resolution.
- @security PASS-WITH-NOTE — strong review that caught the sharp slug-marker-breakout surface but MISSED the embedded-newline sub-case inside the mechanism it specified (an honest "good but not complete" signal; recorded in retro §8 Pattern #2).
- @dev PASS — all safety clauses shipped as real bash; sound AC-P1-4 deferral.
- @qa PASS — fresh-fixture discipline caught the BLOCKER two prior passes missed (the cycle's strongest data point for the independent gate).
