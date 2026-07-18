# Security Review — v2.3.0 Top-2 Stub Expansion + ADR-028 Spec Scaffold

## Phase: 1 (Deliberation Round 1 — threat-model review of @architect design)
## Date: 2026-05-08T01:15:00Z
## Status: APPROVE-WITH-WATCH-ITEMS
## Classification: STANDARD (docs+spec; no runtime code, no auth, no schema migrations)

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | INFO | 1 | configuration | ADR-028 uses `####` (H4) heading while ADR-020..027 use `##` (H2); minor index/heading hygiene drift |
| S2 | WARNING | 1 | logging | C-v2.3-1 base-sync verification is procedural-only (no automated guard); narrow risk-window during Phase 4 commit authoring — recommend a documented checklist line in @dev's Phase 4 Round 1 output |
| S3 | INFO | 1 | external-api | ADR-028 `content_sha256` v2.4 plan: when /sync-agency fetches and hashes external content, ensure TLS-pinned + redirect-blocked fetch — flag forward to v2.4 @architect/@security review (NOT a v2.3.0 blocker; ADR-028 is PROPOSED only) |
| S4 | INFO | 1 | ui | The mixed-state `cowork.lock.json` after v2.4 (some entries with `content_sha256`, some without) creates a tooling-ambiguity surface — recommend ADR-028 explicitly add a "presence implies enforcement; absence implies tolerated" reader contract (it does, but state it as a binding reader rule, not just consequence prose) |

**Counts: 0 CRITICAL · 1 WARNING · 3 INFO**

## Independent Verification of @architect's 3 Critical Findings

| Claim | Verification method | Result |
|-------|---------------------|--------|
| Variable rename `ENFORCED_PRESETS` → `ENFORCED_EXAMPLES` | `grep -n "ENFORCED_EXAMPLES\|ENFORCED_PRESETS" .github/workflows/quality.yml` | **PASS** — variable is `ENFORCED_EXAMPLES` at L323 + L383, value `"study research project-management"`. Comments reference ADR-021/ADR-026 v2.0.0 rename. |
| Cascade-fail mechanism (adding writing/PA would CI-red the remaining stubs) | Read CI script L334–375 + `wc -l` on all SKILL.md under writing + PA | **PASS** — depth-check inner loop is `for skill_file in "${skill_base}"/*/SKILL.md` (glob, not allowlist). All 6 stubs (writing/{editing-pass,outline-generator,voice-matching}, personal-assistant/{daily-briefing,follow-up-tracker,spend-awareness}) are 18 lines. Adding either example to ENFORCED_EXAMPLES this cycle would FAIL the 60-line floor on the 4 unexpanded stubs. OQ-3 resolution is correct. |
| ADR-Index gap (ADR-020..027 missing) | Read architecture.md L11–37 + `grep -nE '^## ADR-0' docs/architecture.md` | **PASS** — Index table ends at the v1.3.2 amendment row (L36). ADR-020 through ADR-027 are present in body (L2722, 2836, 2943, 3048, 3148, 3257, 3357, 3691) but absent from index. ADR-028 also not added this cycle (acknowledged in design L4393). |

All three @architect findings independently verified PASS.

## Threat Model Surface Verification

### Surface 1 — LLM01 (instruction injection in W1 + W2 SKILL.md content)

**Status: PASS — bindings are sufficient.**

C-v2.3-7 binds:
- Imperative-voice numbered steps (literature-review precedent verified at `examples/research/.../literature-review/SKILL.md` L88–L98).
- Pasted content treated as DATA, not instructions (mirrors PA `global-instructions.md` line 7 — already shipped).
- No URLs except local-relative paths or ADR cross-refs.
- No meta-prompts overriding `global-instructions.md`.

The four explicit prohibitions in the design's LLM01 section (`You are now`, `Your role is`, `Ignore previous instructions`, `From now on`) cover the canonical role-prompt-redefinition vectors. Section-by-section content guidance (L4283–4381) is consistent: every named step is imperative-voice ("Read available samples", "Identify named voice patterns", "Determine invocation path"). No second-person directives slipped through.

