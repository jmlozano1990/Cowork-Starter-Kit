# Compliance Review — Claude Cowork Config v2.5

## Phase: 2 (Pre-Build — COMPLIANCE-SENSITIVE, /legal before /design)
## Date: 2026-05-09T18:00:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Category | Surface | Description |
|----|----------|----------|---------|-------------|
| L1-1 | WARNING | L1-License | license | Outbound contribution model: MIT → MIT direction is clean, but inbound content contamination check on `meeting-notes` requires one explicit strip (writing-profile reference line 108) before submission |
| L1-2 | INFO | L1-License | license | `THIRD-PARTY-NOTICES.md` (ADR-025) tracks inbound content only; outbound contribution does not require a new entry — confirmed |
| L2-1 | INFO | L5-Trademark | branding | F2 `tools:` vocabulary tokens (claude-code, copilot, cursor, windsurf) are descriptive compatibility metadata — trademark fair-use applies |
| L3-1 | INFO | L3-ToS | api | No CLA or DCO requirement exists in upstream CONTRIBUTING.md; no copyright assignment requirement; open PR submission |
| L4-1 | INFO | L1-License | license | Upstream CONTRIBUTING.md "given credit in the agent file itself" recognition norm creates an optional attribution opportunity; no obligation to carry Cowork attribution in the skill file body, but PR description attribution is the correct and sufficient mechanism |
| L5-1 | INFO | L5-Trademark | branding | "Cowork" in PR copy: safe in descriptive attribution context; explicit boundary scoped below |
| L6-1 | INFO | L3-ToS | api | `content_sha256` integrity tracking (F1) is consistent with standard package-manager lock file precedent; no upstream notification required |

---

### CRITICAL

None.

---

### WARNING

**L1-1 — Inbound contamination check: `writing-profile` reference must be stripped before submission.**

The `meeting-notes` SKILL.md at `skills/meeting-notes/SKILL.md` contains a writing-profile integration section (lines 103–108) that references `context/writing-profile.md`. This is Cowork-specific infrastructure. The spec (AC-F3-3) already mandates: `grep -ciE "WIZARD|ADR-|cowork\.lock|selection-preset|skill-depth|sync-agency|writing-profile" upstream-contribution/meeting-notes-upstream.md` = 0.

However, the compliance concern is upstream-facing, not just a grep gate: a contributed skill that contains references to private infrastructure (even in a non-executable prose section) would either (a) confuse upstream users who do not have `context/writing-profile.md`, or (b) require a rewrite of that section for the contribution to be genuinely useful to the upstream community. The spec notes this is already required ("1 optional writing-profile reference, line 108, contextual — easily stripped"). This WARNING is a confirmation and binding instruction: the upstream-format rewrite (`upstream-contribution/meeting-notes-upstream.md`) MUST NOT include the writing-profile integration section in any form. The reformatted version should represent the core skill functionality as a standalone tool.

**Assessment:** The strip is straightforward — this section has zero functional role in the upstream persona-centric format (which has no writing-profile concept). The content risk is low; the action is mandatory.

**Bind to Phase 4:** AC-F3-3 already encodes this requirement. @dev must verify the rewrite excludes the section entirely, not just the filename reference.

---

### INFO

**L1-2 — THIRD-PARTY-NOTICES.md does not require an outbound contribution entry.**

ADR-025 scopes `THIRD-PARTY-NOTICES.md` to inbound content: third-party sources whose content is distributed through the Cowork wizard. An outbound contribution (Cowork-authored content submitted to an upstream repo) is the inverse: Cowork is the originating party, not the receiving party. No new third-party entry is required in `THIRD-PARTY-NOTICES.md` for F3. The spec's Technical Constraints section correctly states this. Confirmed — no action required.

---

**L2-1 — F2 `tools:` vocabulary tokens are descriptive compatibility metadata; trademark fair-use applies.**

The closed vocabulary `[claude-code, copilot, cursor, windsurf]` in SKILL.md frontmatter functions as compatibility metadata, directly analogous to `os: linux` in CI config files or `engines: { node: ">=18" }` in `package.json`. This is descriptive use of marks to identify the tools a skill has been validated with — not use in commerce, not endorsement-implying branding, not a service/product name for Cowork.

