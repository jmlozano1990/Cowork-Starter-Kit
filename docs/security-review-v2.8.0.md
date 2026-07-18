# Security Review — v2.8.0 "Showcase"

## Phase: 2
## Date: 2026-07-18T09:06:44Z
## Status: PASS WITH WARNINGS
## Classification: CONFIRMED STANDARD (combined-path design-stage spot-review) — no escalation, no Guard Change Summary required

Design commit reviewed: `90fdca1` on `release/v2.8.0` (from `main` `e24318c`).
Scope: design-stage spot-review of the WS5 move manifest + three CI-workflow diffs
(`quality.yml`, `sync-agency.yml`, `release-assets.yml`) + the WS3 SVG spec — per the
STANDARD combined-path elevation in `docs/architecture.md` §3.1/§3.3. NOT a full-repo OWASP sweep.
The actual file edits are @dev's Phase 4 work; this review dispositions the DESIGN and binds
Phase 4 MUST-FIX / MUST-VERIFY items.

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING  | 2 | configuration | `.github/PULL_REQUEST_TEMPLATE.md:17` refs `docs/security/upstream-content-scan-rules.md` — OMITTED from the design's §2c cross-check surface list; becomes a stale/dangling pointer post-move |
| S2 | WARNING  | 2 | configuration | `curated-skills-registry.md:84` & `:86` ref `docs/skills-roadmap.md` (×2) in a PUBLIC (archive-shipped) file — OMITTED from cross-check; becomes a dangling pointer to an internal path in shipped copy |
| S3 | WARNING  | 2 | configuration | This new `docs/security-review-v2.8.0.md` is NOT export-ignore'd at root and is absent from the §2b move manifest (computed before it existed) — a fresh D-9 leak instance unless Phase 4 WS5 moves it to `docs/internal/security/` |
| S4 | WARNING  | 2 | configuration | AC-WS5-5 verify `grep -c "docs/internal" release-assets.yml >= 1` is a check-that-barely-fails — passes even if the token is only a comment, not the DROP_PATHS[] backstop; leak-gate could be green-but-unwired |
| S5 | WARNING  | 2 | ui | WS3 SVG spec (§3.6) forbids JS/external-asset in prose but does NOT explicitly forbid `<foreignObject>`, `on*=` event handlers, or external `href`/`xlink:href`; relies on GitHub `<img>` sanitization without binding direct-open inertness |
| S6 | INFO     | 2 | configuration | ACTIVE pre-existing leak CONFIRMED (validates WS5): `docs/qa-report-v2.7.2.md` + `docs/security-review-v2.7.2.md` currently ship in the public `git archive` (missing DROP lines). WS5's collapse closes this |
| S7 | INFO     | 2 | configuration | Stale `.gitattributes:62` entry `docs/security-review-v2.6.1.md` references a non-existent file — harmless, removed by the §2d collapse |
| S8 | INFO     | 2 | configuration | Post-move cross-check should be REPO-WIDE (exclude only `docs/` + `CHANGELOG.md`), not the design's fixed surface list, which demonstrably missed 2 surfaces (S1/S2) |
| S9 | INFO     | 2 | dependency | quality.yml drift check is a new JOB (not merely a step) but stays inside the existing workflow (spec "no new workflow file" honored); must reuse pinned `actions/checkout@11bd719…v4.2.2`; no permissions/secret/network |

### CRITICAL
_(none)_

