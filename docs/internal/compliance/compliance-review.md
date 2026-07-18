# Compliance Review — Claude Cowork Config

## Phase: Pre-build (Phase 2 gate input)
## Date: 2026-04-15T07:00:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Area | Description |
|----|----------|------|-------------|
| L1 | WARNING | License | LICENSE file not yet created; MIT intent documented but not enforceable until file exists |
| L2 | WARNING | Trademark | Product name "Claude Cowork Config" embeds "Claude" — a registered Anthropic trademark — creating implied endorsement/affiliation risk |
| L3 | INFO | Trademark | Google, Gmail, Slack, DocuSign referenced by name in connector docs; nominative-use framing should be applied consistently |
| L4 | INFO | Liability | Safety claim ("you're safe here") may create false assurance and modest liability surface |
| L5 | INFO | Community IP | Open PR contributions without a CLA or DCO create ambiguous IP ownership over community-submitted presets |
| L6 | INFO | GDPR/Privacy | No privacy surface detected; local-only data storage confirmed; brief local-storage disclosure recommended for transparency |

---

### CRITICAL

None.

---

### WARNING

**L1 — LICENSE file absent.** The architecture (ADR-004) and spec both state the repo is MIT-licensed, but no `LICENSE` file exists at the project root. Without this file, the repo is technically "all rights reserved" under copyright law in most jurisdictions, regardless of stated intent. Any user who downloads or forks the repo before the file is added has no clear license grant. Recommend creating `LICENSE` (MIT, standard SPDX text) before any public release or community contribution period opens. This is a pre-launch blocker.

**L2 — "Claude" in the product name.** The product is named "Claude Cowork Config" and the repo is `claude-cowork-config`. "Claude" is an Anthropic registered trademark. Using a trademark in a product or repository name may require explicit permission and may imply Anthropic endorsement or official affiliation that does not exist. This is distinct from nominative fair use, which covers referring to the product by name in documentation — naming a repo after a trademark is a different use. Recommend review by counsel or direct inquiry to Anthropic's developer relations team before the LinkedIn launch. Mitigations to consider: rename to a descriptive term that avoids embedding the mark (e.g., `cowork-config`, `cowork-starter-kit`), or obtain explicit written permission from Anthropic.

---

### INFO

**L3 — Third-party trademark references in connector documentation.** The spec (F6) references Google Drive, Gmail, Slack, and DocuSign by name. This is nominative fair use (describing what the product works with) and is standard practice in integration documentation. No action required beyond consistent framing: descriptions should read as "works with Google Drive" not "powered by" or "partnered with." The spec's current framing appears appropriate. Final connector checklist language should avoid phrases that could be read as implying partnership or endorsement.

**L4 — Safety claim liability.** The wizard includes the statement: "this wizard only uses skills you build yourself and Anthropic's official pre-built skills — so you're safe here." This claim may create false assurance. "Safe" is a broad, unqualified assertion. Recommend narrowing to: "This wizard guides you to create skills yourself or use Anthropic's official pre-built skills. We do not reference external skill repositories in this step." Removing "you're safe here" eliminates the implied guarantee without losing the reassurance intent.

**L5 — Community IP / Contributor rights.** Without a Contributor License Agreement (CLA) or Developer Certificate of Origin (DCO) requirement, the IP status of contributed presets is ambiguous. Contributors retain copyright by default, meaning the maintainer cannot sublicense contributions without individual permission. Recommend a DCO requirement (`git commit -s` sign-off) plus a line in CONTRIBUTING.md stating contributions are submitted under the MIT license. A formal CLA is heavier machinery and likely unnecessary at this stage.

**L6 — GDPR/Privacy surface.** The wizard collects name, role, study subject, tools used, and output format preference. All data is stored in `cowork-profile.md` on the user's local machine — no data leaves the device. This architecture has no GDPR exposure under the household exemption (Article 2(2)(c)). No privacy notice is legally required. However, a brief disclosure in README or WIZARD.md that "your answers are saved locally in cowork-profile.md on your own machine and are never transmitted anywhere" is recommended for user trust, particularly for European users.

