# Competitive Analysis — Claude Cowork Config

## Research Date: 2026-04-17

## Scope for v1.2

v1.2 adds three new competitive surfaces that weren't relevant in v1.1:
1. **Skill discovery and vetting** — the GitHub skill ecosystem and emerging registries
2. **Anti-AI writing tools** — writing profile calibration competes with standalone humanizer tools
3. **Dynamic workspace builders** — tools that guide users to a workspace vs. presenting a menu

v1.1 competitors (Cowork native, GPT Builder, Claude Code Onboard, Notion Templates, PromptBase) are carried forward with updates.

---

## Part 1 — v1.1 Competitors (Updated)

### 1. Claude Cowork Native Onboarding (Anthropic)

**What it is:** Out-of-the-box Cowork setup — basic account flow, no goal-based personalization.
**Update since v1.1:** No change observed. Anthropic has not shipped a native personalization wizard as of April 2026.

| Dimension | Assessment |
|-----------|-----------|
| Dynamic goal discovery | None |
| Skill discovery | None — user must search/find skills manually |
| Writing profile / voice calibration | None |
| Novel-goal workspace building | None |
| Non-technical user fit | Poor — blank slate after account setup |

**Whitespace:** Everything past basic account setup remains unclaimed. v1.2's dynamic wizard and writing profile are unaddressed by Anthropic's native product.

**Risk:** Unchanged. Anthropic could ship a wizard. Mitigated by: community preset library and curated skills registry compound faster than a first-party product can iterate.

---

### 2. ChatGPT Custom GPT Builder (OpenAI)

**Update since v1.1:** GPT Builder added a "starter suggestions" flow in late 2025 — if users describe a vague goal, the builder now suggests GPT configurations. This is the closest analog to v1.2's dynamic wizard.

| Dimension | Assessment |
|-----------|-----------|
| Dynamic goal discovery | Yes (added late 2025) — conversational goal → GPT config |
| Skill/file setup | Knowledge upload (PDFs, docs) |
| Writing voice profile | None — no persistent voice calibration |
| Local file access | None — ChatGPT doesn't access local filesystems |
| Non-technical user fit | Moderate — builder helps, result depends on prompt quality |

**Key difference (v1.2):** GPT Builder creates a new AI assistant. Claude Cowork Config configures your local AI agent's relationship with YOUR files. GPT Builder's "starter suggestions" is the closest UX analog — but it has no equivalent to Cowork's local file system, connectors, or persistent project context.

**What we can learn:** The "describe your goal, get suggested configuration" UX is validated by OpenAI's decision to add it. Our suggestion branch and dynamic wizard is aligned with the industry's UX direction.

---

### 3. Claude Code Onboard (aiwithremy — GitHub)

**Update since v1.1:** This project targets Claude Code developers. Unchanged audience gap — knowledge workers are still underserved.

**What we can learn from its Voice DNA feature:** aiwithremy's "Voice DNA" captures writing style from existing emails/messages. v1.2's writing profile is inspired by this but implemented for non-technical Cowork users: shorter interview (3–4 questions) and optional sample paste rather than requiring email import.

---

### 4. Notion AI Template Library

**Update since v1.1:** No significant change. Browse-by-category model confirmed by our presets structure. Non-overlapping surface.

---

### 5. Prompt Template Marketplaces (PromptBase, FlowGPT)

**Update since v1.1:** skills.sh has emerged as a dedicated skills marketplace for Claude and other agents. This is more relevant than PromptBase — see Part 2 below.

---

## Part 2 — New Competitors for v1.2

### 6. skills.sh — Agent Skills Marketplace

**What it is:** An open-source agent skills marketplace built on the universal SKILL.md format. Provides discovery, installation, and publishing infrastructure for skills across Claude Code, Cursor, Codex CLI, and others.
**URL:** skills.sh
**Target user:** Developers and power users who want to discover and install agent skills.
**Pricing:** Free / open-source.

| Dimension | Assessment |
|-----------|-----------|
| Skill discovery | Yes — searchable marketplace |
| Skill safety vetting | Limited — community reputation signals only |
| Non-technical user UX | Poor — requires manual installation steps |
| Cowork-specific guidance | None — Claude Code focus |
| Writing profile / workspace building | None |
| Goal-driven recommendations | None — browse by tag only |

**Relationship to v1.2:** skills.sh is a potential SOURCE for v1.2's curated-skills-registry.md. Entries vetted from skills.sh can be added to our registry. We are not competing with skills.sh — we are providing a safer, goal-filtered entry point to the same ecosystem for non-technical Cowork users.

**Key difference:** skills.sh is a marketplace. Claude Cowork Config is a wizard that recommends skills from the marketplace (and other sources) based on your specific goal, with safety filtering applied.

---

### 7. Anthropic Official Skills (anthropics/skills on GitHub)

