# QA Report — v2.8.1 "Demo Story Truthfulness"

## Phase: 5+6+7 (Combined — v2.5.4-precedent path, STANDARD)
## Date: 2026-07-18T14:11:48Z
## Status: APPROVED

---

## Scope Under Review

Branch `release/v2.8.1`, HEAD `491ad18` (1 commit over `main` @ `79a8ae4`, NOT pushed at time of review).

`git diff --name-only main...release/v2.8.1` = exactly 4 files:

```
CHANGELOG.md
README.md
VERSION
assets/setup-demo.svg
```

No rider changes. Each file's diff independently inspected (`git diff main...release/v2.8.1 -- VERSION README.md CHANGELOG.md` and the full `assets/setup-demo.svg` diff): VERSION is a single-line bump, README.md touches only the version badge line, CHANGELOG.md only inserts the new `[2.8.1]` section above `[2.8.0]`, and `assets/setup-demo.svg` is the declared full storyboard rewrite. **Diff audit: PASS — no undeclared files, no incidental edits.**

All independent verification below was re-run from the branch by @qa (`git -C /home/user/claude-cowork-config show release/v2.8.1:<path>` and `git -C /home/user/claude-cowork-config diff main...release/v2.8.1`) — none of it trusts @dev's Phase 4 narrative.

---

## Phase 5 — Testing

### HARD GATE (a) — Traceability

**7-beat byte-compare against the Phase 3 binding storyboard** (pipeline.md `## v2.8.1 Phase Log` → `3. User Gate` row). Dialogue text was extracted programmatically from the committed SVG (`<text class="textAssistant|textUser">` nodes, in document order) and diffed against the binding string, split on the binding's `/` line-break markers:

| Beat | Speaker | Binding (Phase 3 gate) | Committed SVG | Match |
|------|---------|------------------------|----------------|-------|
| 1 | COWORK | "Welcome! What do you need help with? / Describe your goal in your own words." | "Welcome! What do you need help with?" + "Describe your goal in your own words." | EXACT |
| 2 | YOU | "I'm a biochem student prepping for finals" | "I'm a biochem student prepping for finals" | EXACT |
| 3 | COWORK | "That sounds like Study — your team: / Flashcard Generation, Note-Taking, / Research Synthesis. Sound right?" | "That sounds like Study — your team:" + "Flashcard Generation, Note-Taking," + "Research Synthesis. Sound right?" | EXACT |
| 4 | YOU | "Yes, let's go" | "Yes, let's go" | EXACT |
| 5 | COWORK | "Saved. Last question — your name, what / you're working toward, any deadlines?" | "Saved. Last question — your name, what" + "you're working toward, any deadlines?" | EXACT |
| 6 | YOU | "Alex — studying for the MCAT, no deadlines yet" | "Alex — studying for the MCAT, no deadlines yet" | EXACT |
| 7 | COWORK | "Your workspace is ready. / ✓ flashcard-generation  ✓ note-taking / + your personalized CLAUDE.md / Setup kit archived in _setup-kit/ — / your folder holds only your files." | "Your workspace is ready." + "✓ flashcard-generation  ✓ note-taking" + "+ your personalized CLAUDE.md" + "Setup kit archived in _setup-kit/ —" + "your folder holds only your files." | EXACT (incl. the double space before ✓ in beat 7, and both em-dashes) |

**15/15 dialogue lines byte-identical to the gate-approved binding, including the two-space gap in beat 7 line 2 and every em-dash.** No fast-track menu beat present (correctly dropped per binding). Fast-track menu beat removal is why beat count went 6→7 while turn count stayed the same (see WIZARD.md cross-check below).

**WIZARD.md line-citation verification** (`git show release/v2.8.1:WIZARD.md`, 395 lines):

