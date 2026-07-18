# Security Audit — v2.4 Dynamic Workspace Architect (Phase 6 FULL)

## Phase: 6 (full mode — SECURITY-SENSITIVE)
## Date: 2026-05-09T08:30:00Z
## Status: PASS — 0 CRITICAL · 0 WARNING · 1 INFO
## Classification: SECURITY-SENSITIVE (independently re-confirmed at Phase 6 per V10-S2)
## Combined-path: NOT eligible (locked at Phase 0; FULL audit ran)
## Audited at: PR #41 HEAD `77741c46fbd3b26bfadbc25459ea9c8a05b61db6` on `release/v2.4.0`
## Cycle: v2.4 — Dynamic Workspace Architect
## Inputs: docs/security-review-v2.4.md (Phase 2), docs/qa-report-v2.4.md (Phase 5)

---

## Verdict

**PASS.** All 6 Phase 2 audit handoff items re-verified at HEAD. All 8 preservation constraints byte-unchanged. MF-1 and MF-2 vocab gates fault-inject correctly (semicolon → MF-1 fires; `$` in goal_tags → MF-2 fires). F3/F4/F5 prose grep clean — no shell injection vectors in WIZARD.md runtime contract; `eval`/`exec` matches are definitional prose ("evaluating keyword presence", "execution") and security-note negations ("Never executed"), not behavioral verbs. F5 attribution-injection ordering numbered correctly (1 lookup → 2 IF non-builtin inject ADR-024 BEFORE write → 3 copy → 4 emit). C-v2.4-3 cmp byte-mirror spot-check 6/6 PASS. action-items + doc-summary content benign. CI 39 PASS / 1 SKIPPED / 0 FAIL re-verified at HEAD via `gh pr checks 41`.

The single INFO item (I1) is a defense-in-depth hardening recommendation for the `|| true` grep-c masking pattern on the MF-1/MF-2 gates — not an active vulnerability; current upstream structural CI checks make the bypass non-exploitable in practice. Carry-forward to v2.5 alongside CF-v2.4-B (W-1 MF-2 col7 fragility refactor).

Phase 7 final approval is unblocked. Combined-path remains NOT eligible per Phase 0 lock.

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| I1 | INFO     | 6     | configuration | MF-1/MF-2 grep-c `\|\| true` masking — if upstream awk pipeline produces empty output (e.g., file structurally broken), grep exits 1 and `\|\| true` collapses BAD to empty; `${BAD:-0}` then defaults to 0 and the gate silently passes. NOT exploitable in v2.4 because POOL/CMP/file-existence checks upstream catch structural breakage before this gate runs. Recommend explicit empty-pipeline assertion (`set -o pipefail` on the BAD subshell or asserting awk produced ≥1 line) when CF-v2.4-B refactors MF-2 to header-name lookup. Bundle with CF-v2.4-B at v2.5. |

### CRITICAL
(none)

### WARNING
(none)

### INFO
- **I1 — `|| true` grep-c masking on MF-1/MF-2 vocab gates.** Logic flow: `BAD=$(awk ... | grep -cE 'PATTERN' || true); if [ "${BAD:-0}" -gt 0 ]; then exit 1; fi`. The `|| true` is required to handle grep's exit-1 on zero matches (which is the COMMON CLEAN-INPUT case). However, it also masks pipeline failures: if the upstream awk produces zero lines because the file structure is broken (e.g., fenced-code block markers stripped, table column reordered, file truncated mid-row), grep exits 1 too, `|| true` swallows that error, BAD becomes empty, and `${BAD:-0}=0` → gate passes silently on broken input. **Why this is INFO and not WARNING in v2.4:** the gate runs AFTER `if [ -f selection-presets.md ]`/`if [ -f curated-skills-registry.md ]` existence checks AND AFTER POOL+CMP+ENFORCED_EXAMPLES jobs that assert structural shape (cardinality, fenced-block presence, byte-mirror invariant). Any structural breakage that would cause empty awk output would cause an upstream job to fail first. **The bypass is non-exploitable on the v2.4 surface.** **Recommendation for v2.5:** when CF-v2.4-B implements MF-2 header-name lookup (replacing positional `$7`), add `set -o pipefail` inside the BAD subshell OR add an explicit `[ "$(awk ... | wc -l)" -gt 0 ] || { echo "::error::structural break"; exit 1; }` precondition. Also folds W-1 / CF-v2.4-B fragility concern into a single hardening commit. **Carry-forward CF-v2.4-G** (new): gate-bypass hardening (pipefail + structural precondition) bundled with CF-v2.4-B at v2.5.

