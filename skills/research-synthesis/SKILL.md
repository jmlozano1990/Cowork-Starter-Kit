---
name: research-synthesis
description: Synthesize sources at peer-review rigor using a 7-column matrix (claim, method, evidence, limitations, authority, recency, citation-network) with structured Agreements, Disagreements, Gaps, and Synthesis sections.
trigger_examples:
  - "Synthesize these papers rigorously"
  - "Cross-reference these sources at peer-review rigor"
  - "I'm preparing to review / referee [paper]"
  - "Systematic review of [X]"
  - "Meta-analysis inputs for [Z]"
---

## When to use

Use this skill when the user needs a rigorous multi-source synthesis at peer-review standards — where source authority, citation networks, and methodology comparisons matter as much as the substantive claims. This skill always operates at peer-review rigor regardless of source count.

This is the **Research preset variant** of `research-synthesis`. It is intentionally distinct from the Study preset's `research-synthesis`, which auto-selects a simplified mode by source count for exam-prep use. The Research variant is always peer-review-oriented: it evaluates source authority, citation chains, and methodology explicitly. Use this skill when the output will inform a paper, thesis, systematic review, or peer-review process.

If you need a thematic cross-cutting review with gap analysis rather than a per-source authority evaluation, prefer literature-review instead.

## Triggers

- User says "Synthesize these papers rigorously" or "Cross-reference these sources at peer-review rigor" — highest-confidence direct invocation.
- User says "I'm preparing to review / referee [paper]" or "Can you steelman and check these sources?" — offer research synthesis with disagreement-surfacing emphasis.
- User asks for a "systematic review of [X]" or "synthesis of the evidence on [Y]" — offer full matrix + gap analysis.
- User asks for "meta-analysis inputs for [Z]" or "quantitative synthesis of [W]" — offer synthesis as qualitative prelude; surface methodology compatibility explicitly.

## Instructions

1. Read all provided sources fully before beginning the matrix.
2. State the synthesis mode at the top of the output in one line: "Peer-review synthesis, N sources." This lets the user recalibrate before reading further.
3. Build the 7-column matrix with rows = sources, columns = Claim | Method | Evidence | Limitations | Authority | Recency | Citation network. Keep cells terse — short noun phrases only.
4. **Claim:** the source's central thesis or finding, in one phrase.
5. **Method:** study design (empirical / theoretical / review / meta-analysis / simulation), sample if applicable, key measures.
6. **Evidence:** strength of evidence supporting the claim. Note if it converges with other sources or is isolated.
7. **Limitations:** the most significant limitation relevant to how this source will be cited. Do not leave this blank.
8. **Authority:** author credentials, institutional standing, citation weight (approximate citation count if known), domain fit.
9. **Recency:** publication date and replication/adoption status. Note if a source is foundational (still valid) vs. partially superseded.
10. **Citation network:** note if the source is a foundational node (cited by most later work) or part of a citation chain (its apparent convergence may reflect chain, not independent replication).
11. Write the synthesis section with four required subsections in this order: **Agreements**, **Disagreements**, **Gaps**, **Synthesis**.
12. **Agreements:** where sources converge, and whether convergence reflects independent confirmation or citation chain.
13. **Disagreements:** methodological divergences, conflicting empirical findings, competing theoretical frames. Name the divergent programs or findings explicitly — do not describe disagreements vaguely.
14. **Gaps:** where the source set is silent or thin. Include both topical gaps (underrepresented themes) and methodological gaps (missing study designs).
15. **Synthesis:** one closing paragraph integrating the full picture — what the field collectively says, what remains open, what a future researcher needs to address.
16. Verify every synthesis claim traces to at least one named matrix row before writing it (no citation drift).
17. Apply the writing-profile rule from `## Writing-profile integration` to synthesis prose.
18. Apply the BibTeX extension if the user has supplied citation keys or `.bib` entries.

## Output format

Plain GitHub-flavored markdown in the chat.

**Mode line (required, at top):** One sentence stating mode and source count. Example: `**Mode auto-selected:** Peer-review synthesis, 3 sources.`

**7-column matrix block:** Standard GitHub-flavored markdown table — rows = sources, 7 columns (Claim, Method, Evidence, Limitations, Authority, Recency, Citation network). Cells are terse noun phrases. No prose in cells.

**Synthesis section:** Four subsections in order: `### Agreements`, `### Disagreements`, `### Gaps`, `### Synthesis` (closing integrative paragraph). Prose, not bullets, in each subsection.

**BibTeX-aware extension (conditional):** If the user supplies citation keys or `.bib` entries, render each source row with `@key` in the Source column and use `[@key]` inline citations in the synthesis. Otherwise use `Author (Year)` format.

No Obsidian `[[wikilinks]]`. No JSON or YAML sidecar. Portable across academic writing tools and plain-text editors.

## Quality criteria

1. Mode line states "Peer-review synthesis, N sources" at the top of the output.
2. All 7 matrix columns populated for every source — no column skipped.
3. Authority column addresses credentials, domain fit, and citation weight.
4. Citation-network column notes whether convergence reflects independent replication or citation chain.
5. Agreements, Disagreements, Gaps, and Synthesis sections all present — no section collapsed to "N/A" without explanation.
6. Disagreements section names the divergent research programs or conflicting findings explicitly, not vaguely.
7. Every synthesis claim traces to at least one matrix cell — no citation drift.

## Anti-patterns

