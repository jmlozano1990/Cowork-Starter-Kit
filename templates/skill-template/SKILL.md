---
name: [skill-slug]
<!-- Replace: folder name in snake-case, e.g. flashcard-generation — must match the parent folder name exactly -->
description: [one sentence describing what this skill enables Cowork to do]
<!-- Replace: ≤160 characters. Start with a verb: "Generate…", "Summarise…", "Draft…", "Extract…" -->
# trigger_examples is optional but recommended. Uncomment and fill in 3–6 trigger phrases.
# These allow global-instructions.md proactive rules to pattern-match without parsing the ## Triggers body.
# trigger_examples:
#   - "[phrase that reliably signals this skill should fire]"
#   - "[another signal phrase for the same skill]"
#   - "[a third trigger phrasing — vary the wording]"
---
<!-- CONTRIBUTOR NOTICE: Before editing the placeholder text in this template, read
     CONTRIBUTING.md §Placeholder authoring rules.
     The 5 rules govern how placeholders must be written to avoid shipping
     unintended runtime instructions to Cowork. Key: use bracketed nouns, never
     imperatives; never include Ignore/Disregard/Override/Instead/Always;
     use HTML comments for guidance text; no safety-rule patterns; Example
     placeholders must read as contributor-guidance, not Cowork instructions.

     This 9-section structure is the kit's open substrate contribution format
     (v2.18.0) — see docs/substrate-contribution-format.md for the full spec,
     the adapter-isolation boundary, and the external consumer contract both
     a future push and a future pull flow are built on. -->

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 1 — WHEN TO USE
     Purpose: Cowork reads this section first to decide whether to invoke this
     skill at all. Write 2–3 declarative sentences: the normal use case (1–2
     sentences) + one edge condition (1 sentence). Do NOT write imperatives
     ("You should…", "Always do…"). Target: 3–6 lines.
     ══════════════════════════════════════════════════════════════════════════ -->
## When to use

[One sentence — the primary scenario where this skill applies.]
[One sentence — a second situation or variation where it also applies.]
[One sentence — an edge condition or boundary: when a lighter approach is more appropriate.]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 2 — TRIGGERS
     Purpose: Bullet list of phrases or situations that signal Cowork should
     offer or auto-invoke this skill. Must stay consistent with the proactive
     rules in the preset's global-instructions.md (v1.1 three-layer trigger
     architecture). Target: 4–8 bullets.
     ══════════════════════════════════════════════════════════════════════════ -->
## Triggers

- [A direct user phrase that reliably signals this skill, e.g. "user says X"]
- [A task-type signal, e.g. "user shares a [document type] and asks for [output type]"]
- [A follow-up signal, e.g. "user asks to refine or expand an earlier output"]
- [A context signal, e.g. "a specific file type or folder is mentioned in the request"]
- [An implicit signal — what the user is trying to accomplish without naming the skill]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 3 — INSTRUCTIONS
     Purpose: Step-by-step execution guide for Cowork. Use numbered steps.
     Each step: one verb + one outcome. No prose paragraphs. Decompose any
     step that would exceed 2 lines into two steps.
     Target: 5–10 numbered steps.
     ══════════════════════════════════════════════════════════════════════════ -->
## Instructions

1. [First step — what Cowork reads or gathers before starting]
2. [Second step — the core processing or analysis action]
3. [Third step — how Cowork structures or organises the output]
4. [Fourth step — quality check or refinement before delivering]
5. [Fifth step — final delivery action or follow-up offer to the user]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 4 — OUTPUT FORMAT
     Purpose: Explicit structure Cowork must produce. Specify headings,
     list shapes, table schemas, counts, and length targets. A reviewer
     reading this section should be able to check the output without
     re-reading the instructions. Target: 4–10 lines.
     ══════════════════════════════════════════════════════════════════════════ -->
## Output format

[Opening line — the top-level structure, e.g. "Numbered list of [N] items."]

Each item follows this shape:

- [Field 1 label]: [description of what goes here and its length target]
- [Field 2 label]: [description of what goes here and its length target]

[One line — any count constraint, e.g. "Aim for [N]–[M] items unless the user specifies otherwise."]
[One line — closing action Cowork takes after delivering, e.g. "End with a note on which items seem most important."]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 5 — QUALITY CRITERIA
     Purpose: 3–5 checkable criteria a reviewer can evaluate as yes/no.
     Each bullet is one line. If a criterion cannot be checked by reading
     the output, rephrase it until it can. Target: 3–5 bullets.
     ══════════════════════════════════════════════════════════════════════════ -->
