# Security Review — v2.18.0 "The Substrate (slim)"

## Phase: 2
## Date: 2026-07-22T00:00:00Z
## Status: PASS WITH WARNINGS

**Verdict: PASS-WITH-WARNINGS — 0 CRITICAL · 5 WARNING · 6 INFO.** The design is architecturally sound and grounded in a proven in-repo model (the `lock-content-sha-fault-injection` / `registry-url-check` firing-control pattern, `quality.yml` lines 307–1140). No finding requires redesign. All 5 WARNINGs are **binding Phase-4 MUST-FIX ACs** per `[[phase2-findings-to-phase4-contract]]` — each closes a "check-that-cannot-fail" or dead-prose-reachability gap the ADRs *describe* but do not yet make *deterministic*. Build may proceed; @dev must satisfy MF-S-1…5 and @qa/@security verify at Phase 5/6.

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING | 2 | schema | F2 firing controls (F2-1/2/3) must each demonstrate a RED leg (evade-RAW) AND the catch/flag-NORMALIZED leg as CI fixtures; doc must honestly enumerate uncovered invisible-codepoint classes (→ MF-S-2) |
| S2 | WARNING | 2 | permissions | `cowork.install.json` must be added to self-apply's explicit line-53 hard deny-list (evaluated FIRST), preserving all 3 existing entries (→ MF-S-3) |
| S3 | WARNING | 2 | schema | ADR-069 drift-verify job must ship a fault-injection self-test proving it CAN fail on a poisoned hash, matching `lock-content-sha-fault-injection` (→ MF-S-1) |
| S4 | INFO | 2 | none | Scan pattern confirmed byte-identical to CONTRIBUTING.md:129; bind byte-equality check in the script (folded into MF-S-5) |
| S5 | INFO | 2 | logging | AC-F1-2 (0 private keys in bodies) + AC-XFER-4 (0 model-class terms) baselines confirmed CLEAN today; Phase-6 must re-grep against shipped diff incl. new format doc (→ SF-S-2) |
| S6 | WARNING | 2 | permissions | self-apply re-scan (ADR-068) needs a concrete reachable invocation point + AC-F3-2 fixture must drive THAT invocation; deny-list self-integrity preserved (→ MF-S-4) |
| S7 | WARNING | 2 | configuration | PROMOTE.md promotion gate must call the SAME canonicalize script (not an inline raw grep); residual raw CONTRIBUTING:129 recipe must not be mislabeled as the gate (→ MF-S-5) |
| S8 | INFO | 2 | dependency | Tier-B: quality.yml adds a JOB not a workflow file, no new `uses:`/SHA — new-workflow trigger correctly does NOT fire; bind no-`pip install`/no-network check (→ SF-S-1) |
| S9 | INFO | 2 | schema | Forward-only: manifest integrity is NOT structurally protected vs direct hand-edits (only vs the apply channel) — bind to v2.19 threat model (→ SF-S-4) |
| S10 | INFO | 2 | ui | Doc must not overclaim: NFKC does NOT fold Cyrillic homoglyphs — they are FLAGGED for human review, never auto-caught (→ SF-S-3) |
| S11 | INFO | 2 | schema | §Maturation self-grep delta must be exactly +4/+4/+4 (32→36) (→ SF-S-5) |

### CRITICAL
- [ ] None.

### WARNING (all → binding Phase-4 MUST-FIX)
- [ ] **S3 → MF-S-1:** ADR-069's drift-verify job as written re-computes and compares, but the ADR does not require a *firing negative control*. Without one, a broken comparison passes silently. A check that cannot fail is not a check (`[[check-that-cannot-fail]]`).
- [ ] **S1 → MF-S-2:** F2-1/F2-2/F2-3 must each ship a fixture that *demonstrably* evades the RAW scan (the RED leg) and is caught/flagged after canonicalization — matching the house `lock-content-sha-fault-injection` shape, not asserted in prose.
- [ ] **S2 → MF-S-3:** `cowork.install.json` is currently only covered by self-apply's catch-all "any file not named in the allow-list is refused" (line 55). ADR-067 requires an *explicit* line-53 hard-deny entry (evaluated FIRST). Currently ABSENT — @dev must add it.
- [ ] **S6 → MF-S-4:** The ADR-068 workspace-side re-scan is described but its *trigger invocation* is unnamed — a reachability (dead-prose) risk. @dev must bind it to a concrete self-apply step and AC-F3-2's fixture must exercise that exact step.
- [ ] **S7 → MF-S-5:** PROMOTE.md's promotion gate must invoke the single-source canonicalize script; the byte-identical scan pattern must be enforced by a diff-equality check.