---

## OWASP Web Top 10 — FULL pass at HEAD 77741c4

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth surface, no RLS, no IDOR. v2.4 introduces no permission/role surface. |
| A02 Cryptographic Failures | N/A | No new crypto. cowork.lock.json BYTE-UNCHANGED (re-verified, see Preservation block below). ADR-028 `content_sha256` PROPOSED unchanged. |
| A03 Injection | PASS | F3 keyword-set-intersection over already-tokenized lists. WIZARD.md prose grep at HEAD: 0 hits for `bash -c`, `system(`, `$(` shell substitution; 0 hits for `https?://`. The 1 `eval` hit (line 303) is definitional prose ("Before evaluating keyword presence") in the ADR-030 stopword filter description, not a shell verb. The 2 `exec` hits are "Sonnet for execution" (model alias prose, line 11) and the security-note negation "Never executed, never passed to a sub-call" (line 41). C-v2.4-9 CI loops use bash glob + `for preset in $ENFORCED_EXAMPLES; do` — no `eval`, no `$(...)` of user data. |
| A04 Insecure Design | PASS | 3-path router (A/B/C) is bounded keyword set-intersection; F4 bounded by in-tree pool; F5 bounded by confirmed bundle. AC-F3-2 enforces user-confirmation at every routing decision (verified by @qa: 3 confirmation phrases at WIZARD.md L47, L49, L70). C-v2.4-6 binds no-LLM-subcall + no-network + no-regex-as-instruction. |
| A05 Security Misconfiguration | PASS | MF-1 + MF-2 vocab gates implemented and fault-inject correctly (see "Fault-injection results" below). I1 INFO is the residual hardening item, non-exploitable in v2.4. |
| A06 Vulnerable & Outdated Components | PASS | Zero new deps in v2.4. `git diff main..release/v2.4.0` adds only markdown + quality.yml CI bash; no new actions, no package additions. |
| A07 Identification & Authentication | N/A | No auth surface. |
| A08 Software & Data Integrity | PASS | cowork.lock.json BYTE-UNCHANGED (`git diff main..release/v2.4.0 -- cowork.lock.json` empty). SCAN_PATTERNS at sync-agency.yml L143+L220 BYTE-UNCHANGED (`git diff` empty; line numbers preserved). `.cowork-allowlist.json` BYTE-UNCHANGED. CLAUDE.md BYTE-UNCHANGED (397 words preserved). C-v2.4-3 cmp byte-mirror invariant: 6/6 spot-check pairs PASS at HEAD. |
| A09 Security Logging & Monitoring | N/A | No logging/telemetry surface. Static markdown repo. |
| A10 Server-Side Request Forgery | N/A | No outbound requests. F3/F4/F5 introduce zero URL fetch. F4 URL-paste rejection prose at WIZARD.md L85 verified ("External skills are not yet supported in v2.4 — coming in v2.5"). |

---

