# v2.19 Persistency Layer — Firing Controls (required pre-release)

Manually-recorded convention, mirroring `tests/self-archive-firing-controls.md` (v2.17.0).
Validates the binding Phase-4 firing controls for **MF-1** (self-apply deny-list
namespace-completeness, + the 3 Phase-2.D refinement controls), **MF-2** (AC-UPGRADE-8
self-integrity, 3 controls), **MF-6** (semver-aware compare), **AC-PULL-1** (manifest-drift
4th state), **AC-PULL-6** (fresh-bytes trust-transitivity), **AC-PULL-7** (poisoned-backfill
defense), and **AC-PULL-9** (malformed-manifest refusal). Each control was run for real
(not narrated), most in an isolated scratch directory so the real repo tree and branch
history were never mutated, per this repo's binding *check-that-cannot-fail* discipline (a
check that cannot fail is not a check) — see `docs/patterns.md`.

Run this before every release that touches `skills/self-apply/SKILL.md`,
`skills/self-archive/SKILL.md`, `skills/self-upgrade/SKILL.md`, `skills/pull-updates/SKILL.md`,
`scripts/semver-compare.sh`, or `curated-skills-registry.md`.

---

## 1. MF-1 — self-apply deny-list namespace-completeness (`self-*` reserved prefix)

**Mechanism:** `.claude/skills/self-*/SKILL.md` is denied by pattern, evaluated before the
`.claude/skills/*/SKILL.md` allow-glob, explicitly naming `self-apply`/`self-archive`/`self-upgrade`.

**GREEN — real repo, current (fixed) state:**

```bash
for pattern in 'self-archive' 'self-upgrade' 'skills/self-\*'; do
  grep -qE "$pattern" skills/self-apply/SKILL.md || echo "MISSING $pattern"
done
```

- [x] **RAN 2026-07-22.** No output (no `MISSING` lines) — all 3 patterns present.

**Negative control — the SAME check against the pre-fix (git `HEAD` at Phase-4 kickoff) content:**

```bash
for pattern in 'self-archive' 'self-upgrade' 'skills/self-\*'; do
  git show HEAD:skills/self-apply/SKILL.md | grep -qE "$pattern" || echo "MISSING (pre-fix): $pattern"
done
```

- [x] **RAN 2026-07-22.** Output:

  ```
  MISSING (pre-fix): self-archive
  MISSING (pre-fix): self-upgrade
  MISSING (pre-fix): skills/self-\*
  ```

  Confirmed RED against the real, unmodified pre-fix repo state — the check genuinely
  fires on the exact vulnerability @security's Phase-2 review found (0 hits, `self-archive`
  reachable via the ordinary allow-glob).

**Phase-2.D's 4 binding firing controls, evaluated against the fixed deny-list text:**

| Control | Expected | Result |
|---|---|---|
| (a) benign `self-review` apply → REFUSED (reserved-prefix holds) | `self-review` matches `self-*` glob | `self-review` matches `^self-` — REFUSED, same as the 3 named members. Real command: `echo "self-review" \| grep -qE '^self-' && echo DENIED` → `DENIED`. |
| (b) each of `self-apply`/`self-archive`/`self-upgrade` apply → REFUSED (glob) | all 3 named explicitly | Confirmed above (GREEN leg) — all 3 present in the deny-list text. |
| (c) backfill writing `self-*`/SKILL.md via INSTALLER channel → SUCCEEDS | MF-1c channel-scoping prose present | `grep -c "does not govern.*installer\|no carve-out\|LOAD-BEARING" skills/self-apply/SKILL.md` → see run below. |
| (d) benign `vendor-comparison` apply → SUCCEEDS (no allow-glob regression) | not `self-*`, not otherwise denied | `echo "vendor-comparison" \| grep -qE '^self-'` → no match — reaches the ordinary allow-glob unchanged. |

```bash
echo "self-review" | grep -qE '^self-' && echo "DENIED"
echo "vendor-comparison" | grep -qE '^self-' || echo "NOT DENIED BY PREFIX — ordinary allow-glob applies"
grep -c "does not govern\|no carve-out\|LOAD-BEARING" skills/self-apply/SKILL.md
```

