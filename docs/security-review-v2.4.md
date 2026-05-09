# Security Review — v2.4 Dynamic Workspace Architect (Phase 2 FULL)

## Phase: 2 (full mode)
## Date: 2026-05-09T00:30:00Z
## Status: APPROVE-WITH-WARNINGS — 0 CRITICAL · 2 WARNING · 3 INFO
## Classification: SECURITY-SENSITIVE (independently confirmed at Phase 2)
## Combined-path: NOT eligible (confirmed)
## Reviewed at: docs/architecture.md HEAD (Phase 1 design + Phase 1 Round 1 amendments folded), 4675879 base
## Cycle: v2.4 — Dynamic Workspace Architect

---

## Verdict

**APPROVE-WITH-WARNINGS.** v2.4 is a structural pivot that converts the wizard from a 7-preset selector into a dynamic skill-bundle composer. Despite the surface expansion, every NEW data flow is either (a) bounded to in-tree-only files governed by PR review, or (b) tokenized through deterministic keyword-matching with no LLM sub-call, no network call, no shell-eval surface. All five Phase 1 deliberation watch items (W1–W5) resolve to either RESOLVED-NO-FINDING or WARNING-class hardening — none escalate to CRITICAL. The two WARNINGs (S1, S2) are CI-vocabulary-gate hardening that can be folded into Phase 4 by amending the existing `skill-depth-check` job amendment (C-v2.4-9), with no new file or new CI job required.

Phase 4 is authorized to proceed once the user accepts the WARNINGs at `/gate`, with the MUST-FIX list below bound into Phase 4.

---

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING  | 2     | configuration | `selection-presets.md` token-vocabulary CI gate not bound — `match_signals` and `skill_bundle` lines accept free-form text via PR; without a regex assertion, a malicious PR could insert shell-metacharacters or non-ASCII tokens that change F3 routing semantics. (W4 disposition.) |
| S2 | WARNING  | 2     | configuration | `curated-skills-registry.md` `description` and `goal_tags` fields enter F3 Path C scoring, but their token vocabulary is unconstrained at CI. The F3 algorithm's `[^a-z0-9-]+` split protects the wizard from injection at scoring time, but the registry has no contributor-facing vocabulary CI assertion comparable to S1's selection-presets gate. (W2 disposition.) |
| S3 | INFO     | 2     | configuration | F3 STOPWORDS list not enumerated in v2.4 architecture; only the WIZARD.md §Phase 1 Role-Generation Rule 64-token STOPWORDS list exists (governs ADR-030 role generation, not F3 goal-tokenization). The architecture should bind F3 to reuse the same 64-token list to avoid maintaining two divergent stopword vocabularies. (W1 disposition.) |
| S4 | INFO     | 2     | ui            | F5 attribution-injection check positioning is asserted in §"Security review handoff" (line 5410) but the F5 design-note prose at line 5348 mentions the check as a general applicability statement, not as an explicit ordered step "BEFORE write". Preserved-but-untested in v2.4 (zero non-builtin slugs). Add an explicit ordered step in WIZARD.md F5 prose to make the v2.5 first-external-import cycle safer. (W5 disposition.) |
| S5 | INFO     | 2     | configuration | F4 add-skill universe is bound to `skills/` pool by C-v2.4-7 prose, but the @qa verifier only greps for the affirmative phrase. A defensive "F4 MUST NOT contain `https?://`" grep is already in C-v2.4-7. Recommend extending the same negative-grep pattern to the per-skill role-generation step in F4 to ensure no URL slips into the displayed role line. |

### CRITICAL
(none)

