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

*End of Security Review — v2.17.0 The Steward (Auto-Cleaning).*