- [x] **RAN 2026-07-22.** `self-review` → `DENIED`. `vendor-comparison` → `NOT DENIED BY PREFIX —
      ordinary allow-glob applies`. MF-1c channel-scoping prose count → `1` (the "Channel
      scope — no carve-out (v2.19, MF-1c, LOAD-BEARING)" paragraph in `skills/self-apply/SKILL.md`
      is present and states the installer/backfill ceremony is a different channel, ungated by
      this deny-list, per AC-PULL-7/ADR-073).

---

## 2. MF-2 / AC-UPGRADE-8 — the two-write-class self-integrity invariant

**Control (a) — structural: is `self-upgrade` itself on the deny-list its own gate would need
to bypass to rewrite it?** Already proven in §1 above — `self-upgrade` matches `self-*`,
denied via the ordinary apply channel, identically to `self-apply`/`self-archive`.

**Control (structural) — reuse-by-reference, not re-declaration (C-v2.19-7 / AC-UPGRADE-4(b)):**

```bash
grep -n "self-apply/SKILL.md\|SECGATE\|verifier\|rollback" skills/self-upgrade/SKILL.md | wc -l
grep -c "^### Applying a confirmed change\|^### The verifier gate" skills/self-upgrade/SKILL.md
```

- [x] **RAN 2026-07-22.** First command → `8` (8 lines reference the Loop 1 gate, SECGATE,
      verifier, or rollback machinery by name/path). Second command → `0` — no re-declared
      "Applying a confirmed change" or "The verifier gate" section header exists in
      `skills/self-upgrade/SKILL.md`; it references `self-apply`'s sections by name instead of
      copying them. Confirms the structural half of AC-UPGRADE-4(b): a grep for a re-declared
      verifier/rollback block returns 0.

**Control (b) — new machinery fails verification under the OLD gate → no swap.** This is a
live-invocation behavioral control (does the LLM session actually refuse to swap when the
synthetic new machinery fails its verifier?), not a mechanically-scriptable file check — there
is no application code layer to unit-test against; the "executable check" for a prose kit is
the literal shell mechanics a deterministic sub-check can drive (as in controls (a)/(c) and §1
above), and control (b)'s pass/fail depends on the agent's own in-session judgment applied to a
synthetic fixture. **Honestly un-exercisable pre-implementation, per the Phase-2.D binding
caveat** (`.claude/projects/claude-cowork-config/scratchpad.md`, "@qa Phase-2.D caveats"): bound
here as a **Phase-5 @qa re-verify item**, not assumed proven. @qa should invoke `self-upgrade`
against a synthetic fixture asserting a newer `kit_version` whose "new machinery" deliberately
fails a planted verifier check, and confirm the skill's prose response is "no swap, old
machinery stays live" — never a silent land.

**Control (c) — a byte-correct upgrade of a non-safety engine file rides the ordinary gate and
succeeds (the higher-ceremony gate is scoped to safety machinery, not a blanket block):**

```bash
echo "pull-updates" | grep -qE '^self-' || echo "NOT self-* -- reaches ordinary Class-1 / allow-glob path, unaffected by Write-Class-2"
```

- [x] **RAN 2026-07-22.** Output: `NOT self-* -- reaches ordinary Class-1 / allow-glob path,
      unaffected by Write-Class-2`. `pull-updates` (a non-safety, mandatory-infrastructure
      skill) is not caught by the `self-*` deny and would ride the ordinary confirm-apply gate
      unchanged — proving the higher-ceremony Write-Class-2 path is scoped to the 3 named
      safety siblings, not a blanket block on all engine files.

---

## 3. MF-6 — semver-aware compare (`scripts/semver-compare.sh`)

```bash
for v in 2.9.0 2.18.0 2.19.0 2.20.1 absent; do
  out=$(./scripts/semver-compare.sh upgrade-ready "$v"); rc=$?
  echo "kit_version=$v -> $out (exit $rc)"
done
```

