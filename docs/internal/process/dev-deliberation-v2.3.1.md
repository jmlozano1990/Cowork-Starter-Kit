# @dev Deliberation Review — v2.3.1 Phase 1

**Verdict**: APPROVE-WITH-AMENDMENTS

---

## Self-review checklist (completed before writing)

- [x] Spot-checked meeting-notes and risk-assessment reference SKILL.md files for the 9-section pattern — confirmed header text and order. Also spot-checked voice-matching and daily-briefing.
- [x] Read cowork.lock.json directly — `grep -c "examples/" cowork.lock.json` returns 0, `grep -c "content_hash"` returns 0. No in-tree file tracking. Lock schema uses `sha256` per file, not `content_hash`. Byte-unchanged ruling is correct.
- [x] Mentally drafted 4 trigger_examples for each of the 8 skills — see D-v2.3.1-3 for ideation-partner distinctness analysis.
- [x] Commit graph: NOT specified in architecture. Amendment required (D-v2.3.1-6).

---

## Findings

### D-v2.3.1-1: Lock-schema field name discrepancy
**Topic**: OQ-v2.3.1-1 / C-v2.3.1-9 — cowork.lock.json byte-unchanged ruling
**Issue**: Architecture states `grep -c "examples/" cowork.lock.json` returns 0, and that there is "no `content_hash` field." Direct inspection confirms the first claim (0 examples/ paths). However, the actual field name in the lock is `sha256` (not `content_hash`). The architecture body uses `content_hash` in historical ADR-028 prose but `sha256` in the lock schema definition. This is a terminology discrepancy, not an implementation risk — both terms refer to the same concept, and the lock has no in-tree file entries regardless of the field name. AC-ZD-1 spec text references `content_hash` in a description context only, and the verification command (`git diff --name-only main`) does not depend on field name.
**Recommendation**: Watch only. No amendment needed. @dev should note that the field is `sha256` in actual cowork.lock.json entries if referenced anywhere in commit message prose. Does not block Phase 4.

---

### D-v2.3.1-2: Trigger_examples frontmatter count — reference skill discrepancy
**Topic**: C-v2.3.1-2 / AC-Sn-2 — "exactly 4 bullets" in trigger_examples
**Issue**: The architecture states all four reference skills confirm the 4-bullet pattern. Direct inspection shows:
- voice-matching: **3** trigger_examples bullets in frontmatter (lines 4–7), **4** bullets in `## Triggers` body section.
- daily-briefing: **3** trigger_examples bullets in frontmatter (lines 4–7), **4** bullets in `## Triggers` body section.
- meeting-notes: **5** trigger_examples bullets in frontmatter, **4** bullets in `## Triggers` body section.
- risk-assessment: **4** trigger_examples bullets in frontmatter (matches body).

The architecture notes meeting-notes has 5 frontmatter bullets and correctly rules 4 as the binding count per v2.3.0 C-v2.3-4 + PRD AC-Sn-2. However, voice-matching and daily-briefing each have only **3** frontmatter bullets — not 4 — while their `## Triggers` body sections do have 4 bullets. The architecture's C-v2.3.1-2 verification command (`awk '/^trigger_examples:/,/^---$/' SKILL.md | grep -c '^  - '`) will return 3 for voice-matching and daily-briefing if used as a reference, but the spec requires 4 for all 8 expansions.

This is not an error in the constraint (the expansion target is 4 bullets), but it means @dev cannot use voice-matching or daily-briefing as a copy-paste template for frontmatter bullet count — those references show 3 bullets, not 4. Only risk-assessment is an accurate reference for the 4-bullet frontmatter contract.
**Recommendation**: Amendment — add a Phase 4 implementation note: "voice-matching and daily-briefing frontmatter carry 3 trigger_examples bullets (pre-C-v2.3.1-2); the 8 expansions MUST emit 4 bullets, matching risk-assessment's frontmatter, not voice-matching's or daily-briefing's." This prevents @dev from misreading the references and shipping 3-bullet frontmatter. Alternatively acceptable: add a sentence to the existing C-v2.3.1-2 verification block noting "reference note: voice-matching + daily-briefing carry 3 frontmatter bullets for historical reasons; expansions must emit 4."

---

