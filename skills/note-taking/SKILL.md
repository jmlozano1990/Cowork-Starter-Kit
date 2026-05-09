---
name: note-taking
description: Convert reading material into organized, concise study notes using a hybrid framework auto-selected from source type (Cornell, Outline, Zettelkasten, or Lightweight bulleted).
trigger_examples:
  - "Take notes on this"
  - "Make notes from [source]"
  - "I need to study [X]"
  - "What's important here?"
---

## When to use

Use this skill when the user asks for notes from a source — article, textbook chapter, academic paper, lecture, or long excerpt. Also use it when the user shares reading material with no specific ask and the source is long enough to benefit from structure (> 200 words). If the user shares dense study material under exam pressure, offer note-taking alongside flashcard generation. Prefer this skill over raw summarization when the user will need to review the material later — structured notes are more useful for review than a flat summary paragraph.

Cowork auto-selects a note-taking framework based on the source type and states the selection at the top of the output so the user can override it.

## Triggers

- User says "Take notes on" or "Make notes from" with an explicit source reference — highest-confidence direct invocation.
- User shares an article, PDF chapter, or long excerpt with no specific ask — proactively offer note-taking when the source exceeds ~200 words.
- User says "I need to study [X]" or "I'm reading [Y] for class" without naming a skill — offer note-taking as one option alongside flashcards.
- User pastes a long excerpt and asks "What's important here?" or "Summarise this" — offer structured notes as an alternative to raw summary, framing it as more useful for later review.

## Instructions

1. Read the full source before choosing a framework.
2. Apply the framework decision rule:

   | Source type | Framework | Why |
   |-------------|-----------|-----|
   | Dense study material with concepts/definitions (textbook, academic paper) | Cornell (Cues + Notes + Summary) | Generates review cues naturally; matches exam-prep use case |
   | Lecture or chapter with natural hierarchy (section headers, bullet structure) | Outline (nested bullets) | Source already has hierarchy; low-ceremony fit |
   | Multi-source research needing cross-linking (papers citing each other) | Zettelkasten (atomic notes + cross-references) | Cross-source synthesis requires linkable atoms |
   | Short excerpt (< 500 words) | Lightweight bulleted outline | No ceremony for small inputs |

3. State the chosen framework in one line at the top of the output (e.g., "**Framework auto-selected:** Cornell (dense definitions + citations)."). The user can override before reviewing the notes.
4. Write notes in your own words — do not transcribe the source verbatim.
5. Preserve the source's hierarchy — use markdown headers and indented bullets to reflect parent/child structure.
6. For each main claim, include enough context that the user can trace it back to the source section or paragraph.
7. For Cornell format: populate three sections — `## Cues` (question-mode keywords), `## Notes` (synthesized body), `## Summary` (closing paragraph).
8. For Outline format: use nested markdown bullets reflecting the source's section hierarchy.
9. For Zettelkasten format: write atomic note blocks, each with a one-line title and cross-references to related blocks using plain text references (not wikilinks).
10. End every set of notes with a review layer — Cornell summary paragraph, Outline section keywords, or Zettelkasten reference list — so the user has a retrieval hook.
11. Aim for 20–30% of the original source length. Condense supporting detail; capture main ideas in full.

## Output format

Plain markdown in the chat. Standard `.md` output with headers and bullets. No Obsidian `[[wikilinks]]`. No JSON or YAML sidecar. No Cornell box art — Cornell structure is shown via `## Cues`, `## Notes`, `## Summary` markdown headers, not a boxed layout.

Output is portable across Obsidian, Notion, Apple Notes, Logseq, and plain text editors. The user copies it into the note app of their choice.

## Quality criteria

- Framework auto-selected per the decision rule and stated at the top of the output.
- Notes written in the user's own words — no verbatim copy-paste from the source.
- Clear hierarchy — parent/child structure visible via markdown headers and indentation.
- Source cues — each main claim is traceable to its origin section or paragraph.
- Review layer present — Cornell cues OR section-heading keywords for Outline/Zettelkasten.
- Summary or synthesis at the end — one sentence for short sources, a short paragraph for long ones.
- Length discipline — main ideas captured; supporting detail condensed, not transcribed.

## Anti-patterns

- Transcribing the source verbatim instead of synthesizing in the user's own words — defeats the point of note-taking.
- Notes with no hierarchy — a wall of bullets with no parent/child structure.
- Over-detailed (every word captured) or under-detailed (main claim lost).
- No source cue — a claim that cannot be traced back to its origin section or page.
- Missing review layer — no questions, keywords, or summary at the end.
- Ignoring structural signals in the source — section headers and bold/italic emphasis exist to guide note structure.
- Framework mismatch — forcing Cornell onto a source that is naturally outline-shaped, or vice versa.

## Example

**Input (academic paper excerpt):**

> Working memory is a limited-capacity cognitive system responsible for temporary storage and manipulation of information. The dominant model, proposed by Baddeley and Hitch (1974), divides working memory into three components: the central executive, the phonological loop, and the visuospatial sketchpad. Later revisions added the episodic buffer (Baddeley, 2000). Capacity limits are typically estimated at 7±2 items (Miller, 1956), though more recent estimates suggest 4 items for active manipulation (Cowan, 2001).

**Framework auto-selected:** Cornell (dense definitions + citations).

**Output:**

```markdown
# Notes: Working Memory Model (Baddeley & Hitch)

**Framework auto-selected:** Cornell (dense definitions + citations).

## Cues
- What does working memory do?
- Who proposed the main model? When?
- What are the components?
- What was added later?
- What is the capacity limit?

## Notes
- **Working memory**: limited-capacity system for temporary storage + manipulation of information
- **Baddeley & Hitch (1974) model** — 3 components:
  - Central executive (attention/control)
  - Phonological loop (verbal info)
  - Visuospatial sketchpad (visual/spatial info)
- **Baddeley (2000) revision** — added *episodic buffer*
- **Capacity limits:**
  - Classic: 7±2 items (Miller, 1956)
  - Modern (active manipulation): 4 items (Cowan, 2001)

## Summary
Working memory is a limited-capacity cognitive system. The Baddeley & Hitch (1974) three-component model (central executive, phonological loop, visuospatial sketchpad) was later extended with an episodic buffer. Capacity estimates shifted from 7±2 (Miller) to approximately 4 items for active manipulation (Cowan).
```

## Writing-profile integration

Three-tier rule based on note section and word count:

- **Cues column (Cornell):** Always terse — question fragments, not prose. Writing profile is not consulted; cues are question-mode keywords, not sentences.
- **Notes body:** Neutral reference style by default. If any single note-item paragraph exceeds approximately 80 words, consult `context/writing-profile.md` for tone and sentence-length guidance.
- **Summary:** Typically meets or exceeds 100 words — full writing-profile consultation applies. Apply the user's tone, sentence-length preferences, and pet peeves from `context/writing-profile.md`.

For Outline and Zettelkasten notes: apply writing-profile only to any closing synthesis paragraph that exceeds 100 words. Bullet content remains neutral reference style.

## Example prompts

- "Take notes on this biology chapter."
- "Make notes from my Notes/psychology-reading.md."
- "I'm reading this paper for class — can you help me study it?"
- "What's important in this article? Give me something I can review later."
