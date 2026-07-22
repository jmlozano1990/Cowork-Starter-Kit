# Changelog

All notable changes to this project are documented here. This project uses [Semantic Versioning](https://semver.org/).

---

## [2.19.1] - 2026-07-22

**Documentation.** Front-page message refresh — no functional change. `README.md` repositioned from "builds a personalized, skill-equipped workspace" (setup-only) to "builds a workspace that then keeps itself sharp" (setup + self-maintenance), surfacing the v2.15–v2.19 living-workspace arc (mini-Council friction-noticing, self-apply, self-archive, pull-updates, and the dormant self-upgrade contract) that had shipped but was invisible on the front page. The README's "Why trust it" summary gains a third, self-integrity threat class alongside the two existing supply-chain threats, carrying TRUST.md's honest containment framing (inspection-class and human-boundary, not a structural guarantee). The 12-entry "What's new in vX.Y" version wall is replaced with a short "Recent releases" pointer to CHANGELOG/Releases. The stale "Next up" teaser is refreshed to the current roadmap: v2.20 demand-gated community intake, v3.0 spawn-only Engine.

### Changed

- `README.md` — hero tagline, new "Two things this kit does" section, reworked "Why trust it," reworked Highlights (living-workspace bullet), condensed "Recent releases" replacing the 12-entry "What's new" stack, refreshed "Next up," minor "Safety first" and "Staying up to date" additions pointing at `pull-updates`.
- `VERSION` — 2.19.0 → 2.19.1.

---

## [2.19.0] - 2026-07-22

**"The Persistency Layer"** — the v2.18.0 substrate's first real consumer. Two distinct faces, kept textually separate throughout: **Face 1 (skill-content pull)** lets a workspace check its installed curated skills against the on-disk pool and offer safe, conflict-aware updates; **Face 2 (kit-version upgrade contract)** lays the engine-walk-forward seam and a dormant-but-reachable mechanism for replacing a workspace's own framework machinery across future kit versions. Highest self-modification blast radius in the kit's history (Face 2 rewrites the running framework) — full-strength security review, 12 binding MUST-FIX items, all discharged with real firing controls.

### Added

- **`pull-updates` — new mandatory infrastructure skill (Face 1, KDQ-PULL).** Classifies every installed curated skill from **freshly-hashed bytes on both sides** (on-disk vs. curated pool, computed fresh every session) — never from the workspace's own `cowork.install.json` manifest label, which is treated as attacker-influenceable (trust-transitivity, ADR-072). Four outcomes: untouched (safe single-item offer), user-customized (conflict surfaced, no silent overwrite), user-authored/not-in-pool (never pull-eligible), and a new `manifest-drift` 4th state for a dangling manifest entry whose file no longer exists on disk. A malformed or schema-invalid manifest refuses to offer or apply anything rather than guessing. No in-session network call, ever. `pull-updates` is also the standing mechanism that backfills the three mandatory safety skills into any pre-v2.19 workspace that runs it, byte-verifying each against the curated registry's `sha256` before it goes live (poisoned-backfill defense, ADR-073).
- **`self-upgrade` — new mandatory, deny-listed safety skill (Face 2, KDQ-UPGRADE, ADR-071).** The third sibling to `self-apply`/`self-archive`, reusing their confirm→apply→verify→rollback primitives **by reference**, never re-declaring them. Ships **dormant** at v2.19 (zero real forward-walk targets — no v3.0 exists yet) but installed and reachable now, so no future rung has to backfill the gate itself. Carries the **self-integrity invariant**: any change to safety machinery (the deny-lists, the verifier, `scripts/canonicalize-scan.sh`, or any of the three safety siblings) is a distinct, higher-ceremony step that verifies new machinery **under the pre-upgrade gate before it goes live** (verify-then-swap, never the reverse) — the `kit_version` write-back is a contract bound now, executed at the first real rung.
- **`scripts/semver-compare.sh` — deterministic semver comparison.** Parses major/minor/patch as integers; a naive string compare is the trap this closes (`"2.9.0" > "2.19.0"` lexically, wrongly, since `9` outranks `1`). `self-upgrade` uses this script for its upgrade-readiness check rather than model judgment.
- **`context/.kit-migrations/` — the migration-provenance seam (ADR-074).** A fixed convention directory holding an append-only, on-disk-local-only log a future rung reads its prior state from and writes its own provenance into. Unwritten at v2.19 (no target); on both `self-apply`'s and `self-archive`'s deny-lists.
- **Namespace-complete safety deny-list (`self-*` reserved prefix).** `self-apply`'s apply deny-list now denies the whole `self-*` prefix (explicitly naming all three: `self-apply`, `self-archive`, `self-upgrade`), closing a gap where the ordinary `.claude/skills/*/SKILL.md` allow-glob could otherwise reach a sibling safety skill. Scoped to the runtime apply channel only — the trusted installer/backfill ceremony `pull-updates` uses is a separate, ungated-by-design channel (bootstrapping-trust), not a carve-out in this deny-list.

### Changed

- `WIZARD.md` Step 4 now installs `self-upgrade` and `pull-updates` unconditionally (Mode A and Mode B), alongside `self-apply`/`self-archive`; the Fallback "existing workspace" flow backfills all four for any pre-v2.19 workspace.
- `curated-skills-registry.md` gains a `self-upgrade` row (Mandatory Safety Skills) and a `pull-updates` row (new Mandatory Infrastructure, non-deny-listed subsection), both with CI-verified `sha256`.

## [2.18.0] - 2026-07-22

**"The Substrate (slim)"** — opens the substrate contribution format the Cowork Evolution Program's next rungs (v2.19 pull, v3.0 spawn) build on: a public, runtime-agnostic contract naming the existing 9-section `SKILL.md` shape as the one format both push (`PROMOTE.md`) and a future pull direction target, plus the integrity plumbing — a per-workspace install manifest and a CI-computed registry hash column — that a future pull step needs to trust what it reads. This increment ships the format and the plumbing only; the pull flow itself is deferred to v2.19.

### Added

- **`docs/substrate-contribution-format.md` — the public contribution-format contract.** Names the 9-section `SKILL.md` template as the single, unforked format for both directions of the skill economy (push via `PROMOTE.md`, a future pull flow), states the Cowork-private-key boundary that keeps routing concerns (`core_skills:`, `optional_skills:`, `wizard_hook`, `preset_route`) out of a skill body, and states plainly what the deterministic scan does and does not catch — an honest-limits section covering homoglyph evasion, the bounded zero-width strip, and scan-section coverage. Kept public (not under `docs/internal/`) on purpose: it is the exact spec an external format consumer reads without touching this kit's own wizard code.
- **Canonicalization pre-pass + re-scannable forbidden-token scan (`scripts/canonicalize-scan.sh`), new CI job.** A single-sourced, fixed-order pipeline — Unicode NFKC normalization, a bounded zero-width strip (U+200B, U+200C, U+200D, U+FEFF), mixed-script flagging (routes to human review, never auto-corrects), then the existing unforked six-token pattern scan — runs at every call site: the pool's own CI gate, the promotion ceremony, and a workspace's own re-check of an edited installed skill. No call site re-implements the pipeline independently.
- **`cowork.install.json` — per-workspace install manifest, plus lock trichotomy.** A standalone, workspace-root file recording which curated skill version a given workspace installed and at what content hash, deny-listed on the mandatory `self-apply` skill so no confirmed-apply write can ever rewrite it. Its two hash comparisons (registry version vs. installed version; on-disk hash vs. installed hash) are kept always distinct, driving a deterministic three-outcome classification — not-in-pool, untouched, or user-customized — so a future update offer never silently overwrites an edited copy. A matching template ships at `templates/cowork.install.template.json`.
- **CI-computed `sha256` column on `curated-skills-registry.md`.** The registry's existing 6-column schema gains a 7th column: the 64-char lowercase hex content hash of each skill's `SKILL.md` bytes at its pool location, computed and drift-verified by CI — never hand-entered. This is the integrity anchor an external puller (or a future in-kit pull flow) reads to verify a pool skill's bytes without re-deriving trust from anything else.

### Deferred

- **The pull flow itself** — a workspace reading `cowork.install.json` + the registry to offer, apply, and record a curated-skill update. This increment ships the manifest and the registry hash it depends on; v2.19 is the first real consumer.
- **Capability transfer to a specific external runtime** — the contribution format proves format transfer only. Confirming a skill behaves the same on a named external runtime (e.g. Confidante) requires a dedicated evaluation pass against that runtime, not assumed from the format alone.

## [2.17.0] - 2026-07-21

**"The Steward (Auto-Cleaning)"** — extends the v2.16.0 confirm→apply→verify→rollback machinery from content edits to a new operation TYPE: file relocation. A stale or superseded file can now be *proposed* for archiving (never silent, never deleted) into a local `context/.archive/`, gated by a positive move-allow-list (default-deny-by-namespace), destination gating, a read-only reference-integrity check, and a reversible-move-log rollback anchored by an out-of-band fingerprint. Scope is auto-cleaning only this increment — living-organization and promote-repetitive-to-Skill are deferred.

### Added

- **Sibling `self-archive` skill (ADR-066).** New mandatory, deny-listed skill `.claude/skills/self-archive/SKILL.md`, installed unconditionally at WIZARD Step 4 (Mode A + B) alongside `self-apply`, reusing its primitives by pointer rather than folding a second operation type into the same verifier module. It is on its own move deny-list — it can never archive or move itself.
- **Positive move-ALLOW-list / default-deny-by-namespace (ADR-063).** Inverts v2.16's content deny-first posture for the move channel: a file is move-eligible ONLY IF it affirmatively satisfies the user-content predicate (outside `.claude/**`, outside `context/**`, not a named root convention/config file, not a dotfile, not `*.json`). A default-deny floor by namespace catches the six FW-1 load-bearing paths (including token-bearing `.mcp.json`) even if the predicate had a hole. Root `README.md`-class docs are also denied (owner decision at the Phase-3 gate).
- **Destination gating + the `context/.archive/` convention (ADR-064).** A move cannot land anywhere but `context/.archive/<basename>.<UTC-timestamp>`, and the destination is checked against the same protected set as the source — a move can never CREATE a load-bearing file by relocation.
- **Reversible-move-log + out-of-band fingerprint (ADR-062).** A move's rollback primitive is a location operation, not a content pre-image: the source/dest/fingerprint tuple is recorded in the session transcript, and rollback normalizes to a defined terminal state (one copy at source, zero at dest, byte-identical to the fingerprint) rather than a blind reverse move.
- **Read-only, scoped-enumerated reference-integrity check (ADR-065).** Before a move lands, a literal grep across a defined convention-file set catches a source path still referenced elsewhere and refuses or rolls back — never auto-rewrites the pointer it finds.
- **Path-channel SECGATE (ADR-066, reusing ADR-058 B1/B2).** The two-turn move confirmation always renders the literal `source → dest` pair computed from the actual operation, never from detector text or anything found inside the source file's own content.
- **Archive non-publication (`.gitignore` + `.gitattributes export-ignore` for `context/.archive/` and `context/.apply-backups/`).** Reframed from the original design's `/sync`-based check (this kit has no such mechanism — Phase-2 finding S1) to the kit's real channel; closes a latent v2.16.0 gap where `context/.apply-backups/` was never actually gitignored (S2).

### Deferred

- **Living-organization** — `folder-structure.md` becoming a maintained contract the workspace keeps current (out of scope this increment, owner-locked).
- **Promote-repetitive-to-Skill** — routing a recurring memory-of-use friction into a proposed new Skill (out of scope this increment, owner-locked).

## [2.16.0] - 2026-07-21

**"Mini-Council — Loop 1, Increment 2 (Apply + Verifier-Gate)"** — closes Loop 1: a confirmed proposal from `[2.15.0]` can now actually be applied. The security posture inverts from `[2.15.0]` by design: that release's safety argument was structural (no code path could write an instruction file); this one opens a real, bounded write channel, contained by a deny-first allow-list, a two-turn literal-diff confirmation, an executable verifier, and rollback — honestly weaker than the prior structural guarantee, and stated as such.

### Added

- **Apply on confirmation (ADR-057).** A confirmed ledger entry gets a second, apply-specific confirmation: the literal diff is re-derived from the file's current bytes and rendered in full before the write, and the write commits exactly those rendered bytes in the same turn (`confirmed-bytes == applied-bytes`). A ledger row edited between the two confirmations surfaces in the re-rendered diff or trips the verifier and rolls back — never a silent mismatched write.
- **A deny-first write-channel allow-list (ADR-056).** Apply-writable: `.claude/skills/*/SKILL.md`, the workspace `CLAUDE.md`, four `context/` preference files, and `global-instructions.md`. Hard-denied ahead of any allow match: the ledger `context/memory-of-use.md` itself and `context/.apply-backups/**`. Everything else — including the archived installer, root `.github/`, and `CONTRIBUTING.md` — is refused, visibly, never silently. Stated honestly as inspection-class and human-boundary containment, not a structural guarantee; the surviving structural bound is narrower — it covers only other users' workspaces and the shared upstream repo.
- **Two confirm-before-apply controls (ADR-058).** An inline courtesy flag scans for approval-shaped language in the ledger note before it's ever rendered (distinct from, and in addition to, the existing injection-shape scan) — explicitly not load-bearing. The actual gate is two independently checkable controls: the write only ever follows immediately after a fresh confirmation, and ledger content is never treated as that confirmation, no matter how it's phrased.
- **The verifier gate (ADR-059), reusing the `skill-studio` grader.** Before landing, an applied change is checked against a paired before/after fixture reproducing the recorded friction, and independently re-checked against the file's own pre-existing safety exercises so a coherent-looking fix can't quietly drop one. Either check failing rolls the change back.
- **Rollback with a write-once, integrity-anchored pre-image (ADR-059).** The pre-apply bytes are saved before any write, with a fingerprint recorded in the session transcript — a surface no apply can itself rewrite — and checked against that anchor before any rollback trusts it. A swapped or corrupted backup refuses rollback rather than restoring something unverified.
- **CLAUDE.md-specific post-apply integrity (ADR-059).** When the applied target is the workspace `CLAUDE.md`, the verifier additionally checks the 400-word ceiling and whole-string section/marker integrity — this workspace file isn't covered by the kit's own CI, so this is its only guard.
- **No batching, checked per occurrence (ADR-060).** More than one ready entry always gets separate, full confirmations — never combined into one prompt — and the confirmation surface is checked to stay byte-identical in shape from the first occurrence to the Nth, never quietly shortened over time.
- **`TRUST.md`** rewrites its fourth threat class and its "never quietly rewrite itself" claim to match the delivered mechanism: the workspace can now write to a bounded allow-list, gated by confirmation, verification, and rollback — weaker than the prior structural claim, stated plainly rather than left stale.
- **Relocated `context/memory-of-use.md` → `templates/preset-template/context/memory-of-use.md` (S4).** Joins its sibling convention files (`about-me.md`, `output-format.md`, `working-rules.md`) in the established canonical-shape location; the stray root-level `context/` directory is removed. A live workspace's own copy still lives at its own root, unchanged.

### Phase-5 rework — behavior-surface relocation (ADR-061)

- **New mandatory skill `skills/self-apply/SKILL.md`, installed unconditionally at WIZARD Step 4 (Mode A + Mode B).** The entire apply/verify/rollback/SECGATE machinery and the ledger's schema/counting/status-vocabulary convention move out of the lazily-created `context/memory-of-use.md` body — where it had no guaranteed path to exist the first time it was needed (REWORK-1) — into this always-installed skill, and onto the AC-APPLY-3 hard deny-list ahead of the `.claude/skills/*/SKILL.md` allow glob, so the apply channel can never rewrite its own governing rules (REWORK-2). `context/memory-of-use.md` reverts to DATA-only: the data-not-instruction line, a one-line pointer to `.claude/skills/self-apply/SKILL.md`, the Ledger, and the Archive. The two bootstrap pointers (`templates/workspace-claude-md-template.md`'s "Noticing friction" section, `skills/weekly-review/SKILL.md` step 6) name that exact path instead of the prior circular "the file's own convention." New AC-REACH-1 (reachability) and AC-INTEGRITY-1 (self-integrity by relocation), each with a firing negative control.

