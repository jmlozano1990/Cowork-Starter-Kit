# Security Review — v2.5 v3.0-Gate Prep (Phase 2 FULL)

## Phase: 2 (full mode)
## Date: 2026-05-09T20:30:00Z
## Status: APPROVE-WITH-WARNINGS — 0 CRITICAL · 2 WARNING · 5 INFO
## Classification: SECURITY-SENSITIVE (independently re-confirmed at Phase 2 per V10-S2)
## Combined-path: NOT eligible (locked at Phase 0; FULL audit ran)
## Reviewed at: docs/architecture.md HEAD v2.5 section (Phase 1 + deliberation Round 1 closed)
## Cycle: v2.5 — ADR-028 + tools: frontmatter + first upstream contribution

---

## Verdict

**APPROVE-WITH-WARNINGS.** v2.5 closes a 3-cycle deferred supply-chain integrity gap (ADR-028 → ACCEPTED) and introduces three new security surfaces: F1 per-file SHA-256 verify pass, F2 new `tools:` frontmatter parse surface with closed-vocabulary CI gate, and F3 first outbound contribution to a third-party repo. Phase 1 deliberation Round 1 already converted @security pre-empt W1 into binding constraint C-v2.5-19 (`lock-content-sha-cross-check` step on every PR), which is the architecturally-correct mitigation for the backfill supply-chain trust gap and removes what would otherwise have been a Phase 2 CRITICAL finding (poisoned-curl in @dev's local env producing wrong-but-self-consistent hashes).

The two WARNINGs (S1, S2) are CI-parser robustness items on the new MF-3 vocabulary gate and the @architect-supplied awk header-name-lookup logic. Both are bounded to in-tree CI files under PR review. Neither is exploitable on the v2.5 surface; both should be hardened in Phase 4 to close residual fail-open paths and set a clean baseline for v3.0's expansion of the `tools:` consumer surface.

The five INFOs cover: (S3) F3 outbound contribution governance handoff (W2 carry — 2FA on submitting account), (S4) MF-3 awk frontmatter-counter walk-past hazard (W3 carry — MD035 sentinel), (S5) F5 pre-commit hook trust model on `.git/hooks/pre-commit` overwrite, (S6) CF-L1-1 paraphrase-escape false-negative window confirmation, and (S7) F1 verify-pass logging differentiation between fetch-failure and integrity-mismatch.

Phase 4 is authorized to proceed once the user accepts the WARNINGs at `/gate`, with the MUST-FIX list below bound into Phase 4.

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING  | 2     | configuration | F2 MF-3 vocab gate parser: `sed -E 's/^tools:\s*\[//; s/\]\s*$//; s/,/ /g' \| tr -d ' '` does not reject malformed YAML where `tools:` value is a multi-line YAML list (`tools:\n  - claude-code\n  - cursor`). The first-line regex captures only the `tools:` line; subsequent `- claude-code` items would NOT be parsed and the gate would silently pass with TOKENS=empty (zero-iteration loop, no error). Fail-open on multi-line YAML form. |
| S2 | WARNING  | 2     | configuration | F4 MF-2 awk header-name lookup: `gsub(/^[[:space:]]+\|[[:space:]]+$/, "", $i)` strips leading/trailing whitespace from header cells, but does not lowercase. If a contributor renames the header to `Goal_Tags` or `goal tags` (capitalized, or space-separated), the `$i == "goal_tags"` exact-match comparison fails, awk exits 2 (HEADER_MISSING_GOAL_TAGS), pipefail propagates — fail-closed. However, a SUBTLE attack: a header containing a zero-width or non-printing character (e.g., `goal_tags<U+200B>` zero-width-space) would also miss the match and fail-closed; this is acceptable. The genuine WARNING is that NR==2 hardcodes header position — if the registry adds a leading blank line or comment line above the header, NR==2 lands on the wrong line, awk fails to find `goal_tags`, exits 2 — fail-closed but produces misleading error. Bind a defensive `NR==2 || (header_found==0 && /^\| / && /goal_tags/)` two-pass header scan, OR document the NR==2 invariant in CONTRIBUTING.md. |
| S3 | INFO     | 2     | configuration | F3 outbound PR submitted from human GitHub account (no CI bot). W2 carry-forward: confirm 2FA enabled on `lozano1.990@gmail.com`-associated GitHub account at PR-submission time. Out-of-band hardening; not blocking. |
| S4 | INFO     | 2     | configuration | F2 MF-3 awk frontmatter extraction `/^---$/{c++; next} c==1 && /^tools:/`: counter walks past the closing fence correctly (verified — `c==1` is false after the second `---`), BUT if a SKILL.md body contains a literal `---` horizontal-rule line (MD035 hazard), `c` increments to 3 and any later `tools:` line in body prose is silently skipped. Risk is currently zero (template bans body-level `---`); recommend a markdownlint MD035 (`hr_style: dashes`) sentinel as defense-in-depth. (W3 carry-forward.) |
| S5 | INFO     | 2     | configuration | F5 `scripts/install-pre-commit.sh` writes to `.git/hooks/pre-commit`. Spec EC-6 covers the `markdownlint`-not-installed case. NOT covered: (a) script behavior when `.git/hooks/pre-commit` already exists (overwrite vs prompt); (b) script's own `set -euo pipefail` declaration; (c) path-validation against `..` traversal in `git rev-parse --show-toplevel` output. Bind into AC-F5-4's "documented manual test procedure" — explicit "refuse to overwrite without `--force` flag" or "back up existing hook to `.git/hooks/pre-commit.bak`" pattern. |
| S6 | INFO     | 2     | license | C-v2.5-11 grep verifier `grep -ciE 'writing.profile\|writing profile\|writing_profile'` catches the literal string and common variations. False-negative window: a paraphrased reference like "consult the user's tone preferences file" or "apply the writing-style document" would slip through. @compliance accepted this scoping in CF-L1-1 ruling. @security records the false-negative window for Phase 6 audit re-verification: @qa at Phase 5 should perform a manual prose-read of `upstream-contribution/meeting-notes-upstream.md` for any oblique reference to writing-profile semantics, not rely solely on grep. Acceptable per @compliance scoping; no design change. |
| S7 | INFO     | 2     | logging | F1 verify pass per ADR-028 emits `::error::Integrity mismatch on ${file_path} — stored content_sha256=<old> fetched=<new>` on mismatch. Existing fetch-failure path emits `WARNING: Failed to fetch ${file_path} — skipping`. Spec EC-2 mandates "distinct failure messages" — confirmed distinct (`::error::` vs `WARNING:`, `Integrity mismatch` vs `Failed to fetch`), but @qa at Phase 5 should grep both message strings independently in CI log to confirm they fire on the right code paths and do not fold into a single ambiguous message. Bind a CI log-grep ACs verifier in Phase 4 (already implicit in AC-F1-3's fault-injection but not log-message-level explicit). |

### CRITICAL
(none)

### WARNING

- [ ] **S1 — MF-3 vocab gate fail-open on multi-line YAML `tools:` form.** ADR-029 implementation sketch (architecture.md L5683–5714) extracts via:
  ```bash
  TOOLS_LINE=$(awk '/^---$/{c++; next} c==1 && /^tools:/' "$skill_md")
  TOKENS=$(echo "$TOOLS_LINE" | sed -E 's/^tools:\s*\[//; s/\]\s*$//; s/,/ /g' | tr -d ' ' | tr ',' ' ')
  ```
  This handles the inline-array form `tools: [claude-code]` (the only form C-v2.5-7 mandates) but a future contributor (or an inadvertent reformatter — e.g., a YAML pretty-printer) could produce the multi-line form:
  ```yaml
  tools:
    - claude-code
    - cursor
  ```
  In this case `TOOLS_LINE` captures only the literal line `tools:`. The sed pipeline then produces an empty TOKENS string, the `for token in $TOKENS` loop iterates zero times, no `BAD_FILES` entry is appended for that file, and the gate **passes silently** despite the `tools:` field being structurally present-but-unparsed. C-v2.5-7 requires `tools: [claude-code]` exactly at v2.5, but the gate enforces nothing about array form — only the missing-`tools:`-line case fails (when TOOLS_LINE is empty). **Mitigation:** add an explicit sanity check: `if [ -z "$TOKENS" ] && [ -n "$TOOLS_LINE" ]; then echo "::error::${skill_md} tools: present but unparsed (multi-line form not supported at v2.5)"; BAD_FILES="${BAD_FILES} ${skill_md}"; continue; fi`. Disposition: **MUST-FIX at Phase 4. Bind into C-v2.5-8.** Two-line bash patch.

- [ ] **S2 — MF-2 awk header-name lookup hardcodes NR==2.** Architecture.md L5905–5920 specifies awk reads the header on `NR==2`. This assumes `curated-skills-registry.md` row 1 = preamble pipe-row, row 2 = header (the current file shape). If a future contributor adds a leading blank line or a markdown comment (`<!-- ... -->`) above the table, NR==2 lands on a non-header row, the `for (i=1; i<=NF; i++)` loop finds no `goal_tags` match, awk emits HEADER_MISSING_GOAL_TAGS to stderr and exits 2 — fail-closed but with a misleading error message that suggests the header is absent when it is merely displaced. **Why WARNING and not INFO:** the failure is fail-closed (correct semantics) but the failure mode is mute about the actual cause (NR offset), creating a debug-time foot-gun. **Mitigation Option A (preferred):** replace `NR==2 { ... }` with `header_seen==0 && /^\| / && /goal_tags/ { ... header_seen=1; next }` — finds the header by structural matching, not positional. **Mitigation Option B (defensive minimum):** keep NR==2 but bind a CONTRIBUTING.md note: "Do not insert blank lines or comments above the registry table header." Disposition: **MUST-FIX at Phase 4. Bind into C-v2.5-14 amendment OR new C-v2.5-20.** @dev's discretion which option (A is durable; B is one line of doc).

### INFO

- **S3 — F3 outbound PR submitted from human GitHub account (W2 carry).** No CI automation submits the PR; the project owner manually opens it at `msitarzewski/agency-agents`. @security recommends 2FA enabled on the project owner's account at PR-submission time. Out-of-band hardening; not a Phase 4 deliverable. Already documented in deliberation Round 1 W2.

- **S4 — MF-3 awk frontmatter-counter walk-past hazard (W3 carry).** Verified empirically: counter increments to 2 at closing `---`, `c==1` becomes false, `tools:` lines in body prose are NOT matched. SAFE for current SKILL.md template (no body-level `---`). Forward hardening: add markdownlint MD035 sentinel (`hr_style: false` or pin to `***`) so a future `---` body line is rejected at lint-time before reaching MF-3.

- **S5 — F5 pre-commit hook trust model.** AC-F5-4 currently allows "documented manual test procedure" in lieu of CI test. Recommend the manual procedure cover three cases beyond spec EC-6: (1) existing-hook overwrite policy, (2) script's own `set -euo pipefail`, (3) `.git/hooks/` path resolution via `git rev-parse --show-toplevel` (not `pwd`-relative). Each is one-line. Bind into AC-F5-4 manual procedure documentation in `docs/architecture.md`.

- **S6 — CF-L1-1 paraphrase-escape false-negative window.** Confirmed: grep verifier `'writing.profile|writing profile|writing_profile'` catches literal references; paraphrased references ("user's tone preferences file", "writing-style document", "user's voice file") slip through. @compliance accepted this scoping. @security adds a Phase 5 manual-read instruction for @qa: prose-read `upstream-contribution/meeting-notes-upstream.md` and assert no oblique writing-profile semantics. Phase 6 re-verifies.

- **S7 — F1 verify-pass log message differentiation.** Confirmed distinct on the wire (`::error::` vs `WARNING:`). Recommend Phase 5 CI-log grep verifier asserts both message strings fire on their respective code paths during the AC-F1-3 fault-injection test (one mismatch entry → one `::error::Integrity mismatch` line; zero `WARNING: Failed to fetch` lines on a clean network).

### Per-watch-item resolution (W1–W3 from Phase 1 Round 1)

| Watch item | Surface | Disposition |
|------------|---------|-------------|
| **W1 backfill supply-chain trust** | F1 ADR-028 backfill | **RESOLVED — folded into binding constraint C-v2.5-19 (`lock-content-sha-cross-check` step on every PR).** No Phase 2 finding; the cross-check makes backfill state cross-environment-verified between @dev's local env and clean GitHub-Actions runner. Pre-empt closed convergent at deliberation. |
| **W2 GitHub 2FA on contributor account** | F3 outbound PR submission | **INFO (S3)** — out-of-band hardening; @security recommends 2FA at PR-submission time. Not blocking. |
| **W3 MF-3 awk MD035 sentinel** | F2 frontmatter extraction | **INFO (S4)** — verified empirically counter walks past close fence correctly; risk only on body-level `---`; markdownlint MD035 sentinel recommended as defense-in-depth. Not blocking. |

---

## OWASP Web Top 10 — FULL pass (v2.5 surfaces)

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth surface, no RLS, no IDOR. v2.5 introduces no permission/role surface. F3 outbound PR uses GitHub's own access controls (the contributor's account + upstream maintainer's review). No Cowork-side permission decision. |
| A02 Cryptographic Failures | PASS | F1 introduces per-file SHA-256 verify; SHA-256 choice is industry-standard for content-addressing (npm package-lock, Go go.sum, Cargo Cargo.lock all use SHA-256). No HMAC needed (no shared-secret model — this is content-integrity against a public commit pin, not authentication). `cowork.lock.json` `$schema_version` "1.0" preserved (additive field). C-v2.5-1 + C-v2.5-19 implement the verify pass + cross-check. |
| A03 Injection | PASS | F1 verify pass: SHA-256 compute + string equality, no shell interpolation of fetched bytes (`sha256sum` reads file by path; `jq --argjson` for hash compare per architect-recommended pattern). F2 MF-3 vocab gate: token candidates pass through `grep -qw "$token"` (literal-word match — safe). Variable expansion `${token}` in echo strings is bash variable expansion only, not command substitution; embedded `$(...)` in a `tools:` value would NOT re-execute when assigned to a variable. F3 outbound: file is a tracked artifact only — never sourced, never executed. F4 awk column-name lookup: input is a markdown table file under PR review; awk single-pass, no eval, no regex-from-input. F5 install-pre-commit.sh: writes a static hook script to `.git/hooks/`; no input interpolation. **No new injection surface.** |
| A04 Insecure Design | PASS | F1 fail-closed semantics: verify runs BEFORE accumulator append, so partial state never reaches the lock rewrite path. Empty `files[]` edge handled (zero-iteration loop). Cross-check (C-v2.5-19) runs on every PR — cross-environment trust anchor. F2 closed-vocabulary at v2.5 prevents drift; CI strictness + runtime grace pattern is correct (architect L5722–5726). F3 outbound is manual + human-reviewed at upstream; no automation path POSTs to upstream APIs. F5 opt-in pre-commit hook — zero forced tooling, consistent with project posture. |
| A05 Security Misconfiguration | PASS-WITH-WARNINGS | S1 (MF-3 multi-line YAML fail-open) and S2 (MF-2 NR==2 hardcoded) are config-gate hardening. Both are bounded to in-tree CI files under PR review. Neither is exploitable in the v2.5 surface (C-v2.5-7 mandates inline form; current registry has no preamble). MUST-FIX at Phase 4 to close residual fail-open paths and set a clean baseline for v3.0. The F4 hardening itself (`set -o pipefail` + awk header-name lookup) is integrity-positive — explicitly closes the v2.4 I1 INFO and CF-v2.4-B + CF-v2.4-G carry-forwards. Per-step pipefail scope (architect ruling on OQ-v2.5-5) is the correct minimal forward-safe choice. |
| A06 Vulnerable & Outdated Components | PASS | Zero new dependencies. F1 backfill script uses `curl` + `sha256sum` + `jq` (already used in sync-agency.yml). F1 verify step uses `sha256sum` + `jq` (already used). F2 MF-3 gate uses awk + sed + tr + grep (already used). F4 hardening uses bash builtins. F5 pre-commit hook invokes `markdownlint` (already used in CI markdown-lint job; spec EC-6 handles missing-locally case). No new actions, no new packages. |
| A07 Identification & Authentication | N/A | No auth surface. F3 PR submission uses the project owner's GitHub credentials — out-of-band trust, GitHub's own auth controls. S3 INFO recommends 2FA. |
| A08 Software & Data Integrity | PASS — STRENGTHENED | This is the load-bearing OWASP category for v2.5. ADR-028 implementation closes a 3-cycle deferred integrity gap. Per-file `content_sha256` provides byte-level tamper-evidence. Cross-check (C-v2.5-19) provides cross-environment verification on every PR (clean GHA runner vs @dev's local env). Backfill atomic in v2.5 PR (architect OQ-v2.5-2 ruling): no half-state. SCAN_PATTERNS preservation (C-v2.5-5) intact. ADR-020 schema_version "1.0" preserved (C-v2.5-4). The v2.0 8-pattern SCAN_PATTERNS chokepoint at sync-agency.yml L143–152/220 remains BYTE-UNCHANGED — load-bearing, preserved. **A08 surface is materially stronger post-v2.5 than at v2.4.** |
| A09 Security Logging & Monitoring | PASS | F1 verify-fail emits `::error::` (GHA-recognized error annotation) on mismatch; existing fetch-fail emits `WARNING:`. Distinct message shapes per spec EC-2. S7 INFO recommends Phase 5 CI-log grep verifier as defense-in-depth. No telemetry surface introduced. |
| A10 Server-Side Request Forgery | PASS | F1 verify pass + cross-check (C-v2.5-19) BOTH fetch from `https://raw.githubusercontent.com/${UPSTREAM}/${PINNED}/${path}` — same URL shape as the existing sync-agency.yml fetch. The `${UPSTREAM}` and `${PINNED}` values come from `cowork.lock.json` (in-tree, PR-reviewed). No user-controlled URL component. The path component is `.path` from `cowork.lock.json` files[] — also in-tree. **No new SSRF vector.** Backfill script (one-shot, NOT shipped) uses identical URL shape — same trust boundary. |

---

## OWASP LLM Top 10 — FULL pass (SECURITY-SENSITIVE classification)

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 Prompt Injection | PASS | F2 `tools:` field is a NEW YAML key on instruction-surface markdown. Verified read-as-data semantics: (a) the wizard at v2.5 reads `tools:` informationally only — no routing logic, no prompt interpolation; ADR-029 forward-binding statement explicitly mandates declarative-not-imperative semantics for v3.0+ ("MUST NOT auto-translate or auto-reformat skill content based on `tools:` declaration"). (b) MF-3 CI gate validates against closed allow-list `[claude-code, copilot, cursor, windsurf]` — any token outside the list fails CI. (c) The closed vocabulary prevents skill-author-supplied free-form strings from becoming instructions to a downstream consumer. (d) C-v2.5-7 forces `tools: [claude-code]` exactly across all 20 v2.5 skills — no skill author supplies the field's contents at v2.5. Combined with the existing 8-pattern SCAN_PATTERNS at sync-agency.yml L143–152 (BYTE-UNCHANGED per C-v2.5-5), the LLM01 surface is materially constrained. F1 SHA-256 verify provides additional integrity-against-injection: a poisoned skill body whose hash drifts from `content_sha256` fails the verify step before reaching the lock rewrite. F3 outbound contribution: `meeting-notes-upstream.md` is a tracked artifact only — never sourced, never read at runtime by Cowork wizard. |
| LLM02 Insecure Output Handling | PASS | F1 verify pass emits hashes (hex strings, bounded character set) and file paths (in-tree, PR-reviewed) to GHA logs — no user-supplied content reaches the log surface. F2 MF-3 emits skill_md path + token literal in `::error::` messages — both are in-tree under PR review. F3 outbound file body follows upstream format conventions (no Cowork-supplied user content). No new output-handling surface. |
| LLM03 Training Data Poisoning | N/A | No model training in scope. |
| LLM04 Model Denial of Service | N/A | No model invocation in scope at v2.5. |
| LLM05 Supply Chain Vulnerabilities | PASS — STRENGTHENED | This is the load-bearing LLM category for v2.5 (parallel to A08). ADR-028 implementation closes the deferred upstream-content-tamper-evidence gap. Per-file `content_sha256` provides byte-level integrity proof at fetch time + verify pass + cross-environment cross-check. The trust chain is: pinned commit SHA → per-file SHA-256 (fetch-time write) → `content_sha256` (verify-time read) → cross-check on every PR (independent re-fetch in clean GHA runner). Three independent proofs of the same bytes; any poison/swap/tamper between commits requires all three to be subverted simultaneously. **Phase 5 must verify all three fire on AC-F1-3 fault-injection.** |
| LLM06 Sensitive Information Disclosure | PASS | F3 outbound PR description includes `lozano1.990@gmail.com` (via the GitHub account name) — this is already public-by-virtue-of-GitHub-username on existing Cowork PRs. No new sensitive data path. F3 PR description per CF-L4-1 contains attribution line; no credentials, tokens, or internal pipeline state. `meeting-notes-upstream.md` follows upstream format — no Cowork-internal references (CF-L1-1 strip, C-v2.5-11). |
| LLM07 Insecure Plugin Design | N/A | No plugin/extension surface. |
| LLM08 Excessive Agency | PASS | F3 outbound PR submitted manually by human; no CI bot or automation POSTs to upstream. Wizard at v2.5 reads `tools:` informationally only — no automated routing decision. ADR-029 forward-binding statement caps v3.0 routing as read-only consumer semantics (filter/weight/warn but never auto-translate). |
| LLM09 Overreliance | N/A | Not a runtime LLM-call surface. v2.5 is markdown + CI bash. |
| LLM10 Model Theft | N/A | No model artifacts in scope. |

---

## F1 ADR-028 Verify-Step Audit (architect handoff item 1)

**SHA-256 choice:** APPROVED. Industry-standard for content-addressing (npm package-lock, Go go.sum, Cargo Cargo.lock). Collision-resistance properties are sufficient for downstream-consumer integrity verification against a public-by-pin upstream. No HMAC needed (no shared-secret model). `sha256sum` is GNU coreutils — already invoked in sync-agency.yml L109, L216.

**Verify placement (resolves OQ-v2.5-1):** APPROVED. Architect ruling: verify step inside existing fetch job, AFTER per-file SHA-256 compute (line 216), BEFORE accumulator append (line 237). This is the architecturally-correct placement:
- Fail-closed semantics: verify failure exits the loop before any partial state reaches the accumulator (line 237 jq append) or the lock rewrite (line 321).
- Topology minimal: 6-line addition inside the existing per-file loop; no new job, no artifact-staging surface.
- `FILE_SHA256` already in scope at line 216 (no re-computation).

**Fault-injection ACs (AC-F1-3):** APPROVED with S7 INFO. Fixture-based test at `tests/fixtures/sha-fault-injection.json` + `quality.yml` step `lock-content-sha-fault-injection` runs verify logic against fixture and asserts non-zero exit. Production lock state never tampered with. **S7 recommendation:** Phase 5 should ALSO grep CI log for `::error::Integrity mismatch` literal — confirms message string fires on the right code path (not just non-zero exit).

**TOCTOU between hash-compute and write:** ANALYZED, NOT VULNERABLE. The hash-compute (line 216) operates on a file already fully written to `/tmp/fetched-files/${category}/${filename}` by line 210's `curl -sf -o`. The verify pass operates on the SAME `FILE_SHA256` variable from line 216 — no second filesystem read between compute and verify. The accumulator append (line 237) uses the same `FILE_SHA256` via `jq --arg sha256 "$FILE_SHA256"`. Three uses of one in-memory value; no race window. **Empty `files[]`:** EC-1 covered — bash `for ... in $(jq -r '.files[]')` iterates zero times on empty array; verify loop also zero-iterations. No shell error.

---

## F1 Backfill Audit (architect handoff item 2)

**Atomic one-shot acceptance (OQ-v2.5-2):** APPROVED. Strategy (a) — local backfill in v2.5 PR — is the correct atomic-deploy pattern. (b) and (c) introduce half-state (entries with vs without `content_sha256` co-existing in the same lock file) which would force the verify pass to carry a tolerance branch indefinitely. (a) lets verify be strict from v2.5.0 onward with no grace-branch maintenance debt.

**Supply-chain trust model (W1 → C-v2.5-19):** RESOLVED via deliberation Round 1 binding. The backfill script runs in @dev's local environment (`curl` against `raw.githubusercontent.com` at the pinned commit). If @dev's local `curl` or DNS were poisoned, the backfilled hashes would be wrong-but-self-consistent — the verify pass would NEVER catch the discrepancy because it only validates against the stored `content_sha256`, which is itself the poisoned value. **C-v2.5-19 closes this:** `lock-content-sha-cross-check` step runs on every PR in a clean GitHub-Actions runner, fetches each `files[]` entry independently from `raw.githubusercontent.com` at `pinned_commit_sha`, computes SHA-256, and asserts equality with the stored `content_sha256`. Any mismatch fails the PR. This makes the backfill state cross-environment-verified — a successful PR merge implies BOTH @dev's local env AND a clean GHA env produced the same hash, providing two-environment trust anchor.

**Script not shipped (deliberation A2):** APPROVED. The backfill script (`scripts/backfill-content-sha256.sh`) is one-shot, lives in PR description / commit message / ADR prose only. Future cycles re-derive from ADR-028 v2.5 prose if they need it. CF-v2.5-A documents this. Avoiding script-creep is positive — fewer files mean fewer maintenance commitments.

**`--arg`/`--argjson` for jq:** Architect script sketch (L5594–5611) uses `jq --argjson i "$idx" --arg h "$HASH"` — no string interpolation of fetched content into jq arguments. Script template SAFE.

**Network fetch path identical to production:** Confirmed. Both use `https://raw.githubusercontent.com/${UPSTREAM}/${PINNED}/${path}`. `${UPSTREAM}` and `${PINNED}` from same `cowork.lock.json` source. Cross-check (C-v2.5-19) uses identical URL shape. Three fetches of identical shape across two environments = strong trust.

**Glob ordering determinism:** Architect script uses `jq -r '.files | to_entries[]' cowork.lock.json` for iteration — jq preserves array order, so iteration is deterministic. SAFE.

---

## F3 Outbound Audit (architect handoff items 5 + 6)

**Information-disclosure on `meeting-notes`:** Verified via direct grep. `skills/meeting-notes/SKILL.md` line 108 contains the writing-profile reference. Per CF-L1-1 + C-v2.5-11, this MUST be stripped from `upstream-contribution/meeting-notes-upstream.md`. The grep verifier is binding. S6 INFO records the paraphrase-escape false-negative window — Phase 5 manual prose-read is the compensating control.

**LLM01 reformat (F3 → upstream format):** Architect ruling (L5801–5827) — manual rewrite, not scriptable. The upstream format (persona-centric: identity + capabilities + workflow + deliverables) is structurally different from Cowork format (procedural: instructions + triggers + output + quality + anti-patterns + example). Rewrite means @dev authors fresh content using `skills/meeting-notes/SKILL.md` as substantive source. **Pasted-content-as-data rule** (from v1.3.3 S1 carry-forward) MUST be reflected in the upstream's "Critical Rules" section per @compliance SF-2 — defensive design demonstrates Cowork's supply-chain hygiene posture. This is a quality recommendation, not a Phase 4 binding.

**Governance handoff (post-merge upstream ownership):** @compliance L3-1 / L4-1 rulings binding — no CLA, no DCO, no copyright assignment at upstream. Cowork retains copyright; upstream receives implicit MIT distribution grant. Post-merge: upstream maintainer may modify, rename, remove without further obligation. Cowork retains canonical at `skills/meeting-notes/SKILL.md` and tracked artifact at `upstream-contribution/meeting-notes-upstream.md`. **Security implication:** post-merge edits at upstream do NOT propagate back to Cowork (upstream is downstream of Cowork for this file). No supply-chain risk. **Account hardening:** S3 INFO — confirm 2FA at PR-submission time on the contributor account.

**Outbound file never sourced/executed by Cowork CI:** Confirmed via path-glob analysis. Architect ruling (L5878–5882): `upstream-contribution/` is excluded from `skill-depth-check` POOL loop, CMP loop, and MF-3 vocab gate by virtue of NOT being targeted (path-glob shape exclusion). No `--exclude` flag, no `if` branch — minimal correct topology. The directory name is the boundary signal. `cowork.lock.json` does not reference `upstream-contribution/`. `sync-agency.yml` does not reference `upstream-contribution/`. The wizard runtime targets `skills/`, not `upstream-contribution/`. Tracked-artifact-only confirmed.

**Inbound contamination strip (CF-L1-1) verification:** C-v2.5-11 grep verifier is binding. S6 INFO documents the paraphrase-escape window; @compliance accepted. Phase 5 prose-read is the compensating control.

---

## F2/MF-3 Vocabulary Gate Adversarial Coverage (architect handoff items 3 + 4)

**Shell metachar injection attempt:** Synthesized test — `tools: [claude-code, "$(rm -rf /)"]`:
- After sed pipeline: TOKENS contains `claude-code"$(rm-rf/)"`.
- `for token in $TOKENS` — bash word-splitting on whitespace, but the `$(...)` is now embedded inside a quoted string artifact; no command substitution occurs because the `$(...)` is in a variable's string value, not a command position.
- `grep -qw "$token"` — grep's `-w` matches whole words; the embedded `"$()` characters are matched literally. `claude-code"$(rm-rf/)"` does NOT match `claude-code` as a whole word (the `"` is not a word boundary in grep's `\<...\>` semantics, but `"` IS a non-word character so word-boundary matches DO fail). The grep returns false (non-match) → token deemed invalid → BAD_FILES updated → exit 1.
- The `${token}` in the `echo "::error::..."` line is bash variable expansion of a string — no re-evaluation of `$()`.
- **Conclusion:** SAFE against shell-metachar injection. The closed-vocabulary allow-list catches the malformed token before any privileged operation. **No exploit.**

**Vocab extension governance:** Allow-list is declared in-step (`ALLOWED='claude-code copilot cursor windsurf'`) — not from external file, not from environment variable. Extension requires an architecture change (ADR amendment) + PR review. **Trust model: in-tree-only, PR-reviewed.**

**Default-when-absent rule:** Architect ruling (L5722–5726) — default applies at WIZARD.md runtime ONLY, NOT at CI. CI is strict (presence required); runtime is graceful (defaults to `[claude-code]`). This split is correct: CI strictness ensures shipped skills declare their target tools; runtime grace handles edge cases (user manually edits SKILL.md mid-session). **No bypass surface — the runtime grace path does not introduce a CI-bypass.**

**Malformed YAML coverage:** S1 WARNING — multi-line YAML form (`tools:\n  - claude-code`) silently passes the gate (TOOLS_LINE captures only literal `tools:`, sed produces empty TOKENS, zero-iteration loop). MUST-FIX at Phase 4 with two-line bash patch (sanity check on TOOLS_LINE-non-empty + TOKENS-empty combination).

**Frontmatter-counter walk-past:** S4 INFO — counter walks past closing `---` correctly under current SKILL.md template (verified empirically); MD035 sentinel recommended as defense-in-depth.

---

## F4 Hardening Verification (architect handoff items 7 + 8)

**Per-step `pipefail` scope (resolves OQ-v2.5-5):** APPROVED. Architect ruling: `set -o pipefail` at the top of each MF-1 and MF-2 `run:` block — NOT global YAML-level, NOT per-line. This is the smallest scope that fixes the v2.4 I1 INFO without affecting other steps in the job. Verified: both MF-1 and MF-2 step bodies end in `grep -c` (the gate signal); no INSIDE-the-step pipelines rely on rightmost-segment-success masking. **Per-step bounded → no spillover risk.** Forward-safe: future steps in the same `run:` block (none currently) can opt out by adding their own `|| true` AFTER pipefail is consumed by the gate.

**`|| true` removal (AC-F4-1, AC-F4-2):** With pipefail on, the trailing `|| true` is no longer needed (pipeline's exit code becomes the rightmost non-zero). Removal closes the v2.4 I1 INFO. CF-v2.4-G resolved.

**MF-2 awk header-name lookup (CF-v2.4-B resolution):** APPROVED with S2 WARNING. Architect-supplied awk (L5905–5920) uses two-row-state machine: NR==2 finds `goal_tags` column index; NR>2 prints `$col`. `gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)` strips whitespace; case-sensitive exact-match against `goal_tags`. **S2 WARNING:** NR==2 hardcoded — fail-closed but misleading-error if a leading blank/comment line is added above the table. MUST-FIX at Phase 4 (Option A: structural header scan; Option B: CONTRIBUTING.md note pinning the file shape).

**Awk header-name robustness vs collision:** No two columns can collide on `goal_tags` because awk's `for (i=1; i<=NF; i++)` loop assigns `col=i` on EACH match; if `goal_tags` appears twice, the LAST occurrence wins. Currently registry has one `goal_tags` column. Defense recommendation: add `if (col != 0 && col != i) { print "DUPLICATE_GOAL_TAGS_HEADER" > "/dev/stderr"; exit 2 }` to detect duplicate-column attack — but the current registry shape forbids duplicates so this is over-engineering at v2.5. Disposition: NOT bound; carry as informational observation for future cycles if registry shape changes.

**Regression fixture (AC-F4-5):** APPROVED. `tests/fixtures/registry-column-reorder.md` + a quality.yml step that runs MF-2 logic against the fixture and asserts BAD=1 still fires on a reordered column. Per architect leaving discretion to @dev whether to fold into MF-3 fault-injection step.

---

## F5 Installer Path-Validation Review (architect handoff item 9)

**Trust model:** Opt-in. Spec L191–193 — script is NOT installed automatically; contributor runs `bash scripts/install-pre-commit.sh` to opt in. This is consistent with project's zero-forced-tooling posture. The trust model is human-mediated: contributor reads the script source before running. Cowork ships the script under PR review.

**Path validation:** Script writes to `.git/hooks/pre-commit`. Architect did not specify path-resolution mechanism (ADR-016 v2.5 amendment focuses on quality.yml, not the install script). **S5 INFO recommendations:**
1. Use `git rev-parse --show-toplevel` to find repo root (canonical), NOT `pwd`-relative resolution.
2. Refuse to overwrite an existing `.git/hooks/pre-commit` without explicit `--force` flag OR back up to `.git/hooks/pre-commit.bak` before write.
3. Script begins with `set -euo pipefail`.
4. Spec EC-6 (markdownlint not installed) covered — clear error message + non-zero exit.

**Path traversal:** `git rev-parse --show-toplevel` returns an absolute path; concatenation with `/.git/hooks/pre-commit` yields an absolute path with no traversal surface. SAFE under the recommended mechanism.

**`markdownlint` invocation:** The hook invokes `markdownlint` against staged `.md` files. Spec L195–196 — same ruleset as CI `markdown-lint` step. Architect did not bind a specific config-file reference mechanism (e.g., shared `.markdownlintrc` vs CI-inline ruleset). Recommend Phase 4 use a shared config file referenced by both CI and the hook to avoid drift. AC-F5-2 verifies `markdownlint` is invoked; @qa at Phase 5 should additionally verify the ruleset is the same as CI (e.g., by comparing rules).

**Disposition:** All four S5 sub-recommendations bound into AC-F5-4's manual procedure documentation in `docs/architecture.md`. Not blocking; INFO-class.

---

## MUST-FIX for Phase 4

Bound to spec ACs and constraints. These are security findings that require @dev action.

| ID | Bound to | Requirement | Verification |
|----|----------|-------------|--------------|
| **MF-S1** | C-v2.5-8 (AC-F2-3) | MF-3 vocab gate MUST reject `tools:` field present-but-unparseable (multi-line YAML form). Add 2-line bash sanity check after sed/tr pipeline: `if [ -z "$TOKENS" ] && [ -n "$TOOLS_LINE" ]; then BAD_FILES="${BAD_FILES} ${skill_md}"; echo "::error::${skill_md} tools: present but unparsed (multi-line form not supported at v2.5)"; continue; fi`. | Fault-inject `tools:\n  - claude-code` (multi-line form) into one SKILL.md → MF-3 exits non-zero with the new error message |
| **MF-S2** | C-v2.5-14 amendment OR new C-v2.5-20 | MF-2 awk header-name lookup MUST replace `NR==2` with structural header scan: `header_seen==0 && /^\| / && /goal_tags/ { ...; header_seen=1; next }`. OR (defensive minimum) bind a CONTRIBUTING.md note: "Do not insert blank lines or comments above the registry table header." @dev's discretion which option. | Option A: fault-inject leading blank line above registry header → MF-2 still finds `goal_tags` and fires correctly on injected bad token. Option B: `grep -F 'no blank lines or comments above the registry table header' CONTRIBUTING.md` >= 1 |

Both MUST-FIX items are bash-only; no architectural change required.

---

## SHOULD-FIX Recommendations (Non-Blocking)

| ID | Recommendation | Rationale |
|----|---------------|-----------|
| **SF-S1** | Bind S5 INFO sub-recommendations (S5.1 `git rev-parse --show-toplevel`; S5.2 existing-hook backup; S5.3 `set -euo pipefail`; S5.4 EC-6 already covered) into AC-F5-4 documented manual test procedure in `docs/architecture.md`. Each is one line. | Closes the F5 trust-model audit cleanly; sets baseline for future contributor-tooling additions. |
| **SF-S2** | Add markdownlint MD035 sentinel (`hr_style: false` or pin to `***`) to the project's markdownlint config. Defense-in-depth against future SKILL.md body-level `---` that would confuse MF-3 awk frontmatter counter. | Closes S4 watch item; cost is one config line. |
| **SF-S3** | Bind a CI log-grep verifier in Phase 4 that asserts `::error::Integrity mismatch on` fires on the AC-F1-3 fault-injection (and zero `WARNING: Failed to fetch` on a clean network). | Closes S7; complements AC-F1-3 (non-zero exit) with message-shape verification per spec EC-2 distinct-message requirement. |
| **SF-S4** | @qa at Phase 5 performs a manual prose-read of `upstream-contribution/meeting-notes-upstream.md` for any oblique reference to writing-profile semantics (paraphrased, not just literal grep). | Compensating control for S6 paraphrase-escape false-negative window. |
| **SF-S5** | F3 PR description includes the pasted-content-is-data rule (per @compliance SF-2). | Demonstrates Cowork's LLM01-aware design posture; improves upstream merge likelihood; quality, not security. |

---

## Phase 6 Audit Handoff

@security at Phase 6 MUST re-verify the following at PR HEAD post-Phase-4:

1. **C-v2.5-1**: `cowork.lock.json` `content_sha256` populated on all 110 entries; cross-check (C-v2.5-19) passes on PR — any backfill drift surfaces here.
2. **C-v2.5-2**: `sync-agency.yml` verify step ordered correctly (after L216, before L237). Inspect git diff for placement; fault-injection (AC-F1-3) fires on PR.
3. **C-v2.5-5 (preservation)**: SCAN_PATTERNS array (L143–152) and accumulator append (L237) byte-unchanged from v2.4 HEAD via git diff regex (per architect's mechanism amendment, not frozen-line cmp).
4. **C-v2.5-19**: `lock-content-sha-cross-check` step runs on PR; cross-environment hash verification passes; failure mode tested via fault-injection.
5. **MF-S1 (S1 WARNING resolution)**: Multi-line YAML form fault-injection fires on MF-3.
6. **MF-S2 (S2 WARNING resolution)**: Either structural header scan in MF-2 awk OR CONTRIBUTING.md note present.
7. **C-v2.5-11 (CF-L1-1)**: `upstream-contribution/meeting-notes-upstream.md` literal grep clean; @qa Phase 5 prose-read covered (per SF-S4).
8. **C-v2.5-12 (AC-F3-3)**: Cowork-specific terms grep clean.
9. **C-v2.5-13 (CF-L4-1)**: PR description attribution line present (verified via `gh pr view`).
10. **MF-3 vocabulary gate functional + closed-allowlist**: Allow-list declared in-step; fault-inject `tools: [unknown-tool]` → MF-3 exits non-zero.
11. **F4 hardening fault-injection**: pipefail removes `|| true` masking; awk header-name lookup fires on column reorder (registry-column-reorder.md fixture).
12. **F5 installer path validation**: SF-S1 sub-recommendations present in script source; existing-hook overwrite policy documented in AC-F5-4 manual procedure.
13. **CI log-shape (SF-S3)**: `::error::Integrity mismatch` literal fires on AC-F1-3; clean-network run produces zero `WARNING: Failed to fetch`.
14. **Classification re-confirmation**: Independent V10-S2 verification — Phase 6 reads Phase 4 diff and confirms SECURITY-SENSITIVE classification holds (auth/RLS/payment surfaces absent, supply-chain integrity surface present per ADR-028 implementation).

**Combined-path eligibility at Phase 6:** NOT eligible (locked at Phase 0). FULL audit required.

---

## Anti-Goals Honored

- ✅ Did NOT re-do compliance work (CF-L1-1 + CF-L4-1 referenced; not re-litigated).
- ✅ Did NOT expand scope beyond architecture-bound surfaces (10 architect handoff items + 2 deliberation watch items audited; no new surfaces invented).
- ✅ Did NOT re-run deliberation Round 1 (W1 disposition referenced as RESOLVED; W2/W3 carried forward as INFO).
- ✅ FULL coverage delivered (combined-path NOT eligible — no abbreviated check); OWASP Web 10/10 + LLM 10/10 categories covered.

---

## Verdict

**APPROVE-WITH-WARNINGS.**

**0 CRITICAL · 2 WARNING · 5 INFO**

Proceed to `/gate` for user decision. MUST-FIX items (MF-S1, MF-S2) bound to Phase 4 via C-v2.5-8 and C-v2.5-14 amendment (or new C-v2.5-20). SHOULD-FIX items (SF-S1 through SF-S5) recommended but not blocking. All 14 Phase 6 audit handoff items enumerated. Combined-path NOT eligible — Phase 6 FULL audit required.

The v2.5 surface is well-managed. The single 3-cycle deferred CRITICAL-class concern (ADR-028 supply-chain integrity gap) is closed atomically with deliberation-strengthened cross-environment trust anchor (C-v2.5-19). The two WARNINGs are CI-parser robustness items bounded to in-tree files under PR review — neither is exploitable on the v2.5 surface, but both should be hardened to set a clean baseline for v3.0's expansion of the `tools:` consumer surface and the registry's contributor surface. The five INFOs are forward-hardening recommendations and watch carries from deliberation Round 1.

A08 (Software & Data Integrity) and LLM05 (Supply Chain) are materially STRENGTHENED post-v2.5 vs v2.4. No new auth, no new payment, no schema migration, no new outbound network call beyond same-shape fetch from `raw.githubusercontent.com`.

---

*This review is the Phase 2 security gate per pipeline-policy V10-S2. Findings marked WARNING should be reviewed by the project owner before `/implement`. The MUST-FIX patches above are drafts — confirm final implementation with @architect at deliberation Round 2 if scope ambiguity arises.*