### WARNING
- [ ] **S1 — Cross-check omission: `.github/PULL_REQUEST_TEMPLATE.md:17`.** References `docs/security/upstream-content-scan-rules.md`. The design's §2c broadened cross-check (and AC-WS5-2's EARS-revised verify) scope to README/CONTRIBUTING/SETUP-CHECKLIST/WIZARD/CLAUDE.md/`.claude/skills/`/the 3 workflows — this template is NOT in that list. Post-move it is a dangling reference (contributor-facing on GitHub PR creation; `.github/` is archive-dropped so not in the ZIP, but live on GitHub). **Phase 4 MUST-FIX:** rewrite to `docs/internal/security/upstream-content-scan-rules.md` in the SAME commit as the move.
- [ ] **S2 — Cross-check omission: `curated-skills-registry.md:84` & `:86`.** Both reference `docs/skills-roadmap.md` (`§Section 1`). This file is PUBLIC (ships in the release archive — confirmed `unspecified`/present). Not in the design's cross-check surface list. Post-move both become dangling pointers to `docs/internal/process/skills-roadmap.md` in a shipped public artifact. **Phase 4 MUST-FIX:** rewrite both to `docs/internal/process/skills-roadmap.md` in the same commit.
- [ ] **S3 — This review file self-tests move exhaustiveness.** `docs/security-review-v2.8.0.md` (this artifact) is created at `docs/` root, is NOT covered by any current `.gitattributes` DROP line, and is absent from the §2b manifest (which was computed against the pre-existing 39-file tree). If Phase 4 collapses `.gitattributes` to `docs/internal/ export-ignore` and does NOT move this file into `docs/internal/security/`, it becomes the next D-9 leak — a Content-Exclusion-Policy-class security-review file shipped public. **Phase 4 MUST-FIX:** include `docs/security-review-v2.8.0.md` in the WS5 `git mv` set → `docs/internal/security/security-review-v2.8.0.md`.
- [ ] **S4 — AC-WS5-5 is a weak check.** `grep -c "docs/internal" .github/workflows/release-assets.yml >= 1` would pass even if `docs/internal/` appears only in a comment. The archive-leak backstop is the `DROP_PATHS[]` negative-assertion array (release-assets.yml:39-65). **Phase 5 MUST-VERIFY (@qa):** confirm `docs/internal/` is specifically in `DROP_PATHS[]` (prefix-match catches the whole subtree) AND `KEEP_PATHS[]` adds the new public assets (`docs/research/`, `docs/project-audit-v2.6.1.md`, `docs/how-it-works.md`, `docs/faq.md`, `TRUST.md`); and run the authoritative backstop `git archive HEAD | tar -t | grep '^docs/'` post-move → the ONLY `docs/` entries may be the 6 intended-public files, ZERO `docs/internal/**`.
- [ ] **S5 — WS3 SVG inertness under-specified.** §3.6 mandates SMIL/CSS-only + "no JS, no external asset" and notes GitHub does not execute `<script>` when embedded via `![]()`/`<img>`. It does NOT explicitly forbid `<foreignObject>` (embeds arbitrary HTML/script), `on*=` inline event handlers (`onload`/`onclick`), or external `href`/`xlink:href`/`<image href>`/`<use href>` (http/https/`//`/`data:`/`file:`); and it does not bind inertness for the DIRECT-OPEN case (raw URL / local file), where the browser renders the SVG as a full document and WOULD execute active content. **Phase 4 MUST-VERIFY:** the delivered SVG must return 0 for `grep -iE '<script|<foreignObject|on[a-z]+=|xlink:href="(https?:|//|data:|file:)|href="(https?:|//|data:|file:)|<image[^>]*href|<use[^>]*href="[^#]' assets/setup-demo.svg` — inert both under GitHub's sanitizer AND on direct open. No real PII in content (already bound).

### INFO
- **S6 — ACTIVE leak confirms WS5's premise.** `git archive HEAD | tar -t | grep '^docs/'` today ships exactly: `docs/architecture.md` (intended public), **`docs/qa-report-v2.7.2.md`**, and **`docs/security-review-v2.7.2.md`**. The latter two are Content-Exclusion-Policy-class internal artifacts leaking into the public release ZIP because the v2.7.2 cycle added them without `.gitattributes` DROP lines — a live D-9 instance. WS5's `docs/internal/` collapse closes this permanently (both are in the §2b move set). Net effect on Content-Exclusion files: MORE restricted, not exposed. OI-SEC-2(b) satisfied.
- **S7 — Stale DROP entry.** `.gitattributes:62 docs/security-review-v2.6.1.md` points at a file not on disk. Harmless (a DROP line for a non-existent path); removed by the §2d collapse. No action beyond the collapse.
- **S8 — Harden the post-move verify.** The design's §2c grep and AC-WS5-2 verify are scoped to a fixed surface list that missed S1/S2. Recommend @qa's Phase 5 cross-check be repo-wide: `git ls-files | grep -vE '^docs/' | grep -v '^CHANGELOG.md$' | xargs grep -nE 'docs/(assumptions|competitive|compliance-review|dev-deliberation|personas|qa-report|retro-template|security-audit|security-review|skills-roadmap|OUTPUT-STRUCTURE|ux-review|security/upstream-content-scan-rules)'` → expect only `docs/internal/**` rewritten paths, 0 pre-move stems.
- **S9 — Drift job hygiene.** §3.4 shows a new *job* `starter-drift-marker-check:` (own `runs-on` + checkout), not merely a step; still inside `quality.yml`, so the spec constraint "no new workflow file" holds. **Phase 4 MUST-VERIFY:** reuse the exact pinned `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2` already in the file (no new/unpinned Action), add NO `permissions:` block, NO `secrets.`, NO network — additive read-only bash/grep only.

