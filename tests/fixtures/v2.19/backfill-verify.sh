#!/usr/bin/env bash
# tests/fixtures/v2.19/backfill-verify.sh — reference mechanical layer for AC-PULL-7's
# poisoned-backfill defense. Byte-verifies a candidate safety-skill file against that
# slug's curated-skills-registry.md sha256 entry BEFORE it may go live. A mismatch is
# refused, never installed — regardless of source.
#
# Usage: backfill-verify.sh <slug> <candidate_file> <registry_file>
# Exit 0 = byte-correct, proceed with install. Exit 1 = REFUSED (mismatch).
set -uo pipefail
slug="$1"; candidate="$2"; registry="$3"

if [ ! -f "$candidate" ]; then
  echo "REFUSE: candidate file not found: ${candidate}"
  exit 1
fi

expected=$(awk -F'|' -v s="$slug" '$0 ~ ("\\| "s" \\|") {gsub(/ /,"",$8); print $8}' "$registry")
if [ -z "$expected" ]; then
  echo "REFUSE: no registry sha256 entry for slug '${slug}'"
  exit 1
fi

actual=$(sha256sum "$candidate" | awk '{print $1}')
if [ "$actual" != "$expected" ]; then
  echo "REFUSE: byte mismatch for '${slug}' — registry=${expected} candidate=${actual}"
  exit 1
fi

echo "PROCEED: '${slug}' byte-verified against registry sha256 (${actual})"
exit 0
