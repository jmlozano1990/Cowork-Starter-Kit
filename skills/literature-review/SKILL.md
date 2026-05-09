---
name: literature-review
description: Organize multiple sources into a thematic matrix with cross-source synthesis and gap analysis, stating detected theme and source counts at the top of the output.
trigger_examples:
  - "Write a literature review on [X]"
  - "Give me a lit review of these papers"
  - "I'm writing a survey on [X]"
  - "I need the lit review chapter for [Z]"
  - "What are the research gaps in [topic]?"
---

## When to use

Use this skill when the user supplies multiple sources — papers, abstracts, excerpts, or articles — and needs a structured thematic review rather than a flat summary or per-source analysis. Literature review is thematic by definition: it organizes the source set by concept or argument, not by publication date.

Distinct from research synthesis: literature review groups sources under auto-detected themes (rows) and evaluates each theme across the source set (columns = sources). Research synthesis produces a 7-column per-source matrix. Use literature review when the output is a review-style document intended for a paper, thesis, or survey chapter.

If the user needs a citation-worthy structured document with explicit agreements, disagreements, and gaps framed at peer-review rigor, prefer research-synthesis instead.

## Triggers

- User says "Write a literature review on [X]" or "Give me a lit review of these papers" — highest-confidence direct invocation.
- User pastes 3 or more abstracts, excerpts, or papers with no specific ask — proactively offer literature review.
- User says "I'm writing a survey on [X]" or "I need to cover the field of [Y]" — offer literature review as the primary deliverable.
- User says "I need the lit review chapter for [Z]" (thesis or dissertation context) — offer literature review with expanded gap analysis; thesis gap sections are typically longer than paper gap sections.

## Instructions

1. Read all provided sources fully before detecting themes.
2. Auto-detect themes from the source set — do not impose themes from outside the sources. A theme is a concept, argument, or research question that at least two sources address directly or implicitly.
3. State the detected theme count and source count in one line at the top of the output (e.g., "**Themes detected:** 3 (Capacity, Components, Evolution of model). **Sources:** 3.") so the user can recalibrate scope before reading further.
4. Build the thematic matrix: rows = themes, columns = sources. Each cell describes how that source addresses the row's theme, using terse noun phrases. Write "—" if the source does not address the theme.
5. For each theme, write a thematic synthesis paragraph that compares how sources treat the theme — do not summarize sources in sequence. Surface agreements, tensions, and nuance across sources.
6. Write the `## Research Gaps` section: list 2–5 gaps, each with a bold gap name and a short explanatory clause. A gap is a theme that is under-covered across the source set, a methodological weakness shared by most sources, or an important question none of the sources address.
7. Distinguish primary, secondary, and tertiary sources where relevant. Note if a source is a review paper or meta-review (tertiary); do not treat its claims as primary evidence.
8. If source methodology is relevant to the theme, note methodological differences in the matrix cell or in the synthesis paragraph — sources using incompatible designs cannot be directly compared without flagging the mismatch.
9. Apply the writing-profile rule from `## Writing-profile integration` to synthesis paragraphs and gap clauses.
10. Apply the BibTeX extension if the user has supplied citation keys or `.bib` entries.

## Output format

Plain GitHub-flavored markdown in the chat.

**Header line (required):** One line stating theme count, theme names, and source count. Example: `**Themes detected:** 3 (Capacity, Components, Evolution). **Sources:** 3.`

**Thematic matrix block:** Standard markdown table — rows = themes, columns = sources. Cells are terse noun phrases. Write "—" for absent coverage.

**Thematic synthesis section:** One subsection per theme (use `**Theme name.**` bold inline header or `### Theme name` subheading). Each subsection is a prose paragraph comparing how sources treat the theme — not a per-source summary.

**Research Gaps section:** Headed `## Research Gaps`. Bullet list of 2–5 gaps, each formatted as `- **Gap name** — short explanatory clause.`

**BibTeX-aware extension (conditional):** If the user supplies citation keys or `.bib` entries, render each source column header with `@key` and use `[@key]` inline citations in synthesis paragraphs. Otherwise use `Author (Year)` format.

No Obsidian `[[wikilinks]]`. No JSON or YAML sidecar. No CSV export. Output is portable across Obsidian, Notion, Apple Notes, Logseq, plain-text editors, and academic writing tools.

## Quality criteria

1. Themes auto-detected from the source set — not imposed externally. Theme count and source count stated at top.
2. Every matrix cell traces back to a specific source passage — no hallucinated claims.
3. Thematic synthesis produces cross-source comparison, not per-source summary.
4. Primary, secondary, and tertiary sources are distinguished (noted in matrix or synthesis).
5. Methodology assessment present — notes where sources use incompatible designs.
6. `## Research Gaps` section lists 2–5 gaps, each with a short explanatory clause.
7. Matrix cells terse; synthesis prose and gap clauses adapt to writing-profile.md.