### INFO (→ Phase-6 SHOULD-FIX)
- S5/SF-S-2, S8/SF-S-1, S9/SF-S-4, S10/SF-S-3, S11/SF-S-5, S4 (byte-equality, folded into MF-S-5).

---

## Per-OI Dispositions (S1–S8)

### OI-v2.18-S1 (canonicalization bypass) — DISPOSITION: SOUND, bind RED legs + honest enumeration
ADR-068 §Decision specifies NFKC (`unicodedata.normalize('NFKC', …)`, stdlib, ubuntu-latest built-in), zero-width strip (U+200B/200C/200D/FEFF), and mixed-script FLAG.
- **NFKC** correctly neutralizes compatibility-decomposable evasion (fullwidth U+FF29 → `I`). F2-1 covers it.
- **Zero-width strip** covers the four named codepoints. **Honest gap (must be stated, never overclaimed):** the strip set does NOT cover other invisible/format (Cf) codepoints — U+2060 word-joiner, U+00AD soft-hyphen, U+180E, U+E0000–E007F tag chars. HLD §11 "narrows only the cheapest evasion classes" and ADR-068 §Risk-knowingly-accepted state this, but the shipped doc + fixtures must **enumerate the uncovered set explicitly**. → **MF-S-2**.
- **Mixed-script → human review, never auto-pass (AC-F2-3):** CONFIRMED as a FLAG-path control, correctly *not* a scan-catch (crucial: NFKC does **not** fold Cyrillic а/е to Latin — a homoglyph token still MISSES the 6-token scan post-NFKC; only the mixed-script flag catches it, and only to human review). ADR-068 gets this right. Matches self-apply's own honest posture ("easy to get past — a homoglyph… slips through"). → doc must not overclaim (**SF-S-3/S10**).
- **Firing controls (F2-1/2/3):** the ADR *names* them but does not demand each proves its RED leg the way `lock-content-sha-fault-injection` ("mismatch was NOT detected → FAIL") does. **Bind → MF-S-2.**

### OI-v2.18-S2 (manifest trust-boundary) — DISPOSITION: SOUND, bind explicit deny-list entry
ADR-067 adds `cowork.install.json` to the apply HARD DENY-LIST (evaluated FIRST) and asserts integrity-anchor-not-fetch-target (AC-F4-4; grounded against WIZARD.md:26 Network/Offline Rule — confirmed no runtime fetch). **Current state (grounded):** self-apply's deny-list (SKILL.md:53) has exactly 3 entries; `cowork.install.json` is ABSENT and only covered by the line-55 catch-all. ADR-067 requires the explicit line-53 entry — defense-in-depth, evaluated-first. → **MF-S-3.** Tamper→silent-overwrite blast radius is bounded by v2.19's "surface conflict, never silently overwrite" (HLD §5) — but that boundary is *forward-only* (v2.19 does not exist yet). → **SF-S-4** (S9).

### OI-v2.18-S3 (sha256 spoofing / drift) — DISPOSITION: SOUND, bind fault-injection self-test
ADR-069 makes the drift-verify job fail-closed on any registry-cell ≠ pool-file-hash, exact `lock-content-sha` model. The manifest↔registry link (`registry.sha256 == manifest.installed_content_sha256` at install) cannot be forged *in-repo* because CI recomputes the registry cell from pool bytes. **Gap:** the ADR does not require the drift job to carry a *firing negative control*; the house standard (`lock-content-sha-fault-injection`, and the `registry-url-check` negative self-test) is that the job proves it CAN fail on a poisoned fixture. → **MF-S-1** (the strongest MUST-FIX). Residual honest limit: the manifest side of the link is workspace-local and NOT CI-covered (see S2/S9).

### OI-v2.18-S4 (scan unforked) — DISPOSITION: PASS
Grounded: CONTRIBUTING.md:129 = `grep -iE '\b(Ignore|Disregard|Override|Instead of|Always respond|New instruction)\b'` — single occurrence, byte-confirmed. ADR-068 step 4 reuses it byte-identical. No opportunistic widening. Bind a byte-equality assertion between CONTRIBUTING.md:129 and `scripts/canonicalize-scan.sh`'s only scan call (folded into **MF-S-5**).