---

## Open-Issue Dispositions

### OI-SEC-1 — `quality.yml` planned edits — PASS
- **New drift-marker check:** additive, read-only bash/grep. No new Action (reuses the pinned checkout SHA — see S9), no `permissions:` block, no secret, no network, modifies no existing control. Same shape as the v2.7.2 WS2 STANDARD precedent. Confirmed no new supply-chain surface.
- **Negative control:** §3.4 specifies the check-that-can-fail (inject `Step 1: Name` into one starter → run under `bash -eo pipefail` → confirm non-zero exit + `::error::` naming the file → revert → record in the Phase-4 commit message). Specified. PASS.
- **WS5 path-fix at 908/920:** CONFIRMED both `docs/security/upstream-content-scan-rules.md` reads are functional (`grep -c` at 908 guarding `PATTERN_COUNT`, `grep` while-read feed at 920). The planned fix changes ONLY the path → `docs/internal/security/upstream-content-scan-rules.md`; the grep patterns, the `if [ "$PATTERN_COUNT" -lt 1 ]; then … exit 1` logic, and the while-read body are byte-identical. **MANDATORY same-commit:** BOTH lines updated in the move commit — if either is missed, `PATTERN_COUNT=0 → exit 1 → hard CI fail`.
- **"#28 Fix A" JSONL regression gate:** lines 923-959 share the SAME step (905) as the path-read guard, but the gate itself does NOT read the moved file — it fetches 2 sample files from `raw.githubusercontent.com` and builds the JSONL accumulator. Post-fix, the step reads a valid path (908/920) and the regression gate is unaffected. Confirmed the security-relevant gate still functions post-move.

### OI-SEC-2 — WS5 move manifest — PASS (exhaustive, not sampled) — with S1/S2/S3/S4 conditions
- **(a) Exhaustiveness — independently recomputed.** `git ls-files 'docs/*.md' 'docs/**/*.md'` = 46 tracked docs files. Subtracting the 7 KEEP-at-root files (architecture, project-audit-v2.6.1, research/×2, spec, retro, patterns) yields exactly 39 must-move files. Diffed against the §2b manifest (39): **0 omissions** (no internal file left behind to leak) and **0 phantoms** (no manifest entry pointing at a non-existent path). The manifest is exhaustive, not sampled. `comm -23`/`comm -13` both empty.
- **(a′) export-ignore MECHANISM verified.** `git archive` (the authoritative release mechanism) recursively honors trailing-slash directory drops: `docs/research/`, `docs/security/`, `.github/`, `tests/`, `upstream-contribution/` all show 0 archive entries. So `docs/internal/ export-ignore` WILL drop the entire nested subtree (`docs/internal/security/…`, `…/qa/…`, etc.). NOTE for @qa: `git check-attr export-ignore <nested-file>` returns `unspecified` for directory patterns (a check-attr quirk) — do NOT verify with check-attr; verify with `git archive … | tar -t`.
- **(b) Content-Exclusion-Policy files MORE restricted.** Confirmed via S6 — currently 2 such files leak; post-move 0. All `security-review*`/`security-audit*`/`qa-report*`/`compliance-review*` land under `docs/internal/{security,qa,compliance}/` which is dropped. (No `risk-register*` file exists in this repo.)
- **(c) Inbound-ref completeness — the 9-item list is INCOMPLETE.** My independent repo-wide grep (all tracked files except `docs/` and `CHANGELOG.md`) reproduces the design's 9 enumerated hits AND surfaces 3 more references across 2 surfaces the cross-check scope missed: `.github/PULL_REQUEST_TEMPLATE.md:17` (S1) and `curated-skills-registry.md:84`+`:86` (S2). `release-assets.yml:51-55` hits are covered by §2e; `.gitattributes` hits are the DROP lines being collapsed. See S1/S2/S3 MUST-FIX and S8.
- **release-assets.yml self-consistency:** §2e's plan (DROP individual entries → single `docs/internal/`; KEEP-add research/project-audit/how-it-works/faq/TRUST.md) is coherent and STRONGER than today (prefix-match `^…/docs/internal/` catches the whole subtree). But AC-WS5-5's verify is weak — see S4.

