# User Personas — Claude Cowork Config (v1.2)

## How to Use This Document

These personas are the product's decision filter. Before adding a feature, removing an AC, or changing a preset, ask: does this serve Alex, Maria, Sam, or Jordan? If it serves none of them, it's out of scope.

v1.2 adds **Jordan** — the "I don't know what I want" user — as a canonical fourth persona that drives the dynamic wizard's design. Jordan is not a new user type; Jordan is Alex, Maria, and Sam on their first day.

Personas are derived from: Cowork community guides (2026), user feedback summaries (coworkhow.com), DataCamp tutorial audience analysis, brainstorm session with project owner (2026-04-14), and v1.1 production observations (2026-04-16).

---

## Primary Persona: Alex — The Student

**Name:** Alex Chen
**Age:** 20
**Role:** Junior, biochemistry major
**Cowork plan:** Claude Pro ($20/month)

### Context

Alex switched to Claude Pro after seeing a LinkedIn post about Cowork for students. He's heard Cowork can "read your PDFs and work in your files" but hasn't figured out how to set it up. His study folder is a mess. He knows he should organize it — he just doesn't know how.

He spends 3–4 hours a week re-explaining context to AI tools because there's no persistent memory.

### v1.2 Context: Alex and the Wizard

Alex is the primary design target for the dynamic wizard. He will NOT recognize himself in a preset menu. He will describe his situation in plain language: "I'm trying to get better at keeping up with my readings for biochem." The wizard must map that description to a Study workspace, suggest appropriate skills, and build the folder structure — without Alex needing to know what any of those things are.

Alex is also the primary writing profile test case. He does not think of himself as "a writer" — he writes lab reports and literature summaries. The writing profile wizard must frame this as "I'll help your work sound like how you think, not like a robot summarized your notes."

### Goals (JTBD)

**Functional jobs:**
- Synthesize 15–20 research papers into a coherent literature summary
- Generate flashcards from lecture notes for active recall studying
- Format citations in APA/Chicago without doing it manually
- Find connections between papers he might have missed
- Draft and revise lab reports with academic tone

**Social jobs:**
- Feel like a capable, effective student — not someone who's struggling
- Produce work that impresses professors
- Feel like he's using tools at their full potential

**Emotional jobs:**
- Reduce the anxiety of "I have 12 papers to read and a report due Friday"
- Feel in control of his study process
- Build confidence he can tackle research-heavy assignments independently

### Pains

| Pain | Severity | v1.2 Impact |
|------|----------|-------------|
| Doesn't know how to configure Cowork | High | Dynamic wizard solves — no product knowledge required |
| Re-explains context every session | High | cowork-profile.md + persistent instructions |
| Outputs sound like generic AI (academic integrity concern) | High | writing-profile.md calibrates to his academic voice |
| Doesn't know what skills are or how to find them | Medium | Curated Tier 1 suggestions, no GitHub browsing required |
| Fears breaking something with a wrong command | Medium | Safety rule + confirm before delete |
| Never set up instructions — every output is too generic | High | Dynamic wizard builds instructions from conversation |

### Quote (v1.2 update)

> "I just told it I was trying to keep up with my biochem readings and it figured out I needed a study workspace. I didn't have to pick from a menu or know any of the jargon. And my summaries actually sound like how I explain things, not like a textbook."

### Writing Profile for Alex

- **Tone:** Semi-formal academic (not stuffy, but not casual)
- **Audience:** Professors and lab partners
- **Anti-AI guidance focus:** Avoid passive voice overuse, overly hedged language, generic transitions ("It is important to note...")
- **Workspace-specific:** APA citation conventions, academic integrity framing (support learning, not shortcut)

### Usage Pattern

- Cowork 3–5 times per week for paper synthesis and note organization
- Most valuable: "Read these 8 PDFs and give me a structured summary with key arguments and gaps"
- Fast-track: Will likely use fast-track pause after Step 6 and return for skills later

---

## Secondary Persona: Maria — The Knowledge Worker

**Name:** Maria Santos
**Age:** 35
**Role:** Research analyst at a mid-size consultancy
**Cowork plan:** Claude Max ($100/month)

### Context

Maria has tried every AI tool in the last two years. She's gotten real value from them. She's never fully cracked how to configure them to match her professional standard. Every time she uses Cowork, she pastes 3–4 paragraphs of context before the first task because there's nowhere to store it permanently.