### WARNING
- [ ] **S1 — selection-presets.md token-vocabulary CI gate (W4 disposition).** `selection-presets.md` `match_signals` and `skill_bundle` are the load-bearing data structures for F3 routing. C-v2.4-1 binds the format (lowercase, comma-separated, fenced-code-block), but no CI assertion enforces the vocabulary at PR-time. A malicious PR (or accidental copy-paste) could insert `;` `$` backticks `&` non-ASCII characters or whitespace patterns that change parser semantics. **Concrete CI patch text (bind into C-v2.4-9 amendment, not a new job):** add to the existing `skill-depth-check` job, after the existing `EXAMPLES` loop:
  ```bash
  # selection-presets.md vocabulary gate (S1 WARNING from v2.4 Phase 2)
  if [ -f selection-presets.md ]; then
    BAD=$(awk '/^```preset$/,/^```$/' selection-presets.md \
      | grep -E '^(match_signals|skill_bundle): ' \
      | grep -cE '[^a-z0-9, :_-]')
    if [ "$BAD" -gt 0 ]; then
      echo "::error::selection-presets.md vocabulary violation: ${BAD} line(s) contain characters outside [a-z0-9, :_-]"
      exit 1
    fi
  fi
  ```
  (Note: the token character class is `[a-z0-9, :_-]` — colon and space are required for the `key: value` line shape; underscore is permitted for slug variants.) **Disposition:** add to C-v2.4-9 quality.yml amendment scope (or as a separate sub-bullet under C-v2.4-9 if @architect prefers; functionally identical). MUST-FIX at Phase 4.
- [ ] **S2 — `curated-skills-registry.md` description+goal_tags vocabulary CI gate (W2 disposition).** Path C of F3 scores `goal_tags` AND `description` from the registry. Today the registry has 22 rows of human-prose `description` text containing punctuation, capital letters, parenthetical clauses — verified by direct grep showing 5 rows contain characters outside `[a-z0-9, -]`. The F3 tokenizer (`split(/[^a-z0-9-]+/)`) makes this safe at scoring time because punctuation is an explicit token-boundary, but the registry has no contributor-facing CI assertion comparable to S1's selection-presets gate. **Disposition:** the F3 tokenizer's defensive split makes this **NOT a runtime injection vector** in v2.4. The WARNING is for v2.5+ when the contributor surface widens (external imports add new registry rows from forked repos). Bind a CI assertion now to lock the contributor contract: `description` MAY contain prose; `goal_tags` MUST conform to `[a-z0-9, -]`. Concrete patch:
  ```bash
  # curated-skills-registry.md goal_tags vocabulary gate (S2 WARNING from v2.4 Phase 2)
  BAD=$(awk -F'|' 'NF>=8 && $2 ~ /^ [a-z]/ {gsub(/^ +| +$/,"",$8); print $8}' curated-skills-registry.md \
    | grep -cE '[^a-z0-9, -]')
  if [ "$BAD" -gt 0 ]; then
    echo "::error::curated-skills-registry.md goal_tags vocabulary violation in ${BAD} row(s)"
    exit 1
  fi
  ```
  (The `description` field is intentionally NOT vocabulary-gated — prose text is permitted there.) **Disposition:** MUST-FIX at Phase 4 alongside S1. Bundle into C-v2.4-9 amendment scope.

### INFO
- **S3 — F3 STOPWORDS list reuse (W1 disposition).** The Phase 1 architecture references `STOPWORDS` in the F3 algorithm prose (line 4957) without enumerating the list. WIZARD.md §"Phase 1 — Role-Generation Rule" already specifies a 64-token STOPWORDS list (lines 222–230) for ADR-030 role generation. Recommend the architecture bind F3 to **reuse the same 64-token list** rather than introducing a divergent list. **Why INFO and not WARNING:** the existing 64-token list is sufficient for English-prose goal descriptions; a divergent F3 list would only cause maintenance drift, not a runtime vulnerability. Phase 4 disposition: @architect adds a 1-sentence binding clarification to F3 prose ("F3 reuses the WIZARD.md §Phase 1 STOPWORDS list verbatim") — OR @dev emits the cross-reference inline in WIZARD.md F3 prose at implementation time. Either path resolves the ambiguity.
- **S4 — F5 attribution-injection ordering preservation (W5 disposition).** The F5 design-note at architecture.md L5348 mentions the ADR-024 check as an applicability statement but does not explicitly mark it as the FIRST step inside the per-slug install loop. Architecture's §"Security review handoff" (L5410) asserts the BEFORE-write ordering, but that section is review-handoff prose, not the binding F5 contract. **Why INFO and not WARNING for v2.4:** all 22 registry rows are `source_url=builtin`, so the attribution block does NOT fire on any v2.4 install. The runtime contract is preserved-but-untested. **However, bind for v2.5 readiness.** Phase 4 disposition: WIZARD.md F5 prose MUST emit the attribution-check step as a numbered sub-step of Step 4 (e.g., "for each slug: (1) compute source_url; (2) IF source_url != "builtin" THEN inject ADR-024 6-field block; (3) write file; (4) emit confirmation"). C-v2.4-10's grep `grep -c 'ADR-024\|attribution block' WIZARD.md ≥ 2` covers presence; the explicit numbered ordering is what makes v2.5's first-external-import safe. Preserve as a v2.4.x or v2.5 hardening item if not folded into v2.4 Phase 4.
- **S5 — F4 URL-grep extension (defense-in-depth).** C-v2.4-7 binds F4 to the `skills/` pool and verifies via `grep -A30 ... | grep -cE 'https?://' = 0`. Recommend extending the same negative-grep to the role-generation step (ADR-030) so that no URL leaks into a displayed role line. Low-likelihood vector (registry rows are vetted), but trivial to add.

