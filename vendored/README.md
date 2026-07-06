# Vendored Upstream Content

This directory is the **local, offline copy** of all upstream content pinned in
`cowork.lock.json`. Nothing here is fetched at runtime — Cowork sessions need no
internet or GitHub access to use it (see WIZARD.md §Network & Offline Rule).

## agency-agents/

The complete reviewed library from
[msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) (MIT),
110 agent definition files across 10 category folders, materialized at the lock
file's `pinned_commit_sha`.

Every file here:

- was fetched at the pinned commit and **SHA-256 verified** against the lock's
  `content_sha256` before being written (fail-closed)
- carries the **ADR-024 6-field attribution block** at the top
- is re-verified by CI on every pull request: the `vendored-integrity-check` job
  strips the attribution block and asserts the remaining bytes still hash to the
  lock value, so tampering with either the lock or the vendored copy fails CI

## Using this content

You can read, quote, and adapt these agent definitions offline — ask Claude to
"read `vendored/agency-agents/<category>/<file>.md`" or to adapt one for your
workspace. Installing them as first-class workspace skills through the wizard is
v2.7+ scope (see WIZARD.md F4 pool boundary); until then the wizard installs only
the curated `skills/` pool.

## Regenerating

Maintainers: after every `/sync-agency` lock bump, run from the repo root:

```bash
bash scripts/vendor-agency.sh
```

The script fetches each lock entry at the new pinned SHA, verifies hashes,
injects attribution, and round-trip-checks that CI will pass. A sync PR that
bumps the lock without refreshing this directory fails `vendored-integrity-check`.
