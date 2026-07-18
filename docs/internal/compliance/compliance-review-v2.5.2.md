# Compliance Review — Claude Cowork Config v2.5.2

## Phase: 2 (Pre-Build — COMPLIANCE-SENSITIVE, /legal before /design)
## Date: 2026-05-10T00:00:00Z
## Status: PASS WITH MUST-FIX

---

## Findings Summary

| ID | Severity | Category | Surface | Description |
|----|----------|----------|---------|-------------|
| L1-1 | WARNING | L1-License | license | `skills/prompt-gate/SKILL.md` must carry a content-equivalent attribution block to the addyosmani/agent-skills MIT source; spec AC-D2-6 already mandates this, but the exact format and content must match the MIT "permission notice" requirement — confirmed below |
| L1-2 | WARNING | L1-License | license | `THIRD-PARTY-NOTICES.md` (ADR-025) currently tracks only `msitarzewski/agency-agents` (inbound). The prompt-gate pattern is a second distinct inbound MIT source (`addyosmani/agent-skills`). A new entry is required in `THIRD-PARTY-NOTICES.md` before Phase 4 ships the skill |
| L1-3 | INFO | L1-License | license | License compatibility verdict: cowork MIT + addyosmani/agent-skills MIT — CLEAN. No conflict |
| L1-4 | INFO | L1-License | license | Same-author context (JmLozano owns both repos) does not waive the MIT attribution obligation; attribution must survive regardless of author identity |
| L1-5 | INFO | L1-License | license | Derived-work scope: the 4-phase context-enrichment pattern (Phases 1-4) is the licensed material; all Cowork-specific prose (pipeline references, registry lookups, AskUserQuestion integration) is original adaptation |
| L5-1 | INFO | L5-Trademark | branding | D-2 skill prose describes Cowork pipeline commands and tools: references — no competitor naming detected; existing `no-competitor-naming-public` rule satisfied |

---

### CRITICAL

None.

---

### WARNING

**L1-1 — Attribution block in `skills/prompt-gate/SKILL.md` must satisfy MIT "permission notice" requirement.**

The-Council's prompt-gate SKILL.md carries the following attribution at its footer:

```
> *Pattern from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
> `skills/context-engineering/SKILL.md` @ commit `9534f44c5448086fcc0046f9d83752c654c81930`
> — Copyright (c) Addy Osmani, MIT License. See `docs/ATTRIBUTIONS.md`.*
```

The MIT license requires: *"The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."* The Council's current attribution carries the copyright notice and source link but defers the full permission text to `docs/ATTRIBUTIONS.md`. This is acceptable within The-Council because that ATTRIBUTIONS.md carries the full MIT permission text for the addyosmani/agent-skills entry (confirmed: row present in The-Council's ATTRIBUTIONS.md table).

**For cowork, the ATTRIBUTIONS.md equivalent is `THIRD-PARTY-NOTICES.md`.** Cowork does not have a machine-parseable attribution table like The-Council's `ATTRIBUTIONS.md`. This means the "see ATTRIBUTIONS.md" reference in the skill footer cannot defer to an equivalent document that carries the full permission text — unless `THIRD-PARTY-NOTICES.md` is updated to include the addyosmani entry (see L1-2).

**Two compliant options for the skill file footer (choose one):**

**Option A — Full embedded notice (most conservative, precedent from v2.0 L1-1 review):**

```markdown
> *Pattern from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
> `skills/context-engineering/SKILL.md` @ commit `9534f44c5448086fcc0046f9d83752c654c81930`.
> Copyright (c) Addy Osmani. Licensed under the MIT License.
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files, to deal in the Software
> without restriction, including without limitation the rights to use, copy,
> modify, merge, publish, distribute, sublicense, and/or sell copies of the
> Software, and to permit persons to whom the Software is furnished to do so,
> subject to the following conditions: The above copyright notice and this
> permission notice shall be included in all copies or substantial portions of
> the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.*
```

**Option B — Condensed notice with THIRD-PARTY-NOTICES.md reference (acceptable if L1-2 is also resolved):**

```markdown
> *Pattern from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
> `skills/context-engineering/SKILL.md` @ commit `9534f44c5448086fcc0046f9d83752c654c81930`
> — Copyright (c) Addy Osmani, MIT License.
> See `THIRD-PARTY-NOTICES.md` for full license text.*
```

Option B requires that `THIRD-PARTY-NOTICES.md` is updated with the addyosmani entry (L1-2 MUST-FIX). Option A is self-contained and does not depend on L1-2 being resolved first. For a project whose positioning is built on supply-chain hygiene, Option A is the recommended choice.

