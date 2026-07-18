# QA Report — v2.8.0 "Showcase"

## Phase: 5 + 6 (inline) + 7 — combined-path (STANDARD classification)
## Date: 2026-07-18T09:45:00Z (re-checked 2026-07-18, HEAD `eab90f3`)
## Branch: `release/v2.8.0` @ `48b2456` → re-checked at `eab90f3` (base `main` `e24318c`)
## Status: **APPROVED at HEAD `eab90f3`** (initial pass at `48b2456` was REJECTED — 1 blocking finding, now resolved; see §Re-check below)

All verification commands below were re-run independently at HEAD `48b2456`, not
taken from @dev's or @security's narrative. Every named number is a command I ran
myself this session.

---

## Part A — Per-AC Results (26 ACs)

### WS1 — Starter File Regeneration

| AC | Verify | Result |
|---|---|---|
| AC-WS1-1 | `grep -liE "Step 1: Name\|Phase 1 —\|Phase 2 —\|Phase 3 —\|Workspace ready\." examples/*/project-instructions-starter.txt \| wc -l` | **0** ✅ |
| AC-WS1-2 | `grep -l "Confirmed bundle" examples/*/project-instructions-starter.txt \| wc -l` | **7** ✅ |
| AC-WS1-3 | Job exists (`grep -ic "starter" quality.yml` = 27) + negative control | ✅ (see Part B) |

Word counts (ceiling 400, target ≤350): business-admin 373, creative 372,
personal-assistant 396, project-management 374, research 373, study 373,
writing 372. All under ceiling; personal-assistant closest to the 400 hard
limit (24 words of margin) — not a failure, noted for awareness.

### WS2 — README Storytelling Pass

| AC | Verify | Result |
|---|---|---|
| AC-WS2-1 | `sed -n '1p' README.md \| grep -c '^# '` | **1** ✅ |
| AC-WS2-2 | `head -60 README.md \| grep -ic "Snyk"` / `"PromptArmor"` | **1 / 1** ✅ |
| AC-WS2-3 | swarm/persona-sim mention in What's-new section | **1** ✅ |
| AC-WS2-4 | archaeology sections removed | **0** ✅ |
| AC-WS2-5 | diagram references `_setup-kit`/handover | **1** ✅ |
| AC-WS2-6 | "hurry" callout | **1** ✅ |
| AC-WS2-7 | TRUST.md exists, has H1, linked 2× from README | ✅ |
| AC-WS2-8 | "zero runtime fetch"/"fully reviewable supply chain" | **1** ✅ |
| AC-WS2-9 | denylist scan (competitor/tool names) | **0 forbidden names** ✅ — independent scan below |

**Independent denylist scan (not just trusting the Phase-4 commit-message disposition):**
ran my own regex across README.md, TRUST.md, docs/how-it-works.md, docs/faq.md,
all 7 starter files, and assets/setup-demo.svg for Cursor/Copilot/Windsurf/
Cline/Aider/Devin/Replit/Bolt.new/v0.dev/Codeium/Tabnine/Amazon Q/CodeWhisperer/
JetBrains AI/Sourcegraph/Cody/ChatGPT/GPT-4/GPT-5/OpenAI/Gemini/Bard —
**0 hits.** Snyk/PromptArmor/agency-agents/msitarzewski present as expected.

