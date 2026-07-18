# QA Report — v2.7.2 "Truth & Release"

## Phase: 5 + 6 + 7 (combined-path, STANDARD classification)
## Date: 2026-07-18T09:15:00Z
## Branch: release/v2.7.2 @ `9a56474` (not pushed)
## Status: REJECTED — one trivial, scoped, verified fix required before push

> Independently re-run at HEAD `9a56474`. Every command below was executed by @qa this
> session, not copied from the @dev/@security narratives. Combined-path eligibility
> (Phase 5+6+7 in one pass): CONFIRMED — classification STANDARD held consistently at
> Phase 1 (@architect, binding), Phase 2 (@security, CONFIRMED no escalation), and Phase 3
> (user gate). @pm's Phase 0 SECURITY-SENSITIVE was explicitly provisional/fail-safe and was
> correctly downgraded with rationale — not a classification inconsistency.

---

## Phase 5 — Testing

### AC Verification (independently re-run, actual command output)

| AC | Description | Command | Result |
|----|---|---|---|
| AC-1 | CHANGELOG dated split | `grep -n "^## \[2\.7\.0\] - 2026-07-06$" CHANGELOG.md` → line 42; `grep -n "^## \[2\.7\.1\] - 2026-07-07$"` → line 31; `grep -c "^## \[Unreleased\]$"` → 0; content-preserve spot-checks → 3 and 1 (both ≥ required) | **PASS** |
| AC-2 | VERSION/badge/What's-new | `cat VERSION` → `2.7.2`; badge count 1; `## What's new in v2.7` count 1; `What's new in v2.6` count 0; `coming in v2.7+` count 0 | **PASS** |
| AC-4 | CI gate logic (positive control) | `V=2.7.2 B=2.7.2 C=2.7.2` → all agree, exit-0 logic confirmed | **PASS** (full negative-control set below) |
| AC-5 | Promise strings purged | `grep -icE "coming in v2\.7\+"` across WIZARD.md/README.md/SETUP-CHECKLIST.md/CLAUDE.md → 0/0/0/0; README "Next up" line (171) carries no version-deadline marker | **PASS** |
| AC-6 | Stale "primary entry point" claims | `grep -n "primary v1\.2\|primary v2\.6\.0" WIZARD.md SETUP-CHECKLIST.md` → 0 matches (grep exit 1) | **PASS** |
| AC-7 | Stale version refs (README/OUTPUT-STRUCTURE) | `sed -n '115p' README.md` → no "new in v1.2"; `docs/OUTPUT-STRUCTURE.md` heading now `## Primary Entry Point` (no `(v1.2)`) | **PASS** |
| AC-8 | Registry vocabulary + annotation | `goal_tags` line includes `personal-assistant` (1 hit); `"24 rows\|23 unique"` → 1 hit | **PASS** |
| AC-9 | setup-wizard SKILL.md frontmatter | line 3 description now lists `personal-assistant` / "daily life" → 1 hit | **PASS** |
| AC-10 | quality.yml stale pool-size comment | `"20 files\|All 20 files"` → 0; `"23 files\|23-skill\|pool of 23"` → 2 | **PASS** |
| AC-11 | Legacy `tests/v1.3.3/` removed | `test ! -d tests/v1.3.3` → exit 0. Per @architect's binding **Architectural Modification** (narrowed AC-11 to directory-path removal, excluding append-only historical docs — Destructive-Migration anti-pattern avoidance), the literal spec-prose grep is superseded. I re-ran the broader grep myself anyway (not the narrowed one) and independently classified every hit: all are in append-only docs (`docs/architecture.md`, `docs/assumptions.md`, `docs/qa-report.md`, `docs/security-review.md`, `docs/retro.md`, `docs/spec.md`) or a benign version-string coincidence at `quality.yml:375` ("v1.3.3: project-management added" — a rollout-history comment, not a reference to the removed directory). **Zero live dangling references confirmed.** | **PASS** |
| AC-12 | SkillRisk decision recorded + applied | Commit `dbe8a46` subject contains `SkillRisk decision: KEEP` (`grep -c "SkillRisk decision:"` on `git log --oneline -1 -- WIZARD.md CONTRIBUTING.md` → 1); WIZARD.md:240 and CONTRIBUTING.md:77 confirmed **byte-unchanged** — full `git diff 427dea9..9a56474 -- WIZARD.md` shows only 3 hunks (lines 1, 27, 108); no hunk touches line 240 | **PASS** |
| AC-13 | CODE_OF_CONDUCT.md | exists; `Contributor Covenant` count 2; `[INSERT` count 0; **S2 fix confirmed**: `contributor-covenant.org` appears 7× including the CC BY 4.0 attribution paragraph and `[v2.1]`/`[homepage]`/`[FAQ]`/`[translations]` link defs | **PASS** |
| AC-14 | Issue templates | `.github/ISSUE_TEMPLATE/{bug_report.md,preset_request.md}` → 2 files | **PASS** |
| AC-15 | README badges | `img.shields.io/github/stars` → 1; `PRs.[Ww]elcome` → 1 | **PASS** |
| AC-3, AC-16, AC-17, AC-18, AC-19 | Tags/Releases, Discussions, homepage, social-preview, issue triage | **N/A this phase** — orchestrator-owned, post-merge. Not evaluated here per task scope; do not fail the cycle for these. | N/A |