### OI-SEC-3 — `sync-agency.yml` planned edits — PASS
- The 4 planned rewrites are ALL non-functional text: line 8 (header comment), line 141 (inline comment above SCAN_PATTERNS), line 404 (PR-body heredoc reviewer-checklist markdown), line 410 (PR-body heredoc markdown). Confirmed by direct read.
- **Key confirmation:** sync-agency.yml NEVER functionally reads `docs/security/upstream-content-scan-rules.md` — the 8 `SCAN_PATTERNS` are hardcoded verbatim inline (lines 143+). Moving the rules doc has ZERO functional/security effect on the supply-chain workflow; the doc is a documentation pointer only.
- Byte-unchanged (not touched by the path rewrites): `SCAN_PATTERNS[]` (143+), `permissions: read-all` (23), job `contents: write`/`pull-requests: write` (33-35), `concurrency` (25-27), the 24h-soak rule (412), "NEVER auto-merges", the monthly cron. Confirmed.
- Line 418 (`security-review-required` label) is a LABEL string, correctly NOT in the rewrite list (no `docs/` prefix) — no false rewrite that would break PR labeling.

### OI-SEC-4 — WS3 synthetic SVG — PASS WITH WARNING (see S5)
- Intent is correct (SMIL/CSS-only, no JS, no external asset, no host dependency). No SVG asset exists yet — Phase 4 deliverable — so there is nothing to audit for actual content; the constraint must be BOUND. The current spec prose is under-specified against the direct-open threat model. See S5 MUST-VERIFY for the explicit forbidden-element list + grep gate.

### OI-COMP (light) — PASS
- Snyk + PromptArmor are bound as "third-party evidence"/"third-party research" for the kit's existing controls (§3.5 point 4, §3.7 "Third-party evidence"), NOT as the kit's own findings — attribution is correct.
- Denylist (AC-WS2-9): no competitor/tool names in new public copy beyond Snyk, PromptArmor, `agency-agents`/`msitarzewski`; disposition recorded in the Phase-4 commit message. The spec flags `improvement-plan-2026-07-18.md` as INTERNAL (names third-party products) — none may reach public copy.
- **Phase 4 reminder (not a finding):** the Snyk figures (36.8% / ~4,000 skills / 76 malicious / Feb 2026) and the PromptArmor Cowork-exfiltration finding are `[ESTIMATED]` (copied from the internal plan, not independently re-verified). AC-WS2-9 / Risk-3 require a FRESH spot-check of both figures before publish.

---

## OWASP Top 10 Assessment (scoped to this docs-IA + CI-hygiene + demo-asset cycle)
| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth/authorization surface in this cycle |
| A02 Cryptographic Failures | N/A | No crypto/secret material introduced |
| A03 Injection | WATCH → bound | SVG XSS vector (OI-SEC-4/S5) — inertness bound as Phase 4 MUST-VERIFY |
| A04 Insecure Design | PASS | Atomic single-commit move (Edge Case 3); exhaustive manifest; `git mv` revertible |
| A05 Security Misconfiguration | PASS w/ conditions | Primary surface. Export-ignore leak class — manifest exhaustive (0 omissions), but cross-check missed 2 surfaces (S1/S2), this file self-leaks (S3), and the AC-WS5-5 backstop is weak (S4). One ACTIVE leak confirmed (S6), closed by WS5 |
| A06 Vulnerable/Outdated Components | PASS | No new/unpinned Action (drift job reuses pinned checkout SHA, S9); no dependency additions |
| A07 Identification/Auth Failures | N/A | — |
| A08 Software/Data Integrity Failures | PRESERVED | Supply-chain workflow (sync-agency.yml) integrity byte-unchanged: S1 content-scan, 24h soak, no-auto-merge, `vendored-integrity-check` all intact (OI-SEC-3) |
| A09 Logging/Monitoring Failures | N/A | — |
| A10 SSRF | N/A (adjacent) | SVG external-fetch is the adjacent concern — forbidden by S5's MUST-VERIFY |

### LLM Threat Assessment (AI-agent starter kit)
- **LLM01 (Prompt Injection):** the core threat the kit's controls address; WS2 cites PromptArmor's Cowork prompt-injection finding as evidence for EXISTING controls. No new LLM instruction surface introduced this cycle. The SVG (S5) could carry injected active content if it embedded `<foreignObject>`/`<script>` — bound as MUST-VERIFY.
- **LLM06 (Sensitive Information Disclosure):** maps to the docs export-ignore leak class (A05). WS5 net-reduces disclosure (closes the S6 active leak); residual risk is S1/S2/S3 dangling pointers (non-exposing) and S4's weak backstop.
- **LLM02 (Insecure Output Handling):** N/A — no model-output rendering surface added.

---

