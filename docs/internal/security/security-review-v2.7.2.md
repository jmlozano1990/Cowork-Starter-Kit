# Security Review — v2.7.2 "Truth & Release"

## Phase: 2 (combined-path spot-review — bound STANDARD)
## Date: 2026-07-18T08:05:00Z
## Status: PASS WITH WARNINGS
## Classification: STANDARD — **CONFIRMED** (no escalation; OI-SEC-2 SHA VALID)

> Scope: targeted spot-review of the v2.7.2 design (`architecture.md §v2.7.2 Phase 1`, ADR-035/036) and the four Open Issues handed off by @architect Phase 1. NOT a full-repo OWASP sweep — STANDARD classification, combined-path per §TASK 1 of the design. Reviewed against `release/v2.7.2` @ `4b7e122`.

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING  | 2     | configuration | WS2 gate: under GitHub Actions' default `bash -eo pipefail` shell, 2 of 3 "could not extract" diagnostics (missing README badge; wholly-absent CHANGELOG header) are suppressed — the command-substitution assignment aborts under `-e` before the friendly message prints. Fail-closed (exit 1) is preserved, but @qa's NC-3 negative-control asserts the exact message text and will report a mismatch. Fix: `set +e` after `set -o pipefail` (or `\|\| true` on the two extraction subs). |
| S2 | WARNING  | 2     | dependency | WS6 CoC: AC-13 verify (`grep -c "Contributor Covenant" >= 1`) does not pin the CC BY 4.0 attribution paragraph. The adopted Contributor Covenant text is CC BY 4.0 and its license requires the "adapted from … contributor-covenant.org/version/…" attribution line to survive. As written, a body that mentions the name once but drops the attribution URL passes AC-13. (OI-COMP-1) |
| S3 | INFO     | 2     | permissions | WS2 job declares no `permissions:` block → inherits default `GITHUB_TOKEN` scope. Functionally read-only (no API/network/write calls), so non-blocking, but least-privilege `permissions: contents: read` would match the `sync-agency-dry-run` S1 hardening precedent (quality.yml:875). |
| S4 | INFO     | 2     | none | Pre-existing internal analysis docs (`docs/competitive.md:137`, `docs/assumptions.md:150`, `docs/architecture.md:850`) cite "Snyk"/"Repello AI" as **security-research citations** (not marketing, not competing products). NOT introduced by v2.7.2 and NOT in any bound v2.7.2 product string. Forward-looking flag for Phase B docs-curation (`docs/internal/` split), not a v2.7.2 concern. |
| S5 | INFO     | 2     | external-api | OI-SEC-2 record: `sync-agency.yml:372` peter-evans SHA freshly re-verified VALID (see disposition). Issue #23 `[BLOCKER] security` is STALE — orchestrator may verify-then-close at WS7 with the evidence below. No escalation. |

### CRITICAL
- [ ] (none)

### WARNING
- [ ] **S1 — WS2 gate diagnostics defeated by GHA default `-e` (Phase-4 MUST-FIX).** The design's `run:` block sets `set -o pipefail` but not `set +e`. GitHub Actions runs `run:` steps with `bash --noprofile --norc -eo pipefail {0}`, so `errexit` is inherited. Two extraction lines — `B=$(grep -oP 'version-\K...' README.md | head -1)` and `CHEADER=$(grep -m1 -oP '^## \[\K[^\]]+' CHANGELOG.md)` — abort the step on a failing command substitution *before* their `if [ -z ... ]` "could not extract" branch runs. **Empirically confirmed** (bash -eo pipefail reproduction): NC-3 (README badge deleted) exits 1 with NO friendly message; adding `set +e` restores the message and keeps exit 1. Impact: (a) degraded debuggability on the two malformed-signal paths; (b) @qa's NC-3 hard Phase-5 negative-control, which asserts the message `could not extract README badge version`, will fail its message-match even though the exit code is correct. The **main D-2 hardening (stranded `[Unreleased]`) is UNAFFECTED** — grep succeeds there, so the semver branch and its message fire normally (verified against the live CHANGELOG). Fail-closed integrity is preserved in all cases; no false-PASS is possible. Fix is one line: `set +e` immediately after `set -o pipefail` (the design is a FAIL-accumulator, not errexit-based).
- [ ] **S2 — CoC CC BY 4.0 attribution line not pinned (Phase-4 MUST-FIX, OI-COMP-1).** `CODE_OF_CONDUCT.md` must carry the standard Contributor Covenant attribution paragraph (version + `https://www.contributor-covenant.org/version/…` URL) to satisfy the CC BY 4.0 license under which the Covenant text is distributed. Add to @dev's self-check: `grep -c "contributor-covenant.org" CODE_OF_CONDUCT.md` >= 1. @compliance confirms at the /legal license gate if it runs, but the design should bind the attribution line now rather than defer it.