**Fresh Snyk/PromptArmor figure spot-check (independent, via WebFetch against
primary sources, not copied from @dev's claim):**
- Snyk "ToxicSkills" (snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub):
  **3,984 skills scanned; 36.82% (1,467) with ≥1 security flaw; 76 confirmed-malicious
  payloads.** Matches README/TRUST.md verbatim. ✅
- PromptArmor (promptarmor.com/resources/claude-cowork-exfiltrates-files):
  indirect prompt injection via uploaded file → curl exfiltration through the
  allowlisted Anthropic API endpoint. Matches README/TRUST.md's characterization. ✅

### WS3 — Demo Asset

| AC | Verify | Result |
|---|---|---|
| AC-WS3-1 | `head -30 README.md \| grep -ic "demo"` | **2** ✅ |
| AC-WS3-2 | Slot populated (option b chosen — synthetic SVG), same PR | ✅ populated, not deferred |

**SVG inertness (S5 MUST-VERIFY, independently re-run):**
`grep -iE '<script|<foreignObject|on[a-z]+=|xlink:href="(https?:|//|data:|file:)|href="(https?:|//|data:|file:)|<image[^>]*href|<use[^>]*href="[^#]' assets/setup-demo.svg`
→ **0 matches.** XML well-formedness confirmed via `python3 xml.etree.ElementTree`.
Content read directly: 6 chat-style beats via CSS `@keyframes` only (no SMIL, no
JS, no external href), uses "Your workspace is ready." (not the retired literal),
matches the F4 fast-track text exactly. Alt text present both as markdown alt
and SVG `<title>`. **PASS.**

### WS4 — Offline Smoke Test / Timing Claim — **BLOCKING FINDING**

| AC | Verify | Result |
|---|---|---|
| AC-WS4-1 | `grep -c "| [0-9]" tests/offline-smoke-test.md` ≥ 4 | **4** (mechanical check passes) |
| AC-WS4-1 substance | "real data from actual executed runs (**not estimates**)" | **FAILS** — see below |
| AC-WS4-2 | decision rule applied + raw numbers cited | ✅ applied correctly, **to non-real data** |
| AC-WS4-3 | `grep -c "offline-smoke-test" CONTRIBUTING.md` ≥ 1 | **1** ✅ |

**This is the one substantive gap in an otherwise clean cycle.** I read
`tests/offline-smoke-test.md` directly. Its own text states: *"no human tester
was available in this Phase 4 implementation session, so all 4 sessions were
dry-run end-to-end by @dev... Wall-clock is a grounded estimate per turn...
not a literal stopwatch on a live human session."* The WS4 commit message
says the same thing, unprompted.

The AC's literal grep check (`>= 4` numeric rows) is a **check that cannot
fail on this defect** — it counts filled cells, not evidence provenance.
Spec's own §Success Metrics and §User Stories are explicit: *"the 'about 15
minutes' claim... backed by 4 real timed runs... not an empty scorecard"*
and AC-WS4-1's own parenthetical says *"(not estimates)."* What shipped is
neither empty nor real — it's a same-session AI self-estimate of its own
designed flow's duration, and the README's hero line (`"...three quick
turns, 15 minutes."`, line 3) carries **zero disclosure** of that. A skeptical
LinkedIn-referred reader — the exact persona this cycle exists to earn trust
with — has no way to know the claim isn't stopwatch-verified.

To be fair to @dev: this may be a structural gap in the cycle's own design,
not a corner deliberately cut. Spec §Gate Decisions Required explicitly
assigned WS4 execution to "orchestrator/@qa," not @dev, and no agent in this
pipeline — @qa included — can produce a literal human-clock timing without
an actual human running the flow. The spec set a bar ("not estimates") that
a fully-automated Phase 4 session cannot clear. @dev's mitigation (documented
methodology, decision rule still correctly applied to the resulting numbers,
explicit self-disclosure in the scorecard itself) is the reasonable move
*given the constraint* — but it doesn't satisfy the AC as written, and the
gap doesn't surface where a reader would see it.

**This was one of the spec's own explicit "Gate Decisions Required" items**
(§WS4 — "the resulting hero-line wording is presented for confirmation") —
i.e., the spec anticipated this needing a human sign-off, not a silent
pass. I'm not able to unilaterally wave it through given my Phase 7 default
(NEEDS_WORK unless evidence supports APPROVED), and I don't have evidence
the literal AC is met.

**Three remediation paths, any of which resolves this cleanly (cheap, no
re-architecture needed):**
1. **Fastest:** add one clause to the README hero line or a footnote near
   the demo — e.g., *"~15 minutes (methodology: [tests/offline-smoke-test.md](tests/offline-smoke-test.md))"*
   — so the claim is honest about its own evidence quality.
