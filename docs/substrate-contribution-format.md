# Substrate Contribution Format

This document names the format both directions of this kit's skill economy target: a
contributor pushing a workspace-built skill up into the shared pool (`PROMOTE.md`'s
ceremony today, a future maintainer-review intake later), and a workspace pulling a
curated update down from the pool (a future flow, not built yet). Both stand on the
same substrate — one format, no fork.

This doc is also the contract an **external format consumer** reads. It stays public
(not under `docs/internal/`) on purpose: it is the exact spec a foreign runtime's
integrator needs, without reading any of this kit's own wizard code.

---

## The format: the existing 9-section `SKILL.md` standard

The substrate contribution format IS the 9-section `SKILL.md` template this kit already
ships and already enforces in CI (`skill-depth-check`, a 60-line floor plus these nine
`##`-level sections, verbatim):

1. `## When to use`
2. `## Triggers`
3. `## Instructions`
4. `## Output format`
5. `## Quality criteria`
6. `## Anti-patterns`
7. `## Example`
8. `## Writing-profile integration`
9. `## Example prompts`

See `templates/skill-template/SKILL.md` for the authoritative, filled-in-blank version
of this structure, and its own header comment for placeholder-authoring rules.

**Both consumers target this one format, with no fork:**

- **Push** — `PROMOTE.md`'s promotion ceremony copies a workspace's graded
  `.claude/skills/<slug>/SKILL.md` verbatim into the shared pool
  (`skills/<slug>/SKILL.md`) plus a `curated-skills-registry.md` row. A future
  maintainer-review intake flow (not built this cycle) is expected to reuse the same
  9-section eligibility bar.
- **Pull** — a future workspace-update flow (not built this cycle) reads
  `skills/<slug>/SKILL.md` from the pool and the `cowork.install.json` +
  `curated-skills-registry.md` schema described below to decide what is safe to offer.

No format fork exists, or is planned, between these two directions.

---

## Adapter isolation — Cowork-private keys stay out of the body

A `SKILL.md` body is portable content. Cowork-specific routing concerns are never
allowed to leak into it. Specifically, none of these keys may appear anywhere in a
`SKILL.md` body (any of the nine sections):

- `core_skills:`
- `optional_skills:`
- `wizard_hook`
- `preset_route`

These keys live exclusively in this kit's own adapter surfaces — `selection-presets.md`
(preset membership) and `global-instructions.md` (proactive trigger routing) — never
inside the skill body itself. A skill's own frontmatter fields (`name:`, `description:`,
`trigger_examples:`) are exempt from this rule; they are already open-standard-shaped,
not Cowork-private.

This boundary is verified mechanically: `grep -riE 'core_skills:|optional_skills:|wizard_hook|preset_route' skills/*/SKILL.md` must return zero matches.

---

## External consumer contract

A foreign puller — the first named candidate is Confidante, a locally-run assistant
shell independently owned and governed outside this kit — can read exactly two things to
decide what is safe to pull, without reading any wizard-runtime code or interview state:

1. **The `curated-skills-registry.md` schema** (7 columns: `name`, `description`,
   `source_url`, `vetting_date`, `tier`, `goal_tags`, `sha256`). The `sha256` column is
   the 64-char lowercase hex content hash of the skill's `SKILL.md` bytes at its pool
   location, CI-computed and drift-verified — never hand-entered.
2. **The `cowork.install.json` per-workspace manifest** — a standalone, workspace-root
   file (schema below) recording which curated skill version a *given workspace*
   installed and at what content hash.

Both are read locally. Neither is EVER a runtime fetch target — this kit's own Network
& Offline Rule (`WIZARD.md`) already states that all skill installation is a local file
copy, never a download, and the manifest and registry are integrity anchors on top of
that same local-only model, not an addition to it.

### `cowork.install.json` — schema

```json
{
  "$schema_version": "1.0",
  "kit_version": "2.18.0",
  "installed_at": "2026-07-22T00:00:00Z",
  "components": [
    {
      "slug": "flashcard-generation",
      "installed_path": ".claude/skills/flashcard-generation/SKILL.md",
      "source": "curated-pool",
      "installed_registry_version": "2026-04-18",
      "installed_content_sha256": "<64-char-lowercase-hex, bytes AS installed>",
      "last_synced_upstream_sha256": "<64-char-hex — pool hash at last sync>"
    }
  ]
}
```

A template with the same shape ships at `templates/cowork.install.template.json`.

Field meanings:

- `installed_registry_version` — the registry row's `vetting_date` at install time. This
  is the **version answer**: is a newer curated version available?
- `installed_content_sha256` — the hash of the `SKILL.md` bytes as installed. This is the
  **content-hash answer**: has the user edited their copy since install? At install time,
  `installed_content_sha256` equals the registry's `sha256` for that version — the link
  between the manifest and the registry that lets a puller verify integrity from the
  registry alone.
- `last_synced_upstream_sha256` — the pool's hash at the last sync, so a future pull step
  can tell whether the pool itself has moved since.
- `source` — `curated-pool` or `user-authored`, carrying the third branch of the
  trichotomy below.

These two comparisons are always kept distinct — never conflated into one:

| Comparison | Question it answers |
|---|---|
| `installed_registry_version` vs current registry row | Is there a newer curated version? |
| on-disk content hash vs `installed_content_sha256` | Has the user edited their copy since install? |