**Note on spec AC-D2-6:** The spec already mandates that the attribution block be "matching the format used in The-Council's prompt-gate SKILL.md." The-Council's format (Option B pattern) is acceptable only because The-Council's `docs/ATTRIBUTIONS.md` carries the full permission text. In cowork, the equivalent is either Option A (self-contained) or Option B + L1-2 resolution (THIRD-PARTY-NOTICES.md updated). Either approach satisfies the MIT requirement.

**Phase 4 binding:** @dev must implement either Option A or Option B (with L1-2 resolved). The choice should be confirmed by @architect at Phase 1. The attribution block in the shipped `skills/prompt-gate/SKILL.md` must satisfy whichever option is selected.

---

**L1-2 — `THIRD-PARTY-NOTICES.md` requires a new entry for `addyosmani/agent-skills`.**

`THIRD-PARTY-NOTICES.md` (ADR-025) currently contains one entry: `msitarzewski/agency-agents`. That entry tracks inbound content distributed through the Cowork wizard. The `addyosmani/agent-skills` pattern ported in D-2 is a second distinct inbound MIT source — a pattern (the 4-phase context-enrichment workflow) that is incorporated into a skill file distributed to users.

ADR-025 scopes the file to "content from third-party sources under their original licenses." The 4-phase pattern is third-party content incorporated into a Cowork-distributed skill file. It requires a `THIRD-PARTY-NOTICES.md` entry.

**Required minimum entry:**