**What it is:** Anthropic's official public repository for agent skills, alongside the MCP Registry (registry.modelcontextprotocol.io).
**Status:** Active. The MCP Registry launched September 2025 with 10,000+ active public MCP servers and 97 million monthly SDK downloads as of March 2026.
**Target user:** Developers building with Claude agents.

| Dimension | Assessment |
|-----------|-----------|
| Official vetting | Yes — Anthropic-published |
| Non-technical installation | Poor — GitHub-level; requires manual setup |
| Cowork-specific skills | Limited — primarily developer-facing |
| Goal-driven recommendations | None |

**Relationship to v1.2:** Anthropic's official skills (pptx, xlsx, docx, pdf document skills) are Tier 1 defaults in v1.2's curated registry — zero-config, zero-risk. The MCP registry is a secondary source for future curated entries, not v1.2 scope.

---

### 8. Cowork Skills Community Libraries (GitHub)

**Key repos researched:**
- `travisvn/awesome-claude-skills` — curated list, 22,000+ stars (Claude Code focus)
- `VoltAgent/awesome-agent-skills` — 1,000+ community skills, cross-platform
- `EAIconsulting/cowork-skills-library` — 21 Cowork-specific skills (directly relevant)
- `alirezarezvani/claude-skills` — 232+ skills, developer focus

**Relevant finding: `EAIconsulting/cowork-skills-library`**
This is the most directly relevant competitor. 21 Cowork skills from Everyday AI, explicitly positioned as "beginner to power user in 18 minutes, free forever."

| Dimension | Assessment |
|-----------|-----------|
| Cowork-specific | Yes — explicitly targets Cowork |
| Safety vetting | None documented |
| Wizard / goal-driven setup | None — user selects skills manually |
| Writing profile | None |
| Non-technical UX | Moderate — still requires manual browsing and installation |

**Key difference:** Cowork Skills Library is a static skill collection. Claude Cowork Config is a wizard that recommends skills from (and could cross-reference) collections like this, filtered by the user's specific goal, with safety review applied. We are complementary — the Skills Library is a candidate SOURCE for our curated registry.

**Security finding:** Snyk ToxicSkills research (2026) found prompt injection in 36% of tested skills and 1,467 malicious payloads across the GitHub skill ecosystem. 13.4% of all skills contain critical-level issues (Repello AI, 2026). This directly validates our Tier 1 curated default model — we should NOT default users to open GitHub search.

---

### 9. AI Writing Humanizer / Voice Calibration Tools

**The anti-AI writing tool landscape:**

| Tool | Approach | Target User | Limitation |
|------|----------|-------------|------------|
| Phrasly | Rewrites AI text using 500k human articles | Content marketers | Post-hoc rewriting, not pre-configuration |
| BypassGPT | Pattern-matching rewrite to bypass detectors | Students, marketers | Ethical concerns; Turnitin now detects humanizer output (Aug 2025) |
| Grammarly AI Humanizer | Vocabulary + grammar adjustment | General writers | No persistent voice profile |
| SidekickWriter | Per-document voice matching pass | Fiction/book authors | Standalone tool, not workspace-integrated |
| Undetectable AI | Algorithmic rewrite targeting detector bypass | Varies | Turnitin update (Aug 2025) specifically targets humanizer output |

**Critical market context:** Turnitin rolled out a major update in August 2025 that now flags text processed through humanizer tools with cyan highlights. The "bypass detection" angle is increasingly risky and ethically problematic, especially for Alex (student persona).

