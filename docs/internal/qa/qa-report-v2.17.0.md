# QA Report — Cowork Starter Kit v2.17.0 · The Steward (Auto-Cleaning)

## Phase: 5 (Testing — INDEPENDENT FRESH-FIXTURE GATE)
## Date: 2026-07-21T20:30:00Z
## Reviewer: @qa (independent Phase-5 pass — every fixture below authored fresh this session, in a scratch directory outside this repo's working tree; none reused from `@dev`'s `tests/self-archive-firing-controls.md` fixture names, filenames, timestamps, or byte content)
## Branch: `feature/v2.17-steward-autoclean` @ `a3241f9` (worktree confirmed: `main..HEAD` shows `a3241f9` + `720b0de` + `a7367d6`)
## Status: **PASS-WITH-NOTES** — all 5 firing-control buckets independently re-fired GREEN+RED with fresh fixtures (0 checks found to be check-that-cannot-fail, 0 unearned-REDs). All 6 relevant CI gates run locally and PASS. **1 NEW documentation-accuracy issue found** (belt-and-suspenders framing overstates namespace coverage for a specific file class) — not a live vulnerability (every currently-named path IS denied), but a latent forever-obligation the design explicitly claims to have escaped. See §New Finding.

> This is a prose/instruction kit (Markdown + YAML) — no `lib/core/`, no Vitest/Playwright surface for this cycle's diff. Verification is executable shell mechanics (for the git-archive/fingerprint/rollback/grep controls) + textual/predicate re-implementation (for the AC-DENY-1/2 gate logic), per this repo's own established convention (`docs/internal/qa/qa-report-v2.16.0.md`).

---