| Beat | Cited source | Verified content at cited location |
|------|--------------|-------------------------------------|
| 1 | WIZARD.md:44 | `> "Welcome! What do you need help with? Describe your goal in your own words — or type 'not sure' for suggestions."` — under `### Q1 — Goal discovery` (line 40). SVG paraphrase drops the "or type 'not sure'" branch-instruction clause, which is correct for a synthetic happy-path demo (that clause is a fallback, not core dialogue). PARAPHRASE-TRACES. |
| 2 | (answers beat 1) | Beat 2 is the user's answer to beat 1's open question — no separate citation needed, correctly the immediate next turn. |
| 3 | WIZARD.md §F3 tokenization / Path A (lines 50–101) | Path A template (line ~78): `"That sounds like **[Preset Name]** — is that right? Your core skills would be: [core_skill 1], [core_skill 2], [core_skill 3]."` SVG folds "is that right?" → "Sound right?" and "core skills would be" → "your team:" — condensation, not fabrication. Skill names cross-checked against `selection-presets.md` Study preset: `core_skills: flashcard-generation, note-taking, research-synthesis` → SVG shows "Flashcard Generation, Note-Taking, Research Synthesis" — **exact match to the real preset data**, not invented content. PARAPHRASE-TRACES. |
| 4 | (answers beat 3) | Direct confirmation of beat 3's question. Correct. |
| 5 | WIZARD.md:136–151 | `### Q2 — Name, role, and deadlines (one turn)` at line 136, quote block at lines 141–151: "Almost done — three quick things in one go: 1. What's your name... 2. [context question]... 3. Any deadlines...". SVG condenses the 3-part single turn into one line, preserving "one turn" semantics (interview budget rule at line 154 confirms Q2 is deliberately one turn, not three). PARAPHRASE-TRACES. |
| 6 | (answers beat 5) | Direct answer to Q2. Correct. |
| 7 | WIZARD.md:313 (closing) + :281–285 (Step 7b) | Closing message (line 313): "Setup complete. Your workspace now contains only your files — the setup kit is archived in `_setup-kit/` (nothing was deleted)..." Step 7b (line 281–285): "I'll move the setup machinery into `_setup-kit/` so your workspace contains only your files." SVG: "Your workspace is ready... Setup kit archived in _setup-kit/ — your folder holds only your files." — direct paraphrase of both cited passages, correctly fuses the closing message with the Step 7b handover as the Phase 0 requirement demanded (the demo discoverability gap). PARAPHRASE-TRACES. |

**Q&A adjacency check:** every YOU line answers the immediately preceding COWORK question (2↔1, 4↔3, 6↔5) — confirmed by re-reading beat order in the file; groups appear in document order b1→b7 with no reordering via CSS/transform.

**Gate (a) verdict: PASS.**

---

### HARD GATE (b) — Inert SVG

All checks run against the **committed blob** (`git show`), not the working tree, though the working tree is confirmed identical (`git status` = clean).

```
$ git -C /home/user/claude-cowork-config show release/v2.8.1:assets/setup-demo.svg | grep -Eic '<script|foreignObject|on[a-z]+=|href='
0
(grep exit code 1 = no match = PASS)
```

**Negative control** (proves the check can fail — per `check-that-cannot-fail`): copied the file to a scratch path under `/tmp/claude-1000/.../scratchpad/` (never committed, never touches the repo), injected `onload="alert(1)"` into the root `<svg>` tag, re-ran the identical grep:

```
$ grep -Ei '<script|foreignObject|on[a-z]+=|href=' setup-demo-NEGCONTROL.svg
<svg onload="alert(1)" viewBox="0 0 800 740" ...>
(grep exit code 0 = match found = neg-control correctly FAILS)
```

**XML well-formedness** (`xmllint` not installed in this environment — confirmed via `which xmllint` → not found; fell back to `python3 xml.dom.minidom`, same fallback @dev used):

```
$ python3 -c "import xml.dom.minidom as m; d=m.parse('setup-demo-v281.svg'); print('WELL-FORMED:', d.documentElement.tagName)"
WELL-FORMED: svg
```

**External resource references** — refined grep (excludes the mandatory `xmlns="http://www.w3.org/2000/svg"` namespace declaration, which is a URI identifier, not a fetched resource):

```
$ grep -Ein '<image|<use|@import|url\(|xlink:href' setup-demo-v281.svg
(no output, exit 1 = PASS)
```

Only `http://` occurrence in the file is the SVG namespace URI on line 1 — confirmed via `grep -noE '.{20}https?://[^"]*.{0,20}'`, single hit, namespace declaration only. Font stack is `"SFMono-Regular", Consolas, monospace` — local system fonts only, no `@font-face`, no remote font loading.

**Gate (b) verdict: PASS** (0 hits, can-fail proven, well-formed, no external refs).

---

### HARD GATE (c) — Version Consistency

