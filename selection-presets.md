# Selection Presets

> Curated skill combinations used as starting suggestions by the dynamic wizard (F3). Not a locked menu — every preset is editable in F4 and the user can request a custom-from-scratch composition (F3 Path C) at any point.

These blocks are parsed by the wizard using line-scanning (`^```preset$` / `^```$` fences). Each block's `core_skills`, `optional_skills`, and `match_signals` values are comma-separated lowercase tokens. Key order is fixed per C-v2.4-1 (updated v2.6.0). The `cross_cutting_skills:` annotation block at the bottom of this file is pool-level (not per-preset) and is parsed as a single comma-separated list under the `cross_cutting_skills:` line.

---

## Study

```preset
name: study
display_name: Study
description: Studying, exam prep, research-heavy coursework.
core_skills: flashcard-generation, note-taking, research-synthesis
optional_skills: editing-pass, outline-generator
scaffold_source: examples/study/
match_signals: study, studying, exam, exams, finals, midterm, midterms, test, coursework, class, classes, semester, learn, learning, course, school
```

## Research

```preset
name: research
display_name: Research
description: Academic research, literature review, analysis.
core_skills: literature-review, source-analysis, research-synthesis
optional_skills: note-taking, doc-summary
scaffold_source: examples/research/
match_signals: research, literature, sources, source, papers, paper, academic, citations, thesis, dissertation, analysis, analyzing, review, reviews
```

## Writing

```preset
name: writing
display_name: Writing
description: Content creation, authoring, journalism, blogging.
core_skills: voice-matching, outline-generator, editing-pass
optional_skills: research-synthesis, feedback-synthesizer
scaffold_source: examples/writing/
match_signals: writing, write, writer, content, blog, blogging, essay, essays, fiction, journalism, draft, drafts, article, articles, newsletter
```

## Project Management

```preset
name: project-management
display_name: Project Management
description: Managing projects, teams, tracking tasks and status.
core_skills: meeting-notes, status-update, risk-assessment
optional_skills: action-items, follow-up-tracker
scaffold_source: examples/project-management/
match_signals: project, projects, management, managing, manage, team, tasks, tracking, milestones, status, risk, sprint, sprints, agile, scrum, roadmap
```

## Creative

```preset
name: creative
display_name: Creative
description: Design, storytelling, creative strategy, ideation.
core_skills: ideation-partner, creative-brief, feedback-synthesizer
optional_skills: outline-generator, voice-matching
scaffold_source: examples/creative/
match_signals: creative, design, designing, designer, brand, branding, ideation, concept, brief, brainstorm, storytelling, campaign, portfolio, feedback
```

## Business/Admin

```preset
name: business-admin
display_name: Business/Admin
description: Email, reporting, scheduling, admin tasks.
core_skills: email-drafting, doc-summary, action-items
optional_skills: meeting-notes, follow-up-tracker
scaffold_source: examples/business-admin/
match_signals: email, emails, admin, business, reports, reporting, scheduling, summary, documents, executive, invoices, invoicing, proposals, clients, meetings, freelance
```

## Personal Assistant

```preset
name: personal-assistant
display_name: Personal Assistant
description: Daily life, calendar, finances, tasks, follow-ups.
core_skills: daily-briefing, follow-up-tracker, spend-awareness
optional_skills: action-items, doc-summary
scaffold_source: examples/personal-assistant/
match_signals: personal, assistant, daily, calendar, finances, budget, family, home, organize, organizing, planning, errands, follow-up, reminders, life
```

---

## Cross-Cutting Skills (pool-level annotation)

These skills are useful across multiple presets. They are NOT installed by default for any preset — the wizard offers them on-demand at runtime via the "Skill swap" affordance in each preset's `global-instructions.md` (per ADR-034 §Decision and D8 — instruction-only swap; no file copy).

```cross_cutting
cross_cutting_skills: action-items, meeting-notes, doc-summary, voice-matching, research-synthesis
```

| Skill | Rationale |
|-------|-----------|
| action-items | Used situationally by PM, business-admin, personal-assistant, and study personas |
| meeting-notes | Used situationally by PM, business-admin, and personal-assistant personas |
| doc-summary | Used situationally by research, business-admin, and personal-assistant personas |
| voice-matching | Used situationally by writing and creative personas; crossover to business-admin for exec emails |
| research-synthesis | Bridges study, research, and writing domains |
