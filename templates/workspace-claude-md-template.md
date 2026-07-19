# Workspace CLAUDE.md Template (post-setup handover)

This is the template for the **workspace** `CLAUDE.md` that WIZARD.md Step 7 generates when setup completes. It REPLACES the kit's wizard-bootstrap `CLAUDE.md` in the user's workspace (with explicit confirmation — Safety rule). Fill every `[bracket]` from the interview answers; keep the generated file under 350 words; do not use em dashes (they inflate the CI word count under C.UTF-8).

---

```markdown
# [WORKSPACE NAME] — Cowork Workspace

Setup is complete. This file is your workspace's standing instructions; the setup kit is archived in `_setup-kit/`.

## Who you're working with

- **Name:** [NAME]
- **Role / context:** [ROLE]
- **Goal:** [GOAL, verbatim from setup]
- **Deadlines to track:** [DEADLINES or "none yet"]

## Every session

1. Read `cowork-profile.md`. Greet [NAME] by name; surface any deadline within 7 days.
2. Write in the voice defined by `context/writing-profile.md`; format per `context/output-format.md` (default: [PRESET DEFAULT]; change anytime on request).
3. Skills live in `.claude/skills/` — apply each proactively per its Triggers section. Installed: [SKILL LIST].

## Proactive skill behavior

Apply installed skills proactively based on context; do not wait to be asked. Skill Studio adds an entry here automatically each time it generates and surfaces a new skill (see `.claude/skills/skill-studio/SKILL.md` step 7).

## Skill swap

If [NAME] asks for a capability outside the installed bundle, offer the closest match from the archived pool at `_setup-kit/skills/` (25 skills; suggestions ≤3 at a time) and copy it into `.claude/skills/` on confirmation. The reviewed upstream agent library at `_setup-kit/vendored/agency-agents/` is available to read and adapt offline. Never fetch skills from GitHub or external URLs.

## Re-run or extend setup

Type `/setup-wizard` anytime — the script is archived at `_setup-kit/WIZARD.md` and detects this existing workspace (add/remove skills without resetting).

## Offline

Everything this workspace needs is local. No internet access is required; never treat missing network access as an error.

## Safety

Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.
```
