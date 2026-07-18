# Skills Roadmap — v2.2 Discovery

**Produced:** 2026-05-08 | **Cycle:** v2.2 | **Author:** @dev (W2 deliverable)

This document is a planning artifact for the v2.3+ release cycle. It synthesizes the v2.2 pre-spec research (`docs/research/v2.2-skill-landscape.md`) and persona data (`docs/personas.md`) into three planning outputs: a per-stub ROI verdict, a persona-JTBD coverage matrix, and a ranked gap-fill recommendation list. None of the verdicts or recommendations here commit v2.3 to a specific action — they are inputs to the next @pm Phase 0 scoping.

---

## Section 1 — Per-Stub ROI Scan

All 12 current stub skills (depth: 16 lines, stub-only frontmatter) are evaluated for their optimal disposition path. Four verdict tokens are used:

- **COVER-BY-RUNTIME** — the JTBD is adequately served by Anthropic's runtime-hosted tools (XLSX/PPTX/DOCX/PDF skills, Research mode, general Claude capability). In-tree expansion would be redundant.
- **COVER-BY-EXTERNAL** — a qualified external skill from a vetted source repo (MIT/Apache 2.0, SHA-pinnable, last commit within 12 months) covers this JTBD better than in-tree development could. Prefer import over build.
- **EXPAND-IN-TREE** — in-tree 9-section depth expansion (per ADR-015) is the right path. No external candidate clears the vetting bar, and the JTBD is underserved by the runtime baseline.
- **REMOVE** — the stub's JTBD is fully served elsewhere (runtime or full-depth in-tree skill), and the stub adds noise without value.

### Writing preset stubs

| Skill | Description (from registry) | Verdict | Justification |
|-------|----------------------------|---------|---------------|
| editing-pass | Performs structured editing at light, medium, or heavy depth | EXPAND-IN-TREE | General Claude capability handles light proofreading, but structured multi-depth editing with explicit stage gates (light → medium → heavy) is not runtime behavior. No external candidate clears Tier 1 vetting for this specific workflow. Sam and Alex both need this at depth. |
| outline-generator | Builds a detailed hierarchical outline for any content type from a brief description | EXPAND-IN-TREE | Claude can outline, but the structured hierarchical format — with content-type branching (essay vs. lab report vs. newsletter) and JTBD-specific depth guidance — is not a runtime default. In-tree 9-section expansion gives Sam and Alex the content-type specificity they need. |
| voice-matching | Analyzes writing samples to match tone, vocabulary, and sentence rhythm in new content | EXPAND-IN-TREE | This is Sam's highest-value skill and the primary v1.2 design target. Runtime Claude does tone-matching on request, but a persistent voice-matching skill that encodes pattern extraction, sample analysis, and anti-AI guidance into a repeatable workflow is meaningfully better. No external candidate with equivalent depth found. |

### Creative preset stubs

| Skill | Description (from registry) | Verdict | Justification |
|-------|----------------------------|---------|---------------|
| creative-brief | Structures a vague creative concept into a clear brief with goals, constraints, and success criteria | EXPAND-IN-TREE | Structuring a brief is a knowledge-work workflow, not a general capability. A 9-section skill with JTBD-specific sections (e.g., brand constraints, audience fit, success criteria format) would materially improve on the runtime default for Sam and Riley. No external candidate vetted. |
| feedback-synthesizer | Consolidates feedback from multiple sources into actionable themes and prioritized revisions | EXPAND-IN-TREE | Feedback consolidation is a real workflow gap: the runtime can summarize feedback, but synthesis with deduplication, theme weighting, and prioritization order is not default behavior. Relevant to Sam (writing feedback), Maria (analyst review cycles), and Riley (cross-team input). |
| ideation-partner | Generates diverse creative directions, builds on half-formed ideas, and breaks creative blocks | EXPAND-IN-TREE | General Claude is already a capable ideation tool, but the specific structure of a skill (entry point, diverge phase, converge phase, anti-block techniques) adds predictability and repeatability that Sam and Riley value. Marginal lift over runtime is moderate, making this lower priority than voice-matching or editing-pass. |

