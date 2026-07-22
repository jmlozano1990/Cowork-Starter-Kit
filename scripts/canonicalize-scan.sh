#!/usr/bin/env bash
# scripts/canonicalize-scan.sh — v2.18.0 Substrate F2/F3 (ADR-068)
#
# Single-source canonicalization + forbidden-token scan. Runs, in order, on
# ONE file's content:
#   (1) Unicode NFKC normalization        (stdlib python3, unicodedata.normalize)
#   (2) Zero-width character stripping    (U+200B, U+200C, U+200D, U+FEFF)
#   (3) Mixed-script FLAGGING             (never auto-corrected, never auto-passed)
#   (4) The ADR-055 6-token forbidden-imperative scan, run on the CANONICALIZED
#       bytes — byte-identical pattern to CONTRIBUTING.md:129. This is the
#       ONLY scan call in this script; there is no raw-scan entry point
#       (AC-F2-4 — the scan-of-record never operates on un-canonicalized bytes).
#
# Zero-code constraint (ADR-020): all hashing/normalization here is a CI/build-time
# shell+stdlib-python computation, never a wizard/LLM-runtime computation.
#
# Callers (single-sourced, MF-S-5):
#   - .github/workflows/quality.yml canonicalize-scan-check job (pool/PR side)
#   - PROMOTE.md's promotion gate (step 4, re-scan at promotion time)
#   - skills/self-apply/SKILL.md's workspace-side re-scan hook (ADR-068 OQ4,
#     turn-two, on installed_content_sha256 mismatch vs cowork.install.json)
#
# SCOPE NOTE (Phase-4 implementation-time finding, recorded in the Phase 4
# report as a deviation): CONTRIBUTING.md:129's own rule frames the 6-token
# scan around "## Example" specifically — "The `## Example` section in a
# SKILL.md is executed as AI context. Apply these three rules to prevent
# indirect prompt injection" — because `## Example` is the section most likely
# to carry pasted, externally-sourced content. Running the byte-identical
# pattern over an ENTIRE SKILL.md (Instructions/Anti-patterns/Quality
# criteria prose, all maintainer-authored, not pasted) produces false
# positives on ordinary English — "instead of" is a common phrase, and
# several existing skills' Anti-patterns sections explicitly discuss
# injection-defense using the very words this scan targets, quoted as
# examples of what NOT to obey (e.g. "ignore previous instructions" is cited,
# as data, inside a data-not-instruction rule). All 27 pool files and all 21
# depth-enforced example files were checked empirically: 0 matches inside
# `## Example`, 15+ files match somewhere in the FULL file. Per this
# project's own existing precedent (never widen or re-scope the 6-token set
# itself — AC-F3-1), this script supports an explicit `--section` flag so
# every caller can apply the SAME existing CONTRIBUTING.md:129 scope
# (`## Example`) consistently, single-sourced, rather than each of 3 call
# sites re-deriving its own section-extraction logic independently.
#
# Usage:
#   scripts/canonicalize-scan.sh <file>                       # whole-file (generic primitive; used for standalone fixtures)
#   scripts/canonicalize-scan.sh --section "## Example" <file> # extract ONE named '## ' section, canonicalize+scan only that slice
#
# HONEST LIMIT (must not be overclaimed — see docs/substrate-contribution-format.md):
#   - NFKC normalization neutralizes compatibility-decomposable evasion (e.g. a
#     fullwidth U+FF29 folds to ASCII 'I'). It does NOT fold homoglyphs from a
#     genuinely distinct Unicode script (e.g. Cyrillic 'а'/U+0430 does not become
#     Latin 'a'/U+0061 under NFKC) — that evasion class is caught ONLY by the
#     mixed-script FLAG below, and only routes to human review, never an
#     automatic catch or correction.
#   - The zero-width strip covers exactly 4 named codepoints (U+200B, U+200C,
#     U+200D, U+FEFF). It does NOT cover every invisible/format (Unicode
#     category Cf) codepoint — at minimum the following remain UNCOVERED by
#     this script and must not be assumed neutralized: U+2060 (WORD JOINER),
#     U+00AD (SOFT HYPHEN), U+180E (MONGOLIAN VOWEL SEPARATOR), and the
#     U+E0000-U+E007F TAG characters block. A motivated adversary using one of
#     these uncovered classes can still evade both the strip and the scan
#     (HLD §11 — canonicalization narrows only the cheapest evasion classes; it
#     does not close all of them).
#
# Exit codes:
#   0 — clean: no forbidden-token match, no mixed-script flag, after canonicalization.
#   1 — forbidden-token match found in the canonicalized content. BLOCKED.
#   2 — mixed-script content flagged (routed to human review). Also non-zero so
#       CI/callers never silently pass a flagged file — "flagged, not silently
#       passed" per AC-F2-3.
#   3 — usage/IO error (missing file, python3 unavailable, named section not found, etc).

set -euo pipefail

SECTION=""
if [ "${1:-}" = "--section" ]; then
  SECTION="${2:-}"
  shift 2
  if [ -z "$SECTION" ]; then
    echo "Usage: $0 [--section \"## Example\"] <file>" >&2
    exit 3
  fi