### D-v2.3.1-3: ideation-partner 4-bullet distinctness — implementable but watch-worthy
**Topic**: OQ-v2.3.1-2 ruling + C-v2.3.1-2
**Issue**: Drafting 4 distinct, concrete trigger phrases for ideation-partner:
1. "Ideate on this brief" / "Give me creative directions for [project]" — direct invocation
2. User describes a project kickoff without clear direction and asks "what should we do?"
3. User says "I'm stuck" or "everything feels like the same idea" — proactive signal from stuck language
4. Presence of an Ideation/ or Concepts/ folder + new-project context without a selected direction

Triggers 3 and 4 are distinguishable. However, Trigger 3 ("I'm stuck") risks drifting toward ambient behavioral description ("when the user feels stuck"), which OQ-v2.3.1-2 explicitly prohibits. The ruling requires "concrete invocation phrases or folder-presence cues." @dev must frame Trigger 3 as a phrasing cue ("user says 'I'm stuck', 'nothing feels different', 'these all feel the same'") not as an emotional state inference. This is achievable but requires care.
**Recommendation**: Watch item. Implementation note for @dev: Triggers 3–4 for ideation-partner must be written as observable phrasing cues or folder-presence signals, not internal user state inferences. Example: "User uses phrases like 'I'm stuck on direction,' 'these all feel similar,' or 'push beyond the obvious'" satisfies the concrete-phrasing requirement.

---

