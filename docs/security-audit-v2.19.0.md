# Security Audit — Cowork Starter Kit v2.19 (Persistency Layer)

**Phase 6 (Code Audit) · 2026-07-22 (UTC) · Project `claude-cowork-config` (EXTERNAL) · HEAD `930fa06` (branch `cycle/v2.19-persistency`, base `383f46a`)**

## VERDICT: PASS — 0 CRITICAL · 0 WARNING · all 12 MF-v2.19-S RESOLVED at HEAD

Full-strength audit (SECURITY-SENSITIVE, no combined path). Every verification ran against actual bytes at HEAD, not agent narrative. @qa Phase-5 ISSUE-2 fix independently reproduced. **Nothing must land before the PR is presented for the Phase-7 merge decision.** 2 INFO carry-forwards (non-blocking, fail-closed/cosmetic).

## MF-v2.19-S re-verification (12/12 RESOLVED at HEAD)

| MF | Verify | Result |
|----|--------|--------|
| MF-1 (linchpin) | self-apply deny (lines 53-59) names `self-*` + explicit 3 members, evaluated-FIRST; base `383f46a` had 0 | RESOLVED — real fix; hole-in-allow |
| MF-1a | `self-` documented reserved prefix (line 55) | RESOLVED |
| MF-1b | "hole-in-allow, not blanket floor" (line 57) | RESOLVED |
| MF-1c (load-bearing) | channel-scope note (line 59): apply-deny does NOT govern installer/pull-backfill; AC-PULL-7 intact | RESOLVED |
| MF-2 | 3 AC-UPGRADE-8 firing controls in self-upgrade + tests doc; verify-then-swap reroute real | RESOLVED |
| MF-3 | classify-component.sh fresh both sides; 4 outcomes fire correctly | RESOLVED |
| MF-4 | registry sha256 match for 4 skills; backfill-verify.sh PROCEED clean / REFUSE poisoned | RESOLVED |
| MF-5 | validate-manifest.sh: well-formed OK, truncated + schema-invalid REFUSE | RESOLVED |
| MF-6 | semver-compare.sh real script; `ge 2.9.0 2.19.0`→false (lexical trap defeated) | RESOLVED |
| MF-7 | grep curl/wget/fetch/nc/ssh/http on added lines → 0 executable; no LLM-judge | RESOLVED |
| MF-8 | git diff 383f46a..HEAD: removed deny lines are strict subsets of replacements; additive-tightening | RESOLVED |
| MF-9 | `context/.kit-migrations/**` on BOTH deny-lists | RESOLVED |
| MF-10 | cowork.install.json on self-apply deny; kit_version rides upgrade ceremony; template no-new-field | RESOLVED |
| MF-11 | self-upgrade documents verify-then-swap order as inherited imperative + references (not re-declares) Loop 1 | RESOLVED |
| MF-12 | dormant no-op writes nothing; synthetic-newer routes into confirm gate | RESOLVED |

## @qa ISSUE-2 fix reproduced
Ran the paragraph-scoped `awk RS='' index($0,anchor)` logic against real file (PASS — 3 patterns present) and a surgical strip removing only the deny-clause enumeration while leaving explanatory prose (FIRES RED — deny paragraph missing siblings while file-wide still shows 2 self-archive hits; old whole-file grep would have wrongly PASSED). Genuine check-that-cannot-fail. CONFIRMED.

## SF-1..4 dispositions (all non-blocking)
- SF-1 semver script — FULLY ADDRESSED (deterministic, 9 cases).
- SF-2 v3.0 Class-2-before-Class-1-exec ordering — PARTIAL → INFO carry (self-upgrade dormant; no Class-1 executable invocable at v2.19).
- SF-3 installed-base sha256 drift re-verify — INFO carry (ADR-073 maturation).
- SF-4 migration-log tamper-evidence — PARTIAL → INFO carry (append-only + deny-listed now; hash-chaining a v3.x hub item).

## Deny-list byte-unchanged + additive-tightening
7-file byte-unchanged (diff=0): canonicalize-scan.sh, cowork.lock.json, .cowork-allowlist.json, CONTRIBUTING.md:129 anchor, cowork.install.template.json (no-new-field). self-apply/self-archive changes additive-tightening only (removed lines strict subsets of replacements; allow-surface identical; no confirmation relaxed). CONFIRMED.