Trademark analysis per token:
- **claude-code**: Anthropic product name. Descriptive use in a `tools:` compatibility field does not imply Anthropic endorsement of Cowork or of the specific skill. Cowork is already publicly associated with Claude Code usage (its primary use case). The token is identifying, not endorsing.
- **copilot**: GitHub Copilot product name (Microsoft). Same analysis — compatibility metadata.
- **cursor**: Cursor product name (Anysphere). Same analysis.
- **windsurf**: Codeium Windsurf product name (Codeium/Windsurf). Same analysis.

None of these tokens appear in Cowork marketing copy, README promotional sections, or user-facing product claims. They appear in YAML frontmatter as a machine-readable vocabulary list. Trademark fair-use for descriptive/referential use applies.

**One boundary to maintain:** If v3.0 introduces tool-aware routing copy (e.g., "Recommended for Copilot users"), the framing must remain descriptive ("works with Copilot") rather than endorsement-implying ("Copilot-certified" or "official Copilot skills"). This is forward-looking guidance, not a v2.5 action item.

No action required for v2.5.

---

**L3-1 — Upstream CONTRIBUTING.md: no CLA, no DCO, no copyright assignment requirement.**

The upstream `msitarzewski/agency-agents` CONTRIBUTING.md (fetched at current HEAD; 14,305 bytes) was reviewed in full. Findings:

- **No CLA (Contributor License Agreement):** No CLA bot, no CLA signing requirement, no CLA text anywhere in the document.
- **No DCO (Developer Certificate of Origin):** No `git commit -s` sign-off requirement, no DCO-1.1 reference, no sign-off checkbox in the PR template.
- **No copyright assignment:** No provision requiring contributors to assign copyright to the maintainer or to any entity.
- **PR process:** Fork → branch (`git checkout -b add-agent-name`) → commit → push → open PR. Title format: `"Add [Agent Name] - [Category]"`. PR template checklist: structure, personality, examples, metrics, workflow, proofreading, testing. No legal checklist items.
- **What belongs in a PR:** "Adding a new agent (one `.md` file)" is listed as "Always welcome as a PR." This is Cowork's exact scenario.
- **Recognition:** "Contributors who make significant contributions will be: Listed in README acknowledgments section / Given credit in the agent file itself." This is a norm, not a requirement — the upstream maintainer may optionally credit contributors in the file, but there is no obligation on the contributor to include their own attribution.

**Governance handoff conclusion:** Post-merge ownership of the contributed file transfers to the upstream repo under the upstream's MIT license and contribution norms. No CLA means contributors retain copyright by default; the submission is an implicit grant to distribute the content under the upstream's MIT license. The upstream maintainer may merge, modify, or reject without further obligation to the contributor. This is standard open-source contribution posture.

**Who submits:** The PR should be opened from the project maintainer's GitHub account (lozano1.990@gmail.com-associated account, or whichever account owns the Cowork repo). No special requirements.

No action required beyond the standard PR submission.

---

**L4-1 — Attribution direction: PR description is the correct and sufficient mechanism for Cowork attribution.**

The upstream CONTRIBUTING.md notes contributors "may be given credit in the agent file itself" — this is a maintainer-discretionary act, not a contributor obligation. The question for v2.5 is: what attribution language survives the reformat, where does it live, and is any of it mandatory?

**Assessment of attribution direction:**

ADR-024 governs inbound attribution (agency-agents content → Cowork user workspaces). It does not apply to outbound contributions. The spec Technical Constraints section correctly states: "The upstream contribution (F3) does NOT use the ADR-024 attribution block — upstream files follow upstream's format."

For the outbound direction, the MIT license governs. Cowork's `meeting-notes` skill is original work authored for cowork-starter-kit, owned by "The cowork-starter-kit contributors" (LICENSE file). When contributed to agency-agents, the work is offered under the MIT license. The contributor retains copyright; the upstream receives a distribution right.

**What attribution survives the reformat:**

