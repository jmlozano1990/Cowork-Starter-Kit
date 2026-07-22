# Security Review — Cowork Starter Kit v2.19 (Persistency Layer)

**Phase 2 (Architecture / Design) · 2026-07-22 (UTC) · Project `claude-cowork-config` (EXTERNAL) · Classification SECURITY-SENSITIVE (full-strength, no combined path)**

## VERDICT: PASS-WITH-WARNINGS — HARD GATE (AC-UPGRADE-8 / SEC-F1) CLEARS

AC-UPGRADE-8 is present in the spec, grounded first-class in ADR-071 §3 (two-write-class verify-then-swap invariant) with three real firing controls. Two defeat attempts (route a safety rewrite through the ordinary path; land new machinery before verifying under the old gate) fail **by construction** (deny-first Class-2 model; old gate stays acting authority until new machinery passes under it).

One load-bearing WARNING, ground-truthed against shipped code: `self-apply`'s deny-list covers only its own file and can today overwrite `self-archive/SKILL.md` (and `self-upgrade/SKILL.md` on arrival) via the `.claude/skills/*/SKILL.md` allow-glob. Not a BLOCKER (the invariant is present), but bound as the linchpin Phase-4 MUST-FIX **MF-v2.19-S-1** (namespace default-deny for Class-2 membership).

**0 CRITICAL · 3 WARNING (S1 deny-list completeness, S6 semver determinism, S11 prose-reference drift) · 12 MF bound Phase-4.**

## HARD Gate Adversarial Report (AC-UPGRADE-8)

| Attack attempted | Defense | Verdict |
|---|---|---|
| Route safety-machinery rewrite through ordinary Write-Class-1 path | ADR-071 §3 Class 2 evaluated FIRST, deny-first; firing control (a) refuses | Defeated — conditional on MF-1 (namespace completeness) |
| Land new machinery live, verify under incoming (attacker) gate | Verify-then-swap: old gate is acting authority until new passes; control (b) → no swap | Defeated by construction |
| Rewrite `self-upgrade` itself to flip order | `self-upgrade` ∈ Class 2 → higher-ceremony, WYSIWYG, pre-image out-of-band | Defeated — conditional on MF-1 (a rename escapes an exact-path set) |
| Corrupt rollback pre-image | Pre-image captured out-of-band before swap | Defeated by construction |

Ruling: invariant is real, first-class, testable, not defeatable-by-construction **provided MF-1 makes Class-2 membership namespace-based, not exact-path.**

## MF-v2.19-S — Binding Phase-4 MUST-FIX (deterministic verify each)

