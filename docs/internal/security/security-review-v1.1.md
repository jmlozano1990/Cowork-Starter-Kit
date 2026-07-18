# Security Review — cowork-starter-kit v1.1

## Phase: 2
## Date: 2026-04-15T22:00:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING | 2 | auth | `project-instructions-starter.txt` is LLM system context — malicious community preset payload is active on every session, not just wizard invocations; CONTRIBUTING.md PR checklist is v1.0 (missing v1.1 items) |
| S2 | WARNING | 2 | configuration | CI `starter-safety-rule-check` job must explicitly target `.txt` files — naive `**/*.md` glob will miss starter files entirely |
| S3 | INFO | 2 | external-api | `/skill-creator` dependency is UNTESTED — fallback path documented but external tool behavior unvalidated |
| S4 | INFO | 2 | auth | `/setup-wizard` reset confirmation relies on LLM instruction-following, not a technical gate — acceptable for this surface |
| S5 | INFO | 2 | ui | AskUserQuestion nudge is a best-effort heuristic — no security surface, noted for completeness |

---

### WARNING

- [ ] **S1 — CONTRIBUTING.md PR checklist is v1.0: missing v1.1 required items.** The v1.1 spec (F8) requires the CONTRIBUTING.md maintainer checklist to include: (1) `project-instructions-starter.txt` present, (2) starter file ≤300 words, (3) safety rule present in starter file verbatim, (4) all skills in `folder/SKILL.md` format (no flat `.md` skill files), (5) minimum file count, (6) "Try this now" prompts, (7) CI passes. The current CONTRIBUTING.md (v1.0) has only 5 checklist items — it checks for safety rule in `global-instructions.md` but has no awareness of starter files or skill format. Until this is updated, maintainers reviewing community PRs will not have the complete checklist. CI jobs from ADR-008 provide a machine-enforced backstop for items 1 and 3, but item 2 (word count) and the initial template validator (item 4) require human review. **Recommendation:** @dev must update CONTRIBUTING.md PR checklist to all 7 v1.1 items as part of Phase 4. This is not blocked by CI — it requires human maintenance discipline.

  **Elevated risk context:** `project-instructions-starter.txt` is meaningfully higher-trust than v1.0's WIZARD.md. As custom instructions (system context), it is active on every session message, not only during wizard invocations. A malicious payload in a merged community preset's starter file would run on every user conversation, not just at setup time. This increases the blast radius of a successful LLM injection via community PR compared to v1.0. The PR review checklist is the human gate — it must be complete.

- [ ] **S2 — CI `starter-safety-rule-check` job must target `.txt` files, not `.md` files.** ADR-008 specifies that the new `starter-safety-rule-check` job greps all 6 starter files for the canonical safety rule. Starter files are `project-instructions-starter.txt` — `.txt` extension, not `.md`. A grep command that globs `**/*.md` or uses markdown-specific tooling will silently miss these files, producing a false-pass result (the job reports success, but the starter files were never checked). **Recommendation:** @dev must implement the grep with a glob targeting `.txt` files specifically: `for f in presets/*/project-instructions-starter.txt; do grep -q "$SAFETY_RULE" "$f" || ...; done`. The job must explicitly iterate `presets/*/project-instructions-starter.txt` (direct path, not glob pattern expansion) to ensure all 6 files are checked even if a new preset is added without one. Consider also adding a count check: if fewer than 6 files are found, fail the job.

---

### INFO

- **S3 — `/skill-creator` dependency is UNTESTED.** The `project-instructions-starter.txt` instructs Cowork to run `/skill-creator` after the user activates a skill. This is a built-in Cowork tool that is explicitly logged as UNTESTED in `docs/assumptions.md`. Risks: (a) `/skill-creator` may be deprecated or renamed before v1.1 ships, (b) it may prompt for additional user input mid-wizard, disrupting the onboarding flow, (c) it may behave differently on skill content that already has the correct `folder/SKILL.md` format. The architecture correctly includes a fallback ("confirm file exists at `.claude/skills/<name>/SKILL.md`"). **Recommendation:** Test `/skill-creator` against a pre-built `folder/SKILL.md` skill file before Phase 4 commit to verify the confirm/improve (not repair) behavior. The fallback path must remain in all 6 onboarding scripts regardless of test outcome. Risk is UX/reliability, not a security vulnerability.

- **S4 — `/setup-wizard` reset confirmation is LLM-enforced, not technically gated.** The `/setup-wizard` SKILL.md instructs Cowork to ask "This will reset your profile and re-run onboarding. Your past sessions are unaffected. Confirm? (Yes / No)" before overwriting `cowork-profile.md`. This confirmation relies on the model following the instruction. There is no technical enforcement (no filesystem lock, no pre-commit hook, no double-confirm UI). This is structurally identical to the v1.0 safety rule — both rely on the LLM following its instructions. For a local desktop tool with no multi-user risk, this is acceptable. **Noted:** consistent with existing safety model. No action required.