The upstream-format file (`upstream-contribution/meeting-notes-upstream.md`) follows upstream's persona-centric format. This format does not include an attribution block field in YAML frontmatter or in the file body (the upstream template uses: `name`, `description`, `tools`, `color`, `emoji`, `vibe` — no `source` or `attribution` field). The upstream recognition norm ("given credit in the agent file itself") is discretionary and maintainer-driven.

**Conclusion — the attribution policy for F3:**

1. **Skill file body and frontmatter:** No Cowork attribution block required or appropriate. The file follows upstream format conventions. Adding a non-standard attribution block to the body would make the contribution non-conforming and may reduce merge likelihood.
2. **PR description (required):** The PR description MUST carry the attribution line: "Originally authored for [cowork-starter-kit](https://github.com/[repo-url]) and adapted to The Agency format." This satisfies the spirit of contribution transparency and starts the relationship on an honest footing without violating upstream format conventions.
3. **CHANGELOG entry (per AC-F3-2):** `Upstream contribution: [PR URL] — meeting-notes skill submitted to project-management category` is the correct Cowork-side record. This is internal to Cowork's documentation.
4. **Cowork `upstream-contribution/meeting-notes-upstream.md`:** As a tracked artifact in the Cowork repo, this file may optionally carry a comment at the top: `# This file was authored for cowork-starter-kit and submitted to msitarzewski/agency-agents as a PR contribution.` This is a Cowork-internal tracking note, not injected into the upstream PR.

**Copy-pasteable PR description template:**

```markdown
## Agent Information
**Agent Name**: Meeting Notes Specialist
**Category**: project-management
**Specialty**: Extract structured decisions, action items, and open questions from meeting transcripts or rough notes into a clean 4-section summary.

## Motivation
Meeting notes extraction is a common knowledge-worker task that benefits from a structured, consistent output format. This agent enforces a strict 4-section schema (Date/Attendees, Decisions, Action Items, Open Questions) and is designed to process input as data — not as instructions — reducing prompt-injection risk.

## Testing
Tested across rough bullet-point notes, formal transcripts, and voice-memo summaries. The 4-section schema handles sparse inputs gracefully ([None recorded] where a section has no content).

## Checklist
- [x] Follows agent template structure
- [x] Includes personality and voice
- [x] Has concrete template examples
- [x] Defines success metrics
- [x] Includes step-by-step workflow
- [x] Proofread and formatted correctly
- [x] Tested in real scenarios

---
*Originally authored for [cowork-starter-kit](https://github.com/JmLozano/claude-cowork-config) and adapted to The Agency format.*
```

**Copy-pasteable commit message for the upstream PR branch:**

```
Add Meeting Notes Specialist - project-management

Extracts structured decisions, action items, and open questions from
meeting transcripts and rough notes into a 4-section schema.

Originally authored for cowork-starter-kit. Adapted to The Agency
persona-centric format.
```

---

**L5-1 — "Cowork" in PR copy: safe in attribution/descriptive context; explicit scope boundary.**

The PR description template above uses "cowork-starter-kit" once, in an attribution line at the bottom. This is descriptive use in a contribution context — identifying the origin of the work, not claiming endorsement, not making a competitive claim, and not implying Anthropic affiliation.

The WILL-NOT-DO list in the spec (item 11) correctly states: "Upstream repository names, tool names, or maintainer identifiers MUST NOT appear in README, CHANGELOG promotional copy, SETUP-CHECKLIST, or any user-facing surface." The F3 attribution context is explicitly exempt from the `no-competitor-naming-public` memory rule (feedback `feedback_no_competitor_naming_public.md`) because:

1. **Outbound contribution is inherent acknowledgment, not competitive positioning.** The PR description names `cowork-starter-kit` as the source of the contribution. This is attribution, not a competitive claim.
2. **The memory exemption for attribution context applies explicitly.** The memory rule targets public copy (README, CHANGELOG promotional sections, marketing). The PR description on a third-party repo, and `docs/architecture.md` / `THIRD-PARTY-NOTICES.md` / `docs/spec.md` are all explicitly permitted surfaces.

**Scope of this exemption — binding for Phase 4:**