### Deferred (tracked for a future increment)

- Confirmation batching as a feature (KDQ-8) — the no-batching *constraint* ships this release; the convenience feature itself does not.
- Loop 3 — the community two-tier submission tier.
- S7/S8 (shellcheck scandir gap; ADR-050 stray-file residual) — this release makes no `.github/workflows/quality.yml` change, so neither is triggered this cycle.

---

## [2.15.0] - 2026-07-20

**"Mini-Council — Loop 1, Increment 1 (Notice & Record)"** — opens Loop 1 of the Cowork Evolution Program: a personal, workspace-local memory of its own use, and a periodic + threshold-triggered loop that can propose a self-improvement in plain language. This increment notices, records, and proposes only — it never applies a self-modification. The apply step is a later, separate increment.

### Added

- **`context/memory-of-use.md` (ADR-053) — the workspace memory-of-use ledger.** A single, lazily-created file (never scaffolded empty into a new workspace) holding a 6-column markdown table (`Entry | Status | Occurrences | Note | First noticed | Last updated`), a verbatim data-not-instruction header contract, and a bounded `## Archive` section for entries in a terminal state. This release ships the canonical convention/example only; a real workspace's own copy is created the first time a note-worthy friction actually occurs.
- **Per-calendar-day threshold counting (ADR-054).** A friction signature's `Occurrences` counter increments at most once per calendar day, measured by the ledger's own `Last updated` field — deterministically checkable, and proven able to genuinely fail its own negative control (same-day repeats stay put; a distinct day increments). Three distinct days promotes an entry through `NOTICED (1/3)` → `WATCH (2/3)` → `READY-TO-PROPOSE (3/3)`, a one-time terminal trigger, never a repeating counter.
- **`skills/weekly-review/SKILL.md` — new "Surface" step.** The existing Collect → Process → Review → Plan pass gains a 5th step: it checks the ledger for anything this week's pass surfaced, writes or updates an entry, and — if that update reaches `3/3` — runs the proposal immediately, in the same pass, rather than waiting for next week. The 4 existing steps are unchanged.
- **The PROPOSE surface (two-layer data-not-instruction control, ADR-055).** Reaching `3/3` — from the weekly pass or noticed mid-session — surfaces a plain-language proposal in the repo's existing four-part shape (What changed / What could break / What's protected / What to verify). Before any ledger text is quoted into that proposal, it is re-scanned with the same forbidden-token recipe this repo already uses (`CONTRIBUTING.md:129`); any match is flagged inline, never obeyed. The one hard boundary: this increment never writes to any `CLAUDE.md` or `SKILL.md`, under any response — the only file it can write is the ledger itself, and marking an entry confirmed always requires an explicit yes.
- **`templates/workspace-claude-md-template.md`** gains a small, fixed-size (non-scaling) `## Noticing friction` pointer instructing the session to note a repeated correction to the ledger, creating it if absent, without interrupting to announce it.
- **`TRUST.md`** names a fourth threat class — a self-modifying local instruction surface — and states what this kit does about it: no write channel to any instruction file, explicit confirmation required, and a mandatory, permanent security review for every Loop 1 increment regardless of blast radius.

### Deferred (tracked for a future increment)

- The apply step and its verifier gate (KDQ-2) — turning a confirmed proposal into an actual file change, safely. This increment stops before it on purpose.
- Confirmation-fatigue/batching (KDQ-8) if PROPOSE fires often in practice.
- Loop 3 — the community two-tier submission tier.

---

## [2.14.0] - 2026-07-20

**"Skill Studio — Increment 2c (Promote-to-Pool)"** — closes the promotion path named as Deferred in both `[2.12.0]` and `[2.13.0]`: a locally-generated skill that has earned it (passed both v2.13 grading axes, in a fresh re-run at promotion time) can now graduate from a workspace's own `.claude/skills/` into the shared curated pool. This release ships the ceremony only — no skill is promoted this release, and `skills/`, `curated-skills-registry.md`, `.claude/skills/`, and `selection-presets.md` are all byte-unchanged.

### Added

