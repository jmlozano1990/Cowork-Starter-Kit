#!/usr/bin/env bash
# tests/fixtures/v2.19/validate-manifest.sh — reference mechanical layer for AC-PULL-9
# (malformed/schema-invalid cowork.install.json refusal). This is the executable check
# that pull-updates/SKILL.md's prose describes: refuse and never guess on a partial
# parse. Prints REFUSE (with reason) and exits 1, or OK and exits 0 (proceed to
# per-component classification).
set -uo pipefail
f="$1"

if ! jq empty "$f" >/dev/null 2>&1; then
  echo "REFUSE: unparseable/truncated JSON"
  exit 1
fi

# schema_version is written as literal key "$schema_version" in the template.
if ! jq -e '(has("$schema_version") or has("schema_version")) and has("kit_version") and has("installed_at") and has("components")' "$f" >/dev/null 2>&1; then
  echo "REFUSE: missing required top-level key (schema_version/kit_version/installed_at/components)"
  exit 1
fi

if ! jq -e '.components | type == "array"' "$f" >/dev/null 2>&1; then
  echo "REFUSE: components is not an array"
  exit 1
fi

n=$(jq '.components | length' "$f")
for i in $(seq 0 $((n - 1))); do
  for field in slug installed_path installed_content_sha256; do
    if ! jq -e ".components[$i] | has(\"$field\")" "$f" >/dev/null 2>&1; then
      echo "REFUSE: component[$i] missing required field '$field'"
      exit 1
    fi
  done
done

echo "OK: manifest well-formed, $n component(s)"
exit 0