Replicated `.github/workflows/quality.yml`'s `version-consistency-check` job (lines 1184–1244) logic verbatim against files extracted from `release/v2.8.1` via `git show` into a scratch directory (not the CI action itself — this environment has no GitHub Actions runner — but the identical shell logic, same extraction regexes, same comparison).

**Positive run** (against release/v2.8.1 content):

```
version-consistency-check PASSED — VERSION == README badge == CHANGELOG top == 2.8.1
```

`VERSION` = `2.8.1`; README badge regex `version-\K[0-9]+\.[0-9]+\.[0-9]+(?=-green)` = `2.8.1`; CHANGELOG top header regex `^## \[\K[^\]]+` = `2.8.1` (top section is `## [2.8.1] - 2026-07-18`, a real dated release header, not `[Unreleased]`).

**Negative control** (VERSION overwritten to `9.9.9` in an isolated scratch copy, README/CHANGELOG left at 2.8.1):

```
::error::version drift — VERSION='9.9.9', README badge='2.8.1', CHANGELOG top='2.8.1'. All three must agree.
version-consistency-check FAILED — see errors above.
(exit 1 — neg-control correctly FAILS)
```

**Gate (c) verdict: PASS** (both directions confirmed).

---

### HARD GATE (d) — No Competitor Naming

```
$ git -C /home/user/claude-cowork-config diff main...release/v2.8.1 > v281.diff
$ grep -Ein 'cursor|windsurf|copilot|replit|bolt\.new|v0\.dev|lovable|lindy|langflow|dify|n8n|zapier|make\.com|crewai|autogpt|babyagi|superagent|flowise|agentgpt' v281.diff
(no output, exit 1 = PASS)
```

Also confirmed Snyk/PromptArmor/agency-agents attribution (allowed research citations per the task) do not even appear in this diff — out of scope for a demo-storyboard patch, as expected.

**Gate (d) verdict: PASS.**

---

### Additional Verification — Animation Timing

Parsed `@keyframes` blocks programmatically (not eyeballed):

| Beat | Entrance | Hold-end |
|------|----------|----------|
| b1 | 3% | 94% |
| b2 | 18% | 94% |
| b3 | 30% | 94% |
| b4 | 42% | 94% |
| b5 | 54% | 94% |
| b6 | 66% | 94% |
| b7 | 78% | 94% |

- Entrances strictly increasing: 3 < 18 < 30 < 42 < 54 < 66 < 78 — **CONFIRMED** (12-point spacing, consistent cadence).
- All 7 beats hold to exactly 94% — **CONFIRMED** (single value set: `{94}`).
- Single infinite loop: one shared `.beat` class rule (`animation-duration: 32s; animation-iteration-count: infinite;`) applied to all 7 `<g class="beat bN">` groups — not 7 separate duration/iteration declarations. **CONFIRMED single loop declaration.**
- No beat-to-beat bubble overlap: extracted each beat's label-y and rect (y, height), computed region tops/bottoms. Beat N's rect bottom vs beat N+1's region top: gap is a constant 10.0px across all 6 adjacent pairs (140→150, 214→224, 330→340, 404→414, 498→508, 572→582). **Zero overlaps.**

### Additional Verification — Geometry

viewBox = `0 0 800 740`. Last beat (b7) bottom edge = 600 (rect y) + 132 (rect height) = 732. `732 ≤ 740` — **within viewBox, 8px margin.** Tight but valid; matches the Phase 3 binding's "viewBox height grows as needed" instruction (660→740, +80 to accommodate the 5-line beat 7 vs. the old 3-line beat 6).

### Additional Verification — markdownlint

CI pins `DavidAnson/markdownlint-cli2-action@05f32210e84442804257b2a6f20b273450ec8265 # v19.1.0` (markdownlint-cli2). Ran the equivalent CLI locally against the branch's working tree (confirmed identical to `release/v2.8.1` HEAD via clean `git status`):

```
$ npx markdownlint-cli2@0.18.1 README.md CHANGELOG.md
Summary: 0 error(s)
```

**Self-tested the tool before trusting the green result** (MD009 trailing-whitespace bit the project in v2.7.2 per project history): built a scratch file with trailing spaces, ran the same tool/config, confirmed it fires:

```
bad.md:3:31 MD009/no-trailing-spaces Trailing spaces [Expected: 0 or 2; Actual: 3]
(exit 1 — tool correctly detects violations)
```

**markdownlint verdict: PASS, 0 violations, tool self-tested as capable of failing.**