She manages 4–5 active projects at once. She's tried Cowork Projects but hasn't set up per-project instructions because it takes time she doesn't have.

### v1.2 Context: Maria and the Wizard

Maria will arrive knowing roughly what she wants ("something for research and project management") but not knowing how to configure it. The dynamic wizard recognizes her goal as a Research/PM hybrid and proposes a workspace that spans both presets. It then asks the writing profile questions — Maria will be the most engaged with this step, because every output she produces has to sound like a senior analyst, not a chatbot.

Maria is also the primary persona for Tier 2 skill discovery. She'll ask "are there any other skills for analyst workflows?" and opt into advanced search with full awareness of the risk context.

### Goals (JTBD)

**Functional jobs:**
- Produce a structured literature review from 20+ source documents in 90 minutes
- Draft client-ready reports with her firm's standard format
- Triage and prioritize her inbox to the 3 emails needing responses today
- Track deliverable status across multiple projects
- Onboard to a new research topic quickly

**Social jobs:**
- Maintain reputation as a rigorous, fast researcher
- Deliver work that impresses senior partners
- Be the team's AI tool power user

**Emotional jobs:**
- Reduce the "constant context tax"
- Feel like she has a reliable AI assistant, not a generic chatbot
- Trust that Cowork won't modify her client files without approval

### Pains

| Pain | Severity | v1.2 Impact |
|------|----------|-------------|
| Re-explains professional context every session | High | cowork-profile.md + writing-profile.md together eliminate this |
| No per-project instructions — generic output | High | Dynamic wizard builds custom instructions per workspace |
| Outputs don't match professional standard | High | Writing profile with sample analysis captures her firm's style conventions |
| Doesn't know which connectors to prioritize | Medium | Goal-filtered connector checklist |
| 3 half-configured setups from different experiments | Medium | /setup-wizard reset path; fresh start |
| Worried about Cowork modifying client files | High | Safety rule non-negotiable |

### Quote (v1.2 update)

> "The writing profile thing was what sold me. I pasted a paragraph from one of my reports and it said 'I notice you lead with the conclusion and use tight, declarative sentences.' That's exactly right. Now my Cowork outputs actually sound like I wrote them."

### Writing Profile for Maria

- **Tone:** Professional, authoritative, structured
- **Audience:** Senior partners and clients
- **Characteristic patterns:** Executive summary first, tight paragraphs, conclusion before reasoning, footnoted citations
- **Anti-AI guidance focus:** Avoid filler phrases, hedged language, "In conclusion" openers, bullet-point overuse when prose is more authoritative
- **Workspace-specific:** Executive summary format, footnote citation style, "never modify files" rule prominent

### Usage Pattern

- Cowork daily, 1–2 hours per day
- Most valuable: "Read all documents in /Project-Alpha/Research/ and produce a structured synthesis"
- Second most valuable: "Go through my Gmail inbox and identify the 5 emails needing responses this week"
- Will use Tier 2 skill discovery; will read safety warnings carefully before installing

---

## Tertiary Persona: Sam — The Creator

**Name:** Sam Rivera
**Age:** 28
**Role:** Freelance writer / newsletter author
**Note:** Writing and Creative presets. Do not over-optimize wizard flow for Sam at the expense of Alex and Maria.

### Context

Sam's pain is specific and urgent: every Cowork output sounds like generic AI, not like Sam. The writing profile step in v1.2 directly solves Sam's core problem in a way v1.1 could not.

Sam will be the most deliberate writing profile user — they will provide a writing sample, review the extracted patterns carefully, and likely refine before confirming.

### v1.2 Context

Sam is the validation case for the writing profile's optional sample analysis. If the sample analysis doesn't produce recognizable patterns for Sam, the feature has failed.

### Goals (JTBD)

**Functional jobs:**
- Maintain consistent voice across all newsletter outputs
- Generate outlines and drafts in their voice from notes
- Get structural feedback that respects their style

**Social jobs:**
- Consistent brand voice — readers know it's Sam's writing, not AI

**Emotional jobs:**
- Feel like Cowork is a creative collaborator, not a ghost-writer who writes in the wrong voice

### Pains

| Pain | Severity | v1.2 Impact |
|------|----------|-------------|
| Every output sounds like generic AI | High | Writing profile with sample analysis = primary v1.2 gain for Sam |
| No persistent brand voice document | High | writing-profile.md is exactly this |
| Voice inconsistency across outputs | Medium | Profile referenced by global-instructions on every ≥100 word output |