**In-scope AC result: 15/15 PASS.**

### WS2 Negative-Control HARD GATE (check-that-can-fail enforcement)

Ran the gate's exact shell body, extracted verbatim from `.github/workflows/quality.yml`
(`version-consistency-check` job), against 4 scratch copies, under GitHub-Actions-exact
invocation `bash --noprofile --norc -eo pipefail gate.sh` (not a relaxed shell — this is the
literal GHA `run:` step invocation). Scratch copies only; nothing committed.

**NC-1 (wrong VERSION → `9.9.9`):**
```
::error::version drift — VERSION='9.9.9', README badge='2.7.2', CHANGELOG top='2.7.2'. All three must agree.
version-consistency-check FAILED — see errors above.
EXIT CODE: 1
```
✅ Exits non-zero AND names VERSION as the disagreer (all three values named, VERSION shown first as the outlier).

**NC-2 (CHANGELOG top left stranded as `[Unreleased]`):**
```
::error::CHANGELOG top section is '[Unreleased]', not a released x.y.z version — release content is stranded above the newest dated header (this is the D-2 defect class). Split it into a dated '## [x.y.z] - YYYY-MM-DD' section.
version-consistency-check FAILED — see errors above.
EXIT CODE: 1
```
✅ Exits non-zero AND explicitly says it is not a released x.y.z version. This is the false-green fix — confirmed it now fails.

**NC-3 (README badge removed/malformed):**
```
::error::could not extract README badge version — no 'version-X.Y.Z-green' shields.io badge found in README.md
version-consistency-check FAILED — see errors above.
EXIT CODE: 1
```
✅ Exits non-zero WITH the "could not extract README badge version" diagnostic present. **This proves the S1 `set +e` fix is real** — under GHA's default `bash -eo pipefail`, this exact diagnostic would have been silently swallowed (command substitution + `errexit` aborting before the friendly-message branch) without the fix. I ran this against the actual shipped gate body (`set +e` present at line 2 of the run block) and the message printed correctly.

**Positive control (unmodified shipped state):**
```
version-consistency-check PASSED — VERSION == README badge == CHANGELOG top == 2.7.2
EXIT CODE: 0
```
✅ Exits 0 with the PASSED message.

**All four negative-control outcomes match spec exactly. No Phase-5 REJECT on this gate.**

### Lint / Static Validation