| Surface | "msitarzewski/agency-agents" | "cowork-starter-kit" |
|---------|------------------------------|----------------------|
| PR title | PERMITTED (naming the target repo) | PERMITTED (attribution line) |
| PR description body | PERMITTED (naming the target repo) | PERMITTED (attribution line only, at bottom) |
| `upstream-contribution/meeting-notes-upstream.md` (body) | OMIT | OMIT (follow upstream format) |
| Cowork `docs/architecture.md` F3 implementation note | PERMITTED | PERMITTED |
| Cowork `CHANGELOG.md` v2.5.0 section | PERMITTED (PR URL contains repo path) | PERMITTED (release note) |
| Cowork `THIRD-PARTY-NOTICES.md` | N/A (no new inbound entry) | N/A |
| Cowork `README.md` | OMIT (no promotional mention) | PERMITTED (own name) |
| Cowork `SETUP-CHECKLIST` | OMIT | N/A |

This exemption does NOT extend to: blog posts, LinkedIn announcements, README feature bullets, or SETUP-CHECKLIST language. Those surfaces follow the full `no-competitor-naming-public` rule.

---

**L6-1 — F1 `content_sha256` integrity tracking: no upstream notification required.**

The `content_sha256` field in `cowork.lock.json` records a hash of the fetched file content at a pinned commit. This is a standard package-manager lock pattern (npm `package-lock.json`, Go `go.sum`, Cargo `Cargo.lock`). None of these patterns require notification to upstream maintainers that their content is being integrity-tracked.

There is no requirement in the upstream CONTRIBUTING.md, README, or LICENSE that addresses downstream integrity tracking of fetched content. The upstream MIT license places no restriction on how downstream consumers choose to verify content integrity.

No action required.

---

## Section 1: License Compatibility Verdict

**MIT → MIT outbound: CLEAN.**

Cowork's `meeting-notes` skill is original work authored by the cowork-starter-kit contributors. The skill's content is not derived from any upstream agency-agents file (it was authored independently for the Cowork PM preset in v1.3.3). The upstream `agency-agents` repo is MIT-licensed (confirmed: `Copyright (c) 2025 AgentLand Contributors`). Contributing original MIT-compatible work to an MIT-licensed repo creates no license conflict.

**Inbound contamination check result:**

The `meeting-notes` SKILL.md at `skills/meeting-notes/SKILL.md` contains:
- 9-section Cowork template structure (instructions, triggers, output format, quality criteria, anti-patterns, example, writing-profile integration, example prompts) — this structure is Cowork-internal format; it is reformatted for the upstream submission, so structural entanglement does not transmit.
- 1 writing-profile reference (lines 103–108, "Writing-profile integration" section) — this is the sole Cowork-specific infrastructure reference. It MUST be omitted from the upstream submission. AC-F3-3 already encodes this requirement.
- 0 ADR references, 0 wizard references, 0 sync-agency references, 0 lock file references.

**Verdict:** The `meeting-notes` content is clean for contribution after the writing-profile section is excluded. No other skill content in the Cowork pool has been incorporated into the upstream-format version (the contribution is a structural rewrite, not a copy). MIT → MIT: PASS.

---

## Section 2: Attribution Direction Policy

**Summary verdict:** PR description attribution is sufficient. Skill file body follows upstream format without Cowork attribution block.

See **L4-1** above for full policy rationale, copy-pasteable PR description template, and commit message template.

**Binding AC linkage:**

| AC | Requirement | Compliance requirement |
|----|-------------|----------------------|
| AC-F3-1 | Upstream-format file exists with correct frontmatter | No attribution block in frontmatter or body — confirmed appropriate |
| AC-F3-3 | No Cowork-specific terms in upstream file | writing-profile reference must be stripped (WARNING L1-1) |
| AC-F3-2 | CHANGELOG records PR URL | Attribution context permitted in CHANGELOG (INFO L5-1) |
| AC-F3-4 | PR URL in architecture.md | Attribution context permitted in architecture.md (INFO L5-1) |

---

## Section 3: Governance Handoff

**CLA/DCO:** None required. Upstream `CONTRIBUTING.md` has no CLA, no DCO sign-off requirement, no copyright assignment provision. Reviewed at current HEAD (sha `10bbac4447e0c2bd06f32b870e88d02f7b06a77d`, 14,305 bytes). No legal preconditions to opening a PR.

