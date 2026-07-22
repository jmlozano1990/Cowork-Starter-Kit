# QA Report — v2.18.0 "The Substrate (slim)"

## Phase: 5
## Date: 2026-07-22T04:03:54Z
## Status: PASS

### Unit Tests
- Total: N/A — static markdown/JSON/CI-config repo, no application runtime; verification is via
  grep/fixture-based ACs and CI job simulation (see below), not Vitest/pytest-style unit tests.

### Fixture / Firing-Control Tests
- Total: 5 (F2-1, F2-2, F2-3 canonicalization fixtures + MF-S-1 registry drift fault-injection +
  CI job local simulation)
- Passing: 5
- Failing: 0
- All firing controls independently reproduced by @qa (not trusting prior agent narrative or the
  CI job's own self-test): RED legs confirmed real (0 raw-scan hits), catch/flag legs confirmed
  correct exit codes (1/1/2), registry fault-injection confirmed to fail on a poisoned scratch
  copy and pass on the real registry.

### Spec AC Coverage
- Total: 27 (F1:4, F2:4, F3:4, F4:6, F5:4, XFER:5)
- Passing: 27
- Failing: 0

### Security Review MUST-FIX Coverage
- Total: 5 (MF-S-1..5)
- Passing: 5
- Failing: 0

### CI Simulation
- canonicalize-scan-check (POOL): 27/27 skills/*/SKILL.md clean
- canonicalize-scan-check (ENFORCED_EXAMPLES): 21/21 example SKILL.md clean
- registry-sha256-check: 28/28 Tier-1 rows verified against pool files
- No pip/npm install, no curl/wget in new jobs
- No new `uses:` action / SHA in quality.yml diff (reuses existing pinned checkout)
- YAML parse: valid
- shellcheck (scripts/canonicalize-scan.sh, scripts/registry-hash.sh): 0 findings
- markdownlint (10 changed non-docs/ .md files): 0 issues

### §Maturation Path
- Self-grep: 36/36/36 (baseline 32 + 4 new ADRs × 3 headers) — confirmed exact.

### Deny-list / Byte-unchanged Checks
- .cowork-allowlist.json, cowork.lock.json, selection-presets.md, CONTRIBUTING.md:129 — all
  byte-unchanged (0-line diff).

### Negative Verification (Out-of-Scope absence)
- 0 LLM-judge, live-Confidante-integration, or community-tier-opening code in the diff
  (all matches are scope-boundary prose statements, individually inspected).

### Issues Found
- [ ] **ISSUE — scan-of-record `--section "## Example"` narrowing.** Reproduced: a forbidden-
      imperative token placed in `## Instructions` (or any non-Example section) escapes the CI
      gate of record (exit 0 PASS) while a whole-file raw scan would catch it (fixture built,
      tested, and removed this session). @dev's in-script SCOPE NOTE argues this matches
      CONTRIBUTING.md:129's own stated threat model (`## Example` = pasted/AI-executed content).
      Handed to @security for an explicit Phase-6 ruling — not adjudicated by @qa.
- [ ] **INFO — no `C-v2.18-N` binding Phase-4 constraints section** in docs/spec.md, unlike the
      v2.17.0 precedent (`C-v2.17-1..10`). Coverage is distributed across 27 ACs + 5 MF-S items
      instead. Convention-consistency carry-forward, not a coverage gap.
- [ ] **INFO — VERSION file unbumped** (still `2.17.0`). WIZARD.md's install-manifest now stamps
      `kit_version` from VERSION at install time; must be bumped to `2.18.0` before merge or every
      shipped manifest will misrecord the kit version. Confirm at Phase 7 / release step.
- [ ] **INFO — MF-S-4's AC-F3-2 fixture is explicitly non-executable** (prose walkthrough +
      grep-proxy), consistent with the security review's own acknowledged honest limit
      (inspection-class re-scan, cannot prove it fires on every real hand-edit).

### Verdict
**APPROVED for Phase 6 — PASS-WITH-NOTES.** 0 blockers. All 27 ACs and all 5 security-review
MUST-FIX items verified with real, independently-reproduced evidence — no check-that-cannot-fail
found anywhere in the substrate. One ISSUE (scan-of-record section-narrowing) is characterized
with a reproduced fixture and handed to @security for Phase-6 ruling. Three INFO items recorded
as carry-forwards, none blocking.

qa_issues_prevented: blocker=0 issue=1 info=3