## Scope-Allow Re-Walk (B2, ADR-127)
**N/A — external-project cycle.** `scope_allow_delta` is a no-op per V44-S5 / ADR-115 §Implications: @dev operates against `/home/user/claude-cowork-config`, not `The-Council/.claude/agents/dev.md`. No Council guard `scope_allow` adjustment applies. The §D file-by-file plan is enforced by the cowork repo's own pre-commit hook (docs/tests allowed pre-Phase-3; implementation files gated on Phase 3 APPROVED) — verified present and functioning.

## Session-Pin Checklist Row (AC-10)
**N/A — no session-pin or env-var-propagation surface** is introduced by v2.8.0 (docs-IA + README + CI-hygiene + demo-asset). Status: PRESERVED (no change to any Council session-isolation mechanism; this is an external-project cycle).

---

## Phase 4 MUST-FIX / MUST-VERIFY (binding @dev / @qa work-order)

**MUST-FIX (Phase 4 @dev, in the SAME atomic WS5 commit as the move):**
1. **[S1]** Rewrite `.github/PULL_REQUEST_TEMPLATE.md:17` → `docs/internal/security/upstream-content-scan-rules.md`.
2. **[S2]** Rewrite `curated-skills-registry.md:84` and `:86` → `docs/internal/process/skills-roadmap.md`.
3. **[S3]** Add `docs/security-review-v2.8.0.md` (this file) to the WS5 `git mv` set → `docs/internal/security/security-review-v2.8.0.md` (else fresh D-9 leak).
4. **[OI-SEC-1]** Update BOTH `quality.yml:908` and `:920` paths → `docs/internal/security/upstream-content-scan-rules.md` in the move commit (either missed = hard CI fail). Grep patterns / `exit 1` logic byte-identical.
5. **[OI-SEC-3]** In `sync-agency.yml`, change ONLY the 4 comment/heredoc paths (lines 8, 141, 404, 410); leave `SCAN_PATTERNS`, `permissions`, `contents:write`/`pull-requests:write`, concurrency, and the 24h-soak rule byte-unchanged.

**MUST-VERIFY (Phase 4 @dev / Phase 5 @qa):**
6. **[S5]** Delivered `assets/setup-demo.svg` returns 0 for the forbidden-element grep (no `<script>`, `<foreignObject>`, `on*=`, external `href`/`xlink:href`/`<image href>`/`<use href>`) — inert under GitHub's sanitizer AND on direct open.
7. **[S4/S8]** @qa post-move verification is REPO-WIDE (exclude only `docs/` + `CHANGELOG.md`) → 0 pre-move stems remain; AND run `git archive HEAD | tar -t | grep '^docs/'` → only the 6 intended-public docs + `TRUST.md` at root, ZERO `docs/internal/**`; AND `docs/internal/` is in `release-assets.yml` `DROP_PATHS[]` (not just a comment), with `KEEP_PATHS[]` extended to the new public assets.
8. **[S9]** quality.yml drift job reuses `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2`; no `permissions:`, no `secrets.`, no network. Negative control recorded in the commit message (OI-SEC-1).
9. **[OI-COMP]** Fresh spot-check of the Snyk + PromptArmor figures before publish; denylist-scan disposition in the Phase-4 commit message.

### Summary
v2.8.0's design is sound and correctly classified **STANDARD** (combined-path) — no auth/schema/secret/permission/guard/supply-chain-control-logic change; no Guard Change Summary required; no escalation. The central WS5 risk (the KEEP-DROP cross-check pattern's textbook 3rd instance) is well-mitigated: the 39-file move manifest is **exhaustive, not sampled** (independently recomputed from `git ls-files` — 0 omissions, 0 phantoms), the export-ignore collapse mechanism is verified sound via `git archive`, and the Content-Exclusion-Policy files end up strictly MORE restricted (the review even confirmed an ACTIVE pre-existing leak of `security-review-v2.7.2.md` + `qa-report-v2.7.2.md` that WS5 closes). The supply-chain workflow (`sync-agency.yml`) is untouched in substance — its scan patterns are inline, not file-read. **Verdict: PASS WITH WARNINGS.** Five WARNING findings, all Phase-4-fixable and none flipping the classification: the design's inbound-reference cross-check is itself not fully exhaustive (it missed `.github/PULL_REQUEST_TEMPLATE.md` and the PUBLIC `curated-skills-registry.md`), this review file self-tests the move's completeness (S3), the AC-WS5-5 leak backstop is a check-that-barely-fails (S4), and the WS3 SVG inertness constraint is under-specified against the direct-open threat model (S5). Proceed to Phase 3 `/gate` with the 9-item MUST-FIX/MUST-VERIFY work-order bound into Phase 4.