### OI-v2.18-S5 (external-consumer leakage) — DISPOSITION: PASS (baselines clean)
Grounded, run this session:
- AC-F1-2: `grep -riE 'core_skills:|optional_skills:|wizard_hook|preset_route' skills/*/SKILL.md` → **0**. Adapter isolation is real *today* (private keys live in `selection-presets.md:15–64`, confirmed).
- AC-XFER-4: `grep -riE '9b|qwen|small model|local model|not claude' templates/skill-template/SKILL.md CONTRIBUTING.md` → **0**.
- AC-F4-6 (wizard-runtime-state leak): ADR-067 external-consumer contract reads slug + `installed_content_sha256` + `installed_registry_version` + registry `sha256`/`vetting_date` — no mid-interview-only field. Sound.
Phase-6 must re-grep against the shipped diff, **adding the new `docs/substrate-contribution-format.md` to the AC-XFER-4 grep set** (per AC-XFER-4's own verify clause). → **SF-S-2.**

### OI-v2.18-S6 (self-apply self-integrity — BOTH axes per `[[reachability-vs-write-scope-review-axes]]`) — DISPOSITION: bind reachability
**(a) REACHABILITY — the weak point.** ADR-068 adds to self-apply: "when the on-disk SKILL.md hash differs from the manifest `installed_content_sha256`, re-run the canonicalize→scan convention." But **who invokes the hash comparison, and when, is unnamed.** self-apply is entered via the ledger apply flow; at turn two it already re-derives current bytes (SKILL.md:63) — the natural, reachable hook. But AC-F3-2's fixture ("hand-edit a skill post-install, confirm the re-scan fires") describes an edit that need not go through the apply flow at all; a hand-edited-then-never-applied file is never reached. This is honestly inspection-class (the ADR says so) — but "described but never reached" is dead prose. @dev **must name the concrete invocation step** and the fixture **must drive that exact step**, not a hypothetical. → **MF-S-4.**
**(b) SELF-INTEGRITY — PRESERVED.** self-apply's own file is on its own deny-list (SKILL.md:53–55), evaluated FIRST, winning over the `.claude/skills/*/SKILL.md` allow glob. ADR-068 adds an inspection step, introduces no write channel to self-apply's own file, and is honestly labeled inspection-class (not dressed as a structural gate). ADR-061 non-corruptibility intact. Constraint: adding the manifest deny entry (MF-S-3) must NOT reorder/weaken the existing 3 entries — @qa greps that all 3 originals + the manifest are present and the "evaluated FIRST" prose is intact.

### OI-v2.18-S7 (pipeline-order enforceability) — DISPOSITION: PASS-WITH-WARNING
Within `scripts/canonicalize-scan.sh` the scan's ONLY call consumes the canonicalized buffer — AC-F2-4 holds *for the gate of record* (the CI `canonicalize-scan-check` job). **Honest nuance:** the raw manual recipe at CONTRIBUTING.md:129 still exists — a contributor *can* run a raw grep by hand. That is a courtesy, NOT the gate; it must not be mislabeled as canonicalizing. And ADR-068 asserts PROMOTE.md's promotion gate "invokes the SAME script" — @dev must actually wire it (not leave an inline raw grep). → **MF-S-5.**

### OI-v2.18-S8 (Tier-B CI surface) — DISPOSITION: PASS
Grounded: every `uses:` in quality.yml is SHA-pinned (`actions/checkout@11bd719… # v4.2.2`, etc. — full list confirmed). ADR-068 adds a JOB (`canonicalize-scan-check`) to the EXISTING quality.yml, reuses the pinned checkout, uses ubuntu-latest built-in `python3` (unicodedata is stdlib) — **no new `uses:`, no new SHA, no new workflow file** → the new-workflow-file Tier-B trigger correctly does NOT fire. The quality.yml modification is subsumed by this cycle's standing SECURITY-SENSITIVE worktree+PR. @qa runs the CONTRIBUTING §CI Workflow Quality Baseline (YAML parse + trigger registration) at Phase 5. **Bind:** grep the new job for `pip install`/`npm install`/`curl`/`wget` → must be 0 (no supply-chain/network add). → **SF-S-1.**

---

## Phase-4 MUST-FIX List (binding, deterministic — `[[phase2-findings-to-phase4-contract]]`)

**MF-v2.18-S-1 (from S3, ties AC-F5 / ADR-069).** The drift-verify job MUST ship a firing negative control matching `lock-content-sha-fault-injection`. A poisoned fixture with a deliberately wrong `sha256` MUST make the job exit non-zero; if the mismatch is NOT detected, the job MUST self-fail.
Verify (@qa/@security, Phase 5/6):
```bash
# the drift job must fail on a poisoned registry hash
grep -nE 'mismatch was NOT detected|FAULT|fault-injection|NEGATIVE' .github/workflows/quality.yml   # new job carries a self-test
# and prove the RED leg runs:
git grep -n 'sha256' .github/workflows/quality.yml | grep -iE 'registry|drift'
```

**MF-v2.18-S-2 (from S1, ties AC-F2-1/2/3).** Each canonicalization fixture MUST demonstrate BOTH legs: evades the RAW 6-token scan AND is caught (F2-1 NFKC, F2-2 zero-width) or flagged to human review (F2-3 mixed-script). The script/doc MUST honestly enumerate the *uncovered* invisible-codepoint classes (at minimum U+2060, U+00AD, tag chars) — no overclaim.
Verify:
```bash
test -f scripts/canonicalize-scan.sh
# RED leg present per fixture:
ls tests/fixtures/ | grep -iE 'canonical|nfkc|zero-width|homoglyph|mixed-script'
grep -niE 'evade|raw scan|NOT caught|uncovered|does not cover|U\+2060|soft.hyphen' scripts/canonicalize-scan.sh docs/substrate-contribution-format.md
```

**MF-v2.18-S-3 (from S2/S6b, ties AC-F4-2 / ADR-067 / ADR-061).** `cowork.install.json` MUST be added to self-apply's EXPLICIT hard deny-list (SKILL.md:53, evaluated FIRST), and all 3 existing entries + the "evaluated FIRST" ordering prose MUST remain intact.
Verify:
```bash
grep -c 'cowork.install.json' skills/self-apply/SKILL.md            # >= 1 (currently 0)
for e in 'context/memory-of-use.md' 'context/.apply-backups' 'self-apply/SKILL.md'; do grep -q "$e" skills/self-apply/SKILL.md || echo "REGRESSION: lost $e"; done
grep -n 'evaluated FIRST' skills/self-apply/SKILL.md                 # ordering prose intact
```

**MF-v2.18-S-4 (from S6a, ties AC-F3-2/F3-3).** The workspace-side re-scan MUST name a concrete, reachable invocation step inside self-apply (bound to the content-hash-mismatch check vs manifest `installed_content_sha256`), and the AC-F3-2 fixture MUST drive THAT step. Honestly labeled inspection-class, not a structural gate.
Verify:
```bash
grep -nE 'installed_content_sha256|content.hash|re-scan|re-run the canonicaliz' skills/self-apply/SKILL.md
ls tests/fixtures/ | grep -iE 're-scan|post-install|edit'   # fixture drives the named step
```

**MF-v2.18-S-5 (from S4/S7, ties AC-F3-1 / AC-F2-4).** `scripts/canonicalize-scan.sh`'s scan call MUST be byte-identical to CONTRIBUTING.md:129, AND PROMOTE.md's promotion gate MUST invoke the same script (not an inline raw grep).
Verify:
```bash
grep -oE '\\b\(Ignore\|Disregard\|Override\|Instead of\|Always respond\|New instruction\)\\b' scripts/canonicalize-scan.sh CONTRIBUTING.md   # identical both files
grep -n 'canonicalize-scan.sh' PROMOTE.md    # promotion gate wired to the single source
```

---

## Phase-6 SHOULD-FIX (non-blocking)

- **SF-S-1 (S8):** grep the new `canonicalize-scan-check` job for `pip install|npm install|curl|wget` → 0 (no supply-chain/network add).
- **SF-S-2 (S5):** re-run AC-F1-2, AC-XFER-4 (incl. `docs/substrate-contribution-format.md`), AC-F4-6 greps against the shipped diff; baseline is clean now, confirm no regression.
- **SF-S-3 (S10):** doc-honesty pass — the format doc MUST state NFKC does not fold homoglyphs; mixed-script is FLAGGED to human review, never auto-caught. No "canonicalization catches homoglyphs" language.
- **SF-S-4 (S9) — forward-only caveat (binding to v2.19 /spec):** the manifest's integrity is protected only against the *apply channel*, not against direct hand-edits or a third skill. v2.19's threat model MUST treat manifest content as attacker-influenceable and confirm before any overwrite (it already surfaces conflicts, HLD §5 — carry this as an explicit v2.19 AC).
- **SF-S-5 (S11):** confirm §Maturation self-grep delta is exactly +4/+4/+4 (32→36).

---

## Classification Ruling (independent, V10-S2 posture)

**CONFIRMED SECURITY-SENSITIVE (permanent). No downgrade.** Independently grounded — any ONE of these mandates it:
1. Modifies `skills/self-apply/SKILL.md` — the ADR-061 mandatory apply-governing safety skill (a self-modifying surface; HLD §3.4 "every self-modifying surface is permanently security-sensitive").
2. Extends the apply HARD DENY-LIST (ADR-056/061) — a trust-boundary control.
3. Modifies `.github/workflows/quality.yml` — the CI gate (Tier-B surface).
4. Extends the ADR-055 injection-scan surface (F2/F3).
5. Defines the trust/verification substrate two future rungs (v2.19 pull, v2.20 push) inherit.

**Caveat-calibration ruling.** @pm asked whether the mandatory-hard-gate applies at full strength or a justified lighter posture, given F1–F5 "write no instruction file into a live workspace." @architect framed the review-focus as gate-integrity/trust-boundary, full-strength ceremony, no new write channel.
- **I CONFIRM full-strength Phase-2 hard-gate + mandatory Phase-6 audit + no combined-path** (matches v2.16/v2.17 precedent). The **lighter posture is DECLINED.**
- **I ESCALATE one nuance in @pm's premise:** "no feature writes an instruction file into a live workspace" is true for F1/F4/F5, but **F3's ADR-068 re-scan step edits `self-apply/SKILL.md` — the very skill that governs live-workspace writes.** That is a self-modifying-surface touch, not merely format/schema work. It does not raise classification beyond SECURITY-SENSITIVE (already the ceiling), but it means the self-apply change earns the **same scrutiny as a guard change** — which OI-S6 (both axes) delivers and MF-S-3/MF-S-4 bind. @architect's "no new write channel" framing is CORRECT (the re-scan adds an inspection step, not a write path), so the focus framing is upheld with this one escalation recorded.

---

## OWASP Top 10 Assessment (Web A01–A10 + LLM Top-10)

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | PASS (bind MF-S-3) | Apply deny-list is the access-control surface; manifest entry must be explicitly added, evaluated-first. |
| A02 Cryptographic Failures | N/A | No secrets/crypto beyond SHA-256 content hashing (integrity, not confidentiality). |
| A03 Injection | PASS (bind MF-S-2/S-5) | Central axis — ADR-055 scan + F2 canonicalization; RED legs bound; pattern unforked (byte-confirmed). |
| A04 Insecure Design | PASS | Substrate = 4 independent primitives; no god-module; honest-limit posture explicit (HLD §11). |
| A05 Security Misconfiguration | PASS (bind SF-S-1) | quality.yml job reuses pinned actions; no new workflow file; no-pip check bound. |
| A06 Vulnerable/Outdated Components | PASS | All `uses:` SHA-pinned; no new action; stdlib-only python3. |
| A07 Auth Failures | N/A | No auth surface (static markdown/JSON kit). |
| A08 Data Integrity Failures | PASS (bind MF-S-1) | The whole substrate — drift-verify must carry a firing negative control (fail-closed proven). |
| A09 Logging/Monitoring | PASS | Fixtures self-report RED/GREEN; ledger keeps durable APPLIED/ROLLED-BACK trail. |
| A10 SSRF | N/A / PASS | AC-F4-4 no runtime fetch; WIZARD.md:26 Network/Offline Rule confirmed. |
| LLM01 Prompt Injection | PASS (bind MF-S-2/S-4) | Canonicalization + re-scan; homoglyph honestly FLAG-only (SF-S-3); re-scan reachability bound. |
| LLM02 Insecure Output Handling | PASS | Ledger/manifest content is DATA never instruction; verdict-style data-not-instruction discipline. |
| LLM06 Sensitive Info Disclosure | PASS (baseline clean) | AC-F1-2/XFER-4 = 0 today; external-consumer contract carries no wizard-runtime state; re-grep at Phase 6. |
| LLM08 Excessive Agency | PASS | Apply stays individually confirmed, deny-list-first, inspection-class re-scan not dressed as a gate; self-integrity preserved. |

---

## Guard Change Summary §I (finalized — copy-paste-ready for the PR description)

**What changed.** This cycle builds the shared *trust substrate* both future directions (pull v2.19, push v2.20) will stand on — it does **not** build either flow. Concretely: one canonical public format doc, a canonicalization pre-pass (fold look-alike/invisible characters before the injection-scan runs) delivered as a new CI job (no new workflow file), a per-workspace `cowork.install.json` install manifest added to the apply deny-list, an inspection-class re-scan step inside the mandatory `self-apply` safety skill, and one CI-computed `sha256` column on the curated-skills registry. **No feature writes any instruction file into a live workspace.**

**What could break** *(worst first, severity-tagged)*:
1. A firing negative control that silently can't fail — e.g., the registry drift-verify job or an F2 fixture that "passes" without ever proving it can catch a poisoned hash / an evasion. *(Possible. High harm — it would give false assurance to two future rungs.)* → closed by **MF-S-1** and **MF-S-2** (each must demonstrate its RED leg, matching the existing `lock-content-sha-fault-injection` model).
2. The `self-apply` re-scan being described but never reached (dead prose), so a hand-edited skill is never actually re-scanned. *(Possible. Medium harm.)* → closed by **MF-S-4** (concrete invocation named; fixture drives it).
3. The install manifest not being on the explicit apply deny-list, so a booby-trapped apply could rewrite install provenance. *(Unlikely. Medium harm — the line-55 catch-all already refuses it; MF-S-3 makes it explicit + evaluated-first.)*
4. The injection-scan being widened opportunistically, or PROMOTE.md running a raw (un-canonicalized) grep. *(Unlikely. Low-Medium harm.)* → closed by **MF-S-5** (byte-equality + single-source wiring).
5. Documentation overclaiming that canonicalization "catches" homoglyphs when it only FLAGS them to human review. *(Likely. Low harm — but erodes the honest-limit posture the kit depends on.)* → closed by **SF-S-3**.

**What's protected** (invariants that remain enforced — verified this session):
- `self-apply`'s own file stays non-apply-writable (deny-list evaluated FIRST, wins over the `*/SKILL.md` allow glob) — ADR-061 non-corruptibility intact; the new re-scan adds an inspection step, **no new write channel**.
- The ADR-055 6-token scan stays byte-identical (unforked) — confirmed at CONTRIBUTING.md:129.
- No runtime network (WIZARD.md:26); all hashing is CI-side (ADR-020 zero-code trust model).
- **Load-bearing control that makes the accepted risks acceptable:** the substrate is **curated-only**, so *maintainer review is the strictly-stronger layer* — no automated stage is load-bearing for untrusted content in this cycle. Every automated layer here is defense-in-depth beneath human review, and the honest limits are stated, not hidden.
- Adapter isolation holds: 0 Cowork-private keys in any skill body, 0 model-class assumptions in shipped format files (both grep-confirmed clean today).
- All GitHub Actions stay SHA-pinned; no new workflow file, no new `uses:`.

**What to verify after merge** (user-checkable signals — absence is the alarm):
- The next cycle (v2.19 `/spec`) starts **without** re-litigating where per-workspace install state lives — KDQ-MANIFEST is closed here.
- CI shows a new `canonicalize-scan-check` job **and** a registry drift/fault-injection job that visibly *fails on a poisoned fixture* (if either passes with no RED-leg evidence in its log, that is the alarm).
- The published `docs/substrate-contribution-format.md` reads as a self-contained pull contract with **no** "~9B / qwen / not-Claude" language and **no** "canonicalization catches homoglyphs" overclaim.

**What we could not prove:** whether the `self-apply` workspace-side re-scan will *actually fire in real use* — in a prose kit with no file-change event, it is honestly inspection-class (fires only when `self-apply` next processes an edited file), and Phase-2 review cannot prove model-adherence to a prose instruction. The AC-F3-2 fixture (MF-S-4) proves the mechanism *can* fire when driven; it cannot prove it *will* be reached on every real hand-edit. This is the substrate's stated honest limit (HLD §11), bounded by maintainer review as the stronger layer, and revisited when the platform exposes a file-change primitive (ADR-068 §Maturation revisit-trigger b).

---

**End of v2.18.0 — Phase 2 Security Review.**