---

### Summary

Two findings require attention before public launch:

**L1 (WARNING)** is a pre-launch blocker. The MIT LICENSE file must exist at the repo root before the repo goes public. Intent documented in the spec does not constitute a license grant under copyright law.

**L2 (WARNING)** requires a judgment call before the LinkedIn launch. Using "Claude" in the repository name embeds an Anthropic trademark and may imply official affiliation. Options: obtain written permission from Anthropic, or rename the repository to avoid embedding the mark.

The remaining findings (L3–L6) are informational. L5 (community IP / DCO) should be resolved before community contributions open. L4 (safety claim language) should be narrowed before first public release.

No GDPR exposure exists. No Anthropic API ToS concerns exist (the product does not use the API directly).

---

*This review is compliance triage, not legal advice. Findings marked WARNING should be reviewed by someone with relevant legal expertise before public launch.*

---

# Compliance Review — v2.0 Dynamic Workspace Architect (agency-agents upstream)

## Phase: 2 (Pre-Build — COMPLIANCE-SENSITIVE, inverse gate order: /legal before /design)
## Date: 2026-05-06T00:00:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Category | Surface | Description |
|----|----------|----------|---------|-------------|
| L1-1 | WARNING | L1-License | license | F5 attribution block omits the MIT permission grant text; link-only notice may not satisfy MIT §1 |
| L1-2 | WARNING | L1-License | license | cowork-starter-kit repo LICENSE does not acknowledge upstream-derived content; THIRD-PARTY-NOTICES.md absent |
| L1-3 | INFO | L1-License | license | Commit-SHA pinning protects pre-relicense content; /sync-agency PR gate is the correct control for future bumps |
| L1-4 | INFO | L1-License | license | nexus-strategy.md download-for-diff creates no attribution duty; redistribution duty does not apply to transient fetches |
| L5-1 | INFO | L5-Trademark | branding | "agency-agents" is not a registered trademark; /sync-agency command name is fair-use referential; no action required |
| L5-2 | INFO | L5-Trademark | branding | "Claude" embedding in repo name was flagged in v1.0 review (L2); pipeline confirms rename to cowork-starter-kit applied — verify repo name at launch |
| L2-1 | INFO | L2-GDPR | privacy | No GDPR surface in v2.0; raw.githubusercontent.com fetches carry no PII; static markdown architecture unchanged |

---

### CRITICAL

None.

---

### WARNING

**L1-1 — MIT attribution block omits permission grant text.**

The F5 attribution block as specified in spec.md contains five fields:
1. `Source: https://github.com/msitarzewski/agency-agents`
2. `Upstream path: <original-file-path>`
3. `Pinned commit: <40-char-sha>`
4. `License: MIT — Copyright (c) msitarzewski/agency-agents contributors`
5. `Derivative work: this file has been adapted for use with cowork-starter-kit`

The MIT license (confirmed from upstream) requires: *"The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."* "This permission notice" means the full permission paragraph — not merely a reference to it. The current 5-field block carries the copyright notice (field 4) and a source link but does NOT include the MIT permission grant text itself.

**Assessment:** This appears to conflict with the MIT license's verbatim-inclusion requirement. A URL pointing to the LICENSE file is not equivalent to including the license text. This pattern is widely used in practice but its legal sufficiency is disputed in some jurisdictions; the conservative and defensible position is to include the full text or a condensed notice that embeds it.

**Recommended corrected attribution block (Option A — condensed, embedded):**

```
---
# Agency Source — msitarzewski/agency-agents
# Upstream path: <original-file-path>
# Pinned commit: <40-char-sha>
# This file is used under the MIT License.
# Copyright (c) msitarzewski/agency-agents contributors
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions: The above copyright notice and this
# permission notice shall be included in all copies or substantial portions of
# the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
# Full license: https://github.com/msitarzewski/agency-agents/blob/main/LICENSE
# Derivative work: adapted for use with cowork-starter-kit
---
```

