# Selection Presets

> Curated skill combinations used as starting suggestions by the dynamic wizard (F3). Not a locked menu — every preset is editable in F4 and the user can request a custom-from-scratch composition (F3 Path C) at any point.

These blocks are parsed by the wizard using line-scanning (`^```preset$` / `^```$` fences). Each block's `skill_bundle` and `match_signals` values are comma-separated lowercase tokens. Key order is fixed per C-v2.4-1.

---

## Study

```preset
name: study
display_name: Study
description: Studying, exam prep, research-heavy coursework.
skill_bundle: flashcard-generation, note-taking, research-synthesis
scaffold_source: examples/study/
match_signals: study, studying, exam, exams, coursework, learn, learning, course
```

## Research

```preset
name: research
display_name: Research
description: Academic research, literature review, analysis.
skill_bundle: literature-review, source-analysis, research-synthesis
scaffold_source: examples/research/
match_signals: research, literature, sources, papers, academic, citations, peer-review, analysis
```

## Writing

```preset
name: writing
display_name: Writing
description: Content creation, authoring, journalism, blogging.
skill_bundle: voice-matching, outline-generator, editing-pass
scaffold_source: examples/writing/
match_signals: writing, write, content, blog, essay, fiction, journalism, draft, article
```

## Project Management

```preset
name: project-management
display_name: Project Management
description: Managing projects, teams, tracking tasks and status.
skill_bundle: status-update, meeting-notes, risk-assessment
scaffold_source: examples/project-management/
match_signals: project, management, team, tasks, tracking, milestones, status, risk
```

## Creative

```preset
name: creative
display_name: Creative
description: Design, storytelling, creative strategy, ideation.
skill_bundle: ideation-partner, creative-brief, feedback-synthesizer
scaffold_source: examples/creative/
match_signals: creative, design, ideation, concept, brief, brainstorm, storytelling, feedback
```

## Business/Admin

```preset
name: business-admin
display_name: Business/Admin
description: Email, reporting, scheduling, admin tasks.
skill_bundle: email-drafting, doc-summary, action-items
scaffold_source: examples/business-admin/
match_signals: email, admin, business, reports, scheduling, summary, documents, executive
```

## Personal Assistant

```preset
name: personal-assistant
display_name: Personal Assistant
description: Daily life, calendar, finances, tasks, follow-ups.
skill_bundle: daily-briefing, follow-up-tracker, spend-awareness
scaffold_source: examples/personal-assistant/
match_signals: personal, assistant, daily, calendar, finances, follow-up, reminders, life
```