## Anti-patterns

- Chronological-only ordering of sources, ignoring thematic structure — literature review is thematic by definition.
- No cross-source thematic synthesis — each theme row must compare how sources treat the theme, not list their contents in sequence.
- No research gap identification — a literature review without gaps is a summary, not a review.
- Treating review papers as primary sources — meta-reviews of other reviews must be labeled tertiary.
- Citation drift — a claim in the thematic synthesis cannot be traced back to a specific source column.
- No methodology assessment — ignoring that sources may use incompatible designs (empirical vs. theoretical vs. review).
- Listing sources without critical evaluation — descriptive paraphrases only, no judgment on evidence quality or authority.

## Example

**Input (3 abstracts):**

> **Miller (1956).** "The Magical Number Seven, Plus or Minus Two." Reviews span-of-attention and immediate-memory experiments across modalities. Proposes capacity ≈ 7±2 items.
>
> **Baddeley (2000).** "The Episodic Buffer." Theoretical extension of the 1974 Baddeley & Hitch working-memory model, adding a fourth component (episodic buffer) that integrates phonological loop, visuospatial sketchpad, and long-term memory.
>
> **Cowan (2001).** "The Magical Number 4 in Short-Term Memory." Multi-paradigm review (visual arrays, running span, auditory recall) arguing active-focus capacity is ~4 items once chunking and rehearsal are controlled.

**Output:**

```markdown
# Literature review: Working-memory capacity and architecture

**Themes detected:** 3 (Capacity, Components, Evolution of model). **Sources:** 3.

## Thematic matrix

| Theme | Miller (1956) | Baddeley (2000) | Cowan (2001) |
|-------|---------------|-----------------|--------------|
| Capacity | ~7±2 items across modalities (conflates chunked & unchunked units) | — (capacity not the focus) | ~4 items active focus (chunking/rehearsal controlled) |
| Components | Single undifferentiated short-term store | 4-component model (central executive, phonological loop, visuospatial sketchpad, episodic buffer) | Attentional-focus model, orthogonal to component theory |
| Evolution of model | Foundational (1956 baseline) | Extends Baddeley & Hitch (1974) with episodic buffer for LTM integration | Refines Miller (1956) downward; attentional rather than structural |

## Thematic synthesis

**Capacity.** The field shifted from Miller's 7±2 (observable span) toward Cowan's ~4 (underlying active focus) as chunking and rehearsal were controlled for. These are not contradictory — they operate at different levels of analysis.

**Components.** Baddeley (2000) treats working memory as structurally partitioned (multiple stores + a buffer). Cowan (2001) treats it as attention-limited (a focus window). Miller (1956) predates both debates.

**Evolution.** Baddeley (2000) is cumulative — extends the 1974 model. Cowan (2001) is revisionary — narrows Miller (1956). The field has diverged from a single-store view into two parallel research programs.

## Research Gaps

- **Neuroimaging evidence absent** — no source cites fMRI or EEG evidence for the proposed components or capacity bounds. A 21st-century neuroimaging review would anchor the structural/attentional debate in biological evidence.
- **Individual differences** — capacity estimates are reported as population means; no source addresses variance across age, working-memory disorders, or expertise-driven chunking differences.
- **Cross-modal interaction** — the phonological loop vs. visuospatial sketchpad boundary is treated as given; no source critically examines whether they genuinely dissociate at the neural level.
```

## Writing-profile integration

Four-tier rule based on output section:

- **Matrix cells:** Always terse — short noun phrases, no prose. `context/writing-profile.md` is not consulted; cells are structured data, not sentences.
- **Theme + source count line** (top of output): one-sentence factual statement, profile-neutral.
- **Thematic synthesis paragraphs:** Full writing-profile consultation applies — tone, sentence-length preferences, and pet peeves from `context/writing-profile.md`. Synthesis paragraphs typically exceed 100 words, triggering the adapt-to-profile rule. Apply the user's style to cross-source prose, not to matrix rows.
- **Research Gaps bullets:** Adapt to writing-profile.md for the short explanatory clause after the bold gap name; the gap name itself stays terse.

## Example prompts

- "Conduct a literature review on cognitive load theory using the papers in my Literature/ folder."
- "Organize these 5 papers into themes for a literature review section."
- "What gaps exist in the literature on attention and working memory based on my current sources?"
- "I need the lit review chapter for my thesis on [topic] — start with these abstracts."