### Unit Tests

- Total: 0 (asset/copy-only cycle — no `lib/core` or equivalent logic surface touched)
- Passing: 0
- Failing: 0

### E2E Tests

- Total: 0 (no functional/wizard behavior change — SVG is a static presentational asset)
- Passing: 0
- Failing: 0

### @ux — SKIPPED

Rationale: single inert marketing/demo asset (SVG storyboard timing + text), no product UI/CSS/component surface, no user-facing application screen. Recorded per task instruction; not a Phase 5 gap.

### Classification Signal

**STANDARD** — confirmed independently. Diff touches only `assets/setup-demo.svg` (presentational, inert-verified), `VERSION`, `README.md` (badge line only), `CHANGELOG.md` (new entry only). No auth surface, no CI/workflow diff (`git diff main...release/v2.8.1 -- .github/` = 0 lines), no new dependency, no RLS/schema/secret/permission surface, no wizard behavior change.

---

## Phase 6 — Abbreviated Security Audit (STANDARD inline, combined-path)

| Check | Result | Evidence |
|-------|--------|----------|
| New auth surface | NONE | Diff = 4 files, none touch auth/permission code |
| New dependencies | NONE | No manifest/lock file in diff |
| CI workflow changes | NONE | `git diff main...release/v2.8.1 -- .github/workflows/` = 0 lines |
| Secret/permission surface | NONE | No workflow, script, or config file touched |
| SVG active-content surface | CLOSED | Gate (b) above — 0 hits, can-fail proven, well-formed, no external refs |
| Competitor naming | NONE | Gate (d) above — 0 hits |
| Deny-list violation (WIZARD.md/skills/CI/etc.) | NONE | Diff name-list = CHANGELOG.md, README.md, VERSION, assets/setup-demo.svg only — none of the 14 deny-listed classes from prior cycles touched |
| Classification cross-check | STANDARD confirmed | No auth/payment/permission/RLS/migration signal anywhere in the Phase 4 diff |

**Verdict: STANDARD classification holds. 0 security findings. No Guard Change Summary required (no guard/settings/pipeline-policy/agent-scope surface — this is an external registered project, not The-Council itself).**

---

## Phase 7 — Final Approval

### ADR-100 Flip-to-APPROVED Checklist

**1. Test output excerpt:**

```
Traceability: 15/15 dialogue lines byte-exact to Phase 3 binding; 7/7 beats WIZARD.md-cited and verified
Inert-SVG grep: 0 hits (exit 1) + negative control confirmed exit 0 on injected onload=
Version-consistency: PASSED 2.8.1==2.8.1==2.8.1 + negative control confirmed FAILED on VERSION=9.9.9
No-competitor-naming: 0 hits in diff
markdownlint: 0 error(s) on README.md + CHANGELOG.md, self-tested via MD009 negative control
Animation: 7 strictly-increasing entrances (3/18/30/42/54/66/78%), uniform 94% hold, single 32s infinite loop, 0 beat overlaps (constant 10px gaps)
Geometry: last bubble bottom 732 ≤ viewBox height 740
Diff audit: exactly 4 declared files, no rider changes
```

**2. Cycle-tier evidence:**
Tier: **Infra/config-adjacent presentational asset** (closest match: docs/config copy-only tier — no `src/`, no `lib/core/`, no `.github/workflows/`, no `package.json`/dependency surface touched). Before/after diff narrative: old SVG (viewBox 800×660, 6 beats, 28s loop) opened with the user speaking first and buried Q2 immediately after an undisplayed fast-track menu beat — both defects independently reproduced by re-reading the pre-image diff (`git diff main...release/v2.8.1 -- assets/setup-demo.svg`, removed-lines side: Beat 1 was `class="beat b1"` containing a `bubbleUser`/YOU label, confirming the "user speaks first" defect existed exactly as the CHANGELOG describes). New SVG (800×740, 7 beats, 32s loop) opens with COWORK, shows Q2 as its own beat, and surfaces the Step 7b handover. All invariants (inertness, well-formedness, version-consistency, no-competitor-naming) held across the change.

**3. Spec-to-code cross-reference:**