- **YAML validity** (`python3 -c "import yaml,sys; list(yaml.safe_load_all(open('.github/workflows/quality.yml')))"`): parses cleanly, 1 document, no syntax error.
- **actionlint**: not available in this environment (binary absent, no network fetch attempted) — SKIPPED. YAML structural validity confirmed by the above; the new job's indentation was visually diffed against the surrounding jobs and matches (2-space job / 6-space step / correct `run: |` block).
- **markdownlint** (`npx markdownlint-cli2` against all 10 changed/added Markdown files — README.md, CHANGELOG.md, WIZARD.md, SETUP-CHECKLIST.md, CODE_OF_CONDUCT.md, docs/OUTPUT-STRUCTURE.md, curated-skills-registry.md, both new issue templates, setup-wizard SKILL.md):

  ```
  Summary: 3 issues in 1 file
  .github/ISSUE_TEMPLATE/bug_report.md:25:68 error MD009/no-trailing-spaces Trailing spaces [Expected: 0 or 2; Actual: 1]
  .github/ISSUE_TEMPLATE/bug_report.md:26:125 error MD009/no-trailing-spaces Trailing spaces [Expected: 0 or 2; Actual: 1]
  .github/ISSUE_TEMPLATE/bug_report.md:27:16 error MD009/no-trailing-spaces Trailing spaces [Expected: 0 or 2; Actual: 1]
  ```

  **This is NOT cosmetic-only noise — it is a verified, concrete CI-breaking defect.**
  `.github/workflows/quality.yml`'s `markdown-lint` job globs `**/*.md` and excludes only
  `docs/**` and `vendored/agency-agents/**`. `.github/ISSUE_TEMPLATE/bug_report.md` is
  **in scope** of that glob and **will fail the "Markdown Lint" CI check on push** in its
  current state. Root cause: 3 lines in the new "Environment" section end with a single
  trailing space (`...version): ` / `...custom): ` / `...use: `) — one char short of
  Markdown's 2-space hard-break convention, so MD009 flags it as accidental trailing
  whitespace rather than an intentional line break.

  **Fix required (trivial, 1 file, 3 lines):** strip the single trailing space at the end
  of `.github/ISSUE_TEMPLATE/bug_report.md` lines 25, 26, and 27. Zero content/logic
  change. This file is owned by @dev (WS6 repo-presentation surface), not @qa's scope —
  flagging for @dev fix-forward, not self-fixing.

### Unit / E2E Tests

N/A — this is a Markdown/YAML/Bash configuration kit with no `package.json`, no
`src/lib/core/`, and no application runtime; CI (`quality.yml`) is the test surface. All
CI-equivalent checks were re-run manually above (gate logic, negative controls, YAML
validity, markdownlint). No Vitest/Playwright surface exists in this repo.

- Total: N/A (no test runner in this stack)
- Passing: 15/15 in-scope ACs, 4/4 negative/positive controls
- Failing: 0 ACs; 1 lint defect (markdownlint, non-AC, CI-breaking)

---

## Phase 6 — Audit (abbreviated inline, combined-path)

### S1/S2/S3 Confirmed Resolved in the Real Diff

- **S1 (`set +e` after `set -o pipefail`):** confirmed present in `.github/workflows/quality.yml`'s `version-consistency-check` job (`set -o pipefail` then `set +e` on the next line, with an explanatory comment citing GHA's default `-e` behavior). Confirmed load-bearing by NC-3 above — the diagnostic message printed correctly, which would not happen without this fix. No path reaches the final `echo … PASSED` unless FAIL stays 0 through all three extractions — re-verified by reading the full `if [ "$FAIL" -eq 1 ]; then exit 1; fi` accumulator logic; there is no early-success branch.
- **S2 (Contributor Covenant CC BY 4.0 attribution):** confirmed — `contributor-covenant.org` appears in `CODE_OF_CONDUCT.md` 7 times including the required "This Code of Conduct is adapted from … version 2.1, available at https://www.contributor-covenant.org/version/2/1/code_of_conduct.html" attribution paragraph and the `[cc-by-4]: https://creativecommons.org/licenses/by/4.0/` link definition.
- **S3 (`permissions: contents: read`):** confirmed present on the `version-consistency-check` job, matching the `sync-agency-dry-run` least-privilege precedent.

### Deny-list / Scope-Drift Check