**Copyright:** Cowork contributors retain copyright on the contributed content. The contribution is an implicit grant to distribute under the upstream's MIT license. No copyright transfer occurs.

**Post-merge ownership:** After merge (if accepted), the upstream maintainer may modify, rename, or remove the file under the upstream's own contribution and governance norms. Cowork retains the original in `upstream-contribution/meeting-notes-upstream.md` and `skills/meeting-notes/SKILL.md` as its canonical copies. There is no obligation on either party post-merge.

**Who submits:** The PR should be submitted from the project owner's GitHub account. No special account or bot account needed.

**v3.0 trigger clock:** Starts at PR open date. 60-day acknowledgment window begins. The v3.0 gate evaluates acknowledgment outcome — PR rejection is a valid outcome that satisfies AC-F3-5 (valid PR URL).

**Project-management category:** Confirmed to exist at upstream (`project-management/` directory contains 6 files: `project-management-experiment-tracker.md`, `project-management-jira-workflow-steward.md`, `project-management-project-shepherd.md`, `project-management-studio-operations.md`, `project-management-studio-producer.md`, `project-manager-senior.md`). No duplicate for meeting-notes extraction exists. Contribution is additive.

**Bulk-modification note:** The upstream CONTRIBUTING.md explicitly states: "PRs that bulk-modify existing agents without a prior discussion — even well-intentioned reformatting — can create merge conflicts for other contributors" are among "things we'll always close." Cowork's F3 PR adds ONE new file to the `project-management/` category. This is squarely within "Always welcome as a PR." No discussion prerequisite required.

---

## Section 4: Trademark

**"Cowork" in PR copy:** Safe in descriptive attribution context. See INFO L5-1 for full analysis and scope boundary table.

**F2 vocabulary tokens:** All four tokens (`claude-code`, `copilot`, `cursor`, `windsurf`) are descriptive compatibility metadata. Trademark fair-use applies. See INFO L2-1 for full analysis.

**"Claude" in repo name / product references:** The v1.0 WARNING (L2) was resolved by the rename to `cowork-starter-kit` (confirmed in v2.0 review, L5-2 INFO). No residual concern for v2.5. The repo name `claude-cowork-config` (the Council-side project slug) is not a public-facing artifact — the public GitHub repo is `cowork-starter-kit` or equivalent. Confirm the public repo name does not embed "Claude" before v2.5 launch.

---

## Section 5: Public-Copy Hygiene Exemption

**Explicit ruling:** The F3 outbound contribution context is EXEMPT from the `no-competitor-naming-public` memory rule (`feedback_no_competitor_naming_public.md`).

**Basis:** The rule prohibits naming specific competing vaults, plugins, or creators in public copy (README, marketing, positioning). The upstream `agency-agents` repo is not a "competing vault or plugin" — it is the upstream source from which Cowork draws content and to which Cowork is contributing back. Naming it in a contribution PR is inherent to the contribution act, not competitive positioning.

**Exemption scope (binding for Phase 4):**

PERMITTED surfaces for naming `msitarzewski`, `agency-agents`, `cowork-starter-kit` in F3 context:
- F3 PR title, description, and commit message on the upstream repo
- `docs/architecture.md` F3 implementation note
- `CHANGELOG.md` v2.5.0 section (PR URL record per AC-F3-2)
- `docs/spec.md` (already present, already internal)
- `THIRD-PARTY-NOTICES.md` (already present, inbound tracking)

NOT PERMITTED (rule applies in full):
- `README.md` promotional copy, feature bullets, or "built on" framing
- `SETUP-CHECKLIST.md`
- `CONTRIBUTING.md` user-facing sections
- Any LinkedIn, blog, or social media post
- Release notes / GitHub Release description body (public marketing surface)

This exemption is scoped to F3 attribution context only. It does not generalize to other features or future cycles.

---

## Section 6: MUST-FIX for Phase 4

Bound to spec ACs. These are compliance requirements, not security findings.