## OWASP LLM Top 10 — FULL pass (SECURITY-SENSITIVE)

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 Prompt Injection | PASS | 5 vectors named by Phase 1 architecture re-checked at HEAD: (1) goal-text-as-instructions — verified data-only at WIZARD.md L38-L41 (lowercase + split on `[^a-z]+` + set-intersect; security-note prose binds DATA-only); (2) selection-preset tampering — MF-1 vocab gate fault-inject confirmed firing on `;` injection; (3) F4 surface expansion — pool-bounded prose at L85 verified; (4) Path C abuse — keyword-match against finite registry, no LLM judgment (C-v2.4-6); (5) slug confusion — registry slug `email-drafting` matches SKILL.md frontmatter `name:`. SCAN_PATTERNS chokepoint at sync-agency.yml L143+L220 BYTE-UNCHANGED. |
| LLM02 Insecure Output Handling | PASS | F5 emits `cp` confirmation strings drawn from confirmed-bundle data set, not raw goal text. skills-as-prompts.md generation reads `## Instructions` from installed SKILL.md and concatenates with H2 — same shape as v2.3.x. |
| LLM03 Training Data Poisoning | N/A | No model training. |
| LLM04 Model DoS | PASS | F3 keyword-match bounded: ≤8 tokens × 7 presets = ≤56 comparisons; Path C ≤22 registry rows. No regex compiled from user input — no backtracking surface. |
| LLM05 Supply Chain | PASS | All 22 registry rows `source_url=builtin` at HEAD. CF-v2.4-B (first external import) deferred to v2.5; @compliance Phase 2/6 will run at that time. |
| LLM06 Sensitive Information Disclosure | PASS | spend-awareness 4 verbatim phrases preserved (carry-forward from v2.3.1). v2.4 does not modify any pre-existing SKILL.md content; pool was populated via cmp-byte-mirror copy from already-vetted `examples/<preset>/` paths. action-items (86L) + doc-summary (80L) content audit clean — no PII, no credentials, no embedded prompt-injection vectors in description, frontmatter, or body. |
| LLM07 Insecure Plugin Design | PASS | F4 pool-bounded; no URL paste, no `source_url` direct fetch, no fallback-to-external. WIZARD.md L85 prose verified. |
| LLM08 Excessive Agency | PASS | 3-path router is suggestion engine; AC-F3-2 confirmation at every install decision (3 confirmation phrases at L47/L49/L70 — @qa-verified). C-v2.4-6 binds keyword-only routing. |
| LLM09 Overreliance | N/A | Wizard is interview-driven; user is final decision-maker at every gate. |
| LLM10 Model Theft | N/A | Static markdown repo. |

---

## Phase 2 Audit Handoff items — re-verification

### (1) MF-1 + MF-2 fault-injection at HEAD (verifies gates fire on poisoned input)

**MF-1 — `selection-presets.md` token-vocabulary gate**

Implementation extracted from `.github/workflows/quality.yml` at HEAD:
```bash
BAD=$(awk '/^```preset$/,/^```$/' selection-presets.md \
  | grep -E '^(match_signals|skill_bundle): ' \
  | grep -cE '[^a-z0-9, :_-]' || true)
if [ "${BAD:-0}" -gt 0 ]; then
  echo "::error::selection-presets.md contains invalid token vocabulary..."
  exit 1
fi
```

| Test | Input | Expected | Observed | Result |
|------|-------|----------|----------|--------|
| Clean | unmodified `selection-presets.md` | BAD=0 | BAD=0 | PASS |
| Poison | first `match_signals:` line prefixed with `evil; rm -rf, ` | BAD≥1 (semicolon outside `[a-z0-9, :_-]`) | BAD=1 | PASS — gate fires |

**MF-2 — `curated-skills-registry.md` `goal_tags` vocabulary gate**

Implementation:
```bash
BAD=$(awk -F'|' '/^\| / && NR>2 { print $7 }' curated-skills-registry.md \
  | grep -vE '^[[:space:]]*(goal_tags|---)' \
  | grep -cE '[^a-z0-9, -]' || true)
if [ "${BAD:-0}" -gt 0 ]; then
  echo "::error::curated-skills-registry.md goal_tags contains invalid token vocabulary..."
  exit 1
fi
```

