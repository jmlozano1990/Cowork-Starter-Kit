# Security Audit — v2.18.0 "The Substrate (slim)"

## Phase: 6
## Date: 2026-07-22T00:00:00Z
## Status: PASS-WITH-CONDITIONS

## Verdict: **PASS-WITH-CONDITIONS — 0 CRITICAL · 2 WARNING · 4 INFO.**

HEAD `78edead`, branch `cycle/v2.18-substrate`. Classification re-confirmed **SECURITY-SENSITIVE, FULL audit, no combined-path** (independently — the diff touches `self-apply/SKILL.md` (self-modifying surface), extends the apply hard deny-list, modifies `quality.yml` (Tier-B CI), extends the ADR-055 injection-scan surface, and defines the substrate two future rungs inherit; any one mandates it). All five MF-S RESOLVED at HEAD, verified against observed state, not agent narrative. All five SF-S run. The one open decision — the Example-scoping deviation — is ruled **(b) ACCEPT with a binding carry-forward**, conditioned on two WARNINGs below.

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| A1 | WARNING | 6 | logging | Public format doc's "Honest limit" section omits that the deterministic gate-of-record scans `## Example` only — non-Example sections (incl. `## Instructions`) are unscanned by the deterministic gate. Honest-limit posture requires disclosing this. Condition of the deviation ACCEPT ruling (land before merge). |
| A2 | WARNING | 6 | permissions | Binding carry-forward: v2.20 intake (genuinely untrusted content) MUST extend semantic coverage (the already-deferred LLM-judge) beyond `## Example` to the AI-executed sections. |
| A3 | INFO | 6 | schema | SF-S-4 forward-only: `cowork.install.json` integrity is protected only against the apply channel, not direct hand-edits/third-skill writes. Bind to v2.19 pull threat model (conflict-before-overwrite, HLD §5). |
| A4 | INFO | 6 | configuration | VERSION file unbumped (still `2.17.0`); WIZARD.md Step-4 stamps `kit_version` from VERSION into every install manifest. Must bump to `2.18.0` before release. |
| A5 | INFO | 6 | none | MF-S-4's AC-F3-2 fixture is a prose-walkthrough/grep-proxy (non-executable) — consistent with the inspection-class limit; proven to fire when driven, cannot be proven to fire on every real hand-edit. |
| A6 | INFO | 6 | none | spec.md has no `C-v2.18-N` binding-constraints section (v2.17 precedent); coverage distributed across 27 ACs + 5 MF-S. Convention-consistency only, no coverage gap. |

### CRITICAL
- None.

### WARNING (both binding conditions of the deviation ACCEPT — A1 before merge, A2 as a v2.20 /spec carry-forward)

**A1 — Format-doc honest-limit gap.** `docs/substrate-contribution-format.md` §"Honest limit" lists NFKC/homoglyph, zero-width bounded set, and shape-tripwire, but does **not** disclose that the mechanically-enforced gate-of-record applies the scan to the `## Example` section **only**. A public external-consumer contract that states its other limits then omits its scope limit overclaims by omission. **Binding disclosure text** (add as a fourth honest-limit bullet):

> **The deterministic scan covers `## Example` only, not the whole file.** Every mechanically-enforced call site (the CI gate, the promotion ceremony, and the workspace re-check) scans the `## Example` section, matching `CONTRIBUTING.md`'s stated threat model (that section is the one executed as AI context). A forbidden imperative planted in another section — `## Instructions`, `## Anti-patterns`, etc. — is **not** caught by this deterministic gate. On a curated-only pool, maintainer review is the layer that covers those sections; the deterministic scan is a shape tripwire over the highest-risk section, not whole-file coverage.

**A2 — v2.20 semantic-coverage carry-forward (binding to v2.20 /spec).** **Binding carry-forward text:**