### Business-admin preset stubs

| Skill | Description (from registry) | Verdict | Justification |
|-------|----------------------------|---------|---------------|
| action-items | Extracts clear, assigned, deadline-tagged action items from meeting notes or email threads | COVER-BY-RUNTIME | The existing full-depth `meeting-notes` skill already extracts action items as part of its workflow. The runtime also handles this well for ad-hoc requests. A standalone stub adds overlap with meeting-notes without adding depth. Unless meeting-notes is removed, action-items is redundant. |
| doc-summary | Summarizes long documents, reports, or proposals into executive-ready highlights | COVER-BY-RUNTIME | Anthropic's DOCX/PDF runtime skills handle document ingestion and summary. General Claude performs well on summarization tasks. An in-tree 9-section skill would need to add structural novelty (e.g., executive-vs-technical audience branching) to clear the redundancy bar — a viable path for v2.3 if scoped tightly. |
| email-drafting | Drafts professional emails matched to audience, tone, and intent from short bullet notes | EXPAND-IN-TREE | The runtime handles email drafting, but tone-matched drafting from bullet notes with audience-context encoding is a specific enough workflow to justify a 9-section skill. Maria's client-ready email output and Sam's newsletter audience targeting both benefit from an opinionated workflow. Moderate priority. |

### Personal-assistant preset stubs

| Skill | Description (from registry) | Verdict | Justification |
|-------|----------------------------|---------|---------------|
| daily-briefing | Summarize today's schedule, open tasks, and pending follow-ups into a concise morning brief from local files | EXPAND-IN-TREE | This is Casey's highest-retention skill. The runtime has no equivalent — Claude cannot autonomously pull from local calendar, tasks, and notes without explicit skill scaffolding. A 9-section depth expansion with file-read patterns and output format guidance is the right path for Casey's primary use case. High priority. |
| follow-up-tracker | Log and surface pending commitments from conversations, notes, and inbox snippets | EXPAND-IN-TREE | No runtime equivalent exists for commitment tracking across sources (group chat, email, calendar). This is Casey's second-highest-value skill and has no meaningful external candidate. The JTBD (relationship-labor surfacing) is distinct from meeting-notes action items — personal vs. professional obligation scope. |
| spend-awareness | Summarize pasted transaction data by category in plain language to surface spending patterns | EXPAND-IN-TREE | The XLSX runtime skill handles spreadsheet data, but spend-awareness is a pasted-text-input skill — the user pastes a bank export, not uploads a file. The runtime does not handle this workflow, and the skill's non-advice framing (descriptive only, no investment recommendations) requires explicit encoding that a 9-section skill provides cleanly. |

**Summary:** 9 stubs → EXPAND-IN-TREE, 2 → COVER-BY-RUNTIME, 0 → COVER-BY-EXTERNAL, 0 → REMOVE. The COVER-BY-RUNTIME verdicts (action-items, doc-summary) are both business-admin stubs with meaningful overlap with existing full-depth skills or runtime defaults. No stub is recommended for removal — the gap between the current 16-line depth and the runtime baseline is real for all others.

---

## Section 2 — Persona × JTBD Coverage Matrix

Coverage sources evaluated:

- **21 builtin skills** — full-depth (study/research/PM skills) and stub (writing/creative/business-admin/PA skills)
- **Anthropic runtime** — XLSX/PPTX/DOCX/PDF hosted skills (referenced in WIZARD.md §Also); Claude.ai Research mode (multi-step web search with citations)
- **General Claude** — base model capability without skill scaffolding

Coverage levels: **FULL** = skill or runtime directly satisfies JTBD | **PARTIAL** = adjacent or incomplete coverage | **RUNTIME** = addressed by Anthropic runtime tools (not an in-tree skill) | **EMPTY** = no meaningful coverage

Personas: **Alex** (student, biochem), **Maria** (research analyst), **Sam** (creator/newsletter), **Casey** (life admin), **Riley** (prosumer builder), **Morgan** (objective-first, novel use case)

