# Project Audit — v2.6.1 (2026-07-06)

**Trigger:** Field report from first live user test: the wizard attempted to download agents from the
upstream repo (`msitarzewski/agency-agents`), Claude had no permission to reach github.com, nothing
installed, and no guide surface identified or explained the failure.

**Scope:** Full-repo audit — runtime surfaces (CLAUDE.md, WIZARD.md, `.claude/skills/setup-wizard/`),
user guides (README, SETUP-CHECKLIST), registry/presets/pool consistency, CI (`quality.yml`,
`sync-agency.yml`), lock file, assumptions register.

**Legend:** CRITICAL = blocks the kit's mandate · HIGH = user-visible malfunction · MEDIUM = drift that
will become a malfunction · LOW = hygiene. Status: FIXED in this change set, or OPEN with recommendation.

---

## F-1 — CRITICAL — Runtime treats GitHub as reachable; offline is the real default (FIXED)

**The reported failure.** Root cause is an ambiguity across the runtime surfaces:

- `cowork.lock.json` pins 110 upstream files — **none are vendored in the repo** (verified: 110/110
  missing locally). Any attempt to "install" them at runtime requires a live GitHub fetch.
- The ADR-024 attribution rule in CLAUDE.md/WIZARD.md is phrased as a **runtime** obligation ("every
  file fetched from agency-agents upstream…"), and README/SETUP-CHECKLIST talk about SHA-pinned
  upstream installs. A model reading this context reasonably concludes it should fetch agents from
  GitHub during onboarding.
- Cowork sessions commonly run with **no network access**. The fetch fails, and there was no
  preflight, no fallback wording, and no troubleshooting entry anywhere ("network", "internet",
  "offline" appeared in zero user-facing guides).
- The assumptions register (docs/assumptions.md) never recorded a network-access assumption at all —
  A-v2.0-3 even assumed the wizard "can fetch the file content from the pinned URL" at install time.

**Fix applied (offline-first contract made explicit):**

1. WIZARD.md — new **§Network & Offline Rule (runtime)**: never fetch from GitHub/upstream in a live
   session; all installs copy from local `skills/`; upstream content flows only through the
   `/sync-agency` CI workflow; exact fallback wording when a step appears to need the internet;
   web access is an optional user-side toggle, never required for setup.
2. CLAUDE.md — new **## Offline Rule** (2 lines; word count 399/400, see F-11).
3. SETUP-CHECKLIST.md — new first troubleshooting entry: *"Claude says it can't access GitHub or the
   internet — skills/agents didn't download"*, including the one-line reply users can paste to
   redirect Claude to the local pool.
4. README.md — "Setup works fully offline" callout in Quick start.

**Follow-up (IMPLEMENTED, second pass):** `tests/offline-smoke-test.md` — full wizard run with
networking disabled, required pre-release. Formal assumption added: `A-v2.6.2-1` "Cowork sessions
have no internet access by default" — [CONFIRMED by field report 2026-07-06], superseding the
fetch-at-install mechanism assumed in A-v2.0-3.

## F-2 — HIGH — Registry offered a skill that does not exist (FIXED)

`curated-skills-registry.md` listed `citation-formatter` as Tier 1 `builtin`, but there is no
`skills/citation-formatter/SKILL.md`. WIZARD.md Step 4 resolves installs via the registry, so the
wizard could offer — and then fail to install — a nonexistent skill. Removed the row with a
disposition annotation (re-add only together with a 9-section pool file). Registry cardinality after
removal: 22 rows (CI minimum 18 — passes).

## F-3 — HIGH — setup-wizard skill diverged from the wizard it invokes (FIXED)

`.claude/skills/setup-wizard/SKILL.md` still ran the **v1.x flow**: a fixed 6-preset menu (Personal
Assistant, shipped in v1.4, was missing) and "run the full 11-step interview… step sequences are in
WIZARD.md" — WIZARD.md has not contained an 11-step sequence since the v2.4 dynamic rewrite. A user
typing `/setup-wizard` (the documented recovery path!) got a broken script pointer. Rewritten to route
through WIZARD.md's actual flow (Q1 routing → F4 → Q2–Q5 → generation steps), 7 presets listed, plus
the offline rule.

## F-4 — MEDIUM — Deadline surfacing could never fire (FIXED)

CLAUDE.md first-session behavior is "Surface deadlines within 7 days" from `cowork-profile.md`, but no
wizard step ever collected deadlines and WIZARD.md's profile template had no Deadlines field (only the
example preset starter mentioned it). Added a `**Deadlines:**` line to the WIZARD.md Step 1 profile
template with a collection prompt.

## F-5 — MEDIUM — Skill-count drift across surfaces (FIXED where user-facing)

