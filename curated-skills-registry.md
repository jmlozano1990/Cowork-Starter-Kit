# Curated Skills Registry

Vetted skills for use with Claude Cowork. Community PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for schema requirements and vetting guidelines.

---

## Schema

Each entry includes:

| Field | Description |
|-------|-------------|
| `name` | Slug matching `name:` frontmatter in SKILL.md (e.g., `flashcard-generation`) |
| `description` | One sentence — what this skill does for the user |
| `source_url` | GitHub URL (HTTPS only) or `builtin` for Anthropic official |
| `vetting_date` | ISO 8601 date of last manual vetting review |
| `tier` | `1` = curated/official, `2` = community |
| `goal_tags` | Comma-separated preset slugs (study, research, writing, project-management, creative, business-admin, personal-assistant) |
| `sha256` | 64-char lowercase hex SHA-256 of the skill's `SKILL.md` bytes at its pool location (`skills/<slug>/SKILL.md`) — CI-computed at PR time and drift-verified on every PR (ADR-069, v2.18.0 Substrate F5), never hand-entered. This is the content-hash half of the pull contract an internal or external puller uses to verify a pulled skill's integrity (see `docs/substrate-contribution-format.md` §External consumer contract). |

---

## Tier 1 — Curated Skills

### Mandatory Safety Skills

These skills are installed unconditionally by the setup wizard (WIZARD.md Step 4, Mode A and Mode B) — they are infrastructure, not part of any preset's `core_skills`/`optional_skills` and not offered through F4 or Path C matching. `goal_tags` here intentionally names no preset domain, so this row cannot surface in any goal-derived draft team or bundle suggestion.

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| self-apply | Mandatory safety skill hosting the memory-of-use ledger's schema/counting convention and the confirmed-proposal apply/verify/rollback machinery (deny-listed — never itself an apply target). | builtin | 2026-07-21 | 1 | mandatory-infrastructure | 66a0e213531c5789ed5f4f5e503a0253d3f8d0858cc0e77394cfdf0e0b08f0ca |
| self-archive | Mandatory safety skill hosting the auto-cleaning move-eligibility gate, destination gating, and reversible-move-log rollback for proposing a stale/superseded file's relocation into the local archive convention (deny-listed — never itself a move target). | builtin | 2026-07-21 | 1 | mandatory-infrastructure | 0e191cd038522e6bda761b27f0da8250849a5f23b1a6d2dfdcb3536fc6466afa |

### Study

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| flashcard-generation | Generate Anki-ready flashcards from source material using spaced-repetition best practices (atomicity, cloze deletion, minimum information principle). | builtin | 2026-04-18 | 1 | study | c38ecb79376db7fb5144717216579c08b4efcc2fd302aa84f203f78b6f0347a9 |
| note-taking | Convert reading material into organized, concise study notes using a hybrid framework auto-selected from source type (Cornell, Outline, Zettelkasten, or Lightweight bulleted). | builtin | 2026-04-18 | 1 | study,research | 33a02c35e0b52031326c3c80c58901611d768e193d927c0d32297020199f2926 |
| research-synthesis | Synthesize multiple sources into a structured literature-review matrix with cross-source synthesis paragraphs, auto-selecting mode from source count (1 = atomic note, 2 = compact matrix, ≥3 = full matrix). | builtin | 2026-04-18 | 1 | study,research | ff95c6aec24417ec508e6a1a6c47ed5431dcef41d98765f8e8900206d7b32dff |

### Research

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| literature-review | Organize multiple sources into a thematic matrix with cross-source synthesis and gap analysis, stating detected theme and source counts at the top of the output. | builtin | 2026-04-18 | 1 | research | 1e10873e2a061ae1c791eb242f59b174e789fda4ea5b25ff82e17f8090e43c60 |
| source-analysis | Evaluate a single source across 7 structured fields (source type, authority, methodology, evidence quality, limitations, bias, bottom line) with an explicit citation recommendation. | builtin | 2026-04-18 | 1 | research,study | 9cdb2ccb62a4b4a10d15a2bb71b2d6c7e7cb5f83b0e201ce46a845e5c9214764 |
| research-synthesis | Synthesize sources at peer-review rigor using a 7-column matrix (claim, method, evidence, limitations, authority, recency, citation-network) with structured Agreements, Disagreements, Gaps, and Synthesis sections. | builtin | 2026-04-18 | 1 | research | ff95c6aec24417ec508e6a1a6c47ed5431dcef41d98765f8e8900206d7b32dff |
| citation-formatter | Format references and citations in APA, MLA, Chicago, or Harvard style from pasted source details, with missing-field flagging and style conversion. | builtin | 2026-07-06 | 1 | research,study,writing | bc844edd7bbf1291b6a932269e9c3a86923c5757c66a636063af26b5fb69d35c |