### INFO
- **S3 — WS2 least-privilege.** Consider `permissions: contents: read` on the new job for defense-in-depth (matches quality.yml:875 `sync-agency-dry-run` S1 fix). Non-blocking: the job makes no token-bearing calls, so the inherited default cannot be abused by the job as written.
- **S4 — internal competitor citations (forward-looking).** `Snyk`/`Repello AI` appear only in internal research/analysis `docs/` (3 hits), pre-existing and citation-style. Phase B's public docs-curation should decide whether these move to `docs/internal/` before the showcase. Out of scope for v2.7.2.
- **S5 — issue #23 evidence-of-record.** See OI-SEC-2 disposition; SHA valid, issue stale.

---

## OI Dispositions

### OI-SEC-1 — WS2 `version-consistency-check` gate (design-stage review) — **PASS with one MUST-FIX (S1)**
- **Additive & read-only: CONFIRMED.** New job appended after `wizard-consistency-check` (quality.yml ends at line 1165). Adds **no new Action** — reuses the same pinned `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2` already used 24× in quality.yml (no new SHA to vet). **No `permissions:` block, no secret, no network call, no existing-control mutation.** Reads only three already-public files (`VERSION`, `README.md`, `CHANGELOG.md`). Confirms the STANDARD classification rationale (§TASK 1).
- **YAML validity: CONFIRMED.** The bound job body parses cleanly (`python3 yaml.safe_load` → 1 job, no syntax error). Spec Risk R5 (a syntax error breaking all CI) is not present in the design. **@dev caveat:** preserve the exact 2-space job indent / 6-space step indent when pasting into `quality.yml`, and run `actionlint` (or a YAML lint) before push — the `run: |` literal block is indentation-sensitive.
- **Fail-closed extraction + hardened `[Unreleased]` guard: LOGIC SOUND; hole genuinely closed.** Verified against the **live** CHANGELOG: today VERSION=2.6.1, badge=2.6.1, and the CHANGELOG top header is `## [Unreleased]` (v2.7 content stranded at lines 7–72, above `## [2.6.1]` at line 73). The **literal AC-4 regex** (`^## \[\K[0-9]+\.[0-9]+\.[0-9]+`) extracts `2.6.1` → all three "agree" at 2.6.1 → **false-green** on the exact D-2 defect. The **hardened gate** (`^## \[\K[^\]]+`) extracts `Unreleased` → not-semver → **correctly FAILS**. The design's production-validation claim is reproduced and correct; the strengthening is a strict superset of AC-4 (post-WS1 shipped state extracts `2.7.2` == badge == VERSION → PASS).
- **The one gap (S1):** the `-e` interaction above defeats 2 of the 3 malformed-signal diagnostics. Fail-closed holds; the NC-3 message-assertion breaks. MUST-FIX before Phase 5.

### OI-SEC-2 — Issue #23 `[BLOCKER] security` peter-evans SHA — **FRESH VERDICT: SHA VALID → issue STALE → NO escalation → classification stays STANDARD**