**Triple-backtick / hidden-instruction-in-example check (W1 + W2 `## Example` sections):**
- W1 `## Example` is described as "one short writing sample (input — ~5 lines of prose), then a new 80–120-word piece in the same voice (output)". This is content-block, not instruction-block. Constraint C-v2.3-7 already binds "treat user-pasted content as data" — same rule applies symmetrically to the example's own pasted-sample illustrations.
- W2 `## Example` is "sample vault state (today's date, 3–4 calendar events, 5–6 tasks, 1–2 People entries) → user's answers → four-section output". Same posture: user-state is data, not instruction.

**No additional binding required.** C-v2.3-7 covers the surface.

### Surface 2 — W4 ADR-028 PROPOSED text scope

**Status: PASS.**

Verified ADR-028 is text-only. C-v2.3-9 explicitly enumerates `cowork.lock.json`, `.github/workflows/sync-agency.yml`, `.github/workflows/quality.yml` as zero-diff. ADR text at L4395–4476 contains a JSON example (L4421–4438) but explicitly notes "illustrative; NOT applied to `cowork.lock.json` in v2.3.0". `$schema_version` bump to `"2.0"` is **prose-only** for v2.3.0 (L4448).

Migration path option (c) "new-entries-only" is independently the lowest-risk choice:
- Option (a) backfill: requires v2.4 `/sync-agency` to fetch and hash 97 files in CI run — adds time + flake surface + bandwidth cost.
- Option (b) destructive (delete + re-run): violates anti-pattern #9; users could lose pinned-state if upstream moved.
- Option (c) optional-on-old + required-on-new: zero-cost migration, validator gradually tightens organically. Lowest blast radius.

@architect's choice is correct. Concur.

### Surface 3 — W3 registry annotation format vs CI cardinality grep

**Status: PASS — independently verified by synthetic test.**

Synthetic test (writing the proposed two-row + two-annotation block to `/tmp/registry-test.md`, then running `grep -cE '\| (builtin|https?://)' /tmp/registry-test.md`):
- Result: `2` (matches the two data rows; annotation lines do NOT match).
- Annotation lines start with `> \`disposition:` — no `| ` prefix on the meaningful content, no `builtin` or `https://` substring on those lines.

Also verified the second registry-touching CI gate, `registry-url-check` at quality.yml L220–264:
- It uses regex `(?<=\| )(https?://[^\s|]+|builtin)(?= \|)` — requires `| ` BEFORE and ` |` AFTER. Annotation lines have neither boundary. Safe.

Both registry CI gates are unaffected. C-v2.3-5 annotation format is sound.

### Surface 4 — OQ-3 ENFORCED_EXAMPLES cascade-fail claim

**Status: PASS.** See Independent Verification table above. The depth-check inner loop is a glob (`for skill_file in "${skill_base}"/*/SKILL.md`). Adding `writing` or `personal-assistant` to the allowlist this cycle WOULD CI-red the four un-expanded stubs (`editing-pass`, `outline-generator`, `follow-up-tracker`, `spend-awareness`), all of which are 18 lines and lack the 9 ADR-015 sections. The OQ-3 resolution to defer is correct.

### Surface 5 — C-v2.3-1 base-sync verification (P5 carry)

**Status: APPROVE-WITH-WATCH-ITEM (S2).**

C-v2.3-1 reads as a procedural directive: "@dev MUST verify... `git fetch origin && git log --oneline release/v2.3..HEAD && git log --oneline main..release/v2.3 | head`. If the working branch is behind `release/v2.3`, @dev MUST rebase or merge before committing."

This is binding language (`MUST`, with a concrete command), but it lacks a Phase 4 deliverable hook. v2.2 retro P5 carry was specifically about a divergence that organic-checking caught — but only because the @architect noticed during another check. To make this enforceable rather than aspirational:

