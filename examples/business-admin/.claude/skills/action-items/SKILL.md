---
name: action-items
description: Identify and structure action items from a meeting, email thread, or document into a clear, owned list
trigger_examples:
  - "What are the action items from this meeting? [paste notes or transcript]"
  - "What files are in my Inbox/ folder? Draft a prioritized action list for today"
  - "Extract all action items from this email thread: [paste thread]"
  - "Summarize what everyone needs to do before the next meeting"
---

## When to use

Use action-items when the user needs a clear, owned, actionable list extracted from a meeting transcript, email thread, chat log, or working document. This skill is appropriate any time a session or document produces decisions and next steps that need to be captured before they are forgotten or scattered. Use it after a meeting, when reviewing a long email thread, when processing a document that contains tasks, or when the user needs to delegate or track follow-ups. Do NOT use it to summarize discussions or produce meeting minutes — this skill produces only actionable items, not narrative recaps.

## Triggers

- User says "action items", "next steps", "what do we need to do", or "action-items" — direct invocation.
- User pastes meeting notes, a transcript, an email thread, or a document and asks what needs to happen.
- User asks for a task list, a to-do list, or a follow-up list from content they have shared.
- User asks who is responsible for what, or wants to assign ownership to decisions that were made.
- User says "what did I commit to" or "what did we agree on" after reviewing a conversation or document.

## Instructions

1. **Read all provided content in full before extracting.** Do not begin listing items while still reading. Identify every explicit or implied action — something that needs to be done, by someone, at some point. Include items that are clearly implied even if not stated as explicit tasks (e.g., "we'll send the contract by Friday" is an action item even without the word "action").
2. **Structure each item with three fields.** For every action item, identify: (a) **Action** — one clear imperative sentence describing what needs to be done; (b) **Owner** — the person responsible, if stated or inferable from context; (c) **Deadline** — the date or timeframe, if stated or implied. Use "TBD" only for genuinely unknown values — do not guess.
3. **Flag ambiguous items rather than resolving them.** If an action is unclear — who is responsible, what exactly needs to be done, or whether it is actually an action at all — mark it as `[Needs clarification]` with a brief note on what is unclear. Do NOT resolve ambiguity by assuming.
4. **Separate the list from a resolution summary.** After the numbered list, add a short resolution block: count items with no owner, count items with no deadline, and flag any item marked for clarification. This block tells the user what needs to be resolved before the list is actionable.
5. **Do not include discussion points, observations, or decisions without actions.** If a decision was made but no one needs to do anything as a result, it is not an action item. Observations, status updates, and FYI notes are excluded unless they carry an implicit task.

## Output format

Numbered list. Each item on a separate block: `**Action:** [imperative sentence]` / `**Owner:** [name or TBD]` / `**Deadline:** [date/timeframe or TBD]`. Items with clarification flags appear at the end of the list, labeled `[Needs clarification]`. Resolution summary follows the list: `Unowned items: N`, `No-deadline items: N`, `Clarification needed: N`. No prose narrative, no headers other than a single `## Action Items` heading.

## Quality criteria

1. Every item is a genuine action (something someone must do), not a decision, observation, or discussion point.
2. Owner is named when inferable — not left as TBD when context makes it clear.
3. Deadlines are included when stated or implied — not fabricated.
4. Ambiguous items are flagged with a clarification note rather than silently assumed.
5. Resolution summary correctly counts unowned and no-deadline items.

## Anti-patterns

- **Turning discussion into actions** — listing a topic that was discussed as if it requires follow-up when no action was stated or implied. "We talked about the budget" is not an action item unless someone is required to do something about the budget.
- **Guessing owners** — assigning ownership to a name that appears in the document but was not clearly linked to the action. "John was in the meeting" is not evidence that John owns the action.
- **Silent resolution of ambiguity** — picking an interpretation of an unclear action item without flagging it. Ambiguity must be surfaced, not resolved unilaterally.
- **Fabricating deadlines** — adding a "standard" deadline or inferring urgency from tone. Deadlines must be stated or clearly implied by context.
- **Including minutes** — producing a meeting summary or narrative alongside the action list. This skill produces a task list, not minutes. If the user needs both, clarify before proceeding.

## Example

**Input:** "Meeting notes: Discussed Q3 roadmap. Sarah will finalize the budget by next Friday. We agreed to move the launch to October. Someone needs to update the website copy before then. John to schedule a follow-up call next week."

**Output:**

## Action Items

1. **Action:** Finalize Q3 budget.
   **Owner:** Sarah
   **Deadline:** Next Friday

2. **Action:** Update website copy before October launch.
   **Owner:** TBD
   **Deadline:** Before October launch

3. **Action:** Schedule follow-up call.
   **Owner:** John
   **Deadline:** Next week

---

Unowned items: 1 (item 2 — no owner named for website copy update)
No-deadline items: 0
Clarification needed: 0

## Writing-profile integration

Action-items output is structural and does not use the user's writing voice. The `context/writing-profile.md` tone and register preferences do not apply to numbered task lists, ownership labels, or deadline fields. If the user's profile includes specific formatting preferences for task lists (e.g., use Markdown checkboxes instead of numbered items), honor those preferences for the list format only — not the content.

## Example prompts

- "What are the action items from this meeting? [paste notes or transcript]"
- "Extract all action items from this email thread: [paste thread]"
- "What did we commit to in this document? [paste document]"
- "Who owns what from this conversation? [paste chat log]"
