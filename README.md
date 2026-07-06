Configure your Claude Cowork workspace in 15 minutes — describe your goal, the Dynamic Workspace Architect builds it from vetted, SHA-pinned skills, no code required.

[![CI](https://github.com/jmlozano1990/cowork-starter-kit/actions/workflows/quality.yml/badge.svg)](https://github.com/jmlozano1990/cowork-starter-kit/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.6.1-green.svg)](https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CHANGELOG.md)

---

## Who is this for

- **Students and exam preppers** — set up a study workspace with flashcard generation, note-taking, and research synthesis in one guided session
- **Knowledge workers and analysts** — configure a research or project workspace tuned to your writing voice and goal — no template hunting required
- **Project managers and team leads** — spin up a status-update, meeting-notes, and risk-tracking workspace without touching a config file

---

## How it works

Open this folder as a Cowork Project. Cowork auto-loads `CLAUDE.md` as system context and runs the Dynamic Workspace Architect the moment you start talking — open-ended goal discovery, 3-path skill bundle composition, writing voice calibration, and Q&A customization. Takes about 15 minutes. No terminal required. No paste required.

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
 |                                    |  Routes goal (Path A: preset match,
 |                                    |  Path B: overlap narrowing,
 |                                    |  Path C: from-scratch composition)
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

- Paste `examples/<name>/project-instructions-starter.txt` into Project Settings > Custom Instructions for preset-suggested onboarding from message one. The wizard will still run dynamic goal discovery — presets are starting suggestions, not fixed selections.
- Type `/setup-wizard` inside any Cowork project to invoke the wizard explicitly.

---

## Quick start

- Toggle **Extended Thinking** ON in Cowork before you start
- Select **Opus 4.x** in the model dropdown

1. **[Download ZIP](https://github.com/jmlozano1990/cowork-starter-kit/archive/refs/heads/main.zip)** — unzip anywhere on your computer
2. Open Claude Cowork → create a new Project → point it at the unzipped folder
3. Start talking — the wizard runs automatically

That's it. Cowork reads the project instructions and walks you through personalized setup.

**Setup works fully offline.** Everything the wizard installs ships inside the ZIP — skills are copied from the local `skills/` folder, never downloaded. If Claude mentions it can't reach github.com or the internet during setup, that's normal and blocks nothing (see the troubleshooting section in `SETUP-CHECKLIST.md`). Web access is only needed for optional web research features, never for setup.

> **Alternative paths:** Type `/setup-wizard` to run or redo setup explicitly. Or paste `examples/<name>/project-instructions-starter.txt` into Project Settings > Custom Instructions for preset-suggested onboarding from message one.
>
> **No Cowork yet?** Use the manual path: open `SETUP-CHECKLIST.md` and follow every step by hand.

---

## What's included

You don't need to know which preset fits your goal — the wizard figures it out. Here are three examples:

| Goal you describe | What the wizard builds |
|-------------------|----------------------|
| "I'm a biochemistry student studying for finals" | Study workspace — flashcard generation, note-taking, research synthesis, academic writing profile |
| "I'm managing a job search and want to track applications" | Career Manager workspace — application tracker, interview prep, resume tailor, professional writing profile |
| "I want to plan a home renovation and stay organized" | Project workspace — task tracking, stakeholder updates, decision log, direct communication writing profile |

The 7 selection presets are starting suggestions — the wizard uses them as scaffolds when your goal matches closely (Path A), narrows across overlapping presets with a follow-up question (Path B), or composes a custom bundle from the unified skill pool when no preset fits (Path C).

### Goal presets

You describe your goal in plain language. The wizard routes to the closest preset suggestion, narrows between overlapping presets, or composes a custom bundle if nothing fits. These are the 7 selection presets it can suggest:

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
- `.claude/skills/<skill-name>/SKILL.md` — 3 deprecation-stub skills (canonical versions live in the unified `skills/` pool)

### Highlights

**v2.4 highlights:**

- **Dynamic Workspace Architect** — open-ended goal discovery replaces preset menus. The wizard routes your description through 3 paths: Path A confirms a close preset match, Path B narrows overlapping presets with one follow-up question, Path C builds from scratch using the unified skill pool.
- **Unified skill pool** — 21 skills (`skills/<slug>/SKILL.md`) consolidated from former per-preset folders into a single canonical source. The wizard composes your bundle from this pool regardless of which path it takes.
- **Selection presets as suggestions** — 7 named presets in `selection-presets.md` are starting templates the wizard suggests, not exclusive choices. Users confirm and customize from there.
- **Q&A bundle customization** — after proposing a skill bundle, the wizard offers add/remove suggestions (≤3 at a time). You confirm when done. No batch-install surprises.
- **ADR-024 attribution preserved** — every skill installed from the pool includes a verified attribution block. No skill installs without it.

Earlier highlights (v1.2):

- **Writing profile for every workspace** — 3–4 questions calibrate Cowork to your voice. Every workspace ships with a goal-appropriate `writing-profile.md`.
- **Curated skills registry** — `curated-skills-registry.md` lists vetted skills with descriptions, source URLs, and goal tags. Advanced users can opt into Tier 2 community skill discovery with built-in safety checks.
- **Paste-and-go setup** — paste `project-instructions-starter.txt` into Project Settings > Custom Instructions for preset-suggested behavior from message one.
- **Proactive skills** — Cowork offers flashcards when you share study material, suggests synthesis when you reference multiple sources, drafts status updates when a deadline is near.
- **`/setup-wizard`** — explicit command to run or redo setup anytime.

---

## How to extend

Want to go deeper? Three paths:

- **Add a preset** — copy `templates/preset-template/` and follow the guide in [`CONTRIBUTING.md`](https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CONTRIBUTING.md). Your new preset joins the wizard's suggestion pool.
- **Explore the architecture** — `docs/architecture.md` contains all ADRs and Phase 1 design records from v1.0 to present.
- **Author a skill** — start from `templates/skill-template/` for the 9-section format the wizard installs.

---

## Safety first

Every preset includes a non-negotiable rule: **Cowork will always ask for your confirmation before deleting, moving, or overwriting any file or folder.** This rule is built into every workspace this wizard generates and is enforced by CI on every community contribution.

---

## Supply-Chain Integrity (v2.0)

v2.0 ships a supply-chain lock file (`cowork.lock.json`) that SHA-pins all upstream content from `msitarzewski/agency-agents`. The wizard installs only allowlisted, checksum-verified, attribution-injected files. The `/sync-agency` CI workflow opens a PR on every upstream SHA bump — no content reaches users without human review.

> **Trust boundary:** The `cowork.lock.json` file is the integrity anchor for upstream content. If you cloned this repo from a fork or modified the lock file locally, the supply-chain guarantees do not apply. Always install from a trusted clone of cowork-starter-kit's main repository.

## What's new in v2.5

v2.5.0 ships: ADR-028 `content_sha256` integrity field (all 110 lock entries backfilled + CI cross-check), `tools:` SKILL.md frontmatter with MF-3 vocab gate, the first outbound skill contribution ([meeting-notes → agency-agents#521](https://github.com/msitarzewski/agency-agents/pull/521)), MF-1/MF-2 CI hardening (`set -o pipefail` + structural awk header scan replacing positional `$7`), and local markdownlint pre-commit installer.

**Next up (v2.7+):** Multi-tool skill authoring — individual skills widened beyond the default tool, with structured routing intent.

---

## Staying up to date

This repo uses [semantic versioning](https://github.com/jmlozano1990/cowork-starter-kit/releases). When a new version ships, check the [Releases](https://github.com/jmlozano1990/cowork-starter-kit/releases) tab. The [CHANGELOG](https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CHANGELOG.md) lists which presets changed. To update: download the new preset folder and replace only the template files. Your `cowork-profile.md` and `project-instructions-starter.txt` are yours and are never overwritten.

---

## Contribute a preset

Want to add a preset for a use case not covered here? See [CONTRIBUTING.md](https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CONTRIBUTING.md) — the templates/preset-template/ folder gives you a ready-to-fill scaffold. All contributions require a DCO sign-off and pass CI automatically.

---

## Star this repo

If this saved you setup time, a star helps other Claude Cowork users find it.

---

## Credits / Attribution

MIT — see LICENSE.

Upstream skill content sourced from [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) (MIT). Full third-party notices in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

Want to contribute? See [CONTRIBUTING.md](https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CONTRIBUTING.md).