| JTBD | Alex | Maria | Sam | Casey | Riley | Morgan |
|------|------|-------|-----|-------|-------|--------|
| J1: Synthesize 15–20 papers into structured summary | FULL (research-synthesis, literature-review) | FULL (same) | EMPTY | EMPTY | PARTIAL (research-synthesis) | PARTIAL |
| J2: Generate flashcards for active recall | FULL (flashcard-generation) | EMPTY | EMPTY | EMPTY | EMPTY | EMPTY |
| J3: Format citations (APA/MLA/Chicago) | FULL (citation-formatter — phantom 2026-05→07, pool file shipped 2026-07-06 per audit F-2 / roadmap idea 10) | FULL | FULL | EMPTY | PARTIAL | PARTIAL |
| J4: Draft and revise structured documents | PARTIAL (editing-pass stub, outline-generator stub) | PARTIAL (editing-pass stub) | PARTIAL (editing-pass, voice-matching, outline-generator — all stubs) | EMPTY | EMPTY | EMPTY |
| J5: Produce PM status updates | FULL (status-update) | FULL | EMPTY | EMPTY | FULL | FULL |
| J6: Extract action items from meetings | FULL (meeting-notes, action-items stub) | FULL | EMPTY | PARTIAL (meeting-notes) | FULL | FULL |
| J7: Analyze tabular/spreadsheet data | RUNTIME (XLSX skill) | RUNTIME | EMPTY | RUNTIME | RUNTIME | RUNTIME |
| J8: Research topic using live web sources | RUNTIME (Research mode) | RUNTIME | RUNTIME | EMPTY | RUNTIME | RUNTIME |
| J9: Create slides/presentation decks | RUNTIME (PPTX skill) | RUNTIME | RUNTIME | EMPTY | RUNTIME | RUNTIME |
| J10: Organize financial/expense records | PARTIAL (spend-awareness stub) | EMPTY | EMPTY | PARTIAL (stub) | EMPTY | EMPTY |
| J11: Surface missed commitments/follow-ups | EMPTY | EMPTY | EMPTY | PARTIAL (follow-up-tracker stub) | EMPTY | EMPTY |
| J12: Maintain consistent brand voice | EMPTY | EMPTY | PARTIAL (voice-matching stub) | EMPTY | EMPTY | EMPTY |
| J13: Assess and communicate project risks | PARTIAL (risk-assessment) | FULL | EMPTY | EMPTY | FULL | FULL |
| J14: Cross-domain workspace in one session | EMPTY | PARTIAL | EMPTY | EMPTY | PARTIAL (v2.0 architecture) | PARTIAL |
| J15: Generate creative ideation/briefs | EMPTY | EMPTY | PARTIAL (ideation-partner, creative-brief — stubs) | EMPTY | EMPTY | EMPTY |
| J16: Draft client-ready emails by tone/audience | PARTIAL (email-drafting stub) | PARTIAL (stub) | PARTIAL (stub) | EMPTY | PARTIAL | EMPTY |
| J17: Morning briefing from local calendar/tasks | EMPTY | EMPTY | EMPTY | PARTIAL (daily-briefing stub) | EMPTY | EMPTY |
| J18: Structured feedback consolidation | EMPTY | PARTIAL (feedback-synthesizer stub) | PARTIAL (stub) | EMPTY | PARTIAL | EMPTY |
| J19: Behavioral pattern analysis from meetings | EMPTY | EMPTY | EMPTY | EMPTY | EMPTY | EMPTY |
| J20: Contract/NDA structured review | EMPTY | PARTIAL (general Claude) | EMPTY | EMPTY | PARTIAL (general Claude) | EMPTY |

**EMPTY-cell gap clusters by priority:**