**v1.2 positioning on this:** Claude Cowork Config's writing profile is NOT a humanizer or detector-bypass tool. It is a persistent voice calibration layer. The goal is to produce writing that sounds like the user in the first place — not to rewrite AI output afterward. This is:
1. Ethically cleaner (no "trick the detector" framing)
2. More durable (not vulnerable to Turnitin's humanizer detection)
3. More aligned with user goals (Maria wants outputs that sound like Maria, not outputs that pass a detector)

**How we frame it:** "This profile helps me write in your voice — so your outputs sound like you, not like generic AI."
We explicitly do NOT use the words "undetectable," "bypass," or "humanize." The academic integrity message for Alex's Study preset notes: "This workspace is designed to support your learning, not to submit AI output as your own work."

**Key difference from standalone humanizers:** Our writing profile is persistent (set once, applies to every session), integrated (part of the workspace, not a separate tool), and honest (voice calibration, not detection evasion). This is a genuinely differentiated position in the landscape.

---

## Updated Feature Matrix

| Feature | Cowork Native | GPT Builder | Cowork Skills Lib | skills.sh | AI Humanizers | Claude Cowork Config v1.2 |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|
| Dynamic goal discovery | — | Yes (2025) | — | — | — | Yes (v1.2) |
| Suggestion branch for vague goals | — | Partial | — | — | — | Yes |
| Custom instructions generator | — | Yes | — | — | — | Yes |
| Writing profile (persistent) | — | — | — | — | Partial (per-doc) | Yes — universal |
| Anti-AI voice calibration | — | — | — | — | Yes (rewrite) | Yes (pre-calibration) |
| Skill discovery + recommendations | — | Limited | Browse-only | Browse-only | — | Yes (curated + advanced) |
| Skill safety vetting | — | — | — | — | — | Yes (Tier 1 curated + Tier 2 scan) |
| Goal-filtered skill suggestions | — | — | — | — | — | Yes |
| Local folder structure | — | N/A | — | — | — | Yes |
| Connector guidance | Generic | Limited | — | — | — | Per-goal checklist |
| Safety configuration | — | — | — | — | — | Yes (every preset) |
| Non-technical user path | Poor | Moderate | Poor | Poor | Moderate | Primary design target |
| Zero-code delivery | Partial | Yes | No | No | Yes | Yes |
| Open-source community presets | — | Via GPT Store | Partial | Yes | — | Yes |
| Cowork-specific | Yes | No | Yes | No | No | Yes |
| Novel-goal (non-preset) support | — | Yes | — | — | — | Yes (v1.2) |

Legend: — = not present, N/A = not applicable

---

## Whitespace Summary (v1.2)

The gap Claude Cowork Config fills has widened since v1.1:

**No existing product is:**
1. Goal-driven with dynamic suggestions (not just a menu or a browse page)
2. Cowork-specific for knowledge workers (not Claude Code, not ChatGPT, not generic)
3. Non-technical-first (not a developer tool)
4. Safety-conscious by default (the 13.4% critical skill risk is real and undisclosed by most discovery tools)
5. Writing-voice-aware (persistent calibration, not per-document rewriting)
6. Novel-goal capable (not locked to 6 preset categories)
7. Open-source and community-extensible with a safety vetting layer

The closest competitors for v1.2's NEW capabilities:
- **Dynamic goal discovery:** GPT Builder (different surface entirely)
- **Skill discovery:** skills.sh (developer audience, no Cowork-specific, no safety vetting)
- **Writing voice:** SidekickWriter (different surface, per-document, not persistent)
- **Cowork skills collection:** EAIconsulting/cowork-skills-library (no wizard, no safety vetting, no writing profile)

No competitor combines all seven dimensions. The whitespace is real, growing, and defensible.

---

---

## Part 3 — v1.4 Competitors: Personal AI Assistant Adjacent Products

_Research date: 2026-04-19. Focus: personal-life PA tools, relationship-labor features, and finance read-only tools relevant to the Personal Assistant preset._

### 10. Monarch Money — Personal Finance Read-Only Analysis

**What it is:** A personal finance app with AI-powered spending summaries, subscription detection, and category analysis. Positioned as the post-Mint successor.
**Target user:** Budget-conscious individuals who want visibility into spending without deep financial planning.

| Dimension | Assessment |
|-----------|-----------|
| Spend categorization | Yes — automatic via bank feed |
| Subscription detection | Yes — explicit feature |
| AI narrative summaries | Yes (2025 feature) |
| Local-first / paste-only | No — requires bank account connection |
| Relationship / commitment labor | None |
| Daily briefing / morning ritual | None |
| Non-technical user fit | Moderate — requires account linking |

**Key gap for v1.4:** Monarch requires live bank connectivity and account linking — a significant privacy/trust barrier for many users. `spend-awareness` serves the same categorical insight need via a paste-only, no-connection model. Monarch is stronger on historical trending; `spend-awareness` wins on zero-trust setup.

**Caution (cautionary signal):** Monarch's AI narrative summaries are the closest feature analog to `spend-awareness`. If users who already use Monarch arrive at cowork-starter-kit, `spend-awareness` must provide clear differentiation (it does: no bank connection required, integrated with other personal PA skills, Cowork-native).

---

### 11. Microsoft Copilot — Finance Read-Only (365 Integration)

**What it is:** Copilot in Microsoft 365 can read Excel/CSV transaction data and produce natural-language summaries if the user pastes or uploads a spreadsheet.
**Target user:** Microsoft 365 users with Excel-based financial tracking.

| Dimension | Assessment |
|-----------|-----------|
| Spend summarization from paste | Yes (via Excel/CSV upload) |
| Subscription detection | Indirect (user must ask) |
| Persistent personal PA configuration | Limited — no equivalent to cowork-starter-kit's global-instructions |
| Relationship / commitment labor | No |
| Daily briefing | No |
| Non-technical user fit | Low — requires knowing to upload the right file format |

**Key gap:** Copilot's finance read-only requires Microsoft 365 and Excel/CSV familiarity. `spend-awareness` works with any paste (bank statement text, screenshot description, transaction list in any format). The data-locality rule also differentiates: Copilot processes data on Microsoft servers; `spend-awareness` in a local Cowork session keeps data local to the conversation.

---

### 12. Motion — AI Calendar and Task Integration

**What it is:** An AI scheduling tool that auto-prioritizes tasks and blocks calendar time based on deadlines and energy levels.
**Target user:** Professionals who want AI to manage their schedule rather than having to manage it themselves.

| Dimension | Assessment |
|-----------|-----------|
| Daily briefing / morning ritual | Partial — shows scheduled blocks, not an intention-setting ritual |
| Commitment tracking | Task-based (not relationship-labor oriented) |
| Cowork-native configuration | No |
| Spend awareness | None |
| Non-technical setup | Low — complex UI; requires calendar/task system integration |

**Key gap for `daily-briefing`:** Motion's AI scheduling is powerful but requires full calendar and task system integration. `daily-briefing` is intentionally lighter: user pastes their current calendar/task list (no integration required) and receives a structured day note plus an intention. Motion solves the scheduling problem; `daily-briefing` solves the morning-clarity problem. Different job.

---

### 13. Reclaim.ai — Intelligent Calendar Blocking

**What it is:** AI that automatically blocks focus time, habits, and tasks in Google Calendar based on priorities.
**Target user:** Knowledge workers who want their calendar to reflect their priorities automatically.

| Dimension | Assessment |
|-----------|-----------|
| Daily briefing | No — manages calendar, doesn't brief you on it |
| Commitment / relationship labor | None |
| Spend awareness | None |
| Non-technical setup | Moderate — requires Google Calendar OAuth |
| Local-first | No — cloud service |

**Key gap:** Reclaim focuses entirely on calendar optimization for professionals. It has no relationship-labor or spend-awareness features. `daily-briefing` is complementary to Reclaim users (they may have Reclaim managing their schedule and use `daily-briefing` for the morning intention ritual on top of what Reclaim blocked).

---

### 14. Rabbit R1 — Personal AI Assistant (Cautionary)

**What it is:** A dedicated hardware personal AI assistant device that promised to handle personal tasks (bookings, orders, information retrieval) via a "Large Action Model."
**Status:** Effectively abandoned as of late 2025 — low adoption, unfulfilled promises, discontinued feature set.

**Why it's relevant as a cautionary signal:**
- Rabbit R1 attempted to be the "everything personal assistant" and failed because it over-promised on action-taking (making reservations, placing orders) without delivering reliable results.
- The market signal from its failure: users distrust personal AI assistants that claim to take action on their behalf without explicit confirmation.
- The lesson for `spend-awareness` specifically: do NOT promise that the skill will "optimize," "recommend," or "act on" financial data. The read-only, observation-only scope is exactly right.

**Design implication:** The explicit "read-only awareness only" scope of `spend-awareness` is validated by the Rabbit R1 failure mode. Over-promising on action leads to loss of user trust in the personal PA space.

---

### 15. Personal AI Assistant Apps (General Survey: Dot, Rewind.ai, Claude for Personal Use)

**Dot (New Computer):**
- AI memory assistant that remembers personal facts across sessions.
- Strong on relationship memory ("your sister's birthday is next week"); weak on task/calendar integration.
- No spend awareness, no daily briefing ritual.
- Key gap `follow-up-tracker` fills: Dot is passive memory; `follow-up-tracker` actively surfaces "you said you'd do X" — a commitment accountability layer Dot doesn't provide.

**Rewind.ai:**
- Records all screen/audio activity to enable recall ("what did I say in that meeting last Tuesday?").
- Strong on retrospective recall; weak on proactive follow-up or morning structuring.
- Privacy-maximalist angle (local processing) aligns with cowork-starter-kit's data-locality posture.
- Key gap: Rewind is retrospective; `follow-up-tracker` is prospective.

**Claude for Personal Use (unstructured):**
- Generic Claude chat without a personal-life PA configuration.
- Users can ask for a daily briefing or spend summary, but get no consistent structure, no context persistence, no proactive skill triggers.
- This is the exact whitespace cowork-starter-kit's Personal Assistant preset fills.

---

## Competitive Gaps v1.4 Validates

**Gap 1 — Relationship labor ("follow-up tracker") is the most unserved personal PA market segment.** No product listed above ships a dedicated relationship-commitment surfacing feature. Monarch, Motion, Reclaim, and Copilot are all task/calendar/finance tools. Dot remembers; it does not proactively surface commitments. `follow-up-tracker` is a genuine market gap.

**Gap 2 — Spend awareness without bank connectivity.** Every finance tool (Monarch, Copilot, Mint) requires bank connection. `spend-awareness` via paste-only is the only zero-trust spend-awareness option in the landscape. Privacy-first positioning is differentiated.

**Gap 3 — Cowork-native personal PA configuration.** All adjacent products are standalone apps. None of them configure a Cowork workspace. The Personal Assistant preset is the only structured Cowork configuration for personal-life users.

---

## Updated Feature Matrix (v1.4 addition)

| Feature | Monarch | Copilot Finance | Motion | Reclaim | Personal Claude (generic) | Cowork PA Preset v1.4 |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|
| Daily briefing / morning ritual | — | — | Partial | — | Manual | Yes |
| Relationship / commitment labor | — | — | — | — | Manual | Yes (follow-up-tracker) |
| Spend awareness (read-only) | Yes (bank-linked) | Yes (Excel) | — | — | Manual | Yes (paste-only) |
| Zero bank-connection spend awareness | — | — | — | — | Manual | Yes |
| Cowork-native configuration | — | — | — | — | — | Yes |
| Local-first data-locality rule | — | — | — | Partial | Depends | Yes (explicit rule) |
| Non-technical user path | Low | Low | Low | Low | Low | Primary design target |
| Persistent personal PA instructions | — | — | — | — | — | Yes (global-instructions.md) |

---

## Positioning Statement (v1.2)

**Claude Cowork Config is the only guided workspace architect for Claude Cowork that builds a personalized, safety-configured AI workspace from any goal — even ones you can't name — and makes sure every output sounds like you, not like a chatbot.**

Where the skill ecosystem is dangerous without guidance, native onboarding gives you nothing, and humanizer tools fight a losing battle against detection, Claude Cowork Config sets up your workspace right the first time: goal-driven, voice-calibrated, safety-vetted, non-technical.

---

---

## Part 4 — v2.0 Competitors: Dynamic Config / Agent Content Registries

_Research date: 2026-05-06. Focus: tools in the dynamic workspace configuration, curated agent content registry, and upstream-content-backbone space. v2.0 introduces a pinned upstream content source (agency-agents) as the skill backbone — this is a new competitive surface not evaluated in v1.x._

### 16. Curated Agent Content Lists (awesome-claude-code class)

**What they are:** Community-maintained "awesome" lists aggregating agent skills, CLAUDE.md configs, and workflow files. Examples include collections in the awesome-claude-code genre (22,000+ stars noted in v1.2 research) and similar aggregations on GitHub. These are not vetted registries — they are link collections.

| Dimension | Assessment |
|-----------|-----------|
| Content coverage | Very broad — hundreds to thousands of entries |
| Integrity verification | None — links only, no SHA pinning, no checksums |
| Allowlist / fail-closed policy | None — unknown entries are displayed, not blocked |
| Goal-driven discovery | None — browse by tag or keyword only |
| Attribution propagation | None — no automatic license injection |
| Non-technical user path | Poor — requires manual browsing and GitHub familiarity |
| Nexus-class architectural conflicts | No filtering — user must assess conflicts manually |

**Key difference from v2.0:** Awesome lists are discovery surfaces. v2.0's lock file + allowlist is a verified, pinned delivery mechanism. A user who finds a skill on an awesome list still has to: (a) assess whether it's safe, (b) verify the URL hasn't rotated, (c) check the license, and (d) manually install. v2.0 handles all four steps with supply-chain guarantees.

**Competitive signal:** These lists validate the demand for agent content discovery. They do not solve the safety or integrity problem. v2.0 is positioned as the "safe path into the same ecosystem these lists catalogue."

---

### 17. claude-flow / Agent Orchestration Frameworks

**What they are:** Orchestration frameworks that manage multi-agent workflows — Claude agents spawning sub-agents, passing context, coordinating parallel tasks. These frameworks often ship with a content registry of agent roles or "personas" that users can install.

| Dimension | Assessment |
|-----------|-----------|
| Content registry | Yes — curated agent roles bundled with the framework |
| Integrity verification | None at the content level — framework-level versioning only |
| Goal-driven discovery | Partial — framework docs suggest which agent roles to use |
| Non-technical user path | Poor — requires CLI, config files, and orchestration literacy |
| NEXUS-class conflict risk | HIGH — orchestration frameworks directly compete with cowork-starter-kit's wizard layer |
| Attribution propagation | None documented |

**Key difference:** Orchestration frameworks target developers and power users who want to build multi-agent systems. v2.0 targets non-technical Cowork users who want a configured workspace — not a pipeline they have to manage. The architectural conflict (orchestration framework vs. wizard layer) is exactly the pattern that motivated the nexus-strategy.md permanent block in F4.

**Competitive signal:** The fact that orchestration frameworks ship with bundled content registries confirms the demand. Their failure mode for non-technical users (complexity, CLI requirement) is v2.0's whitespace.

---

### 18. Cursor / Windsurf / IDE-Native Rules Ecosystems

**What they are:** AI-native code editors that support workspace configuration via rules files (`.cursorrules`, `.windsurfrules`). An ecosystem of community-shared rules has emerged — GitHub repos with thousands of curated rules, websites for browsing and installing IDE-specific configurations.

| Dimension | Assessment |
|-----------|-----------|
| Goal-driven discovery | Partial — browse by language/framework category |
| Integrity verification | None — download from GitHub or copy-paste |
| Attribution propagation | None systematic |
| Non-technical user path | Poor — developer-primary audience |
| Content freshness | Variable — community-maintained repos update irregularly |
| Allowlist / blocked content | None — user must assess conflicts with their own setup |

**Why this is relevant to v2.0:** The agency-agents upstream repo (msitarzewski/agency-agents) follows a similar pattern to IDE rules ecosystems — a community-maintained collection of workspace configurations for a specific AI tool. The difference: v2.0 adds the supply-chain layer (SHA pinning, checksums, allowlist, attribution) that IDE rules ecosystems lack entirely.

**Competitive signal:** IDE rules ecosystems have demonstrated that users want curated, category-organized workspace configurations. The safety gap (no integrity verification, no allowlist, no attribution) is identical to what v1.x identified in the Claude skill ecosystem. v2.0's upstream content approach is the first application of IDE-rules-ecosystem-style content coverage to Cowork, with a supply-chain layer on top.

---

### 19. agency-agents (msitarzewski) — The Upstream Source Itself

**What it is:** The upstream content backbone for v2.0. msitarzewski/agency-agents is a collection of ~30 category folders (academic, design, engineering, finance, game-development, integrations, marketing, paid-media, product, project-management, sales, spatial-computing, specialized, strategy, support, testing) with CLAUDE.md-style agent configuration files for each domain.
**License:** MIT.
**Target user:** Claude Code power users who know what they want and can manually install from GitHub.

| Dimension | Assessment |
|-----------|-----------|
| Content coverage | Very broad — ~30 domains, actively maintained |
| Integrity verification | None — users pull from main branch directly |
| Allowlist / blocked content | None — NEXUS framework content is included without warning |
| Non-technical user path | None — manual GitHub install required |
| Goal-driven discovery | None — browse by category folder |
| Attribution propagation | MIT notice is on the repo; not propagated to installed files |

**Relationship to v2.0:** agency-agents is the supplier, not a competitor. v2.0 is the distribution and safety layer on top of it. The relationship is complementary: users who are comfortable with GitHub and don't need safety filtering can install directly from agency-agents; users who want wizard-guided, integrity-verified, allowlisted installation use cowork-starter-kit v2.0.

**Key risk:** If agency-agents dramatically improves its own installation UX (e.g., ships a wizard or a Cowork integration), the distribution gap narrows. Mitigation: cowork-starter-kit's safety layer (allowlist, SHA pinning, nexus-strategy.md block, attribution) provides value even if agency-agents ships a wizard — a wizard without safety filtering is not the same product.

---

### 20. MCP Marketplace / Registry Frontends

**What they are:** Emerging web UIs for browsing and installing Model Context Protocol (MCP) servers. The MCP Registry (registry.modelcontextprotocol.io, 10,000+ active servers as of March 2026) has spawned third-party browser UIs that let users search, filter, and one-click install MCP servers. Some of these frontends are beginning to add workspace configuration content alongside MCP servers.

| Dimension | Assessment |
|-----------|-----------|
| Content coverage | Large and growing (10,000+ MCP servers; workspace configs emerging) |
| Integrity verification | Variable — depends on registry implementation; SHA pinning rare |
| Allowlist / blocked content | None at the frontend level |
| Goal-driven discovery | Partial — search + category filter; no interview-driven recommendation |
| Non-technical user path | Improving — web UI removes GitHub barrier |
| Attribution propagation | None documented for workspace configs |

**Key difference from v2.0:** MCP marketplaces focus on MCP server installation (tools, integrations, data connectors). Workspace configuration content (agent roles, CLAUDE.md files, skill instructions) is an emerging secondary surface. v2.0 is ahead of MCP frontends specifically for workspace configuration. As MCP frontends expand into workspace configs, the competitive overlap increases — but v2.0's allowlist + integrity verification + non-technical wizard UX is differentiated.

**Competitive signal:** MCP marketplaces confirm that the "browse and install AI capabilities" UX is a growing market. The safety gap (no allowlist, no checksums, no conflict detection) in most MCP frontends is the same gap v1.x identified and v2.0 addresses for upstream content.

---

### 21. Prompt Engineering Platforms (Agentive Config Layer)

**What they are:** SaaS platforms for managing, versioning, and deploying agent configurations across teams. Examples include platforms that let users create "agent templates" (analogous to cowork-starter-kit presets), share them with a team, and track versions. These are emerging as enterprise-grade alternatives to file-based agent configuration.

| Dimension | Assessment |
|-----------|-----------|
| Content library | Yes — platform-hosted templates; some community sharing |
| Integrity verification | Platform-level versioning; no SHA pinning for user-imported content |
| Goal-driven discovery | Partial — search + category; no interview |
| Non-technical user path | Moderate — web UI; still requires understanding agent concepts |
| Allowlist / blocked content | None for imported content |
| Zero-code delivery | No — typically requires API key setup or OAuth |
| Attribution propagation | Varies; often silently omits upstream attribution |

**Key difference from v2.0:** Enterprise platforms target teams, not individual knowledge workers. They add collaboration and governance features that v2.0 doesn't need. They lack the local-first, zero-code, wizard-driven UX that is v2.0's primary design target.

**Competitive signal:** Enterprise platforms confirm the market for managed agent configuration. Their enterprise pricing and team-first model leaves the individual knowledge worker segment unserved — v2.0's target market.

---

## Updated Feature Matrix (v2.0 addition)

| Feature | awesome-lists | claude-flow class | IDE rules ecosystems | agency-agents (upstream) | MCP frontends | Prompt platforms | cowork-starter-kit v2.0 |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Goal-driven discovery | — | Partial | Partial | — | Partial | Partial | Yes |
| SHA-pinned upstream content | — | — | — | — | Rare | — | Yes |
| Per-file SHA-256 integrity | — | — | — | — | — | — | Yes |
| Allowlist / fail-closed policy | — | — | — | — | — | — | Yes |
| NEXUS-class conflict blocking | — | — | — | — | — | — | Yes |
| MIT attribution propagation | — | — | — | — | — | Varies | Yes |
| Non-technical wizard UX | — | — | — | — | Improving | Moderate | Yes |
| Zero-code delivery | N/A | — | — | — | Partial | — | Yes |
| Multi-category composition | — | Partial | — | Partial | Partial | Partial | Yes (v2.0) |
| Writing profile (persistent) | — | — | — | — | — | — | Yes |
| Cowork-specific | — | — | — | Partial | Partial | — | Yes |
| Local-first / no account required | — | — | — | Yes | — | — | Yes |

---

## Whitespace Summary (v2.0)

The v2.0 gap adds three new dimensions that no existing product addresses:

**New gap 1 — SHA-pinned, checksum-verified agent content delivery:** No competing tool verifies upstream content integrity at install time via SHA-256 checksums against a pinned commit. awesome lists have no integrity model. IDE rules ecosystems pull from main branches. MCP frontends vary but rarely apply per-file checksums. v2.0 is the first application of package-manager-style supply-chain hygiene to Cowork workspace configuration.

**New gap 2 — Allowlist with fail-closed policy and structural conflict blocking:** No competing tool has an explicit allowlist that blocks architecturally-conflicting content (nexus-strategy.md). The combination of fail-closed (unknown = blocked) + specific permanent blocks is unique to v2.0.

**New gap 3 — Automatic MIT attribution propagation to installed files:** MIT content is widely distributed without attribution. v2.0's F5 attribution injection is the only systematic solution to license compliance for user-installed agent configuration content.

The seven-dimension whitespace from v1.2 remains intact. v2.0 adds three more. No competitor combines all ten dimensions.

---

## Positioning Statement (v2.0)

**Claude Cowork Config v2.0 is the only workspace architect for Claude Cowork that combines upstream content breadth (~30 categories from a curated library) with supply-chain safety (SHA-pinned, checksum-verified, allowlisted, attribution-injected) — so non-technical users get the coverage they need and the safeguards they can't build themselves.**

Where the skill ecosystem is dangerous without guidance, awesome lists give you links without integrity, and orchestration frameworks require developer expertise, Claude Cowork Config v2.0 gives you a vetted, verified workspace built from any goal — with full provenance on every file installed.

---

## v2.6.0 — Dynamic Preset Scaffolds Competitive Scan (2026-05-10)

> **Internal document.** Per `feedback_no_competitor_naming_public`, competitor names may appear in this file. Do NOT sync to Confluence or any public surface. Competitor names must be stripped from all user-facing copy (README, CHANGELOG, SETUP-CHECKLIST, release bodies).

### Scope

v2.6 introduces runtime-editable preset scaffolds. This scan examines how adjacent AI workspace tools handle the scaffold-vs-runtime distinction: what is fixed at setup vs. what the user can change mid-session. Four patterns examined.

---

### Pattern 1 — Custom GPT / GPT Builder (OpenAI)

**Starting-scaffold mechanism:** Creator defines a fixed set of capabilities at configuration time via the GPT Builder UI: instructions (system prompt), knowledge files (uploaded), and tool toggles (web, DALL-E, code interpreter). This is fully static from the user's perspective — once configured, the capability set does not change per session.

**Runtime edit affordance:** None within a session. Users cannot swap capabilities mid-conversation. To change the capability set, the user must open the builder, edit, and re-deploy. No in-session runtime adjustment path exists.

**Schema (flat vs. tiered):** Flat. Tool toggles are binary (on/off). No distinction between "core" and "optional" capabilities within a single GPT. Cross-tool coverage is handled by creating multiple distinct GPTs (e.g., a "Research GPT" and a "Writing GPT").

**Implications for Cowork:** The flat, static model is well-understood but generates the exact pain point v2.6 addresses — users who want to cross domains in a single session (e.g., research then write) must switch GPTs. Cowork's tiered scaffold with runtime swap affordance is a genuine differentiator here. The risk: users trained on GPT Builder's "configure once" mental model may not intuitively expect runtime edit to exist. Proactive offer at the bundle-confirmation step (A-v2.6-7) directly addresses this expectation gap.

---

### Pattern 2 — IDE Rule Presets (Cursor / Windsurf style)

**Starting-scaffold mechanism:** The user selects or creates a "rules" file (`.cursorrules`, project-level YAML, or inline rule block) that configures AI behavior for a codebase. Rules are loaded at session start and persist for the session. Presets (e.g., "React rules", "Python linting rules") are offered via templates or community repos.

**Runtime edit affordance:** Limited but present. Users can temporarily override a rule mid-conversation by prefixing a prompt ("ignore the linting rule for this output") or by editing the rules file between sessions. The affordance is implicit and requires knowing the rule override syntax.

**Schema (flat vs. tiered):** Flat. All rules are in a single file at the same priority level. No distinction between "core" (always-active) and "optional" (context-dependent) rules. Some community templates use comment sections to separate concerns (e.g., `# Core rules` / `# Optional rules`), but this is convention, not system-enforced.

**Implications for Cowork:** The implicit override pattern ("ignore rule X for this output") is a low-friction escape hatch but requires user expertise. Cowork's proactive chip-based affordance ("Want to add a skill to this session?") is a lower-expertise entry point — better fit for Cowork's non-technical target users. The section-comment convention (core / optional in a single file) is an interesting signal: users who care enough have already invented tiered thinking. Cowork formalizes what the community already does informally.

---

### Pattern 3 — AI Agent Composition Tools (e.g., multi-agent orchestrators)

**Starting-scaffold mechanism:** Users define an agent "team" at setup: which agents are active, what tools each has access to, and what the orchestrator's routing logic is. The team is fixed for a workflow run. Some tools allow "hot-swap" of agents between runs but not within a single execution thread.

**Runtime edit affordance:** Mid-run affordance is rare and complex. Most tools treat a running agent composition as immutable to avoid state corruption. Post-run reconfiguration is the norm.

**Schema (flat vs. tiered):** Varies. More mature tools distinguish between "required agents" (core to the workflow) and "optional agents" (invoked only when specific conditions are met). This is structurally analogous to Cowork's `core` vs `optional` tier.

**Implications for Cowork:** The core/optional agent distinction in multi-agent tools validates the tier concept architecturally. The key difference: Cowork's "agents" are skills (stateless tools invoked on demand), not autonomous agents (stateful actors with memory). This makes runtime skill swap safer and simpler in Cowork than in true multi-agent systems — no state corruption risk. Cowork can implement mid-session swap affordance more aggressively than agent orchestration tools can.

---

### Pattern 4 — Personal AI Workflow Builders (non-developer tools)

**Starting-scaffold mechanism:** These tools offer a preset library (productivity, communication, research) that users select at setup. The preset configures which "powers" or "modes" the AI has. Some tools offer a "build from scratch" path for power users.

**Runtime edit affordance:** Some tools have introduced a "mode switch" chip during conversation — a tappable element that changes the AI's behavior context mid-chat (e.g., switching from "research mode" to "writing mode"). This is the most direct competitive reference for Cowork's v2.6 runtime swap affordance.

**Schema (flat vs. tiered):** Flat presets, but "mode" chips represent an implicit tier — modes are overlaid on the base preset at runtime. This is functionally similar to what Cowork's `optional` tier does.

**Implications for Cowork:** The mode-chip pattern (mid-conversation context switch) is validated by at least one competitor. It was adopted by power users before it was a product feature — suggesting genuine user demand. Cowork's version (skill swap affordance after bundle-confirmation) is more granular than mode-switching: users add/remove specific skills rather than switching entire modes. This is a richer UX if the complexity is managed; it becomes friction if the option set is too long.

---

### Cross-Pattern Synthesis — What Competitors Validate

| Pattern | Validated? | Cowork differentiation |
|---------|-----------|----------------------|
| Fixed scaffold at setup | Universally validated | Cowork extends this with runtime edit |
| Mid-session override (implicit) | IDE tools validate; expert users only | Cowork makes this explicit and chip-driven |
| Core vs optional tier | Multi-agent tools validate structurally | Cowork applies to single-session skill loading |
| Mode-switch chips mid-chat | Validated by at least 1 competitor | Cowork variant: skill-level granularity, not mode-level |
| Cross-domain skill sharing | No competitor does this well | Cowork's `cross_cutting` tier is genuinely differentiated |

**Strongest validated bet:** Mid-session override demand is real (IDE tools prove expert users want it; mode-switch competitors prove casual users want it). Cowork's chip-based swap affordance addresses both segments.

**Strongest differentiated bet:** The `cross_cutting` tier — explicitly representing skills that work across domain presets — is not present in any competitor pattern examined. Every competitor forces a preset switch to change domain context. Cowork's v2.6 positions this as the primary architectural innovation.

**Risk to manage:** The mode-switch competitor's lesson is that mid-conversation context switches can create session-state confusion when the AI doesn't explicitly confirm what has changed. Cowork's global-instructions must proactively acknowledge skill additions mid-session ("I've added `action-items` to your session — here's what it does") to avoid the silent-state-change failure mode.

