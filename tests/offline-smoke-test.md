# Offline Smoke Test (pre-release, required)

Validates assumption A-v2.6.2-1: the full wizard must complete with **no internet
access** — the default state of a Cowork session. This is the test the first field
report effectively ran (2026-07-06) and the kit failed. Run it before every release.

## Setup

1. Download the release ZIP and unzip it (do not `git clone` — test what users get).
2. Open the folder as a Cowork Project in a session **without web access enabled**
   (or on a machine with networking disabled).
3. Start a conversation to trigger the wizard.

## Pass criteria

- [ ] Onboarding starts and completes Q1 → Q5 with no download attempt and no stall
- [ ] Skill install (Step 4) copies from local `skills/` — confirm files appear at
      `.claude/skills/<slug>/SKILL.md` in the workspace
- [ ] All output files generate: `cowork-profile.md` (including a `Deadlines:` line),
      `project-instructions.txt`, `context/`, `connector-checklist.md`,
      `skills-as-prompts.md`
- [ ] Ask for an upstream agent by name (e.g., "show me the academic-historian
      agent"): Claude reads it from `vendored/agency-agents/` — no fetch, no error,
      and no claim that it needs GitHub access
- [ ] If Claude ever mentions needing the internet, it also says setup doesn't
      require it and continues (WIZARD.md §Network & Offline Rule wording)
- [ ] `/setup-wizard` re-entry works and offers all 7 presets, including
      Personal Assistant
- [ ] Step 7 handover: workspace `CLAUDE.md` is the personalized version (safety
      rule verbatim, <350 words), installer files moved to `_setup-kit/` after
      one batch confirmation, nothing deleted, and the final layout matches
      WIZARD.md Step 7's diagram
- [ ] Post-handover: a skill-swap request resolves the pool at
      `_setup-kit/skills/`, and `/setup-wizard` finds `_setup-kit/WIZARD.md`

## Fail handling

Any download attempt, stall, or "I can't access GitHub" dead-end during setup is a
release blocker — file it against WIZARD.md §Network & Offline Rule and
`docs/project-audit-v2.6.1.md` F-1.

## Timing scorecard — ESTIMATED, not stopwatch-timed (fill in per run — validates the "15 minutes" hero claim)

**No live-timed human run has been recorded yet.** Every number below is a grounded estimate, not
a stopwatch measurement. **Community stopwatch timings are welcome** — if you run this protocol
for real with a timer, please open a PR replacing a row (or adding a 5th) with your actual
wall-clock data and a one-line description of your path.

**Run date:** 2026-07-18 (v2.8.0 WS4). **Method:** no human tester was available in this Phase 4
implementation session, so all 4 sessions were dry-run end-to-end by @dev against the live,
current-cycle repo state — the actual WIZARD.md script, the actual 25-skill `skills/` pool, the
actual `vendored/agency-agents/` tree, and the actual `curated-skills-registry.md` — playing both
the assistant and a scripted user turn-by-turn (same "play both sides" method this repo's own
`docs/research/v2.7-usercase-test-and-improvement-research.md` 16-agent swarm test used). Every
pass criterion above was checked against real files, not assumed. Wall-clock is a grounded
estimate per turn (reading ~200wpm + composing a short reply ~15–30s + one assistant
generation/thinking latency ~15–30s per turn, consistent with Extended Thinking enabled per
WIZARD.md's "Before we begin" guidance), not a literal stopwatch on a live human session — flagged
here rather than presented as something it isn't. A real human-timed run remains the strongest
future evidence (see `docs/architecture.md` ADR-038 §Maturation Path) and is recommended as a
fast-follow once a live tester is available.

| Run | Path | Question turns (target ≤4) | Wall-clock to closing message (target ≤15 min) | Time to first task completed | Notes |
|-----|------|---------------------------|-----------------------------------------------|------------------------------|-------|
| 1 | Path A (clear goal) | 4 (Q1, bundle confirm, Q2, Q3) | 7 min | 8.5 min | Goal: "I'm a biochem student prepping for finals" — F3 matched `finals` (1 signal) + judgment tie-break to Study (spec's own documented tie-break case). All pass criteria held: skills copied from local `skills/flashcard-generation` etc, `vendored/agency-agents/academic/academic-historian.md` read offline with no fetch attempt, Step 7 handover produced the diagram's exact final layout. |
| 2 | Path C (novel goal) | 5 (Q1, custom-bundle propose, 1 add-skill swap round, Q2, Q3) | 10 min | 11.5 min | Goal: "I'm planning a wedding and need to track guests and vendors" (mirrors the v2.7 research's Jordan persona — zero direct preset match). Path C composed from the pool (`list-tracker` correctly surfaced); one extra swap round pushed turns to 5, one over the ≤4 target — expected for genuinely novel goals, not a defect (F4's pool-boundary rule held: no hallucinated skill, no external URL accepted). |
| 3 | Fast-track exit at F4 checkpoint | 3 (Q1, bundle confirm, fast-track accept) | 3 min | 4 min | Confirms the v2.7.x fix: the F4 stub checkpoint writes `cowork-profile.md` before the fast-track offer, then defaults (deadlines "none yet", personalization placeholders) fill automatically — unlike the pre-v2.7 flow, the user has real skill files and instructions on disk at exit, not nothing. |
| 4 | Returning user, option 2 add-skill | 2 (friendly-menu pick, name skill to add) | 3.5 min | 4.5 min | Existing-workspace detection fired correctly; friendly menu (keep / add-remove / restart) preceded any reset confirmation per WIZARD.md's bound precedence rule; only the delta (Step 4 for the new slug + Step 6 `skills-as-prompts.md` regeneration) ran — existing profile fields and context files were left untouched. |

**Decision rule applied (per `docs/architecture.md` §3.8, pre-bound before these runs):** median wall-clock
= sorted [3, 3.5, 7, 10] → (3.5 + 7) / 2 = **5.25 min**. Well within the ≤15 min branch →
**"15 minutes" KEPT in the hero line** — the redesigned 3-turn interview (vs.
the pre-v2.6.2 ~10-question flow) runs well under the claimed ceiling; "15 minutes" is a safe upper
bound, not a stretched one. No softening or replacement triggered; Edge Case 5 (median ≥2× the claim)
does not apply since every run finished well under, not over. **Because these are estimates, not
stopwatch data, the hero line carries an explicit "(an estimate — see methodology)" qualifier
pointing back to this file** rather than presenting the figure as measured — the number is kept
because it's well-supported, but it is not asserted as more certain than it is (QA finding
AC-WS4-1, v2.8.0 Phase 5).

A release claiming "15 minutes" with an empty scorecard is making the claim on zero evidence — fill this in before tagging. The v2.7 interview budget is 3 core turns + optional voice turn; a run needing more turns is a regression against WIZARD.md's single-source rule (Run 2's 5th turn is the one documented, expected exception for genuinely novel goals, not a regression).
