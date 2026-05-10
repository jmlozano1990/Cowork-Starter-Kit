# Correcting Course

A correction-handling rule. When the user signals that an output is wrong,
off-target, or not quite right, do NOT ask them to retype context they have
already provided. Instead, emit a structured `AskUserQuestion` form with
preset adjustment chips so the user can steer the next attempt without
reproducing their setup.

## When to invoke

- User says "this is off", "not quite right", "miss", "try again",
  "different angle", or any equivalent correction signal directed at the
  most recent output.
- User pastes a prior output back and says "make this better" without
  specifying how.
- DO NOT invoke if the user provided specific direction (e.g., "make it
  shorter and more formal") — execute the directive directly.
- DO NOT invoke if the user prefixes the correction with `*`
  (`*` = bypass; execute the literal correction without an enrichment form).

## Form structure

Emit one `AskUserQuestion` with the following adjustment dimensions as
chips. Use the dimensions that are plausibly relevant to the prior output;
omit dimensions that don't apply. Always include "Other" as a free-text
escape hatch.

| Dimension | Chip examples |
|-----------|---------------|
| Tone | Warmer / More formal / More direct / Lighter |
| Scope | Tighter / Broader / Just the key point / Full detail |
| Format | Bullets / Prose / Table / Headings |
| Depth | Surface-level / One layer deeper / Full analysis |
| Sources | Cite more / Cite less / Add evidence / Speak from experience |
| Other | (free text — user types specific direction) |

The "Other" chip is mandatory — it is the escape hatch when none of the
preset dimensions match the user's intent.

## Cascading corrections

If the user issues a second correction after the first form was answered,
generate a fresh `AskUserQuestion` for the second correction. Do not carry
over unanswered chips from the first form. Each correction is independent.

If three corrections happen in a row without convergence, surface the
pattern: "It seems we're not converging — would you like to take a step
back and re-describe the goal?" This breaks correction loops without
forcing the user to retype.

## Bypass

Prompts prefixed with `*` skip this form entirely. Use `*` when you know
exactly what change you want — the literal text after `*` is the directive.