### Quote (v1.2 update)

> "I pasted one paragraph from my newsletter and it caught that I start sentences with conjunctions and use em-dashes a lot. My outputs actually sound like my newsletter now."

### Writing Profile for Sam

- **Tone:** Conversational, distinct, personal
- **Audience:** Newsletter readers
- **Characteristic patterns:** Short paragraphs, em-dashes for asides, sentence-starting conjunctions, specific concrete examples over generalizations
- **Anti-AI guidance focus:** Avoid formal academic transitions, passive voice, "it's important to" openers, comma-heavy long sentences

---

## New Persona: Jordan — "I Don't Know What I Want"

**Name:** Jordan (any age, any role)
**This is a state, not a person.** Jordan is Alex, Maria, or Sam on their first session. They exist to ensure the dynamic wizard is designed for uncertainty.

### What Jordan Represents

Jordan just installed Cowork. Jordan knows AI is useful. Jordan has heard Cowork is powerful. Jordan has no idea how to get started. Jordan cannot identify with any preset in a menu — not because their goal is exotic, but because they don't know what a "preset" is or why they'd pick one.

Jordan describes their situation:
- "I want to use this for work stuff"
- "Something to help me with my job"
- "I'm a teacher and I want to use AI to help me plan lessons, grade, communicate with parents..."
- "I'm trying to manage my job search"

None of these are "Study" or "Research" or "Business/Admin" in the way a menu item presents them.

### Why Jordan Is a Canonical Persona

Every design decision that requires "the user knows what they want" fails Jordan. v1.2 exists because Jordan is not an edge case — Jordan is the median new Cowork user.

### Jordan's Requirements from the Wizard

1. The wizard must NOT require Jordan to identify a preset before asking questions
2. The wizard must suggest options when Jordan is uncertain — not wait for Jordan to figure it out
3. If Jordan's goal resembles a preset, the wizard can offer the preset as a shortcut — but Jordan never has to know the preset existed
4. If Jordan's goal is novel (Career Manager, Home Renovation, Language Learning), the wizard must still produce a complete, useful workspace

### Jordan's Success Criteria

Jordan completes setup. Jordan's workspace matches what they actually wanted. Jordan does not know or care that it was built from a "preset scaffold" or a "novel-goal flow." Jordan just has a workspace that works.

### Design Principle Derived from Jordan

**The wizard must assume zero product knowledge at every step.** When the wizard says "skill," it immediately explains what a skill is. When it says "folder structure," it explains why you'd want one. When it suggests a connector, it explains what that connector will let you do. Every term is introduced with context the first time it appears.

---

---

## Tertiary Persona (v1.4): Casey — The Life Admin Juggler

**Name:** Casey (any age, parent/caretaker archetype)
**Role:** Parent, caretaker, or anyone simultaneously managing family logistics, shared finances, and relationship networks.
**Cowork plan:** Claude Pro ($20/month)
**Note:** Tertiary persona added in v1.4. Does not displace Alex, Maria, or Sam. Do not over-optimize for Casey at the expense of the primary/secondary personas.

### Context

Casey has three different inboxes (work email, family group chat, school portal) and a mental model of who owes whom what — a birthday gift to buy, a callback to a sibling, a reimbursement from the carpool. Casey is constantly managing relationship labor that falls through the cracks precisely because it lives nowhere: not in a task app, not in a calendar, not in a notes app.

Casey also runs the family finances but has no time for deep budgeting — they just want to know if anything looks weird this month and whether there's a subscription nobody uses.

Casey has tried ChatGPT and Copilot but gets frustrated re-explaining context every session. Casey is not a knowledge worker in a professional sense — their "work" is the domestic and relational coordination of a household.

### Goals (JTBD)

- Surface missed commitments before they cause relationship damage ("You were supposed to call Mom on Tuesday")
- Get a structured morning view of the day without building it manually
- Catch unusual or duplicate charges without spending an hour on Mint or a spreadsheet
- Keep personal files organized without a system that requires constant maintenance

### Why Casey Validates the Personal Assistant Preset

Casey is the persona for whom the three PA skills (`daily-briefing`, `follow-up-tracker`, `spend-awareness`) have the highest retention signal. They are not a productivity optimizer — they are an overloaded coordinator who needs to reduce the cognitive overhead of domestic administration.