| ID | Bound to | Requirement | Verification |
|----|---------|-------------|-------------|
| CF-L1-1 | AC-F3-3 | `upstream-contribution/meeting-notes-upstream.md` MUST NOT contain the writing-profile integration section in any form. Strip entirely; do not rephrase as a general "output style" note. | `grep -i "writing.profile\|writing profile\|writing_profile" upstream-contribution/meeting-notes-upstream.md` = 0 |
| CF-L4-1 | AC-F3-2 (PR description) | The PR description submitted to `msitarzewski/agency-agents` MUST include the attribution line: "Originally authored for [cowork-starter-kit]([URL]) and adapted to The Agency format." Record the exact PR URL in CHANGELOG and architecture.md per ACs F3-2 and F3-4. | PR description reviewed by @qa at Phase 5; URL recorded per AC-F3-2 and AC-F3-4 |

---

## Section 7: SHOULD-FIX Recommendations (Non-Blocking)

| ID | Recommendation | Rationale |
|----|---------------|-----------|
| SF-1 | Add a comment at the top of `upstream-contribution/meeting-notes-upstream.md` (the Cowork-tracked copy only, not the file submitted upstream) noting: "This file was authored for cowork-starter-kit and submitted to msitarzewski/agency-agents. The Cowork canonical version is at skills/meeting-notes/SKILL.md." | Provenance tracking for future maintainers who find the file without context. Low cost, high clarity. |
| SF-2 | @dev should author the upstream-format version's "Critical Rules" section to include the pasted-content-is-data rule (from v1.3.3 S1 carry-forward, already present in the Cowork version's anti-patterns). The upstream community benefits from the LLM01-aware design; it improves the PR's reception and reflects Cowork's supply-chain hygiene positioning. | The anti-pattern is in the Cowork version (## Anti-patterns, last bullet). Including it in the upstream contribution demonstrates quality. Not a compliance requirement; a quality recommendation. |
| SF-3 | If the upstream PR receives reviewer feedback requesting changes before v2.5 Phase 7 approval, @qa should not block Phase 7 on the basis of PR content changes — only on the basis of AC-F3-5 (valid PR URL). Revision requests from upstream maintainers are a normal contribution workflow event and do not constitute a v2.5 failure. | Prevent @qa from mis-scoping the PR outcome evaluation. |

---

## Section 8: Verdict

**PASS WITH WARNINGS**

**0 CRITICAL · 1 WARNING · 6 INFO**

**Proceed to `/design` (@architect Phase 1).** Combined-path remains NOT eligible (SECURITY-SENSITIVE lock from spec classification).

The v2.5 compliance surface is well-managed. The outbound contribution model (MIT → MIT) is legally clean. The upstream has no CLA, no DCO, and no IP transfer requirements — the contribution is a simple PR with implicit MIT grant. The one WARNING (L1-1) is already encoded as a Phase 4 AC (AC-F3-3) and requires only that @dev omit the writing-profile integration section from the upstream-format rewrite, which the spec anticipates. No architecture changes are required to proceed.

---

## Skills Run

| Skill | Triggered | Status |
|-------|-----------|--------|
| L1: License Scan | Yes — outbound MIT contribution + F2 frontmatter vocab | WARN (L1-1) |
| L2a: GDPR | No — no telemetry, analytics, or API sending user data | SKIP |
| L2b: Privacy Notice | No — L2a did not trigger | SKIP |
| L3: API ToS | No — no Anthropic/OpenAI API usage; GitHub ToS standard PR | SKIP |
| L4: Obsidian Plugin | No — not an Obsidian plugin | SKIP |
| L5: Trademark | Yes — F2 vocabulary tokens + "Cowork" in PR copy + upstream naming | INFO |
| C1: ISO 27001 | No — out of scope per task brief | SKIP |
| C2: SOC 2 | No — out of scope per task brief | SKIP |
| C3: HIPAA | No — no PHI, not a covered entity | SKIP |
| C4: GDPR Operational | No — L2a did not trigger | SKIP |

---

*This review is compliance triage, not legal advice. Findings marked WARNING should be reviewed by the project owner before implementation. The attribution templates above are drafts for review — confirm the final PR description with the project owner before submission.*
