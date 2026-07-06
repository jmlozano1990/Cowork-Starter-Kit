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