### Per-watch-item resolution (W1–W5 from Phase 1 Round 1)

| Watch item | Surface | Disposition |
|------------|---------|-------------|
| **W1 STOPWORDS list unspecified** | F3 algorithm prose | **INFO (S3)** — reuse the existing WIZARD.md §Phase 1 64-token list; either @architect binds, or @dev cross-references at implementation. No new list needed. |
| **W2 registry description+goal_tags token vocabulary** | F3 Path C scoring | **WARNING (S2)** — F3's split-on-`[^a-z0-9-]+` tokenizer makes prose `description` safe at scoring time, but goal_tags should be vocabulary-gated at CI for contributor contract clarity. Patch text given. MUST-FIX Phase 4. |
| **W3 grep slug-fix consumers** | `email-drafter` → `email-drafting` rename | **RESOLVED-NO-FINDING.** `grep -rn 'email-drafter' /home/user/claude-cowork-config --exclude-dir=.git --include='*.md' --include='*.json' --include='*.txt' --include='*.yml'` returns hits in: (a) `curated-skills-registry.md:69` (the slug being fixed — covered by C-v2.4-12), (b) `docs/architecture.md` lines 5093/5101/5106/5116/5168/5172/5201/5359/5451 (all are design-of-the-fix discussion in the v2.4 architecture section), (c) `docs/spec.md` lines 2631/3785/4142 (also design-of-the-fix discussion in the v2.4 spec section). **NO references in scripts/, .github/workflows/, WIZARD.md, CLAUDE.md, examples/, .cowork-allowlist.json, cowork.lock.json, or any other consumer code.** C-v2.4-12 (single-slug-edit verifier) is sufficient. |
| **W4 selection-presets.md token-vocabulary CI gate severity** | F3 routing input | **WARNING (S1)** — confirmed WARNING-class as flagged at deliberation. Concrete CI patch text supplied; bundle into C-v2.4-9. MUST-FIX Phase 4. |
| **W5 F5 attribution-injection check positioning** | ADR-024 contract preservation | **INFO (S4)** — preserved-but-untested in v2.4 (all 22 registry rows are `source_url=builtin`). The architecture asserts BEFORE-write ordering in review-handoff prose but the F5 design-note doesn't bind it as numbered step ordering. Bind in v2.4 Phase 4 OR carry to v2.5 first-external-import readiness. NOT a v2.4 CRITICAL because no live invocation. |

---

