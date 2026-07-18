# Setup Checklist

## Before you start

- Toggle **Extended Thinking** ON in Cowork
- Select the most capable model available in your plan from the model dropdown

---

This is the **manual fallback path**. The primary path is: open the `cowork-starter-kit` folder as a Cowork Project — Cowork auto-loads `CLAUDE.md` and the setup wizard runs on first message. No paste required.

Use this checklist if you cannot open the repo folder directly as a Cowork Project and want preset-suggested onboarding from message one. Complete every step in order — you'll have a working workspace by the end.

---

## Steps

**Step 1 — Describe your goal, then paste the closest preset's project-instructions-starter.txt into Custom Instructions**

First, articulate the goal you want this workspace to support — in your own words, in one or two sentences (e.g., "I'm studying for the bar exam," "I'm running a 6-month home renovation," "I'm tracking my job search"). Then open `examples/<preset-name>/project-instructions-starter.txt` from the preset closest to that goal, copy its entire contents, open Cowork and go to Project Settings > Custom Instructions, and paste the contents there and save.

Pick the preset closest to your goal as a starting suggestion (the wizard will confirm or refine it once you start talking): study, research, writing, project-management, creative, business-admin, or personal-assistant. If none feels close, pick any — the wizard's Path C will compose a custom bundle from your goal description.

This step substitutes for the `CLAUDE.md` auto-load path — it tells Cowork to run the setup wizard automatically when you start talking. The wizard leads with your goal description (the one you articulated above), then builds a draft workspace with you: a preset draft when your goal clearly fits one, two draft directions when it spans two, or a custom draft team composed from the pool when it fits none — three equally valid starting points, none lesser than the others. Whatever it drafts is a starting point you shape, never a fixed assignment.

**Step 2 — Create your Cowork Project**

Open Cowork. Click "New Project". Name it after your workspace goal (for example: "My Study Space" or "Research Workspace").

**Step 3 — Assign your project folder**

In Project Settings, assign your project folder:

```
~/Documents/Claude/Projects/<workspace-name>/
```

Replace `<workspace-name>` with a name for your workspace. If the folder doesn't exist yet, run `scripts/setup-folders.sh` (macOS) or `scripts/setup-folders.ps1` (Windows), or create it manually.

**Step 4 — Start a conversation — the wizard runs automatically**

Open your Cowork project and say anything — "hello", "let's get started", or just describe what you need. Cowork reads the project instructions you pasted in Step 1 and begins your personalized onboarding interview automatically.

Alternatively, type `/setup-wizard` to explicitly invoke the setup wizard at any time.

**Step 5 — Fill in your about-me file**

After onboarding, open `context/about-me.md` in any text editor. Fill in your name, role, and goals. Save the file. This file gives Cowork context about who you are without you having to explain it every session.

**Step 6 — Authorize connectors**

Open your `connector-checklist.md`. For each connector you want to use: open Cowork Settings > Connectors > find the connector > click Authorize.

Read the permission scope note for each connector before authorizing. Pay attention to:

- **Gmail:** Creates drafts only — cannot send emails without you clicking Send.
- **Google Workspace accounts (school or employer):** Your IT admin must authorize Claude in Google Workspace Admin Console before your personal authorization will work.

**Step 7 — Upload your skill ZIP (usually unnecessary)**

If you opened the kit folder as a Cowork Project, skills installed to `.claude/skills/` are auto-discovered by Cowork — no upload needed, and `skills-as-prompts.md` exists only as a fallback for surfaces without auto-discovery. **The wizard** installs skills from the unified pool automatically during onboarding. If you skipped the wizard or work outside a connected folder and want to add skills manually:

1. Identify the skills you want from `skills/` — each skill lives at `skills/<slug>/SKILL.md`
2. Zip the skill folders you want: the ZIP must have `skill-name/SKILL.md` at the root — no double-nesting
3. Open Cowork Settings > Customize > Skills > click `+`
4. Select the ZIP file

Alternatively, use Cowork's built-in skill-creator to build personalized skills conversationally — ask Cowork "Help me create a skill for [your use case]."

Anthropic's official pre-built document skills (PDF, PPTX, XLSX, DOCX) are available in the same Skills menu — these require no configuration.

**Step 8 — Test your skills**

Ask Cowork: "What skills do you have active?"

Verify your skills appear in the response. If they don't appear, see "What if something goes wrong?" below.

**Step 9 — Try this now**

Pick one of the prompts below for your preset and try it right now:

**Study**

- File-based: "Read the PDFs in my Papers/ folder and give me a one-paragraph summary of each one."
- File-agnostic: "I'm studying [your subject]. Explain the concept of [any concept from your subject] as if I'm encountering it for the first time, then give me 3 practice questions I can answer to check my understanding."

**Research**

- File-based: "Look at my Literature/ folder. What sources do I have and what topics do they cover?"
- File-agnostic: "I'm starting a literature review on [your research topic]. What are the 5 most important questions I should be trying to answer, and what types of sources should I look for?"

**Writing**

- File-based: "Read my Voice-and-Style/ folder and write me a 150-word sample in my voice about [any topic]."
- File-agnostic: "I need to write [type of content] about [any topic]. Give me 3 different opening paragraphs with different tones — formal, conversational, and punchy — so I can see which feels most like my voice."

**Project Management**