**Under 200 words:** Casey is a parent or caretaker archetype who manages family logistics, commitments, and finances simultaneously. The Personal Assistant preset — with its tactical daily-briefing, relationship-labor follow-up tracker, and one-glance spend-awareness summary — is designed for this exact overload profile.

---

## Persona Priority Matrix (v1.2)

| Decision | Alex | Maria | Sam | Jordan |
|----------|------|-------|-----|--------|
| Wizard entry point | Dynamic description → Study scaffold | Dynamic description → Research/PM hybrid | Dynamic description → Writing scaffold | Dynamic description → anything |
| Writing profile engagement | Medium (frames as "academic voice") | High (professional standard) | Very high (brand voice) | Unknown — wizard must make case |
| Technical comfort | Low — zero-code required | Medium — tolerates checklist | Low-medium | Low — assume Alex level |
| Safety sensitivity | Medium — student files | Very high — client files | Low | Unknown — default to high |
| Skill discovery | Tier 1 curated only | Tier 1 + optional Tier 2 | Tier 1 curated only | Tier 1 curated only (can't opt into Tier 2 safely without safety literacy) |
| Primary success metric | Workspace matched goal + used within 7 days | Hours saved + professional quality output | Voice consistency | Setup completed — workspace matched what they described |
| Fast-track behavior | Will likely fast-track at Step 6 | Will complete all steps | Will complete writing profile but maybe fast-track skills | Will fast-track — come back later |

---

---

## New Persona (v2.0): Riley — The Prosumer Builder

**Name:** Riley (any age — skews 28–45)
**Role:** Cross-functional professional or solopreneur simultaneously operating in 2–4 domains (e.g., product + marketing, engineering + sales, creative + strategy)
**Cowork plan:** Claude Max ($100/month)
**Added:** v2.0 — Dynamic Workspace Architect
**Note:** Riley is the persona that v2.0's upstream category system is designed for. Riley is NOT Jordan (Riley knows what they want), NOT Maria (Riley's workflow is cross-functional, not single-domain), NOT Sam (Riley produces multiple output types, not just writing).

### Context

Riley runs a small product studio or works in a startup where job titles don't constrain responsibilities. One week Riley is doing customer discovery interviews and synthesizing research. The next week Riley is writing a marketing brief and reviewing engineering specs. The week after that Riley is building a financial model for a fundraise.

Riley has tried to use v1.x of cowork-starter-kit. The problem: no single preset covers the week. Riley started with the Research preset, then set up a second workspace for Project Management, then gave up on configuring a third for Marketing because it was too manual.

**What Riley actually needs:** A wizard that says "I see you need research synthesis, project tracking, and marketing copy this week — here's a workspace that covers all three, built from the [academic], [project-management], and [marketing] upstream categories."

Riley is the primary driver of v2.0's multi-category composition feature. Riley is the answer to the question: "who needs ~30 categories when we already have 6 presets?"

### Goals (JTBD)

**Functional jobs:**
- Configure a workspace that covers all active domains without running the wizard three separate times
- Get research synthesis, project updates, and marketing copy from a single Cowork workspace without losing context between tasks
- Install verified, well-described agent configurations for domains Riley enters for the first time (e.g., "I've never done investor relations before — what does a good IR workflow look like?")
- Know that every installed configuration was reviewed and approved, not randomly pulled from the internet

**Social jobs:**
- Be the person on the team who "actually figured out Cowork"
- Produce output in multiple voices and formats (research report, project brief, marketing copy) from one workspace

**Emotional jobs:**
- Feel like the workspace adapts to the week's priorities, not the reverse
- Trust that the workspace setup won't break something (strong safety sensitivity — Riley has client work in the same Cowork environment as personal projects)

### Pains

| Pain | Severity | v2.0 Impact |
|------|----------|-------------|
| No single preset covers cross-functional workload | High | Multi-category wizard composition directly solves |
| Running the wizard N times for N domains is tedious | High | Single session maps goal → multiple upstream categories |
| Doesn't know which upstream configurations are safe to install | High | SHA-pinned lock file + allowlist eliminates research burden |
| Installed content from random GitHub repos before; broke workspace | High | Integrity verification + attribution block provides provenance |
| Can't verify that two installed configurations won't conflict | Medium | Allowlist policy's architectural conflict blocking (F4) reduces this risk |
| Writing voice inconsistency across domains (research prose vs. marketing copy) | Medium | v1.x writing profile still applies; v2.0 inherits this |

### v2.0 Context