```markdown
## addyosmani/agent-skills

- **Source:** <https://github.com/addyosmani/agent-skills>
- **License:** MIT
- **Copyright:** Copyright (c) Addy Osmani
- **Pinned commit:** 9534f44c5448086fcc0046f9d83752c654c81930
- **Source file:** skills/context-engineering/SKILL.md

### Content incorporated

The 4-phase context-enrichment pattern (Context Check → Codebase Research →
Clarifying Questions → Execute) incorporated into `skills/prompt-gate/SKILL.md`.
This is a structural pattern, not a verbatim copy. Original prose is authored
for cowork-starter-kit; the pattern design is MIT-licensed source material.

### Full License Text

MIT License

Copyright (c) Addy Osmani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**ADR-025 compatibility note:** `THIRD-PARTY-NOTICES.md` is flagged as "regenerated automatically by sync-agency.yml on every upstream SHA bump." The addyosmani entry is NOT managed by sync-agency.yml (it is not distributed via the wizard; it is incorporated directly into a SKILL.md). @architect must determine whether ADR-025 should be amended to cover directly-incorporated patterns alongside wizard-distributed content, or whether a separate attribution section is added to the file under a "Direct pattern incorporations" heading. Either approach satisfies the MIT requirement. This is a Phase 1 design question.

**Phase 4 binding:** `THIRD-PARTY-NOTICES.md` must contain the addyosmani/agent-skills entry before Phase 4 ships. The exact format (amendment to existing file under a new heading vs. inline entry) is @architect's decision at Phase 1.

---

### INFO

**L1-3 — License compatibility: MIT → MIT — CLEAN.**

Cowork's `LICENSE` file (confirmed present, MIT, "Copyright (c) 2026 The cowork-starter-kit contributors") is fully compatible with `addyosmani/agent-skills` (MIT, Copyright (c) Addy Osmani). MIT is permissive and bidirectionally compatible with itself. There is no copyleft conflict, no license incompatibility, and no relicensing requirement.

The ported material is a structural pattern (4-phase workflow), not a verbatim copy of the source SKILL.md. The original prose in cowork's `skills/prompt-gate/SKILL.md` will adapt the pattern to Cowork's pipeline context (registry.json, pipeline.md, scratchpad.md references rather than The-Council's internal paths). The distinction between licensed material (the pattern structure) and original adaptation (the Cowork-specific prose) is clean and well-defined by the spec.

No action required.

---

**L1-4 — Same-author context does not waive MIT attribution obligation.**

Both repos (The-Council and cowork-starter-kit) are owned by the same author (JmLozano / lozano1.990@gmail.com). The `addyosmani/agent-skills` pattern was originally adopted into The-Council under MIT attribution (entry at commit `9534f44c5448086fcc0046f9d83752c654c81930`; The-Council's ATTRIBUTIONS.md row dated 2026-04-17). The cowork port is an additional downstream use of the same MIT-licensed material.

Same-author ownership of the intermediate work (The-Council) does not change the attribution obligation for the original MIT source (addyosmani/agent-skills). The attribution obligation runs from the MIT licensor (addyosmani) to any downstream redistributor (cowork), not from licensor to intermediate holder only. Attribution must survive each redistribution step regardless of author identity at intermediate steps.

This is a confirmation finding, not a new risk. The spec already states this correctly ("same author both repos, but attribution preservation required"). No action beyond the MUST-FIX items above.

---

**L1-5 — Derived-work scope: what is licensed vs. what is original.**

For the record, to assist @architect and @dev at Phases 1 and 4:

**Licensed material (MIT attribution required):**
- The 4-phase structure: Context Check → Codebase Research → Clarifying Questions → Execute
- The decision logic at each phase boundary (fully resolve → skip to Execute; partially resolve → proceed to next phase)
- The "max 3 questions" constraint as a structural design element of Phase 3
- The Context Hierarchy concept (Level 1 most trusted → Level 5 least trusted) — this appears in The-Council's SKILL.md and originates from the source

**Original Cowork adaptation (no attribution required for this material):**
- All prose describing Cowork-specific state files (registry.json, pipeline.md, scratchpad.md)
- References to `/spec`, `/design`, `/implement`, `/test` pipeline commands
- AskUserQuestion integration details
- curated-skills-registry.md and global-instructions references
- Any Cowork-specific examples, AC verification language, or persona references

@dev should draft the skill body as original Cowork prose throughout, with the pattern attribution block at the footer. The licensed element is the structural design; the prose is original.

---

**L5-1 — No competitor naming detected in D-2 or D-3 scope.**

The D-2 prompt-gate skill describes a pipeline-aware clarification workflow. The D-3 correcting-course rule establishes a correction form. Neither feature introduces references to competing vault frameworks, plugins, or creator names. The `tools:` frontmatter field for the new skill will carry `[claude-code]` (matching all 20 existing skills in the v2.5.0 pool). No trademark or competitor-naming concerns apply.

The `no-competitor-naming-public` memory rule (`feedback_no_competitor_naming_public.md`) is not triggered by either D-2 or D-3 scope as specified.

No action required.

---

## Section 1: License Compatibility Verdict

**MIT → MIT port: CLEAN.** No license conflict. Attribution is required (MIT condition) but there is no copyleft barrier, no relicensing requirement, and no incompatibility between cowork's project license and the source material's license.

---

## Section 2: Attribution Surface Map

The v2.5.2 attribution obligation covers two surfaces:

| Surface | Required action | Bound to |
|---------|----------------|---------|
| `skills/prompt-gate/SKILL.md` footer | Attribution block — Option A (self-contained) or Option B (THIRD-PARTY-NOTICES.md reference) | AC-D2-6 |
| `THIRD-PARTY-NOTICES.md` | New addyosmani/agent-skills entry with full MIT license text | MUST-FIX CF-L1-2 |

If Option B is chosen for the skill file footer, BOTH surfaces are required. If Option A is chosen, the skill file is self-contained and THIRD-PARTY-NOTICES.md update is a belt-and-suspenders addition (still recommended for the product's supply-chain hygiene positioning, but the MIT requirement is satisfied by Option A alone).

---

## Section 3: Same-Author, Cross-Repo Port — Policy Statement

This is the first time the Cowork project has ported a pattern from The-Council (also owned by JmLozano). For the record, the policy applicable to future same-author cross-repo ports:

1. If the ported material itself incorporates MIT-licensed third-party content (as here — The-Council's prompt-gate traces to addyosmani/agent-skills), the MIT attribution obligation carries through all downstream ports, regardless of intermediate author identity.
2. If the ported material is 100% original The-Council work with no third-party attribution chain, no external attribution is required (same-author transfer has no attribution duty).
3. The determination of which case applies requires reading the source SKILL.md attribution footer before porting.

This policy requires no ADR at v2.5.2 (it is compliance guidance, not an architectural decision). @architect may choose to record it as an operational note in ADR-025 or a new ADR if it is expected to recur.

---

## Section 4: MUST-FIX for Phase 4

Bound to spec ACs. These are compliance requirements, not security findings.

| ID | Bound to | Requirement | Verification |
|----|---------|-------------|-------------|
| CF-L1-1 | AC-D2-6 | `skills/prompt-gate/SKILL.md` must carry a compliant MIT attribution block (Option A or Option B — see L1-1 above). Option B requires CF-L1-2 to be resolved first. | `grep -c "addyosmani\|agent-skills\|9534f44" skills/prompt-gate/SKILL.md` >= 2 (commit SHA + copyright/source URL both present) |
| CF-L1-2 | THIRD-PARTY-NOTICES.md | `THIRD-PARTY-NOTICES.md` must contain a new section for `addyosmani/agent-skills` with full MIT license text. See L1-2 for required content. | `grep -c "addyosmani" THIRD-PARTY-NOTICES.md` >= 1; `grep -c "9534f44" THIRD-PARTY-NOTICES.md` >= 1 |

---

## Section 5: SHOULD-FIX Recommendations (Non-Blocking)

| ID | Recommendation | Rationale |
|----|---------------|-----------|
| SF-1 | @architect should record the cross-repo attribution policy (Section 3 above) as an operational note in `docs/architecture.md` — either as an amendment to ADR-025 or as a standalone note in the v2.5.2 implementation record. | Establishes precedent for future same-author cross-repo ports. Without this note, a future agent may incorrectly assume same-author ports require no attribution check. |
| SF-2 | If Option B is chosen for the skill file footer, the `THIRD-PARTY-NOTICES.md` header text should be updated to note that the file covers both wizard-distributed inbound content (ADR-025 scope) AND directly-incorporated pattern material (new as of v2.5.2). | Prevents a future agent from reading the current header and concluding the addyosmani entry is out of scope. |
| SF-3 | @dev should verify that the 4-phase workflow in the ported SKILL.md uses original Cowork-specific prose throughout — no verbatim copy of The-Council's SKILL.md text beyond the pattern structure. This is a quality recommendation, not a legal requirement (MIT permits verbatim reuse with attribution), but original prose is preferred for differentiation. | Avoids any confusion about whether the Cowork skill is a copy vs. an original adaptation. |

---

## Section 6: Phase 3 User-Gate Items

None blocking. The two WARNINGs are both Phase 4 MUST-FIX items already bound to spec ACs (AC-D2-6 for L1-1; THIRD-PARTY-NOTICES.md update for L1-2). No user decision is required at Phase 3 beyond acknowledging these carry-forward bindings.

The user should confirm at Phase 3 whether Option A or Option B is preferred for the skill file attribution block. This is a format choice, not a compliance decision — both are legally sufficient if the respective preconditions are met.

---

## Section 7: Verdict

**PASS WITH MUST-FIX**

**0 CRITICAL · 2 WARNING · 4 INFO**

**Proceed to `/design` (@architect Phase 1).** Phase 1 is NOT blocked. Phase 1 MUST:
1. Confirm Option A or Option B for the skill file attribution block
2. Determine how `THIRD-PARTY-NOTICES.md` is updated for the addyosmani entry (amendment to existing ADR-025 scope vs. new heading)
3. Bind both MUST-FIX items (CF-L1-1 and CF-L1-2) as Phase 4 implementation constraints

**Phase 4 MUST NOT ship** `skills/prompt-gate/SKILL.md` without the compliant attribution block, and MUST NOT ship the PR without `THIRD-PARTY-NOTICES.md` updated.

The compliance surface is narrow and well-defined. The risk is low (MIT → MIT, same-author chain, clean license compatibility). The required actions are mechanical (add attribution block, update THIRD-PARTY-NOTICES.md) and already partially anticipated by spec AC-D2-6. No architecture changes are required to proceed.

---

## Skills Run

| Skill | Triggered | Status |
|-------|-----------|--------|
| L1: License Scan | Yes — inbound MIT pattern from addyosmani/agent-skills via The-Council port | WARN (L1-1, L1-2) |
| L2a: GDPR | No — no telemetry, analytics, or API sending user data | SKIP |
| L2b: Privacy Notice | No — L2a did not trigger | SKIP |
| L3: API ToS | No — no Anthropic/OpenAI API usage; prompt-gate is a local workflow skill | SKIP |
| L4: Obsidian Plugin | No — not an Obsidian plugin | SKIP |
| L5: Trademark | Yes — tools: field, competitor naming check | INFO (L5-1) |
| C1: ISO 27001 | No — out of scope per task brief | SKIP |
| C2: SOC 2 | No — out of scope per task brief | SKIP |
| C3: HIPAA | No — no PHI, not a covered entity | SKIP |
| C4: GDPR Operational | No — L2a did not trigger | SKIP |

---

*This review is compliance triage, not legal advice. Findings marked WARNING should be reviewed by the project owner before implementation. The attribution block options above are drafts for review — confirm the chosen option with the project owner before @architect finalizes the Phase 1 design contract.*