- **J19 (meeting behavioral analysis)** — EMPTY for all 6 personas. No stub, no runtime equivalent.
- **J20 (contract review)** — EMPTY for 4 personas; general Claude covers at low quality for 2.
- **J11 (follow-up tracking)** — EMPTY for 5 personas; stub coverage for Casey only.
- **J12 (brand voice)** — EMPTY for 5 personas; stub for Sam only.
- **J17 (daily briefing)** — EMPTY for 5 personas; stub for Casey only.
- **J4 (structured document drafting)** — PARTIAL or EMPTY for all 6; all relevant skills are stubs.
- **J14 (cross-domain workspace)** — PARTIAL for Riley/Morgan/Maria; EMPTY for Alex/Sam/Casey.

---

## Section 3 — Gap Analysis and Ranked v2.3+ Recommendations

Scoring formula: `persona_coverage × frequency × output_quality_lift / development_cost`

- Persona coverage: count of {Alex, Maria, Sam, Casey, Riley, Morgan} meaningfully served (1–6)
- Frequency: how often the JTBD arises for served personas (1 = rare, 3 = weekly+)
- Output quality lift: improvement over current fallback (1 = marginal, 5 = no alternative)
- Development cost: in-tree build effort or adapter cost for external import (S=1, M=2, L=3)

### Ranked Candidates

**1. Expand `voice-matching` stub to full depth (in-tree, EXPAND-IN-TREE)**

| Field | Value |
|-------|-------|
| Gap filled | J12 (brand voice consistency) — PARTIAL → FULL for Sam |
| JTBD coverage | Sam (primary, very high frequency), Alex (academic voice), Maria (professional tone) |
| Persona coverage | 3 of 6 |
| Frequency | 4 — Sam: every output; Alex: every lab report; Maria: every client deliverable |
| Output quality lift | 5 — no runtime equivalent for persistent voice encoding |
| Development cost | M |
| Score | (3 × 4 × 5) / 2 = 30 |
| License | Builtin — no external dependency |
| Go/no-go | GO — highest ROI in-tree expansion; Sam's primary pain point since v1.2 design |

**2. Expand `daily-briefing` stub to full depth (in-tree, EXPAND-IN-TREE)**

| Field | Value |
|-------|-------|
| Gap filled | J17 (morning briefing from local files) — PARTIAL → FULL for Casey |
| JTBD coverage | Casey (primary, daily), Riley (cross-domain task surface) |
| Persona coverage | 2 of 6 |
| Frequency | 5 — Casey: daily use case; this is the primary retention driver for the PA preset |
| Output quality lift | 5 — no runtime equivalent (requires local file access pattern) |
| Development cost | M |
| Score | (2 × 5 × 5) / 2 = 25 |
| License | Builtin — no external dependency |
| Go/no-go | GO — Casey's highest-value skill; stub-only state is the primary weakness of the PA preset |

**3. Import `meeting-insights-analyzer` from ComposioHQ/awesome-claude-skills (external, COVER-BY-EXTERNAL)**

| Field | Value |
|-------|-------|
| Gap filled | J19 (meeting behavioral analysis) — EMPTY → FULL for Maria and Riley |
| Source | https://github.com/ComposioHQ/awesome-claude-skills |
| License | Apache 2.0 (confirmed) |
| SHA-pinnable | Yes |
| Persona coverage | 2 of 6 — Maria (primary), Riley (secondary) |
| Frequency | 3 — Maria: weekly client-facing meetings; Riley: weekly cross-functional |
| Output quality lift | 5 — no runtime equivalent for behavioral pattern analysis (distinct from transcript extraction) |
| Development cost | L — 480-line SKILL.md requires condensation to ~130 lines per ADR-015 standard |
| Score | (2 × 3 × 5) / 3 = 10 |
| License | Apache 2.0 permits derivative works with attribution — adapter is compliant |
| Go/no-go | CONDITIONAL GO — strong content quality, high adapter cost. Viable v2.3 candidate once ADR-028 adapter framework is established. Evaluate after #1 and #2 ship. |

**4. Expand `editing-pass` stub to full depth (in-tree, EXPAND-IN-TREE)**