Riley is the primary validation case for the multi-category disambiguation flow (F2 open question). When Riley says "I need to run a product launch," the wizard must map that to [product] + [project-management] + [marketing] + [strategy] and ask: "I found content across 4 categories for 'product launch.' Which should be the primary focus, or should I set up all four?"

Riley is also the primary test case for the attribution block (F5). Riley will ask "where did this come from?" — and the attribution block must give a satisfying answer without requiring Riley to understand GitHub commit SHAs.

Riley will read the SETUP-CHECKLIST more carefully than Jordan or Alex, and will specifically look for: (a) what content is being installed, (b) where it comes from, and (c) whether it's been reviewed. F1 (lock file), F4 (allowlist), and F5 (attribution) together answer these questions.

### Quote (v2.0)

> "I told it I was doing a product launch — research, planning, and marketing in the same week. It found content for all three in the library, told me what each piece was for, and I confirmed. Everything installed with a note showing exactly where it came from. I didn't have to go to GitHub once."

### Writing Profile for Riley

- **Tone:** Adaptive — formal for research/stakeholder outputs, direct for project updates, persuasive for marketing
- **Audience:** Variable (investors, engineers, customers) — Riley uses the workspace-specific rules section of the writing profile heavily
- **Characteristic patterns:** Executive summary leads, clear headings, outcome-first structure
- **Anti-AI guidance:** Avoid generic templates that don't reflect the specific domain's conventions

### Usage Pattern

- Cowork 5+ days/week across multiple project types
- Most valuable: "Synthesize this research and then draft a one-pager for our engineering team" (cross-domain, single session)
- Strong safety sensitivity: Riley keeps client work in the same Cowork environment; the "confirm before delete" safety rule is non-negotiable
- Will read the attribution block on installed files; will not install content without knowing its source
- Will use the `/setup-wizard --upgrade` flow to selectively replace v1.x preset content with upstream equivalents as the lock file covers more categories

---

## Persona Priority Matrix (v2.0 update)

| Decision | Alex | Maria | Sam | Jordan | Casey | Riley |
|----------|------|-------|-----|--------|-------|-------|
| v2.0 wizard entry | Category suggestions (study-adjacent) | Category suggestions (academic + product) | Category suggestions (marketing + design) | Category suggestions → anything | Category suggestions (personal assistant) | Category suggestions → multi-category |
| Upstream content engagement | Low — prefers known presets | Medium — quality-focused | Medium — creative/design categories | Unknown — default to low | Low — personal assistant only | Very high — primary v2.0 user |
| SHA/attribution visibility | None — not relevant to Alex | Moderate — wants provenance | Low — trusts the wizard | Low — trusts the wizard | None | High — reads attribution block |
| Multi-category need | None | Occasional (Research + PM) | Occasional (Writing + Marketing) | Unknown | None | Primary — 3+ categories per week |
| Safety sensitivity | Medium | Very high | Low | Unknown → default high | Low | High (client work in same env) |
| Fast-track behavior | Fast-track at Step 6 | Completes all steps | Writing profile + fast-track skills | Fast-track | Fast-track | Completes all steps + reviews attribution |

---

## Design Principles from Personas (v2.0 additions)

7. **Riley drives multi-category design but must not break single-category UX.** Jordan, Alex, and Casey do not want to choose between 4 upstream categories. The multi-category disambiguation prompt must be triggered only when the goal genuinely spans multiple categories — not for every goal.

8. **Attribution blocks are for Riley, not for everyone.** The F5 attribution block must be visually distinct enough that Riley can find it quickly, but unobtrusive enough that Alex and Casey never have to think about it.

9. **The upstream content label ("workspace library") must not require understanding of GitHub.** Riley knows what GitHub is; Jordan does not. The wizard framing must work for Jordan while satisfying Riley's provenance curiosity.

10. **Allowlist fail-closed means Riley never gets surprised.** Riley's primary fear is "installing something that breaks my workspace." The fail-closed allowlist + nexus-strategy.md block means Riley's workspace is protected from architectural conflicts even when Riley doesn't know enough to assess them.

---

## Design Principles from Personas (v1.2)

1. **Lowest common denominator = Jordan.** If Jordan can navigate a step without product knowledge, Alex can too. Maria is never blocked by a step designed for Jordan.

2. **Safety is Maria's hard requirement, and Jordan's unspoken one.** Jordan doesn't know to ask for safety. We provide it by default because Jordan cannot protect themselves from a file deletion they didn't anticipate.