- HARD GATE (a) traceability: 15/15 line table above, file `assets/setup-demo.svg` (git blob at `release/v2.8.1`), WIZARD.md line citations verified at :44, :50–101 (Path A ~:78), :136–151, :281–285, :313. PASS.
- HARD GATE (b) inert SVG: grep evidence + negative control above. PASS.
- HARD GATE (c) version-consistency: replicated CI job, positive + negative control above. PASS.
- HARD GATE (d) no-competitor-naming: grep evidence above. PASS.
- Animation/geometry/markdownlint/diff-audit: all PASS, evidence above.

**4. Prior-cycle carry-forwards confirmed/deferred:**
No open carry-forwards apply to this patch's scope. Pre-existing CARRY-FORWARD items from v2.8.0 (sync-agency-dry-run PATTERN_COUNT gate never firing since v2.0.0; WS7 social-preview manual check) are unrelated to this cycle's 4-file scope and remain correctly parked for Phase C (v2.9.0) per the v2.8.1 Requirements row's explicit "out of scope" list.

### Layered Verification — @dev's 4 Disclosed Deviations (all independently re-checked, not trusted from narrative)

1. **Unpushed amend (stray char).** `git reflog show release/v2.8.1` shows `491ad18 ... commit (amend)` over a prior local `3f842c4`, both on a branch never pushed (confirmed: `git status` on `release/v2.8.1` shows no upstream tracking issue and the task brief states "NOT pushed"). Amending a not-yet-pushed, not-yet-reviewed local commit is standard practice, not a rewritten-shared-history violation. **Benign — confirmed correct.**
2. **xmllint fallback.** `which xmllint` → not found in this environment. @qa independently hit the same absence and used the same `python3 xml.dom.minidom` fallback, which succeeded (`WELL-FORMED: svg`). **Benign — confirmed correct, and independently reproduced, not merely trusted.**
3. **README alt/caption left unchanged — reviewed, non-contradictory.** Read README.md lines 15 and 17 directly from `release/v2.8.1`: alt text says "...answer three quick turns, and get a working, personalized workspace with installed skills"; caption says "A synthetic demo of the real 3-turn interview: describe a goal, confirm a skill bundle, answer one quick turn, and land on a personalized workspace with skills already installed." Both describe **3 user turns** (goal → bundle-confirm → Q2 answer), which the new 7-beat storyboard still delivers (beats 2, 4, 6 are the 3 YOU turns; the extra COWORK beats are turn-framing, not additional user turns). Caption's phrase-by-phrase mapping (describe a goal→beat 2, confirm a skill bundle→beat 4, answer one quick turn→beat 6, land on personalized workspace→beat 7) is exact. **No contradiction — confirmed correct disposition.**
4. **"Next up" teaser — reviewed, not stale.** Only one "Next up" instance in README.md (line 191): "External skill install support — wizard-managed installs from the vendored upstream library, plus multi-tool skill authoring with structured routing intent." This sits under `## What's new in v2.7` (a historical section, not v2.8.1-specific) and describes unrelated future roadmap scope (skill installs), with no reference to the demo storyboard this cycle touches. **Not stale — confirmed correct disposition.**

### Rework Rate

- Phase 4 final SHA: `491ad18`
- Current HEAD (pre-qa-report-commit): `491ad18` (same)
- `git diff 491ad18 HEAD -- .` = 0 lines
- **Rework rate: 0%**

### Auto-fail Trigger Scan

Scanned this report and the Phase 4/Phase 3 pipeline.md prose for: "zero issues", "perfect score", "100%", "flawless", "production-grade", "enterprise-grade", "world-class", "luxury", "premium" (case-insensitive, whitespace-normalized). Result: 0 matches outside of legitimate technical context (e.g., "0 hits", "0 violations" are measured counts with evidence attached, not the banned superlative phrasing). **CLEAN.**

### Classification Cross-check

Phase 5 classification: STANDARD. Phase 7 re-check: no auth, payment, permission, RLS, or migration signal anywhere in the Phase 4 diff (4 files: CHANGELOG.md, README.md, VERSION, assets/setup-demo.svg — none is a code/schema/auth surface). **STANDARD confirmed throughout. Full Phase 6 audit escalation not triggered.**

### Public Artifact Audit (v0.14.0 / ADR-110 bump-type gate)

`bump_type` = **patch** (2.8.0 → 2.8.1, only the patch digit increased per CHANGELOG.md and VERSION). Per the auto-invoke rule, this **SKIPS** the G1 public artifact audit and the 5-category enumeration entirely.

```
Public artifact audit: SKIPPED — bump_type=patch — artifact audit not required for patch bumps.
```

