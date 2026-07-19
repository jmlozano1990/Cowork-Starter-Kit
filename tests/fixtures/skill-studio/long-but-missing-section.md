---
name: long-but-missing-section
description: Fixture for AC-VALID-3b — at or above the 60-line floor, but exactly one required section (Writing-profile integration) is missing
---

## When to use

Use this fixture to prove the validator fails a file that clears the line floor but is
missing exactly one of the nine required sections. This fixture is deliberately padded
past 60 lines so that only the missing-section rule fires, not the line-floor rule —
isolating the two structural checks from each other, per AC-VALID-3's "both failure
modes" requirement.

## Triggers

- "run the long fixture"
- "check the missing-section case"
- "validate a file that clears the line floor but drops a section"

## Instructions

1. Read the file in full.
2. Confirm all nine required section headers are present.
3. Confirm the file has at least 60 lines.
4. Report PASS only if both checks succeed.
5. Report FAIL, naming the missing section, if either check fails.

## Output format

A PASS or FAIL line, followed by the specific reason on FAIL — either a named missing
section, a line-count shortfall, or both. This fixture is designed to trigger only the
missing-section reason.

## Quality criteria

- The validator names the specific missing section, not a generic failure.
- The validator does not also report a line-count failure for this fixture (it is
  deliberately long enough to clear the floor on its own).
- The validator exits non-zero.

## Anti-patterns

- Treating this fixture as a real skill to install.
- Editing this fixture to add the missing section — that would defeat its purpose as a
  negative control.
- Assuming a passing line count means the whole file is structurally valid.
- Assuming a passing section-presence check means the file also clears the line floor —
  the two rules are independent and this fixture exists to prove exactly one of them
  (section presence) is the one that should fire here.

## Example

**Input:** n/a — this is a structural fixture, not a content-processing skill.

**Output:** n/a — the validator's own PASS/FAIL line is the only output under test.

## Example prompts

- "validate the long-but-missing-section fixture"
- "run skill-studio-validate.sh against this file"
- "confirm the missing-section negative control fires"
