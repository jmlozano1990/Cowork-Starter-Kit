---
name: short-but-complete
description: Fixture for AC-VALID-3a — all 9 required sections present, but under the 60-line floor
---

## When to use

Use this fixture to prove the validator fails a structurally-complete file that is too short.

## Triggers

- "run the short fixture"

## Instructions

1. Read the file.
2. Check its line count.

## Output format

A single PASS/FAIL line.

## Quality criteria

- Line count is checked.

## Anti-patterns

- Treating this fixture as a real skill.

## Example

**Input:** n/a

**Output:** n/a

## Writing-profile integration

Not applicable — this fixture produces no prose output.

## Example prompts

- "validate the short fixture"