> **v2.20-CARRY-1 (from v2.18 Phase-6 A2, SECURITY-SENSITIVE):** v2.20 intake accepts genuinely untrusted push content, at which point the v2.18 substrate's Example-only deterministic scan is structurally insufficient — an injection in any AI-executed section (`## Instructions` at minimum) escapes it (reproduced in v2.18 Phase 6). v2.20 MUST extend the semantic injection-intent stage (the LLM-judge already deferred to v2.20 per ADR-068 §Maturation / HLD §4) to read **meaning across all sections**, not just `## Example` — the semantic judge sidesteps the false-positive problem that makes a whole-file deterministic scan infeasible with the blunt 6-token pattern. This is the "defect here silently weakens two future rungs" risk from the v2.18 spec (risk #1) discharged forward, not closed.

### INFO
- A3 (SF-S-4): v2.19 pull threat model must treat manifest content as attacker-influenceable; confirm-before-overwrite already surfaced (HLD §5) — carry as an explicit v2.19 AC.
- A4: bump VERSION → `2.18.0` before release (Phase 7 gate).
- A5: MF-S-4 fixture is inspection-class prose proof; honest limit stated.
- A6: no `C-v2.18-N` section; distributed coverage is complete.

---

## The deviation ruling — (b) ACCEPT with binding carry-forward

**Both sides independently reproduced this session (not trusting @qa's or @dev's narrative):**

```
# The gap is real:
injection planted in ## Instructions:
  whole-file scan          -> exit 1  (caught)
  --section "## Example"    -> exit 0  (ESCAPES the gate of record)

# The narrowing justification is real:
whole-file raw-scan hits: 14 / 27 pool skills   (ordinary English "instead of", etc.)
```

**Ruling: (b) ACCEPT as-is, conditioned on A1 (disclose the scope limit now) + A2 (bind semantic coverage to v2.20).** Not (a), not (c). Grounds:

1. **Not a regression, and not a new narrowing.** `CONTRIBUTING.md:129` is byte-unchanged this cycle and *already* scopes the model to `## Example`. The `--section "## Example"` flag faithfully single-sources that pre-existing documented scope across all three call sites; it does not invent a narrowing. Before v2.18 there was **zero** automated scan, so this is net-new coverage over the highest-risk section.
2. **(c) REQUIRE-fix-now over-escalates.** Whole-file gating with the byte-identical 6-token pattern is infeasible (14/27 FP). The correct instrument for non-Example sections is a *semantic* judge that reads intent — and that judge is **already architecturally deferred to v2.20**. Building a hand-rolled semantic layer now is build-ahead-of-need the substrate's slimness forbids.
3. **(a) pure-ACCEPT under-delivers on honesty.** The public doc states its other limits meticulously but omits the scope limit (A1). And v2.20 inheriting an Example-only gate must be bound now (A2) or it is lost.

Not a rubber-stamp (two binding conditions, one blocking-before-merge) and not an over-escalation (no fix-now to the gate itself; the real fix rides the already-planned v2.20 semantic stage).

---

## MF-v2.18-S-1..5 — RESOLVED confirmations (observed state at HEAD)

- **MF-S-1 (drift firing negative control) — RESOLVED.** `registry-sha256-check` ships a fault-injection self-test that copies the registry, poisons self-apply's `sha256` cell with a valid-hex wrong value, and asserts detection (`exit 1` if the poison is NOT detected). Matches the house `lock-content-sha-fault-injection` model. Fail-closed; also fails on zero-rows-checked.
- **MF-S-2 (RED legs + honest enumeration) — RESOLVED.** All 3 fixtures verified BOTH legs: raw 6-token scan misses each (RED leg real), and `canonicalize-scan.sh` returns exit 1/1/2 (NFKC catch / zero-width catch / mixed-script flag). Script header + format doc enumerate the uncovered set: U+2060, U+00AD, U+180E, U+E0000–U+E007F.
- **MF-S-3 (explicit deny-list entry) — RESOLVED.** `cowork.install.json` added to the deny-list evaluated FIRST. All 3 priors intact + "evaluated FIRST" prose present.
- **MF-S-4 (reachable re-scan invocation) — RESOLVED (inspection-class).** self-apply turn-two step 1 is the concrete hook: computes current-bytes sha256, compares to the slug's `installed_content_sha256`, and on mismatch re-runs `canonicalize-scan.sh --section "## Example"` before rendering the diff. Fixture drives that exact step. Honestly labeled inspection-class (A5).
- **MF-S-5 (byte-identity + single-source) — RESOLVED.** Scan token set byte-identical between `CONTRIBUTING.md:129` and `canonicalize-scan.sh`. PROMOTE.md step 4 invokes the script, not an inline grep.