- **S5 — AskUserQuestion nudge has no security surface.** The instruction "use AskUserQuestion to present options as clickable buttons if available" is a heuristic request to a built-in SDK feature. The worst case is that buttons do not render and the numbered list is used instead. There is no injection surface, no data disclosure risk, and no multi-user interaction. **Noted for completeness.** No action required.

---

### OWASP Top 10 Assessment (Adapted for Static Template Repository — v1.1 Delta)

| Category | Status | Notes |
|----------|--------|-------|
| A01:2021 — Broken Access Control | N/A | No access control system. Unchanged from v1.0. |
| A02:2021 — Cryptographic Failures | N/A | No cryptographic operations. Unchanged. |
| A03:2021 — Injection | WATCHED | LLM prompt injection surface has grown. `project-instructions-starter.txt` is now system context (active on every session), versus v1.0 WIZARD.md which was passive markdown. Blast radius of a malicious merged preset is higher. Mitigated by PR review (CONTRIBUTING.md — needs v1.1 update, S1) + CI enforcement (ADR-008). |
| A04:2021 — Insecure Design | PASS | Safety architecture strengthened in v1.1: safety rule now enforced in primary runtime surface (system context), not only in passive global-instructions. Four-layer defense-in-depth is more robust than v1.0. |
| A05:2021 — Security Misconfiguration | WATCHED | S2: CI `starter-safety-rule-check` must target `.txt` files. If misconfigured, the job silently passes while starter files go unchecked. |
| A06:2021 — Vulnerable & Outdated Components | N/A | No new action dependencies added in v1.1 CI jobs (ADR-008 uses native `run:` shell commands, not third-party actions). |
| A07:2021 — Identification & Authentication Failures | N/A | No auth system. Unchanged. |
| A08:2021 — Software & Data Integrity Failures | PASS | ADR-008 CI jobs enforce starter file presence and safety rule verbatim — machine-verifiable integrity check on the primary runtime surface. |
| A09:2021 — Security Logging & Monitoring Failures | N/A | No runtime system. Git history + CHANGELOG serve as audit trail. Unchanged. |
| A10:2021 — Server-Side Request Forgery | N/A | No server. Unchanged. |

### OWASP LLM Top 10 Assessment — v1.1 Delta

| Category | v1.0 Status | v1.1 Delta | Notes |
|----------|-------------|------------|-------|
| LLM01 — Prompt Injection | WATCHED | ELEVATED WATCH | Surface is now system context (always-on), not passive markdown. Same mitigations apply; blast radius is larger if a malicious preset merges. S1 (CONTRIBUTING.md update) is the key human control. |
| LLM02 — Insecure Output Handling | LOW RISK | UNCHANGED | Wizard output is local files only. No downstream system consumes output programmatically. |
| LLM06 — Sensitive Information Disclosure | LOW RISK | UNCHANGED | State machine check reads `cowork-profile.md` (user's own data). No data leaves the machine. No telemetry. |

---

### v1.0 Carry-Forwards Status

For reference: all v1.0 WARNINGs were resolved in Phase 4 and confirmed clean in Phase 6.

| ID | v1.0 Finding | v1.1 Status |
|----|-------------|-------------|
| S1 | CI safety-rule enforcement deferred | RESOLVED in v1.0 Phase 4 — CI job ships at v1. Extended to starter files in v1.1 ADR-008. |
| S2 | Unpinned GitHub Actions | RESOLVED in v1.0 Phase 4 — all actions SHA-pinned (confirmed in quality.yml). v1.1 adds no new third-party actions. |
| S3 | Shell script path validation | RESOLVED in v1.0 Phase 4 — path validation implemented in both scripts. Unchanged in v1.1. |

---

### Summary

v1.1 is a well-designed architecture with a materially stronger safety posture than v1.0. The primary security improvement is moving the safety rule into system context (`project-instructions-starter.txt`) — this makes it active on every session, not only during wizard invocations. The four-layer safety defense-in-depth (template → preset → starter file → CI) is the strongest this product has had.

Two findings require @dev attention:

**S1** is a human-process gap: CONTRIBUTING.md must be updated to the v1.1 PR checklist before the repo accepts community contributions. CI provides a machine-enforced backstop (ADR-008 jobs), but the human review checklist needs to match the new file surfaces. This is a straightforward documentation task with no implementation complexity.

**S2** is a CI correctness risk: the `starter-safety-rule-check` job must target `.txt` files, not markdown files. A misconfigured implementation silently passes while leaving starter files unchecked — this would be a false sense of security. The implementation must be verified against the actual file extension.

No CRITICAL findings. The `/skill-creator` dependency (S3) is acknowledged risk with a documented fallback — not a security concern. The reset confirmation (S4) and AskUserQuestion nudge (S5) are within acceptable parameters for this surface type.

**Decision: PASS WITH WARNINGS.** Two WARNINGs carry forward to Phase 4 implementation.