## Quality criteria

- [Criterion 1 — a structural check, e.g. "Output contains the required [element]"]
- [Criterion 2 — a content depth check, e.g. "Each [item] includes [required detail]"]
- [Criterion 3 — a scope check, e.g. "Output stays within [count/length] target"]
- [Criterion 4 — a user-value check, e.g. "Output would be directly usable without editing"]
- [Criterion 5 — an edge-case check, optional; remove this bullet if 4 criteria are sufficient]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 6 — ANTI-PATTERNS
     Purpose: 3–5 common mistakes Cowork must not make. One line each.
     Frame as "what NOT to do." Do not repeat quality criteria negated —
     anti-patterns should surface failure modes that a quality check would
     miss. Target: 3–5 bullets.
     ══════════════════════════════════════════════════════════════════════════ -->
## Anti-patterns

- [Anti-pattern 1 — a common structural mistake in this skill's output domain]
- [Anti-pattern 2 — a scope or depth error, e.g. "surface-level output that doesn't …"]
- [Anti-pattern 3 — a voice or format error, e.g. "treating all [input types] as equivalent when …"]
- [Anti-pattern 4 — a process error, e.g. "starting without reading [required input]"]
- [Anti-pattern 5 — optional; remove if 4 anti-patterns are sufficient]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 7 — EXAMPLE
     Purpose: ONE worked input→output pair. Use a real-looking, minimal
     example — not a hypothetical. The input should be brief enough to
     paste here (3–8 lines). The output should illustrate the full format
     specified in §Output format (not a truncated sketch).
     Contributor note: paste a real input and the ideal output you would
     accept in a PR review. Do NOT write instructions to Cowork here.
     Target: 15–40 lines total for this section.
     ══════════════════════════════════════════════════════════════════════════ -->
## Example

**Input:**

[Paste a real input here — e.g. a snippet of text, a user request, or a file excerpt
that represents the most common activation scenario for this skill.
Keep it to 3–8 lines so the example remains scannable.]

**Output:**

[Paste the ideal output here — the response Cowork should produce for the input above.
Match the structure in §Output format exactly. Include all required fields/sections.
Aim for a complete output, not a "..." truncated sketch — reviewers need to see the
real shape, not a placeholder for it.
Remove this parenthetical when you paste the actual example.]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 8 — WRITING-PROFILE INTEGRATION
     Purpose: One sentence stating WHEN this skill consults
     context/writing-profile.md, plus one concrete rule.
     Per v1.2 ADR-013: if output ≥100 words, the skill must reference the
     writing profile. If output is always <100 words, say so explicitly.
     Target: 1–4 lines.
     ══════════════════════════════════════════════════════════════════════════ -->
## Writing-profile integration

[One sentence — when this skill reads context/writing-profile.md, e.g.
"When output exceeds 100 words, Cowork consults context/writing-profile.md
and applies the user's stated tone, sentence-length preferences, and pet peeves."]
[One concrete rule, e.g. "If no writing profile exists, default to clear and direct prose." — or
"This skill produces structured data under 100 words; writing profile is not consulted."]

<!-- ══════════════════════════════════════════════════════════════════════════
     SECTION 9 — EXAMPLE PROMPTS
     Purpose: 3 realistic invocation phrases the user might type. These
     appear in skills-as-prompts.md and inform global-instructions.md
     trigger rules. Write prompts users actually say, not command syntax.
     Target: exactly 3 bullets.
     ══════════════════════════════════════════════════════════════════════════ -->
## Example prompts

- "[A direct invocation phrase — the most common way a user requests this skill]"
- "[A variation with a specific input — e.g. a file reference or a scope qualifier]"
- "[A follow-up or edge-case invocation — a less obvious but valid request for this skill]"

<!-- ADR-015 defines the canonical 9-section template and length budget.
     CI (skill-depth-check, ADR-016) enforces a 60-line floor: SKILL.md files
     in depth-enforced presets that fall below 60 lines will fail CI.
     This template targets 80–120 lines; the soft cap is 150 lines.
     Reference: docs/architecture.md §ADR-015. -->