**Recommended corrected attribution block (Option B — condensed notice, permissible pattern):**

```
---
# Agency Source — msitarzewski/agency-agents
# Upstream path: <original-file-path>
# Pinned commit: <40-char-sha>
# Copyright (c) msitarzewski/agency-agents contributors
# Licensed under the MIT License — see https://github.com/msitarzewski/agency-agents/blob/main/LICENSE
# Derivative work: adapted for use with cowork-starter-kit
---
```

Option B is the pattern used in the majority of open-source projects for embedded files. It may be sufficient in practice, but Option A is the most legally conservative because it embeds the permission grant verbatim. The choice between A and B is a legal judgment call; both are improvements over the current spec. Recommend Option A for a project whose positioning is built on supply-chain hygiene.

**Note on upstream README finding:** The agency-agents README states "The author appreciates but does not require attribution." This is a statement of personal preference, not a license modification. The MIT license terms (which are a legal instrument) still apply; the author's preference statement does not waive the license requirement. Continue treating MIT attribution as mandatory.

**Action before Phase 4:** @architect must specify the corrected attribution block format (Option A or B) in the Phase 1 ADR for F5. The format confirmed by @compliance here must be adopted verbatim in the injection mechanism. Implementation of F5 MUST NOT proceed with the current 5-field spec until the attribution block is updated.

---

**L1-2 — Repo LICENSE file does not acknowledge upstream-derived content; THIRD-PARTY-NOTICES.md absent.**

The cowork-starter-kit `LICENSE` file declares: *"Copyright (c) 2026 The cowork-starter-kit contributors."* This is correct for the cowork-starter-kit's own code and documentation. However, v2.0 introduces a new state: when a user installs agency-agents content via the wizard, their installed workspace contains approximately 50% upstream-derived content (per spec's framing). The cowork-starter-kit itself, as the distribution mechanism, ships a lock file referencing that content and a wizard that injects it into user workspaces.

Under MIT, distributing a derivative work requires that the copyright notice and license of the upstream work be preserved in the distributed files. The F5 attribution injection handles this at the per-file level (pending L1-1 correction). However, the repo-level LICENSE file and repo root do not contain a collective acknowledgment that third-party MIT content is included under its own copyright.

**Assessment:** A `THIRD-PARTY-NOTICES.md` file at the repo root is the standard industry practice for documenting upstream copyright holders whose content is incorporated. This is not strictly required under MIT (which only mandates per-file notice preservation, satisfied by F5), but it provides:
1. A single point of truth for what upstream copyright holders have contributed
2. Protection against any claim that upstream attribution was "buried" in installed files the repo maintainer doesn't directly control
3. Alignment with the supply-chain hygiene positioning of the product

**Recommended THIRD-PARTY-NOTICES.md minimum content:**

```markdown
# Third-Party Notices

This repository distributes content from third-party sources under their original licenses.

## msitarzewski/agency-agents

- Source: https://github.com/msitarzewski/agency-agents
- License: MIT
- Copyright (c) msitarzewski/agency-agents contributors

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

Content from this source is distributed in user workspaces via the cowork-starter-kit
wizard, with attribution injected per-file at install time (see F5 in docs/spec.md).
Content is pinned to a specific upstream commit SHA recorded in the lock file.
```

**Action before Phase 4:** Create `THIRD-PARTY-NOTICES.md` at repo root with the content above. Update CONTRIBUTING.md to document that community contributions incorporating agency-agents content must follow the same attribution pattern. This file should be added to the Phase 4 deliverables list.

---

### INFO

**L1-3 — Commit-SHA pinning is legally sound as a pre-relicense content protection mechanism.**

