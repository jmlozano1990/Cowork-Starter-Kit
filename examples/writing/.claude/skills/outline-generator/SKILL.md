---
name: outline-generator
description: Create a structured, specific outline for any type of written content
trigger_examples:
  - "Outline a blog post about remote work productivity"
  - "Build a talk outline on habit formation for a 20-minute slot"
  - "Structure these notes into an article outline"
  - "Outline a proposal for a new internal tool"
---

## When to use

Use outline-generator when the user has an idea, topic, or brief but needs help turning it into a structure they can write from. This skill produces a specific, detailed outline — not a topic list and not a narrative summary. Use it before drafting begins, when the user is stuck on structure, or when multiple structural options would genuinely help them choose a direction. This skill is distinct from editing-pass (which improves an existing draft) and voice-matching (which produces voiced content).

## Triggers

- User says "outline", "structure this", "help me organize this", or "build an outline" — direct invocation.
- User describes a content idea and asks how to approach it or how to structure it.
- User shares rough notes or a brief and wants to turn it into a writing plan.
- User asks for "different approaches" or "structural options" for a topic or piece.

## Instructions

1. **Gather missing inputs before generating.** Confirm: (a) content type (article, essay, blog post, talk, newsletter, proposal, listicle); (b) target length or duration; (c) target audience; (d) the main argument, takeaway, or hook. If any of these are absent and cannot be reasonably inferred from context, ask before generating. Do NOT produce a generic placeholder outline.
2. **Auto-detect content type shape if not specified.** Essay → thesis-driven structure with argument, evidence, counterargument, conclusion. Blog post → hook, sections, CTA. Talk → open, core idea, supporting points, close. Proposal → problem, solution, evidence, ask. Listicle → hook, numbered items, closing. Newsletter → subject-line-driven open, core content, call to action. Apply the appropriate shape.
3. **Produce the outline with these components.** Working headline (specific, not generic), lead description (1–2 sentences on how the piece opens and what it promises to the reader), section headers with one-sentence descriptions, and closing direction. For essays: include the thesis. For listicles: include the actual list items. For talks: include a hook and a one-sentence close. The outline must be detailed enough that the writer can produce the piece without further clarification.
4. **Offer 2–3 structural options when the topic supports genuinely different approaches.** If the same topic could be structured as a narrative, a how-to, or a contrarian argument, present the options and let the user choose. Do NOT offer options when one structure is clearly the right fit.
5. **Do not number-bomb.** Resist outlines deeper than 3 hierarchical levels unless the content genuinely requires it. A five-level nested outline is harder to write from than a clean three-level one.

## Output format

Plain markdown in the chat. Structure: working headline → lead description → section headers with one-sentence descriptions → closing direction. Use `##` for major sections, `-` for subsection bullets where needed. No JSON, no YAML, no Obsidian wikilinks. Output is portable across writing apps, Notion, and plain text.

## Quality criteria

1. All four inputs (content type, length, audience, argument/takeaway) were either supplied or confirmed before generating.
2. The outline is specific — section headers name their content, not just their topic (e.g., "Why most remote teams fail at async communication" not "Remote work challenges").
3. Each section description tells the writer what they will argue or illustrate, not just what they will mention.
4. Depth does not exceed 3 hierarchical levels unless the content type requires it.
5. Working headline is specific enough to guide the piece — not a placeholder like "Introduction to [topic]."

## Anti-patterns

- **Inventing claims not in the brief** — adding arguments, examples, or angles the user did not provide or imply. The outline structures the user's idea; it does not extend it.
- **Padding with filler sections** — adding a "Background" or "Why This Matters" section when the user's brief doesn't call for it. Every section in the outline must earn its place.
- **Enforcing a fixed depth** — imposing a 5-level hierarchy on a piece that needs 2 levels. Let content complexity drive structure depth.
- **Including filler conclusions** — "Conclusion: Wrap up the key points" is not a section description. The closing direction must specify what impression the piece leaves and what the reader should do or believe afterward.
- **Number-bombing** — nesting sub-sub-subsections just to appear thorough. Deep nesting makes the outline harder to write from, not easier.

## Example

**Input:** "Blog post about why people abandon their second brain / note-taking systems. Target: productivity-curious readers who've tried Notion or Obsidian. ~800 words."

**Output:**

**Working headline:** Why Your Second Brain Died After Three Weeks (And How to Revive It)

**Lead:** Opens with the moment of recognition — you built the system, you stopped using the system. Promises a diagnostic, not another productivity lecture.

**Sections:**

**## The Setup: Why Everyone Starts Optimistic**
*The initial enthusiasm loop: beautiful templates, exciting concepts, zero friction — until the first busy week hits.*

**## Three Failure Modes (Pick Your Poison)**
*Overcapture (saving everything, using nothing), maintenance debt (filing backlog kills momentum), and identity mismatch (the system you built is for someone else's workflow).*

**## What "Using" Actually Means**
*The distinction between building a system and using a system. Most tutorials optimize for capture. Usage is retrieval and action.*

**## One Fix That Doesn't Require Rebuilding Everything**
*The weekly decay check: 10-minute ritual to prune, surface, and reconnect the system to active work. No redesign required.*

**Closing:** Reader leaves with a specific next action — not a redesign project but a 10-minute reset that works with their current system.

## Writing-profile integration

Outline-generator consults `context/writing-profile.md` for two purposes: (1) adapting the structural recommendation to the user's documented content style (e.g., a writer who prefers no subheadings in their prose should receive a flatter, paragraph-driven outline); (2) naming the audience and register correctly in the lead description (e.g., "conversational register for readers who distrust corporate productivity content"). If no profile exists, default to standard structure for the content type.

## Example prompts

- "Outline an 800-word article on [topic] for [audience]."
- "Build a talk outline on [topic] for a 20-minute slot."
- "Structure these notes into an article outline: [paste notes]."
- "Outline a proposal for [initiative] — recipient is the executive team."
