---
name: prompt-gate
description: Enrich vague prompts before execution by reading workspace context, scanning local files for the topic, asking up to 3 grounded clarifying questions, then executing with full context. Skips silently for clear prompts and for any prompt prefixed with `*`.
tools: [claude-code]
trigger_examples:
  - "let's work on the project"
  - "fix the thing"
  - "improve the workspace"
  - "add a section about X"
  - "build out the brief"
---

## When to use

Use this skill when a user submits a prompt that is vague, low-context, or could plausibly map to multiple intents. This is a behavior you (the assistant) apply while reading the prompt, not a separate system component: before drafting any answer to a vague request, first enrich it with workspace context and targeted clarifying questions so the output actually matches what the user needs.

Skip this behavior for: any prompt prefixed with `*` (bypass marker), prompts that are obviously trivial (greetings, single-word answer requests, simple arithmetic), or prompts where the conversation history already resolves the ambiguity. Decide whether to apply it as the first thing you do with a new prompt, before starting the substantive answer.

If all relevant context files are present and filled, and the prompt's intent is unambiguous after a quick workspace scan, proceed directly to execution without surfacing any enrichment form.

## Triggers

- User submits a prompt without project, file, or scope context — e.g., "let's work on this," "improve it," "can you fix the thing."
- User says "work on," "improve," "fix," "build out," or "add" with no clear object or target.
- Prompt could plausibly map to multiple workflow paths and the correct path depends on user intent.
- User opens a preset workspace with an unfilled context file and submits any non-trivial first prompt.
- `*` prefix → **DO NOT trigger.** Execute the literal text after `*` directly.
- Trivial prompts (greetings, "what time is it?", single-word echoes, math calculations) → **DO NOT trigger.**

### `*` prefix bypass

Prompts beginning with `*` skip the prompt-gate evaluation entirely and execute directly. This is a Council convention preserved in Cowork. Use it when you know exactly what you want and do not need enrichment. Example: `*draft the project update email` runs without any gate, context check, or clarifying questions.

## Instructions

### Self-evaluation gate

Before Phase 1, decide whether enrichment is needed at all:

- **Bypass immediately (no enrichment):** prompt begins with `*`; prompt is a greeting or social opener ("hi", "hello", "thanks"); prompt is a simple factual question with a bounded answer ("what time is it?", "what does X mean?"); prompt includes all necessary context inline ("summarize this paragraph: <text>").
- **Proceed to Phase 1:** prompt is vague, references project work without specifying what, or could reasonably map to more than one execution path.

### Phase 1 — Context check

Read `context/about-me.md`, `writing-profile.md`, and `working-rules.md` if present in the workspace.

For each file:

1. If the file is **missing** AND the task is clearly dependent on the information it would contain → emit an `AskUserQuestion` with chips: `Fill now` / `Skip` / `Run the wizard`.
2. If the file exists but contains **unfilled template placeholders** (e.g., `[your name]`, `[describe your work]`, `[your role]`) AND the file is relevant to the task → emit the same `AskUserQuestion` with chips: `Fill now` / `Skip` / `Run the wizard`.
3. If the file is **irrelevant to the task** — for example, `writing-profile.md` exists but the task is a math calculation or a file-search — **silently skip that file.** Do not surface a bootstrap offer for an irrelevant file.
4. If all relevant files are **present and filled** → skip Phase 1 bootstrap offer entirely. Proceed to Phase 2.

One offer per relevant missing/unfilled file. Do not stack multiple bootstrap offers in a single pass.

### Phase 2 — Workspace research

Use Glob and Grep to scan the active workspace for content matching the prompt's topic:

- `PROJECTS/` — project folders and their content
- `TEMPLATES/` — any template files relevant to the task
- `cowork-profile.md` — if present at repo root
- Active workspace folder contents

Document findings internally. The goal is to narrow the prompt's intent and ground the Phase 3 questions in real workspace content. If the research fully resolves the ambiguity — you know exactly what the user wants and what file/project to work in — skip Phase 3 and proceed to Phase 4 directly.

### Phase 3 — Clarifying questions (1–3)

Emit 1–3 `AskUserQuestion` items grounded in Phase 2 findings:

- Every chip option must come from research, not assumption.
- Never ask a question answerable from the context files already read.
- Cap at 3 questions — one `AskUserQuestion` with up to 3 items is preferred over 3 separate questions.
- If Phase 2 resolved the ambiguity completely, skip this phase.

### Phase 4 — Execute