`git diff 427dea9..9a56474 --name-only` (exact list, 16 files):
```
.claude/skills/setup-wizard/SKILL.md
.github/ISSUE_TEMPLATE/bug_report.md
.github/ISSUE_TEMPLATE/preset_request.md
.github/workflows/quality.yml
CHANGELOG.md
CODE_OF_CONDUCT.md
README.md
SETUP-CHECKLIST.md
VERSION
WIZARD.md
curated-skills-registry.md
docs/OUTPUT-STRUCTURE.md
docs/architecture.md
docs/security-review-v2.7.2.md
docs/spec.md
tests/v1.3.3/test-checklist.md
```
Grep for forbidden surfaces (`sync-agency.yml|cowork.lock.json|^skills/|^examples/`) against
this list → **0 hits.** Zero drift into `sync-agency.yml`, `cowork.lock.json`, `skills/*/SKILL.md`
content, or the `examples/*` byte-mirror. This is exactly the declared WS1–WS7 file set plus
the two governed docs (architecture.md, spec.md — both confirmed pure-append, 0 real deletions
after filtering diff-header noise) and the removed legacy test directory.

### No-Competitor-Naming Scan

Scanned all new/changed product copy (README "What's new in v2.7", CODE_OF_CONDUCT.md, both
issue templates, CHANGELOG [2.7.2] section, WIZARD.md WS3/WS4 rewrites) for
`Snyk|PromptArmor|Repello` → **0 hits.** Only permitted third-party name present is the
MIT-required `msitarzewski/agency-agents` upstream attribution (README, CHANGELOG) — unrelated
to the internal competitor/tool-name set and correctly untouched. S4's pre-existing internal
citations (docs/competitive.md, docs/assumptions.md, docs/architecture.md) are unchanged by
this cycle and out of scope per the security review — confirmed not re-touched in this diff.

### Escalation Check

Full `quality.yml` diff (reviewed in entirety, not sampled): the only changes are (1) the
pool-size comment correction (20→23 files, 2 lines) and (2) the new
`version-consistency-check` job. The new job reuses the already-pinned
`actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683` (no new SHA to vet), adds no new
Action, requests no new secret, makes no network call, and modifies no existing job/control.
**No escalation trigger fires** — combined-path remains valid; a full sequential Phase 6
@security audit is not required.

### @dev Deviation Verification

- **dev-1 (AC-12 SkillRisk line in commit subject, not body):** confirmed benign — the AC-12
  verify command explicitly checks the commit *subject line* (`git log --oneline`), and commit
  `dbe8a46`'s subject literally reads "...SkillRisk decision: KEEP — verified live/reputable
  2026-07-18". Satisfies the AC as written.
- **dev-2 (AC-11 grep hits are self-referential, not a live dangling reference):** independently
  re-verified above under AC-11 — re-ran the broader (non-narrowed) grep myself and hand-classified
  every hit; all are inside append-only historical docs or a benign string coincidence in a
  `quality.yml` rollout-history comment. No hit references the removed `tests/v1.3.3/` directory
  as if it still exists. Confirmed benign.

---

## Phase 7 — Final Approval

### Rework Rate

`git diff 9a56474 HEAD` → **empty** (HEAD is exactly `9a56474`, the branch's declared target
SHA). No rework occurred between @dev's final commit and this QA pass. **Rework rate: 0%.**

### ADR-100 Flip-to-APPROVED Checklist

1. **Test output excerpt** — provided above (15/15 in-scope ACs, 4/4 NC/PC outcomes with full
   verbatim output, YAML parse confirmation, markdownlint summary).
2. **Cycle-tier evidence — Infra/config tier** (diff touches `.github/workflows/quality.yml`,
   `.github/ISSUE_TEMPLATE/`): before/after diff narrative provided (WS2 job addition, pool-size
   comment fix); dry-run verification provided (negative controls run under GHA-exact shell
   against scratch copies, not the live repo).
3. **Spec-to-code cross-reference** — provided per-AC in the table above (file:line / grep output
   for all 15 in-scope ACs).
4. **Prior-cycle issues confirmed resolved** — S1/S2/S3 (Phase 2 MUST-FIX/SHOULD-FIX) confirmed
   RESOLVED in the real diff, not assumed, with S1's fix independently proven load-bearing via
   NC-3. No other carry-forwards exist for this cycle.