## Unit Tests
N/A — no code-level unit test surface. Executable checks run this session: 5 firing-control buckets (each with GREEN + RED legs) + 4 CI-equivalent gates run locally. All fixtures fresh (new filenames, new byte content, new scratch directories — never `/home/user/claude-cowork-config`'s own tracked tree, so no risk of polluting branch history).

## E2E Tests
N/A — no browser/UI surface. Behavioral/textual simulation substitutes for the two controls that are pure LLM-prose (SECGATE path-channel render discipline, AC-DENY-1/2 predicate logic), per convention.

---

## Per-Control Table (5 firing-control buckets, each independently re-run with fresh fixtures)

| # | Control (AC) | Fresh fixture (this session, distinct from `@dev`'s) | GREEN leg | RED leg (firing) | Verdict |
|---|---|---|---|---|---|
| 1 | S1/S2 archive non-publication (`C-v2.17-8` reframe) | Scratch git repo `s1test/`, canary files `context/.archive/qa-canary-move.md.20260721T170000Z` and `context/.apply-backups/qa-canary-backup.pre` (both paths — `@dev`'s test only force-added into `.archive/`; I additionally covered `.apply-backups/` end-to-end). | `git check-ignore -v` matched both paths; `git archive HEAD \| tar t` omitted both force-added canaries. | Stripped `.gitignore` archive-line → `check-ignore` stopped matching (RED). Stripped `.gitignore` apply-backups-line → same (RED). Stripped `.gitattributes export-ignore` for `context/.archive/` → canary reappeared in `git archive` listing (RED). Stripped it for `context/.apply-backups/` → canary reappeared too (RED) — **this 4th sub-case was not in `@dev`'s test file; added it for full path-pair coverage.** | SOUND (4/4 sub-controls fire) |
| 2 | AC-VERIFYMOVE-2 corruption fingerprint mismatch | `source_area/quarterly-notes-v9.md` (165 bytes, fresh sentence, sha256 `e8c2a70c…`). | Untouched copy: length + checksum match exactly → PASS confirmed as a genuine PASS (not just "RED confirmed" — verified the GREEN leg actually passes, closing the "unearned-RED" gap: a check that always fails is equally broken as one that always passes). | `truncate -s -17` on the dest → length 148 vs 165, checksum diverges → correctly reports FAIL → rollback. | SOUND (both legs independently exercised) |
| 3 | AC-ROLLBACKMOVE-2 terminal state | Same fixture as #2. | On verifier FAIL, removed the corrupted dest, kept source: `source copies=1 dest copies=0 source_checksum_matches=yes`. | Simulated a buggy rollback that re-copies to dest instead of removing it → `source copies=1 dest copies=1` → terminal-state assertion correctly fails (RED). | SOUND |
| 4 | AC-VERIFYMOVE-3 reference-integrity (read-only, scoped-enumerated) | Ran directly against this repo's real, already-committed content (same grounding instance `@dev` used — `self-apply/SKILL.md`'s 3 live pointers — but independently re-derived the grep and independently chose `skills/weekly-review/SKILL.md` as the byte-identity target file, not `memory-of-use.md` as `@dev` did). | 3 live literal references found (`templates/preset-template/context/memory-of-use.md:7`, `skills/weekly-review/SKILL.md:29`, `templates/workspace-claude-md-template.md:31`). SHA-256 of `skills/weekly-review/SKILL.md` identical before/after the grep → confirms read-only. | Re-ran the grep with `context/*.md` AND `.claude/skills/*/SKILL.md` dropped from the enumerated set → both `memory-of-use.md:7` and `weekly-review/SKILL.md:29` went completely invisible (RED). | SOUND |
| 5 | AC-DENY-1/2 predicate logic (mechanical re-implementation, not narrated) | Wrote a standalone shell re-implementation of the positive-predicate conditions (a)–(f) exactly as described in `skills/self-archive/SKILL.md` §"The move-eligibility gate", independent of `@dev`'s prose, and ran it against every FW-1 path + the floor + hypothetical new paths. | All 14 currently-named deny paths (`CLAUDE.md`, `cowork-profile.md`, `global-instructions.md`, `folder-structure.md`, `skills-as-prompts.md`, `project-instructions.txt`, `.mcp.json`, `.claude/settings.json`, `.claude/settings.local.json`, `cowork.lock.json`, `.cowork-allowlist.json`, `CONTRIBUTING.md`, `LICENSE`, `README*.md`-class) correctly classify as DENIED. | See §New Finding below — a RED case exists that is **not** one of `@dev`'s named firing controls: a *hypothetical future* root-level `.md` convention file not yet added to the named list (e.g. `workspace-manifest.md`) mechanically evaluates as ELIGIBLE under the predicate as literally written, even though it belongs to the same class as the six named files. | SOUND for every path named in spec.md; **new residual found for the not-yet-named-file class** |

**Summary: 5/5 firing-control buckets exercised with genuinely fresh fixtures. 0 controls found to be check-that-cannot-fail. 0 unearned-REDs (every GREEN leg was independently confirmed to actually pass, not just assumed). 1 new residual found in control #5, detailed below.**

---

## CI Gates Run Locally (this cycle's diff: `.gitattributes`, `.gitignore`, `CHANGELOG.md`, `README.md`, `VERSION`, `WIZARD.md`, `curated-skills-registry.md`, `docs/architecture.md`, `docs/assumptions.md`, `docs/internal/security/security-review-v2.17.0.md`, `docs/roadmap.md`, `docs/spec.md`, `skills/self-archive/SKILL.md`, `tests/self-archive-firing-controls.md`)

| Check | Result |
|---|---|
| `.github/workflows/` touched by this diff? | **NO** (confirmed via `git diff --name-only main..HEAD`) — Tier-B PR-only ceremony correctly not triggered; standard SECURITY-SENSITIVE worktree+PR ceremony applies (already satisfied — on branch `feature/v2.17-steward-autoclean`). |
| `markdownlint-cli2` on `skills/self-archive/SKILL.md`, `tests/self-archive-firing-controls.md`, `WIZARD.md`, `curated-skills-registry.md`, `README.md`, `CHANGELOG.md` | PASS — 0 issues. |
| `registry-cardinality-check` (min 18 rows) | PASS — 28 entries found. |
| `wizard-consistency-check` (presets/pool/registry/setup-wizard agreement + personalization placeholders) | PASS — `self-archive` is bundle-independent (mirrors `self-apply`), correctly absent from `selection-presets.md` core/optional/cross_cutting lists, so the byte-mirror (CMP) job does not apply to it (same precedent as `self-apply`, confirmed not referenced in `selection-presets.md`). |
| `version-consistency-check` (VERSION == README badge == CHANGELOG top) | PASS — all three read `2.17.0`. |
| `registry-url-check` (self-archive row) | PASS — `source_url` = literal `builtin`. |
| `MF-3 tools: vocabulary gate` (self-archive frontmatter) | PASS — `tools: [claude-code]`, single allowed token. |
| `skill-depth-check` (9-section template + 60-line floor, POOL loop) | PASS — `skills/self-archive/SKILL.md` has all 9 required section headers and is 129 lines (floor 60). |

---

## New Finding (documentation-accuracy residual, not a live vulnerability)

**Where:** `skills/self-archive/SKILL.md`, "The move-eligibility gate" section (the paragraph beginning "The default-deny-by-namespace floor").

**What the prose claims:** the six named root convention files (`CLAUDE.md`, `cowork-profile.md`, `global-instructions.md`, `folder-structure.md`, `skills-as-prompts.md`, `project-instructions.txt`) are "Named explicitly as belt-and-suspenders (**a file added tomorrow is still caught by namespace, not by an update to this list**)."

**What I mechanically demonstrated:** this claim is true for every OTHER class in the floor (`.claude/**`, `context/**`, any `*.json`, root dotfiles — confirmed with `.claude/skills/newskill/SKILL.md`, `new-secrets.json`, `.env.production`, all correctly DENIED by namespace alone). It is **not** true for the six named root `.md` convention files' own class: they are not dotfiles, not `*.json`, not under `.claude/` or `context/`. Re-implementing the positive predicate's conditions (a)–(f) exactly as written and running it against a *hypothetical future* root convention file not yet on the named list (e.g. `workspace-manifest.md`, `onboarding-charter.md`) returns **ELIGIBLE** — i.e., movable — every time. The only reason today's six files are safe is that they are individually enumerated; a *seventh* root `.md` convention file introduced in a future cycle (v2.18+ living-organization is the obvious candidate) would silently be movable unless someone remembers to add it here.

**Why this matters:** `ADR-063` explicitly rejected deny-first-with-per-file-lists because "per-file enumeration is an unbounded forever-obligation" — but this specific class (root `.md` convention files) reintroduces exactly that forever-obligation without saying so. `docs/assumptions.md` A-v2.17-5 makes the same "stays correct without per-file lockstep maintenance" claim and should be scoped to the classes it actually covers.

**Severity:** ISSUE, not BLOCKER. No AC in `spec.md` is currently violated — every path named by FW-1 and the Phase-3 S3 amendment IS in the deny list today. This is a latent risk to future maintenance, not a hole in the shipped v2.17.0 surface.

**Minimal fix (recommended, not blocking merge):** reword the "belt-and-suspenders" sentence to scope the "caught by namespace" claim to the four genuinely namespace-coverable classes, and add one line naming the residual explicitly (mirroring how W-2's prose-reference residual is already named) — e.g. "a new root-level `.md` convention file introduced in a future cycle is NOT automatically caught by namespace and MUST be added to this list by hand." This turns an unstated assumption into a named, accepted one, consistent with this design's own residual-naming discipline (W-1/W-2/W-3).

---

## Pre-Existing Carry Item (not new, already flagged by @dev)

- `docs/roadmap.md:31` "Rung notes" still references the deferred "already-gated promote-to-Skill path" — stale wording, not fixed this cycle (only the AC-RELEASE-3 row was in scope). Confirmed present, confirmed non-functional (doc text only). INFO, not blocking.

---

## Release Completeness (AC-RELEASE-1/2/3)

- `VERSION` = `2.17.0`. ✓
- `CHANGELOG.md` `[2.17.0]` section present with Added/Deferred split. ✓
- README badge = `2.17.0`; "What's new in v2.17" section present; "Also next up" correctly reframed for partial delivery (auto-cleaning shipped, living-organization + promote-to-Skill deferred). ✓
- `docs/roadmap.md` v2.17 row records `SHIPPED (PARTIAL)`. ✓

## Reachability + Self-Integrity (C-v2.17-9/10)

- `WIZARD.md` installs `self-archive` unconditionally at Step 4, **both Mode A and Mode B**, plus an explicit backfill clause for pre-v2.17.0 workspaces reaching the add/remove flow later. Confirmed via direct grep (4 hits, Step 4 install + handover narrative + backfill). ✓
- Self-deny confirmed: `self-archive/SKILL.md` names its own file as never move-eligible, and — unlike the root-convention-file class above — this one genuinely IS redundant with the `.claude/**` namespace floor (confirmed: `.claude/skills/self-archive/SKILL.md` is caught by namespace alone even if the explicit self-deny sentence were removed). No residual here. ✓

---

## Rework Rate

0% — no NEEDS-REWORK verdict. All 5 firing-control buckets fired correctly on independent re-test; the one new finding is a documentation-accuracy note carried forward, not a functional defect requiring rework before this cycle can proceed to Phase 6.

## qa_issues_prevented

- blocker: 0
- issue: 1 (belt-and-suspenders namespace-coverage overstatement — §New Finding)
- info: 1 (roadmap.md:31 stale "Rung notes" reference — pre-existing, already named by @dev)

## Verdict

**PASS-WITH-NOTES.** Recommend proceeding to Phase 6 (`@security` code audit). The one new finding (§New Finding) is not a blocker — no shipped AC is violated — but should be handed to `@security` for Phase 6 awareness (it sits squarely in the FW-1/AC-DENY-1 surface `@security`'s Phase 2 review already scrutinized) and ideally closed with the minimal prose fix before Phase 7 sign-off, or explicitly accepted as a named residual alongside W-1/W-2/W-3.
