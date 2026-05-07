# cowork-starter-kit

> Set up your Claude Cowork workspace in 15 minutes. No code. No configuration files. Open the folder in Cowork — the wizard runs automatically.

[![CI](https://github.com/jmlozano1990/cowork-starter-kit/actions/workflows/quality.yml/badge.svg)](https://github.com/jmlozano1990/cowork-starter-kit/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.5-green.svg)](CHANGELOG.md)

---

## The problem

Claude Cowork is powerful — but a blank project is intimidating. Most people never configure it properly, so they get generic answers instead of a workspace tuned for how they actually work.

This fixes that.

---

## How it works

Open this folder as a Cowork Project. Cowork auto-loads `CLAUDE.md` as system context and runs a dynamic onboarding wizard the moment you start talking — open-ended goal discovery, profile, writing voice calibration, then skill activation. Takes about 15 minutes. No terminal required. No paste required.

```
You                                Cowork
 |                                    |
 |  Open the cowork-starter-kit       |
 |  folder as a Cowork Project        |
 | ---------------------------------> |
 |                                    |  Auto-loads CLAUDE.md
 |                                    |  as system context
 |                                    |
 |  Start conversation                |
 | ---------------------------------> |
 |                                    |  "What would you like to use
 |                                    |  this workspace for?"
 |  [your goal in your own words]     |
 | ---------------------------------> |
 |                                    |  Detects goal, proposes scaffold
 |                                    |  (preset if one matches, or
 |                                    |  builds from scratch)
 |                                    |  Asks profile + writing questions
 |  [your answers]                    |
 | ---------------------------------> |
 |                                    |  Generates your workspace:
 |                                    |    cowork-profile.md
 |                                    |    writing-profile.md
 |                                    |    context/ folder
 |                                    |    skill files
 |  "Your workspace is ready."        |
 | <--------------------------------- |
 |                                    |
 |  Type /setup-wizard                |
 | ---------------------------------> |  Explicit fallback — redo setup
```

**Two alternative entry paths** if you can't open the folder directly:

- Paste `examples/<name>/project-instructions-starter.txt` into Project Settings > Custom Instructions for a preset-flavored start from message one.
- Type `/setup-wizard` inside any Cowork project to invoke the wizard explicitly.

---

## Quick start

1. **[Download ZIP](https://github.com/jmlozano1990/cowork-starter-kit/archive/refs/heads/main.zip)** — unzip anywhere on your computer
2. Open Claude Cowork → create a new Project → point it at the unzipped folder
3. Start talking — the wizard runs automatically

That's it. Cowork reads the project instructions and walks you through personalized setup.

> **Alternative paths:** Type `/setup-wizard` to run or redo setup explicitly. Or paste your preset's `project-instructions-starter.txt` into Project Settings > Custom Instructions for preset-specific behavior from message one.
>
> **No Cowork yet?** Use the manual path: open `SETUP-CHECKLIST.md` and follow every step by hand.

---

## What can you build?

You don't need to know which preset fits your goal — the wizard figures it out. Here are three examples:

| Goal you describe | What the wizard builds |
|-------------------|----------------------|
| "I'm a biochemistry student studying for finals" | Study workspace — flashcard generation, note-taking, research synthesis, academic writing profile |
| "I'm managing a job search and want to track applications" | Career Manager workspace — application tracker, interview prep, resume tailor, professional writing profile |
| "I want to plan a home renovation and stay organized" | Project workspace — task tracking, stakeholder updates, decision log, direct communication writing profile |

The 6 presets (Study, Research, Writing, PM, Creative, Business/Admin) are accelerators — the wizard uses them as scaffolds when your goal matches. For anything else, it builds from scratch.

---

## Seven goal presets

You don't pick — you describe your goal in plain language and the wizard picks the right preset (or builds from scratch if nothing fits). These are the 7 scaffolds it can use:

| Preset | Best for | What you get |
|--------|----------|--------------|
| **Study** | Students, exam prep, coursework | Research synthesis, note-taking, flashcard generation |
| **Research** | Academics, analysts, lit review | Literature review, source analysis, synthesis |
| **Writing** | Authors, bloggers, journalists | Voice matching, editing pass, outline generator |
| **Project Management** | PMs, team leads, ops | Status updates, meeting notes, risk assessment |
| **Creative** | Designers, storytellers, strategists | Ideation, creative brief, feedback synthesis |
| **Business/Admin** | Executives, assistants, owners | Email drafting, report summary, action items |
| **Personal Assistant** | Individuals managing daily life | Daily briefing, follow-up tracker, spend awareness |

**Each preset includes:**

- `project-instructions-starter.txt` — optional manual entry path: paste into Project Settings > Custom Instructions for example-specific onboarding without opening the repo folder (functionally equivalent to `CLAUDE.md` auto-load)
- `global-instructions.md` — proactive skill trigger rules (session behavior) with writing profile integration
- `context/about-me.md` — fill in your name, role, and goals
- `context/working-rules.md` — safe defaults (includes confirm-before-delete rule)
- `context/output-format.md` — pre-filled for your preset
- `context/writing-profile.md` — goal-appropriate writing voice defaults (new in v1.2)
- `connector-checklist.md` — which connectors to authorize and why
- `skills-as-prompts.md` — skill content as copy-paste prompts if skill upload is unavailable
- `folder-structure.md` — recommended folder layout for your workspace
- `.claude/skills/<skill-name>/SKILL.md` — 3 preset skills in Cowork-native format

---

## v1.2 highlights

- **Dynamic goal discovery** — the wizard asks your goal in plain language instead of showing a preset menu. If you're not sure what you want, it suggests three concrete directions. If your goal matches a preset, it uses that as a scaffold. If not, it builds from scratch.
- **Writing profile for every workspace** — 3–4 questions calibrate Cowork to your voice, not generic AI. Outputs sound like you. Every workspace now ships with a goal-appropriate `writing-profile.md`.
- **Curated skills registry** — `curated-skills-registry.md` lists 18 vetted skills (3 per preset) with descriptions, source URLs, and goal tags. Advanced users can opt into Tier 2 community skill discovery with built-in safety checks.
- **No-config open** — open the repo folder in Cowork and start talking. `CLAUDE.md` auto-runs the dynamic wizard. No paste required.

Earlier highlights:

- **Paste-and-go setup** — paste `project-instructions-starter.txt` into Project Settings > Custom Instructions before your first conversation for preset-specific behavior.
- **Proactive skills** — Cowork offers flashcards when you share study material, suggests synthesis when you reference multiple sources, drafts status updates when a deadline is near.
- **`/setup-wizard`** — explicit command to run or redo setup anytime.
- **18 auto-discovering skills** — properly formatted as `/slash-commands` (e.g., `/flashcard-generation`, `/voice-matching`).

---

## Safety first

Every preset includes a non-negotiable rule: **Cowork will always ask for your confirmation before deleting, moving, or overwriting any file or folder.** This rule is built into every workspace this wizard generates and is enforced by CI on every community contribution.

---

## Supply-Chain Integrity (v2.0)

v2.0 ships a supply-chain lock file (`cowork.lock.json`) that SHA-pins all upstream content from `msitarzewski/agency-agents`. The wizard installs only allowlisted, checksum-verified, attribution-injected files. The `/sync-agency` CI workflow opens a PR on every upstream SHA bump — no content reaches users without human review.

> **Trust boundary:** The `cowork.lock.json` file is the integrity anchor for upstream content. If you cloned this repo from a fork or modified the lock file locally, the supply-chain guarantees do not apply. Always install from a trusted clone of cowork-starter-kit's main repository.

## Next up — v2.1 Multi-Source Upstream + Wizard FSM Completion

v2.0 ships the Dynamic Workspace Architect (upstream content integration, lock file, allowlist, attribution). v2.0.2 hardens the supply-chain and compliance controls (SHA fix, SPDX comparison, PR template, verbatim-attribution CI, Windows symlink docs). v2.1 will add a second upstream source and complete the Wizard FSM for Riley-class users building cross-functional workspaces.

---

## Staying up to date

This repo uses [semantic versioning](https://github.com/jmlozano1990/cowork-starter-kit/releases). When a new version ships, check the [Releases](https://github.com/jmlozano1990/cowork-starter-kit/releases) tab. The CHANGELOG lists which presets changed. To update: download the new preset folder and replace only the template files. Your `cowork-profile.md` and `project-instructions-starter.txt` are yours and are never overwritten.

---

## Contribute a preset

Want to add a preset for a use case not covered here? See CONTRIBUTING.md — the templates/preset-template/ folder gives you a ready-to-fill scaffold. All contributions require a DCO sign-off and pass CI automatically.

---

## Star this repo

If this saved you setup time, a star helps other Claude Cowork users find it.

---

## License

MIT — see LICENSE.
