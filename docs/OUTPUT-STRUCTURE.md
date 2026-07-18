# Output Structure — Claude Cowork Config

This document describes the files the wizard produces and where they should be placed in the user's Cowork workspace.

## Primary Entry Point

**`CLAUDE.md`** at the repo root is the primary entry point (Layer 1a per ADR-010). When the user opens the `cowork-starter-kit` folder as a Cowork Project, Cowork auto-loads `CLAUDE.md` as system context — no paste required — and the dynamic wizard runs on the first message.

**`project-instructions-starter.txt`** (per preset) is the Layer 1b manual-paste alternative. It is functionally equivalent to the CLAUDE.md auto-load path and is used when a user cannot open the repo folder directly (e.g. creates a fresh Cowork Project and wants preset-flavored onboarding from message one). The user pastes it into Cowork Project Settings > Custom Instructions before any conversation.

After the onboarding interview (dynamic wizard flow defined in CLAUDE.md, deep interview continued via `/setup-wizard`), Cowork generates the remaining output files below.

## Generated Output

After completing the onboarding interview (auto-triggered via `CLAUDE.md` auto-load, or via a pasted `project-instructions-starter.txt`, or explicit `/setup-wizard` invocation), the user's workspace should contain the following files:

```
<your-cowork-workspace>/
|
|-- cowork-profile.md                  # Your answers and selected goal preset (generated)
|-- writing-profile.md                 # Your writing voice calibration (generated, v1.2)
|-- project-instructions-starter.txt   # (present only if Layer 1b path was used)
|
|-- .claude/
|   |-- skills/
|       |-- <skill-name>/
|           |-- SKILL.md               # folder/SKILL.md format (auto-discovers as /<skill-name>)
|
|-- context/
|   |-- about-me.md                    # Fill in your details (template with prompts)
|   |-- working-rules.md               # Pre-filled rules for safe, consistent AI behavior
|   |-- output-format.md               # Pre-filled output preferences for your goal type
|   |-- writing-profile.md             # Goal-appropriate writing voice defaults (v1.2)
|
|-- <goal-specific-folders>/           # Folder structure for your preset
|   |-- (varies by preset — see your preset's folder-structure.md)
|
|-- connector-checklist.md             # Which Cowork connectors to enable and why
|-- SETUP-CHECKLIST.md                 # Manual fallback steps (paste-based path)
|-- skills-as-prompts.md               # Copy-paste fallback if skill upload unavailable
```

## File Descriptions

| File | Format | Source | User Action Required |
|------|--------|--------|---------------------|
| `CLAUDE.md` | Markdown | Shipped at repo root | Auto-loaded by Cowork when folder is opened as a Project (Layer 1a — primary v1.2 entry point) |
| `project-instructions-starter.txt` | Plain text | Pre-built per preset | Optional Layer 1b path: paste into Project Settings > Custom Instructions BEFORE any conversation |
| `cowork-profile.md` | Markdown | Generated from wizard answers | Review (read-only) |
| `writing-profile.md` | Markdown | Generated from writing-profile questions (v1.2) | Review, refine as your voice evolves |
| `.claude/skills/<name>/SKILL.md` | Markdown | Pre-built per preset | Upload as ZIP via Settings > Customize > Skills |
| `context/about-me.md` | Markdown | Template from preset | Fill in your details |
| `context/working-rules.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `context/output-format.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `context/writing-profile.md` | Markdown | Pre-filled per preset (v1.2) | Review, refine during writing-profile questions |
| `connector-checklist.md` | Markdown | Copied from preset | Work through checklist in Cowork UI |
| `skills-as-prompts.md` | Markdown | Copied from preset | Use as copy-paste fallback if skill ZIP upload fails |
| `SETUP-CHECKLIST.md` | Markdown | Copied from repo | Follow step by step |

## Important Notes

- `project-instructions-starter.txt` is plain text, not markdown. It is pasted into Cowork Project Settings > Custom Instructions — not opened as a project file.
- Every `project-instructions-starter.txt` includes the safety rule verbatim: "Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder." Do not remove this line.
- Skill files use `folder/SKILL.md` format (not flat `.md`). This is the Cowork-native format that enables auto-discovery as `/slash-commands` after ZIP upload.
- If skill upload is unavailable, `skills-as-prompts.md` in your preset folder provides all skill content as copy-paste prompt snippets.
- The state machine check in `project-instructions-starter.txt` uses the presence and content of `cowork-profile.md` to detect first vs. returning sessions. Do not delete `cowork-profile.md` after setup.