#### Disposition Annotations

> `research-synthesis` appears in both the Study and Research sections intentionally (ADR-018): the canonical pool file `skills/research-synthesis/SKILL.md` is the research variant; `examples/study/.claude/skills/research-synthesis/SKILL.md` is a preserved study variant. Wizard installs resolve to the pool file.
>
> `citation-formatter` — removed at the v2.6.x audit as a phantom entry (no pool file), re-added 2026-07-06 together with a 9-section `skills/citation-formatter/SKILL.md` per the audit's disposition condition. Source: `docs/project-audit-v2.6.1.md` F-2, roadmap idea 10.
>
> The registry therefore has 26 rows across 25 unique skill slugs.

### Writing

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| voice-matching | Analyzes writing samples to match tone, vocabulary, and sentence rhythm in new content | builtin | 2026-04-17 | 1 | writing,creative | 04940ad5c9ce1b55756c2cd20c205ba3274b24fbdde37e1add8314dfe28b77d0 |
| outline-generator | Builds a detailed hierarchical outline for any content type from a brief description | builtin | 2026-04-17 | 1 | writing,creative | 6c749e41a20887c344ee1931b2e6847ce4c9127ecaaf9f309a362194458f3a1d |
| editing-pass | Performs structured editing at light (errors), medium (clarity), or heavy (restructure) depth | builtin | 2026-04-17 | 1 | writing,creative,research | 305c6c54060fcd34e891994ca0d414f8890570d485e542f3c2862f3c7824bd86 |

### Project Management

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| status-update | Synthesize project progress into a RAG-status update (Green/Amber/Red + 2–3 line narrative + next milestone) calibrated for the specified audience. | builtin | 2026-05-07 | 1 | project-management | 0497909e9c6c45bbce3b72decc9836a2cb0887d6b22280c9b3ce033fa01d4237 |
| meeting-notes | Extract structured decisions, action items, and open questions from a meeting transcript or rough notes into a clean 4-section summary. | builtin | 2026-05-07 | 1 | project-management,business-admin | b5571679dd67fc4a70958eaab90ecf5ebdc5db11e763a7e8cdcc23c491a12bc8 |
| risk-assessment | Identify and tabulate the top 5–7 project risks with likelihood, impact, and mitigation in a 6-column table, then surface the top-2 priority risks in a prose section. | builtin | 2026-05-07 | 1 | project-management | 74e32994dcae948bbc326ddec19f10533634bfb8ee378a45a9380087400c439c |
| prompt-gate | Enrich vague prompts by reading workspace context, scanning local files, asking up to 3 grounded clarifying questions, then executing with full context — auto-skips for trivial prompts and `*`-prefixed bypass. | builtin | 2026-05-10 | 1 | study,research,writing,project-management,creative,business-admin,personal-assistant | 16b8ef1036d5d7320a7a166b5ea907d365a703b28f5858592bdccc810f1db2c3 |

### Creative

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| ideation-partner | Generates diverse creative directions, builds on half-formed ideas, and breaks creative blocks | builtin | 2026-04-17 | 1 | creative | e3c03c10add4f3addf17761ac1da0bc9f5ddaa3a8d031f4d371b530268ad4734 |
| creative-brief | Structures a vague creative concept into a clear brief with goals, constraints, and success criteria | builtin | 2026-04-17 | 1 | creative,project-management | b003aadee9329ebe4f834351d8aa50ee5887435ef8d2010da2d8bf0e9e2de8a4 |
| feedback-synthesizer | Consolidates feedback from multiple sources into actionable themes and prioritized revisions | builtin | 2026-04-17 | 1 | creative,writing,project-management | d38f05eb31c759672cfca68e574b59985febc89c9102a9359e486cf529f828d5 |