**3 of 4 checklist items are clean. Item 1 (test output) surfaces a real, unresolved defect**
(markdownlint MD009 × 3, `.github/ISSUE_TEMPLATE/bug_report.md`) that will fail CI on push. Per
ADR-100's default-to-NEEDS_WORK bias, a known CI-breaking defect at the moment of sign-off is
disqualifying regardless of how trivial the fix is — the alternative is presenting the user a
merge decision on red CI, which CLAUDE.md's merge rule explicitly prohibits ("Never ask the user
to merge over red CI").

### Classification Consistency

STANDARD held consistently Phase 1 (@architect, binding, with reconciliation rationale against
v2.5.4/v2.6.0 precedent) → Phase 2 (@security, "CONFIRMED — no escalation") → Phase 3 (user gate
approved on STANDARD). @pm's Phase 0 proposal was explicitly provisional/fail-safe
("SECURITY-SENSITIVE (provisional...)") and was correctly downgraded with documented rationale,
not silently overridden — no inconsistency.

### Auto-Fail Trigger Scan

Scanned `docs/spec.md` (§v2.7.2), `docs/architecture.md` (§v2.7.2 Phase 1), and
`docs/security-review-v2.7.2.md` for "zero issues" / "perfect score" / "100%" / "flawless" /
"luxury" / "premium" / "production-grade" / "enterprise-grade" / "world-class" (case-insensitive)
→ **0 hits, all three docs.** Clean.

### @ux / F2 JIRA-Confluence

@ux: SKIPPED — no UI files (Markdown/YAML/Bash config kit only), consistent with prior cycles
for this project. F2 JIRA/Confluence: SKIPPED — not configured for `claude-cowork-config`
(`registry.json` has no `jira` key for this project). AC-3 (tags/Releases), AC-16/17/18
(Discussions/homepage/social-preview), AC-19 (issue triage) are orchestrator-owned, post-merge —
excluded from this verdict per task scope, not failed.

---

## Issues Found

- [ ] **[BLOCKING — must fix before push]** `.github/ISSUE_TEMPLATE/bug_report.md` lines 25–27
      carry a single trailing space each (MD009), which will fail the `markdown-lint` GitHub
      Actions job on push (the file is in-scope of the job's `**/*.md` glob and not covered by
      `.markdownlintignore`). Fix: strip the trailing space on all 3 lines. Zero content change,
      1 file, ~2-minute fix, no re-review of substance needed — re-run
      `npx markdownlint-cli2 .github/ISSUE_TEMPLATE/bug_report.md` to confirm 0 errors, then this
      cycle is clean for APPROVED.

No other issues found. All 15 in-scope ACs verified PASS with independently re-run commands.
Both Phase 2 MUST-FIXES (S1, S2) and the SHOULD-FIX (S3) confirmed genuinely resolved in the
diff, not merely claimed. Deny-list, competitor-naming, and escalation checks all clean. Rework
rate 0%.

## Verdict

**REJECTED — one trivial, scoped fix required.**

**Not** a rejection of the design, the WS2 gate logic, the security fixes, or the AC coverage —
all of that independently verifies clean. This is a narrow, mechanical CI-lint fix
(`.github/ISSUE_TEMPLATE/bug_report.md`, 3 trailing spaces) that I verified will fail the
`markdown-lint` GitHub Actions check on push. Per CLAUDE.md's merge rule, CI must be fully green
before the user is presented a merge decision — approving now would just push the same failure
one step downstream.

**Exact next step:** route back to @dev (or self-heal via a 1-line trailing-whitespace strip on
`.github/ISSUE_TEMPLATE/bug_report.md:25-27` — outside @qa's scope_allow to write directly) →
re-run `npx markdownlint-cli2` to confirm 0 errors → re-request @qa sign-off (should be a
same-session, single-command re-verification, not a new Phase 5/6/7 pass) → orchestrator pushes
`release/v2.7.2` → opens PR → `gh pr checks` confirmed all-green (including the now-passing
Markdown Lint job) → present merge confirmation to user for MERGE/REJECT decision.

Everything else in this cycle — WS1 version truth, WS2's negative-control-proven CI gate, WS3
promise-string purge, WS4 paper cuts, WS5 SkillRisk KEEP decision, WS6 CoC/issue-template/badges
(save the one lint nit), and the Phase 2→4 security fix loop — is ready to ship as-is.