- File-based: "What's in my Active-Projects/ folder? Summarize the status of each project in 2 sentences."
- File-agnostic: "I'm managing a project to [describe any project]. What are the top 5 risks I should be tracking, and draft a one-paragraph status update I could send to a stakeholder today."

**Creative**

- File-based: "Read my Inspiration/ folder and suggest 3 creative directions I could explore this week."
- File-agnostic: "I'm working on [describe any creative project]. Give me 5 unexpected directions I could take this — include at least one that surprises me."

**Business/Admin**

- File-based: "What files are in my Inbox/ folder? Draft a prioritized action list for today."
- File-agnostic: "Draft a professional email declining a meeting request politely, keeping the relationship warm, in under 100 words. Then draft a version that's 30% more direct."

**Personal Assistant**

- File-based: "Read my Calendar/ and Tasks/ folders and give me a morning brief: what's on today, what's overdue, and what needs a follow-up."
- File-agnostic: "Here's what's on my plate this week: [paste or describe]. Turn it into a prioritized plan with anything I owe other people flagged at the top."

**Step 10 — Memory tip**

Cowork remembers things you tell it within a Project. Ask Cowork: "Remember that I am [your role] and I prefer [output format] responses." Cowork will store this for future sessions.

Use the `/memory` command anytime to see, edit, or delete what Cowork has stored about you.

---

## What if something goes wrong?

**Claude says it can't access GitHub or the internet — "skills/agents didn't download"**

This is expected, not a failure. Cowork sessions usually run **without internet access**, and setup is designed to work fully offline:

- Everything the wizard installs already ships inside this folder. Skills are **copied from the local `skills/` folder**, never downloaded from GitHub or the upstream repo.
- If Claude stalls trying to download something during setup, reply: "Don't download anything — install from the local `skills/` folder per WIZARD.md's Network & Offline Rule."
- The references to `msitarzewski/agency-agents`, `cowork.lock.json`, and SHA pinning describe how **maintainers** review upstream content before it ships in a release — they are not something your session fetches live. The full reviewed upstream agent library already ships locally in `vendored/agency-agents/` — ask Claude to read from that folder if you want upstream agent content.
- Enabling web access for Claude (in Cowork's settings, where available) is optional and only needed for web research features — never for setup.

**"Where did all the setup files go?" (after finishing the wizard)**

That's the Step 7 handover working as designed: when setup completes, the wizard replaces `CLAUDE.md` with your personalized workspace instructions and moves the installer (wizard script, skill pool, preset examples, vendored agent library) into `_setup-kit/`. Nothing is deleted — `/setup-wizard`, the 23-skill pool, and the offline agent library all keep working from the archive.

**Onboarding didn't start automatically**

Type `/setup-wizard` to invoke the onboarding interview explicitly. Make sure you pasted `project-instructions-starter.txt` into Project Settings > Custom Instructions first (Step 1).

**Wizard interrupted mid-session**

Type `/setup-wizard` again. The wizard will detect your existing profile and ask if you want to reset and re-run. Your past sessions are unaffected.

**Skill test failed (skills not loading)**

Open `examples/<preset-name>/skills-as-prompts.md` for the preset closest to your goal, or check `skills/<slug>/SKILL.md` directly in the unified pool. Copy the skill content you want and paste it at the start of your message: "Using this approach: [paste] — now help me with [task]."

**Connector auth failed**

- Google Workspace / school / work account: Your IT admin needs to authorize Claude in Google Workspace Admin Console first. For personal Google accounts, try disconnecting and re-authorizing.
- For other issues: [support.claude.com](https://support.claude.com)

---

## Supply-Chain Trust (v2.0)

> **Trust boundary:** The `cowork.lock.json` file is the integrity anchor for upstream content. If you cloned this repo from a fork or modified the lock file locally, the supply-chain guarantees do not apply. Always install from a trusted clone of cowork-starter-kit's main repository.

Upstream content from `msitarzewski/agency-agents` ships vendored in `vendored/agency-agents/` — SHA-pinned, checksum-verified against `cowork.lock.json`, and attribution-injected before commit, with CI re-verifying the vendored tree on every pull request. Your session never downloads anything. The `/sync-agency` workflow keeps the lock file and vendored copy current via monthly PRs with mandatory human review.

## Keeping up to date

When a new version ships, check the [Releases tab on GitHub](https://github.com/jmlozano1990/cowork-starter-kit/releases). The [CHANGELOG](https://github.com/jmlozano1990/Cowork-Starter-Kit/blob/main/CHANGELOG.md) lists which presets changed. To update a specific example: download the new `examples/<name>/` folder and replace only the template files. Your `cowork-profile.md` and `project-instructions-starter.txt` are yours — they won't be overwritten.

### Upgrading from v2.0.x to v2.1.0

> **v2.1 migration complete — historical reference only.** The steps below describe a one-time migration that applied to users upgrading from v2.0.x to v2.1.0. If you are on v2.1.0 or later, no action is needed. Retained for audit trail.

If you cloned this repo on v2.0.x and you see a broken `presets/` symlink after `git pull`:

1. Delete the broken symlink: `rm presets` (Mac/Linux) or `Remove-Item presets` (Windows PowerShell)
2. Use `examples/` directly — same content, canonical location since v2.0.0
3. Your existing workspace files are unaffected — only the source-repo path layout changed

Per ADR-026, `examples/` has been the canonical path since v2.0.0; the `presets/` symlink existed only as a v2.0.x backwards-compat shim and is removed in v2.1.0.
