#!/usr/bin/env bash
# tests/fixtures/v2.19/classify-component.sh — reference mechanical layer for
# AC-PULL-1 (manifest-drift 4th state) and AC-PULL-6 (fresh-bytes-both-sides
# trust-transitivity). Classifies ONE component given:
#   $1 = slug
#   $2 = on-disk SKILL.md path (may not exist — the manifest-drift case)
#   $3 = curated-pool SKILL.md path (the fresh comparison target)
#   $4 = registry file (to test P — is slug in curated-skills-registry.md)
#
# Never reads a "trusted" hash from the manifest for the decision — this script does
# not even accept one as an argument. H_current and H_pool are always computed fresh,
# right here, right now (AC-PULL-6). Outputs exactly one of:
#   manifest-drift | user-authored-not-in-pool | untouched | user-customized
set -uo pipefail
slug="$1"; ondisk="$2"; pool="$3"; registry="$4"

if [ ! -f "$ondisk" ]; then
  echo "manifest-drift"
  exit 0
fi

if ! grep -qE "^\| ${slug} \|" "$registry"; then
  echo "user-authored-not-in-pool"
  exit 0
fi

if [ ! -f "$pool" ]; then
  echo "REFUSE: pool file for registered slug '${slug}' not found (should not happen)"
  exit 2
fi

H_current=$(sha256sum "$ondisk" | awk '{print $1}')
H_pool=$(sha256sum "$pool" | awk '{print $1}')

if [ "$H_current" = "$H_pool" ]; then
  echo "untouched"
else
  echo "user-customized"
fi