## OWASP Web Top 10 — FULL pass

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth surface, no RLS, no IDOR risk. Markdown-only repo. v2.4 introduces no auth/permission/role surface. |
| A02 Cryptographic Failures | N/A | No new crypto in v2.4. Lock file `cowork.lock.json` BYTE-UNCHANGED per C-v2.4-2; SHA-pinned upstream chain (ADR-020 v2.0) preserved. ADR-028 `content_sha256` PROPOSED stays untouched. |
| A03 Injection | PASS | F3 algorithm is keyword-set-intersection over already-tokenized lists. Tokenizer is `lowercase + split on [^a-z0-9-]+` (data-only, no eval, no regex compiled from input, no shell interpolation). F5 install is `cp` over slug-keyed paths — slugs come from confirmed-bundle (data set), never from raw user goal text. Path arguments are bash-glob (`for f in skills/*/SKILL.md`) per the architecture's CI loop pattern, not `$(...)` substitution of user data. C-v2.4-9 cmp loop uses fixed-string `${preset}` and `${slug}` from `ENFORCED_EXAMPLES` and parsed `skill_bundle` — both come from in-tree content under PR review trust boundary. **No new injection surface.** |
| A04 Insecure Design | PASS | The 3-path router (A/B/C) is bounded by deterministic keyword set-intersection; F4 is bounded by the in-tree pool; F5 is bounded by the confirmed bundle. Every routing decision requires user confirmation before install (per AC-F3-2). No silent escalation, no implicit installs. C-v2.4-6 binds the no-LLM-subcall constraint explicitly. The `selection-presets.md` file becomes a security-relevant config (correctly identified by @architect at L5407), gated by PR review + S1 CI patch (WARNING). |
| A05 Security Misconfiguration | PASS-WITH-WARNINGS | S1 + S2 are CI-vocabulary-gate hardening (WARNING). C-v2.4-9 already amends `skill-depth-check`; bundling S1 and S2 into the same job amendment costs ~10 lines of bash and adds zero new CI surface. The CI loop in A1/A2 of Round 1 amendments uses bash glob + `for preset in $ENFORCED_EXAMPLES; do` — no `eval`, no `$(...)` of user data. |
| A06 Vulnerable & Outdated Components | PASS | Zero new dependencies. No new actions, no new npm/pip packages, no new shell tools beyond bash builtins + coreutils + jq + cmp + awk + grep + find (all already used). `cmp -s` is coreutils. |
| A07 Identification & Authentication | N/A | No auth surface. |
| A08 Software & Data Integrity | PASS | `cowork.lock.json` BYTE-UNCHANGED (C-v2.4-2 + verifier). SCAN_PATTERNS at sync-agency.yml L143 + L220 BYTE-UNCHANGED (verified at HEAD 4675879, 8 patterns intact, no v2.4 deny-list/allow-list change touches sync-agency.yml). `.cowork-allowlist.json` 10-entry seed + blocked_patterns intact. ADR-024 attribution rule preserved verbatim. ADR-028 PROPOSED unchanged. v2.4's `cmp` byte-mirror invariant (C-v2.4-3) ADDS a new integrity-check surface: any drift between `skills/<slug>/SKILL.md` and `examples/<preset>/.claude/skills/<slug>/SKILL.md` becomes a CI failure — this is integrity-positive. |
| A09 Security Logging & Monitoring | N/A | No logging surface. Static markdown repo, no runtime telemetry. |
| A10 Server-Side Request Forgery | N/A | No outbound requests added. F3/F4/F5 do not introduce any URL fetch. C-v2.4-6 explicitly bans `fetch.*url\|spawn.*agent` in F3. C-v2.4-7 explicitly bans `https?://` in F4 install scope. |

---