### D-v2.3.1-4: Unresolved OQ — ENFORCED_EXAMPLES for creative, business-admin, writing, personal-assistant
**Topic**: Spec OQ-v2.3.1-5 (the 5th spec OQ, about ENFORCED_PRESETS/ENFORCED_EXAMPLES)
**Issue**: The spec explicitly asked @architect: "Confirm whether `examples/creative/.claude/skills/*/SKILL.md` and `examples/business-admin/.claude/skills/*/SKILL.md` are currently in the CI `ENFORCED_PRESETS` allowlist." The architect's OQ numbering resolved OQ-v2.3.1-1 through OQ-v2.3.1-5, but the architect's OQ-v2.3.1-5 addresses line-band hardness — not ENFORCED_EXAMPLES. The ENFORCED_EXAMPLES question is resolved IMPLICITLY (via WILL-NOT-DO #9: quality.yml byte-unchanged + C-v2.3.1-9 deny-list) but NOT explicitly as a named OQ resolution.

Direct inspection of `.github/workflows/quality.yml` confirms:
- `ENFORCED_EXAMPLES="study research project-management"` (line 323 and 383)
- `writing`, `creative`, `business-admin`, and `personal-assistant` are all UNENFORCED
- The unenforced advisory-notice step emits `::notice::` (not `::error::`) for all 4 of these presets

This means: after @dev expands the 8 skills, CI will NOT enforce section structure or line floor on any of them. The 8 expansions will only be checked via @qa manual grep verification (C-v2.3.1-3 through C-v2.3.1-5 shell commands). This is consistent with the WILL-NOT-DO #9 ruling but leaves CI advisory for v2.3.1.

There is a secondary implication: the spec's OQ asked "if no, @dev must add these paths at the same commit per ADR-015 v1.3.3 pattern (CI-red-avoidance)." The v2.3.0 architecture established the precedent that adding unenforced presets to ENFORCED_EXAMPLES when stubs remain would CI-red (the remaining stubs fail the floor). For v2.3.1, all 8 stubs ARE being expanded — so after Phase 4, adding all 4 presets to ENFORCED_EXAMPLES would be safe. However, C-v2.3.1-9 explicitly prohibits quality.yml changes in v2.3.1. This creates a question for @dev: the ENFORCED_EXAMPLES addition that was appropriate to ADR-015 v1.3.3 precedent is now being deferred past the natural opportunity (when stubs are fixed).

This is NOT a hard block, but it is a gap: @dev will be asked "why didn't you add writing/creative/business-admin/PA to ENFORCED_EXAMPLES while you had the chance?" The answer is "because C-v2.3.1-9 prohibits quality.yml changes," and that answer needs to be explicit in the Phase 4 commit messages or scratchpad.
**Recommendation**: Amendment — add a single sentence to the architecture's v2.3.1 section noting the explicit ENFORCED_EXAMPLES ruling: "ENFORCED_EXAMPLES stays `'study research project-management'` through v2.3.1 (no quality.yml changes, per C-v2.3.1-9). Adding writing, creative, business-admin, personal-assistant to ENFORCED_EXAMPLES is deferred to v2.4 as part of the CI enforcement widening that accompanies stub completion. @dev MUST note this deferral in the Phase 4 scratchpad entry." Alternatively, this can be a single line in C-v2.3.1-9 prose.

---

### D-v2.3.1-5: Anti-patterns count — architecture says 4–7, spec says 4–6; named-5 carry-forward
**Topic**: Anti-patterns section cardinality — v2.3.0 CF carry-forward
**Issue**: The architecture (section 5 reference analysis, line 4633) observes "4–7 items" for `## Anti-patterns` (voice-matching: 5, daily-briefing: 4, meeting-notes: 6, risk-assessment: 7). The spec's binding template (section at offset 3477) says "4–6 items." These ranges differ at the high end (7 vs 6 ceiling).

There is no "named-5 rule" carry-forward in the v2.3.1 spec — the v2.3.0 carry-forward CF-1..6 do not include a "5 named anti-patterns" requirement for v2.3.1. The voice-matching 5-pattern baseline (C-v2.3-3) from v2.3.0 was a per-cycle constraint, not a permanent floor. The v2.3.1 cycle's constraint C-v2.3.1-7 binds anti-patterns to: (a) imperative voice, (b) no second-person prompt-redefinition, (c) data-as-data clause for 5 pasted-content skills. No cardinality floor beyond "4–7 items" from the reference survey.

For outline-generator specifically (the concern in the deliberation prompt): naming 5 specific anti-patterns for an outline tool is achievable with some creativity: (1) generating an outline before asking for content type + audience, (2) producing a flat list instead of a hierarchical structure, (3) generating a single structural option when multiple approaches exist, (4) treating the outline as final rather than drafting-fodder, (5) over-specifying word counts to the point of false precision. These are distinct and non-generic.
**Recommendation**: Watch item. The range discrepancy (arch: 4–7, spec: 4–6) is minor and not a Phase 4 reject risk — the binding constraint is the imperative-voice and data-as-data pattern (C-v2.3.1-7), not cardinality alone. @dev should target 4–6 per spec guidance but is not penalized if a skill naturally produces 7 (within the 130-line ceiling). No amendment needed.

---

### D-v2.3.1-6: Commit graph not specified (MISSING)
**Topic**: Phase 4 commit topology — architecture did not specify
**Issue**: The v2.3.0 architecture included a full "v2.3.0 Dependency Graph for Phase 4" with named commits and sequencing rules. The v2.3.1 architecture provides only the allow-list and deny-list — no commit count, no commit order, no named commit strategy. The Constraint Table (C-v2.3.1-1a) implies a "Commit 0" but does not define the full commit topology.

There is no specification for: (a) how many commits, (b) whether skills are batched by preset or committed individually, (c) which commit carries the release artifacts, (d) whether the base-sync evidence commit (Commit 0) is a separate no-content commit or part of the first skill commit.

**My proposed commit graph (to be confirmed by @architect as an amendment, or accepted as @dev discretion):**

```
Commit 0 — Base-sync verification (no content changes, or combined with Commit 1)
  Body: "Base-sync verified: release/v2.3.1 at <SHA>, ahead of main by N commits, working branch matches release/v2.3.1 at <SHA>."
  
Commit 1 — W1: editing-pass + outline-generator (writing preset batch, 2 skills)
  Files: editing-pass/SKILL.md, outline-generator/SKILL.md

Commit 2 — W2: creative-brief + feedback-synthesizer + ideation-partner (creative batch, 3 skills)
  Files: creative-brief/SKILL.md, feedback-synthesizer/SKILL.md, ideation-partner/SKILL.md

Commit 3 — W3: email-drafting (business-admin batch, 1 skill)
  Files: email-drafting/SKILL.md

Commit 4 — W4: follow-up-tracker + spend-awareness (personal-assistant batch, 2 skills)
  Files: follow-up-tracker/SKILL.md, spend-awareness/SKILL.md

Commit 5 — W5: Release artifacts
  Files: VERSION, CHANGELOG.md, README.md
```

Total: 5 content commits (+ Commit 0 body, which may be combined with Commit 1). 6 commits maximum. Preset-batch strategy matches natural blast-radius grouping: a bug in one preset's skills won't taint another preset's commit, and CI can be checked per-commit.

Alternative: 8 individual commits (one per skill) + 1 release commit = 9 commits. This is cleaner for `git bisect` but higher overhead.

**Recommendation**: Amendment — @architect should specify the commit topology explicitly, OR the architecture should state "@dev discretion on commit granularity within the allow-list." Without a spec, @dev will choose the preset-batch approach (6 commits as above). If @architect has a different preference (e.g., alphabetical, per-skill, or all-in-one), it needs to be stated before Phase 4.

---

### D-v2.3.1-7: Release artifact "Next up" teaser — draft available, no invention needed
**Topic**: C-v2.3.1-6 / AC-REL-4 — README "Next up" teaser
**Issue**: The architecture says 'README.md → "Next up" teaser unchanged or refreshed to keep v2.4 reference per AC-REL-4'. The README already contains:

```
## Next up — v2.4: First External Skill Import + ADR-028 Implementation
...
**Next up (v2.4):** First external skill import (Rank 3 / Rank 5 candidate from skills-roadmap.md) + ADR-028 `content_sha256` implementation.
```

This text already names v2.4 scope items correctly (ADR-028 + external skill import). @dev does NOT need to invent new teaser language — only the badge update (`version-2.3.0-green` → `version-2.3.1-green`) and possibly a v2.3.1 mention in the intro paragraph. The "Next up" section heading and ADR-028/external-import content can stay unchanged. AC-REL-4 verifies `grep -i 'next up' README.md` returns ≥1 match AND references v2.4. Both will pass with no changes to the "Next up" section.
**Recommendation**: Watch item. @dev note: only the badge URL needs updating in README.md. The "Next up" teaser already satisfies AC-REL-4. Do not edit the "Next up" section prose (would touch a WILL-NOT-DO-adjacent surface unnecessarily).

---

### D-v2.3.1-8: email-drafting 130-line ceiling with 4-item verification step
**Topic**: C-v2.3.1-11 + C-v2.3.1-5 — email-drafting line count risk
**Issue**: email-drafting is the highest target at ~120 lines. The 4-item pre-send verification step (C-v2.3.1-11) is bound as a numbered step inside `## Instructions` with four sub-bullets (a) through (d), each carrying a sentence of prose. A 4-sub-bullet step with prose labels adds approximately 8–10 lines to the Instructions section. With a standard 9-section structure at ~9 section headers + frontmatter (~8 lines) + when-to-use (~4 lines) + triggers (~7 lines) + instructions with verification step (~14–16 lines) + output format (~8 lines) + quality criteria (~8 lines) + anti-patterns (~8 lines) + example (~18–20 lines) + writing-profile integration (~5 lines) + example prompts (~5 lines) + blank lines (~10): estimated total 100–120 lines.

The risk: if the Example section follows meeting-notes density (30+ lines with a full email draft), the total could approach 130. The condensation moves available per OQ-v2.3.1-5 (reduce quality criteria to 4, reduce anti-patterns to 4, shorten Example input) are all viable.
**Recommendation**: Watch item. At Phase 4, @dev should draft email-drafting first among the 8 skills, count lines early, and condense the Example section if needed before adding the final pre-send verification step. Budget: if Example section exceeds 20 lines, condense to 15. Maximum anti-patterns: 5 (drop to 4 if needed).

---

### D-v2.3.1-9: spend-awareness financial boundary — implementable, no size risk
**Topic**: C-v2.3.1-10 + C-v2.3.1-5 — spend-awareness Boundaries + 130-line ceiling
**Issue**: Architect estimated 95–110 lines for spend-awareness including the Boundaries hard-block. The estimation is credible given the skill's simple output schema (categorical bullet list, not a table) and lightweight writing-profile integration ("N/A — data output"). The 4 bound phrases (`investment advice`, `budgeting recommendations`/`budget recommendations`, `savings plans`/`savings advice`, `for planning, consider a financial advisor`) are already present verbatim in the existing stub's Instructions section — they only need to be moved into `## Anti-patterns` as named bullets, not authored from scratch.
**Recommendation**: No action. Confirmed implementable within 130-line ceiling.

---

### D-v2.3.1-10: Excluded skills cmp verifier — SHA snapshot sufficient
**Topic**: C-v2.3.1-8 / AC-ZD-9 — action-items + doc-summary byte-unchanged
**Issue**: The architecture's verification is `git diff main -- examples/business-admin/.claude/skills/action-items/SKILL.md examples/business-admin/.claude/skills/doc-summary/SKILL.md` returns empty. This is sufficient and is the standard git-diff verification. A pre-Phase-4 SHA snapshot is redundant if @dev is working on `release/v2.3.1` branch (which was cut from main at v2.3.0 tag), and git diff against main captures any accidental modification. No pre-Phase-4 snapshot needed.
**Recommendation**: No action. git diff verification is sufficient.

---

### D-v2.3.1-11: Combined-path eligibility — confirmed
**Topic**: Architecture routing note + PRD routing note
**Issue**: Architecture closes with: "Phase 2 may be SKIPPED with the deliberation Round serving as the security pass." PRD routing note says "TBD at Phase 1 deliberation." Combined-path eligibility is consistent with v2.3.0 precedent (same classification: STANDARD, no auth/RLS/payments/external-API/schema surface, markdown-only deliverable). The only new surfaces are spend-awareness Boundaries (liability-adjacent, but addressed at skill level per OQ-v2.3.1-3) and email-drafting pre-send check (addressed procedurally in Instructions). No new attack surface introduced.
**Recommendation**: CONFIRM combined-path eligible. Phase 2 `/review` can be skipped provided @security Round 1 deliberation co-approves. @dev confirms this classification from implementability perspective.

---

### D-v2.3.1-12: Imperative voice on ideation-partner — no conflict
**Topic**: C-v2.3.1-7 — imperative voice convention on all 8 skills
**Issue**: ideation-partner's natural Instructions voice is exploratory ("encourage diverse directions," "avoid premature filtering"). Imperative voice can still accommodate this: "Generate 3–5 genuinely distinct directions (not variations on a single theme). Include at least one direction that challenges the obvious interpretation. Name each direction memorably. Write 2–3 sentences per direction." All of these are imperatives. The exploratory framing lives in `## When to use` (prose) and `## Quality criteria` (testable claims), not Instructions. No stylistic exception is needed.
**Recommendation**: No action. Confirmed implementable under imperative voice convention.

---

## Carry-forward acknowledgments (from v2.3.0 retro, per agent protocol)

The v2.3.1 spec explicitly dispositions all 6 v2.3.0 carry-forwards in the Carry-Forward Dispositions table:

- **CF-1 (ADR-028 impl)**: Reject (deferred) — explicitly out of scope, WILL-NOT-DO #3.
- **CF-2 (first external skill import)**: Reject (deferred) — explicitly out of scope, WILL-NOT-DO #4.
- **CF-3 (ADR Index backfill)**: Reject (deferred) — hygiene cycle, out of scope.
- **CF-4 (local markdownlint pre-commit)**: Reject (deferred) — Council self-improve cycle.
- **CF-5 (release-artifact regression watch)**: Accept — active regression watch. All 4 release artifacts (VERSION + CHANGELOG + README badge + README "Next up") bound via AC-REL-1..4 + C-v2.3.1-6. This was RESOLVED in v2.3.0 and must STAY resolved. The watch is not passive — it is a Phase 4 implementation requirement.
- **CF-6 (Local-Lint-vs-CI-Divergence watch)**: Accept — @dev must run `markdownlint-cli2` locally on all changed SKILL.md files before push. The quality.yml CI lint check fires on all files; local pre-push run prevents CF-6 first-push failures.

---

## Implementation pitfalls flagged for self-recall at Phase 4

- **Frontmatter trigger count**: Do NOT copy frontmatter bullet count from voice-matching (3 bullets) or daily-briefing (3 bullets) — those are legacy 3-bullet frontmatter. Copy from risk-assessment (4 bullets). All 8 expansions need exactly 4 trigger_examples in frontmatter AND 4 bullets in `## Triggers` body.
- **ideation-partner Trigger 3**: Must be a phrasing cue ("user says 'I'm stuck', 'these all feel the same'"), not a behavioral state inference. Re-read OQ-v2.3.1-2 ruling before drafting.
- **email-drafting line budget**: Draft first. Count lines before adding the full 4-item verification step. If over 120, condense Example section. Do not condense Instructions.
- **spend-awareness Boundaries phrases**: All 4 verbatim phrases are ALREADY in the existing stub's Instructions — move them to `## Anti-patterns` as named bullets, don't reinvent them.
- **data-as-data clause required** for: creative-brief (if brief is pasted), feedback-synthesizer, email-drafting (thread paste), follow-up-tracker (conversation paste), spend-awareness (transaction paste). 5 of 8 skills. C-v2.3.1-7 grep-verifies this at Phase 5.
- **markdownlint-cli2 local run required** before push on all 8 SKILL.md files (CF-6 regression watch). Do not skip.
- **ENFORCED_EXAMPLES**: writing, creative, business-admin, personal-assistant are all UNENFORCED in CI. The 8 skills pass CI at stub level (no enforcement fires). After expansion they still pass CI advisory-only. @qa verification is manual grep, not CI gate.
- **cowork.lock.json**: Field is `sha256`, not `content_hash`. Byte-unchanged. Do not touch. If any editor or tooling modifies it, `git checkout cowork.lock.json` before commit.
- **README badge only**: The "Next up" section already references v2.4 correctly. Update ONLY the badge URL (`version-2.3.0-green` → `version-2.3.1-green`). Do not edit the "Next up" prose.
- **Base-sync evidence string**: Must appear verbatim in Commit 0 body AND in the Phase 4 scratchpad entry. Use the exact format: `Base-sync verified: release/v2.3.1 at <SHA>, ahead of main by N commits, working branch matches release/v2.3.1 at <SHA>.`
- **Section header order is grep-verified**: Do not reorder sections even if content flow suggests a different order. The 9-section order is binding and @qa runs `grep -nE '^## ' SKILL.md` to verify sequence.

---

## Commit graph proposal

Proposed preset-batch topology (6 commits total):

```
Commit 0 — base-sync evidence (Commit 0 body appended to Commit 1, or standalone)
  No content changes beyond the evidence string in the commit message body.
  
Commit 1 — [v2.3.1] W1: editing-pass + outline-generator (writing preset)
  Files: examples/writing/.claude/skills/editing-pass/SKILL.md
         examples/writing/.claude/skills/outline-generator/SKILL.md

Commit 2 — [v2.3.1] W2: creative-brief + feedback-synthesizer + ideation-partner
  Files: examples/creative/.claude/skills/creative-brief/SKILL.md
         examples/creative/.claude/skills/feedback-synthesizer/SKILL.md
         examples/creative/.claude/skills/ideation-partner/SKILL.md

Commit 3 — [v2.3.1] W3: email-drafting (business-admin preset)
  Files: examples/business-admin/.claude/skills/email-drafting/SKILL.md

Commit 4 — [v2.3.1] W4: follow-up-tracker + spend-awareness (personal-assistant preset)
  Files: examples/personal-assistant/.claude/skills/follow-up-tracker/SKILL.md
         examples/personal-assistant/.claude/skills/spend-awareness/SKILL.md

Commit 5 — [v2.3.1] W5: release artifacts
  Files: VERSION, CHANGELOG.md, README.md
```

Rationale for preset-batch over per-skill: blast radius isolation (one preset's review doesn't re-open another's), natural review groupings, still allows per-commit CI green signals. Commit 0 can be combined with Commit 1's message body if @architect prefers fewer commits (reduces to 5 commits).

Note: architecture did not specify a commit graph. This proposal is @dev's recommendation. @architect should confirm or override before Phase 4 starts.

---

## Approval line

The v2.3.1 architecture is implementable as specified; two amendments are required before Phase 4 (D-v2.3.1-2 frontmatter bullet-count reference warning and D-v2.3.1-6 commit graph specification), and one watch item warrants a single clarifying sentence in architecture prose (D-v2.3.1-4 ENFORCED_EXAMPLES deferral), after which Phase 4 can proceed with zero remaining @dev discretion.

---

**APPROVE-WITH-AMENDMENTS — @dev**
