# self-archive Firing Controls (v2.17.0, required pre-release)

Validates the four firing-control buckets the v2.17.0 design turns on (spec.md
C-v2.17-1/2/3/4/5 + S1's reframed C-v2.17-8): **AC-DENY-1, AC-DENY-2,
AC-VERIFYMOVE-2/3, AC-ROLLBACKMOVE-2**. Each control was run for real
(not narrated) during Phase 4 implementation, in an isolated scratch
directory so the real repo tree and branch history were never mutated —
this file records the exact commands and the exact output, both the GREEN
path and the RED negative control, per the repo's own binding
*check-that-cannot-fail* discipline (a check that cannot fail is not a check).

Run this before every release that touches `.gitignore`, `.gitattributes`,
or `skills/self-archive/SKILL.md`.

## 1. Archive non-publication (S1 reframe of C-v2.17-8 + S2 apply-backups gap)

**Mechanism:** workspace `.gitignore` excludes `context/.archive/` and
`context/.apply-backups/`; `.gitattributes export-ignore` covers both
(belt-and-suspenders, since `context/` itself is not export-ignored — v2.15 S3).

```bash
# GREEN — with both guard clauses present
mkdir -p context/.archive
echo "SENSITIVE-LEAK-FIXTURE" > context/.archive/leak-fixture.md
git check-ignore -v context/.archive/leak-fixture.md
# -> .gitignore:<N>:context/.archive/    context/.archive/leak-fixture.md

git add -f context/.archive/leak-fixture.md   # force-add — without -f the control is vacuous,
git commit -m "TEST: force-add leak fixture"  # untracked files are trivially absent from git archive

git archive HEAD | tar t | grep leak-fixture
# -> (no output, exit 1) — PASS: fixture absent from the release archive
```

- [x] **RAN 2026-07-21.** `git check-ignore` matched; `git archive HEAD | tar t` did not list the
      force-added fixture. PASS.

**Negative control (a) — remove the `.gitignore` line:**

```bash
sed -i '/context\/\.archive\//d' .gitignore
git check-ignore -v context/.archive/leak-fixture.md
# -> (no output, exit 1) -- RED, as required: check-ignore no longer matches
```

- [x] **RAN 2026-07-21.** Confirmed RED — with the entry removed, `git check-ignore` stops
      matching. Entry restored immediately after.

**Negative control (b) — remove the `.gitattributes export-ignore` line:**

```bash
sed -i '/context\/\.archive\//d' .gitattributes
git add .gitattributes && git commit -m "TEST: strip export-ignore (negative control b)"
git archive HEAD | tar t | grep leak-fixture
# -> context/.archive/leak-fixture.md -- RED, as required: fixture reappears in the archive
```

- [x] **RAN 2026-07-21.** Confirmed RED — with the `export-ignore` entry removed, the
      force-added fixture reappears in `git archive HEAD | tar t`. Entry restored immediately
      after.

## 2. AC-VERIFYMOVE-2 — corrupted-dest fingerprint mismatch routes to rollback

**Mechanism:** before a move, record `(source_path, dest_path, length+checksum)`
out-of-band. After the copy, recompute the dest's `length+checksum` and compare.

```bash
echo "This is real user content that must survive the move intact." > source_area/old-draft.md
SRC_LEN=$(wc -c < source_area/old-draft.md); SRC_SUM=$(sha256sum source_area/old-draft.md | awk '{print $1}')
# SRC_LEN=61  SRC_SUM=8f2ef6c0...

cp source_area/old-draft.md context/.archive/old-draft.md.2026-07-21T160305Z
truncate -s -10 context/.archive/old-draft.md.2026-07-21T160305Z   # simulate a corrupted copy
DEST_LEN=$(wc -c < context/.archive/old-draft.md.2026-07-21T160305Z)
DEST_SUM=$(sha256sum context/.archive/old-draft.md.2026-07-21T160305Z | awk '{print $1}')
# DEST_LEN=51  DEST_SUM=9d5c873c...  (mismatch)
[ "$DEST_LEN" = "$SRC_LEN" ] && [ "$DEST_SUM" = "$SRC_SUM" ] && echo PASS || echo "FAIL -> rollback"
```

- [x] **RAN 2026-07-21.** Fingerprints genuinely diverged (length 61 vs 51, checksum mismatch)
      and the check correctly reported FAIL → rollback. **Before-run requirement met**: the
      corruption was actually exhibited (truncated file), not asserted.

## 3. AC-ROLLBACKMOVE-2 — terminal state after a verifier FAIL

**Mechanism:** on FAIL, if both source and dest exist, verify the source against the
recorded fingerprint and remove dest (never trust the dest).

```bash
# both source_area/old-draft.md and the corrupted dest exist at this point (verify runs
# BEFORE any unlink of source, per the skill's ordering)
LIVE_SRC_SUM=$(sha256sum source_area/old-draft.md | awk '{print $1}')
[ "$LIVE_SRC_SUM" = "$SRC_SUM" ] && rm -f context/.archive/old-draft.md.2026-07-21T160305Z

# Assert terminal state: exactly one copy at source, zero at dest, byte-identical to fingerprint
```

- [x] **RAN 2026-07-21.** Terminal state confirmed: `source copies=1 dest copies=0 source
      checksum matches fingerprint=yes` → PASS.

**Negative control** — a rollback that leaves two copies:

```bash
cp source_area/old-draft.md context/.archive/old-draft.md.2026-07-21T160305Z  # buggy rollback
[ -f source_area/old-draft.md ] && [ ! -f context/.archive/old-draft.md.2026-07-21T160305Z ] \
  && echo PASS || echo "FAIL -- RED (two copies present)"
```

- [x] **RAN 2026-07-21.** Confirmed RED — two copies present, terminal-state check correctly
      failed.

## 4. AC-VERIFYMOVE-3 — reference-integrity check (read-only, scoped, enumerated)

**Mechanism:** grep the enumerated convention set (`folder-structure.md`,
`skills-as-prompts.md`, `global-instructions.md`, root `CLAUDE.md`, `cowork-profile.md`,
every `.claude/skills/*/SKILL.md`, every `context/*.md`) for a literal reference to the
move's source path/basename.

**Live reference fires the check (real repo, no fixture needed — self-apply's own
grounding instance):**

```bash
grep -rn --include="*.md" -F "self-apply/SKILL.md" \
  templates/preset-template/context/memory-of-use.md \
  skills/weekly-review/SKILL.md \
  templates/workspace-claude-md-template.md
```

- [x] **RAN 2026-07-21.** Three live literal references found:
  `templates/preset-template/context/memory-of-use.md:7`,
  `skills/weekly-review/SKILL.md:29`, `templates/workspace-claude-md-template.md:31`.
  A move of `self-apply/SKILL.md` (moot in practice — it's separately self-deny-listed) would
  correctly trigger this check.

**Read-only assertion (byte-identity before/after):**

```bash
SUM_BEFORE=$(sha256sum templates/preset-template/context/memory-of-use.md | awk '{print $1}')
grep -F "self-apply/SKILL.md" templates/preset-template/context/memory-of-use.md > /dev/null
SUM_AFTER=$(sha256sum templates/preset-template/context/memory-of-use.md | awk '{print $1}')
[ "$SUM_BEFORE" = "$SUM_AFTER" ] && echo PASS
```

- [x] **RAN 2026-07-21.** PASS — pointer file byte-identical before and after the check;
      nothing was rewritten.

**Negative control — drop a convention file from the enumerated set:**

```bash
# Checker re-run WITHOUT templates/preset-template/context/*.md in its enumerated set
grep -rn --include="*.md" -F "self-apply/SKILL.md" \
  skills/weekly-review/SKILL.md templates/workspace-claude-md-template.md
# the memory-of-use.md:7 pointer is now completely invisible to this narrowed checker
```

- [x] **RAN 2026-07-21.** Confirmed RED — with `context/*.md` dropped from the enumerated set,
      the live `memory-of-use.md:7` pointer to `self-apply` goes entirely undetected.

## Scope note

Controls 2 and 3 were run in an isolated scratch directory (not this repo's working tree) —
a move/corruption/rollback fixture has no meaningful place to live inside this kit's own
tracked tree, and running it there would risk polluting the branch. Controls 1 and 4 were run
either in an isolated scratch git repo (1) or read-only against this repo's real, already-committed
content (4) — safe, no mutation. @qa should re-run all four at Phase 5 as part of formal test
coverage, ideally re-implemented as `.claude/skills/self-archive/SKILL.md`-driven fixtures once
a live agent session can exercise the actual skill prose end-to-end (this kit has no application
code layer to unit-test against — the "executable check" for a prose kit is the literal shell
mechanics the skill's prose describes, demonstrated here).