3. **Context persistence is the #1 gain for Alex and Maria.** `cowork-profile.md` + `writing-profile.md` together eliminate the "constant context tax." Both files are created in every setup.

4. **Voice is Sam's primary requirement and Maria's secondary.** The writing profile is not optional for Sam — it IS the product. For Maria, it elevates already-good work to something that sounds like her specifically.

5. **Jordan must not feel lost when given options.** Every AskUserQuestion button set must include an "I'm not sure / help me decide" path. The wizard never dead-ends on uncertainty.

6. **Skill discovery must protect Jordan by default.** Jordan cannot assess security risk. Tier 1 curated skills are Jordan's path. Tier 2 is only available after explicit opt-in with a clear explanation of what "community-sourced, unverified" means.

---

## v2.6.0 — Dynamic Preset Scaffolds (2026-05-10)

### Overview

v2.6.0 reframes all 7 presets as _starting scaffolds_ with runtime swap/add/drop affordance. This section adds domain-level JTBD analysis and per-preset personas to inform the tiered schema and scaffold composition decisions.

Personas in this section are decision filters for: (1) which skills belong in `core` vs `optional` vs `cross_cutting` tiers, (2) where the runtime edit affordance surfaces in the wizard flow, and (3) what backwards-compat strategy respects existing users.

---

### Persona 1 — Alex (Study)

**Background:** 20-year-old biochemistry major using Cowork to survive high-volume reading weeks.

**Primary JTBD:**
- When buried in 5+ papers before an exam, I want to convert them into flashcards and structured notes in one session so I can review efficiently without re-reading everything.
- When I finish a lecture recording, I want to capture what I'll actually be tested on so I can stop worrying about forgetting it.
- When I'm confused by a paper's argument, I want to see how it compares to other sources so I understand where the author fits in the debate.

**Skills Alex uses most (core tier):**
- `flashcard-generation` — daily during exam prep; the primary reason Alex stays in the workspace
- `note-taking` — used for every paper and lecture; produces the review layer
- `research-synthesis` — used 2-3x/week when comparing sources for a paper or lit review section

**Skills Alex uses situationally (optional tier):**
- `editing-pass` — for lab reports and essays: "I know what I want to say, just fix my writing"
- `outline-generator` — for longer assignments where Alex is stuck on structure before drafting

**Skills Alex would never use in a Study workspace:**
- `email-drafting`, `daily-briefing`, `spend-awareness`, `risk-assessment`, `status-update`, `creative-brief`, `ideation-partner`, `follow-up-tracker`

**Friction the current 3-skill cap creates:**
The current Study bundle (flashcard-generation + note-taking + research-synthesis) hits Alex's core perfectly. But when Alex writes a lab report mid-session, there is no `editing-pass` available without starting a new workspace or asking the wizard to swap. The missing affordance: "I want to write this essay now — can you help me polish it?" The pivot from study mode to writing mode is natural for Alex; the wizard makes it feel like a system boundary.

---

### Persona 2 — Maya (Research)

**Background:** 29-year-old PhD candidate in cognitive science managing a 60-source systematic review.

**Primary JTBD:**
- When I have a new batch of papers to process, I want to see how they map to the themes I already know so I can identify gaps without re-reading sources I've already coded.
- When I evaluate whether to cite a source, I want a quick credibility and relevance verdict so I can move through my stack faster.
- When I'm writing the lit review chapter, I want a synthesis view of how sources agree and diverge so I can structure the argument without losing important contradictions.

**Skills Maya uses most (core tier):**
- `literature-review` — the defining tool; organizes her source set thematically
- `source-analysis` — used on every new paper before deciding to include it
- `research-synthesis` — bridges individual sources into the comparative synthesis Maya needs to write

**Skills Maya uses situationally (optional tier):**
- `note-taking` — for new sources in the first pass, before formal coding
- `doc-summary` — when reviewing a paper for a committee member who needs a quick brief

**Skills Maya would never use in a Research workspace:**
- `flashcard-generation`, `daily-briefing`, `spend-awareness`, `creative-brief`, `ideation-partner`, `email-drafting`, `follow-up-tracker`

**Friction the current 3-skill cap creates:**
Maya's current bundle (literature-review + source-analysis + research-synthesis) matches her core workflow. The gap is when she shifts to writing a section of her thesis. `note-taking` is missing from her loaded bundle when she needs to draft structured notes from a new source mid-session. She exits the flow mentally to remember that she doesn't have note-taking active — then either re-explains what she wants or settles for a less structured output.