## Self-integrity & reachability
verify-then-swap (AC-UPGRADE-8) present, not defeatable-by-construction (Class-2 deny-first; old gate acting authority until new passes; out-of-band pre-image). "A gate cannot rewrite its own rules" extended to the upgrade channel (3 siblings mutually deny-listed). No new write channel / no LLM-judge / no runtime network (MF-7). HOLDS.

## OWASP A01-A10 + LLM01/02/06/08
0 CRITICAL. A01 PASS (namespace default-deny closes sibling-overwrite). A05 PASS (Phase-2 exact-path WARNING resolved by MF-1). A02 PASS honest-limit (sha256, no signing under no-network). A03/A06/A08 PASS. A07/A10 N/A. LLM01/02/06/08 PASS (data-not-instruction; WYSIWYG; confirm-first; deterministic semver replaces model judgment).

## Classification + DEVIATION ruling
CONFIRMED SECURITY-SENSITIVE (independently re-derived; self-modifying-engine surface sufficient alone). @dev deviation (registry footnote 26/25→30/29): **ACCEPT, clean, in-scope** — independently counted 30 rows at HEAD; base footnote was itself stale by 2 (true base 28/27); v2.19 adds exactly 2 → 30/29 factually accurate; touches no security surface.

## INFO carry-forwards (non-blocking — do NOT gate the PR)
- **CF-v2.19-A (INFO):** self-apply Quality-criteria line 130 still summarizes the pre-v2.19 exact-path deny; operative paragraph (53-59) is correct and CI-enforced. Cosmetic doc-consistency.
- **CF-v2.19-B (INFO):** semver-compare.sh returns not-ready (exit 1) not documented exit-2 on malformed input; fail-CLOSED (malformed kit_version → manual-re-clone, never falsely ready). Contract-tidiness.
- SF-2/SF-3/SF-4: v3.0/v3.x maturation (none fire while self-upgrade dormant).

## shellcheck
Not available in audit env; `bash -n` clean on all 4 new shell files. CI runner (`ubuntu-latest`) has shellcheck and exercises them on the PR.

## Guard Change Summary §I (AS-BUILT — copy-paste-ready for PR)

**MERGE — 0 existing gate rules relaxed; adds a dormant upgrade gate + a pull flow and TIGHTENS the safety deny-lists. All 12 Phase-4 must-fixes verified resolved at HEAD; the @qa ISSUE-2 regression is fixed and its fix independently reproduced.**

**What changed.** `pull-updates` (Face 1) checks installed curated skills against the on-disk pool + `cowork.install.json` manifest, offering per-component updates with no silent overwrite; it is also the standing mechanism that backfills the 3 mandatory safety skills into workspaces missing them, byte-verified against the registry sha256. `self-upgrade` (Face 2) is a new, dormant, deny-listed sibling holding the contract to later walk a workspace's engine forward across kit versions. The safety deny-lists (self-apply, self-archive) grow — never shrink — to cover the new machinery by namespace.

**What could break.** (1) CF-A stale prose-summary line in self-apply (operative deny paragraph is complete + CI-enforced; unlikely to mislead; LOW). (2) CF-B semver malformed-input exit code (fail-closed — never falsely "ready"; LOW).

**What's protected.** Every Loop 1 invariant byte-unchanged and re-fires through the new entry points: confirm→apply→verify→rollback, no-batching, WYSIWYG-at-apply, out-of-band rollback pre-image, and "a gate cannot rewrite its own rules" — extended to the upgrade channel as verify-then-swap. MF-1 namespace floor closes the Phase-2 A05 finding. Per-item human WYSIWYG confirmation at turn two is the load-bearing independent control — do not weaken.

**What to verify after merge.** Fresh workspace (Mode A + B) contains self-upgrade + pull-updates; invoking self-upgrade says "nothing to walk forward to yet" and writes nothing. curated-skills-registry.md shows self-upgrade + pull-updates rows with 64-hex sha256; registry-sha256-check green. self-apply-deny-completeness-check green (its absence on a future PR that generalizes the deny enumeration is the alarm). Applying an ordinary skill edit targeting self-archive/self-upgrade/self-apply is REFUSED (absence of that refusal is the alarm).

**What we could not prove:** shellcheck unavailable locally (bash -n clean; CI runner has it).