2. Soften to "about 15 minutes" and add the same disclosure.
3. User explicitly accepts the estimate-based scorecard as sufficient for
   this release (documented sign-off), given no human tester is available
   in this environment (spec's own `[UNTESTED]` assumption) — with a real
   human-timed run tracked as the fast-follow ADR-038 §Maturation Path
   already recommends.

I recommend (1) — it's a one-line fix, preserves the "15 minutes" claim
that the actual numbers (5.25 min estimated median) comfortably support,
and closes the trust gap for the exact audience TRUST.md is written for.

### WS5 — docs/ Information Architecture Split

| AC | Verify | Result |
|---|---|---|
| AC-WS5-1 | `find docs/internal -type f \| wc -l` ≥ 30; 4 root files present | **40**; spec.md/retro.md/patterns.md/architecture.md all present ✅ |
| AC-WS5-2 | broadened cross-check (backtick + functional + workflow surfaces) | **0 stale pre-move references** ✅ (see Part C) |
| AC-WS5-3 | `.gitattributes` collapse ≤6 docs/ lines; research/audit removed | **4** lines; **0** research/audit refs ✅ |
| AC-WS5-4 | atomic single-commit landing; Link Check green | ✅ landed as 1 commit (`1c48235`); Link Check pending PR push (see note) |
| AC-WS5-5 | `docs/internal` in release-assets.yml as real array entry, not comment | **3 hits**, confirmed genuinely in `DROP_PATHS[]` (not comment-only) ✅ |

**This is the highest-blast-radius surface (67 files, 40 relocations) and
the security review's flagged 3rd-instance KEEP-DROP risk — verified
exhaustively, not sampled.** Full detail in Part C below.

### WS6 — Dead-Reference + Canonical-Q1 Cleanup

| AC | Verify | Result |
|---|---|---|
| AC-WS6-1 | `grep -c "CLAUDE.md Phase" WIZARD.md` | **0** ✅ |
| AC-WS6-2 | `grep -c "^## Phase 1" WIZARD.md` (both headings) | **0** ✅ — confirmed both line-343 and line-365 headings renamed |
| AC-WS6-3 | canonical Q1 quoted verbatim in SKILL.md | **1**, and I confirmed byte-for-byte match against WIZARD.md:44 directly | ✅ |

Read the full WIZARD.md diff directly: exactly the 6 bound exact-line edits
(227, 343-heading, 345, 355, 365-heading, 393), nothing else touched — Q1/F4/Q2/Q3
routing logic untouched, matching the preservation constraint.

### WS7 — Social-Preview Currency

| AC | Verify | Result |
|---|---|---|
| AC-WS7-1 | disposition line in PR description or scratchpad | **NOT YET PRESENT** — expected per orchestrator brief (deviation b) |

Searched all 8 commit messages on this branch: no social-preview disposition
recorded anywhere yet. This is the pre-cleared deviation the orchestrator
flagged ("WS7 deferred to user — must be in the PR description"). **Action
item for PR creation:** the PR description MUST contain a line of the form
"Social-preview: current, verified `<date>`" / "regenerated, see `<asset>`" /
"UNKNOWN — deferred to user for a manual check" before this AC is satisfied.
Not a rejection reason on its own — it's a known, orchestrator-acknowledged
gap contingent on PR creation, which hasn't happened yet.

**AC tally: 25/26 mechanically verified + substantively sound. 1/26
(AC-WS4-1) mechanically passes but fails its own explicit substance
requirement. 1/26 (AC-WS7-1) is an expected, pre-cleared pending item
contingent on PR creation, not yet applicable.**

---

## Part B — WS1 Negative Control (run independently, not trusted from @dev's commit message)

Extracted the actual `starter-drift-marker-check` script from `quality.yml:294-309`
and ran it myself against a scratch copy of the repo (not the real repo — reverted
before any commit):

**Positive control (clean tree):**
```
PASS: no retired-interview markers in any starter file.
```
Exit code: **0**

**Negative control (injected literal `Step 1: Name` into
`examples/creative/project-instructions-starter.txt`):**
```
::error::Retired-interview marker found — starter files must reflect the current v2.7 WIZARD.md interview:
examples/creative/project-instructions-starter.txt
```
Exit code: **1**, and the error message names the exact injected file.

Reverted; `diff` against the real repo's copy confirmed byte-identical, no
residual change. **Negative control independently reproduced — AC-WS1-3
genuinely satisfied, not a check-that-cannot-fail.**

---

## Part C — WS5 Leak Check, Cross-Check, and Repo-Wide Sweep (verbatim outputs)

### C1 — Archive leak check (the critical one)

```
$ git archive HEAD | tar -t | grep '^docs/'
docs/
docs/architecture.md
docs/faq.md
docs/how-it-works.md
docs/project-audit-v2.6.1.md
docs/research/
docs/research/v2.2-skill-landscape.md
docs/research/v2.7-usercase-test-and-improvement-research.md

$ git archive HEAD | tar -t | grep -c '^docs/internal/'
0

$ git archive HEAD | tar -t | grep -E '^TRUST\.md$'
TRUST.md
```

**Exactly** the intended public set (architecture.md, faq.md, how-it-works.md,
project-audit-v2.6.1.md, research/×2) + TRUST.md at root. **Zero
`docs/internal/**` entries. Zero unexpected files. CLEAN.**

`docs/spec.md`/`docs/retro.md`/`docs/patterns.md` correctly absent from the
archive (Council-tooling exempt, still `export-ignore`'d) — confirmed via
`.gitattributes:31-33`.

### C2 — DROP_PATHS[] backstop verification (S4's concern — not a comment-only check)

Read `.github/workflows/release-assets.yml` diff directly: `docs/internal/` is a
genuine array element in `DROP_PATHS[]` (replacing ~6 individually-named
entries), and `KEEP_PATHS[]` is extended with `TRUST.md`,
`docs/project-audit-v2.6.1.md`, both `docs/research/*` files,
`docs/how-it-works.md`, `docs/faq.md`. This is a real prefix-match backstop,
not a check-that-barely-fails as S4 warned it could become. **PASS.**

### C3 — Broadened cross-check (AC-WS5-2, architecture.md §2c command, re-run verbatim)

```
$ grep -rnE "(\]\(|\`)?docs/(internal/)?(assumptions|competitive|compliance-review|
  dev-deliberation|personas|qa-report|retro-template|security-audit|security-review|
  skills-roadmap|OUTPUT-STRUCTURE|ux-review|security/upstream-content-scan-rules)" \
  README.md CONTRIBUTING.md SETUP-CHECKLIST.md WIZARD.md CLAUDE.md \
  .claude/skills/ .github/workflows/{quality,sync-agency,release-assets}.yml
```
Returns 5 hits — all 5 are the **correctly rewritten** `docs/internal/...`
form (the pattern is deliberately inclusive of both pre- and post-move
forms). Filtering to pre-move-style hits only (`grep -v "docs/internal/"`):
**0 stale references.** Individually verified all 9 enumerated hits from
architecture.md §2c's table (quality.yml:925/937 — line numbers shifted
from 908/920 due to the WS1 job insertion above them, content correct;
CONTRIBUTING.md ×3; sync-agency.yml ×4) — every one now reads
`docs/internal/...`. **PASS.**

### C4 — Repo-wide sweep (orchestrator's explicit ask, item 4 — broader than architecture's 9-surface list)

Built the full 40-basename moved-file list from `docs/internal/`, grepped
every tracked file in the repo (`git ls-files`) for `docs/<basename>`
NOT prefixed by `internal/`. 186 raw hits; after excluding `CHANGELOG.md`
(explicitly bound as append-only/LEAVE by architecture.md) and
`docs/internal/**` self-references (internal-only, not shipped, not a leak),
the remaining hits are all inside `docs/architecture.md`, `docs/patterns.md`,
`docs/retro.md`, `docs/spec.md` (historical per-cycle ADR/retro/spec record —
same append-only convention as CHANGELOG) plus two genuinely NEW public
documents:

- `docs/project-audit-v2.6.1.md:29` — "The assumptions register
  (docs/assumptions.md) never recorded..." — descriptive past-tense audit
  finding, not an actionable link.
- `docs/research/v2.7-usercase-test-and-improvement-research.md:60` —
  "Platform reality (vs docs/assumptions.md)" — same, a comparison label in
  a dated research artifact.

**Disposition: INFO, not a rejection trigger.** Both are historical/dated
documents (an audit snapshot and a research report, each self-identified by
version/date) referencing a filename as prose, not as a live cross-reference
a reader would click — the same class the design already excepted for
CHANGELOG.md. No functional break (no CI reads these), no reader-facing
"go here" instruction that dead-ends. Recommend a future cycle add a
bracketed `[since relocated to docs/internal/]` note if these documents are
revised again, but this does not block this merge.

**No dangling pointer found in any live/functional surface** (README,
SETUP-CHECKLIST, CONTRIBUTING, WIZARD, CLAUDE.md, `.claude/skills/**`,
all 3 workflows, PR template, `curated-skills-registry.md`). Both S1/S2
MUST-FIX items independently confirmed applied (PR template:17 → correct
path; curated-skills-registry.md:84/86 → correct path).

---

## Part D — Version Consistency, Markdownlint, YAML

```
$ V=$(cat VERSION); B=$(grep -oP 'version-\K[0-9.]+(?=-green)' README.md|head -1); C=$(grep -m1 -oP '^## \[\K[0-9.]+' CHANGELOG.md)
VERSION=2.8.0 BADGE=2.8.0 CHANGELOG=2.8.0
```
**PASS — all three agree.**

Markdownlint run against the **exact CI glob scope** (`quality.yml:13-16`:
`**/*.md` excluding `docs/**` and `vendored/agency-agents/**` — the whole
`docs/` tree, including newly-public `docs/how-it-works.md`/`docs/faq.md`,
is intentionally CI-exempt by this repo's own long-standing convention):
```
Linting: 145 files
Summary: 0 issues in 0 files
```
**0 errors.** (Note: running markdownlint against `docs/spec.md` and the
just-relocated `docs/internal/security/*.md` files outside the CI scope
surfaces ~55 pre-existing formatting issues — all in append-only
historical documents that predate this cycle and were never subject to
linting; not this cycle's defect, not in CI's actual scope, not a finding.)

YAML validity — all 3 touched workflows parse cleanly via `yaml.safe_load`:
`quality.yml`, `sync-agency.yml`, `release-assets.yml` — **all VALID.**

---

## Part E — Phase 6 (inline security audit re-confirmation)

Re-verified each of @security's 5 Phase-4 MUST-FIX items directly against
the diff (not trusting the security-review's own PASS claim):

1. **PR-template:17** → confirmed rewritten to `docs/internal/security/upstream-content-scan-rules.md`. ✅
2. **curated-skills-registry.md:84,86** → both confirmed rewritten to `docs/internal/process/skills-roadmap.md`. ✅
3. **security-review-v2.8.0.md moved** → confirmed present at `docs/internal/security/security-review-v2.8.0.md` (this file's own sibling), correctly excluded from the archive. ✅
4. **quality.yml functional path-fix (lines formerly 908/920, now 925/937)** → confirmed path-only change; grep patterns and `exit 1` logic byte-identical (diff shows literally only the path token changed on 2 lines). ✅
5. **sync-agency.yml 4 comment/heredoc paths** → confirmed via full diff: exactly lines 8, 141, 404, 410 changed, each a comment or PR-body heredoc string; `SCAN_PATTERNS[]`, `permissions: read-all`, `contents:write`/`pull-requests:write`, concurrency, and the 24h-soak rule are **byte-unchanged** (verified by reading the full diff, not a claim). ✅

**No-competitor-naming scan:** independently re-run (see Part A/WS2-9) — **0 hits** beyond the pre-approved 3.

**Snyk/PromptArmor accuracy:** independently re-verified against primary
sources via live fetch (see Part A/WS2) — **figures match exactly.**

**sync-agency-dry-run pre-existing bug — independently confirmed PRE-EXISTING, not a regression:**
- `git show e24318c:docs/security/upstream-content-scan-rules.md | grep -n '^- \`'` → 0 matches (pre-move file, same bug)
- `git log --oneline --diff-filter=A -- docs/security/upstream-content-scan-rules.md` → introduced at `373a8e5` (v2.0.0)
- Traced the actual bash behavior: `PATTERN_COUNT=$(grep -c '^- \`' FILE || echo 0)` produces the malformed
  2-line string `"0\n0"` (grep -c already prints "0" on zero matches but exits 1, triggering the `|| echo 0`
  fallback too), and `[ "$PATTERN_COUNT" -lt 1 ]` throws a bash integer-syntax error that the `if` swallows
  without tripping `exit 1` — the gate silently never fires, regardless of file content or path.
- **Confirmed unaffected by this PR:** the diff changes ONLY the file path on 2 lines; the `grep -c '^- \`'`
  pattern itself (the actual bug) is untouched. This job will report the same "success" behavior it always
  has — it does not block this merge and is a valid pre-existing carry-forward, correctly left out of
  scope per the MUST-FIX #4 "byte-identical logic" bound.

---

## Part F — Deviation Assessment

**(a) Commit-grouping only:** the 6 @dev commits land WS1/WS5/WS6/WS4/WS3/WS2
in a different order than the spec's WS1–WS7 listing, and WS7 has no
standalone commit (folded into the pending PR-description disposition).
Reviewed all 8 commit diffs directly — no functional coupling issue, no
missing work, no cross-workstream file bleed. **Confirmed benign,
organizational only.**

**(b) WS7 deferred to user:** confirmed — see Part A/WS7. Must land in the
PR description at creation time; not yet present anywhere on this branch.
**Confirmed as the orchestrator described it — not a new finding.**

**`git diff 48b2456 HEAD`** (before this report's own commit): **empty.**
No drift introduced by my verification session.

---

## Part G — @ux Light Pass (README + SVG structure)

Not a full @ux run (STANDARD classification, no CSS/component surface) —
a light heuristic read, as the orchestrator scoped it.

- **README structure:** H1 → badges → demo → trust story → audience →
  how-it-works (+ diagram) → quick start. Logical top-to-bottom order,
  matches the bound skeleton in architecture.md §3.5. Reads clearly within
  the first screen; the "See it in action" section immediately following
  badges gives a first-time visitor something concrete before the trust
  pitch. No orphaned headings, no broken internal anchors observed.
- **SVG:** read the full 87-line source directly. 6 legible chat-style
  beats, staggered CSS `@keyframes` reveal (28s loop), monospace styling,
  no PII, content matches the real interview flow. Alt text present twice
  (markdown `![]()` alt + SVG `<title>` for the no-render/screen-reader
  fallback) and is descriptive, not decorative-only. `role="img"` +
  `aria-labelledby` is a reasonable accessible pattern for a static/animated
  informational SVG.
- **No broken embed:** `assets/setup-demo.svg` exists at the path README
  references; confirmed present in the release archive alongside README.

**No blocking UX issues found.** A full @ux pass is not warranted for this
cycle's surface area.

---

## Verdict

**REJECTED** — pending disposition of one finding (WS4 / AC-WS4-1 substance
gap: the "15 minutes" claim is backed by an AI-estimated, not stopwatch-timed,
scorecard, undisclosed in the public-facing README). This is a one-line,
same-day fix (see Part A/WS4 remediation options) — not a rework cycle.

**Everything else is clean and ready to ship:**
- 24/26 ACs mechanically AND substantively verified, independently, this session.
- 1/26 (AC-WS7-1) is an expected pending item contingent on PR creation (not yet applicable — action item, not a defect).
- All 5 Phase-4 security MUST-FIX items confirmed applied, byte-precise.
- All 4 Phase-4 MUST-VERIFY items confirmed (SVG inertness, WS5 archive/DROP_PATHS backstop, drift-job hygiene, fresh Snyk/PromptArmor figures).
- Archive leak check: exactly the intended public set, zero `docs/internal/**` leakage.
- Repo-wide dangling-reference sweep: zero live/functional-surface stale pointers; 2 INFO-only historical-prose mentions in dated documents, non-blocking.
- Negative control for the new CI drift-marker job independently reproduced (exit 1, correct file named).
- No-competitor-naming denylist: 0 hits, independently re-scanned.
- Version consistency, markdownlint (CI-scoped), YAML validity: all clean.
- Pre-existing `sync-agency-dry-run` bug confirmed genuinely pre-existing (v2.0.0), unaffected by this PR, correctly out of scope.
- 2 known deviations (commit-grouping, WS7-deferred) both confirmed benign/as-described.

### Next step (orchestrator)

1. Route the WS4 finding to the user/@dev for a one-line disposition (see
   Part A/WS4's 3 remediation options — recommend option 1, a same-day fix).
2. Once resolved, re-run `head -30 README.md` / hero-line check to confirm
   the fix landed, then: push branch → open PR (with the WS7 social-preview
   disposition line included in the PR description, per Part A/WS7) →
   `gh pr checks <PR-number>` must show all green → present the green-CI
   + this report to the user for MERGE / REJECT.
3. This qa-report is committed on `release/v2.8.0` now, per the session
   brief — not pushed.

---

## Re-check — WS4 disclosure fix (2026-07-18, HEAD `eab90f3`)

**Delta since the rejected pass:** `git diff 24e3b42..eab90f3 --stat` → exactly
`README.md` (+1/-1) and `tests/offline-smoke-test.md` (+13/-4). No other file
touched — confirmed no other workstream regressed alongside this fix.

**User decision (per commit `eab90f3`):** keep "~15 minutes" (the underlying
number — median 5.25 min estimated — comfortably supports it) but disclose
the estimate rather than presenting it as measured. This is remediation
option 1 from my original finding.

**Fix, read directly:**
- README.md hero line now reads: *"...three quick turns, about 15 minutes
  (an estimate — see [methodology](tests/offline-smoke-test.md))."* Link
  target confirmed present (`tests/offline-smoke-test.md` exists).
- `tests/offline-smoke-test.md`'s Timing scorecard heading now reads
  "ESTIMATED, not stopwatch-timed," with an explicit lead sentence: no
  live-timed human run has been recorded, every number is a grounded
  estimate, and community stopwatch PRs are explicitly invited to replace
  rows with real data. The decision-rule paragraph now explains why the
  hero line carries the qualifier.

**AC-WS4-1 substance re-verification:**
```
$ grep -n "15 minutes" README.md | grep -i "estimate"
3:> ...three quick turns, about 15 minutes (an estimate — see [methodology](tests/offline-smoke-test.md)).
```
Exit 0. **Sanity-checked the check itself can fail** (not tautological) by
piping the OLD undisclosed phrasing ("...15 minutes.") through the identical
grep chain: exit 1, no match — confirming the check genuinely distinguishes
disclosed from undisclosed, i.e. it exercises the real defect class rather
than always passing.

**No regression on other README-dependent ACs** (spot-checked):
AC-WS2-1 (H1) = 1, AC-WS2-2 (Snyk/PromptArmor in first 60 lines) = 1/1,
AC-WS3-1 (demo mention) = 2, AC-WS2-6 (hurry callout) = 1 — all unchanged
from the original pass.

**Version consistency:** `VERSION=2.8.0 BADGE=2.8.0 CHANGELOG=2.8.0` — unaffected.

**Markdownlint** on the 2 changed files: `Linting: 2 files / Summary: 0
issues in 0 files`.

**`git diff eab90f3 HEAD`** (before this commit): empty — no drift introduced
by this re-check session.

### Updated verdict

**APPROVED.** The one blocking finding from the initial pass (AC-WS4-1
substance gap) is resolved: the "15 minutes" claim is now honestly qualified
as an estimate with a working link to methodology, and the underlying check
is verifiably non-tautological. Combined with the initial pass's clean
results across all other 25 ACs, all 9 Phase-4/6 security MUST-FIX/
MUST-VERIFY items, the archive leak check, the repo-wide dangling-reference
sweep, the WS1 negative control, and version/markdownlint/YAML hygiene —
**this cycle is ready to ship.**

Two items remain for the orchestrator at PR-creation time (both already
known, neither blocks this APPROVED):
1. **AC-WS7-1** — the social-preview disposition line must be added to the
   PR description (still absent from any commit on this branch).
2. Push → open PR → `gh pr checks <PR-number>` must show all green before
   presenting to the user for MERGE.
