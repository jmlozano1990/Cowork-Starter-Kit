---
name: daily-briefing
description: Summarize today's schedule, open tasks, and pending follow-ups into a concise morning brief from local files
trigger_examples:
  - "Good morning — what does my day look like?"
  - "Daily briefing"
  - "What's on my plate today?"
---

## When to use

Use at the start of Casey's day when a structured intention-setting ritual is needed — schedule, open tasks, pending follow-ups, and a one-line focus intention. Edge case: when no calendar, tasks, or people data are available, the skill prompts for user input rather than fabricating a briefing.

## Triggers

- User says "daily briefing", "morning brief", "what's on my plate today", or names this skill directly.
- User starts the day or sends the first message in a session.
- User mentions their calendar, schedule, or asks "what should I focus on today".
- User shares a list of upcoming events or asks what they should focus on.

## Instructions

1. **Determine invocation path.** If invoked via Trigger 1 (user typed "morning brief", "daily briefing", "what's on my plate", etc.), proceed directly. If invoked via Trigger 2, 3, or 4 (proactive-offer per `examples/personal-assistant/global-instructions.md` line 19), wait for user confirmation before reading any files. Do NOT auto-execute.
2. **Read sources with graceful-degradation ladder.** Read `Calendar/` folder (any `*.md` files matching today's date or a date range that includes today). If folder is missing or empty: note "No calendar entries found for today" in the Time blocks section. Do NOT error. Read `Tasks/` folder (any `*.md` files). If folder is missing or empty: note "No tasks tracked" in the Priorities section. Do NOT error. Read `People/` folder (any `*.md` files). If folder is missing or empty: note "No people-tracked follow-ups" inline in the Priorities or Time blocks section as appropriate. Do NOT error. If all three folders are missing AND no inline context is provided, ask the user: "I can produce a briefing if you paste today's calendar / tasks / follow-ups, or point me at the right folders." Do NOT generate a fabricated briefing.
3. **Ask the three intention questions.** Ask: (a) energy level today; (b) priority-one for today; (c) one thing to protect against interruption. If any of these were inferable from a previous session's brief or shared context, surface that and ask for confirmation rather than re-asking.
4. **Draft the priority-ordered structure.** Condense the Tasks/ + People/ content into at most 3 ranked priorities. Do NOT produce a 10-item priority list — see anti-pattern 1 below.
5. **Add time blocks.** Build a table with three columns: time range, activity, priority-link. Each time block links to one of the at-most-3 priorities or to the Protect item. Do NOT add unsolicited time-blocks not derived from user-stated priorities.
6. **Write the one-line "why today matters" intention.** One sentence, in the user's voice. Consult `context/writing-profile.md` for the Intention line (see `## Writing-profile integration`).
7. **Present for user confirmation** before saving any file or scheduling any event. Ask: "Does this brief match your day, or should I adjust priorities or time-blocks?" Do NOT save to file silently.

## Output format

The output must contain exactly these four labeled sections in this order:

1. **Intention** — one line. The "why today matters" sentence in the user's voice.
2. **Priorities** — at most 3 bullets, ranked. Each bullet is at most one line.
3. **Time blocks** — markdown table with three columns: time range | activity | priority-link.
4. **Protect** — one item. The single thing to defend against interruption.

No additional sections. No "Tomorrow" preview. No moralizing summary at the end.

## Quality criteria

1. Intention is one line, not a paragraph.
2. Priorities are at most 3 (not a task dump from the Tasks/ folder).
3. Every time block links to a priority or to the Protect item.
4. No moralizing or productivity advice beyond user-named priorities.

## Anti-patterns

- **Generating a 10-item priority list** — violates the at-most-3 focus rule. Condense to the three most consequential items; move the rest to a "parking lot" note only if the user asks.
- **Adding unsolicited productivity advice** — phrases like "you should also consider...", "this would be a good time to...", or "don't forget to..." are not part of the briefing schema. Omit them.
- **Proposing time blocks without asking about energy level** — skips Instructions step 3. Energy level affects block duration; always ask before allocating focus blocks.
- **Producing a blank or error output when a source folder is absent** — Calendar/, Tasks/, or People/ folder missing must result in a partial brief with a noted missing-source line, never an error message and never an empty section.

## Example

**Vault state (illustrative):**
- Calendar/: 3 entries — 9:00 team standup, 14:00 1:1 with manager, 16:30 dentist
- Tasks/: 5 entries — Q2 report draft (overdue), expense report (due today), read onboarding doc, reply to client email, update roadmap slide
- People/: 2 entries — Alex (waiting on Q2 report since Monday), Sarah (asked for expense form last week)

**User answers the three intention questions:**
- Energy: medium
- Priority-one: finish Q2 report draft for Alex
- Protect: the 10:00–12:00 block from meetings

**Output:**

**Intention:** Today is about clearing the two things Alex and Sarah are waiting on so the afternoon is actually mine.

**Priorities:**
1. Q2 report draft — Alex is blocked since Monday
2. Expense report — due today, Sarah needs the form
3. Reply to client email — low urgency but quick win

**Time blocks:**

| Time | Activity | Priority |
|------|----------|----------|
| 9:00 | Team standup | — |
| 10:00–12:00 | Q2 report draft | Priority 1 (Protect) |
| 12:00 | Expense report + client reply | Priority 2 + 3 |
| 14:00 | 1:1 with manager | — |
| 16:30 | Dentist | — |

**Protect:** 10:00–12:00 — Q2 draft block. No meetings, no Slack, phone on silent.

## Writing-profile integration

Daily briefings are typically under 200 words. The writing-profile applies selectively:

- **Intention line:** the user's voice is most present here. Always consult `context/writing-profile.md` for tone, pet peeves, and anti-AI guidance — even though the line is short.
- **Priorities, Time blocks, Protect:** schematic and terse. Do NOT apply writing-profile tone to priority bullets or table cells; neutrality is correct here.

## Example prompts

- "Good morning — what does my day look like?"
- "What's on my plate today? Check my calendar and tasks."
- "Give me a quick briefing before I start work."