fi

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [--section \"## Example\"] <file>" >&2
  exit 3
fi

TARGET="$1"
if [ ! -f "$TARGET" ]; then
  echo "::error::File not found: ${TARGET}" >&2
  exit 3
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "::error::python3 not found — this script requires only the ubuntu-latest built-in stdlib python3 (unicodedata), no new dependency." >&2
  exit 3
fi

CANON_TMP="$(mktemp)"
FLAG_TMP="$(mktemp)"
trap 'rm -f "$CANON_TMP" "$FLAG_TMP"' EXIT

# Steps (1) NFKC normalize, (2) strip the 4 named zero-width codepoints,
# (3) detect and report mixed-script tokens (flag only — never corrected).
# Pure stdlib (unicodedata) — no new dependency, no network, no pip/npm install
# (SF-S-1 / OI-v2.18-S8).
python3 - "$TARGET" "$CANON_TMP" "$FLAG_TMP" "$SECTION" <<'PYEOF'
import sys
import unicodedata
import re

src_path, canon_path, flag_path, section = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open(src_path, "r", encoding="utf-8", errors="surrogateescape") as f:
    raw = f.read()

if section:
    # Extract exactly the named '## <section>' heading's body, up to (not
    # including) the next '## ' heading or EOF. Single-sourced here so every
    # caller (CI job, PROMOTE.md, self-apply) applies the identical
    # CONTRIBUTING.md:129 scope decision — see the script header's SCOPE NOTE.
    heading_re = re.compile(r"^" + re.escape(section) + r"\s*$", re.MULTILINE)
    m = heading_re.search(raw)
    if not m:
        sys.stderr.write(f"::error::canonicalize-scan: section '{section}' not found in {src_path}\n")
        sys.exit(3)
    start = m.end()
    m2 = re.search(r"^## ", raw[start:], flags=re.MULTILINE)
    end = start + m2.start() if m2 else len(raw)
    raw = raw[start:end]

# (1) NFKC normalization — folds compatibility-decomposable variants
# (e.g. fullwidth U+FF29 -> ASCII 'I') into their canonical form.
normalized = unicodedata.normalize("NFKC", raw)

# (2) Zero-width strip — exactly the 4 named codepoints (honest, bounded set;
# see the script header's HONEST LIMIT block for what remains uncovered:
# U+2060 word-joiner, U+00AD soft-hyphen, U+180E, tag chars U+E0000-E007F).
ZERO_WIDTH = ("\u200b", "\u200c", "\u200d", "\ufeff")
canonical = normalized
for ch in ZERO_WIDTH:
    canonical = canonical.replace(ch, "")

with open(canon_path, "w", encoding="utf-8", errors="surrogateescape") as f:
    f.write(canonical)

# (3) Mixed-script FLAG — never auto-corrected, never silently passed.
# Heuristic: unicodedata.name() prefix as a script-family proxy (stdlib-only,
# no external script-detection dependency). A token mixing 2+ distinct script
# families (e.g. LATIN + CYRILLIC in the same word) is flagged. NFKC does NOT
# fold this class — a homoglyph substitution still MISSES the literal 6-token
# scan below even after canonicalization; only this flag catches it, and only
# to human review (AC-F2-3 — not an auto-correction, not an auto-catch).
SCRIPT_PREFIXES = (
    "LATIN", "CYRILLIC", "GREEK", "ARMENIAN", "HEBREW", "ARABIC",
    "CJK", "HIRAGANA", "KATAKANA", "HANGUL", "THAI", "DEVANAGARI",
)

def script_family(ch):
    try:
        name = unicodedata.name(ch)
    except ValueError:
        return None
    for prefix in SCRIPT_PREFIXES:
        if name.startswith(prefix):
            return prefix
    return None

flagged_tokens = []
for token in re.findall(r"[^\W\d_]+", canonical, flags=re.UNICODE):
    families = set()
    for ch in token:
        fam = script_family(ch)
        if fam:
            families.add(fam)
    if len(families) >= 2:
        flagged_tokens.append((token, sorted(families)))

with open(flag_path, "w", encoding="utf-8") as f:
    for token, families in flagged_tokens:
        f.write(f"{token}\t{'+'.join(families)}\n")
PYEOF

# (4) The ADR-055 6-token forbidden-imperative scan — run on the CANONICALIZED
# buffer ONLY. Byte-identical pattern to CONTRIBUTING.md:129 (MF-S-5).
SCAN_MATCH=0
if grep -iE '\b(Ignore|Disregard|Override|Instead of|Always respond|New instruction)\b' "$CANON_TMP" > /dev/null 2>&1; then
  SCAN_MATCH=1
fi

MIXED_SCRIPT_FLAG=0
if [ -s "$FLAG_TMP" ]; then
  MIXED_SCRIPT_FLAG=1
fi

if [ "$SCAN_MATCH" -eq 1 ]; then
  echo "::error::canonicalize-scan: forbidden imperative token found in ${TARGET} (post-canonicalization)."
  grep -inE '\b(Ignore|Disregard|Override|Instead of|Always respond|New instruction)\b' "$CANON_TMP" >&2 || true
  # A mixed-script flag on the same file is still reported for context, but the
  # forbidden-token match is the harder finding — exit 1 takes precedence.
  if [ "$MIXED_SCRIPT_FLAG" -eq 1 ]; then
    echo "::warning::canonicalize-scan: mixed-script token(s) also flagged in ${TARGET}:"
    cat "$FLAG_TMP" >&2
  fi
  exit 1
fi

if [ "$MIXED_SCRIPT_FLAG" -eq 1 ]; then
  echo "::warning::canonicalize-scan: mixed-script content FLAGGED for human review in ${TARGET} (NOT auto-caught, NOT auto-corrected — NFKC does not fold cross-script homoglyphs):"
  cat "$FLAG_TMP" >&2
  echo "::warning::A mixed-script flag is not itself proof of an injection attempt — it routes to human review, per the honest-limit posture this pool is curated (maintainer-reviewed) against."
  exit 2
fi

echo "canonicalize-scan: PASS — ${TARGET} clean after NFKC + zero-width strip; no forbidden token; no mixed-script flag."
exit 0