- **MF-1 (WARNING, linchpin).** `self-apply` apply deny-list MUST deny all safety-skill files by namespace default-deny (`.claude/skills/self-*/SKILL.md` or explicit self-apply+self-archive+self-upgrade), evaluated-FIRST over the allow-glob (mirror `self-archive`'s `.claude/**` floor). Verify: `grep -n "self-archive\|self-upgrade\|skills/self-\*" skills/self-apply/SKILL.md` returns deny hits (currently 0). Fixture: apply targeting `.claude/skills/self-archive/SKILL.md` AND `.../self-upgrade/SKILL.md` → REFUSED; benign skill → proceeds (negative control that can fail).
- **MF-2 (HARD).** `self-upgrade/SKILL.md` authors AC-UPGRADE-8's 3 firing controls as real fixtures: (a) safety-file via ordinary path → refused/rerouted; (b) new machinery fails verify under OLD gate → no swap; (c) non-safety engine file → ordinary gate succeeds. Removing the reroute must make (a) go RED (check-that-cannot-fail).
- **MF-3 (S2).** Overwrite/conflict decision from fresh bytes BOTH sides. Fixture: `installed_content_sha256` = hash of a different file than on-disk → classifies user-customized (from on-disk), not "untouched".
- **MF-4 (S3).** Backfill byte-verifies each safety skill vs ADR-069 registry sha256, curated-pool-only; add `self-upgrade` tier-1 mandatory-infrastructure row to `curated-skills-registry.md` with CI sha256. Poisoned copy → REFUSED.
- **MF-5 (S4).** Malformed/truncated/schema-invalid manifest → refuse + safe-fallback; never partial-parse. Bidirectional firing control.
- **MF-6 (S5).** Semver-aware compare (parse integers). Fixtures 2.9.0 / 2.18.0 / 2.19.0 / 2.20.1 / absent → correct each; a string-compare impl FAILS 2.9.0 vs 2.19.0.
- **MF-7 (S6).** No in-session network on either face or the migration-seam writer regardless of @dev's Face-1 locus. `grep -rEn "curl|wget|fetch|nc |ssh |https?://"` on new/edited lines → 0.
- **MF-8 (S7).** self-apply/self-archive edits additive-tightening ONLY: no allow-glob widened, no deny removed, no confirmation relaxed. `git diff` shows only deny additions.
- **MF-9 (S8).** `context/.kit-migrations/**` explicitly on BOTH deny-lists.
- **MF-10 (S9).** `cowork.install.json` deny entry in self-apply byte-unchanged; kit_version write rides upgrade ceremony, never self-apply.
- **MF-11 (S11).** `self-upgrade/SKILL.md` documents verify-then-swap ORDER as inherited imperative + REFERENCES (not re-declares) Loop 1 primitives (C-v2.19-7 / AC-UPGRADE-4b).
- **MF-12 (S12).** Dormant no-op writes nothing (edge #7); synthetic-newer routes into the confirmed-apply gate.

## OWASP A01–A10 + LLM01/02/06/08
0 CRITICAL. A05 WARNING (Class-2 exact-path = misconfig-by-omission → MF-1). A01/A04/A08 PASS (verify-then-swap + deny-first + append-only integrity — strong). A02 PASS honest-limit (sha256 anchor, no signing — accepted under no-network). A03 PASS (manifest untrusted data; fresh-bytes + malformed-refusal). A07/A10 N/A (no auth, no network). LLM06/08 PASS (confirm-first, non-destructive, no-batching; self-modify constrained by verify-then-swap; MF-1 load-bearing).

## Classification (independently re-derived)
CONFIRMED SECURITY-SENSITIVE — full-strength, no combined/lightened path, no compliance surface, no outbound network either face. Reason #1 (self-modifying engine surface — upgrade rewrites the running framework; higher blast radius than v3.0 spawn) strongest and sufficient alone. OQ1/OQ5 add self-modifying surface, do not shrink it. Combined audit+approve path explicitly rejected.

## Phase-6 SHOULD-FIX (non-blocking)
- SF-1 (LLM08): deterministic semver-compare helper (script) over model-judgment prose.
- SF-2 (v3.0 forward): within a multi-file upgrade unit, Class-2 verification completes BEFORE any newly-written Class-1 executable is invoked; prose note in self-upgrade/SKILL.md now.
- SF-3 (ADR-073 maturation): periodic re-verify already-backfilled safety skills still match registry sha256 (installed-base drift).
- SF-4 (A09): migration-log tamper-evidence beyond deny-list if a future v3.x hub reads migration state across siblings.

## Phase-2.D recommendation
OPTIONAL — narrowly scoped to MF-1 (@architect confirms namespace-floor fix mirrors self-archive without breaking self-apply allow-glob semantics; @qa confirms MF-1/MF-2 firing controls testable pre-implementation). De-risking nicety, not a gate; binding MF-1 as a hard Phase-4 AC is sufficient.

## Guard Change Summary §I (copy-paste-ready for PR)

**MERGE — 0 existing gate rules relaxed; adds a dormant upgrade gate and tightens the safety deny-lists. One safety-machinery deny-list completeness fix (MF-1) bound as a Phase-4 hard AC.**

**What changed.** The kit gains a persistency layer: workspaces can pull newer curated skills (conflict-safe, fresh-bytes-verified offers) and — via a new, dormant, deny-listed `self-upgrade` skill — hold the contract to later walk their engine forward across kit versions. Safety deny-lists grow (never shrink) to cover the new machinery.

**What could break.** (1) MF-1 — until the deny-list is namespace-complete, the content-apply channel can target `self-archive` (today) / `self-upgrade` (on arrival); likely only under a malicious curated payload that also survives human WYSIWYG confirm; MEDIUM, the one worth attention. (2) MF-11 — prose-reference reuse could drift toward swap-then-verify in a future edit; unlikely, MEDIUM, mitigated. (3) MF-6/SF-1 — model-executed semver compare could mis-order; possible, LOW, fixture catches it.

**What's protected.** Every Loop 1 invariant byte-unchanged and re-fires through the upgrade entry point: confirm→apply→verify→rollback, no-batching, WYSIWYG-at-apply, out-of-band rollback pre-image, and "a gate cannot rewrite its own rules" — now extended to the upgrade channel as verify-then-swap. The interim independent control making the MF-1 residual acceptable is per-item human WYSIWYG confirmation — load-bearing; do not weaken before MF-1 lands.

**What to verify after merge.** Fresh workspace (Mode A + B) contains `.claude/skills/self-upgrade/SKILL.md`, deny-listed; invoking it says "nothing to walk forward to yet" and writes nothing. `curated-skills-registry.md` shows a `self-upgrade` row with 64-hex sha256. Diff of self-apply/self-archive = only deny additions. After MF-1: applying a change to `self-archive/SKILL.md` is REFUSED (absence of that refusal is the alarm).

**What we could not prove (no code yet → Phase-6):** that the 3 AC-UPGRADE-8 firing controls actually fire (MF-2); that the semver compare is deterministic (MF-6 + SF-1). The design requires them; this review confirms the requirement is present and testable, not that the eventual implementation honors it.
