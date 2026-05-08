# Security Review — v2.3.1 (Phase 1 Round 1 Deliberation)

**Date:** 2026-05-08T18:05:00Z
**Reviewer:** @security
**Scope:** Phase 1 deliberation on `docs/architecture.md` § "v2.3.1 — Stub Completion Architecture" (architect's design landing for the 8-stub completion cycle).
**Classification (architect-asserted):** STANDARD — content-only patch, no auth/RLS/payments/external-API/schema surface.

**Verdict**: APPROVE-WITH-WATCH-ITEMS

**Severity counts**: 0 CRITICAL · 1 WARNING · 4 INFO

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S-v2.3.1-1 | WARNING | 1 | configuration | Spec OQ-v2.3.1-5 (ENFORCED_PRESETS coverage) is silently re-numbered/dropped in the architecture — the architect's OQ-v2.3.1-5 ruling is on line-count band, not on whether writing/creative/business-admin/personal-assistant are in the CI allowlist. Confirmed by direct read of `.github/workflows/quality.yml`: `ENFORCED_EXAMPLES="study research project-management"` — all 4 v2.3.1 target presets are OUT of the CI allowlist. Watch-item, not a blocker (deny-list correctly keeps `quality.yml` byte-unchanged per WILL-NOT-DO #9; @qa grep verifiers under C-v2.3.1-3 enforce 9-section structure at Phase 5 even though CI does not). |
| S-v2.3.1-2 | INFO | 1 | none | Reference-template trigger-bullet count claim is partially incorrect: voice-matching has 3 `trigger_examples`, daily-briefing has 3, risk-assessment has 4, meeting-notes has 5. Architect's "exactly 4" rule for `trigger_examples` (C-v2.3.1-2 + PRD AC-Sn-2) is therefore TIGHTER than the reference set, not extracted from it. Defensible policy choice (LLM01 mitigation via concrete trigger surface) — not a defect. Recommendation: leave the rule as-is; flag the reference-extraction wording as imprecise. |
| S-v2.3.1-3 | INFO | 1 | none | spend-awareness Boundaries (C-v2.3.1-10) bind 3 forbidden behavior NAMES + 1 redirect phrase via grep. Verifier proves the words appear in `## Anti-patterns`; it does not prove the runtime blocks behavior phrased without those exact words (e.g., "consider increasing your set-aside from 10% to 15%" performs savings advice without saying "savings"). Skill-level anti-pattern is the right mitigation tier (matches v2.3.0 C-v2.3-3 voice-matching precedent), but Phase 5 should sample-test the example output for substantive coverage, not just word presence. |
| S-v2.3.1-4 | INFO | 1 | none | OQ-v2.3.1-2 ideation-partner ruling is correct — keeping triggers concrete and pushing open-ended framing into `## When to use` + `## Instructions` is the right LLM01 posture (avoids implicit-trigger introspection, the 5th named pattern in the architect's scan). No "When NOT to use" anti-pattern is needed; the standard `## Anti-patterns` section already carries the negative-space callout per the 9-section template. |
| S-v2.3.1-5 | INFO | 1 | none | C-v2.3.1-8 zero-diff verification on action-items + doc-summary uses `git diff` and `cmp`. Both are byte-equality verifiers. sha256 adds nothing — `cmp` already detects ANY single-byte change. No additional hash-based verification needed. |

---

### CRITICAL
- (none)

### WARNING
- [ ] **S-v2.3.1-1 — ENFORCED_PRESETS / spec-OQ-5 trace gap.** The spec asked OQ-v2.3.1-5 about CI allowlist coverage for writing/creative/business-admin/personal-assistant presets. The architecture renames OQ-v2.3.1-5 to a line-count-band ruling and does not address the CI allowlist question. Direct verification: `.github/workflows/quality.yml` line 323 has `ENFORCED_EXAMPLES="study research project-management"` — all 4 v2.3.1 target presets are OUTSIDE the allowlist. **Why it's only a WARNING, not an OBJECT:** the deny-list under C-v2.3.1-9 correctly forbids `quality.yml` modification (PRD WILL-NOT-DO #9), and @qa's grep verifiers under C-v2.3.1-3 enforce the 9-section structure at Phase 5 directly — stronger than CI. The user-visible failure mode is "CI green does not prove 9-section conformance for these 4 presets after v2.3.1," which is acceptable for a content-only patch where Phase 5 is the structural gate. **Watch-item:** add `examples/writing examples/creative examples/business-admin examples/personal-assistant` to `ENFORCED_EXAMPLES` in a follow-up CI cycle (v2.4 or a hygiene cycle). Track in v2.3.1 retro carry-forwards.

### INFO
- **S-v2.3.1-2 — Trigger-count claim imprecision.** Architect states voice-matching, daily-briefing, and risk-assessment "carry exactly 4 bullets" in `trigger_examples`. Direct read: voice-matching 3, daily-briefing 3, risk-assessment 4, meeting-notes 5. The "exactly 4" binding is a POLICY choice (LLM01: concrete-trigger surface), not a faithful extraction. Policy is defensible; suggest tightening the wording in any retro/lessons doc.
- **S-v2.3.1-3 — spend-awareness substantive coverage at Phase 5.** Grep proves words present, not behavior absent. Phase 5 reviewer should read the worked example in spend-awareness `## Example` and confirm the example output does not perform investment/budgeting/savings advice via substitute phrasing.
- **S-v2.3.1-4 — ideation-partner posture correct.** No "When NOT to use" addition needed. Standard `## Anti-patterns` is sufficient.
- **S-v2.3.1-5 — `cmp` verification sufficiency.** No sha256 needed for action-items + doc-summary byte-unchanged check.

### OWASP Top 10 + LLM01-06 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth surface, no RLS, no IDOR risk. Markdown-only patch. |
| A02 Cryptographic Failures | N/A | No crypto. |
| A03 Injection | N/A | No code, no SQL, no shell-eval surface. |
| A04 Insecure Design | PASS | Architect's 9-section binding + 12-constraint catalog is sound. OQ-v2.3.1-5 trace gap noted as WARNING (S-v2.3.1-1) but not a design defect — out-of-scope-by-policy. |
| A05 Security Misconfiguration | PASS-WITH-NOTE | CI allowlist gap (S-v2.3.1-1) is a misconfiguration, but pre-existing to v2.3.1 and explicitly out of scope this cycle. Tracked as carry-forward. |
| A06 Vulnerable Components | N/A | No dependencies added or upgraded. `npm audit` not applicable to a markdown-only patch. |
| A07 Identification/Auth Failures | N/A | No auth. |
| A08 Software/Data Integrity | PASS | Lock file BYTE-UNCHANGED ruling verified by direct read of `cowork.lock.json` — confirmed: only tracks upstream `agency-agents` paths, zero `examples/` entries, no top-level tree-hash field. C-v2.3.1-9 and AC-ZD-1 strong form are correctly applied. `cmp` verifier is sufficient (S-v2.3.1-5). |
| A09 Logging/Monitoring | N/A | No logging surface. |
| A10 SSRF | N/A | No URL fetch in any of the 8 SKILL.md targets per architect's LLM01 scan item 3 ("URL fetch-and-act — NOT present in any reference skill"). Verified posture for v2.3.1 expansions. |
| LLM01 Prompt Injection | PASS | 5-pattern named scan covers the relevant surface for the 8 stubs: (1) second-person prompt-redefinition, (2) pasted-content-as-instructions, (3) URL fetch-and-act, (4) meta-prompt overrides, (5) implicit-trigger introspection. C-v2.3.1-7 binds imperative-voice + data-as-data conventions with concrete @qa greps for the 5 pasted-content-heavy expansions (creative-brief, feedback-synthesizer, email-drafting, follow-up-tracker, spend-awareness). The 5 patterns ARE the right 5 for these 8 skills (I checked each pattern against each stub's primary input shape). Pattern 5 (implicit-trigger introspection) is specifically the LLM01 mitigation argument that resolves OQ-v2.3.1-2 — confirmed correct (S-v2.3.1-4). |
| LLM02 Insecure Output Handling | PASS | All 8 outputs are plain-markdown, portability-constrained (no JSON, no YAML sidecar, no Obsidian wikilinks per C-v2.3.1-3 § Output format). No code execution path from skill output. |
| LLM03 Training Data Poisoning | N/A | Not applicable — no model training in scope. |
| LLM04 Model DoS | N/A | No throughput-sensitive surface. |
| LLM05 Supply Chain | PASS | No upstream sync this cycle. `cowork.lock.json` BYTE-UNCHANGED. ADR-028 PROPOSED stays untouched. No external skill import (deferred to v2.4). |
| LLM06 Sensitive Info Disclosure | PASS-WITH-NOTE | spend-awareness pasted-transaction handling: data-as-data clause bound under C-v2.3.1-7. C-v2.3.1-10 boundaries: 3 forbidden behaviors + redirect phrase. Covers the LLM06-adjacent risk (model echoing financial guidance it is unqualified to give). Phase 5 should sample-test substantive coverage, not just grep word presence (S-v2.3.1-3). |

---

## Combined-path Phase 5+6+7 ruling

**ELIGIBLE.**

Reasoning:
- Classification confirmed STANDARD via independent verification (V10-S2 protocol): zero auth surface, zero RLS surface, zero payment surface, zero external-API surface, zero schema surface, zero dependency additions, zero hardcoded-secret surface, zero CI workflow changes.
- Surface is markdown-only across 11 files (8 SKILL.md + VERSION + CHANGELOG.md + README.md).
- v2.3.0 + v2.2 precedent applies — STANDARD content-only patch with no architectural surface qualifies for combined Phase 5+6+7.
- This Round 1 verdict serves as the Phase 6 audit. No standalone `/audit` invocation required after Phase 5 unless @qa surfaces a new finding that escalates classification mid-cycle.
- One WARNING (S-v2.3.1-1) is a CI-coverage carry-forward, NOT a content/security defect that would block combined-path eligibility.

## MUST-NOT scope-creep verification

Re-read of the v2.3.1 architecture section for accidental scope expansion against the 12-item PRD WILL-NOT-DO list:

| WILL-NOT-DO | Architecture text contradicts? | Notes |
|---|---|---|
| 1. No new skills | NO | Registry cardinality 22 confirmed in `### Cycle context` and zero-diff list item 8. |
| 2. No version-minor bump | NO | Patch v2.3.0 → v2.3.1 stated in opening header. |
| 3. No ADR-028 impl | NO | "ADR-028 PROPOSED stays untouched" appears 3× in architecture. |
| 4. No external skill import | NO | Not mentioned (= excluded). |
| 5. No global-instructions changes | NO | Listed in deny-list item 6. |
| 6. No WIZARD.md changes | NO | Listed in deny-list item 5. |
| 7. No CLAUDE.md changes | NO | "wc -w CLAUDE.md returns exactly 397" hard-bound in C-v2.3.1-9. |
| 8. No cowork.lock.json schema changes | NO | OQ-v2.3.1-1 ruling: BYTE-UNCHANGED. Independently verified by reading the lock file. |
| 9. No CI workflow changes | NO | Listed in deny-list items 2-3. (Architecture also does not contradict this; see S-v2.3.1-1 for the trace gap on the *related* allowlist question.) |
| 10. No template changes | NO | Listed in deny-list item 7. |
| 11. No preset structure changes | NO | Folder layout intact across all 8 target paths. |
| 12. No registry annotation moves | NO | Listed in deny-list item 8. |
| Excluded: action-items + doc-summary BYTE-UNCHANGED | NO | C-v2.3.1-8 + deny-list items 9-10. `cmp` verifier sufficient (S-v2.3.1-5). |

Zero scope creep detected.

## Lock-schema independent verification

Read `cowork.lock.json` directly (669 lines). Verified:
- `$schema_version: "1.0"` — single top-level integrity field.
- `upstream: "msitarzewski/agency-agents"`, `pinned_commit_sha`, `pinned_at`, `license_file_sha256` — all upstream provenance.
- `files[]` array — 113 entries (counted by `path` keys spanning lines 9–667). Every path uses upstream prefixes (`academic/`, `design/`, `engineering/`, `finance/`, `marketing/`, `product/`, `project-management/`, `sales/`, `support/`, `testing/`). ZERO entries reference the in-tree `examples/` prefix.
- No tree-hash field, no per-file `examples/` content_hash field, no dependency-graph field that could transitively be affected by SKILL.md content changes.

**Conclusion:** Architect's OQ-v2.3.1-1 ruling (BYTE-UNCHANGED, no regen required) is correct. The lock file is provably unaffected by the 8 SKILL.md content changes. No security or supply-chain defect.

## Approval line

APPROVE-WITH-WATCH-ITEMS — design is implementable as-bound; the single WARNING is a pre-existing CI allowlist gap correctly held out of scope this cycle, with a follow-up carry-forward; combined-path Phase 5+6+7 eligibility CONFIRMED.

— @security