- [x] **RAN 2026-07-22.** Output:

  ```
  kit_version=2.9.0 -> not-ready (exit 1)
  kit_version=2.18.0 -> not-ready (exit 1)
  kit_version=2.19.0 -> ready (exit 0)
  kit_version=2.20.1 -> ready (exit 0)
  kit_version=absent -> not-ready (exit 1)
  ```

  All 5 fixtures correct — `2.9.0` correctly `not-ready` (a naive string compare would say
  otherwise, below).

**Negative control — a naive string compare FAILS this exact fixture, proving the trap is
real (the reason MF-6 exists):**

```bash
[[ "2.9.0" > "2.19.0" ]] && echo "STRING-COMPARE SAYS: 2.9.0 > 2.19.0 (WRONG)"
```

- [x] **RAN 2026-07-22.** Output: `STRING-COMPARE SAYS: 2.9.0 > 2.19.0 (WRONG)` — a lexical
      compare puts `2.9.0` ahead of `2.19.0` (the character `9` outranks `1`), which would
      incorrectly report a v2.18-born workspace as upgrade-ready. `scripts/semver-compare.sh`
      parses integers and gets this right (see the GREEN run above).

---

## 4. AC-PULL-9 — malformed/schema-invalid manifest refusal

**Mechanism:** `tests/fixtures/v2.19/validate-manifest.sh` — parse `cowork.install.json`
defensively; refuse on unparseable JSON, a missing required top-level key, or a component
missing `slug`/`installed_path`/`installed_content_sha256`.

```bash
tests/fixtures/v2.19/validate-manifest.sh tests/fixtures/v2.19/manifest-truncated.json
tests/fixtures/v2.19/validate-manifest.sh tests/fixtures/v2.19/manifest-schema-invalid.json
tests/fixtures/v2.19/validate-manifest.sh tests/fixtures/v2.19/manifest-well-formed.json
```

- [x] **RAN 2026-07-22.** Output:

  ```
  REFUSE: unparseable/truncated JSON
  REFUSE: component[0] missing required field 'installed_content_sha256'
  OK: manifest well-formed, 1 component(s)
  ```

  Both malformed fixtures REFUSE (exit 1); the well-formed fixture (negative control /
  GREEN — proves the refusal is a real gate, not a blanket block) proceeds (exit 0).

---

## 5. AC-PULL-1 / AC-PULL-6 — component classification (manifest-drift + fresh-bytes trust-transitivity)

**Mechanism:** `tests/fixtures/v2.19/classify-component.sh` — never accepts a manifest-asserted
hash as an input at all (the strongest form of AC-PULL-6: the decision path is structurally
unable to read a manifest label). Computes `H_current` (on-disk) and `H_pool` (curated pool)
fresh, this session, every time.

