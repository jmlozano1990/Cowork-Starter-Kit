#!/usr/bin/env bash
# scripts/semver-compare.sh — v2.19 Persistency Layer (MF-6, Phase-2.D binding refinement:
# "implement semver compare as a SCRIPT, not model-judgment prose" — AC-UPGRADE-2)
#
# Deterministic semver comparison — parses major/minor/patch as INTEGERS, never a
# lexical string compare. A naive string compare is the exact trap AC-UPGRADE-2 names:
# "2.9.0" > "2.19.0" lexically (the character '9' outranks '1' at that position) even
# though 2.9.0 < 2.19.0 numerically. This script gets that right, deterministically,
# every time — the `self-upgrade` skill invokes it rather than judging version order
# itself.
#
# Zero-code constraint (ADR-020): a CI/skill-invocation shell computation, never a
# wizard/LLM-runtime free-form judgment — same trust boundary scripts/registry-hash.sh
# and cowork.lock.json's own hashing already stand on.
#
# Usage:
#   scripts/semver-compare.sh ge <version_a> <version_b>
#       Prints "true" and exits 0 if version_a >= version_b (semver-aware).
#       Prints "false" and exits 1 otherwise. "absent" is a valid version_a — it always
#       evaluates false (an absent version is never >= anything).
#   scripts/semver-compare.sh upgrade-ready <kit_version_or_absent>
#       Prints "ready" and exits 0 if kit_version is present AND >= 2.19.0 (the
#       AC-UPGRADE-2 threshold). Prints "not-ready" and exits 1 otherwise (absent OR
#       < 2.19.0 — a workspace born at or before v2.18).
#
# Exit codes: 0 = true/ready; 1 = false/not-ready; 2 = usage or parse error.

set -euo pipefail

UPGRADE_THRESHOLD="2.19.0"

# parse_semver <version> -> prints "MAJOR MINOR PATCH" (space-separated integers).
# Exits 2 if the string is not a strict x.y.z integer-triplet (never guesses a partial
# or malformed version — mirrors AC-PULL-9's "never guess missing fields" discipline).
parse_semver() {
  local v="$1"
  if ! [[ "$v" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "::error::not a valid x.y.z semver: '${v}'" >&2
    exit 2
  fi
  echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
}

# semver_ge <a> <b> -> return 0 if a >= b, 1 otherwise. Integer comparison only, at
# each of major/minor/patch in turn — never a string compare of the whole version.
semver_ge() {
  local a="$1" b="$2"
  local a_major a_minor a_patch b_major b_minor b_patch
  read -r a_major a_minor a_patch <<< "$(parse_semver "$a")"
  read -r b_major b_minor b_patch <<< "$(parse_semver "$b")"

  if [ "$a_major" -gt "$b_major" ]; then return 0; fi
  if [ "$a_major" -lt "$b_major" ]; then return 1; fi
  if [ "$a_minor" -gt "$b_minor" ]; then return 0; fi
  if [ "$a_minor" -lt "$b_minor" ]; then return 1; fi
  if [ "$a_patch" -ge "$b_patch" ]; then return 0; fi
  return 1
}

cmd="${1:-}"
case "$cmd" in
  ge)
    a="${2:-}"; b="${3:-}"
    if [ -z "$a" ] || [ -z "$b" ]; then
      echo "::error::usage: semver-compare.sh ge <version_a> <version_b>" >&2
      exit 2
    fi
    if [ "$a" = "absent" ]; then
      echo "false"
      exit 1
    fi
    if semver_ge "$a" "$b"; then
      echo "true"
      exit 0
    fi
    echo "false"
    exit 1
    ;;
  upgrade-ready)
    kv="${2:-}"
    if [ -z "$kv" ]; then
      echo "::error::usage: semver-compare.sh upgrade-ready <kit_version_or_absent>" >&2
      exit 2
    fi
    if [ "$kv" = "absent" ]; then
      echo "not-ready"
      exit 1
    fi
    if semver_ge "$kv" "$UPGRADE_THRESHOLD"; then
      echo "ready"
      exit 0
    fi
    echo "not-ready"
    exit 1
    ;;
  *)
    echo "::error::unknown command '${cmd}' — expected 'ge' or 'upgrade-ready'" >&2
    exit 2
    ;;
esac