| Test | Input | Expected | Observed | Result |
|------|-------|----------|----------|--------|
| Clean | unmodified registry | BAD=0 | BAD=0 | PASS |
| Poison | line 28 (flashcard-generation) `goal_tags` cell modified to `study,$evil` | BAD≥1 (`$` outside `[a-z0-9, -]`) | BAD=1 | PASS — gate fires |

**MF-1 + MF-2 verdict: PASS.** Both gates fire on adversarial input as designed.

(Note: Phase 2 review's example patch text used `$8` in the awk field index, which would be incorrect for the 6-data-column registry; @dev correctly used `$7` in the actual implementation. Field-position is the W-1 / CF-v2.4-B fragility item already deferred to v2.5.)

### (2) SCAN_PATTERNS chokepoint preservation

```
git diff main..release/v2.4.0 -- .github/workflows/sync-agency.yml
```
**Result:** empty. BYTE-UNCHANGED.

```
grep -n 'SCAN_PATTERNS' .github/workflows/sync-agency.yml
```
**Result:** L143 (declaration), L220 (iteration). Line numbers identical to Phase 2 record. 8-pattern body intact.

**Verdict: PASS.**

### (3) Slug-fix consumer search at HEAD

```
grep -rn 'email-drafter' . --exclude-dir=.git
```

**Hits found** (all design-discussion or release-note prose; ZERO consumer-code references):
- `CHANGELOG.md:28` — release note: "slug fix `email-drafter` → `email-drafting`" (expected, references the fix)
- `docs/security-review-v2.4.md:71` + `:158` — Phase 2 review prose (expected)
- `docs/architecture.md` — 9 design-discussion lines (5093, 5101, 5106, 5116, 5168, 5172, 5201, 5359, 5451 — all prose explaining the fix)
- `docs/spec.md` — 3 design-discussion lines (2631, 3785, 4142)
- `docs/qa-report-v2.4.md:76,80` — QA's verifier listing (expected)

**ZERO hits in:** WIZARD.md, CLAUDE.md, scripts/, .github/workflows/, .cowork-allowlist.json, cowork.lock.json, examples/, skills/, selection-presets.md, curated-skills-registry.md (the registry row at line 69 is now `email-drafting`, not `email-drafter` — fix landed).

**Verdict: PASS.** No runtime consumer references the legacy slug.

### (4) WIZARD.md F3/F4/F5 prose grep — injection vectors

| Pattern | Hits | Disposition |
|---------|------|-------------|
| `eval` | 1 (line 303) | "Before **eval**uating keyword presence" — definitional prose, ADR-030 stopword filter description. NOT a shell verb. PASS. |
| `bash -c` | 0 | PASS |
| `system(` | 0 | PASS |
| `exec` | 2 | Line 11: "opusplan (Opus for planning, Sonnet for **exec**ution)" — model alias prose. Line 41: security-note "Never **exec**uted, never passed to a sub-call" — negation. Both benign. PASS. |
| `$(` | 0 | PASS — no shell substitution syntax in WIZARD.md |
| `https?://` | 0 | PASS — F4 URL-paste rejection prose uses literal "URL" word, not example URL |

**Verdict: PASS.** No exploitable shell-injection or URL-installation vectors in WIZARD.md F3/F4/F5 sections.

### (5) F5 attribution-injection ordering grep (S4 follow-through, SF-2 fold)

WIZARD.md lines 213-222 (Step 4 — Install skill files):

```
For each `<slug>` in the user's confirmed final bundle from F4:

1. Look up `source_url` in `curated-skills-registry.md` for the slug.
2. **IF** `source_url` is NOT `"builtin"`: inject the ADR-024 6-field attribution
   block into the SKILL.md content buffer BEFORE writing to disk. This check
   MUST happen before the file write — never after. ...
3. Copy `skills/<slug>/SKILL.md` to `<user-workspace>/.claude/skills/<slug>/SKILL.md`.
4. Emit confirmation: "Installed [Skill Name]."
```

**Verdict: PASS.** SF-2 (S4 disposition) folded by @dev as numbered sub-steps with explicit "BEFORE writing to disk" + "MUST happen before the file write — never after" binding. v2.5 first-external-import readiness contract is in place.

### (6) C-v2.4-3 cmp byte-mirror spot-check

| # | Pair | Result |
|---|------|--------|
| 1 | `skills/flashcard-generation/SKILL.md` vs `examples/study/.claude/skills/flashcard-generation/SKILL.md` | PASS |
| 2 | `skills/literature-review/SKILL.md` vs `examples/research/.claude/skills/literature-review/SKILL.md` | PASS |
| 3 | `skills/voice-matching/SKILL.md` vs `examples/writing/.claude/skills/voice-matching/SKILL.md` | PASS |
| 4 | `skills/creative-brief/SKILL.md` vs `examples/creative/.claude/skills/creative-brief/SKILL.md` | PASS |
| 5 | `skills/email-drafting/SKILL.md` vs `examples/business-admin/.claude/skills/email-drafting/SKILL.md` | PASS |
| 6 (extra) | `skills/status-update/SKILL.md` vs `examples/project-management/.claude/skills/status-update/SKILL.md` | PASS |

**Verdict: PASS.** 6/6 spot-check pairs byte-identical. CMP CI gate is wired correctly (not silently skipping).

---

## Preservation Constraints Re-verified at HEAD 77741c4

| Constraint | Verifier | Result |
|------------|----------|--------|
| SCAN_PATTERNS sync-agency.yml byte-unchanged | `git diff main..release/v2.4.0 -- .github/workflows/sync-agency.yml` empty + L143/L220 lines preserved | PASS |
| `.cowork-allowlist.json` byte-unchanged | `git diff main..release/v2.4.0 -- .cowork-allowlist.json` empty | PASS |
| CLAUDE.md byte-unchanged ≤400w | `git diff main..release/v2.4.0 -- CLAUDE.md` empty; `wc -w CLAUDE.md` = 397 | PASS |
| `cowork.lock.json` byte-unchanged | `git diff main..release/v2.4.0 -- cowork.lock.json` empty | PASS |
| ADR-024 verbatim attribution rule preserved | 28 occurrences of `ADR-024` in architecture.md; F5 numbered ordering at WIZARD.md 213-222 binds the contract | PASS |
| ADR-028 PROPOSED status preserved | `grep ADR-028` shows `Status: PROPOSED (impl deferred to v2.5)` at architecture.md L47 (ADR Index row); body untouched in diff | PASS |
| `presets/` symlink absent | `ls` confirms no `presets/` dir; only `examples/` + `skills/` (v2.4 new) | PASS |
| Pool cardinality = 20 | `ls skills/ \| wc -l` = 20 (verified by @qa, re-confirmed via `find skills/ -name SKILL.md` count = 20) | PASS |

**Verdict: PASS — 8/8 preservation constraints intact.**

---

## action-items + doc-summary content review (Phase 4 expansion files)

`skills/action-items/SKILL.md` (86 lines):
- Frontmatter: `name: action-items`, `description: Identify and structure action items...`, 4 trigger_examples
- Injection-vector grep (`eval(`, `exec(`, `bash -c`, `system(`, `$(`, suspicious `https?://`): **0 hits**
- Content benign — straightforward action-item extraction skill

`skills/doc-summary/SKILL.md` (80 lines):
- Frontmatter: `name: doc-summary`, `description: Extract the key insight...`, 4 trigger_examples
- Injection-vector grep: **0 hits**
- Content benign — document summarization skill

**Verdict: PASS.** Both Phase 4 expansion files are clean.

---

## R-001 / R-002 / R-004 carry-forward disposition

These are legacy carry-forward IDs from earlier cycles. Search results:
- No active R-001/R-002/R-004 strings in v2.4 diff
- `git diff main..release/v2.4.0` does not reintroduce, mutate, or re-open any of these
- v2.4's relevant carry-forwards are CF-v2.4-A through CF-v2.4-F (deferred to v2.5)

**Verdict: PASS — no legacy R-carry-forward touched.**

---

## CI Re-verification at HEAD

Run `gh pr checks 41` at HEAD `77741c4`:
- **39 PASS / 1 SKIPPED / 0 FAIL**
- Skipped check: `/sync-agency Dry-Run (v2.0.3)` (one of two duplicate runs — release-only workflow)
- Notable PASS: Skill Depth Check, Skill Format Check, Registry Cardinality Check, Lock File Zero-SHA Rejection, Markdown Lint, Link Check Internal+External, Verbatim Attribution Rule Check (ADR-024), THIRD-PARTY-NOTICES.md Check, ShellCheck

**Verdict: PASS.** CI is fully green.

---

## Classification cross-check (V10-S2 protocol, Phase 6)

Independent classification verification at Phase 6:
- **Auth/RLS surface change?** NO
- **Payment surface?** NO
- **Permissions/scope_allow change?** NO — @security scope_allow=[] preserved
- **Schema/migration?** NO — ADR-028 stays PROPOSED, no lock-schema change
- **External-API or new outbound network?** NO
- **File-upload surface?** NO
- **Dependency additions?** NO (zero new actions/packages/tools)
- **Logging surface?** NO
- **UI/CSS surface?** NO
- **NEW configuration with security-relevant semantics?** YES — `selection-presets.md` is now a routing-control file; `skills/` is the install-source pool. Both gated by PR review + MF-1/MF-2 CI vocab gates.
- **NEW user-controlled free-text input that flows into install decisions?** YES — Q1 goal text feeds F3 routing; mitigated by C-v2.4-6 (keyword-only, no LLM subcall) and AC-F3-2 (user confirmation).

**Classification CONFIRMED at Phase 6: SECURITY-SENSITIVE.** Full Phase 6 audit completed as required. Combined-path remains NOT eligible.

---

## Phase 7 Handoff

- **Verdict: PASS** — Phase 7 final approval is unblocked.
- **Combined-path: NOT eligible** (locked at Phase 0; FULL Phase 6 audit completed).
- **Carry-forwards generated at Phase 6:**
  - **CF-v2.4-G (NEW):** MF-1/MF-2 grep-c bypass hardening (`set -o pipefail` or explicit empty-pipeline assertion). Bundle with CF-v2.4-B (W-1 MF-2 col7 fragility) at v2.5 in a single hardening commit. INFO-level — no v2.4 blocker.
- **Pre-existing carry-forwards re-confirmed deferred:**
  - CF-v2.4-A: ADR-028 implementation (v2.5)
  - CF-v2.4-B: First external skill import + W-1 MF-2 col7 header-name lookup refactor (v2.5)
  - CF-v2.4-C: selection-presets token-vocab CI gate — RESOLVED in v2.4 as MF-1
  - CF-v2.4-D: selection-preset PR contribution workflow (v2.5+)
  - CF-v2.4-E: LLM-based goal matching (backlog, NOT next cycle)
  - CF-v2.4-F: local markdownlint pre-commit (v2.5)
- **Phase 5 INFO carryovers** (verifier phrasing gaps from QA report) — non-blocking; recommend retro note for verifier-phrasing reconciliation.

---

## Approval line

**PASS** — 0 CRITICAL, 0 WARNING, 1 INFO. v2.4 design is implemented as bound; all 6 Phase 2 audit handoff items re-verified PASS at HEAD `77741c4`; all 8 preservation constraints byte-unchanged; OWASP Web + LLM Top 10 FULL pass; CI 39/0; combined-path NOT eligible reaffirmed. Phase 7 unblocked.

— @security