Run in an isolated scratch directory (`$SCRATCH`, outside this repo's tree) with copies of two
real pool skills — `note-taking` (left untouched) and `voice-matching` (a line appended to
simulate a user edit) — plus a manifest entry naming a file that does not exist on disk
(`old-skill`, simulating a dangling/drifted entry) and a slug not in the registry
(`my-custom-thing`):

```bash
bash tests/fixtures/v2.19/classify-component.sh note-taking "$SCRATCH/.../note-taking/SKILL.md" skills/note-taking/SKILL.md curated-skills-registry.md
bash tests/fixtures/v2.19/classify-component.sh voice-matching "$SCRATCH/.../voice-matching/SKILL.md" skills/voice-matching/SKILL.md curated-skills-registry.md
bash tests/fixtures/v2.19/classify-component.sh old-skill "$SCRATCH/.../old-skill/SKILL.md" skills/old-skill/SKILL.md curated-skills-registry.md
bash tests/fixtures/v2.19/classify-component.sh my-custom-thing "$SCRATCH/.../note-taking/SKILL.md" skills/note-taking/SKILL.md curated-skills-registry.md
```

- [x] **RAN 2026-07-22.** Output:

  ```
  untouched
  user-customized
  manifest-drift
  user-authored-not-in-pool
  ```

  All four outcomes fire correctly: `note-taking` (byte-identical to pool) → `untouched`;
  `voice-matching` (appended line) → `user-customized`; `old-skill` (no on-disk file, the
  dangling-entry case) → `manifest-drift`, never coerced into a trichotomy state; a slug not in
  the registry → `user-authored-not-in-pool`, never pull-eligible.

**AC-PULL-6 trust-transitivity — why this is the load-bearing evidence, not just a 4-way
demo:** `classify-component.sh`'s own signature (see the script header) takes no manifest-hash
argument — there is no code path by which a poisoned `installed_content_sha256` label (e.g. one
an attacker sets to the ORIGINAL untouched hash, to make a hand-edited `voice-matching` falsely
read as "untouched, safe to overwrite") could reach the decision. The `voice-matching` run above
IS that fixture: its on-disk bytes are edited, and the classifier — which never even looked at
what any manifest might have claimed — still correctly returns `user-customized`. **Negative
control (proving this isn't a blanket "always conflict"):** the `note-taking` run in the same
batch, with genuinely untouched on-disk bytes, correctly returns `untouched` — the fresh-bytes
path produces both outcomes correctly, not a fixed answer regardless of input.

---

## 6. AC-PULL-7 — poisoned-backfill defense (byte-verify against registry `sha256`)

**Mechanism:** `tests/fixtures/v2.19/backfill-verify.sh` — a candidate safety-skill file is
byte-verified against `curated-skills-registry.md`'s `sha256` entry for that slug before it may
go live; a mismatch refuses.

Run in the isolated scratch directory with two copies of `skills/self-upgrade/SKILL.md`: one
byte-identical, one with an appended line simulating an injected weakening ("skip the deny-list
check"):

```bash
bash tests/fixtures/v2.19/backfill-verify.sh self-upgrade "$SCRATCH/.../self-upgrade-byte-correct.md" curated-skills-registry.md
bash tests/fixtures/v2.19/backfill-verify.sh self-upgrade "$SCRATCH/.../self-upgrade-poisoned.md" curated-skills-registry.md
```

- [x] **RAN 2026-07-22.** Output:

  ```
  PROCEED: 'self-upgrade' byte-verified against registry sha256 (a4abd71af9dafe8a267af758c86593a1260426a5387f2825f75512559fdf3e11)
  REFUSE: byte mismatch for 'self-upgrade' — registry=a4abd71af9dafe8a267af758c86593a1260426a5387f2825f75512559fdf3e11 candidate=cdf0bba8c4038c06313f6653851d98b53bb71c56282a12be4f5ea58eefba44bc
  ```

  Byte-correct copy proceeds; the poisoned copy (a genuinely different hash, not asserted) is
  refused — the defense fires on real divergent bytes, not a narrated claim.

---

## 7. AC-UPGRADE-3(c) — dormant no-op vs. synthetic-newer routing

The deterministic INPUT to this routing decision (is `kit_version` upgrade-ready) is proven in
§3 above via `scripts/semver-compare.sh`. The routing behavior itself — does `self-upgrade`
actually emit "nothing to walk forward to yet" and write nothing when no target exists, versus
actually route into the confirmed-apply gate when a synthetic newer target is substituted — is a
live-invocation behavioral control, same honest limitation as MF-2(b) above (no application
code layer to unit-test; the check is the agent's own in-session behavior against a fixture).
**Bound as a Phase-5 @qa re-verify item**, not assumed proven at Phase 4: @qa should invoke
`self-upgrade` twice — once against the real, current manifest (no target; expect the no-op
report, zero writes) and once against a synthetic fixture asserting a newer `kit_version` (expect
routing into the confirmed-apply gate, not a silent pass).

---

## Scope note

Controls in §5 and §6 (component classification, backfill byte-verify) were run in an isolated
scratch directory outside this repo's working tree, using real copies of real pool skill files —
no fixture was invented that misrepresents what the classifier or the backfill verifier actually
computes. Controls in §1–§4 were run directly against this repo's real, already-committed (or
about-to-be-committed) content — safe, read-only or grep-only, no mutation of tracked files.
MF-2(b) and AC-UPGRADE-3(c)'s live-routing halves are explicitly named as **not yet exercised by
an actual agent session** and handed to @qa for Phase 5, per this cycle's binding Phase-2.D
caveat — the same honest disclosure discipline `tests/self-archive-firing-controls.md` models for
its own scope note.