## SF-S-1..5 — results

- **SF-S-1 (no network/dep add) — PASS.** New job installs nothing; self-checks for `pip/npm install|curl|wget`. Both new jobs reuse the single pinned `actions/checkout@11bd719…# v4.2.2`; no new `uses:`/SHA/workflow file.
- **SF-S-2 (leakage re-grep) — PASS.** AC-F1-2 = 0; AC-XFER-4 model-class terms = 0 (sole hit is the runtime-agnostic negation clause); AC-F4-6 external contract reads slug + hashes + registry version only.
- **SF-S-3 (doc honesty) — PASS (with A1 caveat).** Format doc states NFKC does not fold homoglyphs, mixed-script FLAGGED (never auto-caught), zero-width set bounded/enumerated, "shape tripwire, not a semantic judge." **Gap: omits the `## Example`-only scope limit → A1.**
- **SF-S-4 (v2.19 carry-forward) — PRESERVED → A3.**
- **SF-S-5 (§Maturation delta) — PASS.** Exactly +4/+4/+4 (32→36).

## Self-integrity + reachability (ADR-061 / deny-list)

- **SELF-INTEGRITY — PRESERVED.** self-apply's own file remains on the deny-list evaluated FIRST, winning over the allow glob. The ADR-068 change adds only an *inspection* step — no new write channel to self-apply's own file or to `cowork.install.json` (both deny-listed). ADR-061 non-corruptibility intact.
- **REACHABILITY — bound.** The re-scan is tied to a step actually reached in the apply flow, and its fixture drives that step. Honest limit (A5) preserved.
- **DENY-LIST evaluated-FIRST — preserved** with all 3 priors + the new manifest entry.

## Negative verification (out-of-scope absence, confirmed at HEAD)

- **No LLM-judge in the diff** — every match is scope-boundary prose deferring it to v2.20.
- **No new write channel** — re-scan is inspection-only; deny-list unweakened.
- **No runtime network** — the only `curl`/`wget` strings are inside the SF-S-1 self-check that forbids them.

## OWASP + LLM Top-10 (at HEAD)

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | PASS | Apply deny-list extended with explicit, evaluated-first manifest entry; priors intact. |
| A03 Injection | PASS-WITH-CONDITIONS | Canonicalization + unforked scan verified; deterministic gate is `## Example`-scoped by design — disclose (A1) + extend semantically at v2.20 (A2). Maintainer review covers other sections. |
| A05 Security Misconfiguration | PASS | No new workflow/action/SHA; job self-checks no-network. |
| A08 Data Integrity Failures | PASS | Drift-verify fail-closed with a proven firing negative control (MF-S-1). |
| LLM01 Prompt Injection | PASS-WITH-CONDITIONS | Canonicalization + re-scan over highest-risk section; homoglyph FLAG-only; non-Example coverage carried to v2.20 (A2). |
| LLM08 Excessive Agency | PASS | Apply individually confirmed, deny-list-first; re-scan not dressed as a structural gate. |

(A02/A07/A10 N/A; A04/A06/A09, LLM02/06 PASS.)

### Summary
The substrate is well-built and honestly documented. Every automated layer proves it can fail (firing negative controls throughout — no check-that-cannot-fail survives). The one contested decision is sound for this rung and correctly deferred forward: an Example-scoped deterministic tripwire beneath a curated-only maintainer-review layer, with the semantic judge that would close the non-Example gap already slated for v2.20. Merge is gated only on disclosing that scope limit in the public contract (A1) and binding the v2.20 carry-forward (A2). No CRITICAL. No guard invariant weakened.

**Ruling: deviation (b) ACCEPT with binding conditions A1 (disclose scope, before merge) + A2 (v2.20 semantic carry-forward). Verdict PASS-WITH-CONDITIONS · 0 CRITICAL · 2 WARNING · 4 INFO.**

**End of v2.18.0 — Phase 6 Security Audit.**
