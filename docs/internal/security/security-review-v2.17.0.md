# Security Review — Cowork Starter Kit v2.17.0 · The Steward (Auto-Cleaning)

## Phase: 2 (Architecture / Design review — MANDATORY SECURITY-SENSITIVE HARD GATE)
## Date: 2026-07-21T16:03:05Z
## Reviewer: @security (independent Phase-2 pass — Phase-0.D binding instruction #2: verify against SHIPPED PROSE, not intent)
## Branch: `feature/v2.17-steward-autoclean` @ `a7367d6` (design commit — `docs/spec.md` + `docs/architecture.md` + `docs/assumptions.md`, 236 insertions, docs-only)
## Status: **PASS WITH WARNINGS** — **0 CRITICAL**, **0 HIGH-unclosed**, 2 WARNING, 2 INFO. **Phase 3 is UNBLOCKED.**

> The hard gate's core requirement is MET: all four HIGH findings-in-waiting (FW-1..FW-4) are **verifiably designed-closed in the committed prose**, not merely asserted in a summary table. Each was traced to the enforcing AC/ADR text this session and cross-checked against the deliberation-log origin. The two WARNINGs are Phase-4 preconditions on the *verification/hygiene deliverables* (W-1), not holes in the four core gates.

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING | 2 | configuration | `C-v2.17-8` verifies W-1 archive non-publication against a **`/sync` skip-list — a mechanism the cowork kit does not have**. The only "sync" is `/sync-agency` (upstream→kit CI, unrelated to publishing user content). As written the check cannot be run → cannot catch a real leak (the repo's own binding *check-that-cannot-fail* anti-pattern). Reframe to the kit's real channel: workspace `.gitignore` + `.gitattributes export-ignore`, with a FIRING control. |
| S2 | WARNING | 2 | file-upload | W-1 requires `context/.archive/` gitignored + non-published and says it "mirrors the `context/.apply-backups/` precedent" — but the committed `.gitignore` excludes **neither**. There is no existing entry to inherit; Phase-4 must author it fresh. `context/` is NOT `export-ignore`d (v2.15 S3), so a belt-and-suspenders `.gitattributes export-ignore` for `context/.archive/` is also required. |
| S3 | INFO | 2 | permissions | The positive move-predicate treats a root-level, non-dotfile, non-`*.json` file that is not one of the 6 named convention files (e.g. `README.md`) as movable user content; the deny floor names `CONTRIBUTING.md`/`LICENSE` but not `README.md`. Acceptable (not auto-loaded, reversible) but @qa should confirm intended treatment of root docs with a Phase-5 fixture. |
| S4 | INFO | 2 | none | Positive signal: every safety AC ships a genuine FIRING negative control (`C-v2.17-1..10`) whose negative-control path produces RED — **none is a check-that-cannot-fail**. The design internalized the v2.15 S2 "check-that-cannot-pass" lesson; AC-VERIFYMOVE-2/3 and AC-ROLLBACKMOVE-2 each require the fault to be exhibited BEFORE trusting green. |

---

## The four HIGH findings-in-waiting — verified designed-closed against committed prose

**FW-1 (deny/allow completeness incl. token-bearing `.mcp.json`) — CLOSED.**
- ADR-063 (`architecture.md:10518`) inverts the gate to a **positive move-ALLOW-list with default-deny-by-namespace**: move-eligible ONLY IF the file affirmatively satisfies the user-content predicate AND destination is the archive convention. Default is DENY.
- AC-DENY-1 (`spec.md:4046`) names all six FW-1 paths in the floor: `.mcp.json` (token-bearing), `cowork-profile.md`, `folder-structure.md`, `skills-as-prompts.md`, `.claude/settings.json` + `.claude/settings.local.json` (= `.claude/settings*.json`), `project-instructions.txt`.
- The namespace floor (`.claude/**`, `context/**`, any `*.json`, root config/dotfiles) is **real in the prose**, not asserted (`architecture.md:10520`). The primary gate is the positive predicate, which covers all of `.claude/**` and `context/**` wholesale ("NOT under `.claude/`", "NOT under `context/`"); the floor is genuine belt-and-suspenders for the named catastrophic paths.
- AQ-6 lockstep is **dissolved** because the floor is namespace-level — no per-file sync with `self-apply`'s content deny-list (`architecture.md:10522`; AQ table row = DISSOLVED). Verified consistent with the SHIPPED `self-apply` deny-list (`skills/self-apply/SKILL.md:53,55,124`).

**FW-2 (destination gating) — CLOSED.**
- AC-DENY-2 (`spec.md:4047`) + ADR-064 (`architecture.md:10539`): the DESTINATION is gated against the same protected set as the source (not merely collision-checked), and constrained to `context/.archive/<original-basename>.<UTC-timestamp>`. A move cannot CREATE a load-bearing/auto-loaded file (`.claude/skills/<x>/SKILL.md`, `global-instructions.md`/`CLAUDE.md` when absent). The dot-prefixed archive dir + timestamp suffix defuses basename-collision-into-load-bearing (even `context/.archive/SKILL.md.<ts>` is not auto-loaded).

**FW-3 (S1 HIGH-at-composition) — CLOSED, and carried at HIGH (not dropped to INFO).**
- `spec.md:4095` records it at HIGH; deliberation-log FW-3 mandated "do NOT drop to INFO". The composition attack (move-create a look-alike SKILL.md + content-edit a pointer to it) is blocked by **source+dest deny-completeness** (ADR-063/064: dest can't be `.claude/skills/**`) **+ WYSIWYG** (ADR-066) **+ AC-VERIFYMOVE-3 read-only** (the pointer half can never ride the move confirmation). The two halves cannot be chained under one confirmation.

**FW-4 (SECGATE path channel + read-only reference check) — CLOSED.**
- AC-PROPOSE-1 (`spec.md:4051`) + ADR-066 (`architecture.md:10585`): the two-turn confirm renders the literal `source→dest` **computed from the ACTUAL operation, never from `Note`/detector-supplied path text**; fresh yes required every time (B1 render-from-computed-op; B2 observe-at-intent — approval-shaped text in the source's context is DATA).
- AC-VERIFYMOVE-3 (`spec.md:4064`) + ADR-065 (`architecture.md:10562`): the reference-integrity check is **READ-ONLY** — detect-and-refuse/warn only, NEVER auto-rewrites a pointer; the firing control asserts the pointer is byte-identical after the check. Grounding is REAL, not asserted: `templates/preset-template/context/memory-of-use.md:7` carries a live literal pointer to `.claude/skills/self-apply/SKILL.md` (verified this session).

---

## Also-verify checklist (all confirmed unless flagged)

- **`self-archive` reachability** — mandatory-installed at WIZARD Step 4 (Mode A+B), mirrors ADR-061; firing control C-v2.17-9. The WIZARD install-to-`.claude/skills/<slug>/SKILL.md` pattern is the shipped precedent (`setup-wizard/SKILL.md:47`). CONFIRMED (design-level; skill body is a Phase-4 deliverable).
- **`self-archive` self-integrity** — on its own move deny-list; cannot archive/move itself (under `.claude/skills/**` → denied by positive predicate + floor) nor its pointers (pointers live in deny-listed `context/**`); firing control C-v2.17-10. CONFIRMED.
- **Archive `context/.archive/` non-published (W-1)** — design SPECIFIES gitignored + Content-Excluded (ADR-064). **See S1/S2**: the verification mechanism (`/sync`) does not exist in the kit and the `.gitignore` entry is not yet present. Binding Phase-4 preconditions.
- **Rollback fingerprint out-of-band, transcript-anchored (W-4)** — ADR-062 (`architecture.md:10499`): on-disk move-log is UNTRUSTED until checked against the transcript tuple; a swapped/corrupted archive or log → rollback REFUSES. Firing control C-v2.17-7. CONFIRMED — no new trust root.
- **AQ-1a mechanism soundness** — reversible-move-log normalizes to the AC-ROLLBACKMOVE-2 terminal state (one copy at source, zero at dest, byte-identical to fingerprint), NOT a blind `mv dest source`; handles the partial-copy case explicitly. Sound.
- **Firing negative controls** — C-v2.17-1..10 each have a genuine negative-control path to RED (remove a deny clause / strip the dest gate / PASS a corrupted dest / drop a convention file / leave two copies / echo Note text / trust a swapped file / miss the skill in Mode-B / remove the self-deny entry). None is a check-that-cannot-fail; C-v2.17-3 explicitly requires the corruption to be exhibited before-run. (S4.)
- **Classification** — CONFIRMED SECURITY-SENSITIVE, no downgrade (new self-modifying write channel = file relocation, strictly larger blast radius than a content edit). Independent check: the committed diff is docs-only (spec/architecture/assumptions) yet the DESIGN introduces the relocation channel → SECURITY-SENSITIVE is correct regardless of the docs-only diff.
- **`.github/workflows/` touched? NO** — `git diff --name-only 01a298a..a7367d6` = 3 docs files only. Tier-B (PR-only) NOT fired by workflow changes. Standard SECURITY-SENSITIVE worktree+PR ceremony applies (already on branch).
- **Session-pin / env-var propagation surface** — NOT touched by this cycle (cowork kit, no session-pin machinery). N/A — no RISK-PRESENT.

---

## OWASP + LLM sweep on the new move op-class

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | ADDRESSED | The move channel IS filesystem access control. Positive allow-list + default-deny-by-namespace + destination gating + self-deny = fail-safe by construction. Named limit: inspection-class enforcement (prose + human confirm), not structural — see "What we could not prove". |
| A05 Security Misconfiguration | ADDRESSED via S1/S2 | Dot-prefixed archive = non-auto-loaded (correct). Archive must be gitignored + non-published (W-1) — not yet configured; binding Phase-4. |
| A06 Vulnerable/Outdated Components | CLEAN | No new dependencies; prose kit. `self-archive` reuses `self-apply` primitives by pointer. `npm audit` N/A (no package changes). |
| LLM01 Prompt Injection | DESIGNED-CLOSED | SECGATE renders the COMPUTED src→dest, never `Note`/detector text (B2 observe-at-intent); attacker approval-text + attacker path pair in source context still requires a fresh human yes on the computed pair (C-v2.17-6). Moved content is DATA, never executed; the reference-check is a literal grep needle, not code (a crafted basename cannot inject). |
| LLM06 Excessive Agency | CONTAINED | Detection is proposal-only (AC-DETECT-3, never moves/writes); two-turn confirm, no batching (AC-PROPOSE-2); read-only reference check never auto-rewrites (AC-VERIFYMOVE-3). Rollback carve-out (no fresh yes) is scoped to restoring prior-confirmed placement only. |

---

## Binding Phase-4 preconditions (from HIGH+/WARNING findings)

1. **[S1] Reframe C-v2.17-8** to the kit's real external-channel mechanism. Replace the `/sync` skip-list check with: (a) workspace `.gitignore` excludes `context/.archive/`, and (b) `.gitattributes export-ignore` covers `context/.archive/` (because `context/` itself is not export-ignored). Ship as a FIRING control: create a fixture `context/.archive/leak-fixture`, assert `git check-ignore` matches AND `git archive HEAD | tar t` omits it; remove the entry → fixture appears → RED.
2. **[S2] Author the W-1 exclusion fresh** — name the EXACT `.gitignore` that receives the entry (workspace vs kit repo). The "mirrors the `.apply-backups/` precedent" claim inherits no existing entry (`.apply-backups/` is itself un-gitignored — a latent v2.16 hygiene gap); recommend closing both in the same pass so pre-apply backups (which hold pre-edit copies of the user's instruction files) are not committable either.
3. **[S3] @qa fixture** confirming intended treatment of root-level docs (`README.md`) under the positive predicate — proposal vs refusal — so the boundary is decided, not incidental.

---

## Phase-3 Security Summary (plain-language — read this at the gate)

**PASS WITH WARNINGS — the design closes all four hard-gate risks; two Phase-4 hygiene items must be fixed before ship, neither blocks approval.**

**What the design does.** It adds a "Steward" that can *propose* moving a stale or superseded file in your workspace into a local archive folder (`context/.archive/`) — never silently. It reuses the v2.16 shape you already approved (confirm → apply → verify → roll back), now for a *move* instead of a content edit. It only ever moves files it can affirmatively prove are your own content; everything load-bearing (your instructions, skills, token-bearing `.mcp.json`, all config) is default-denied. A move that fails verification rolls itself back to exactly where it was.

**What could go wrong.**
1. The archive folder could leak sensitive moved content if it isn't excluded from publishing. *(Possible. Medium harm.)* The design requires it to be gitignored and never published — but the committed tree does not yet do that, and the check the design wrote points at a `/sync` mechanism this kit doesn't have. Both are fixed in Phase-4 (preconditions 1 & 2). **This is the one to watch.**
2. A stale reference (a pointer to a file that gets moved) phrased in prose rather than as a literal path won't be caught. *(Unlikely. Low harm — the move is reversible; named accepted limit W-2.)*
3. A root-level doc like `README.md` would be treated as movable. *(Possible. Low harm — not auto-loaded, reversible; @qa confirms intent.)*

**What's protected.** The four things that could have made a *move* dangerous are all designed-closed and traced to the enforcing text: (1) nothing load-bearing is movable — positive allow-list, default-deny by namespace, with your token-bearing `.mcp.json` explicitly named; (2) a move can't *create* a dangerous file at its destination; (3) the two-step "look-alike skill + rewire a pointer" attack can't be chained under one confirmation; (4) the confirmation always shows you the *real* computed source→destination, never text a file can plant, and the tool never silently rewrites a pointer. **The load-bearing control is your fresh yes at the two-turn confirmation** — that human step is the actual security boundary (see below).

**What to verify after merge.** In the next Phase-5/6 run you should SEE: (a) a fixture that puts a file in `context/.archive/` and then proves `git` ignores it and a release archive omits it — its *absence* from the archive listing is the alarm if it's missing; (b) each "firing control" (C-v2.17-1..10) actually going RED when its guard clause is removed — a control that stays green when broken is the alarm.

**What we could not prove.** The entire safety model is **inspection-class** — it rests on the skill's prose being followed and on your fresh yes at the confirmation. Nothing in Cowork *structurally* prevents a write outside the deny-list (the shipped `self-apply` skill states this plainly at line 57 for the content channel; it is identical for the move channel). This is inherited from v2.16, is correctly named in ADR-062's maturation path, and is **not a new defect** — but it is the thing to understand: this design makes the *right* thing easy and visible and reversible; it does not make the wrong thing structurally impossible. That guarantee waits on a future code-execution layer (v2.18+).

---

# Phase 6 — Code Audit (SECURITY-SENSITIVE, at shipped HEAD)

## Phase: 6 (Code Audit — MANDATORY, no combined-path)
## Date: 2026-07-21T21:15:00Z
## Reviewer: @security (independent Phase-6 pass — audited the SHIPPED BYTES via grep/git-verify, not intent)
## Branch: `feature/v2.17-steward-autoclean` @ `7cca4fc` (code `a3241f9` + QA `7cca4fc`; `main..HEAD` = `7cca4fc`+`a3241f9`+`720b0de`+`a7367d6`, no drift)
## Status: **PASS WITH WARNINGS** — **0 CRITICAL**, **0 HIGH**, **1 WARNING (new, S5)**, 1 INFO. **Phase 7 is UNBLOCKED**, with S5 as a documented pre-sign-off condition (below).

> All four Phase-2 HIGH findings-in-waiting (FW-1..FW-4) re-confirmed CLOSED against the shipped `skills/self-archive/SKILL.md`, `.gitignore`, `.gitattributes`, and `WIZARD.md`. The single new Phase-6 finding (S5) is the @qa Phase-5 residual, adjudicated below as an **acceptable named residual conditional on one prose/floor correction** — NOT a merge-blocker. No secrets in the diff. `.github/workflows/` NOT touched → no Tier-B.

## Findings Summary (Phase 6)

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S5 | WARNING | 6 | permissions | Move-eligibility predicate mis-classifies the **root-level `*.md` convention-file class**: a hypothetical future 7th root `.md` convention file (not among the 6 named, not `README*`) evaluates as ELIGIBLE, contradicting ADR-063's own default-deny invariant. The shipped "belt-and-suspenders … caught by namespace, not by an update to this list" prose (`skills/self-archive/SKILL.md:42`) is FALSE for this class. Zero live exploit (no such file exists; all named paths denied today). Adjudicated: acceptable named residual CONDITIONAL on correction before Phase 7. Recommended fix = structural root-`.md` default-deny floor. |
| S6 | INFO | 6 | configuration | `docs/roadmap.md:31` "Rung notes" retains stale deferred-path wording (pre-existing, already flagged by @dev/@qa). Doc-text only, non-functional. |

## FW-1..FW-4 re-confirmation (shipped bytes, grep/git-verified)

**FW-1 (deny/allow completeness incl. token-bearing `.mcp.json`) — CLOSED on shipped bytes.**
- `skills/self-archive/SKILL.md:38-46`: deny-list evaluated FIRST and "always wins"; positive allow-list applies ONLY past every deny check (default = DENY, line 46).
- Namespace floor (line 42) real in prose: `.claude/**`, `context/**`, any `*.json`, root config/dotfiles. All 6 FW-1 load-bearing paths named: `.mcp.json` (token-bearing), `cowork-profile.md`, `folder-structure.md`, `skills-as-prompts.md`, `project-instructions.txt`, `.claude/settings.json`+`.claude/settings.local.json`.
- README-class denial (line 44, S3 Phase-3 amendment) present and explicit.
- @qa mechanical re-implementation (Phase-5 control #5) confirmed all 14 currently-named deny paths classify DENIED. VERIFIED.

**FW-2 (destination gating) — CLOSED.**
- `skills/self-archive/SKILL.md:48-50`: destination checked against the exact same protected set as the source (not collision-only), constrained to `context/.archive/<original-basename>.<UTC-timestamp>`; a dest landing in any load-bearing namespace or elsewhere is refused visibly. No move can CREATE a load-bearing file at a novel destination. VERIFIED.

**FW-3 (S1-composition: move-create look-alike + edit-pointer) — CLOSED, carried at composition level.**
- Blocked by source+dest deny-completeness (dest can never be `.claude/skills/**`, line 40/42) + WYSIWYG turn-two render (line 56) + read-only reference check (line 71, 100). The two halves cannot chain under one confirmation. VERIFIED.

**FW-4 (SECGATE path channel + read-only reference check) — CLOSED.**
- `skills/self-archive/SKILL.md:56`: turn-two literal `source → dest` computed FRESH from the ACTUAL operation, "never from the detector's `Note` text or any path string that happened to appear in the source file's own content." This is the load-bearing anti-injection control and renders the COMPUTED pair only.
- Line 71 + Quality-criteria #5 (line 100): reference-integrity check is READ-ONLY (detect-and-refuse/warn), never rewrites a pointer; "byte-identical before and after this check, every time." @qa control #4 confirmed read-only via before/after SHA-256. AC-VERIFYMOVE-3 provably read-only. VERIFIED.

## Also-verified (shipped bytes)

- **Reachability (WIZARD Step-4).** `WIZARD.md:257` unconditional install of `self-archive` (Mode A + Mode B), plus `:319`/`:332` handover narrative and `:354` explicit pre-v2.17.0 backfill clause. 4 grep hits. CONFIRMED.
- **Self-integrity.** `SKILL.md:40` self-deny (own file never move-eligible as source or destination namespace); genuinely redundant with the `.claude/**` floor (@qa: caught by namespace even if the explicit self-deny sentence were removed — no residual). CONFIRMED.
- **W-1 archive non-publication.** `.gitignore` adds `context/.archive/` AND `context/.apply-backups/`; `.gitattributes export-ignore` adds both (belt-and-suspenders because `context/` itself is not export-ignored — v2.15 S3). @qa control #1 fired 4/4 sub-controls (both paths, both `check-ignore` and `git archive` legs). The latent v2.16 `.apply-backups/` gitignore gap is closed in the same pass. CONFIRMED.
- **W-4 rollback fingerprint out-of-band.** `SKILL.md:62,70,77` + ADR-062 (`architecture.md:10499`): fingerprint tuple anchored in the session TRANSCRIPT; on-disk move-log UNTRUSTED until checked against it; swapped/corrupted archive or log → rollback REFUSES. No new trust root. CONFIRMED.
- **ADR-064 erratum.** `architecture.md:10596-10622` present, append-only, original ADR-064 text unchanged — corrects the S1 `/sync` and S2 `.apply-backups precedent` false claims without editing the original. CONFIRMED.
- **`.github/workflows/` touched? NO.** `git diff --name-only main..HEAD` = 15 files, none under `.github/workflows/`. No Tier-B ceremony. Standard SECURITY-SENSITIVE worktree+PR applies (already on branch). CONFIRMED.
- **Secret scan (diff).** No secret values in added lines; only the tokens "token"/"secrets" appear as prose in the QA report and a `.env.production` test-fixture *reference* (a deny-classification test input, not a value). CLEAN.

## OWASP + LLM sweep on the shipped move op-class (Phase 6)

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | ADDRESSED | Shipped predicate = positive allow-list + default-deny floor + destination gating + self-deny. Named residual S5 (root-`.md` class) below; live blast radius today = zero. Inspection-class (prose + human confirm), not structural — inherited from v2.16, named in ADR-062 maturation path. |
| A05 Security Misconfiguration | ADDRESSED | Archive is dot-prefixed (non-auto-loaded) AND now gitignored + export-ignored (W-1 shipped, @qa 4/4). |
| A06 Vulnerable/Outdated Components | CLEAN | No dependency changes; prose kit. `npm audit` N/A. |
| LLM01 Prompt Injection | DESIGNED-CLOSED | Turn-two renders the COMPUTED src→dest, never `Note`/source-body text (SKILL.md:56); moved content is DATA, never executed; reference-check is a literal grep needle. |
| LLM06 Excessive Agency | CONTAINED | Detection proposal-only (line 34); two-turn confirm, no batching (lines 52-58); read-only reference check (line 71); rollback carve-out scoped to restoring prior-approved placement (line 79). |

## ADJUDICATION — @qa Phase-5 New Finding (belt-and-suspenders namespace overstatement)

**The gap (demonstrated, not hypothetical).** @qa mechanically re-implemented the positive predicate's conditions (a)–(f) as literally written in `SKILL.md:46` and ran a root-level `.md` file that is not one of the 6 named convention files and not `README*` (e.g. `workspace-manifest.md`): it evaluates **ELIGIBLE** every time. This contradicts ADR-063's own stated invariant ("The DEFAULT is DENY … a new load-bearing file added tomorrow is denied automatically", `architecture.md:10518`). The floor's belt-and-suspenders prose ("a file added tomorrow is still caught by namespace, not by an update to this list", `SKILL.md:42`) is **FALSE for the root-`.md` convention-file class** — that class is protected only by explicit enumeration, i.e. exactly the per-file forever-obligation ADR-063 was written to escape.

**Severity of the LIVE risk: LOW.** No such 7th root `.md` convention file exists today; every FW-1 path and every Phase-3-amended path IS denied. Even in the future-file case, a move requires (1) qualifying on an evidence class (explicitly-superseded, or unreferenced-and-aged ≥90d), (2) a four-part turn-one proposal the human sees, (3) a fresh human yes on the literal computed pair at turn two, (4) full reversibility via the transcript-anchored rollback, into a (5) gitignored, export-ignored destination. Owner-locked to auto-cleaning only. The blast radius is bounded by two fresh human confirmations and is reversible — it cannot reach a live-exploit severity.

**Disposition: ACCEPTABLE NAMED RESIDUAL (W-5), CONDITIONAL on one correction before Phase 7 sign-off. NOT a Phase-6 merge-blocker / not a hard FAIL.** Rationale: an honest severity read cannot inflate a zero-live-exploit, human-gated, reversible, future-only maintenance gap into CRITICAL/HIGH — doing so would be an unearned RED. Two independent prior reviewers (Phase-2 S3 INFO, Phase-5 ISSUE) landed non-blocking; I concur on the live risk. **However**, the shipped *prose actively asserts the opposite of the truth* on the FW-1 deny-completeness surface — that is materially worse than an honestly-named limitation (contrast W-2/W-4, which state their limits plainly) and cannot ship uncorrected. The finding is therefore a WARNING with a required disposition, not an unconditional pass.

**Two ways to close it (either satisfies the condition):**
1. **STRUCTURAL — recommended.** Add a **root-level `*.md` default-deny floor** to the namespace floor: any bare `<workspace-root>/*.md` is denied by default (identical location-class treatment already given to root dotfiles and root config in the same floor). This has **zero legitimate-use cost** — genuine disposable user content lives under `context/` and working folders, never as a bare root `.md`; root `.md` files are convention/instruction/docs by location. It makes the predicate's own "caught by namespace" claim TRUE, eliminates the per-file obligation entirely, and realigns the shipped predicate with ADR-063's stated invariant. This is the correct permanent closure and matches this project's structural-over-prose discipline.
2. **PROSE — minimum acceptable fallback.** Reword `SKILL.md:42` to scope the "caught by namespace" claim to the four genuinely namespace-coverable classes and add one explicit line naming the residual (mirroring W-2's prose-reference residual): "a new root-level `.md` convention file introduced in a future cycle is NOT automatically caught by namespace and MUST be added to this list by hand." `docs/assumptions.md` A-v2.17-5's "stays correct without per-file lockstep maintenance" claim must be scoped identically. This converts a false claim into an honest named residual but leaves the eligibility gap live (just documented).

Recommend option 1. Either is a docs-only ~2-line change, well within a prose-fix and not a code rework.

## Phase-6 Security Summary (plain-language)

**PASS WITH WARNINGS — the shipped bytes close all four hard-gate risks (FW-1..FW-4), no secrets, no CI-workflow surface. One documentation-accuracy warning (S5) on the deny-list must be corrected before final sign-off; it is not a live vulnerability.**

**What could go wrong.**
1. A *future* root-level `.md` convention file (none exists today) would be treated as movable, and the shipped prose wrongly says it's auto-protected — a maintainer could believe they don't need to add it. *(Possible, future-only. Low harm — reversible, two-turn human-confirmed, owner-locked, gitignored dest.)* **This is S5 — correct before Phase 7 (structural floor recommended).**
2. A stale pointer phrased only in prose (no literal path) isn't caught by the reference check. *(Unlikely. Low harm — reversible; named limit W-2, unchanged.)*

**What's protected.** Nothing load-bearing is movable (positive allow-list + default-deny floor, `.mcp.json` explicitly named); a move can't create a dangerous file at its destination; the look-alike-skill + rewire-pointer attack can't chain under one confirmation; the turn-two confirmation always shows the real computed source→destination, never text a moved file can plant. **The load-bearing control remains the human's fresh yes at the two-turn confirmation** — the same inspection-class human boundary v2.16 shipped; not made structurally impossible, correctly named in ADR-062's maturation path (v2.18+).

**What we could not prove.** The safety model is inspection-class — it rests on the skill's prose being followed and the human's fresh yes. Nothing in Cowork *structurally* prevents a write outside the deny-list (identical to the v2.16 content channel). Not a new defect; inherited and correctly documented. This design makes the right thing easy, visible, and reversible; it does not make the wrong thing structurally impossible — that waits on a future code-execution layer.

---

*End of Phase-6 Code Audit — v2.17.0 The Steward (Auto-Cleaning).*

---

*End of Security Review — v2.17.0 The Steward (Auto-Cleaning).*