---

### Persona 3 — Sam (Writing)

**Background:** 32-year-old freelance content strategist who produces 3-5 long-form pieces a week for B2B clients.

**Primary JTBD:**
- When I take on a new client brief, I want to match their voice quickly so my first draft doesn't come back with "this doesn't sound like us" edits.
- When I'm stuck on structure for a complex piece, I want a detailed outline I can argue against so I stop staring at a blank page.
- When I finish a draft, I want targeted editing suggestions at the depth I specify so I can polish without losing my voice.

**Skills Sam uses most (core tier):**
- `voice-matching` — the first skill Sam loads; without it, the workspace produces generic AI copy
- `outline-generator` — used at the start of every major piece; Sam navigates from the outline
- `editing-pass` — final polish before client delivery

**Skills Sam uses situationally (optional tier):**
- `research-synthesis` — when a piece requires comparing sources or positioning a client against market alternatives
- `feedback-synthesizer` — when clients send mixed notes and Sam needs to reconcile them into a coherent revision direction

**Skills Sam would never use in a Writing workspace:**
- `flashcard-generation`, `daily-briefing`, `spend-awareness`, `risk-assessment`, `action-items`, `meeting-notes`, `follow-up-tracker`

**Friction the current 3-skill cap creates:**
Sam's current bundle (voice-matching + outline-generator + editing-pass) is the strongest-fit preset of the 7. Almost no friction in core workflow. The gap appears when Sam takes a research-heavy client brief and needs `research-synthesis` to compare competitors before writing. Sam either does that manually or opens a separate Research workspace — a context switch that breaks the writing session flow.

---

### Persona 4 — Jordan (Project Management)

**Background:** 38-year-old operations manager at a 40-person SaaS company who runs 3 concurrent projects and is in 8+ meetings a week.

**Primary JTBD:**
- When I finish a meeting with decisions and commitments scattered across notes, I want a clean record of what was decided and who owns what so nothing falls through the cracks.
- When I need to update a stakeholder on project status, I want a draft calibrated to their level (exec, team, client) so I can send it without rewriting from scratch.
- When a new initiative starts, I want a risk snapshot so I can surface blockers before they become incidents.

**Skills Jordan uses most (core tier):**
- `meeting-notes` — used after every meeting; the highest-frequency touchpoint for Jordan's workspace
- `status-update` — used 2-3x/week for stakeholder communication
- `risk-assessment` — used at project start and when something feels off mid-project

**Skills Jordan uses situationally (optional tier):**
- `action-items` — when meeting-notes output needs to feed directly into a task system (ownership + deadline extraction in a separate structured list)
- `follow-up-tracker` — when tracking multi-party commitments across a week of meetings

**Skills Jordan would never use in a Project Management workspace:**
- `flashcard-generation`, `voice-matching`, `creative-brief`, `ideation-partner`, `spend-awareness`, `daily-briefing`, `literature-review`, `source-analysis`

**Friction the current 3-skill cap creates:**
The current project-management bundle has `status-update`, `meeting-notes`, and `risk-assessment` — matching Jordan's core perfectly in theory. But `action-items` is missing. After meeting-notes produces a clean record, Jordan's next step is always "pull the action items for the task board." Doing this in two steps is not a blocker, but `action-items` is used as frequently as `meeting-notes` in practice. It is the clearest example of a skill that belongs in the `optional` tier because it is used by the same persona on the same trigger events, just not every single time.

---

### Persona 5 — Priya (Creative)

**Background:** 26-year-old brand strategist at a creative agency who owns ideation and brief-writing for 4-6 clients simultaneously.

**Primary JTBD:**
- When a client brief is too vague to brief the creative team, I want to structure it into a clear problem + principles + constraints document so the team can execute without constant interruptions.
- When a project is starting from a blank page, I want genuinely distinct creative directions to explore so I don't default to the same pattern for every client.
- When feedback arrives from 4 different reviewers on a campaign, I want a synthesis that separates signal from noise so the next iteration has a clear direction.

**Skills Priya uses most (core tier):**
- `creative-brief` — the core deliverable of Priya's work; used on every new client project
- `ideation-partner` — used at project start to break out of familiar patterns
- `feedback-synthesizer` — used after every review round; multi-source feedback is the norm, not the exception