Actual pool: **21** slugs. README said "20 skills"; WIZARD.md F4 says 21 (correct). README fixed.
Comment-only references to "20 files" remain in `quality.yml` (lines ~317–321) — harmless but worth
cleaning next CI touch.

## F-6 — MEDIUM — SETUP-CHECKLIST Step 9 covered 6 of 7 presets (FIXED)

"Try this now" prompts existed for every preset except Personal Assistant. Added file-based and
file-agnostic PA prompts.

## F-7 — MEDIUM — Supply-chain story oversells what users receive (FIXED — option (a) implemented)

README §Supply-Chain Integrity says "the wizard installs only allowlisted, checksum-verified,
attribution-injected files," but at v2.6 the wizard installs only in-tree `builtin` skills — which the
lock file does **not** cover — while the 110 lock-pinned upstream files are never installed (or even
present). The lock file currently anchors content that no user path consumes. Two coherent options:

- **(a) Vendor it:** have `/sync-agency` commit reviewed upstream files (with ADR-024 blocks) into a
  `vendored/` tree so future external-skill support (v2.7+) works offline by construction; or
- **(b) Re-scope the claim:** present the lock file as forward-looking infrastructure for v2.7+ and
  state plainly that today's installs are all local/builtin.

Either resolves the mismatch; (a) aligns best with the offline-first contract now codified in F-1.

**Implemented (second pass): option (a).** All 110 lock entries + LICENSE are now vendored at
`vendored/agency-agents/`:

- `scripts/vendor-agency.sh` fetches each file at the pinned SHA, verifies `content_sha256`
  (fail-closed), verifies the LICENSE hash, injects the ADR-024 6-field attribution block, and
  round-trip-checks that stripping the block reproduces the upstream hash exactly.
- New CI job `vendored-integrity-check` re-runs that verification **offline** on every PR — a lock
  bump without a vendored refresh, or any tamper on either side, fails CI. S1 8-pattern injection
  scan ran clean over all 110 files at vendor time (0 hits, consistent with `requires_review: false`
  across the lock).
- `sync-agency.yml` reviewer checklist now includes the vendored refresh step; release archive keeps
  `vendored/` (KEEP assertion added for `vendored/agency-agents/LICENSE`); markdownlint and lychee
  exclude the verbatim upstream tree.
- README/SETUP-CHECKLIST supply-chain sections rewritten to describe what actually ships; WIZARD.md
  Network & Offline Rule now directs offline reads to `vendored/agency-agents/`. Wizard *install*
  of vendored agents remains v2.7+ scope per the F4 pool boundary (ADR-034) — reading/quoting/adapting
  is available offline today.

## F-8 — LOW — Three overlapping onboarding scripts (MITIGATED — CI drift gate shipped)

CLAUDE.md (Phases 1–4), WIZARD.md (Q1–Q5 + F-steps), and the setup-wizard skill each describe the
interview. F-3 is what divergence looks like after a few cycles. **Implemented (second pass):** new
CI job `wizard-consistency-check` asserts (1) every preset core/optional/cross-cutting slug has a
pool file, (2) every pool skill has a registry row, (3) every registry `builtin` row names a real
pool skill (would have caught F-2), (4) every preset display_name appears in the setup-wizard skill
menu (would have caught F-3). Full consolidation to pointer-only secondary surfaces remains a future
editorial pass; the drift gate removes the silent-failure mode.

## F-9 — LOW — Stale model guidance (FIXED)

"Select **Opus 4.x**" / `opusplan` recommendations (README, WIZARD.md, SETUP-CHECKLIST) predated
current model generations. Replaced with version-neutral wording ("most capable model available in
your plan" / "planning-optimized alias where available") in all three files — no re-editing needed
on future model launches.

## F-10 — LOW — README version narrative is stale (FIXED)

"What's new in v2.5" rewritten as "What's new in v2.6" summarizing 2.6.x (tiered scaffolds, skill
swap, archive hygiene, offline-first + vendored library) with v2.5 kept as an "Earlier" line; "Next
up (v2.7+)" updated to name external skill install from the vendored library.

## F-11 — LOW — CLAUDE.md is at 399/400 words (WATCH)

The offline rule consumed nearly all remaining budget (380 → 399 after trims). The next CLAUDE.md
addition must trim elsewhere or push detail into WIZARD.md per the ADR-021 overflow precedent.

---

## Verification performed

- `wc -w CLAUDE.md` = 399 (≤400 CI cap); safety rule + verbatim ADR-024 rule strings intact in both
  CLAUDE.md and WIZARD.md (grep-verified, byte-for-byte).
- Registry: 22 data rows (≥18); all `source_url` values `builtin`; goal_tags vocabulary unchanged.
- No `skills/`, `selection-presets.md`, or `examples/` skill files touched — byte-mirror (CMP), depth,
  and vocabulary gates unaffected.
- markdownlint run locally on changed non-docs files (config: `.markdownlint.jsonc`).