Proceed with the enriched understanding gathered in Phases 1–3. Do not re-surface resolved questions. Do not repeat context the user already confirmed. Execute the original intent with full fidelity to the enriched context.

## Output format

This skill produces enrichment output as `AskUserQuestion` chips (Phases 1 and 3) or no visible output (Phases 2 and the trivial-skip path), then proceeds to the user's original ask in Phase 4. The skill does not produce a standalone artifact — its output is the enriched execution in Phase 4. A user who benefits from this skill should see better output, not a visible enrichment step.

## Quality criteria

- Max 3 questions in Phase 3 — never more.
- Every chip option comes from workspace research, not from assumption or generic templates.
- `*` prefix is honored without exception — no enrichment runs when `*` is present.
- Trivial prompts are detected and bypassed without user friction.
- Phase 1 bootstrap offer fires only when a relevant file is missing or unfilled — not on every workspace open.
- The skill never modifies user files directly. Context files (`context/about-me.md`, `writing-profile.md`, `working-rules.md`) are read-only. Only the user can fill them (via "Fill now" chip).
- If all context is present and the prompt is unambiguous after Phase 2, the user experiences zero visible enrichment — Phase 4 runs directly.

## Anti-patterns

- Firing on trivial prompts ("what time is it?", single-word echoes, greetings) — this creates friction without value.
- Asking more than 3 questions in Phase 3. Cap is hard.
- Asking a question answerable from a context file that was already read in Phase 1.
- Asking the user to retype context already provided in `context/about-me.md`, `writing-profile.md`, or `working-rules.md`.
- Modifying `context/about-me.md` or any other user file directly — always emit chips and let the user choose.
- Running enrichment on a `*`-prefixed prompt. The bypass is unconditional.
- Surfacing a bootstrap offer for a file that is irrelevant to the current task (e.g., offering to fill `writing-profile.md` when the task is a calendar lookup or math problem).
- Stacking multiple bootstrap offers in a single AskUserQuestion pass — offer one at a time if multiple files are missing.

## Example

**Scenario:** User opens `examples/research/` workspace, types "let's work on the lit review."

**Phase 1 — Context check:**
- `context/about-me.md`: present, filled (name and role filled in). No bootstrap offer.
- `writing-profile.md`: present, filled. No bootstrap offer.
- `working-rules.md`: present, filled. No bootstrap offer.
- All three fine — skip Phase 1 offer, proceed to Phase 2.

**Phase 2 — Workspace research:**
- Glob `PROJECTS/*.md` → finds three project folders: `china-supply-chain/`, `urban-heat-study/`, `bioethics-review/`.
- Research finding: three distinct projects, each with its own lit review context. Ambiguity not fully resolved — proceed to Phase 3.

**Phase 3 — Clarifying question:**
Emit one `AskUserQuestion`: "Which project's lit review?"
Chips: `China supply chain` / `Urban heat study` / `Bioethics review` / `Other`

**Phase 4 — Execute:**
User picks "Urban heat study." Proceed with the lit review work in `PROJECTS/urban-heat-study/`, applying `research-synthesis` or `literature-review` skill as appropriate.

---

**Trivial bypass example:**

User types "what time is it?" → self-evaluation gate: trivial factual question → skip all phases → answer directly.

**`*` bypass example:**

User types "*draft the executive summary for the China supply chain project" → `*` prefix detected → skip all phases → execute directly.

## Writing-profile integration

This skill does not produce content exceeding 100 words, so `writing-profile.md` voice preferences are not applied to the skill's own output (the AskUserQuestion chips and the self-evaluation logic are structural, not content). However, when the skill resolves to Phase 4 and the downstream task is a content task (writing, summary, email, brief), the standard writing-voice rule from `global-instructions.md` — the existing `## Writing voice` block in every preset — applies as usual to that downstream output.

## Example prompts

- "let's work on the project" → fires (vague; no object or scope).
- "what time is it?" → bypasses (trivial factual question; no enrichment value).
- "*draft the email" → bypasses (`*` prefix; unconditional bypass).
- "fix the thing" → fires (vague object reference; needs workspace research to resolve).
- "summarize this paragraph: <text>" → bypasses (trivial; full content provided inline).

---

> *Pattern from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
> `skills/context-engineering/SKILL.md` @ commit `9534f44c5448086fcc0046f9d83752c654c81930`.
> Copyright (c) Addy Osmani. Licensed under the MIT License.
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions: The above copyright
> notice and this permission notice shall be included in all copies or
> substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS",
> WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. See `THIRD-PARTY-NOTICES.md`
> for the unabridged license text.*
