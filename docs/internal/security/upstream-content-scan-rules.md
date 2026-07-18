# Upstream Content Scan Rules

**Version:** 1.0 (v2.0.0)
**Owner:** @security
**Status:** ACTIVE — referenced by `.github/workflows/sync-agency.yml` content-scan step

These rules implement S1 CRITICAL from the v2.0 Phase 2 security review. The
`/sync-agency` CI workflow runs these patterns against every file fetched from
`msitarzewski/agency-agents` before updating the lock file. Any hit flags the
file for human review (`requires_review` workflow) — the `/sync-agency` PR is
NOT auto-merged.

> **OWASP mapping:** LLM01 (Prompt Injection) — upstream agent files are
> LLM instruction surfaces. A file containing adversarial imperative phrases
> becomes a live instruction injected into user workspaces.

---

## Pattern Set (8 patterns)

These are case-insensitive extended regular expressions (`grep -iE`). A match
in any fetched upstream file triggers a `requires_review` flag on the
`/sync-agency` PR.

### Pattern 1 — Ignore previous instructions

```regex
ignore (previous|all|prior) instructions?
```

**Rationale:** Classic prompt injection preamble. Intended to cause the LLM
to discard its system context before executing attacker-supplied instructions.

### Pattern 2 — Disregard instructions

```regex
disregard (your|all|any|previous|prior)? ?(instructions?|rules?|guidelines?|context)
```

**Rationale:** Synonym for Pattern 1. Variations include "disregard your
guidelines" and "disregard all rules."

### Pattern 3 — Override instructions

```regex
override (your|all|any|previous|prior)? ?(instructions?|rules?|guidelines?|context|settings?)
```

**Rationale:** Common injection variant targeting instruction override. May
appear in seemingly benign "configuration" files.

### Pattern 4 — You are now / Act as

```regex
you are now |act as (a |an )?(different|new|unrestricted|jailbreak|dan|system|root)
```

**Rationale:** Role-reassignment injection. "You are now DAN" and "act as
an unrestricted AI" are archetypal jailbreak patterns.

### Pattern 5 — New instruction / New system prompt

```regex
new (system )?(instruction|prompt|directive|rule)s?:
```

**Rationale:** Signals an attempt to inject a secondary system prompt within
the file content. Colon suffix indicates the attacker expects the LLM to
parse what follows as instructions.

### Pattern 6 — Forget the rules / Forget your instructions

```regex
forget (the |your |all |these )?(rules?|instructions?|guidelines?|constraints?|training)
```

**Rationale:** Instruction erasure pattern. Intended to cause the LLM to
ignore its configured behavior before processing attacker content.

### Pattern 7 — Pretend you are / Pretend you have no

```regex
pretend (you (are|have no|don't have)|this is not|there (are|is) no) ?(instructions?|rules?|restrictions?|guidelines?)?
```

**Rationale:** Hypothetical framing injection. "Pretend you have no
restrictions" is a common jailbreak entry point.

### Pattern 8 — Jailbreak / DAN / STAN

```regex
jailbreak|do anything now|stan (mode|prompt)|developer mode (enabled|on|activated)
```

**Rationale:** Named jailbreak tokens. "DAN" (Do Anything Now), "STAN"
(Strive To Avoid Norms), and "developer mode" are documented attack strings
with known effectiveness histories.

---

## Usage in `/sync-agency` CI

The `/sync-agency` workflow runs the content-scan step after fetching each
allowlisted file and before writing to the lock file:

```bash
# For each fetched file:
FLAGGED=0
while IFS= read -r pattern; do
  if grep -iEq "$pattern" "$fetched_file"; then
    echo "::warning::CONTENT-SCAN HIT — pattern '$pattern' in $fetched_file"
    FLAGGED=1
  fi
done < docs/security/upstream-content-scan-rules.md.patterns

if [ "$FLAGGED" -eq 1 ]; then
  echo "requires_review=true" >> "$GITHUB_OUTPUT"
fi
```

The patterns file (`upstream-content-scan-rules.md.patterns`) is generated
by the workflow from this document — one pattern per line, extracted from
fenced code blocks.

**Hit behavior:**
- File is still added to the lock file with `"requires_review": true`
- PR label `security-review-required` is added
- PR body includes a hit-summary table (file path, pattern matched)
- PR is NOT auto-mergeable while `security-review-required` label is present
- A maintainer with CODEOWNERS approval must manually clear the label

---

## Audit History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-07 | Initial 8-pattern set per v2.0 Phase 2 S1 CRITICAL finding |

---

## Maintenance Notes

- This document is the authoritative source for content-scan patterns.
- Adding a pattern: update this file + add a row to the Audit History table.
  No CI change is needed — `/sync-agency` extracts patterns from fenced
  blocks automatically.
- Removing a pattern requires @security sign-off (CODEOWNERS: quality.yml).
- Patterns must be case-insensitive extended regex (`grep -iE` compatible).
- False-positive assessment: any pattern hit on a legitimate upstream file
  should be reviewed. If it is a false positive, either (a) the pattern needs
  tightening, or (b) the file requires annotation in `.cowork-allowlist.json`
  `requires_review` list.