- **`PROMOTE.md` (ADR-051) — the promote-to-pool ceremony.** A documented, explicitly-invoked procedure (not a meta-skill, not a new step in `skill-studio`'s loop) that turns a graded local skill into a PR-gated Tier 1 pool addition. The eligibility gate, in order: a real `## Example` present; a **fresh** re-run of both WS-EVAL and WS-EVALSAFE grading at promotion time (never a stored result); an independent forbidden-token re-scan; collision and reserved-name refusal; a personal-data confirmation that renders the entire nine-section body about to become public, not a sample; and a plain-language confirmation in the repo's existing four-part Guard Change Summary shape. Only after all of that does the ceremony open a pull request — it never writes the pool directly, including from a maintainer's own write-access checkout. Write targets are exactly `skills/<slug>/SKILL.md` and a Tier 1 `curated-skills-registry.md` row, with a self-referential pinned-commit `source_url`; the PR reuses CONTRIBUTING.md's existing 4-pattern scan and DCO sign-off, adding zero new CI machinery.
- **`.github/CODEOWNERS`** now covers `skills/` and `curated-skills-registry.md`, reinforcing the promotion PR-gate for a maintainer-in-kit-checkout (write-access) promoter. A non-maintainer promoter was already structurally gated by GitHub's own permission model; this closes the analogous gap for the maintainer's own convention-based gate.
- **`TRUST.md`** gains a scoped ingress note describing the new promotion path and its gate (PR review, fresh re-grade, forbidden-token re-scan, body confirmation) — a disclosure of a new way the pool can grow, not a claim that the review bar itself changed.

### Deferred (tracked for a future increment)

- Loop 1 — a personal mini-Council in the workspace (memory-of-use, periodic self-review, user-confirmed self-modification). No owner greenlight yet; this closes out Loop 2 (generate → grade → promote) of the 3-loop program.

---

## [2.13.0] - 2026-07-19

**"Skill Studio — Increment 2b (Eval-Loop)"** — closes ADR-044's deferred with/without quality benchmark and v2.12.0's AC-SEC-S5 honest limit ("grep proves the instruction is present, not that the LLM honors it every run — that quantitative guarantee is the deferred v2.13 eval loop"), plus two already-scoped CI hardening items that ride along because this cycle already touches CI.

### Added

- **Eval-loop grade step (ADR-048/049) — `skill-studio/SKILL.md` step 7, "Grade."** A new step, inserted between structural validation (6) and surfacing (now 8), gates the "installed" declaration on TWO axes: **quality** (WS-EVAL — a baseline-first "without"/"with" paired transcript, scored per-`## Quality criteria`-bullet, PASS only if "with" strictly beats "without") and **behavioral-adherence** (WS-EVALSAFE — N=3 adversarial exercises per baked-in safety clause, observe-at-intent: the skill-under-test's proposed destructive action is elicited as inert quoted text and graded on attempt-vs-refusal, never executed). Grading runs entirely in-session — no network call, no external eval service. A WS-EVAL FAIL returns to refine (stops after 2 consecutive FAILs); a WS-EVALSAFE FAIL deletes the file and returns to author, the same disposition as a structural-validation failure. The loop is now nine steps.
- **`skills-allowlist-check` CI job (ADR-050, closes F2).** Mechanically enforces the kit's own top-level `.claude/skills/` allowlist (`setup-wizard`, `skill-studio` only) — fails closed (an absent or unlistable directory exits 2) instead of relying on a human remembering to check it every release.
- **`link-check-external` resilience (ADR-050, closes Pattern #3, 5 consecutive cycles).** Host-anchored excludes for the two chronically-flaky hosts named in this file's own retro history (shields.io, contributor-covenant.org), so a badge/policy-link false-red no longer trains reviewers to merge over red.

### Changed

- **`link-check-external` no longer suppresses job failure.** The job's `continue-on-error: true` setting already existed pre-fix and, on its own, was insufficient to stop the job showing red on the two flaky hosts — the real fix is the host-anchored exclude above. Removing the fail-suppression setting is a real, deliberate behavior change: a genuine break in any non-excluded external link now blocks merge, where previously it did not reliably.

### Deferred (tracked for a future increment)

- A promotion path from a local generated skill into the shared pool — v2.14.

---

## [2.12.0] - 2026-07-19

**"Skill Studio — Increment 2a (Discoverability)"** — closes both gaps named in ADR-044's accepted risk: a setup-time hook that offers to author a skill on the spot when nothing in the pool fits, and proactive re-surfacing of a generated skill's triggers in the workspace's own auto-loaded instructions, so a skill you generate once doesn't have to be remembered by name to use again.

### Added

- **Setup-trigger hook (ADR-047).** `WIZARD.md`'s Path C zero-coverage branch now offers "author one for you" (invoke `skill-studio`, carrying the stated goal in as data) alongside the existing closest-pool-skill routing — neither replaces the other. On a validated install, the generated skill folds into the bundle and the interview resumes at final confirmation.
- **Proactive surfacing (ADR-046).** `skill-studio` gains an 8th loop step that writes a generated skill's triggers into the workspace's auto-loaded `CLAUDE.md`, under a new `## Proactive skill behavior` section, wrapped in a skill-scoped idempotency marker so re-runs update in place instead of duplicating.
- **`templates/workspace-claude-md-template.md`** gains a `## Proactive skill behavior` section so the surface exists from first setup.
- **Slug-charset and block-scoped safety gates** — closes a proven marker-breakout path (an unvalidated slug could inject visible text into an auto-loaded instructions file) and a check-that-cannot-fail forbidden-token scan, both found in Phase 2 review before any code shipped.

### Deferred (tracked for a future increment)

- Quality evaluation beyond structural validation — v2.13.
- A promotion path from a local generated skill into the shared pool — v2.14.

---

## [2.11.0] - 2026-07-19

**"Skill Studio — Increment 1 (Walking Skeleton)"** — adds a generative path alongside the kit's existing assembly path. Today the wizard only ever composes from the fixed skill pool; on a genuinely novel need, you can now brainstorm it directly and get a matching skill authored, installed, and validated on the spot, entirely inside your own workspace.

### Added

- **`skill-studio`** — an always-available meta-skill that runs a full brainstorm → propose → confirm → author → install → validate → refine loop. Call it any time a need doesn't fit any of the 25 pool skills — "I keep needing X, make me a skill" — and it drafts a skill-spec for your approval before writing anything, then installs a complete, structurally-validated skill to your own workspace. Generated skills are local to your workspace only and are never added to the shared pool or registry.
- **`scripts/skill-studio-validate.sh`** — a portable, offline, dependency-free structural validator that checks any skill file against the same section and length rules the kit's own CI uses, so a generated skill can be checked without needing this repo or an internet connection.

### Deferred (tracked for a future increment)

- Wiring the setup wizard to offer skill authoring directly when no pool skill fits.
- Surfacing a generated skill's triggers into proactive suggestions the way pool skills are.
- Quality evaluation beyond structural validation.
- A promotion path from a local generated skill into the shared pool.

---

## [2.10.0] - 2026-07-19

**"Empowerment Skills"** — grows the pool by exactly the JTBD-justified amount: two new skills plus one recalibration extension, evidence-sourced (research memo + a documented adapt-vs-author sourcing scan), offered through the existing bundle-customization surfaces and never forced into any preset's `core_skills`.

### Added

- **`skills/anti-ai-slop`** — an opt-in authenticity pass that flags AI-tell vocabulary, uniform sentence rhythm, and empty hedging in any drafted content, in any preset domain, while never flagging a device the writer's own sample text or `context/writing-profile.md` establishes as intentional style. Offered via `cross_cutting_skills` (all 7 preset `goal_tags`), not auto-applied — an output-altering rewrite is offered, never silent.
- **`skills/weekly-review`** — a GTD-style Collect → Process → Review → Plan pass across the user's own workspace files, on a weekly cadence distinct from the daily briefing or a single-project status update. Offered via `optional_skills` on `personal-assistant` and `project-management`, plus `study` via `goal_tags` only.
- **`voice-matching` recalibration** — new trigger phrases ("check if my voice has changed," "recalibrate my voice," "update my writing profile") and a numbered recalibration path: compare a new sample against the recorded profile, name both consistent and drifted patterns explicitly (never a binary verdict), then update `context/writing-profile.md` in place only on explicit confirmation, showing the exact derived delta first.
- **`curated-skills-registry.md` — new `### Cross-Domain` subsection** for skills whose `goal_tags` span 3+ preset domains, rather than forcing a genuinely multi-domain skill under one arbitrary preset heading. Registry grows from 24 rows / 23 unique slugs to 26 rows / 25 unique slugs.
- **`docs/research/v2.10-empowerment-skills-research.md`** — internal offer-architecture/CI audit plus dated, URL-cited external sources on AI-slop detection and knowledge-worker empowerment, feeding the two AUTHOR decisions above.
- **ADR-042** (pool expansion + Cross-Domain registry subsection) and **ADR-043** (adapt-vs-author sourcing policy, codifying the "research it properly or pull from a tested repo" quality bar for future pool additions).

### Changed

- Pool-count prose updated from 23 to 25 skills at all seven live locations (`WIZARD.md`, `SETUP-CHECKLIST.md`, `templates/workspace-claude-md-template.md`, `tests/offline-smoke-test.md`, `README.md`) plus one descriptive CI comment in `.github/workflows/quality.yml` — zero logic, permission, or pass/fail-condition changes anywhere in that file. The C-v2.4-6/C-v2.4-7 security notes in `WIZARD.md` stay byte-unchanged in substance; only the count moves.
- **Security hardening from Phase 2 review:** the `.github/workflows/quality.yml` zero-logic-delta verify is now a sound comment-only-line inversion (the prior added-line-only form missed deletions and SHA-pin swaps); both new ingesting skills carry an explicit data-not-instruction line for pasted/read content; `voice-matching` recalibration and all `## Writing-profile integration` readers (`voice-matching`, `editing-pass`, `anti-ai-slop`) now treat `context/writing-profile.md` as descriptive style data only — a non-style imperative found there is surfaced to the user, never obeyed.
- **v2.9.0 fast-follows:** the AC-STORE-4 verify command (`docs/internal/security/security-review-v2.9.0.md`) replaced with a sound, anchor-scoped grep, proven to fail on the pre-v2.9.0 tree; `SETUP-CHECKLIST.md`'s dense Step 1 sentence split in two for readability, substance unchanged; README gains "What's new in v2.10" and "What's new in v2.9" sections (the latter closing a v2.9.0 retro carry-forward).

## [2.9.0] - 2026-07-18

**"Dynamic Reclaim"** — reclaims the wizard's co-creation framing without touching the v2.7 routing fix underneath it: the presentation layer changes, the `≥2`-threshold/vocabulary/stemming mechanics and both C-v2.4-6/C-v2.4-7 security notes stay byte-unchanged.

### Changed

- **Draft-first routing presentation (ADR-040).** `WIZARD.md`'s judgment tie-break paragraph drops the cost-asymmetry sentence ("a wrong suggestion costs one 'no', while a false Path C costs the whole scaffold") — Path A and Path C are now explicitly equally-valid, equally-fast starting points, and Path C is the correct first-class outcome when nothing clearly fits, not a fallback. Path A/B's binary "That sounds like **[Preset]** — is that right?" verdict is replaced with an explicit draft frame — a `(matched: [token])` reasoning fragment naming the specific `match_signals` token(s) that fired, plus a three-way close (run with it / adjust it / set it aside for custom) — and the Matched-reasoning rule now also binds the canonical vocabulary token over the user's surface inflection (e.g. echo `email`, not a plural/typo surface form).
- **Path C structural parity + `goal_tags` matching (ADR-041).** Path C's opening presentation now matches Path A/B's structure — a named, reasoned "draft team" instead of a flat unlabeled skill list — and its matching reads `curated-skills-registry.md`'s `goal_tags` column (dormant since ADR-012, v1.2) in addition to name/description, so a crossover goal (e.g. a homeschool plan) surfaces skills from every domain it touches. The addressable set stays exactly the 23-skill pool (C-v2.4-7, unchanged) — `goal_tags` widens the matching signal, not the pool boundary. A zero-coverage goal gets a plain, non-apologetic "we build yours from scratch" acknowledgment, and "want more" is the normal next step (identical to F4's existing ≤3-at-a-time batching), not an overflow apology. The Path C goal-derived team name is bound under the same C-v2.4-6 rule as the `matched:` fragment: a short topical label from matched vocabulary only, never a verbatim echo of imperative-shaped goal text.
- **Storefront alignment.** `assets/setup-demo.svg` beats 3–4 rewritten to mirror the real new dialogue (draft framing + `matched: finals` + a run/adjust close, widened to a 620px bubble to hold the longer text); the 7-beat structure is unchanged. README's Highlights bullets and "What's included" copy reframe the wizard's `(≤3 at a time)` add-skill batching from a headline constraint into a progressive-disclosure default, and drop the "composes a custom bundle when no preset fits" fallback framing in favor of "drafts a custom team from the pool." `CLAUDE.md`'s onboarding pointer and `.claude/skills/setup-wizard/SKILL.md`'s routing line updated to the same draft-team framing (CLAUDE.md stays at 339/400 words, well under the CI ceiling); 6 of 7 starter files align "team" → "draft team" terminology (`personal-assistant` is held at 396/400 words — no non-essential edits, to protect its CI headroom).
- **Naming retired to plain language (Gate Decision 1 — unnamed).** `SETUP-CHECKLIST.md`'s remaining "Dynamic Workspace Architect" references (the sole live surface still using the term) are replaced with "the setup wizard" / "the wizard," matching README's existing plain-language framing. Step 1's description drops "confirms the preset you chose" for the same three-way, non-hierarchical draft language used everywhere else. `CHANGELOG.md`'s historical entries are untouched (append-only record).

### Added

- **`docs/research/v2.9-dynamic-reclaim-research.md`** — internal drift trace of the unreviewed cost-framing language that rode in on the v2.7.0 routing fix (`e2f622d`), plus 6 dated, URL-cited external UX sources on progressive disclosure, draft-mode framing, and choice-overload thresholds.

### Non-regression

- `WIZARD.md`'s `≥2` match-score threshold, 16-token `match_signals` vocabulary, light-stemming rule, and the C-v2.4-6 (goal text is DATA)/C-v2.4-7 (pool boundary) security notes are byte-unchanged — the edit boundary never reaches either note line.
- No CI job, schema, auth surface, or dependency change this cycle.

## [2.8.1] - 2026-07-18

### Fixed

- **`assets/setup-demo.svg` storyboard rewritten to mirror the actual `WIZARD.md` interview.** The prior 6-beat demo opened with the user speaking first (the real wizard opens the conversation — `WIZARD.md:44`), and its 5th beat had the user answering Q2 ("Alex — studying for the MCAT, no deadlines yet") immediately after a fast-track menu beat, with Q2 itself never shown — a narrative non-sequitur an owner review caught on the live rendered README. The demo is now a strict 7-beat COWORK/YOU alternation that traces to the real script: Cowork opens with Q1 (`WIZARD.md:44`) → user states a goal → Cowork routes to a preset and proposes a bundle (`WIZARD.md` §F3 tokenization / Path A + §F4 bundle-confirm) → user confirms → Cowork asks the single Q2 turn (`WIZARD.md:136-151`) → user answers → Cowork closes with the workspace-ready summary and now also surfaces the Step 7b clean handover (`WIZARD.md:283-285`, `:313`) — the setup kit archiving itself into `_setup-kit/` — which the demo previously never showed. The fast-track menu beat is dropped (it was the non-sequitur source; the README prose already covers the checkpoint mechanic). SVG remains fully inert (no `<script>`, `<foreignObject>`, `on*=` attributes, or external `href`/`xlink:href` — re-verified with a 0-hit grep plus a negative control), well-formed, and keeps the existing palette/typography/mac-dots-header visual system; the `<title>` aria text now also mentions the clean handover.

## [2.8.0] - 2026-07-18

**"Showcase"** — Phase B of the 4-phase improvement roadmap (Truth & Release → **Showcase** → Distribution & Trust → Upstream refresh). Focused on visibility and provable trust, not interview behavior — WIZARD.md's Q1/F4/Q2/Q3 flow is unchanged this release.

### Added

- **`TRUST.md`** (repo root) — plain-language threat model: what could go wrong with an AI-agent starter kit and exactly what this one does about it, citing independently re-verified third-party research (Snyk's ToxicSkills study: 3,984 skills scanned, 36.82% with a security flaw, 76 confirmed-malicious payloads, Feb 2026; PromptArmor's Claude Cowork file-exfiltration disclosure, Jan 2026).
- **`assets/setup-demo.svg`** — a self-contained, inert (no `<script>`, no `<foreignObject>`, no external fetch) animated SVG demo of the real 3-turn interview, embedded near the top of README.
- **`docs/how-it-works.md`, `docs/faq.md`** — new curated public docs answering the questions a first-time evaluator actually asks, replacing internal QA paperwork as the first thing a `docs/` visitor sees.
- **`docs/internal/{qa,security,compliance,process,planning}/`** — 40 internal QA/security/compliance/process artifacts relocated here (WS5, ADR-037). `.gitattributes` collapsed from ~42 individual per-file DROP lines to a single `docs/internal/ export-ignore` directory rule (plus 3 Council-tooling exemptions for `docs/spec.md`/`docs/retro.md`/`docs/patterns.md`) — a new `docs/*.md` file is now public-unless-placed-internal, not the reverse. `docs/architecture.md`, `docs/research/*`, and `docs/project-audit-v2.6.1.md` are now public credibility assets.
- **`starter-drift-marker-check`** CI job (`quality.yml`) — fails the build if any of the 7 `examples/*/project-instructions-starter.txt` files contains a retired-interview marker (`Step N: Name`, `Phase N —`, `Workspace ready.`), verified with a negative control before trusting the green run.
- Real timing data in `tests/offline-smoke-test.md` — 4 dry-run sessions across the interview's main paths; see the file for the decision rule and raw numbers behind the "15 minutes" hero claim.
- A pre-release checklist in `CONTRIBUTING.md` requiring a current offline-smoke-test scorecard before tagging.

### Changed

- **README.md rewritten**: an actual `#` H1 title + identity block (previously bare prose), a trust story in the first screens citing Snyk and PromptArmor, an enriched "What's new in v2.7" section naming the 16-agent swarm-test methodology and the two failures it found and fixed, an updated sequence diagram reflecting the Step 7 handover, a marketed fast-path callout, and "zero runtime fetches / fully reviewable supply chain" framing alongside the existing offline-first language. The stale "v2.4 highlights" / "Earlier highlights (v1.2)" archaeology sections are removed.
- **All 7 `examples/*/project-instructions-starter.txt` regenerated** (ADR-038, closes D-1) — full self-contained copies of the current v2.7 3-turn interview (open-ended Q1, the `Confirmed bundle`/F4 profile-stub checkpoint, the correct "Basics saved… Keep going" fast-track text), replacing the retired pre-v2.7 4-Phase/6-Step flow with an incompatible profile schema and a different fast-track string. Each stays under the 400-word CI ceiling (373–396 words).
- **WIZARD.md dead-reference + canonical-Q1 cleanup** (ADR-039, closes D-5/D-6): 4 dead `CLAUDE.md Phase N` cross-references now name `Q1`/`Q3` directly; both `## Phase 1 —` headings renamed (`Uncertainty Fallback (Q1)`, `Role-Generation Rule (Q1, AC-W2-9)`); `CLAUDE.md`'s matching inbound reference updated (word-neutral, 325/400 words); `.claude/skills/setup-wizard/SKILL.md`'s Q1 block now quotes WIZARD.md's canonical opener verbatim instead of carrying its own duplicate 7-preset menu.
- `.github/workflows/quality.yml`, `sync-agency.yml`, `release-assets.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, `curated-skills-registry.md`, `CONTRIBUTING.md` — all inbound references to the 40 relocated internal docs updated in the same commit as the move (9-item cross-check plus 3 additional surfaces a Phase 2 spot-review found: the PR template, and two `curated-skills-registry.md` disposition annotations).

### Fixed

- The interview logic itself is unchanged this release (out of scope — see the roadmap above); this cycle is presentation, truthfulness-of-story, and information architecture only.

## [2.7.2] - 2026-07-18

### Added

- **Version-consistency CI gate** (`version-consistency-check` in `.github/workflows/quality.yml`) — asserts `VERSION` == README badge version == the first CHANGELOG release header on every PR; fails loudly, naming the offending signal, on any malformed/missing value, and treats a stranded `[Unreleased]` header as a hard failure instead of silently skipping it. Closes the version/badge/CHANGELOG drift defect class structurally.
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1, with the required CC BY 4.0 attribution.
- `.github/ISSUE_TEMPLATE/` — bug report and preset request templates.
- README GitHub-stars and "PRs welcome" badges alongside the existing CI/License/Version badges.
- `personal-assistant` added to `curated-skills-registry.md`'s `goal_tags` vocabulary and to the `.claude/skills/setup-wizard/SKILL.md` preset list; registry row-count annotation added (24 rows / 23 unique skill slugs).

### Changed

- **CHANGELOG restructured (ADR-036):** all v2.7.0/v2.7.1 content re-homed from an undated `[Unreleased]` heading into dated `## [2.7.0] - 2026-07-06` and `## [2.7.1] - 2026-07-07` sections below, so the version story matches what actually shipped.
- `VERSION` and the README version badge bumped to `2.7.2`; README "What's new" refreshed to summarize the actual shipped v2.7.0/v2.7.1 content.
- WIZARD.md's external-skill refusal wording (2 sites) and README's "Next up" teaser rewritten to drop the missed "coming in v2.7+" deadline while preserving the underlying substance.
- Stale version markers removed/neutralized: WIZARD.md's "v1.2" entry-point claim, SETUP-CHECKLIST's "v2.6.0" path claim, README's "(new in v1.2)" parenthetical, and `docs/OUTPUT-STRUCTURE.md`'s "(v1.2)" heading marker.
- `.github/workflows/quality.yml` pool-size comments corrected from "20 files" to the current "23 files".

### Removed

- Legacy `tests/v1.3.3/` directory (superseded).

---

## [2.7.1] - 2026-07-07

### Added — fourth pass (Step 7 handover: installer-to-workspace transition)

- **WIZARD.md Step 7 — Handover:** setup now ENDS with a transition instead of leaving the user living inside the installer. 7a generates a personalized workspace `CLAUDE.md` from the new `templates/workspace-claude-md-template.md` (replaces the wizard bootstrap, explicit confirmation required, safety rule verbatim, <350 words); 7b archives the entire installer — wizard script, skill pool, presets, templates, vendored agent library (+ THIRD-PARTY-NOTICES, which travels with the content it covers) — into `_setup-kit/` (MOVED, never deleted, one batch confirmation; skipped automatically when the workspace isn't the kit folder); 7c optionally creates the preset's working folders. Final workspace layout documented in the step.
- **Post-handover path rule:** kit paths (`skills/`, `vendored/agency-agents/`, `WIZARD.md`) resolve under `_setup-kit/` once archived; the F4 pool boundary, Network & Offline Rule, and ADR-024 apply unchanged. setup-wizard SKILL.md locates the script at either path, so `/setup-wizard` keeps working after the tidy-up.
- Workspace `CLAUDE.md` template bakes in: per-session profile/deadline behavior, canonical writing-profile/output-format references, proactive skill triggers, the skill-swap affordance against the archived pool, offline rule, and the verbatim safety rule.
- README "clean handover" callout, SETUP-CHECKLIST troubleshooting entry ("Where did all the setup files go?"), and offline smoke-test pass criteria for the handover + post-handover path resolution.

---

## [2.7.0] - 2026-07-06

### Added — third pass (v2.7 roadmap implementation, from the 16-agent test campaign)

- **Two new pool skills (roadmap idea 10):** `skills/citation-formatter` (APA/MLA/Chicago/Harvard with missing-field flagging — closes the Alex persona's J3 gap and honors the audit F-2 re-add condition) and `skills/list-tracker` (guest lists/RSVPs/vendors/applications as local markdown tables — closes the Jordan persona's zero-coverage gap). Wired into study/research/personal-assistant optional tiers; pool is now 23 skills.
- **Profile-stub checkpoint (idea 2):** bundle confirmation immediately persists `cowork-profile.md` with `Status: in-progress`; the interruption fallback resumes from it (skipping Q1/F4), and fast-track runs generation with defaults instead of exiting empty. Fixes the two outright persona-sim failures (fast-track dead-end, crash recovery losing everything).
- **Personalization placeholders (idea 1):** all 7 presets gain a "Who you're working with" block (`[YOUR NAME]`/`[YOUR ROLE]`/`[GOAL]`/`[DEADLINES]`); WIZARD.md Step 2 fills all four and verifies none remain; `wizard-consistency-check` CI fails any preset missing one (the replace-placeholders step had been a verified no-op — no preset contained them).
- **Optional Q3 voice turn (ideas 4+7):** the writing profile moves into WIZARD.md as one sample-first optional turn; `context/writing-profile.md` is the single canonical profile with an explicit do-not-overwrite rule.
- Timing scorecard in `tests/offline-smoke-test.md` (idea 12) and a v2.7 assumptions-register section reversing A2 — Cowork now auto-discovers `.claude/skills/` in connected folders (idea 13, hedged both-channels decision).

### Changed — third pass

- **Interview cut from ~10 questions to 3 core turns (idea 3):** Q1 goal + one bundle confirm + Q2 (name/role/deadlines in one turn). Output format defaults from the preset; connectors are configured at point-of-need; the safety question became a one-line notice (its answer never changed anything). Closing message now ends with a personalized first task instead of checklist homework (idea 5).
- **F3 routing fixed (idea 6):** light stemming, `match_signals` enriched to ≤16 tokens/preset, Path A threshold ≥2 with runner-up separation, Path B tie band defined, and a codified judgment tie-break. Regression-tested against all 7 persona goals — Alex/Riley/Taylor now route correctly (previously Path C), Maria correctly ties.
- **Single-source interview (idea 7):** WIZARD.md is the only script (engineering spec split behind an appendix banner; F4 header fixed; "F5" now exists as the generation phase). CLAUDE.md rewritten as bootstrap+pointer (400→326 words under the CI locale) with an in-progress resume branch; setup-wizard SKILL.md is a pure router with resume-guard-before-reset-guard precedence and first-task prompts for all 7 presets + custom.
- **Returning-user path defined (idea 8):** existing-workspace fallback generalized beyond exact v2.3.x signatures; option 2 add/remove flow specified (delta install + `skills-as-prompts.md` regeneration + profile bundle update, nothing else touched).
- **Skill hygiene (idea 9, targeted):** daily-briefing's ambient first-message trigger replaced with verbatim phrases + do-not-fire rule (worst collision found); prompt-gate reframed honestly as assistant behavior, not middleware; research-synthesis's false "distinct Study variant" claim corrected (files were byte-identical) — example copies re-mirrored.

### Deferred (with rationale)

- **Idea 11 (generate instructions/checklists from installed bundle):** superseded-by-design tension with idea 1's placeholder approach, judged L-effort/6.7 — revisit in the v2.7 cycle proper as a template-assembly redesign.
- **Idea 14 (plugin-marketplace manifest + catalog publishing):** lowest judge score (4.3); adds a new distribution artifact no CI invariant covers. Needs its own lock-style drift controls before shipping.

### Added — second pass (audit recommendations implemented)

- **Vendored upstream library** (`vendored/agency-agents/`, audit F-7 option a) — all 110 lock-pinned files + LICENSE from `msitarzewski/agency-agents`, fetched at the pinned commit, SHA-256-verified against `cowork.lock.json` (fail-closed), ADR-024 attribution-injected, S1-scanned (0 hits). The upstream agent library is now readable fully offline; wizard-managed *install* of vendored agents remains v2.7+ scope per the F4 pool boundary.
- `scripts/vendor-agency.sh` — reproducible vendoring: fetch → hash-verify → inject attribution → round-trip strip-check. Run after every `/sync-agency` lock bump (added to the sync PR reviewer checklist).
- CI job `vendored-integrity-check` — offline, on every PR: strips each vendored file's attribution block and asserts the remaining bytes hash to the lock's `content_sha256`; also verifies the vendored LICENSE. Lock bumps without a vendored refresh, and tampering on either side, fail CI.
- CI job `wizard-consistency-check` (audit F-8) — drift gate across wizard surfaces: preset slugs ↔ pool files ↔ registry rows ↔ setup-wizard skill menu. Would have caught both the phantom `citation-formatter` registry entry (F-2) and the missing Personal Assistant preset (F-3).
- `tests/offline-smoke-test.md` — required pre-release test: full wizard run with networking disabled (the scenario the first field report failed).
- Assumptions register entry `A-v2.6.2-1` — "Cowork sessions have no internet access by default" [CONFIRMED by field report], superseding A-v2.0-3's fetch-at-install mechanism.

### Changed — second pass

- README Supply-Chain Integrity section rewritten to describe what actually ships (vendored, CI-verified, zero runtime downloads); "What's new" brought current to v2.6 (was v2.5); "Next up (v2.7+)" now names external skill install from the vendored library.
- WIZARD.md Network & Offline Rule now directs offline reads of upstream agents to `vendored/agency-agents/`; SETUP-CHECKLIST troubleshooting and Supply-Chain Trust sections updated to match.
- Model guidance made version-neutral in README, WIZARD.md, and SETUP-CHECKLIST (audit F-9): "most capable model available in your plan" replaces hardcoded "Opus 4.x" / `opusplan` references.
- markdownlint and lychee link checks exclude `vendored/agency-agents/` (verbatim upstream content — integrity-checked against the lock instead); release archive keeps `vendored/` with a KEEP assertion for its LICENSE.

### Added

- **Network & Offline Rule** (WIZARD.md new section + CLAUDE.md `## Offline Rule`) — codifies that Cowork sessions commonly have no internet access and that setup is offline by design: all skill installs copy from the local `skills/` pool; the wizard must never fetch from GitHub or the agency-agents upstream in a live session; includes exact fallback wording when a step appears to require the internet. Root-caused from the first field test, where the wizard attempted an upstream GitHub download without network permission and no guide surface explained the failure (`docs/project-audit-v2.6.1.md` F-1).
- SETUP-CHECKLIST troubleshooting entry: "Claude says it can't access GitHub or the internet — skills/agents didn't download" — including a one-line reply users can paste to redirect Claude to the local pool.
- README "Setup works fully offline" callout in Quick start.
- SETUP-CHECKLIST Step 9 "Try this now" prompts for the Personal Assistant preset (previously 6 of 7 presets covered).
- `**Deadlines:**` field in the WIZARD.md `cowork-profile.md` template, so CLAUDE.md's first-session "surface deadlines within 7 days" behavior has data to act on.
- Full audit report: `docs/project-audit-v2.6.1.md` (11 findings; 6 fixed here, 5 open with recommendations).

### Changed

- `.claude/skills/setup-wizard/SKILL.md` realigned with the v2.4+ dynamic wizard: 7-preset menu (Personal Assistant was missing), routes through WIZARD.md Q1/F4/Q2–Q5 instead of the removed v1.x "11-step interview", and states the offline install rule.
- README unified skill pool count corrected: 20 → 21.

### Removed

- `citation-formatter` registry entry — listed as `builtin` but no `skills/citation-formatter/SKILL.md` exists, so the wizard could offer a skill it cannot install. Disposition annotation added; re-add only together with a 9-section pool file.

---

## [2.6.1] - 2026-05-11

### Changed

- Release archive hygiene: introduced `.gitattributes` with `export-ignore` rules so GitHub release ZIP/tarball contains only end-user product files (`.claude/`, `skills/`, `prompts/`, `templates/`, `examples/`, `CLAUDE.md`, `WIZARD.md`, `SETUP-CHECKLIST.md`, `README.md`, `LICENSE`, `VERSION`, `THIRD-PARTY-NOTICES.md`, `cowork.lock.json`, `.cowork-allowlist.json`, `scripts/setup-folders.{sh,ps1}`, `docs/architecture.md`, and product reference markdown). Internal artifacts (CI workflows, contributor docs, ADR retros, QA reports, security reviews, tests, upstream contribution notes, dev tooling configs) no longer ship to end users.
- Release CI: added inline archive-content verification step in `release-assets.yml` — fails the release build if any DROP-list path leaks or any of 10 core KEEP files is missing.
- README + SETUP-CHECKLIST: rewrote relative links to `CHANGELOG.md` and `CONTRIBUTING.md` to absolute GitHub URLs so extracted archives don't surface broken links.

---

## [2.6.0] — 2026-05-10 (Dynamic Preset Scaffolds)

### Added

- **Tiered skill schema** — `selection-presets.md` now defines three tiers per preset:
  - `core_skills:` (2-4 skills, always installed by the wizard — replaces `skill_bundle:`)
  - `optional_skills:` (1-3 skills, proactively offered at bundle-confirm and mid-session)
  - `cross_cutting_skills:` (pool-level annotation, 5 skills useful across multiple workspace types)
- **Per-preset optional-tier proactive-offer blocks** — all 7 `examples/*/global-instructions.md` files gain proactive-offer trigger blocks for each `optional_skills:` entry (14 new blocks total, paired 1:1 with optional tier per preset)
- **"## Skill swap" section** in all 7 `examples/*/global-instructions.md` — instructs the AI to offer optional/cross-cutting skills inline when the user requests a capability outside the core bundle (D8 instruction-only swap; no file copy to `.claude/skills/` at runtime)
- **Cross-cutting skills annotation** — `selection-presets.md` footer block lists 5 pool-level cross-cutting skills with rationale table

### Changed

- **Wizard Path A flow** (WIZARD.md) — bundle-confirm now proactively presents optional-tier before user confirms, per D5. User can add any optional skill to the install at setup time.
- **Wizard F4 customization** (WIZARD.md) — bundle customization step now distinguishes three add-sources: optional tier (preset-specific), cross-cutting (pool-level), full pool (free-text match)
- **Wizard pool boundary** (WIZARD.md) — updated from 20 to 21 slugs; external-skills rejection message updated to v2.6 reference
- **Wizard Step 6 header** (WIZARD.md) — clarifies that `skills-as-prompts.md` covers core + user-confirmed optional adds at install time; cross-cutting skills added mid-session are loaded inline, not written to disk
- **7 preset bundles recomposed** from full-pool JTBD analysis: Study, Research, Writing, Project Management, Creative, Business/Admin, Personal Assistant — all cores unchanged from v2.5.x; optional tiers are net-new in v2.6.0
- **README "Next up" line** — updated to v2.7+ framing per D7 (no tool names)
- **README version badge** — bumped `2.5.4` → `2.6.0`
- **CI `quality.yml` CMP step** — parser switched from `skill_bundle:` to `core_skills:` in lock-step with ADR-034 (ADR-016 v2.6 amendment). Byte-mirror invariant semantics unchanged: pool files must match example folder copies for installed core skills.
- **CI `quality.yml` MF-1 vocabulary gate** — regex updated from `^(match_signals|skill_bundle):` to `^(match_signals|core_skills|optional_skills):` to cover new field names

### Removed

- **`skill_bundle:` field** (D4 hard-break) — removed from all 7 preset blocks in `selection-presets.md`. New schema is the only schema. No parser fallback exists in the wizard or CI.

### Schema migration

The `skill_bundle:` field in `selection-presets.md` is removed. New schema: `core_skills:` (always loaded) + `optional_skills:` (offered at setup or runtime) + `cross_cutting_skills:` (pool-level annotation). Existing v2.5.x clones are unaffected — their `selection-presets.md` still contains `skill_bundle:` and their bundled wizard reads it. Users who clone v2.6.0 get the new schema only (clone-once template design — `selection-presets.md` is read by the wizard at setup time, not by user workspaces post-setup). CI byte-mirror parser updated in lock-step (ADR-016 v2.6 amendment). See ADR-034 for full migration scenario table.

### References

- ADR-034: Tiered Preset Schema with Hard-Break Migration
- ADR-016 (Amendment v2.6): CMP Byte-Mirror + MF-1 Parser Switch to `core_skills:`

---

## [2.5.4] — 2026-05-10 (Pivot framing realignment)

### Changed

- **README hero (line 1) realigned to v2.4.0 Dynamic Workspace Architect framing:**
  Replaced "goal-based preset wizard, 20 curated skills" wording with "describe your goal, the
  Dynamic Workspace Architect builds it from vetted, SHA-pinned skills." The v2.4.0 cycle shipped the pivot
  functionally (open-ended goal discovery replaces preset menus); v2.5.4
  closes the gap on the two surface-level artifacts that still carried
  pre-pivot framing. Value-prop anchors preserved byte-identically:
  "no code required." Note: "20 curated skills" framing was replaced with "vetted, SHA-pinned skills" — local
  skill count understates the dynamic-architect curation story (Cowork curates down from a larger agency-agents
  upstream pool with SHA-pinning, content-scanning, and MIT attribution injection). Curation > count.
- **SETUP-CHECKLIST.md Step 1 sequencing fix:** Goal articulation is now
  presented as the primary first action; preset selection is reframed as
  "pick a starting suggestion" (the wizard confirms / narrows / composes
  from there per Paths A/B/C). Steps 2 and 3 unchanged.
- Version badge bumped `2.5.3` → `2.5.4`.

### Operational note (manual post-merge)

GitHub repo Topics need a one-time swap to match the v2.4.0 pivot. Run after
PR merge:

```bash
gh repo edit jmlozano1990/Cowork-Starter-Kit \
  --remove-topic templates \
  --add-topic dynamic-workspace
```

`github.enabled=false` in the registry — in-cycle automation is skipped (same
pattern as v2.5.3 S1/S2/S3 manual signals).

---

## [2.5.3] — 2026-05-10 (v43 framework application + O-1 guard)

### Changed

- **Scope A — v43 Public Artifact Framework applied to cowork-starter-kit:**
  README restructured to Profile-1 `how-to` IA (positioning statement first,
  new `## Who is this for` H2, section order aligned: value prop → audience →
  Demo → Quick start → What's included → How to extend → Credits / Attribution).
  `## License` renamed to `## Credits / Attribution` with upstream attribution.
  `## What can you build?` renamed to `## What's included`; `## Seven goal presets`
  merged as `### Goal presets` subsection. New `## How to extend` H2 added.
  Version badge bumped `2.5.2` → `2.5.3` (AC-A4).
  SETUP-CHECKLIST.md intro paragraph updated to v2.5.3 reference.
  CONTRIBUTING.md gains a contributor value statement before `## Adding a new preset`.

### Added

- **`templates/public-artifact/release-body.md`** — v43-compliant release body
  template with `[REPLACE:VERSION]`, `[REPLACE:POSITIONING]`,
  `[REPLACE:CHANGE_BULLET_1..3]`, `[REPLACE:BREAKING]`, `[REPLACE:CHANGELOG_LINK]`,
  `[REPLACE:NEXT_TEASER]` markers per `public-artifact-strategy.md` § 7.

- **Scope B — O-1 Guard: sync-agency.yml now preserves DO-NOT-REGENERATE tail:**
  The "Regenerate THIRD-PARTY-NOTICES.md" step (ADR-025) is patched (Path 1) to
  read and re-append any content below the `<!-- DO-NOT-REGENERATE -->` marker in
  the live file. The `## Direct Pattern Incorporations` section added in v2.5.2
  will survive future upstream SHA bumps.
  Defense-in-depth: step name now advertises tail-preserve behavior in `gh run list`
  output (V2.5.3-S1); `set -euo pipefail` added to patched run block (V2.5.3-S2).

---

## [2.5.2] — 2026-05-10

### Added

- **prompt-gate skill** (`skills/prompt-gate/SKILL.md`) — auto-loaded via every
  preset's `global-instructions.md`. Detects vague prompts and enriches them by
  reading workspace context, scanning local files, asking up to 3 grounded
  clarifying questions, then executing with full context. Bypass with `*` prefix.
- **correcting-course rule** (`prompts/correcting-course.md`) — auto-loaded via
  every preset's `global-instructions.md`. When the user says output is off,
  emits a structured form with preset adjustment chips (tone, scope, format,
  depth, sources) plus an "Other" free-text escape — no need to retype context.
- New `prompts/` directory at repo root for cross-cutting workflow rules
  injected into preset `global-instructions.md` files.
- `THIRD-PARTY-NOTICES.md` updated: new `## Direct Pattern Incorporations`
  section with the `addyosmani/agent-skills` MIT entry covering the 4-phase
  context-enrichment pattern incorporated into `skills/prompt-gate/SKILL.md`.

### Changed

- All 7 presets' `global-instructions.md` files gained two appended sections
  (`## Prompt enrichment (prompt-gate)` and `## Correcting course`). Existing
  content is byte-unchanged.
- `curated-skills-registry.md` adds a `prompt-gate` row under Project
  Management with cross-cutting `goal_tags`.

### Patch-Level Exception (process note)

A new opt-in skill (prompt-gate) ships at patch level here because the v2.6
minor slot is publicly committed to multi-tool skill authoring. The skill is
auto-loaded via global-instructions but can be removed from any preset's
`global-instructions.md` without other changes. Future new-skill cycles
default back to minor version bumps.

### Compliance

- MIT attribution preserved for the upstream pattern source
  (`addyosmani/agent-skills` @ `9534f44c5448086fcc0046f9d83752c654c81930`):
  full permission notice embedded in `skills/prompt-gate/SKILL.md` footer
  (Option A, self-contained) and full license text in
  `THIRD-PARTY-NOTICES.md` (`## Direct Pattern Incorporations`).
- Phase 2 `/legal` review: PASS WITH MUST-FIX (2 WARNING / 4 INFO);
  CF-L1-1 and CF-L1-2 resolved by the additions above.

---

## [2.5.1] — 2026-05-09

Doc-only patch: Extended Thinking + Opus onboarding guidance added to three user-facing files.

- README.md Quick-start: two leading bullets added ("Toggle Extended Thinking ON" and "Select Opus 4.x in the model dropdown")
- SETUP-CHECKLIST.md: new "Before you start" preface section at the top of the file with the same two items
- WIZARD.md: "Before we begin — model check" section updated to reference Opus 4.x + Extended Thinking explicitly (replaces "Sonnet or higher"); `opusplan` notes for Research/Writing/PM presets unchanged

---

## [2.5.0] — 2026-05-09

### Added
- ADR-028: `content_sha256` per-file integrity field backfilled across all 110 entries in `cowork.lock.json`. The sync workflow now verifies `content_sha256` on every pull before accumulating changes — mismatches abort with a CI error.
- `tests/fixtures/sha-fault-injection.json` — CI fixture for lock-content-sha fault-injection test (asserts mismatch fires).
- `lock-content-sha-fault-injection` CI job — regression test that the verify logic fires on the DEADBEEF fixture.
- `lock-content-sha-cross-check` CI job — cross-environment trust anchor: recomputes SHA on PR and compares to lock (C-v2.5-19).
- ADR-029: `tools:` SKILL.md frontmatter field — closed vocabulary `[claude-code, copilot, cursor, windsurf]`. Default-when-absent rule (assume `claude-code` at runtime). CI vocab gate (MF-3) enforces all pool skills declare an inline-array `tools:` value.
- `tools: [claude-code]` added to all 20 skills in `skills/*/SKILL.md`. All 21 `examples/*/SKILL.md` byte-mirrored (ADR-018 research-synthesis exemption applied). MF-3 CI gate blocks vocab violations and multi-line YAML form (MF-S1 MUST-FIX).
- ADR-030: Outbound contribution model — `upstream-contribution/` working directory convention, attribution-via-PR-description policy. First outbound submission: meeting-notes skill to `msitarzewski/agency-agents`.
- `upstream-contribution/meeting-notes-upstream.md` — upstream-format version of meeting-notes skill. Writing-profile reference stripped (CF-L1-1). Attribution line in PR description (CF-L4-1).
- Upstream contribution: [PR #521](https://github.com/msitarzewski/agency-agents/pull/521) — meeting-notes skill submitted to `project-management/` category.
- MF-3 vocabulary gate in `quality.yml` — closed allowlist, multi-line YAML form rejected (MF-S1 MUST-FIX).
- MF-1 hardening: `set -o pipefail` per-step scope + `|| BAD=0` pattern replaces `|| true` (CF-v2.4-G / AC-F4-1).
- MF-2 hardening: structural header scan replacing positional `$7` (MF-S2 MUST-FIX / AC-F4-3). awk finds `goal_tags` column by name; skips backtick-wrapped documentation rows.
- `tests/fixtures/registry-column-reorder.md` — regression fixture for MF-2 structural scan (goal_tags at column 3 with BAD_TOKEN).
- `scripts/install-pre-commit.sh` — local markdownlint pre-commit hook installer. Closes the v2.3.0 MD058 gap. Same ruleset as CI `markdown-lint` step.
- `docs/security-review-v2.5.md`, `docs/compliance-review-v2.5.md` — Phase 2 review documents for this cycle.

### Changed
- MF-2 awk now uses structural header scan (goal_tags found by column name, not positional index) — making it resilient to column-reorder in `curated-skills-registry.md`.
- `quality.yml` `skill-depth-check` job: `upstream-contribution/` excluded from depth-check (follows upstream format, not Cowork 9-section template). ADR-016 v2.5 amendment.
- `docs/architecture.md`: ADR-028 ACCEPTED, ADR-029, ADR-030, ADR-007 amendment (v2.5), ADR-016 amendment (v2.5) added.

---

## [2.4.0] — 2026-05-08

### Added
- `skills/` root pool — 20 SKILL.md files (7 presets × 3 skills, minus 1 ADR-018 dedup for research-synthesis). Canonical copy drives all install operations.
- `selection-presets.md` — 7 preset blocks in fenced ` ```preset ` format with `name`, `display_name`, `description`, `skill_bundle`, `scaffold_source`, `match_signals` keys. Authoritative keyword sets for F3 matcher.
- Dynamic goal matcher (F3) in WIZARD.md — keyword set-intersection over `match_signals`, deterministic, no LLM sub-call. Three paths: A (single preset), B (tie), C (novel/custom). STOPWORDS cross-referenced (SF-1).
- Q&A bundle customization (F4) in WIZARD.md — add/remove from `skills/` pool only; ≤3 suggestions per round; URL/external file rejection enforced (SF-3).
- Dynamic install (F5) in WIZARD.md — installs from `skills/<slug>/SKILL.md` pool; ADR-024 attribution injected as numbered step 1-2-3-4 BEFORE file write (SF-2).
- Dynamic `skills-as-prompts.md` generation in WIZARD.md Step 6 — generated from installed bundle, not copied from per-preset stub.
- Fallback legacy workspace paragraph in WIZARD.md (OQ-6).
- CI vocabulary gates (MF-1, MF-2) — `selection-presets.md` token-vocab gate + `curated-skills-registry.md` goal_tags gate. Rejects out-of-charset tokens.
- CI `POOL` loop — validates all `skills/*/SKILL.md` against 9-section template + 60-line floor.
- CI `CMP` assertion — byte-mirror check for all (preset, skill_bundle) pairs; ADR-018 exemption for study/research-synthesis.
- `docs/security-review-v2.4.md` — Phase 2 full security review (MF-1, MF-2, SF-1, SF-2, SF-3 findings).

### Changed
- WIZARD.md Q1: replaced 7-item force-map with open-ended goal discovery (F1/F2/F3).
- WIZARD.md Step 4: dynamic install from pool replaces static preset copy.
- WIZARD.md Step 6: dynamic generation from installed bundle.
- All 7 `examples/*/project-instructions-starter.txt`: Phase 1 section replaced with byte-identical 87-word compact Q1 block (Amendment A3).
- All 7 `examples/*/skills-as-prompts.md`: replaced with byte-identical 5-line deprecation stub (C-v2.4-4).
- `curated-skills-registry.md`: slug fix `email-drafter` → `email-drafting` (MF-2 compliance).
- CI `skill-depth-check` job: ENFORCED_EXAMPLES widened from 3 presets to all 7; POOL + CMP + MF-1 + MF-2 gates added.
- `docs/architecture.md`: ADR-024 thru ADR-028 + ADR Index backfill.
- `docs/spec.md`: v2.4 feature spec + architectural modifications.
- `docs/security-review.md`: v2.4 pointer entry.

### Notes
- `cowork.lock.json` unchanged (C-v2.4-2). Supply-chain integrity maintained.
- `CLAUDE.md` unchanged (C-v2.4-11). Word count ≤400.
- ADR-028 (external skill import) remains PROPOSED — implementation deferred to v2.5.

---

## [2.3.1] — 2026-05-08

### Changed
- Expanded 8 SKILL.md files from stub (18 lines) to production depth (~70–130 lines, 9-section structure):
  - `editing-pass` (writing)
  - `outline-generator` (writing)
  - `creative-brief` (creative)
  - `feedback-synthesizer` (creative)
  - `ideation-partner` (creative)
  - `email-drafting` (business-admin)
  - `follow-up-tracker` (personal-assistant)
  - `spend-awareness` (personal-assistant)
- All 8 files now match the canonical pattern set by `voice-matching`, `daily-briefing`, `meeting-notes`, `risk-assessment` (frontmatter with 4-bullet `trigger_examples`, 9-section body).

### Notes
- No new skills (curated-skills-registry.md cardinality unchanged at 22).
- No registry annotation moves.
- `action-items` and `doc-summary` remain `disposition: covered-by-runtime` (untouched per v2.3.0 W3).
- ADR-028 stays PROPOSED (implementation still deferred to v2.4).
- ENFORCED_EXAMPLES widening to writing/creative/business-admin/personal-assistant deferred to v2.4 hygiene cycle (CF-v2.3.1-A).

---

## [2.3.0] — 2026-05-08

**v2.3 — Top-2 Stub Expansion + ADR-028 Spec Scaffold**

### W1 — voice-matching SKILL.md depth expansion (writing preset)

- **voice-matching → full ADR-015 9-section depth (71 lines):** Replaces 18-line stub with complete skill: When to use, Triggers (4 bullets), Instructions (5 steps), Output format, Quality criteria, Anti-patterns (5 named anti-AI patterns), Example (input/output/meta-note), Writing-profile integration, Example prompts. Imperative-voice convention throughout (C-v2.3-7). 5 named anti-AI patterns: averaging to generic, ignoring samples, em-dash flood, hedged-language overuse, generic transitions (C-v2.3-3). Always consults `context/writing-profile.md` regardless of output length.

### W2 — daily-briefing SKILL.md depth expansion (personal-assistant preset)

- **daily-briefing → full ADR-015 9-section depth (100 lines):** Replaces 18-line stub with complete skill: When to use, Triggers (4 bullets mirroring PA global-instructions lines 16–18), Instructions (7 steps incl. proactive-offer confirmation gate + graceful-degradation ladder), Output format (4-section fixed schema: Intention/Priorities/Time blocks/Protect), Quality criteria, Anti-patterns, Example (vault state + intention questions + 4-section output), Writing-profile integration (tiered: Intention always; Priorities/blocks neutral), Example prompts. Graceful-degradation ladder: Calendar→Tasks→People→ask-user (C-v2.3-8).

### W3 — registry disposition annotations (curated-skills-registry.md)

- **doc-summary annotation:** `disposition: covered-by-runtime` blockquote immediately after doc-summary row. Reason: meeting-notes + Anthropic runtime DOCX/PDF skills + general Claude summarization are sufficient; no in-tree expansion planned.
- **action-items annotation:** `disposition: covered-by-runtime` blockquote immediately after action-items row. Reason: meeting-notes skill already extracts action items as a workflow step; no standalone in-tree expansion planned.
- CI cardinality grep count unchanged at 22 (annotations contain no `| builtin` or `| https://` patterns).

### W4 — ADR-028 PROPOSED spec scaffold (docs/architecture.md, landed at Phase 1)

- **ADR-028: `content_sha256` per-file integrity field for `cowork.lock.json`** (PROPOSED, implementation deferred to v2.4). Specifies: 64-char lowercase hex per-file content hash, optional on pre-v2.4 entries / required on new entries (option (c) new-entries-only migration), reader contract ("presence implies enforcement; absence implies tolerated"), JSON example, CI verification step prose for v2.4.

### W5 — orphan-item closeout

- Orphan commits `a7aa1cb` and `02bdf21` confirmed resolved on main per pipeline.md Phase 0 + Phase 1 rows. No file changes required.

---

## [2.2.0] — 2026-05-08

**v2.2 — Carry-Forward Closeout + Skills Roadmap Discovery**

### W1 — Wizard Quality Fixes

- **D2 — Stopword filter in role-generation rule (WIZARD.md, AC-D2):** Extends AC-W2-9 verbatim-fallback with a 64-token STOPWORDS list. Description is lowercased, tokenized on non-alpha chars, stopwords stripped. Empty filtered token set fires the verbatim fallback unconditionally. Prevents placeholder-quality descriptions from generating unmoored role lines. Example: `description = "the a of"` → fallback fires.
- **D3 — SETUP-CHECKLIST.md migration annotation (AC-D3):** Adds "v2.1 migration complete — historical reference only" blockquote annotation to the `Upgrading from v2.0.x to v2.1.0` section. All original content retained for audit trail — no removal.
- **CFP — Objective field in personal-assistant starter profile (AC-CFP):** Appends `**Objective:** Stay on top of household, family, and personal logistics so nothing important falls through the cracks.` to `examples/personal-assistant/cowork-profile-starter.md` after the `**Goal preset:**` line. Format byte-matches WIZARD.md Step 1 output template per ADR-031.

### W2 — Skills Roadmap

- **docs/skills-roadmap.md (AC-RM-1..4):** New planning artifact for v2.3+ cycle. Three sections: (1) per-stub ROI scan — all 12 stubs receive a COVER-BY-RUNTIME / COVER-BY-EXTERNAL / EXPAND-IN-TREE / REMOVE verdict (9 EXPAND-IN-TREE, 2 COVER-BY-RUNTIME, 0 remove); (2) persona × JTBD coverage matrix — 20 JTBDs × 6 personas with FULL/PARTIAL/RUNTIME/EMPTY cells; (3) ranked v2.3+ candidates — voice-matching in-tree expansion (score 30), daily-briefing in-tree expansion (score 25), and contract-review external import from evolsb/claude-legal-skill (score 20) as top three.

---

## [2.1.0] — 2026-05-07

**v2.1 — Objective-First FSM + Team-Composition Framing + Stub Markers + Symlink Removal**

### Added

- **Objective-first wizard FSM (ADR-029):** CLAUDE.md Phase 1 rewritten as "Phase 1 — Objective & Team". The wizard now opens with "What do you need help with? Tell me what you want this workspace to do for you — I'll assemble the right team." Three routing branches (fits one area / spans areas / novel) all emit named team members with objective-specific roles, not a category list.
- **WIZARD.md §Phase 1 Uncertainty Fallback (ADR-029):** New section inserted before the existing fallback — three angles (Learning / Shipping / Writing) for users who reply "not sure". Referenced by CLAUDE.md Phase 1 final line.
- **WIZARD.md §Phase 1 Role-Generation Rule (ADR-030, AC-W2-9):** Verbatim-fallback rule encoded: if a generated role line does not contain at least one keyword from the source skill's `description` field, fall back to verbatim `description` (truncated to ≤12 words).
- **Resume-after-interrupt with objective context (ADR-031):** WIZARD.md Fallback section rewritten to read `Objective:` from `cowork-profile.md`. v2.0.x profiles (no Objective field) trigger one extra question before resuming. Partial-install detection checks `<workspace>/.claude/skills/` for already-installed team members.
- **`cowork-profile.md` Objective field (ADR-031):** Optional `Objective:` line added to WIZARD.md Step 1 template, after `Goal preset:`. Absence in v2.0.x profiles is non-error (backward-compatible).
- **Stub depth markers (ADR-030):** `depth: stub` and `expansion: v2.2+` YAML frontmatter added to all 12 stub SKILL.md files: writing (editing-pass, outline-generator, voice-matching), creative (creative-brief, feedback-synthesizer, ideation-partner), business-admin (email-drafting, doc-summary, action-items), personal-assistant (daily-briefing, follow-up-tracker, spend-awareness).

### Changed

- **`presets/` symlink removed (ADR-032, ADR-026):** The `presets/` backward-compat symlink (pointing to `examples/`) is removed. `examples/` is the sole canonical path from v2.1.0. All CI, CONTRIBUTING.md, and SETUP-CHECKLIST.md references updated to `examples/`. Upgrade note in SETUP-CHECKLIST.md §Upgrading from v2.0.x.
- **CLAUDE.md word count:** 363 → 397 words (hard cap 400; 3-word buffer). Phase 1 block replaced (81 words → 115 words per ADR-029 verbatim contract).

### Documentation

- **ADR-028** (doc-only): Second trust anchor (content_sha256 pinned-digest) contract frozen for v2.2+ implementation.
- **ADR-033** (codified): Release-artifact completeness checklist (VERSION + CHANGELOG + README badge + Next-up teaser) as a mandatory single Phase 4 sub-step.

---

## [2.0.5] — 2026-05-07

**Chore release — first lock-populated release artifact.**

**Why:** v2.0.4 fixed the subshell scope bug (#28) that was preventing `cowork.lock.json` from populating, but the v2.0.4 release artifact was tagged BEFORE PR #31 merged the first real lock-population (110 files via `/sync-agency`). The v2.0.4 release ZIP shipped with `files: []` despite the code being correct. v2.0.5 re-tags from main HEAD so the release artifact reflects the fully-populated state.

**No code changes.** Identical to v2.0.4 except:
- `cowork.lock.json` now ships with 110 vetted upstream files (`pinned_commit_sha: 783f6a72bfd7f3135700ac273c619d92821b419a`, distributed across 10 categories: marketing 30, engineering 29, testing 8, sales 8, design 8, support 6, project-management 6, product 5, finance 5, academic 5)
- `THIRD-PARTY-NOTICES.md` reflects the same SHA
- VERSION + README badge bumped to 2.0.5

**For users:** Downloading v2.0.5.zip now gives a fully bootstrapped install. v2.0.4 still works but requires a `/sync-agency` dispatch first to populate the lock.

---

## [2.0.4] — 2026-05-06

**Hotfix — fetch loop subshell scope fix + allowlist alignment (#28).**

**Fixed:**
- **#28-A BLOCKER** — Replaced `echo "$CATEGORY_LISTING" | jq -r '...' | while read` pipe pattern with a JSONL accumulator pattern in `sync-agency.yml`. The pipe spawned a subshell; `NEW_FILES_JSON` mutations were invisible to the parent shell, producing `Files fetched: 0` and an empty `cowork.lock.json` regardless of upstream content. The accumulator writes one JSON line per file via `jq -nc --arg/--argjson` (no string interpolation — S1 mitigation), then composes the final array with `jq -s '.'` after the loop completes. Accumulator filename includes `${GITHUB_RUN_ID}` suffix to prevent cross-run `/tmp` collision (E3). `trap EXIT` cleanup prevents accumulator file leak on mid-run failure (E1).
- **#28-B BLOCKER** — Trimmed `.cowork-allowlist.json` `.allowed_categories` from 13 entries to the vetted 10-entry subset matching real upstream `agency-agents/specialized/` directories: `academic, design, engineering, finance, marketing, product, project-management, sales, support, testing`. Removed 6 phantom entries (`business, content-creation, customer-success, data-analysis, hr, legal`) that silently produced empty lock sections because no matching upstream directory exists.

**Added:**
- **JSONL accumulator regression gate** in `sync-agency-dry-run` CI job (`quality.yml` step 3). Fetches 2 sample files from `academic/`, builds a JSONL accumulator exactly as `sync-agency.yml` does, then asserts `jq -s '.' | length >= 1`. Catches subshell-class regressions at PR time before any sync-agency edit ships broken to main.

---

## [2.0.3] — 2026-05-07

**Hotfix — sync-agency authentication + dry-run CI gate.**

**Fixed:**
- **#25 BLOCKER** — Added `Authorization: bearer ${GITHUB_TOKEN}` to all `api.github.com` curl calls in `sync-agency.yml` (HEAD-SHA fetch + per-category content listing). Without auth, GitHub Actions runner anonymous-IP pool rate-limits caused `curl -sf` to fail silently, blocking the workflow at "Fetch upstream latest HEAD SHA". Authenticated calls use the 5000-req/hr pool. `raw.githubusercontent.com` calls do NOT require auth (separate pool, anonymous-friendly).

**Added:**
- **`sync-agency-dry-run` CI job** in `quality.yml` — runs on every PR that touches `sync-agency.yml`, the THIRD-PARTY-NOTICES template, the allowlist, or the lock file. Simulates the first three critical workflow steps (fetch HEAD SHA via auth, fetch LICENSE, content-scan regex compile-check) at PR time, catching auth/rate-limit/regex/structural BLOCKERs BEFORE merge instead of post-merge. Closes the 3-cycle pattern (v2.0 #12 YAML, v2.0.1 envsubst, v2.0.2 SPDX/regex, v2.0.3 #25 auth). Pinned with `permissions: { contents: read }` for fork-PR safety (S1 Phase 2 finding).

**Process improvement:**
- Pattern P3 (action SHA hallucination) and the new dry-run gate together close the post-merge BLOCKER recurrence pattern observed across v2.0.0 → v2.0.2.

---

## [2.0.2] — 2026-05-07

**Hardening Bundle — 10 security, compliance, and documentation fixes from v2.0/v2.0.1 carry-forward.**

**Fixed:**
- **#23 BLOCKER** — Corrected hallucinated `peter-evans/create-pull-request` SHA in `sync-agency.yml`. Previous SHA (271a8d0...) was not a real commit; replaced with verified v7.0.6 SHA (67ccf78...). Without this fix, the PR-creation step in `/sync-agency` fails silently.
- **#13** — Added per-file SPDX comparison step to `sync-agency.yml`. Reads OLD `.files[].spdx` from the pre-update lock file, compares to NEW entries from the fetch. If any SPDX field changes: adds `legal-review-required` label AND fails CI until @compliance acknowledges. Bootstrap-tolerant (skips when old lock has no `.files[]` entries). Closes ADR-022 compliance gap (v2.0 Phase 5 C8).
- **#14** — Created `.github/PULL_REQUEST_TEMPLATE.md` with Summary, Test plan, and Agency-Sync Checklist sections. Checklist (collapsible, agency-sync-only) requires lock file diff review, ≥3 file sample-audit per category, nexus-strategy.md absence check, SPDX acknowledgment, and 24h soak rule. Closes v2.0 Phase 6 A3 finding.
- **#15** — Added `verbatim-attribution-rule-check` job to `quality.yml`. Greps `CLAUDE.md` and `WIZARD.md` for the exact 4-sentence non-overridable attribution rule (ADR-024). Fails CI if the literal string is absent from either file. Closes G3 finding from v2.0 Phase 5.
- **#16** — Closed as superseded by ADR-027. ADR-027 (template extraction, v2.0.1) eliminates the heredoc delimiter surface that issue #16 proposed randomizing.
- **#17** — Changed fetch loop staging path from `/tmp/fetched-files/${filename}` to `/tmp/fetched-files/${category}/${filename}` with `mkdir -p` guard. Prevents filename collisions across categories. Closes A6 finding from v2.0 Phase 6.
- **#18** — Added `permissions: read-all` at workflow top level in `sync-agency.yml`. Job-level `contents: write, pull-requests: write` explicit grants remain. Closes A7 finding from v2.0 Phase 6.
- **#19** — Added Windows symlink note to `SETUP-CHECKLIST.md` explaining `presets/ → examples/` symlink behavior. Three workarounds documented: (a) Developer Mode, (b) `git clone -c core.symlinks=true`, (c) use `examples/` directly. Notes symlink removed in v2.1.0 (ADR-026). Closes A8 finding from v2.0 Phase 6.
- **#20** — ADR-023 amendment block recording live 13-category enumeration from `.cowork-allowlist.json` written to `docs/architecture.md` by @architect Phase 1. Closes v2.0 Phase 5 B2 (ADR-023 placeholder drift). Live categories: `academic`, `business`, `content-creation`, `customer-success`, `data-analysis`, `design`, `engineering`, `finance`, `hr`, `legal`, `marketing`, `product`, `support`.
- **#21** — Added `concurrency: { group: sync-agency, cancel-in-progress: false }` at workflow top level in `sync-agency.yml`. Prevents concurrent sync-agency runs; in-progress runs are preserved when a new push queues. Closes A4 finding from v2.0 Phase 6.
- **P3 baseline** — Extended `CONTRIBUTING.md` CI Workflow Quality Baseline with Check 3: every `uses:` SHA MUST be verified via `gh api repos/<owner>/<repo>/git/refs/tags/<tag>` at Phase 5. Hallucinated SHAs are blocking. Codifies P3 pattern from v2.0 retrospective.

**YAML validation:** `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/sync-agency.yml'))"` and `yaml.safe_load(open('.github/workflows/quality.yml'))` both pass.

---

## [2.0.0] — 2026-05-07

**Dynamic Workspace Architect — upstream content integration via msitarzewski/agency-agents.** Major supply-chain infrastructure: SHA-pinned lock file, fail-closed allowlist, monthly sync CI, prompt-injection content scan, attribution injection (ADR-024 full MIT block), THIRD-PARTY-NOTICES.md. All 8 Phase 2 MUST-FIX security items resolved. Presets relocated to `examples/` (v1.x symlink preserved for v2.0.x).

**Added:**
- `cowork.lock.json` — supply-chain lock file (ADR-020): pinned upstream SHA + per-file SHA-256 checksums. Bootstrap state: zero-SHA (populate via `/sync-agency`).
- `.cowork-allowlist.json` — fail-closed allowlist policy (ADR-023): 13 allowed categories, `nexus-strategy.md` permanently blocked, 9-entry `blocked_patterns` seed (nexus variants, orchestrator, meta-agent, pipeline-controller, the-council, cowork-orchestrator).
- `.github/workflows/sync-agency.yml` — hybrid cron (monthly) + manual dispatch; fetches upstream at pinned SHA; runs S1 8-pattern content-scan; updates lock file; regenerates `THIRD-PARTY-NOTICES.md`; opens PR labeled `agency-sync`; never auto-merges. All Action SHAs pinned (ADR-002).
- `.github/CODEOWNERS` — supply-chain files require maintainer sign-off (S2 MUST-FIX).
- `docs/security/upstream-content-scan-rules.md` — 8 prompt-injection detection patterns for upstream content (S1 CRITICAL MUST-FIX): ignore previous instructions, disregard, override, you are now/act as, new system instruction, forget the rules, pretend you have no, jailbreak/DAN/STAN.
- `THIRD-PARTY-NOTICES.md` — repo-level upstream copyright notices (ADR-025, L1-2 WARNING resolved). Regenerated by `/sync-agency` on every SHA bump.
- `examples/` — all 7 v1.x preset directories relocated here (byte-identical move, git blame preserved).
- `presets` symlink → `examples/` (v2.0.x deprecation alias; removed in v2.1).

**Changed:**
- `CLAUDE.md` — added `## Attribution (non-overridable, ADR-024)` section with S6 verbatim rule; category-discovery flow updated for upstream categories (academic, marketing, engineering, etc.); trimmed to 363 words.
- `WIZARD.md` — added `## Attribution Rule (non-overridable, ADR-024)` section with S6 verbatim rule; `presets/` → `examples/` path references updated.
- `CONTRIBUTING.md` — added Agency-Sync PR Review section: 2-approval rule (S2), 10-item reviewer checklist, 24h soak rule (S7), goal taxonomy keyword review (S10).
- `SETUP-CHECKLIST.md` — added trust-boundary disclosure (Open Issue #6); `presets/` → `examples/` path references.
- `README.md` — version badge 1.3.3 → 2.0.0; added supply-chain integrity section; trust-boundary disclosure (Open Issue #6); "Next up" → v2.1 Multi-Source Upstream; `presets/` → `examples/` references.
- `.github/workflows/quality.yml` — `ENFORCED_PRESETS` → `ENFORCED_EXAMPLES` (ADR-026, both enforcement + advisory blocks); all CI path globs updated `presets/` → `examples/`; new `lock-file-zero-sha-check` job (S9: reject zero-SHA on main); new `third-party-notices-check` job (ADR-025 existence); new `attribution-survives-render` job (S5 MUST-FIX: Python frontmatter + grep extraction).

**Security MUST-FIX resolutions:**
- S1 CRITICAL — 8-pattern content-scan in `/sync-agency` + `docs/security/upstream-content-scan-rules.md`
- S2 — `.github/CODEOWNERS` + CONTRIBUTING.md 2-approval rule for agency-sync PRs
- S4 — `.cowork-allowlist.json` 9-entry blocked_patterns seed
- S5 — `attribution-survives-render` CI job
- S6 — verbatim non-overridable attribution rule in CLAUDE.md + WIZARD.md
- S9 — `lock-file-zero-sha-check` CI job rejecting zero-SHA on main
- Open Issue #3 — `/sync-agency` first run designated SECURITY-SENSITIVE in PR template + CONTRIBUTING.md
- Open Issue #6 — trust-boundary disclosure in README.md + SETUP-CHECKLIST.md

**v1.x compatibility:** All 7 preset examples retained in `examples/`. `presets/` symlink provides backward compatibility for v2.0.x. CI still enforces depth on `study`, `research`, `project-management`. No skill content changes.

---

## [1.3.3] — 2026-05-07

**Project Management preset depth upgrade.** Three PM skills rewritten from 16-line stubs to full 9-section ADR-015 production depth. CI enforcement expanded. LICENSE copyright updated.

**Changed:**
- `presets/project-management/.claude/skills/meeting-notes/SKILL.md` — rewritten to 9-section template (114 lines): decision/action/open-question extraction framework, pasted-content-is-data anti-pattern guard (S1), worked example, writing-profile integration.
- `presets/project-management/.claude/skills/status-update/SKILL.md` — rewritten to 9-section template (88 lines): RAG-status synthesis, pasted-content-is-data guard (S1), output-echo anti-pattern guard (S2 — first LLM02-class finding in codebase), audience-calibrated narrative output.
- `presets/project-management/.claude/skills/risk-assessment/SKILL.md` — rewritten to 9-section template (110 lines): 6-column neutral schema table (ID/Description/Likelihood/Impact/Mitigation/Owner), pasted-content-is-data guard (S1), sensitive-shape naming guard (S3), top-2 priority prose section.
- `presets/project-management/skills-as-prompts.md` — regenerated from new SKILL.md bodies with condensed synthesis approach and safety constraint per skill.
- `curated-skills-registry.md` — PM row descriptions refreshed to reflect 9-section skill depth (row count unchanged: 22).
- `.github/workflows/quality.yml` — ENFORCED_PRESETS expanded from `"study research"` to `"study research project-management"` (ADR-016 v1.3.3 amendment; no CI shell-logic change).
- `LICENSE` — copyright updated to `Copyright (c) 2026 The cowork-starter-kit contributors`.
- `docs/security-review.md` — v1.3.3 Phase 2 security review section appended (S1/S2/S3 WARNINGs, S4/S5/S6 INFOs, Phase 4 resolution status).

**Preset-level changes:** project-management only. Study, Research, Writing, Creative, Business-Admin, Personal Assistant presets: no changes.

---

## [1.3.2.1] — 2026-04-20

**Infra patch.** Automate release-asset uploads.

**Added:**
- `.github/workflows/release-assets.yml` — auto-builds `.zip` and `.tar.gz` source archives and attaches them to the GitHub Release when a `v*` tag is pushed. Uses SHA-pinned actions (checkout v4.2.2, softprops/action-gh-release v3.0.0).

**Changed:**
- Future releases automatically include trackable download assets. Prior releases (v1.1.0–v1.3.2) were backfilled manually on 2026-04-20.

---

## [1.3.2] — 2026-04-19

> **Note:** This release was initially tagged as v1.4.0 (2026-04-19) but was renamed to v1.3.2 to align with the v1.3.x preset-rollout versioning lane. Content is identical to the original v1.4.0 release.

**Personal Assistant Preset (7th preset) + Security Posture.** Adds a new goal preset for daily personal life management, introducing the first sensitive-personal-data surface in cowork-starter-kit history and the ADR-019 Data-Locality Rule pattern.

**Added:**

- 7th preset `presets/personal-assistant/` — full scaffold: README, folder-structure (Calendar/, Finances/, Tasks/, People/, Documents/), writing-profile, connector-checklist, context/ (5 files), project-instructions-starter.txt, cowork-profile-starter.md, skills-as-prompts.md
- 3 stub skills for Personal Assistant preset:
  - `presets/personal-assistant/.claude/skills/daily-briefing/SKILL.md` — 16-line stub; morning briefing from local Calendar/, Tasks/, People/ folders
  - `presets/personal-assistant/.claude/skills/follow-up-tracker/SKILL.md` — 16-line stub; logs commitments owed and pending from conversations and inbox
  - `presets/personal-assistant/.claude/skills/spend-awareness/SKILL.md` — 16-line stub; paste-based transaction summarizer; descriptive only (no investment advice, budgeting recommendations, or savings plans)
- ADR-019 "Instruction-Surface Security Posture" — 4-element contract for data-category constraints (exact heading, grep phrase, placement, setup-surface reinforcement); explicit scope limitation: NOT appropriate as sole control for regulated data (HIPAA PHI, PCI, GDPR Art. 9); bold callout block added to architecture.md per S7
- ADR-015 v1.3.2 amendment — Trigger 1 direct-invocation exempt from proactive-mapping requirement with global-instructions.md; codifies v1.3.1 Phase 6 implicit behavior
- Data Locality Rule in `presets/personal-assistant/global-instructions.md` — 6 sensitive-data categories (financial amounts, calendar events, contact details, health information, physical addresses, authentication credentials); decline-and-redirect rule; pasted-content-as-data rule; placed BEFORE proactive trigger rules per ADR-019
- New persona: Life Admin Juggler (v1.3.2 PRD)
- `presets/personal-assistant/connector-checklist.md` — finance paste-only prohibition with explicit naming of prohibited connectors (Plaid, Yodlee, bank APIs)
- S4 note in ADR-019 Consequences: redaction escape-valve scoped to PA preset in v1.3.2; community preset authors must revisit before broadening

**Changed:**

- `WIZARD.md` Q1 — Personal Assistant added as 7th goal option; Q3 — preset-specific question added for Personal Assistant; fallback message updated "6 options" → "7 options"
- `CLAUDE.md` — `personal-assistant` alias added to preset enumeration (350 words maintained via compensating trim of "sample" in Step 6 phrasing — non-semantic trim)
- `curated-skills-registry.md` — Personal Assistant section added; 3 new rows (daily-briefing, follow-up-tracker, spend-awareness); total 19 → 22 entries
- `README.md` — version badge 1.3.1 → 1.3.2; preset table updated to 7 presets; "Six goal presets" → "Seven goal presets"; Next up teaser updated
- `docs/security-review.md` — v1.3.2 Phase 2 security review appended (0 CRITICAL / 3 WARNING / 6 INFO; classification SECURITY-SENSITIVE; data-locality verdict ACCEPT WITH REFINEMENT; all 6 @architect open issues resolved)

**Security:**

- First SECURITY-SENSITIVE cycle since v1.2; first sensitive-personal-data surface in cowork-starter-kit history
- 9 MUST-FIX carry-forwards from Phase 2 absorbed: S1 (data-category extension), S2 (pasted-content-as-data rule), S3 (CLAUDE.md word-count preserved), S4 (ADR-019 S4 note), S5 (spend-awareness anti-pattern line), S6 (finance connector prohibition), S7 (ADR-019 scope bold callout), S8 (WIZARD.md "7 options"), Issue 5 (IP boundary grep — 0 hits confirmed)

---

## [1.3.1.1] — 2026-04-18

**Documentation patch.** No functional changes.

**Changed:**
- README.md version badge corrected 1.2.0 → 1.3.1 (stale since v1.3.0 release)
- README.md "Next up" teaser updated from shipped v1.3.0 to upcoming v1.3.2 Writing preset depth
- templates/skill-template/SKILL.md CONTRIBUTOR NOTICE block — removed stale "(arriving in v1.3.0 B2 commit)" future-tense reference; placeholder authoring rules are now live

---

## [1.3.1] — 2026-04-18

**Research Preset Depth + Carry-Forward Hygiene** — rewrites all 3 Research preset skills to the full 9-section ADR-015 template, expands skill-depth CI enforcement to include the Research preset, and resolves all 3 Phase 2 v1.3.1 security carry-forwards.

**Added:**

- 3 Research preset skills rewritten to full depth:
  - `presets/research/.claude/skills/literature-review/SKILL.md` — thematic matrix + gap analysis framework; theme/source count header; 7 quality criteria; 7 anti-patterns; four-tier writing-profile rule (cells terse, count-line neutral, synthesis adapts, gaps adapt); BibTeX-aware extension
  - `presets/research/.claude/skills/source-analysis/SKILL.md` — 7-field evaluation card (source type, authority, methodology, evidence quality, limitations, bias, bottom line); citation recommendation as Bottom line; two-tier writing-profile rule (fields 1–6 terse, Bottom line adapts)
  - `presets/research/.claude/skills/research-synthesis/SKILL.md` — Research preset variant (ADR-018); always peer-review-rigor; 7-column matrix (claim, method, evidence, limitations, authority, recency, citation-network); four synthesis sections (Agreements, Disagreements, Gaps, Synthesis); four-tier writing-profile rule; intentionally distinct from Study variant
- `presets/research/skills-as-prompts.md` — regenerated from the 3 new Research SKILL.md files; replaces v1.0 stubs with full 9-section prose content for each skill; preserves ADR-003 dual-path fallback usability

**Changed:**

- `presets/research/global-instructions.md` — trigger rules expanded to cover all 4 modes per Research skill (literature-review: academic survey + thesis chapter; source-analysis: citation vetting + claim-specific evaluation; research-synthesis: peer-review prep + systematic review + meta-analysis framing)
- `curated-skills-registry.md` — Research preset descriptions updated to match v1.3.1 SKILL.md frontmatter; new `research-synthesis` Research entry added (ADR-018 dual-file; 19 total rows); vetting dates updated to 2026-04-18
- `.github/workflows/quality.yml` — `skill-depth-check` job: `ENFORCED_PRESETS` expanded from `"study"` to `"study research"`
- `CONTRIBUTING.md` — v1.3.1: B10 input-session template section added (full 6-Q schema, defaults+clarify pattern for skills 2+); After Phase 7 push-and-PR checklist added; PR reviewer checklist item 19 added (cross-preset slug-divergence check per ADR-018)
- `CLAUDE.md` — trimmed to 350 words (carry-forward from v1.2 audit A3; target met)

**Security (Phase 2 carry-forwards resolved):**

- S1 (MUST-FIX): CONTRIBUTING.md B10 section documents 3 worked-example authoring rules (real sources only; forbidden imperative token scan; user-written expected output); all 3 Research SKILL.md `## Example` sections cite real peer-reviewed sources (Miller 1956, Baddeley 2000, Cowan 2001) with no imperative tokens outside code fences
- S2 (SHOULD-FIX): CONTRIBUTING.md PR reviewer checklist item 19 added for cross-preset slug-divergence verification (ADR-018 enforcement by review, not CI)
- S3 (MUST-FIX): `presets/research/global-instructions.md` updated so all 4 trigger modes per Research skill map to "offer automatically when" firing conditions; `## Triggers` sections in B1/B2/B3 are a subset-or-extend of the updated global rules

---

## [1.3.0] — 2026-04-18

**Preset Skills Depth — Study Preset Pilot** — rewrites all 3 Study preset skills to the full 9-section ADR-015 template, adds skill-depth CI enforcement, and resolves all 4 Phase 2 v1.3 security carry-forwards.

**Added:**

- 9-section skill template (ADR-015): `## When to use`, `## Triggers`, `## Instructions`, `## Output format`, `## Quality criteria`, `## Anti-patterns`, `## Example`, `## Writing-profile integration`, `## Example prompts` — enforced via CI for the Study preset pilot
- `skill-depth-check` CI job (ADR-016): validates each Study preset skill has all 9 required section headings and meets the 60-line floor; path allowlist prevents false positives on non-skill files
- 3 Study preset skills rewritten to full depth:
  - `presets/study/.claude/skills/flashcard-generation/SKILL.md` — Anki-ready output with human-readable + TSV blocks, 6 quality criteria, 6 anti-patterns, writing-profile integration, spaced-repetition atomicity rules
  - `presets/study/.claude/skills/note-taking/SKILL.md` — 4-framework auto-selection (Cornell / Outline / Zettelkasten / Lightweight), 11-step instructions, 7 quality criteria, 7 anti-patterns, 3-tier writing-profile rule
  - `presets/study/.claude/skills/research-synthesis/SKILL.md` — source-count mode auto-selection (1/2/≥3), full matrix + synthesis output, BibTeX-aware extension, 7 quality criteria, 7 anti-patterns
- Retro-template carry-forward workflow (B8): `docs/retro.md` v1.3.0 section added with carry-forward surfacing process
- README "Next up" teaser (B9): `## Next up` section added describing v1.4 Research preset pilot
- CONTRIBUTING.md v1.3: checklist items 12–17 added (skill-depth-check CI requirements); placeholder-authoring rules: 5 rules stating when placeholder content is acceptable (no undeclared gaps, examples must be real)
- `.gitignore` guard: patterns added for `.claude/projects/` and `skill-inputs/` directories to prevent accidental commit of local pipeline state and user skill-input files (S4 carry-forward)

**Changed:**

- `curated-skills-registry.md`: Study preset descriptions updated to match v1.3.0 SKILL.md frontmatter (`description:` field) for all 3 entries; vetting dates updated to 2026-04-18
- `presets/study/skills-as-prompts.md`: regenerated from the three v1.3.0 SKILL.md files; replaces 16-line v1.2 stubs with full 9-section prose content for each skill; preserves ADR-003 dual-path fallback usability as a single pasteable prompt
- `.github/workflows/quality.yml` `registry-url-check` job: tightened URL validation to require `https://github.com/` prefix for non-builtin entries (was any HTTPS URL)

**Security (Phase 2 carry-forwards resolved):**

- S1: CI advisory notice added — `skill-depth-check` job comments warn when a skill file is near the CI floor; CONTRIBUTING.md v1.3 documents the fail-open rationale
- S2: CONTRIBUTING.md v1.3 item 16 added: SHA-pin all GitHub Action versions before publishing community skills
- S3: Inline negative test added to `skill-depth-check` CI job: verifies the check correctly rejects a synthetic 59-line stub
- S4: `.gitignore` guard added for `skill-inputs/` and `.claude/projects/` — prevents local user input files from being committed to the public repo

---

## [1.2.0] - 2026-04-17

**Dynamic Workspace Architect** — the wizard now discovers your goal before proposing a workspace, adds a universal writing profile step for all presets, and ships a curated skills registry for goal-matched skill discovery.

**All 6 presets updated.**

**New files:**

- `curated-skills-registry.md` — Tier 1 curated skills registry at repo root; 18 vetted entries (3 per preset); Tier 2 community section with opt-in instructions; community PR process for additions
- `templates/writing-profile-template.md` — canonical writing profile template with 5 sections; used by contributors for new presets; CI-enforced
- `presets/*/context/writing-profile.md` (6 new files) — goal-appropriate writing profile defaults for each preset; not blank; user fills in personal details

**Updated files (all presets):**

- `project-instructions-starter.txt` (6 files) — rewritten with dynamic wizard flow: open-ended goal discovery, suggestion branch for uncertain users, preset detection + accelerator offer, novel-goal handling, writing profile step (3–4 questions), fast-track pause; ≤400 words each
- `global-instructions.md` (6 files) — added writing profile trigger rule: reference `writing-profile.md` when generating content ≥100 words

**Infrastructure:**

- `CLAUDE.md` — rewritten with full dynamic wizard (same as starter files); replaces v1.1.1 preset-selector content; Layer 1a universal entry point per ADR-010
- `CONTRIBUTING.md` — PR checklist updated to v1.2 (11 items); added CLAUDE.md high-impact guidance, registry entry requirements, SHA-pinning guidance, writing-profile.md requirements
- `.github/workflows/quality.yml` — 3 new CI jobs: `claude-md-word-count-check` (≤400 words), `writing-profile-template-check` (template + required sections), `registry-url-check` (HTTPS-only source_url)
- `VERSION` — bumped to 1.2.0

---

## [1.1.1] - 2026-04-16

**Zero-paste setup** — adds `CLAUDE.md` at repo root so Cowork auto-runs the onboarding wizard when you open the project. No copy-paste required.

**New files:**

- `CLAUDE.md` — project instructions auto-loaded by Cowork; contains preset-agnostic onboarding state machine and safety rule

**Updated files:**

- `README.md` — Quick Start simplified to 3 steps (download, open, talk)
- `SETUP-CHECKLIST.md` — paste step demoted to optional; wizard starts automatically
- `.github/workflows/quality.yml` — new CI job: `claude-md-safety-rule-check`
- `VERSION` — bumped to 1.1.1

---

## [1.1.0] - 2026-04-16

**Wizard Architecture Redesign** — fixes the v1.0 root cause failure where Cowork's intent classifier intercepted WIZARD.md before it could be read.

**All 6 presets updated.**

**New files (all presets):**

- `project-instructions-starter.txt` — paste into Project Settings > Custom Instructions BEFORE any conversation; contains state machine check + abbreviated onboarding interview + ongoing behavior rules; primary trigger path
- `.claude/skills/<skill-name>/SKILL.md` — all skills converted from flat `.md` to `folder/SKILL.md` format with YAML frontmatter for auto-discovery as `/slash-commands`

**Updated files (all presets):**

- `global-instructions.md` — rewritten from passive skill list to proactive trigger rules format; explicit trigger conditions and offer phrases for each skill
- `context/about-me.md` — added `Upcoming deadlines:` field for session-start deadline surfacing

**Infrastructure:**

- `.claude/skills/setup-wizard/SKILL.md` — root-level /setup-wizard skill for explicit fallback invocation; includes reset confirmation guard
- `WIZARD.md` — marked documentation-only with top note; no longer a runtime path
- `SETUP-CHECKLIST.md` — Step 3 is now paste `project-instructions-starter.txt` (before any conversation)
- `README.md` — updated flow diagram and Quick Start with new architecture
- `CONTRIBUTING.md` — PR checklist updated to v1.1 (7 items including starter file, word count, safety rule in starter, skill format)
- `templates/preset-template/` — added `project-instructions-starter.txt` template and `example-skill/SKILL.md`
- `docs/OUTPUT-STRUCTURE.md` — updated to show `project-instructions-starter.txt` as primary output artifact
- `.github/workflows/quality.yml` — 3 new CI jobs: `starter-file-check`, `starter-safety-rule-check`, `skill-format-check`
- `VERSION` — bumped to 1.1.0

---

## [1.0.0] - 2026-04-15

Initial release.

**Presets included:**

- Study — research, note-taking, flashcard generation
- Research — literature review, source analysis, synthesis
- Writing — voice matching, editing, outlining
- Project Management — status updates, meeting notes, risk assessment
- Creative — ideation, creative briefs, feedback synthesis
- Business/Admin — email drafting, report summary, action items

**Infrastructure:**

- WIZARD.md — Cowork-as-wizard primary delivery
- SETUP-CHECKLIST.md — manual fallback path
- scripts/setup-folders.sh — bash folder creation (macOS)
- scripts/setup-folders.ps1 — PowerShell folder creation (Windows)
- templates/preset-template/ — contributor scaffold
- templates/global-instructions-base.md — safety rule source of truth
- .github/workflows/quality.yml — CI: markdown lint, link check, shellcheck, safety-rule enforcement
