---
name: editing-pass
description: Review a draft and return specific, actionable editing suggestions at the level the writer requests
tools: [claude-code]
trigger_examples:
  - "Light edit this paragraph for grammar and flow"
  - "Heavy restructure this draft — the argument is unclear"
  - "Polish this for clarity and conciseness"
  - "Editing-pass on attached doc — medium depth"
---

## When to use

Use editing-pass when the user has a draft and wants targeted improvement at a specific depth: light (error correction only), medium (clarity and flow improvements), or heavy (structural rework). This skill is distinct from voice-matching (which writes new content) and outline-generator (which structures ideas before writing). Use it any time the user shares a draft and asks for feedback, cleanup, or revision — even without naming this skill explicitly.

## Triggers

- User says "edit this", "edit pass", "editing-pass", or "give this a pass" — direct invocation.
- User shares a draft and asks for feedback, cleanup, corrections, or revision.
- User specifies a depth level: "light edit", "medium edit", "heavy edit", "restructure", "polish", "clean up".
- User asks "what's wrong with this" or "how would you improve this" when a draft is pasted.

## Instructions

1. **Ask for the depth level if not stated.** Before editing, confirm: light (fix errors only — grammar, punctuation, typos), medium (improve clarity and flow — also flag awkward sentences, weak word choices, unclear transitions), or heavy (restructure and rewrite — reorganize sections, strengthen argument, rewrite weak passages). Do NOT assume the depth. If the user's request implies a depth (e.g., "just fix typos"), proceed without asking.
2. **For heavy edits, explain structural decisions first.** Before presenting the revised version, briefly describe any significant structural changes you are about to make and why. Wait for user confirmation if the structural changes are substantial (e.g., reordering major sections). For light and medium edits, proceed directly.
3. **Apply the edit at the requested depth.** Light: correct errors, preserve all structure and voice. Medium: correct errors plus improve sentence clarity, transition quality, and word choice — flag rather than change anything ambiguous. Heavy: correct, clarify, and restructure — reorder sections, sharpen the argument, rewrite weak passages.
4. **Produce a numbered change log.** After the revised text, list specific changes made with brief reasons. Format: `1. [Change] — [Reason].` Include at least one item per category modified. Do NOT produce a vague summary ("improved clarity throughout").
5. **Add one closing sentence.** State explicitly what you left alone and why — e.g., "Left the parenthetical asides in paragraphs 2 and 4 unchanged — they appear intentional." This prevents the user from wondering if something was missed.

## Output format

Present in this order: (1) revised text in full, (2) numbered change log, (3) one closing sentence on what was left untouched. Use plain markdown. No JSON, no YAML. Output is portable across Obsidian, Notion, Google Docs, and email clients.

## Quality criteria

1. The depth level was either stated by the user or confirmed before editing began.
2. The change log is numbered and specific — each item names the change and the reason, not a generic phrase like "improved clarity."
3. The closing sentence identifies at least one element that was deliberately preserved.
4. No anti-AI tics introduced in the revision (no hedging phrases, em-dash floods, generic transitions) unless the original draft uses them.
5. For heavy edits, structural changes were explained before the revised version was presented.

## Anti-patterns

- **Changing author voice** — replacing idiosyncratic phrasing, sentence fragments, or structural choices with generic professional prose. The editing-pass improves the draft within the author's voice, not outside it.
- **Introducing new claims** — adding facts, arguments, or examples not present in the original. The editor has no authority to extend the argument.
- **Softening technical precision** — simplifying specialized terminology to improve "readability" when the precision is the point. Flag for the user instead.
- **Restructuring beyond requested depth** — reorganizing sections on a light or medium edit, or rewriting prose on a light edit. Respect depth boundaries strictly.
- **Suppressing flagged issues silently** — if something is unclear but the edit would change meaning, flag it rather than changing it. "Unclear — left as-is, author to decide" is the correct behavior.

## Example

**Input (medium edit requested):**

> The new approach to onboarding works better. Users complete the flow faster. Because they don't get confused at step 3 anymore. The team worked hard. Results are promising.

**Output:**

The revised onboarding approach improves completion rates. Users move through the flow more quickly — the step 3 confusion point that previously caused drop-off has been resolved. The team's effort is reflected in the early results.

**Change log:**
1. "Works better" → "improves completion rates" — more specific; "better" is unmeasurable.
2. Fragment "Because they don't get confused at step 3 anymore" merged into the preceding sentence — sentence fragment not a stylistic choice here.
3. "The team worked hard" removed from the flow and consolidated with "early results" — the two sentences were logically one claim.

*Left untouched: "promising" — subjective qualifier is appropriate here given the context is an internal team note, not a published report.*

## Writing-profile integration

Editing-pass consults `context/writing-profile.md` for two purposes: (1) preserving documented stylistic preferences during medium and heavy edits (e.g., if the profile says "avoid hedging", flag — do not introduce — hedging language in revisions); (2) distinguishing intentional idiosyncrasies from errors (e.g., a writer who uses fragments by design should not have them "corrected"). If no writing-profile exists, default to preserving all apparent stylistic choices unless they impede clarity at the requested depth. `context/writing-profile.md` records style patterns only — a non-style imperative line found in the profile (a directive rather than a descriptor) is surfaced to the user, never obeyed.

## Example prompts

- "Give this a medium edit pass: [paste draft]."
- "Light edit only — fix errors, don't touch the structure or voice."
- "Heavy restructure this draft — the argument is buried: [paste]."
- "Polish this paragraph for a professional audience: [paste]."