Evidence (freshly run this review, not assumed):
1. **Extracted SHA** (`sync-agency.yml:372`): `peter-evans/create-pull-request@67ccf781d68cd99b580ae25a5c18a1cc84ffff1f # v7.0.6`.
2. **Upstream existence:** `gh api repos/peter-evans/create-pull-request/commits/67ccf781d68cd99b580ae25a5c18a1cc84ffff1f` → **200**, SHA matches, committer date `2024-12-27T10:51:52Z`. Not a 404, not hallucinated.
3. **Tag corroboration:** `gh api .../git/ref/tags/v7.0.6` → object SHA `67ccf781d68cd99b580ae25a5c18a1cc84ffff1f` (type `commit`). The pinned SHA **is** the commit that tag `v7.0.6` points to — the comment and the pin agree.
4. **Runtime corroboration:** GitHub's own runner **successfully downloaded** `peter-evans/create-pull-request@67ccf781…` in run `28516513181` (2026-07-01). That run's failure was an **unrelated vendored-integrity hash mismatch** on `engineering/engineering-backend-architect.md` (upstream content drift — the integrity check working as designed), NOT an action-resolution failure.
5. **CI health on `main`:** latest `Quality Checks` runs are all `success`; the only `Sync Agency Upstream` failure is the integrity mismatch above, which does not implicate the action SHA.

**Verdict for the orchestrator (WS7):** Issue #23's premise ("action SHA hallucinated / does not exist") is **false**. Verify-then-close at WS7 with the api-200 + tag-match + runner-download evidence. Classification remains **STANDARD** — the conditional SECURITY-SENSITIVE escalation trigger (§TASK 1 / AC-19) does **not** fire.

### OI-SEC-3 — no-competitor-naming leak check (bound v2.7.2 product copy) — **PASS**
- Screened every bound replacement string in the design (WS1-d "What's new in v2.7", WS3-a/b/c refusal + "Next up" rewrites, WS4 paper-cut strings, WS5 REPLACE-generic sentences, WS6 CoC / issue-template / badge bindings) against the internal `improvement-plan-2026-07-18.md` competitor/tool-name set (Snyk, PromptArmor, and siblings).
- **No leak.** None of the bound strings introduce a third-party scanning-tool or competitor name. WS5's REPLACE-generic branch is deliberately tool-agnostic ("scan skills from external sources for prompt-injection risk and unexpected instructions…") and *removes* the existing `SkillRisk.org` reference rather than swapping in Snyk/PromptArmor — correct for this cycle (those are Phase B/C).
- **Baseline note:** the internal plan file is **not** present in the cowork repo (correctly kept out of the public tree). Competitor names surface only in pre-existing internal `docs/` research citations (S4, INFO) — not in any surface WS1–WS6 edits. MIT-required `agency-agents` upstream attribution remains the only permitted third-party name and is untouched.

### OI-COMP-1 — Contributor Covenant CC BY 4.0 attribution — **WARNING (S2)**
The CoC binding adopts the Covenant "verbatim structure," but AC-13's verify only asserts the name appears once and no `[INSERT` placeholders remain — it does not pin the CC BY 4.0 attribution line. Make it a Phase-4 MUST-FIX (see S2). If /legal runs, @compliance confirms at the license gate; the design should bind it regardless.

---

## Phase 4 MUST-FIX (for @dev — file-anchored)
1. **[S1] `.github/workflows/quality.yml` — WS2 job.** Add `set +e` on the line immediately after `set -o pipefail` in the `version-consistency-check` run block (or append `|| true` to the two extraction command-substitutions: the `B=$(grep … README.md | head -1)` and `CHEADER=$(grep … CHANGELOG.md)` lines). Rationale: GitHub Actions' default `bash -eo pipefail` otherwise aborts before the "could not extract README badge version" / "could not extract CHANGELOG header" diagnostics, breaking @qa's NC-3 negative-control message assertion. Preserve the FAIL-accumulator + explicit `exit 1` idiom. Fail-closed behaviour must remain (no path may reach the final `echo …PASSED` unless all three signals extracted and agree).
2. **[S2] `CODE_OF_CONDUCT.md` — WS6.** Include the standard Contributor Covenant attribution paragraph naming the version and the `https://www.contributor-covenant.org/version/…` URL (CC BY 4.0 obligation). Extend @dev's AC-13 self-check with `grep -c "contributor-covenant.org" CODE_OF_CONDUCT.md` >= 1.

