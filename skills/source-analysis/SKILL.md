---
name: source-analysis
description: Evaluate a single source across 7 structured fields (source type, authority, methodology, evidence quality, limitations, bias, bottom line) with an explicit citation recommendation.
trigger_examples:
  - "Evaluate / critique / analyze this paper"
  - "How good is this source?"
  - "Can I cite this?"
  - "I'm thinking of citing [X] for [claim]"
---

## When to use

Use this skill when the user has a single source — a paper, article, book chapter, or preprint — and needs a structured evaluation of its credibility, authority, and citability. Source analysis produces a judgment, not a summary.

Distinct from literature review and research synthesis: those skills work across multiple sources. Source analysis focuses entirely on one source and delivers a citation recommendation as its final output. Use it when the key question is "Can I cite this? For what kinds of claims? With what caveats?"

If the user shares multiple sources and wants comparison, prefer literature review or research synthesis instead.

## Triggers

- User says "Evaluate / critique / analyze this paper" or "How good is this source?" — highest-confidence direct invocation.
- User pastes a single paper abstract or excerpt with no specific ask — proactively offer source analysis.
- User asks "Can I cite this?" or "Is this source any good?" — offer source analysis with citation-recommendation framing.
- User says "I'm thinking of citing [X] for [claim]" — offer source analysis with Bottom line tuned to the specific claim.

## Instructions

1. Read the provided source fully before beginning the evaluation.
2. State the source type at the top of the output (Primary / Secondary / Tertiary) with a one-sentence justification so the user can recalibrate citation strategy before reading further.
3. Complete all 7 fields in order. Do not skip or mark a field "N/A" without explanation.
4. **Source type** — Primary (original empirical data or argument), Secondary (review, synthesis, or commentary on primary sources), or Tertiary (meta-review of reviews, encyclopedias, textbooks). Justify in one sentence.
5. **Authority** — author credentials, institutional affiliation, track record (h-index or key prior work if relevant), and domain fit. Note if the author is writing outside their primary field of expertise.
6. **Methodology** — study design (empirical / theoretical / review / meta-analysis), sample, and measures where applicable. Assess whether the method is appropriate for the main claim.
7. **Evidence quality** — strength of evidence supporting the main claim. Does it converge with other studies or is it an isolated result? Note replication status if known.
8. **Limitations** — distinguish what the author acknowledges and what the author omits. Every source has limitations; a complete analysis names both categories.
9. **Bias assessment** — funding source, ideological framing, methodological narrowness, and motivated framing. State bias level explicitly (low / moderate / high) with reasoning.
10. **Bottom line** — write a narrative judgment paragraph answering: Can this source be cited? For what kinds of claims? With what caveats? Apply the writing-profile rule from `## Writing-profile integration` to this paragraph.
11. Apply the BibTeX extension if the user supplies citation keys: use `@key` references throughout.

## Output format

Plain GitHub-flavored markdown in the chat.

**Source type declaration (required, at top):** `**Source type:** [Primary/Secondary/Tertiary] — one-sentence justification.`

**7 fields as labeled list:** Each field rendered as a `**Field name:**` bold-label line, with field content on the same or following line. Fields 1–6 are typically 1–3 sentences each. Use complete sentences, not bullets, within each field.

**Bottom line:** A standalone paragraph (typically 100 words or more) that delivers the citation recommendation. This is the interpretive payoff of the analysis.

No tables by default — the 7 fields are a fixed schema, not a comparison matrix. No Obsidian `[[wikilinks]]`. No JSON or YAML sidecar. Portable across academic writing tools and plain-text editors.

## Quality criteria

1. Source type (primary/secondary/tertiary) stated explicitly at top with one-sentence justification.
2. All 7 fields populated — no field skipped or marked "N/A" without explanation.
3. Authority field addresses credentials, domain fit, and track record — not just the author's name.
4. Methodology field describes design, sample, and measures where applicable.
5. Limitations section distinguishes author-acknowledged from author-omitted limitations.
6. Bias assessment is explicit (low / moderate / high) with reasoning.
7. Bottom line delivers a citation recommendation — answers "can I cite this? for what? with what caveats?"

## Anti-patterns

- Summarizing the source instead of evaluating it — a good summary is not source analysis.
- Accepting the author's framing uncritically — analysis must surface what the author is not saying.
- Ignoring methodology — citing a 30-subject pilot and a 3000-subject RCT as equivalently authoritative.
- No authority assessment — failing to note when a source is outside the author's field of expertise.
- No limitations surfaced — every source has limitations; if none are listed, the analysis is incomplete.
- Conflating primary with secondary — treating a review paper's claim as though it were original evidence.
- No explicit bottom-line judgment — analysis must end with a citation recommendation, not drift into summary.

## Example

**Input:** Baddeley (2000). "The Episodic Buffer: A new component of working memory?" *Trends in Cognitive Sciences*, 4(11), 417–423.

**Output:**

```markdown
# Source analysis: Baddeley (2000) — The Episodic Buffer

**Source type:** Secondary (theoretical review article extending a prior model).

**Authority:** Alan Baddeley — emeritus professor, University of York; co-originator of the working-memory model (Baddeley & Hitch 1974); h-index >130; this paper is within the author's primary research domain and extends his own theoretical framework.

**Methodology:** Theoretical paper — no new empirical data. Synthesizes prior empirical findings (cross-modal binding, prose recall, amnesiac integration performance) to motivate a new model component. Argument structure: (1) limits of the original 3-component model, (2) empirical anomalies the buffer resolves, (3) buffer properties.

**Evidence quality:** Claims are consistent with the cited empirical record at the time. The episodic buffer proposal has since been adopted as standard in the working-memory literature (see Baddeley 2012 for follow-up). However, direct empirical evidence for the buffer as a structurally distinct component (vs. an emergent property of executive attention) remains contested.

**Limitations acknowledged by author:** "The nature of the buffer is still to be determined" — Baddeley notes the proposal is a placeholder for integrating capacity. Limits on buffer capacity and its relationship to long-term memory are left as open questions.

**Limitations omitted by author:** The paper does not engage seriously with attentional-focus alternatives (Cowan 1999) that can account for the same empirical anomalies without requiring a new structural component. The buffer is presented as the resolution; alternative models are mentioned only briefly.

**Bias assessment:** Low-to-moderate. The author is extending his own model — mild theoretical commitment bias. No funding-source concerns. Publication venue (*Trends in Cognitive Sciences*) is reputable and peer-reviewed.

**Bottom line:** Citable as the canonical statement of the episodic buffer proposal. Appropriate for: (1) describing the 4-component working-memory model in its mature form, (2) grounding discussions of binding and integration in working memory. Caveat: when citing, acknowledge the buffer remains theoretically contested and Cowan's attentional-focus alternative should be mentioned in any thorough treatment.
```

## Writing-profile integration

Two-tier rule based on output section:

- **Fields 1–6** (Source type, Authority, Methodology, Evidence quality, Limitations, Bias assessment): structured judgment — terse clauses, minimal prose. `context/writing-profile.md` is not consulted; these fields are structured data.
- **Bottom line:** Narrative judgment paragraph — full writing-profile consultation applies. Tone, sentence-length preferences, and pet peeves from `context/writing-profile.md` apply to this paragraph only. The Bottom line typically exceeds 100 words, triggering the adapt-to-profile rule.

## Example prompts

- "Analyze this paper: [paste abstract or filename]."
- "Is this source credible and relevant to my research on [topic]?"
- "Can I cite this for my claim about [X]?"
- "What are the methodological strengths and limitations of this study?"