The second comparison drives a deterministic three-outcome classification:

| In registry? | On-disk hash == installed hash? | Outcome |
|---|---|---|
| No | (either) | user-authored / not-in-pool — never touched |
| Yes | Yes (unedited) | untouched — a newer version can be offered plainly |
| Yes | No (edited) | user-customized — any update surfaces a conflict, never a silent overwrite |

`cowork.install.json` is a workspace-root file present in every install path this kit
supports, and is on the mandatory `self-apply` skill's hard deny-list — it is never a
target a confirmed-apply write can rewrite.

**Nothing in this contract requires reading any wizard interview state.** A slug, an
installed content hash, and a registry row are enough to compute both answers above.

---

## Canonicalization + scan pipeline

Before any pool content is trusted — at promotion time, at the pool's own CI gate, or
when a workspace re-checks an edited file against its install record — it passes through
one single-sourced pipeline, in this fixed order (`scripts/canonicalize-scan.sh`):

1. **Unicode NFKC normalization.** Folds compatibility-decomposable character variants
   (for example, a fullwidth-encoded letter) back to their plain ASCII form.
2. **Zero-width character stripping.** Removes exactly four named codepoints: U+200B,
   U+200C, U+200D, and U+FEFF.
3. **Mixed-script flagging.** Content mixing letters from two or more distinct writing
   systems in the same word is flagged for human review. This step never auto-corrects
   and never silently passes flagged content — it surfaces the flag and stops there.
4. **The pattern scan.** The existing, deliberately unforked six-token pattern
   (`CONTRIBUTING.md`, byte-identical) runs on the canonicalized result of steps 1–3.
   Step 4 never runs against raw, un-canonicalized bytes — there is no supported code
   path that skips steps 1–3.

Every call site — the pool's own CI gate, the promotion ceremony, and a workspace's
own re-check of an edited installed skill — invokes this same script. None of them
re-implements the pipeline independently.

### Honest limit — what this pipeline does NOT catch

Stated plainly, because a false sense of security is worse than a known gap:

- **NFKC does not fold cross-script homoglyphs.** A Cyrillic letter that looks
  identical to a Latin letter does not become that Latin letter under NFKC
  normalization. A token built from such a substitution still evades the pattern scan
  even after canonicalization — it is caught **only** by the mixed-script flag above,
  and that flag routes to human review. It is never an automatic catch, and never an
  automatic correction.
- **The zero-width strip is a bounded, named list — not "every invisible character."**
  It covers exactly U+200B, U+200C, U+200D, and U+FEFF. It does **not** cover every
  Unicode invisible or formatting codepoint. At minimum, the following remain
  uncovered and must not be assumed neutralized: **U+2060** (word joiner), **U+00AD**
  (soft hyphen), **U+180E**, and the **U+E0000–U+E007F** tag-character block. A
  motivated adversary using one of these uncovered classes can still evade both the
  strip and the scan.
- **This is a shape tripwire, not a semantic judge.** The pattern scan matches a fixed
  set of six literal tokens. It does not understand intent, and it is not a substitute
  for a maintainer actually reading a submission before it merges. On a curated-only
  pool, that maintainer review is the strictly stronger layer; every automated step
  above is defense-in-depth beneath it, not a replacement for it.

---

## Runtime-agnostic — no target-model-class assumption

Nothing in this document, in `templates/skill-template/SKILL.md`, or in
`CONTRIBUTING.md`'s format rules assumes, names, or depends on which model or runtime
class executes a skill's content. A skill body is portable prose — instructions, an
example, quality criteria — readable and usable by any capable assistant, not tuned to
or gated on a specific parameter count, vendor, or runtime name.

This is verified mechanically and applies going forward, absent a dedicated future
decision: no shipped format file in this set may name a specific runtime scale or
vendor assumption.

---

## Format transfer vs. capability transfer — two distinct, separately-gated layers

This document solves **format transfer**: a skill authored in this 9-section shape,
free of Cowork-private routing keys, is readable by any external system that wants to
parse it. That is what ships in this cycle.

**Capability transfer — whether a given skill actually produces good output on a
specific external runtime — is a separate, harder question this cycle does not
answer.** A skill graded against one assistant's behavior is not proven to work
identically elsewhere; different runtimes vary in reasoning depth, instruction
adherence, and context handling. Confirming a skill's behavior on a specific external
runtime requires a dedicated evaluation pass against that runtime, re-run at the point
a real external integration is attempted — not assumed from the format alone.

**A claim that this substrate is "ready" for any specific external runtime must route
through that evaluation first.** Publishing the format as an open, external-readable
contract is the point of the external consumer contract above; it is not itself a claim
that any external runtime has been evaluated against it.

---

## See also

- `templates/skill-template/SKILL.md` — the filled-in-blank 9-section template.
- `CONTRIBUTING.md` — contributor how-to, including the worked-example authoring rules
  the pattern scan enforces and the CI checklist a PR is reviewed against.
- `PROMOTE.md` — the push ceremony that copies a workspace skill into the shared pool.
- `curated-skills-registry.md` — the pool catalog, including the `sha256` column this
  document's external consumer contract depends on.
- `templates/cowork.install.template.json` — the per-workspace manifest template.