### Business/Admin

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| email-drafting | Drafts professional emails matched to audience, tone, and intent from short bullet notes | builtin | 2026-04-17 | 1 | business-admin | c27830016c3be62c0e62045f1605cb399beca21b864a86007d2993e3741c7172 |
| doc-summary | Summarizes long documents, reports, or proposals into executive-ready highlights | builtin | 2026-04-17 | 1 | business-admin,research,project-management | abe1eca736cc200b59b4073cf1b5fc82b96cbc9c35813e870a1bbefa95035ab2 |
| action-items | Extracts clear, assigned, deadline-tagged action items from meeting notes or email threads | builtin | 2026-04-17 | 1 | business-admin,project-management | e4292289558c34325ecd82da8ff3a80ebf973ca4a02caa07b1e20c8aea3a96e4 |

#### Disposition Annotations

> `doc-summary` — `disposition: covered-by-runtime` — meeting-notes skill + Anthropic runtime DOCX/PDF skills + general Claude summarization are sufficient. No in-tree expansion planned. Source: `docs/internal/process/skills-roadmap.md` §Section 1.
>
> `action-items` — `disposition: covered-by-runtime` — meeting-notes skill already extracts action items as a workflow step. No standalone in-tree expansion planned. Source: `docs/internal/process/skills-roadmap.md` §Section 1.

### Personal Assistant

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| daily-briefing | Summarize today's schedule, open tasks, and pending follow-ups into a concise morning brief from local files | builtin | 2026-04-19 | 1 | personal-assistant | 2cb04551a2067eccf3af8745ebe8c5474385ebe90ba18b4329236272254c0bdc |
| follow-up-tracker | Log and surface pending commitments — things you owe others and things others owe you — from conversations, notes, and inbox snippets | builtin | 2026-04-19 | 1 | personal-assistant | 600bad0fb6f91092d99f7d1d93e1af66af9ad82109295c641896255bff232e09 |
| spend-awareness | Summarize pasted transaction data by category in plain language to surface spending patterns — descriptive only, does not provide investment advice, budgeting recommendations, or savings plans | builtin | 2026-04-19 | 1 | personal-assistant | cef113ff18a5acc2c116625c61ad754e4183bdd143da52fa42944bdf900901a1 |
| list-tracker | Create and maintain structured tracking lists — guest lists, RSVPs, vendors, applications — as local markdown tables with statuses, counts, and follow-up flags | builtin | 2026-07-06 | 1 | personal-assistant,project-management,business-admin | 687597250fc8706c26236ae08ad1ac3f274e059b6399ed6cfbf2bc7fb2c8a59e |

### Cross-Domain

These skills span 3+ preset domains; their `goal_tags` reflect the breadth rather than any single home preset. Offered on-demand (`cross_cutting_skills` F4 / `optional_skills` / Path C `goal_tags`), never in any preset's `core_skills`.

| name | description | source_url | vetting_date | tier | goal_tags | sha256 |
|------|-------------|------------|--------------|------|-----------|----------------------------------------------------------------|
| anti-ai-slop | Remove AI-tell vocabulary, uniform sentence rhythm, and empty hedging from any drafted content — an opt-in authenticity pass that respects the user's own established voice rather than imposing a fixed denylist. | builtin | 2026-07-19 | 1 | study,research,writing,project-management,creative,business-admin,personal-assistant | 92c56b918b6c52653d7e724f68fb1b52bbc63d8a4301a4c7d0a7c93ae682487d |
| weekly-review | Run a periodic (weekly-cadence) Collect → Process → Review → Plan pass across the user's own workspace files — a descriptive zoom-out distinct from the daily briefing or a project status update. | builtin | 2026-07-19 | 1 | personal-assistant,project-management,study | 3c82284355e82ed353813ed5c18631d85cde5630d9ecc32ad325b35b6888be52 |

---

## Tier 2 — Community Skills

Community skills are shown only after explicit user opt-in. They are not verified by repo maintainers. Review each skill's SKILL.md carefully before installing.

> To add a Tier 2 entry: open a PR with your skill entry following the schema above. Include vetting evidence (source repo stars, last commit date, keyword scan result). See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process.

*(No Tier 2 entries at v1.2 launch — community contributions welcome via PR.)*

---

## Adding a Registry Entry

1. Fork the repo and add your entry to the appropriate section in this file
2. `source_url` must be `https://` (HTTPS only) — `http://` URLs are not accepted
3. For GitHub entries: pin `source_url` to a specific commit SHA, not a branch URL
   - Example: `https://github.com/org/repo/blob/a1b2c3d4e5f6/SKILL.md`
4. `vetting_date` is the date you personally tested the skill in a live Cowork session
5. Include a brief vetting summary in your PR description (stars, last commit, keyword scan result)
6. Open a PR with title `feat: add <skill-name> to curated-skills-registry`

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full PR checklist.