### Privacy-Scrub Dry-Run

`scripts/privacy-scrub.sh` does not exist in this project (`find /home/user/claude-cowork-config -iname "privacy-scrub*"` = no results; this is a Council-self-improvement tooling script, not present in registered external projects).

```
Privacy-scrub dry-run: SKIPPED — scripts/privacy-scrub.sh not present.
```

Does not block APPROVED.

### Worktree Commit Topology

```
Worktree commit topology: SKIPPED — classification STANDARD (no worktree required for this patch cycle).
```

### .gitattributes Export-Ignore Confirmation

Confirmed while reviewing the repo: `.gitattributes` contains `docs/internal/          export-ignore` (directory-prefix DROP rule, v2.8.0 ADR-037 convention). This qa-report is being written to `docs/internal/qa/qa-report-v2.8.1.md`, which is covered by that rule and will not ship in `git archive` release ZIPs — matching the established convention used by all 12 prior `docs/internal/qa/qa-report-v*.md` files in this repo.

### Issues Found

None.

### qa_issues_prevented

- blocker: 0
- issue: 0
- info: 0

Note: the meaningful interventions this cycle happened upstream of Phase 5 — Phase 0 interactive requirements gathering caught the narrative defect from an owner screenshot review, and the Phase 3 gate bound the exact 7-beat dialogue text before implementation. Phase 5–7 independently re-verified that the implementation matched that binding exactly; nothing new was caught at this layer, which is itself the expected/correct outcome for a well-gated patch cycle, not evidence of a weak QA pass (every hard gate + additional check was independently re-run from the committed artifact, including two negative controls proving those checks can fail).

---

## Completion Report

**v2.8.1 "Demo Story Truthfulness" — Phase 7 Completion**

**What shipped:** `assets/setup-demo.svg` rewritten from a 6-beat storyboard (viewBox 800×660, 28s loop) that opened with the user speaking first and buried an unshown Q2 after a fast-track menu beat, to a 7-beat storyboard (viewBox 800×740, 32s loop) that opens with Cowork's real Q1, shows Q2 as its own beat, and closes by surfacing the Step 7b `_setup-kit/` clean handover — a feature that already shipped in v2.7 but that the owner didn't know existed until this demo review. VERSION/README badge/CHANGELOG bumped to 2.8.1.

**What was tested:** All 4 hard gates (traceability, inert-SVG, version-consistency, no-competitor-naming) independently re-run from the committed branch with negative controls proving 3 of the 4 mechanical checks can actually fail (traceability is a byte-compare, not a boolean gate — its "negative control" is the documented pre-image diff showing the old, wrong content). Plus animation-timing, geometry, markdownlint (with a self-test), and full diff-audit. Plus independent re-verification of all 4 of @dev's disclosed deviations by reading the cited files directly rather than trusting the Phase 4 narrative.

**Security posture:** STANDARD classification, confirmed at Phase 5 and re-confirmed at Phase 7. Zero new attack surface — single inert presentational asset + version-trio text edit.

**Rework rate:** 0% (Phase 4 HEAD = current HEAD).

**Issues caught by the pipeline that would have shipped without it:** 0 blockers/issues/info at this QA layer — the substantive catch happened at Phase 0 (owner screenshot review surfaced the narrative defect) and Phase 3 (gate bound the exact replacement dialogue before implementation began). QA's role this cycle was independent verification that the binding was honored byte-for-byte, which it was.

**Public artifact audit:** SKIPPED (patch bump).

**Next action for user:** Orchestrator to push `release/v2.8.1` and open a PR (not done by @qa per task instructions — no push performed).

### Verdict

**APPROVED** — all 4 hard gates PASS with evidence and negative controls, animation/geometry/markdownlint/diff-audit all PASS, all 4 disclosed deviations independently confirmed benign, 0% rework, STANDARD classification confirmed, 0 security findings.

---

*Process note (recorded by orchestrator): @qa authored this report in full but was blocked from writing it by the scope guard — the @qa subagent's process tree did not inherit the orchestrator session's project pin, so the guard fail-closed against `registry.active_project=self`. The orchestrator committed this file verbatim as a pipeline-state write (qa-report.md is state, not implementation, per CLAUDE.md worktree-cycle state rules). The pin-inheritance gap is flagged as a Council self-improve candidate in the Phase 8 retro.*