| Field | Value |
|-------|-------|
| Gap filled | J4 (structured document drafting) — PARTIAL → FULL for Sam, Alex, Maria |
| JTBD coverage | Sam (newsletter structure), Alex (lab reports), Maria (analyst reports) |
| Persona coverage | 3 of 6 |
| Frequency | 3 — Sam and Alex: weekly; Maria: frequent |
| Output quality lift | 3 — general Claude handles editing; the workflow specificity (depth stages) is the lift |
| Development cost | M |
| Score | (3 × 3 × 3) / 2 = 13.5 |
| License | Builtin — no external dependency |
| Go/no-go | GO (lower priority than voice-matching) — bundle with outline-generator in a writing-stubs cycle |

**5. Import `contract-review` from evolsb/claude-legal-skill (external, COVER-BY-EXTERNAL)**

| Field | Value |
|-------|-------|
| Gap filled | J20 (contract/NDA review) — EMPTY/PARTIAL → FULL for Riley |
| Source | https://github.com/evolsb/claude-legal-skill |
| License | MIT (confirmed — Copyright Chris Sheehan) |
| SHA-pinnable | Yes (SHA e6c63c6) |
| Persona coverage | 2 of 6 — Riley (primary, pre-launch), Maria (occasional) |
| Frequency | 2 — Riley: high at pre-launch phase; Maria: occasional |
| Output quality lift | 5 — CUAD-grounded output is a distinct class above general Claude contract review |
| Development cost | S — compact SKILL.md (~120 lines), minor adapter work only |
| Score | (2 × 2 × 5) / 1 = 20 |
| License | MIT — import is straightforward |
| Go/no-go | CONDITIONAL GO — narrow persona coverage (Riley primary) but high output quality lift and low adapter cost. Strong candidate once ADR-028 is implemented. Best first-external-source candidate due to low adapter friction. |

### Prioritization Summary

| Rank | Candidate | Type | Score | Go/no-go | v2.3 priority |
|------|-----------|------|-------|----------|---------------|
| 1 | voice-matching (expand stub) | In-tree | 30 | GO | High |
| 2 | daily-briefing (expand stub) | In-tree | 25 | GO | High |
| 3 | contract-review (import evolsb) | External | 20 | Conditional GO | Medium — post ADR-028 |
| 4 | editing-pass (expand stub) | In-tree | 13.5 | GO | Medium — bundle with writing cycle |
| 5 | meeting-insights-analyzer (import ComposioHQ) | External | 10 | Conditional GO | Medium-Low — high adapter cost |

### Open Questions for v2.3 @pm Phase 0

1. **Stub cycle vs external source:** The top two ranked candidates are in-tree expansions. Does v2.3 run a dedicated writing+PA stub depth cycle first, then a separate external-source cycle? Or bundle both? Bundling risks scope creep; sequencing adds a cycle. Recommend two cycles (v2.3a stub expansion, v2.3b first external source), but user decides.

2. **ADR-028 implementation timing:** Candidates #3 and #5 both require ADR-028 `content_sha256` implementation in the lock schema before import. If v2.3 targets an external source, ADR-028 implementation is a mandatory v2.3 deliverable — @architect must spec it at Phase 1 before any import work begins.

3. **action-items and doc-summary stub disposition:** Both received COVER-BY-RUNTIME verdicts. The cleanest resolution is to document this in the registry (add a `disposition: covered-by-runtime` note) and suppress them from the team-composition output rather than removing the stub files. Removal would require an ADR-015 amendment; annotation is safer. v2.3 @pm should surface this decision to the user explicitly.

4. **J19 unserved gap (meeting behavioral analysis):** ComposioHQ's `meeting-insights-analyzer` is the only known candidate. If the adapter cost is acceptable, this fills the only EMPTY gap that affects two core personas (Maria, Riley) at the same time. Consider commissioning the adapter work as a standalone task before the v2.3 cycle opens formally.

---

*This document is a v2.2 planning artifact. It modifies no existing architecture surfaces, introduces no ADR, and makes no binding v2.3 commitments. A-v2.2-3 escalation gate: no recommendation above implies a v2.2-cycle architectural change. All external-import recommendations explicitly require ADR-028 implementation in a future cycle.*

*Generated: 2026-05-08 | Cycle: v2.2 W2*