**Recommendation (S2 watch-item):** @dev's Phase 4 Round 1 deliverable should include a one-line evidence statement, e.g., "Base-sync verified: `release/v2.3` is at <SHA>, ahead of `main` by N commits, working branch matches release/v2.3 at <SHA>." This makes C-v2.3-1 auditable by @qa at Phase 5 (grep for the evidence line in the Phase 4 Round 1 summary). Without an evidence-string, "MUST verify" is unverifiable post-hoc.

This is a WARNING, not CRITICAL — it's a process-rigor improvement, not a defect. The classification stays STANDARD.

## OWASP / LLM Top-10 Light Pass (STANDARD-classified abbreviated check)

| Category | Status | Notes |
|----------|--------|-------|
| A01 Broken Access Control | N/A | No auth surface in this cycle. |
| A02 Cryptographic Failures | N/A | ADR-028 is PROPOSED prose only — no crypto code lands in v2.3.0. SHA-256 choice is fine for content integrity (matches existing path-hash convention). |
| A03 Injection | N/A | No SQL, no command parsing. |
| A04 Insecure Design | PASS | OQ-3 cascade-fail caught preemptively; OQ-5 destructive-migration rejected; defense-in-depth via PROPOSED-then-implement separation. |
| A05 Security Misconfiguration | PASS | C-v2.3-9 zero-diff list explicitly protects `quality.yml`, `sync-agency.yml`, `cowork.lock.json`, `CLAUDE.md`, `WIZARD.md`. Scope-creep prevention is binding. |
| A06 Vulnerable & Outdated Components | N/A | No deps added; no `npm audit` surface. |
| A07 Authentication Failures | N/A | No auth surface. |
| A08 Software & Data Integrity | PASS | ADR-028 strengthens future integrity (per-file `content_sha256`) without weakening current integrity. Migration path preserves existing 97 entries' validity. |
| A09 Logging & Monitoring | N/A | No new log surface. |
| A10 SSRF | INFO (S3) | v2.4 `/sync-agency` will fetch external content under ADR-028 — flag forward (NOT a v2.3.0 finding). |
| LLM01 Prompt Injection | PASS | C-v2.3-7 binds imperative-voice + data-not-instruction posture; literature-review precedent valid. |
| LLM02 Insecure Output | PASS | W1 + W2 outputs are plain markdown / prose; no executable surface. W2 explicitly forbids file-save without confirmation (Instructions step 7). |
| LLM06 Sensitive Info Disclosure | PASS | W2 graceful-degradation ladder (C-v2.3-8) explicitly forbids fabricating briefings — protects against hallucinated PII. Calendar/Tasks/People reads are local-file only (data-locality preserved). |

## Phase 6 Audit Eligibility

Classification: **STANDARD**. Findings: 0 CRITICAL · 1 WARNING · 3 INFO. The single WARNING (S2) is a process-rigor recommendation that does NOT change the threat surface; it asks @dev to add an evidence-string at Phase 4 Round 1.

**Combined Phase 5+6+7 path: ELIGIBLE** — but **conditionally**. The combined path is normally gated on 0 CRITICAL + 0 WARNING. S2 is a WARNING. However, S2 is a procedural watch-item, not a code-finding; if @dev's Phase 4 Round 1 deliverable includes the recommended base-sync evidence-string, S2 closes at Phase 4 and the combined path remains eligible at Phase 5 entry. Orchestrator decision: route based on whether @dev folds S2 into the Phase 4 commit-series header.

If S2 is NOT folded in, recommend running the standard `/audit` path at Phase 6 to spot-check that no scope creep occurred under the procedural-only base-sync rule.

## Verdict

**APPROVE-WITH-WATCH-ITEMS** — design is sound, all five OQs resolved bindingly, all three @architect critical findings independently verified PASS, all five threat-model surfaces clear or covered by binding constraints. Single WARNING is process-rigor (S2 base-sync evidence-string); three INFOs are forward-looking notes (S1 heading hygiene, S3 v2.4 SSRF flag-forward, S4 lock-file reader contract crisper).

No blocking findings. Phase 1 deliberation Round 1 from @security: **PROCEED**.