- Equal-authority treatment — weighting a dissertation and a Nobel laureate's RCT identically.
- No citation-network analysis — failing to note when a claim appears in 3 sources that all cite a single foundational paper (apparent convergence is actually a citation chain).
- Ignoring publication venue rigor — treating a conference poster and a *Nature* paper as equivalent evidence strength.
- No methodology comparison across sources — ignoring that empirical, theoretical, and simulation studies produce different kinds of evidence.
- Citation drift — a synthesis claim cannot be traced to a specific matrix cell.
- Recency bias — treating older sources as outdated without checking replication status; treating newer sources as superseding older ones without checking whether they address the same question.
- Synthesis = concatenation — restating each source in sequence instead of producing cross-source insight that no single source stated.

## Example

**Input (3 sources, evaluated at research-rigor level):**

> **Miller (1956).** "The Magical Number Seven, Plus or Minus Two." *Psychological Review*, 63(2), 81–97. Review article. Miller: Harvard, co-founder of cognitive science. ~35,000 citations. Method: narrative review of span-of-attention experiments.
>
> **Baddeley (2000).** "The Episodic Buffer." *Trends in Cognitive Sciences*, 4(11), 417–423. Theoretical paper. Baddeley: Cambridge/York; h-index >130; originator of the dominant working-memory model. ~7,000 citations. Method: theoretical synthesis motivating a new model component.
>
> **Cowan (2001).** "The Magical Number 4 in Short-Term Memory." *Behavioral and Brain Sciences*, 24(1), 87–114. BBS target article with peer commentary. Cowan: Missouri; primary attentional-focus theorist. ~8,000 citations. Method: multi-paradigm review + re-analysis.

**Output:**

```markdown
# Research synthesis: Working-memory capacity

**Mode auto-selected:** Peer-review synthesis, 3 sources.

| Source | Claim | Method | Evidence | Limitations | Authority | Recency | Citation network |
|--------|-------|--------|----------|-------------|-----------|---------|------------------|
| Miller (1956) | Capacity ~7±2 items | Narrative review | Convergence across span tasks & modalities | Conflates chunked & unchunked units; no direct capacity isolation | Harvard, ~35K cites, foundational | 70 years old; partially superseded | Cited by nearly all subsequent WM work — foundational node |
| Baddeley (2000) | 4-component WM model (adds episodic buffer) | Theoretical synthesis | Accounts for cross-modal binding + amnesiac integration | No direct empirical test of buffer-as-structure | Cambridge/York, h>130, model originator | 25 years old; widely adopted | Extends Baddeley & Hitch (1974); cited by downstream component-model work |
| Cowan (2001) | Raw capacity ~4 items | Multi-paradigm review + re-analysis | Converges across visual arrays, running span, auditory recall | Active-focus framing, not total-WM framing | Missouri, ~8K cites, primary attentional theorist | 25 years old; widely cited; replication ongoing | Target article with 60+ peer commentaries — independent scrutiny node |

## Peer-review synthesis

### Agreements

The field converges on the view that observable short-term span overstates raw capacity. Miller's 7±2 is widely understood as an upper bound including chunking, while Cowan's ~4 approximates the underlying focus. Independent methodological streams (span tasks in Miller; chunking-controlled paradigms in Cowan) reach compatible conclusions — this is not a citation-chain artifact but genuine convergence from different methods.

### Disagreements

Baddeley (2000) and Cowan (2001) represent divergent research programs. Baddeley treats working memory as structurally partitioned (multiple stores + a binding buffer). Cowan treats it as attention-limited (a focus window gating long-term memory). The two programs account for overlapping empirical anomalies (cross-modal binding, prose recall) with different architectures, and the field has not converged on either. Methodologically, Baddeley relies on theoretical synthesis; Cowan relies on paradigm convergence — neither decisively adjudicates between structural and attentional framings.

### Gaps

Despite extensive citation cross-referencing, no source in this set is neuroimaging-based. The structural/attentional debate has proceeded largely behaviorally; fMRI/EEG evidence that might adjudicate the Baddeley–Cowan divide is not represented. A modern synthesis would incorporate work like Postle (2006) or D'Esposito & Postle (2015) to ground the debate in biological evidence.

### Synthesis

The short-term-memory capacity literature has matured from observable-span estimates (Miller) toward refined theoretical frameworks (Baddeley's structural; Cowan's attentional) that agree on capacity magnitude (~4 items active focus) but diverge on underlying architecture. The divergence is substantive, not semantic, and remains open absent neuroimaging evidence.
```

## Writing-profile integration

Four-tier rule based on output section:

- **Matrix cells:** Always terse — short noun phrases, no prose. `context/writing-profile.md` is not consulted; cells are structured data, not sentences.
- **Mode line** (top of output): one-sentence factual statement, profile-neutral.
- **Agreements / Disagreements / Gaps paragraphs:** Full writing-profile consultation applies — tone, sentence-length preferences, and pet peeves from `context/writing-profile.md`.
- **Disagreement framing sentences** (e.g., "Baddeley and Cowan represent divergent research programs"): profile-neutral — clarity and neutrality take precedence over voice to avoid the synthesis appearing to take a side.
- **Closing Synthesis paragraph:** Full writing-profile consultation applies.

## Example prompts

- "Synthesize these papers on protein folding at peer-review rigor."
- "I'm preparing to referee this paper — can you cross-reference its sources?"
- "Give me a systematic review of the evidence on [topic] from my Literature/ folder."
- "I need meta-analysis inputs on [topic] — synthesize these sources qualitatively first."
