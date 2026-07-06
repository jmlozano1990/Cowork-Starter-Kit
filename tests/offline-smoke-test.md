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

## Fail handling

Any download attempt, stall, or "I can't access GitHub" dead-end during setup is a
release blocker — file it against WIZARD.md §Network & Offline Rule and
`docs/project-audit-v2.6.1.md` F-1.

## Timing scorecard (fill in per run — validates the "15 minutes" hero claim)

| Run | Path | Question turns (target ≤4) | Wall-clock to closing message (target ≤15 min) | Time to first task completed | Notes |
|-----|------|---------------------------|-----------------------------------------------|------------------------------|-------|
| 1 | Path A (clear goal) | | | | |
| 2 | Path C (novel goal) | | | | |
| 3 | Fast-track exit at F4 checkpoint | | | | |
| 4 | Returning user, option 2 add-skill | | | | |

A release claiming "15 minutes" with an empty scorecard is making the claim on zero evidence — fill this in before tagging. The v2.7 interview budget is 3 core turns + optional voice turn; a run needing more turns is a regression against WIZARD.md's single-source rule.