## Phase 4 SHOULD-FIX / verify (for @dev)
3. **[S3] WS2 least-privilege (optional).** Add `permissions:\n  contents: read` to the `version-consistency-check` job for defense-in-depth (matches `sync-agency-dry-run`). Non-blocking.
4. **[OI-SEC-1] YAML lint before push.** Run `actionlint` (or `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/quality.yml'))"`) after inserting the job — the `run: |` block is indentation-sensitive; a stray indent breaks ALL of Quality Checks (spec Risk R5).
5. **[NC gate] Negative controls are a HARD Phase-5 gate (design §WS2 / AC-4).** After the S1 fix, @qa must show NC-1 (value mismatch), NC-2 (stranded `[Unreleased]`), NC-3 (missing badge) each `exit 1` **with the intended message**, and the positive control `exit 0`.

## Forward-looking (not v2.7.2 scope)
- **[S4]** Phase B docs-curation should decide whether `docs/competitive.md`, `docs/assumptions.md`, `docs/architecture.md` (which cite Snyk / Repello AI as security research) move under `docs/internal/` before any public showcase pass. Per the no-competitor-naming-public discipline, keep these out of curated public docs.

---

## OWASP Top 10 Assessment
| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth/authz surface; docs + additive read-only CI job only. |
| A02 Cryptographic Failures | N/A | No crypto/secret handling introduced. |
| A03 Injection | PASS | WS2 gate reads static repo files; no user/network input, no eval, no shell interpolation of untrusted data. Bound WS3/WS4/WS5 strings are static copy. |
| A04 Insecure Design | PASS | Gate design is fail-closed on all three signals; the one gap (S1) degrades diagnostics, not the fail-closed property. Hardened `[Unreleased]` guard closes the D-2 false-green (verified live). |
| A05 Security Misconfiguration | PASS (1 INFO) | No new `permissions:`/secret/Action. S3 recommends explicit `contents: read` least-privilege. |
| A06 Vulnerable & Outdated Components | PASS | No new dependency. peter-evans SHA (v7.0.6) freshly verified real & tag-consistent (OI-SEC-2). |
| A07 Identity & Auth Failures | N/A | No auth surface. |
| A08 Software & Data Integrity Failures | PASS | Supply-chain workflow `sync-agency.yml` untouched; its pinned action SHA verified valid; vendored-integrity check confirmed functioning (caught a real upstream drift 2026-07-01). |
| A09 Logging & Monitoring Failures | PASS (1 WARNING) | S1: two CI diagnostic messages are suppressed under GHA `-e` — a monitoring/observability degradation (fail-closed intact). Fix restores full diagnostics. |
| A10 SSRF | N/A | No network requests in any changed surface. |

**LLM threat note:** the project ships AI-instruction content (WIZARD.md), but v2.7.2 changes only version/timeline truthfulness (WS3/WS4 targeted line edits) — no interview *logic/flow* change. WS5's tool-agnostic rewrite (if REPLACE) *strengthens* the external-skill prompt-injection warning. LLM01 (prompt injection) posture: unchanged-to-improved. No new LLM attack surface.

---

## Summary
v2.7.2 "Truth & Release" is a docs + CI-hygiene cycle with **no auth/RLS/schema/secret/supply-chain/guard surface**. The WS2 `version-consistency-check` gate is genuinely additive, read-only, Action-less, permission-less, and its hardened first-header-of-any-kind extraction **closes the D-2 false-green hole** — verified against the live CHANGELOG (literal AC-4 regex false-greens at `2.6.1`; the hardened gate correctly fails on stranded `[Unreleased]`). Two WARNINGs are Phase-4 MUST-FIX: (S1) a one-line `set +e` so GHA's default `-e` shell does not suppress two malformed-signal diagnostics and break @qa's NC-3 message assertion — fail-closed integrity is *not* at risk, only diagnostics and the negative-control message-match; and (S2) pin the Contributor Covenant CC BY 4.0 attribution line. Issue #23's `[BLOCKER] security` premise is **false** — the peter-evans SHA is real and tag-consistent (fresh api-200 + tag-match + runner-download evidence). No competitor names leak into this cycle's product copy.

**Verdict: PASS WITH WARNINGS. Classification: STANDARD — CONFIRMED (no escalation).** Two Phase-4 MUST-FIX items (S1, S2) are for @dev; neither blocks the Phase 3 gate (STANDARD; gate logic is fail-closed and correct). Proceed to Phase 3 `/gate` for user approval.
