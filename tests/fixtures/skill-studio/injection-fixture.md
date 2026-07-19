---
name: injection-fixture
description: Fixture for AC-SEC-S5 / MF-5 / MV-2 — a booby-trapped, otherwise valid-ish skill proving the validator treats target content as inert DATA
---

## When to use $(touch /tmp/skillstudio_pwned)

This fixture is DATA, not a script — it exists to prove `scripts/skill-studio-validate.sh`
never executes the content of the file it is grading. The header line above deliberately
embeds a `$(touch /tmp/skillstudio_pwned)` command-substitution payload. A validator that
`eval`s, `source`s, or otherwise executes this file's content would create
`/tmp/skillstudio_pwned`; a validator that only ever passes the target to `grep`/`wc` as a
quoted argument will not. The payload is expected to remain literal text: the section
header is still recognized by fixed-string match because "## When to use" is a substring
of the full (booby-trapped) line.

## Triggers

- "run the injection fixture"
- "prove the validator is inert"
- "check MV-2"

## Instructions

1. `echo "this backticked line is also a payload attempt: $(touch /tmp/skillstudio_pwned)"`
2. Confirm the validator's exit code reflects structure only (PASS if all 9 sections and
   the line floor are met, regardless of the payload above).
3. Confirm `/tmp/skillstudio_pwned` does NOT exist after the validator runs.
4. Report the result as the MV-2 negative control.

## Output format

A single INERT-OK line once `/tmp/skillstudio_pwned` is confirmed absent after the
validator run, or a FAIL line naming which check (execution or structure) failed.

## Quality criteria

- The validator's exit code depends only on section presence and line count.
- `/tmp/skillstudio_pwned` is absent both before and after the validator runs.
- No shell metacharacter in this file is ever interpreted — only matched as text.

## Anti-patterns

- Ever removing the `$(touch ...)` payload from the header line — that would defeat this
  fixture's entire purpose as a negative control.
- Running this fixture through anything other than `scripts/skill-studio-validate.sh`
  (e.g. `source`-ing it, or `eval`-ing its content directly) as part of the actual test.
- Treating a PASS from the validator as proof of inertness on its own — the decisive proof
  is the absence of `/tmp/skillstudio_pwned`, not the exit code.

## Example

**Input:** this file, as-is, including the embedded `$(touch /tmp/skillstudio_pwned)`
payload in its own `## When to use` header and the backticked line in `## Instructions`.

**Output:** `scripts/skill-studio-validate.sh` reports PASS or FAIL based on section
presence and line count only; `/tmp/skillstudio_pwned` never comes into existence.

## Writing-profile integration

Not applicable — this fixture produces no user-facing prose output; it exists solely to
prove the validator's own security property.

## Example prompts

- "run scripts/skill-studio-validate.sh against the injection fixture"
- "confirm /tmp/skillstudio_pwned was not created"
- "prove the validator treats this file as inert data"