The spec's analysis (A-v2.0-2, Risks section) is correct: when a user's lock file pins to commit SHA X, and the upstream later introduces a license change at commit SHA Y, the content at SHA X was MIT-licensed at the time of publication. The lock file captures the state of the repository at a point in time; installing from a pinned SHA installs the content under the terms that were in effect at that SHA. This is the same principle that package managers rely on — a published npm package version retains its declared license even if the maintainer later changes the license on a new version.

**However, two nuances apply:**

1. The `/sync-agency` PR gate is the critical control. When a future sync PR proposes bumping the pinned SHA to post-relicense content, the PR reviewer must check the license before merging. Recommend adding a CI check or a PR template checklist item: "Confirm agency-agents LICENSE file is unchanged from MIT at the new pinned SHA." This can be implemented as a CI step that fetches and compares the upstream LICENSE file hash.

2. If the upstream maintainer claims that even the old SHA commits should be relicensed retroactively (a legally questionable but theoretically possible position), the cowork-starter-kit's only risk-free response is to remove that content from the lock file entirely and replace with original or differently-licensed alternatives. The lock file's pinning does not protect against a bad-faith retroactive relicense claim — but such claims are extremely rare and generally unenforceable for code that was openly published under MIT without DRM.

No action required. The current design is sound. The CI license-check recommendation above is optional but advisable.

---

**L1-4 — nexus-strategy.md download-for-diff creates no attribution duty.**

The spec states cowork's `/sync-agency` CI workflow fetches the full agency-agents tree for diff inspection, including `nexus-strategy.md`. The question is whether downloading a file for comparison purposes — without redistributing it — triggers MIT's attribution requirement.

**Assessment:** No. The MIT license's attribution requirement applies to "copies or substantial portions of the Software" that are distributed. Fetching a file into a CI job's transient working directory for comparison and then discarding it (or showing it only in a PR diff) is not distribution. The PR diff showing file contents may be accessible to PR reviewers, but it is part of the CI/review process, not a product distribution. There is no obligation to attribute `nexus-strategy.md` content that is fetched-and-discarded, and the permanent block in F4 ensures it is never distributed to users.

The CI should ensure that `nexus-strategy.md` is not included in any build artifact or committed to the repo in any form — which F4 already enforces.

No action required.

---

**L5-1 — "agency-agents" name: fair-use referential; /sync-agency command name is acceptable.**

"agency-agents" does not appear to be a registered trademark (no evidence found in the upstream repo or README of trademark registration). The name is used by msitarzewski for a GitHub repository. Using a descriptive name in a command (`/sync-agency`) to describe what the command does (sync content from the agency-agents upstream) is nominative fair use — the same fair-use category as referencing a product by name in documentation.

The spec's pervasive use of "agency-agents" in referential contexts (spec.md, docs, CI workflow names) is standard and appropriate for an open-source integration. The author's README statement ("appreciates but does not require attribution") further confirms there is no trademark sensitivity.

**One caution:** If the cowork-starter-kit markets v2.0 with heavy use of "agency-agents" in promotional copy or uses it in a way that could imply the upstream author endorses the distribution layer, that framing should be reviewed. The appropriate framing is: "built on content from msitarzewski/agency-agents" or "powered by the agency-agents library" — not "agency-agents for non-technical users" (which could imply an official partnership). Current spec framing appears appropriate.

No action required.

---

**L5-2 — "Claude" trademark: confirm cowork-starter-kit rename is complete.**

The v1.0 compliance review (L2 WARNING) flagged that the original product name "Claude Cowork Config" embeds an Anthropic trademark. The v1.0 Phase 3 gate decision (2026-04-15) recorded that the repo was renamed to "cowork-starter-kit." This finding is marked as resolved in the prior pipeline.

**Confirm before v2.0 launch:** Verify that all v2.0 documentation, the GitHub repository name, README title, and any external links use "cowork-starter-kit" — not "Claude Cowork Config" or any name embedding "Claude." The v2.0 spec's technical constraints note "IP boundary: No Pillar OS vocabulary, no Life Vault internal terminology, no The-Council internals in any v2.0 outputs or docs" — the same discipline applies to the Anthropic trademark.