## OWASP LLM Top 10 — FULL pass (SECURITY-SENSITIVE classification)

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 Prompt Injection | PASS | The 5-pattern LLM01 scan in architecture.md L5085–5095 names the v2.4 surfaces (goal-text-as-instructions, selection-preset tampering, F4 surface expansion, Path C abuse, slug confusion). Each is mitigated: (1) goal text is DATA-only at F3 (`grep -ciE 'sub-call\|fetch.*url' WIZARD.md = 0` per C-v2.4-6); (2) selection-presets.md is in-tree under PR review (S1 CI gate further constrains); (3) F4 universe = `skills/` pool only (C-v2.4-7); (4) Path C uses keyword-match against registry, not LLM judgement; (5) slug confusion resolved by C-v2.4-12 single-slug-edit. The v2.0 8-pattern SCAN_PATTERNS chokepoint at sync-agency.yml L143–152/220 remains BYTE-UNCHANGED — load-bearing for v2.5 first-external-import. |
| LLM02 Insecure Output Handling | PASS | F5 emits `cp` confirmation lines and a per-skill "Installed [name]." string. Skill names come from confirmed bundle (data set), not raw goal text. `skills-as-prompts.md` generation reads each installed SKILL.md `## Instructions` section and concatenates with H2 headers — content shape identical to v2.3.x per-preset file, no new escape/encoding surface. |
| LLM03 Training Data Poisoning | N/A | No model training in scope. |
| LLM04 Model DoS | PASS | F3 keyword-match is bounded by finite `match_signals` set (≤8 tokens × 7 presets = ≤56 comparisons) and finite registry rows (22) on Path C. No regex backtracking surface (no regex applied to user-controlled input). No recursive structure. Catastrophic-backtracking inputs cannot DoS the wizard. |
| LLM05 Supply Chain | PASS | No new external imports in v2.4 (CF-v2.4-B deferred to v2.5). All 20 pool slugs are `source_url=builtin`. SHA-pinned upstream chain unchanged. v2.5 first-external-import will require @compliance Phase 2/6 per pipeline-policy. |
| LLM06 Sensitive Information Disclosure | PASS | spend-awareness skill (the data-as-data canonical example, ADR-019 v1.3.2) preserved byte-identical. v2.4 does NOT modify any SKILL.md content — pool is populated via `cp` from existing `examples/<preset>/.claude/skills/<skill>/SKILL.md` which were already vetted at v2.3.1. Goal-text in Q1 is held in the wizard session, not persisted, not transmitted. F5 install copies vetted files only. |
| LLM07 Insecure Plugin Design | PASS | F4 add-skill universe BOUNDED to `skills/` pool by C-v2.4-7. No URL paste, no registry `source_url` direct fetch, no fallback-to-external. The pool itself is the trust boundary. F5 install path uses slug-keyed lookup `skills/<slug>/SKILL.md` — slug comes from confirmed-bundle (data set), never path-component-injection from goal text. |
| LLM08 Excessive Agency | PASS | The 3-path router is a SUGGESTION engine — every path requires user confirmation before install (AC-F3-2: `Sound right?` / `adjust or build from scratch` / `Continue?`). No silent install, no auto-add, no agentic loop. F4 customisation pause is the agency boundary: user can drop, keep, swap, or stop. C-v2.4-6 binds keyword-match-only — no agentic LLM sub-call to "decide" beyond the user-confirmation step. |
| LLM09 Overreliance | N/A | Wizard is interview-driven; user is decision-maker at every routing/install gate. No automated decision pipeline. |
| LLM10 Model Theft | N/A | Static markdown repo. |

---

## Phase 1/2 Preservation Constraints (re-verified at HEAD 4675879)

| Constraint | Result |
|------------|--------|
| SCAN_PATTERNS at `.github/workflows/sync-agency.yml` L143 + L220 BYTE-UNCHANGED | **PASS** — `grep -n 'SCAN_PATTERNS' .github/workflows/sync-agency.yml` returns L143 (declaration) and L220 (iteration); 8 patterns visually intact and identical to v2.0 ship state. v2.4 deny-list (architecture.md L5227) explicitly forbids sync-agency.yml modification. |
| `.cowork-allowlist.json` 10-entry seed + blocked_patterns + blocked_files intact | **PASS** — file present at HEAD with `$schema_version: "1.0"`, `allowed_categories` (10), `blocked_files` (1 — nexus-strategy.md permanent), `blocked_patterns` (>1 — nexus-strategy + orchestrator variants enumerated). Not in v2.4 allow-list — BYTE-UNCHANGED implicit. |
| `presets/` symlink absent | **PASS** — no `presets/` directory at HEAD; only `examples/` and the new `skills/` (v2.4) and `selection-presets.md` (v2.4). |
| `CLAUDE.md` ≤ 400 words preserved (C-v2.4-11 binds = 397) | **PASS** — `wc -w CLAUDE.md` = 397 (verified prior cycles); v2.4 deny-list item 2 forbids CLAUDE.md modification. |
| `cowork.lock.json` BYTE-UNCHANGED (C-v2.4-2) | **PASS-AT-DESIGN** — deny-list item 1 + 16 forbids modification; verifier `cmp cowork.lock.json <(git show main:cowork.lock.json)` exits 0 will run at Phase 5. v2.3.1 verified 113 entries upstream-only (no `examples/` paths). v2.4 introduces no new lock-relevant path — pool consolidation is in-tree, lock tracks upstream agency-agents only. |
| ADR-024 attribution rule preserved verbatim | **PASS-WITH-INFO (S4)** — architecture's L5151–5153 explicitly states "ADR-024 (v2.4): NO change. Attribution-injection contract preserved." The contract is preserved as written; ordering binding clarification is the S4 INFO recommendation for v2.5 readiness. |
| ADR-028 PROPOSED unchanged | **PASS** — C-v2.4-2 binds `cmp` on lock file + `git diff main -- docs/architecture.md \| grep '^[+-].*ADR-028' = 0` (modulo the index-table row append). |

