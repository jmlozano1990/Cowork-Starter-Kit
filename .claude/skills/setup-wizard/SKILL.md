---
name: setup-wizard
description: Run the Cowork workspace onboarding wizard — personalized setup for your goal (study, research, writing, PM, creative, business, personal-assistant)
---

## Setup Wizard

This skill runs the Cowork workspace onboarding interview. **WIZARD.md is the single script source — this file only routes into it.** Locate it at `WIZARD.md` (fresh kit) or `_setup-kit/WIZARD.md` (after the Step 7 handover archived the installer); the same rule applies to `skills/`, `selection-presets.md`, and every other kit path the script references. Never re-ask a field already answered in this session or recorded in `cowork-profile.md`.

**Resume guard:** if `cowork-profile.md` exists with `Status: in-progress`, do NOT reset — resume per WIZARD.md Fallback (recap goal + bundle, continue from the first unanswered field).

**Reset guard:** if `cowork-profile.md` exists with real completed content, first offer the friendly menu: "You already have a workspace set up. 1) Keep it as-is  2) Add or remove skills  3) Start fresh from a new goal". Only option 3 triggers the reset confirmation: "This will reset your profile and re-run onboarding. Your past sessions are unaffected. Confirm? (Yes / No)" — proceed only on Yes; on No, return to the menu.

---

## Interview

Run WIZARD.md from Q1. Use AskUserQuestion buttons when available; otherwise numbered lists, with `**Your answer:**` on its own line.

### Q1 — Goal

> "Welcome! What do you need help with? Describe your goal in your own words — or type 'not sure' for suggestions."

Quoted verbatim from WIZARD.md's canonical Q1 opener (Single-Source Rule) — do not paraphrase it here. If the user is uncertain, defer to WIZARD.md's Uncertainty Fallback (Q1) rather than re-presenting a preset menu in this file.

Route per WIZARD.md Q1 (Path A/B/C, stemmed signals, judgment tie-break). The 7 presets are starting suggestions, not fixed selections.

### Everything after Q1

Follow WIZARD.md in order: F4 bundle customization → profile-stub checkpoint → fast-track offer (exactly once, there) → Q2 (name + role + deadlines, one turn) → safety notice → optional Q3 voice turn → After-Q2 generation steps → Step 7 handover (generate the personalized workspace CLAUDE.md, archive the installer to `_setup-kit/`, offer working folders). The interview is 3 core turns plus the optional voice turn; output format is defaulted from the preset, tools/connectors are asked at point-of-need, and all skills install by copying from the local `skills/` pool — no internet needed (WIZARD.md Network & Offline Rule).

---

## After the interview

`cowork-profile.md` follows the WIZARD.md Step 1 template — the only profile schema. Close with the task-first message (WIZARD.md Closing), using the matching first-task invitation:

- Study: "Your [Subject] study space is ready. Paste something you're studying and I'll turn it into flashcards or notes."
- Research: "Your [Domain] research workspace is ready. Share 2–3 sources and I'll synthesize them."
- Writing: "Your writing space is ready. Paste a paragraph you've written and I'll match your voice, or let's outline something new."
- Project Management: "Your [Role] workspace is ready. Tell me where a project stands and I'll draft your first status update."
- Creative: "Your creative workspace is ready. Give me a half-formed idea and I'll help you develop it."
- Business/Admin: "Your workspace is ready. Forward me the gist of an email you need to write and I'll draft it."
- Personal Assistant: "Your workspace is ready. Tell me what's on your plate this week and I'll organize it."
- Custom (Path C): "[Goal] workspace is ready. [One-sentence invitation using an installed skill on their actual goal.]"

**Skill verification (once, not per skill):** confirm each installed file exists at `.claude/skills/<slug>/SKILL.md` and say so in one line. Cowork auto-discovers these files; `skills-as-prompts.md` is the fallback for surfaces that don't.

Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.
