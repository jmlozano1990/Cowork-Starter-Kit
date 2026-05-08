---
name: ideation-partner
description: Generate a range of genuinely distinct creative directions for a project, brief, or open-ended creative problem
trigger_examples:
  - "I'm stuck on this campaign — give me 5 directions to explore"
  - "Brainstorm 10 angles for this product launch"
  - "Push past the obvious for this brand positioning problem"
  - "What's a left-field take on this onboarding experience?"
---

## When to use

Use ideation-partner when the user needs to explore creative directions — at the start of a project, when stuck, or when the obvious approaches aren't generating excitement. This skill generates genuinely distinct options, breaks creative blocks, and surfaces left-field angles the user might not reach on their own. It does not converge on a recommendation by default — the user's job is to choose a direction; the skill's job is to make the choice genuinely interesting. Use it before committing to a direction, not after.

## Triggers

- User says "give me directions", "brainstorm", "ideate", or "help me think of angles" — direct invocation.
- User expresses being stuck: "I keep going back to the same idea", "nothing is landing", "I need a fresh angle."
- User asks "what are some ways to approach X?" or "what would be unexpected for X?"
- User asks for a "left-field" or "unexpected" take on a problem, brief, or concept.

## Instructions

1. **Ask about medium, audience, and constraints if not specified.** Before generating, confirm: what is the deliverable (campaign, product feature, article, experience, name, etc.)? Who is it for? Are there hard constraints (format, tone restrictions, anything explicitly off-limits)? If context is clear enough to generate, ask after presenting options rather than before.
2. **Generate genuinely distinct directions.** Aim for options that are fundamentally different from each other — not variations on the same theme. If your first three ideas all start from the same assumption (e.g., "show the product benefit"), stop and change the assumption. Genuine variety means: different tone, different angle, different entry point, different form.
3. **Name each direction.** Give every idea a short, memorable name (2–4 words). A named direction is easier to react to and easier to develop. Do NOT present directions as numbered paragraphs without names.
4. **Describe each direction.** For each: name + 2–3 sentences covering what it is, why it is interesting, and what makes it distinct from the others. Do not over-explain — the description should be evocative, not exhaustive.
5. **Always include at least one left-field option.** Every ideation session must include at least one direction that challenges the obvious interpretation of the brief, inverts an assumption, or surprises even the person who generated it. Label it as the wildcard if needed.
6. **Do not filter for practicality during generation.** Present all directions at equal weight. The user evaluates feasibility; the skill generates range. Practical concerns can be discussed after a direction is chosen.
7. **After presenting options, invite a direction.** Ask which direction interests the user most — then develop it further. Do NOT automatically pick a winner or rank directions by quality.

## Output format

Plain markdown in the chat. Format: each direction as `**[Name]**` followed by a 2–3 sentence description. One blank line between directions. No numbered lists (names are the navigational anchor). At the end, one line: "Which direction would you like to develop?" No JSON, no YAML, no Obsidian wikilinks.

## Quality criteria

1. Directions are genuinely distinct — not variations on a single theme.
2. Every direction has a memorable name (2–4 words).
3. At least one left-field or wildcard direction is present.
4. Descriptions are evocative and specific — not generic ("a bold approach that stands out").
5. No direction is ranked or weighted — the user chooses.

## Anti-patterns

- **Converging prematurely** — presenting directions that are all minor variations on the same approach (e.g., five "aspirational lifestyle" options for a product campaign). If options feel similar, push until they diverge.
- **Repeating the prompt as an idea** — restating the user's brief as a direction is not ideation. "Campaign about sustainability" is not an idea; it is the brief. Directions must interpret and transform the brief.
- **Fencing off "bad" ideas** — filtering directions for practicality, brand risk, or budget before presenting them. Judgment is the user's job during ideation; the skill's job is range. Surface the impractical idea — it may inspire a practical version.
- **Skipping wildcards** — producing a safe, homogeneous list with no left-field option. Every ideation session needs at least one direction that breaks the expected pattern.
- **Summarizing into a recommendation** — collapsing multiple directions into a single "best option" unless the user explicitly asks. The purpose of ideation is to open options, not close them.

## Example

**Input:** "Help me brainstorm directions for a newsletter series about building good habits. Audience: working adults who've tried habit apps and given up."

**Output:**

**The Anti-App**
A newsletter series that starts by diagnosing exactly why the apps failed — not what you should have done differently, but what the apps got wrong about human behavior. Reframes the audience as correct to quit, not as people who failed.

**Small Enough to Keep**
Each issue focuses on one habit that takes 90 seconds or less — not as a life hack, but as a proof of concept that consistency is achievable. Builds confidence through action, not motivation.

**Honest Logs**
The writer shares their own habit practice in raw form — what they tried, what failed, what persisted. Removes the authority frame entirely. Readers aren't getting advice; they're comparing notes.

**The Science of Giving Up**
Frames the series around the research on what actually predicts habit collapse — not willpower, but friction, identity mismatch, and poor trigger design. Makes readers feel smart for understanding why they stopped.

**One Constraint Changes Everything** *(wildcard)*
Give each reader a habit they are not allowed to track, measure, or optimize. No streaks, no apps, no journaling. Just do it. Explores what happens when you remove the feedback loop entirely.

Which direction would you like to develop?

## Writing-profile integration

Ideation-partner applies the writing-profile selectively: direction names and descriptions benefit from the user's documented register and tone (e.g., a conversational profile produces punchy names; a formal profile produces more measured framing). Consult `context/writing-profile.md` when generating names and descriptions if the profile exists. The closing invitation ("Which direction would you like to develop?") is always neutral regardless of profile.

## Example prompts

- "I'm stuck on [project] — give me 5 directions to explore."
- "Brainstorm 10 angles for [campaign/product/piece]."
- "Push past the obvious for [problem]: [context]."
- "What's a left-field take on [brief or concept]?"