---

## Phase 4 MUST-FIX list (binding for @dev)

These are folded into Phase 4 as additional ACs under the existing C-v2.4-9 quality.yml amendment scope. No new constraint number issued (they extend C-v2.4-9). If @architect prefers, they may be promoted to C-v2.4-16 + C-v2.4-17 — equivalent functionally.

1. **MF-1 (S1):** add the `selection-presets.md` vocabulary gate (CI patch text in S1 above) to the `skill-depth-check` job in `.github/workflows/quality.yml`. Verifier: `grep -c 'selection-presets.md vocabulary' .github/workflows/quality.yml ≥ 1` AND a fault-injection PR with a `;` character in any `match_signals:` line MUST CI-fail at this gate.
2. **MF-2 (S2):** add the `curated-skills-registry.md` `goal_tags` vocabulary gate (CI patch text in S2 above) to the same job. Verifier: `grep -c 'curated-skills-registry.md goal_tags vocabulary' .github/workflows/quality.yml ≥ 1` AND a fault-injection PR with a `$` character in any `goal_tags` cell MUST CI-fail at this gate.

These two MUST-FIX items DO NOT block Phase 3 `/gate` — they are folded into Phase 4 as additional CI requirements. The user may APPROVE at `/gate` with awareness that S1 + S2 will land in Phase 4 alongside the C-v2.4-9 quality.yml amendment.

---

## Phase 4 SHOULD-FIX list (recommended; @dev judgment)

3. **SF-1 (S3):** add a 1-sentence binding clarification to F3 algorithm prose stating "F3 STOPWORDS reuses the WIZARD.md §Phase 1 Role-Generation Rule 64-token list verbatim." Either @architect amends architecture.md prose, or @dev emits the cross-reference inline in WIZARD.md F3 prose at implementation. Verifier: `grep -c 'STOPWORDS' WIZARD.md ≥ 1 in F3 section` AND `grep -c 'Phase 1.*Role-Generation\|same 64-token\|reuses.*STOPWORDS' WIZARD.md ≥ 1`.
4. **SF-2 (S4):** WIZARD.md F5 prose MUST emit the ADR-024 attribution-check step as a numbered sub-step BEFORE the file write. Suggested numbered template (per slug):
   ```
   For each <slug> in confirmed bundle:
   1. Look up source_url in curated-skills-registry.md.
   2. IF source_url != "builtin" THEN inject ADR-024 6-field block into the SKILL.md content buffer.
   3. Write skills/<slug>/SKILL.md to <user-workspace>/.claude/skills/<slug>/SKILL.md.
   4. Emit "Installed [Skill Name]."
   ```
   Verifier: `grep -A30 '## Step 4\|^### Step 4\|F5\|Dynamic install' WIZARD.md \| grep -c 'BEFORE\|before write\|step 1\|step 2\|step 3' ≥ 1`. Closes W5 for v2.5 first-external-import readiness.
5. **SF-3 (S5):** extend the C-v2.4-7 negative-grep pattern to the F4 role-generation step. Verifier: F4 role-display prose contains no `https?://` (already covered by existing C-v2.4-7 grep; no new check needed if F4 section grep range covers role display).

---

## Phase 6 Audit handoff items

Phase 6 audit at `release/v2.4.0` HEAD MUST verify (re-run all four):

