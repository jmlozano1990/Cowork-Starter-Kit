#!/usr/bin/env bash
# skill-studio-validate.sh — portable structural validator for Skill Studio-generated SKILL.md files
#
# SYNC-SOURCE: .github/workflows/quality.yml `skill-depth-check` job is the single authority
# for the REQUIRED_SECTIONS list and the MIN_LINES floor below (ADR-045, v2.11.0 KDQ-2).
# Any ADR-015/ADR-016 amendment that changes either MUST update this script in the same cycle.
#
# Runs the same two structural rules as skill-depth-check, but against an arbitrary target
# file path (not hardcoded to a pool glob), because this script executes inside an arbitrary
# end-user workspace, not this repo. Offline: grep/wc/bash builtins only, no network calls.
#
# Usage: scripts/skill-studio-validate.sh <path-to-SKILL.md>
#
# Exit codes:
#   0 — PASS (all 9 required sections present AND line count >= MIN_LINES)
#   1 — FAIL (missing section(s) and/or under the line floor)
#   2 — usage error (wrong argument count, or target file not found)
#
# Security (AC-SEC-S5 / MF-5): the target file is treated as INERT DATA throughout — it is
# only ever passed as an argument to grep/wc, quoted. This script never eval's, source's, or
# backtick/$()-executes the target's content, so a booby-trapped generated skill (e.g. a
# section header containing a `$(...)` payload) cannot achieve code execution here.

set -euo pipefail

usage() {
  echo "Usage: $0 <path-to-SKILL.md>" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 2
fi

target="$1"

if [ ! -f "$target" ]; then
  usage
  echo "Error: file not found: $target" >&2
  exit 2
fi

# SYNC-SOURCE: keep byte-identical to .github/workflows/quality.yml skill-depth-check's
# REQUIRED_SECTIONS array (9 entries) and line-floor value.
REQUIRED_SECTIONS=(
  "## When to use"
  "## Triggers"
  "## Instructions"
  "## Output format"
  "## Quality criteria"
  "## Anti-patterns"
  "## Example"
  "## Writing-profile integration"
  "## Example prompts"
)
MIN_LINES=60

fail=0

for section in "${REQUIRED_SECTIONS[@]}"; do
  if ! grep -qF -- "$section" "$target"; then
    echo "MISSING section '$section' in: $target"
    echo "  -> See templates/skill-template/SKILL.md for the required structure."
    fail=1
  fi
done

line_count=$(wc -l < "$target")

if [ "$line_count" -lt "$MIN_LINES" ]; then
  echo "TOO SHORT (${line_count} lines, minimum ${MIN_LINES}): $target"
  fail=1
fi

if [ "$fail" -eq 1 ]; then
  echo "FAIL: $target"
  exit 1
fi

echo "PASS: $target (${line_count} lines, all 9 required sections present)"
exit 0
