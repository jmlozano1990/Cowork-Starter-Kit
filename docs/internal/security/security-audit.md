# Security Audit — claude-cowork-config v1.2 (Dynamic Workspace Architect)

## Phase: 6
## Date: 2026-04-17T19:30:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| A1 | WARNING | 6 | configuration | registry-cardinality-check CI job has a counting logic bug — computes DATA_ROWS=6 (not 18) and would fail on push with current registry |
| A2 | INFO | 6 | external-api | registry-url-check CI job silently passes non-http/https URL schemes (ftp://, relative paths) — gap in URL validation coverage |
| A3 | INFO | 6 | configuration | CLAUDE.md is 385 words (target ≤350, hard cap ≤400) — CI passes; S2 carry-forward partial resolution carried from Phase 5 WARN-1 |

---

### CRITICAL

*(None — pipeline not blocked)*

---

### WARNING

- [ ] **A1 — registry-cardinality-check CI job has a counting logic bug.** The job (`quality.yml` lines 272–297) uses the expression `HEADER_ROWS=$(grep -c '^| [A-Za-z]' ...)` to identify table header rows to subtract. However, the pattern `^| [A-Za-z]` matches **data rows** as well as header rows — every skill entry (e.g., `| flashcard-generation | ...`) starts with `| f` and matches this pattern.

  Simulation against the current registry (18 actual entries):
  - `ENTRY_COUNT=38` (all lines starting with `|`)
  - `HEADER_ROWS=25` (incorrectly includes all 18 data rows + 6 section header rows + 1 schema header row)
  - `SEPARATOR_ROWS=7`
  - `DATA_ROWS=6` (38 − 25 − 7 = 6, **not 18**)
  - **Result: CI would fail** — reports only 6 entries against a minimum of 18

  Impact: `registry-cardinality-check` is permanently broken on the current registry structure. Every push/PR would fail this job. The intended enforcement of "minimum 18 registry entries" is not functioning.

  **Recommendation:** Replace the current counting logic with a precise match on actual skill entry rows — lines containing `| builtin |` or `| https://` in column 3 position:
  ```bash
  DATA_ROWS=$(grep -cE '\| (builtin|https?://)' curated-skills-registry.md || echo 0)
  ```
  This reliably counts only actual skill entries (18 currently), regardless of table structure or header text. Simulated result on current registry: 18 entries — check passes correctly.

---

### INFO

- **A2 — registry-url-check silently passes non-http/https URL schemes.** The CI job (`quality.yml` lines 216–247) uses a regex that only extracts values matching `https?://[^\s|]+` or `builtin`. URL schemes other than `http://` and `https://` (e.g., `ftp://`, `data:`, `javascript:`, relative paths) would not be extracted by the regex and would silently pass the check. The job only **blocks** `http://` URLs it successfully extracts — it does not block patterns it does not extract.

  Risk rating: LOW-INFO. At v1.2 all 18 registry entries use `builtin`. This is a gap that matters when the first real community URL is added. Practical attack scenario: a contributor submits `ftp://attacker.com/SKILL.md` as a `source_url`. The link-check CI job would likely flag this (lychee checks external URLs), but the registry-url-check job specifically would not. The defense-in-depth is intact but the dedicated registry URL check has a narrower scope than intended.

  **Recommendation (v1.3 scope):** Extend the registry-url-check to also flag non-standard URL schemes. Simplest approach: after extracting non-`builtin` values, verify each matches exactly `^https://github\.com/` (or a configurable allowlist of trusted domains). Alternatively, add a complementary check: if `source_url` is not `builtin` and does not start with `https://`, fail.

- **A3 — CLAUDE.md 385 words (target ≤350, hard cap ≤400).** CLAUDE.md word count is 385 words. The security property established in ADR-011 targets ≤350 words; the CI hard cap is ≤400. The file passes CI. This is a non-blocking carry-forward from Phase 5 WARN-1 — flagged for @dev to trim 35 words in a future cycle if possible. No immediate action required.

---

### OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01:2021 — Broken Access Control | N/A | No access control system. Public repo. Template files only. No privileged operations. |
| A02:2021 — Cryptographic Failures | PASS | No secrets. No credentials. No encryption operations. Secrets scan: zero matches across all repo files. |
| A03:2021 — Injection | PASS | Prompt injection scan across all 31 LLM context files: zero injection payloads detected. CLAUDE.md and 6 starter files: no "ignore previous", "disregard", "override", "jailbreak", "system prompt", "you are now" patterns. Safety rule in 13/13 required locations. |
| A04:2021 — Insecure Design | PASS WITH A1 | 5-layer safety rule defense-in-depth is operational. A1 finding (cardinality check bug) is a CI logic defect, not an architectural failure. Core design is sound. |
| A05:2021 — Authentication Failures | N/A | No authentication system. |
| A06:2021 — Sensitive Data Exposure | PASS | Writing profile template confirmed free of raw sample fields. "Do NOT store raw sample text" instruction present in all 7 wizard surfaces. S8 fully resolved. |
| A07:2021 — Identification & Authentication Failures | N/A | No auth. No sessions. |
| A08:2021 — Software & Data Integrity Failures | PASS WITH A1 | 18 CI action uses: entries all SHA-pinned (18/18 full 40-char commit SHAs). curated-skills-registry.md has HTTPS-only enforcement via registry-url-check (functional). A1 affects cardinality enforcement only. |
| A09:2021 — Security Logging | N/A | No runtime system. Git history is audit trail. |
| A10:2021 — Server-Side Request Forgery | N/A | No server. No HTTP requests during wizard execution. |

### OWASP LLM Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 — Prompt Injection | PASS | Comprehensive injection scan across CLAUDE.md, 6 starter files, 18 SKILL.md, 6 global-instructions.md, 6 writing-profile.md, 1 setup-wizard/SKILL.md — zero injection vectors found. No "ignore previous", "disregard", "new instruction", "you are now", "act as", "pretend", "jailbreak", "override", "bypass" patterns. Phase 2 LLM01 ELEVATED rating was contingent on community PR injection — the CI controls (safety-rule-check, starter-safety-rule-check, claude-md-safety-rule-check) now provide machine enforcement. PASS for current content; WATCHED for future community PRs. |
| LLM02 — Insecure Output Handling | PASS | Wizard output is local files only. writing-profile.md output now confirmed patterns-only — "do NOT store raw sample text" instruction verified in all 7 wizard surfaces. No programmatic downstream execution of wizard output. |
| LLM06 — Excessive Agency | PASS | No irreversible external actions in any wizard instruction. Safety rule in 13/13 locations enforces confirmation before destructive operations. setup-wizard/SKILL.md includes explicit reset guard. |

---

## Phase 2 Carry-Forward Resolution Audit

### S1 — CONTRIBUTING.md v1.2 PR checklist (WARNING → RESOLVED)

CONTRIBUTING.md confirmed to contain all 11 checklist items including the 4 v1.2 additions:
- Item 8: `writing-profile.md` present with non-placeholder content
- Item 9: `curated-skills-registry.md` schema compliance + vetting evidence
- Item 10: CLAUDE.md sync requirement (all 7 wizard surfaces in sync)
- Item 11: Starter file ≤350 words (updated from v1.1 ≤300)

Additionally, CONTRIBUTING.md contains:
- CLAUDE.md high-impact notice with 3-point PR protocol (S4 carry-forward)
- Registry SHA-pin guidance with correct/avoid examples (S3 carry-forward)
- Tier 2 scope note — "Do not submit PRs that add new repos to that list" (S6 carry-forward)
- No raw Sample/Raw sample field requirement — "extract patterns only" (S8 carry-forward)
- `source_url: builtin` reserved-for-Anthropic guidance (S7)

**Verdict: FULLY RESOLVED.**

### S2 — claude-md-word-count-check CI job (WARNING → PARTIAL)

CI job present at `quality.yml` lines 173–191. Verified logic: `wc -w < CLAUDE.md` compared against 400-word hard cap. Job passes at current 385 words. Implementation is correct.

CLAUDE.md is 385 words — 35 words over the 350-word security target but 15 words under the 400-word hard cap. CI enforces the hard cap only. This partial resolution was documented in Phase 5 WARN-1 and is non-blocking.

**Verdict: PARTIAL — hard cap enforced (400 words), target (350 words) not met. Non-blocking. Carry as A3 (INFO).**

### S3 — registry-url-check CI job + SHA-pin guidance (WARNING → RESOLVED)

`registry-url-check` job present at `quality.yml` lines 216–247. Verified logic:
- Extracts `https?://...` or `builtin` values from registry table rows using PCRE lookaround
- Flags and fails on `http://` URLs
- CONTRIBUTING.md SHA-pin guidance present with correct/avoid examples

Simulation against current registry: 18 `builtin` entries — all pass, no false failures, no false passes.

Minor INFO gap (A2): non-http/https URL schemes silently pass — noted above, v1.3 scope.

**Verdict: RESOLVED for v1.2 scope. A2 is a v1.3 improvement recommendation.**

### S4 — CLAUDE.md blast radius guidance (WARNING → RESOLVED)

CONTRIBUTING.md `## CLAUDE.md changes — high-impact notice` section confirmed present with:
1. All 6 starter file sync requirement
2. Explanation requirement in PR description
3. Maintainer review requirement
4. Bidirectional sync notice (starter file changes must update CLAUDE.md too)

**Verdict: FULLY RESOLVED at CONTRIBUTING.md level. No CI sync check (stretch goal) — acceptable at v1.2.**

### S6 — Tier 2 repo list control (INFO → RESOLVED)

CONTRIBUTING.md explicitly states: "Do not submit PRs that add new repos to that list — open an issue to request additions." This is the appropriate human-control for this surface.

**Verdict: RESOLVED.**

### S8 — No raw sample field in template (INFO → RESOLVED)

`templates/writing-profile-template.md` audited: no `Sample:` or `Raw sample:` field. All 7 wizard surfaces (CLAUDE.md + 6 starter files) contain "do NOT store raw sample text" or "do NOT store raw sample" instruction. QA T12 confirmed no raw sample field in template.

**Verdict: FULLY RESOLVED.**

---

## New Surface Audit — v1.2

### CLAUDE.md (Universal Layer 1a Entry Point)

CLAUDE.md is 385 words. Content audited for:

| Check | Result |
|-------|--------|
| Safety rule present | PASS |
| AskUserQuestion nudge present | PASS |
| State machine check (cowork-profile.md existence) | PASS |
| Goal detection opener present | PASS |
| Suggestion branch (3 options for uncertainty) | PASS |
| Writing profile step present | PASS |
| Fast-track pause after Phase 3 | PASS |
| Raw sample extraction instruction | PASS ("Do NOT store raw sample text") |
| No injection payloads | PASS |
| No instructions to override safety rules | PASS |
| No external data ingestion | PASS |
| No instructions to access files outside workspace | PASS |

**Assessment: PASS. The content is a well-scoped wizard bootstrap. No unsafe patterns.**

### curated-skills-registry.md (Trust Surface — New in v1.2)

| Check | Result |
|-------|--------|
| File exists at repo root | PASS |
| 18 skill entries present | PASS (18 entries confirmed) |
| All source_url values are `builtin` or HTTPS | PASS (18/18 `builtin`) |
| No `http://` URLs | PASS |
| Schema field compliance (6 fields per row) | PASS |
| vetting_date field present on all entries | PASS (2026-04-17 on all 18) |
| tier field: all Tier 1 | PASS |
| No Tier 2 entries at launch | PASS (zero community entries) |
| CONTRIBUTING.md `builtin` sentinel guidance | PASS (explicit reservation for Anthropic official) |
| CI registry-url-check functional | PASS (simulation confirmed) |
| CI registry-cardinality-check functional | FAIL (A1 — logic bug, DATA_ROWS=6 not 18) |

**Assessment: PASS WITH A1. Content is clean; CI logic bug requires fix before first community PR.**

### Starter Files (6 × ≤350 words)

| File | Words | Safety Rule | AskUserQuestion | Raw Sample Instruction | State Machine |
|------|-------|-------------|-----------------|------------------------|---------------|
| study | 338 | PASS | PASS | PASS | PASS |
| research | 338 | PASS | PASS | PASS | PASS |
| writing | 340 | PASS | PASS | PASS | PASS |
| project-management | 340 | PASS | PASS | PASS | PASS |
| creative | 340 | PASS | PASS | PASS | PASS |
| business-admin | 340 | PASS | PASS | PASS | PASS |

**Assessment: PASS. All 6 files ≤340 words (well below 350 target). All required elements present.**

### Writing Profile Template

| Check | Result |
|-------|--------|
| File exists at `templates/writing-profile-template.md` | PASS |
| 5 sections present (Tone & Voice, Style Preferences, Anti-AI Guidance, Workspace-Specific Rules, Pet Peeves) | PASS |
| No `Sample:` or `Raw sample:` field | PASS |
| No stored user content | PASS |
| Anti-AI framing uses "voice calibration" (not "bypass") | PASS |

**Assessment: PASS. S8 resolution confirmed.**

### Global Instructions (6 Presets)

| Check | Result |
|-------|--------|
| Safety rule in 6/6 global-instructions.md | PASS |
| Writing profile trigger rule present (≥100 words threshold) | PASS — spot-checked writing preset |
| Proactive skill trigger format | PASS |
| No unsafe patterns | PASS |

**Assessment: PASS.**

### 18 Skill Files

| Check | Result |
|-------|--------|
| All in folder/SKILL.md format (no flat .md files) | PASS |
| All have YAML frontmatter (name:, description: fields) | PASS |
| No instructions to override safety rules | PASS |
| No instructions to access external URLs/APIs | PASS |
| No prompt injection payloads | PASS |
| No file deletion instructions | PASS |

**Assessment: PASS. All 18 skills are clean with consistent format.**

### CI Workflow (14 jobs)

| Job | SHA-Pinned | Logic Verified | Status |
|-----|-----------|----------------|--------|
| markdown-lint | PASS | N/A | PASS |
| link-check | PASS | N/A | PASS |
| link-check-external | PASS | N/A | PASS |
| shellcheck | PASS | N/A | PASS |
| safety-rule-check | PASS | Correct .txt glob for global-instructions | PASS |
| starter-file-check | PASS | Hardcoded 6-preset list + count check | PASS |
| starter-safety-rule-check | PASS | .txt glob confirmed; count check ≥6 present | PASS |
| skill-format-check | PASS | No flat .md + SKILL.md in each folder | PASS |
| claude-md-safety-rule-check | PASS | Correct string match | PASS |
| claude-md-word-count-check | PASS | 400-word hard cap enforced | PASS |
| writing-profile-template-check | PASS | 3 required sections checked | PASS |
| registry-url-check | PASS | HTTPS/builtin enforced; http:// blocked | PASS |
| starter-file-word-count-check | PASS | 400-word hard cap on starter files | PASS |
| registry-cardinality-check | PASS | **FAIL — logic bug (A1)** | WARNING |

All 18 `uses:` entries are pinned to full 40-character commit SHAs. Zero unpinned actions.

---

## Independent Classification Verification

**Signal received:** SECURITY-SENSITIVE (from Phase 5 Summary)
**Independent verification:** CONFIRMED SECURITY-SENSITIVE.

Independent check findings that confirm the classification:
1. CLAUDE.md is auto-loaded as LLM system context for any user who opens the repo folder in Cowork (ADR-010 Layer 1a). This is a new-in-v1.2 auto-execution surface.
2. curated-skills-registry.md introduces an external URL trust surface (source_url field) that was absent in v1.1.
3. The writing profile step involves user-provided content (writing samples) in the wizard flow — a new PII-adjacent data handling surface.

All three surfaces are new relative to v1.1. SECURITY-SENSITIVE classification is correct. No override required.

---

## Secrets Scan

| Pattern | Matches |
|---------|---------|
| API keys, tokens, secrets, credentials | 0 |
| Bearer tokens, authorization headers | 0 |
| `.env`, `.pem`, `.key`, `.p12` file references | 0 (`.env` in `.gitignore` only) |
| Hardcoded URLs with credentials (user:pass@host) | 0 |
| AWS/OpenAI/Anthropic key patterns | 0 |

**Zero secrets found across all repo files.**

---

## Summary

The v1.2 Dynamic Workspace Architect implementation is clean. All four Phase 2 WARNINGs (S1–S4) are resolved or mitigated to the level specified. The new security surfaces introduced in v1.2 — CLAUDE.md as universal entry point, curated-skills-registry.md, and the writing profile step — were implemented correctly:

- CLAUDE.md content is well-scoped (385 words) with all required safety elements present
- The registry is clean at launch (18 Tier 1 `builtin` entries, zero community URLs)
- The writing profile pattern-only design is faithfully implemented (no raw sample fields anywhere)
- The 5-layer safety rule defense-in-depth is fully operational

**One WARNING was found during audit** that was not detected by Phase 5 testing: the `registry-cardinality-check` CI job has a logic bug in its row-counting algorithm that would produce a false failure (DATA_ROWS=6, threshold 18) on the current registry. The 18 actual registry entries are correctly present; only the CI job counting them is broken. This does not affect the security posture of the current release (18 `builtin` entries require no cardinality enforcement), but it means the intended CI guard for community PRs adding/removing entries would fire on every commit. Fix required before the first community PR is merged.

No CRITICAL findings. One WARNING (CI logic bug — fix recommended before community PR ingestion begins). Two INFO findings (URL scheme coverage gap, CLAUDE.md 35 words over target).

**Decision: PASS WITH WARNINGS.**

---

## Phase 6 History

### v1.0 Audit (2026-04-15T18:30:00Z)
PASS — 0 findings. All v1.0 Phase 2 carry-forwards (S1/S2/S3) confirmed resolved.

### v1.1 Audit (2026-04-16T09:30:00Z)
PASS — 0 findings. S1/S2 v1.1 carry-forwards confirmed resolved. 31 LLM context files clean.

### v1.2 Audit (this document — 2026-04-17T19:30:00Z)
PASS WITH WARNINGS — 1 WARNING (CI logic bug), 2 INFO.