(a) **MF-1 + MF-2 CI-gate verification at HEAD** — fault-injection grep on the actual amended quality.yml shows both vocabulary gates present with the correct character classes; the `git log` for commit 5 (CI scope expansion) shows the patches landed.
(b) **SCAN_PATTERNS chokepoint preservation** — `grep -n 'SCAN_PATTERNS' .github/workflows/sync-agency.yml` returns L143 + L220 with byte-identical 8-pattern body (no v2.4 commit touched sync-agency.yml).
(c) **Slug-fix consumer search at HEAD** — re-run `grep -rn 'email-drafter' /home/user/claude-cowork-config --exclude-dir=.git` returns hits ONLY in: docs/architecture.md (design-discussion sections), docs/spec.md (design-discussion sections), CHANGELOG.md (release-note mention if present), AND ZERO hits in scripts/, .github/workflows/, WIZARD.md, CLAUDE.md, .cowork-allowlist.json, cowork.lock.json, examples/. The registry row at curated-skills-registry.md:69 must be `email-drafting` (not `email-drafter`).
(d) **WIZARD.md F3/F4/F5 prose grep** — confirm zero `eval`, `$(`, backticks (other than markdown-fence triple-backticks), `bash -c`, or `https?://` patterns inside F3/F4/F5 sections (architecture's @security review handoff item 5).
(e) **F5 attribution-ordering grep (S4 follow-through)** — if SF-2 was folded into Phase 4: confirm WIZARD.md F5 emits the attribution-check step as numbered sub-step BEFORE write. If SF-2 was deferred: log as v2.5 entry-condition.
(f) **C-v2.4-3 cmp byte-mirror sample** — spot-check 5 random `<slug>`/`<preset>` pairs at HEAD: `cmp -s skills/<slug>/SKILL.md examples/<preset>/.claude/skills/<slug>/SKILL.md` exits 0 each time. (CI gate covers the full set; the spot-check verifies the gate is actually wired and not silently skipping.)

**Combined-path Phase 5+6+7 NOT eligible** — confirmed. SECURITY-SENSITIVE classification triggers full Phase 6 audit run after Phase 5.

---

## Classification cross-check (V10-S2 protocol)

Independent verification of SECURITY-SENSITIVE classification:
- **Auth/RLS surface change?** NO — no auth surface in repo.
- **Payment surface?** NO.
- **Permissions/scope_allow change?** NO — no agent scope changes; @security scope_allow=[] preserved.
- **Schema/migration?** NO — no DB. ADR-028 stays PROPOSED, no lock-schema change.
- **External-API or new outbound network?** NO — F3/F4/F5 markdown-runtime only.
- **File-upload surface?** NO.
- **Dependency additions?** NO — zero new packages/actions/tools.
- **Logging surface?** NO — no telemetry.
- **UI/CSS surface?** NO — markdown wizard.
- **NEW configuration with security-relevant semantics?** YES — `selection-presets.md` becomes a routing-control file; `skills/` becomes the install-source pool. Both are in-tree under PR review. → confirms **SECURITY-SENSITIVE classification holds.**
- **NEW user-controlled free-text input that flows into install decisions?** YES — Q1 goal text feeds F3 routing. Mitigated by C-v2.4-6 (keyword-only, no LLM subcall) and AC-F3-2 (user confirmation required at every routing decision). → still SECURITY-SENSITIVE; mitigation does not downgrade classification.

**Classification CONFIRMED: SECURITY-SENSITIVE.** Combined-path NOT eligible. Proceed to Phase 3 `/gate` with the WARNING+INFO findings as inputs. Phase 4 binds MF-1 + MF-2; SF-1/SF-2/SF-3 at @architect+@dev judgment.

---

## Approval line

**APPROVE-WITH-WARNINGS** — design is implementable as-bound; 2 WARNINGs (S1 selection-presets vocab gate, S2 registry goal_tags vocab gate) are CI-hardening MUST-FIX folded into existing C-v2.4-9 amendment scope; 3 INFO items (S3 STOPWORDS reuse, S4 F5 attribution ordering, S5 F4 URL-grep) are SHOULD-FIX hygiene that can land in Phase 4 or carry to v2.5; combined-path Phase 5+6+7 NOT eligible per SECURITY-SENSITIVE classification (independently re-confirmed).

— @security
