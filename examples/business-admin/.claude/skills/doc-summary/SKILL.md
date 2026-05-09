---
name: doc-summary
description: Extract the key insight and supporting points from any business document for fast understanding and decision-making
trigger_examples:
  - "Summarize this document: [filename or paste text]"
  - "What is the key recommendation in this file?"
  - "Give me a 3-bullet executive summary I can share in a meeting"
  - "What decision does this document want me to make?"
---

## When to use

Use doc-summary when the user needs to quickly understand a long document, brief someone on its key findings, or extract a recommendation without reading the full text. This skill is appropriate for business documents, reports, research papers, proposals, briefing notes, and any text where the user needs the conclusion before the full read. Use it when the user is time-constrained, preparing for a meeting, or needs to share a summary with others. Do NOT use it as a replacement for a full read when the user needs to take legal, financial, or compliance action based on the document — flag this constraint and recommend a full read.

## Triggers

- User says "summarize", "summary", "tldr", "key points", or "doc-summary" — direct invocation.
- User pastes or references a document and asks what it says, what the recommendation is, or what they need to know.
- User asks for an executive summary, a one-pager, or a briefing they can share.
- User says "what should I take from this" or "what does this mean for me" after sharing a document.
- User needs to brief someone else on a document they have reviewed.

## Instructions

1. **Read the full document before producing any output.** Do not summarize section by section as you read — first identify the single most important finding, then produce the structured output. If the document is too long to read in one pass, process it in chunks but hold output until the complete read is done.
2. **Identify the headline insight first.** Every document worth summarizing has one most important finding, recommendation, or conclusion. State it in one sentence. If the document has no clear headline finding, ask the user: "What decision is this document meant to inform?" before proceeding — do not fabricate a headline.
3. **Produce the four-part output.** (1) **Headline insight** — one sentence, the most important takeaway; (2) **Supporting points** — 3–5 bullets of key data, findings, or arguments that back the headline; (3) **Recommended action** — if the document implies a decision or next step, state it in one sentence; if it does not, omit this section rather than fabricating one; (4) **Where to look for more** — name the single most relevant section for a reader who wants depth (e.g., "See Section 4.2 for the methodology details").
4. **Keep the total output under 150 words** unless the document's complexity genuinely requires more. The goal is to enable a decision, not to recap every finding. If the user explicitly asks for a longer summary, adjust accordingly.
5. **Flag documents with legal, financial, or safety content.** If the document contains content that requires professional judgment to act on — contracts, financial statements, medical records, compliance requirements — state: "This document contains [type] content. This summary is for orientation only — do not take action based on this summary alone without a full review."

## Output format

Four-section structured output under a single `## Summary` heading. Sections: `**Headline:** [one sentence]`, `**Key points:** [3–5 bullets]`, `**Recommended action:** [one sentence, or omit if none]`, `**For more depth:** [section name or range]`. Total output under 150 words unless the user requests otherwise. No prose paragraphs, no document title repetition, no page-by-page recap.

## Quality criteria

1. Headline is a single sentence that states the most important finding — not a topic description ("This document covers X") but a finding ("X shows that Y").
2. Supporting points back the headline — they do not introduce new topics or restate the headline.
3. Recommended action is one specific next step, not a list of possibilities.
4. Total output is under 150 words unless the user requested more.
5. Legal, financial, or safety content is flagged before presenting the summary.

## Anti-patterns

- **Topic description instead of headline** — writing "This report covers the Q3 financial performance" instead of "Q3 revenue missed target by 12% due to delayed product launch." The headline is a finding, not a description.
- **Supporting points that are just the headline rephrased** — adding three bullets that all say the same thing as the headline at lower fidelity. Supporting points must add new information.
- **Fabricating a recommended action** — stating what the user should do when the document does not actually contain a recommendation. If there is no recommended action, omit the section.
- **Exceeding the word budget without cause** — producing a 400-word summary of a one-page memo. Length must match the document's complexity and the user's stated need.
- **Replacing professional review** — presenting a summary of a legal contract, financial statement, or compliance document as sufficient for a decision. These documents require a full read and professional judgment.

## Example

**Input:** "Summarize this vendor proposal: [3-page proposal recommending switching to a new CRM platform, citing 30% cost savings and a 6-month migration timeline, with risks including data migration complexity and user adoption]"

**Output:**

## Summary

**Headline:** The proposal recommends switching CRM platforms for a projected 30% cost saving, with a 6-month migration timeline and two material risks.

**Key points:**
- 30% annual cost reduction vs. current platform, based on seat-count pricing
- 6-month migration timeline with milestone-based payment schedule
- Data migration complexity identified as primary technical risk
- User adoption flagged as requiring a change management plan

**Recommended action:** Commission a data migration audit before signing — the cost saving is credible but the migration risk is underspecified.

**For more depth:** See Appendix B for the migration timeline and pricing breakdown.

## Writing-profile integration

Doc-summary output follows the structural format above and does not adopt the user's writing voice for section labels or headline formatting. If the user's `context/writing-profile.md` includes preferences for list formatting (e.g., use dashes instead of bullets, or a specific tone for executive audiences), apply those preferences to the supporting points and recommended action sections only — not the headline or section labels.

## Example prompts

- "Summarize this document: [filename or paste text]"
- "What is the key recommendation in this report?"
- "Give me a 3-bullet executive summary I can share before the meeting."
- "What decision does this proposal want me to make? [paste proposal]"
