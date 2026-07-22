#!/usr/bin/env bash
# scripts/registry-hash.sh — v2.18.0 Substrate F5 (ADR-069)
#
# CI/build-time helper that computes the sha256 of every Tier-1 skill's
# pool-location SKILL.md (skills/<slug>/SKILL.md), for backfilling and
# drift-verifying curated-skills-registry.md's `sha256` column.
#
# Zero-code constraint (ADR-020): this is a CI/build-time shell computation,
# never a wizard/LLM-runtime computation — the same trust boundary
# cowork.lock.json's own hashing already stands on.
#
# Usage:
#   scripts/registry-hash.sh                  # print "<slug> <sha256>" for every skills/*/SKILL.md
#   scripts/registry-hash.sh <slug>            # print the sha256 for one slug only
#
# Exit codes: 0 success; 1 skills/ pool directory missing or a named slug not found.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "::error::skills/ pool directory not found at ${SKILLS_DIR}" >&2
  exit 1
fi

hash_one() {
  local slug="$1"
  local f="${SKILLS_DIR}/${slug}/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "::error::No pool file for slug '${slug}' at ${f}" >&2
    return 1
  fi
  sha256sum "$f" | awk '{print $1}'
}

if [ "$#" -eq 1 ]; then
  hash_one "$1"
  exit 0
fi

for f in "$SKILLS_DIR"/*/SKILL.md; do
  [ -f "$f" ] || continue
  slug="$(basename "$(dirname "$f")")"
  hash="$(sha256sum "$f" | awk '{print $1}')"
  echo "${slug} ${hash}"
done