**Skills Priya uses situationally (optional tier):**
- `outline-generator` — when Priya is writing a strategy deck or proposal (not a brief)
- `voice-matching` — when producing client-facing copy that must match a brand voice Priya has already documented

**Skills Priya would never use in a Creative workspace:**
- `flashcard-generation`, `daily-briefing`, `spend-awareness`, `risk-assessment`, `action-items`, `follow-up-tracker`, `literature-review`, `source-analysis`

**Friction the current 3-skill cap creates:**
The current creative bundle (ideation-partner + creative-brief + feedback-synthesizer) is a near-perfect core match. The gap is `outline-generator`: when Priya shifts from brief-writing to strategy-deck writing mid-session, she needs structural help for a longer document format. The skill exists in the pool but is invisible in the creative workspace. The "hard boundary" between presets is the friction point — Priya's work spans both creative strategy and written deliverables, and the current architecture treats these as two separate workspaces.

---

### Persona 6 — Chris (Business/Admin)

**Background:** 44-year-old VP of operations at a professional services firm whose job is equal parts communication, document processing, and admin coordination.

**Primary JTBD:**
- When I receive a long vendor proposal or internal report I need to act on in a meeting, I want the key insight and recommended action summarized in 2 minutes so I'm prepared without a full read.
- When I need to communicate a decision or respond to a complex email, I want a draft calibrated to the recipient relationship so I don't over-explain or under-explain.
- When I finish a meeting, I want the action items extracted and owned so I can paste them into the team channel without manually re-reading my notes.

**Skills Chris uses most (core tier):**
- `email-drafting` — used daily; the highest-frequency tool in the business-admin context
- `doc-summary` — used whenever Chris receives a document that requires a decision
- `action-items` — used after every meeting to feed the team channel and task system

**Skills Chris uses situationally (optional tier):**
- `meeting-notes` — when the meeting requires a full structured record (not just action items)
- `follow-up-tracker` — when Chris needs to track multi-party commitments across a week

**Skills Chris would never use in a Business/Admin workspace:**
- `flashcard-generation`, `voice-matching`, `creative-brief`, `ideation-partner`, `literature-review`, `source-analysis`, `risk-assessment`

**Friction the current 3-skill cap creates:**
The current business-admin bundle was (email-drafting + doc-summary + action-items) as of v2.6 recomposition analysis. This actually matches Chris's core well. But `meeting-notes` is absent from the bundle. Chris's meeting frequency means that after `action-items` runs, the next natural ask is a full structured record for the team. `meeting-notes` and `action-items` are used by the same persona in the same trigger window; separating them into different bundles is arbitrary from Chris's perspective.

---

### Persona 7 — Casey (Personal Assistant)

**Background:** 35-year-old knowledge worker and parent managing work commitments, household logistics, and personal finances with no admin support.

**Primary JTBD:**
- When I start my day with too many tabs open in my head, I want a structured briefing of my schedule, priorities, and pending follow-ups so I can close those loops before 10am.
- When someone promises to send me something or I commit to sending something, I want a record of who owes what so I stop discovering dropped commitments 2 weeks later.
- When I review my transactions for the month, I want a plain-language breakdown by category so I understand where money went without building a spreadsheet.

**Skills Casey uses most (core tier):**
- `daily-briefing` — the anchor habit; used every morning to structure the day
- `follow-up-tracker` — used after inbox processing sessions and end-of-week reviews
- `spend-awareness` — used monthly for financial review and weekly for high-spend weeks

**Skills Casey uses situationally (optional tier):**
- `action-items` — when Casey processes meeting notes from a work context and needs to extract tasks
- `doc-summary` — when Casey receives a long document (HOA notice, insurance policy, school communication) and needs the key decision quickly

**Skills Casey would never use in a Personal Assistant workspace:**
- `flashcard-generation`, `literature-review`, `source-analysis`, `creative-brief`, `ideation-partner`, `voice-matching`, `risk-assessment`, `meeting-notes`, `outline-generator`

**Friction the current 3-skill cap creates:**
Casey's current bundle (daily-briefing + follow-up-tracker + spend-awareness) is a clean core match. The optional-tier gap is `action-items` and `doc-summary`. When Casey processes a complex email thread or HOA document, neither skill is available without leaving the personal workspace. The 3-skill cap means Casey must either tolerate the gap or open a Business/Admin workspace that lacks daily-briefing and spend-awareness. The friction is the forced binary: home vs. work contexts, not the natural blend Casey actually lives.