This is an INFO finding because the prior cycle resolved the core issue. Confirm residual references are cleaned up before launch.

---

**L2-1 — GDPR / Privacy: no surface in v2.0.**

The v2.0 architecture is static markdown with `raw.githubusercontent.com` fetches at install time. No PII is transmitted to any server. The wizard collects user goal/profile answers that are stored locally in `cowork-profile.md` and `writing-profile.md` on the user's own machine — identical to v1.x, which was already assessed as GDPR-exempt under Article 2(2)(c) (household exemption). The `raw.githubusercontent.com` fetch endpoint is a public CDN; no authentication or user identification is involved.

L2a (GDPR telemetry trigger) does not apply. L2b (Privacy Notice Generation) does not apply.

No action required.

---

### Skills Run

| Skill | Triggered | Status |
|-------|-----------|--------|
| L1: License Scan | Yes — MIT content import from third-party upstream | WARN |
| L2a: GDPR | No — no telemetry, analytics, or API sending user data | SKIP |
| L2b: Privacy Notice | No — L2a did not trigger | SKIP |
| L3: API ToS | No — no Anthropic/OpenAI API usage in v2.0 scope | SKIP |
| L4: Obsidian Plugin | No — not an Obsidian plugin | SKIP |
| L5: Trademark | Yes — agency-agents name + /sync-agency command + Claude trademark carry-forward | INFO |
| C1: ISO 27001 | No — out of scope per task brief | SKIP |
| C2: SOC 2 | No — out of scope per task brief | SKIP |
| C3: HIPAA | No — no PHI, not a covered entity | SKIP |
| C4: GDPR Operational | No — L2a did not trigger | SKIP |

---

### Summary

**Overall verdict: PASS WITH WARNINGS — proceed to /design with two carry-forward WARNINGs.**

The v2.0 design is legally sound in its fundamental approach. Pinning to an upstream MIT-licensed commit SHA, applying a fail-closed allowlist, and injecting per-file attribution is the right architecture for supply-chain-hygiene-as-differentiator. The compliance risks are implementation-level, not design-level.

**Two WARNINGs require resolution before Phase 4 implementation begins:**

**L1-1 (WARNING)** is a pre-implementation blocker for F5. The current 5-field attribution block in the spec does not include the MIT permission grant text. The MIT license requires "this permission notice" to be included in all copies — a source URL does not satisfy this. @architect must specify a corrected attribution block in the F5 ADR, choosing between Option A (full embedded text) or Option B (condensed notice with embedded copyright + license link). Option A is recommended given the product's supply-chain hygiene positioning. No Phase 4 implementation of F5 may begin until the corrected format is approved.

**L1-2 (WARNING)** is a pre-release deliverable. A `THIRD-PARTY-NOTICES.md` file must be created at the repo root documenting the msitarzewski/agency-agents copyright and MIT license terms. This is standard industry practice for distribution mechanisms that incorporate third-party content, and it aligns directly with the product's positioning. The file template is provided above. This should be added to the Phase 4 deliverables list alongside the lock file and allowlist policy.

The INFO findings (L1-3, L1-4, L5-1, L5-2, L2-1) require no blocking action. L1-3's optional CI license-check recommendation (verify LICENSE file hash at each /sync-agency bump) is worth adding to the allowlist policy as a CI step — it closes a monitoring gap that the current design leaves to human reviewers.

The upstream README's "appreciates but does not require attribution" statement does not modify the MIT license terms. Attribution remains legally required.

---

*This review is compliance triage, not legal advice. Findings marked WARNING should be reviewed by someone with relevant legal expertise before public launch. The corrected attribution block formats (Option A and B above) are drafts for review — @architect should confirm the chosen format with the project owner before implementation.*
