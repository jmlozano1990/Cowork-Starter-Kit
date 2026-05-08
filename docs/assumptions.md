# Assumptions Register — Claude Cowork Config

## About This Document

Every assumption in the product spec is catalogued here with:
- **Confidence:** [CONFIRMED], [ESTIMATED], or [UNTESTED]
- **Risk:** What breaks if this assumption is wrong
- **Validation path:** How to verify before or after shipping

Assumptions are grouped by domain. Review this register before Phase 1 (architecture) and before any preset ships.

Last updated: v1.2 — 2026-04-17T00:00:00Z

---

## A — Cowork Platform Assumptions

### A1 — Project custom instructions accepts ≤350 words
**Confidence:** [UNTESTED — CRITICAL for v1.2]
**Assumption:** Cowork's Project custom instructions field accepts multi-paragraph plain-text up to approximately 400 words without truncation, reformatting, or rendering issues. v1.2 targets ≤350 words (increased from v1.1's ≤300 to support dynamic wizard branching).
**v1.2 update:** Dynamic wizard branches (suggestion flow, writing profile step) add ~30–50 words to each starter file. The ≤350 word target keeps files within the ~400-word assumption limit. If actual field limit is proven <300 words, revert to split architecture: state machine check in instructions (≤150 words), full wizard branches in WIZARD.md referenced by pointer.
**Risk:** If the field has a shorter character limit, the dynamic wizard is truncated silently. Users see a partial wizard with no indication something is wrong. This is the highest-impact technical risk in v1.2.
**Validation path:** Before Phase 4: manually paste a 350-word block into Cowork Project Settings > Custom Instructions. Verify saved text matches input exactly. Test at 300, 350, and 400 words. Document the actual limit.
**Escalation:** If limit is <300 words: redesign starter file to ~150-word state machine check + pointer to WIZARD.md for interview script.

### A2 — SKILL.md files in .claude/skills/ are loaded by Cowork
**Confidence:** [RESOLVED — SUPERSEDED by v1.1]
**Status:** Closed. Confirmed that Cowork does NOT auto-discover SKILL.md files from filesystem. Static skill file delivery delivers zero automatic value in Cowork.
**Resolution:** Skills delivered via: (1) `/skill-creator` wizard conversation (primary), (2) Anthropic pre-built skills (zero-config defaults), (3) ZIP upload via Settings > Customize > Skills > '+' (tertiary).
**No further action required.**

### A3 — Projects feature (March 2026) is stable for documentation guidance
**Confidence:** [ESTIMATED]
**Assumption:** Cowork's Projects feature (launched March 20, 2026) is stable enough for wizard guidance.
**Risk:** Low — GA product confirmed.
**Validation path:** Walk through Projects creation flow to confirm: project-scoped instructions persist, memory is scoped per-project, folder assignment works as documented.

### A4 — Cowork connectors do not require developer credentials
**Confidence:** [ESTIMATED]
**Assumption:** Authorizing Cowork connectors (Google Drive, Gmail, Slack) is a pure OAuth flow — no API keys or developer accounts required.
**Risk:** If any connector requires technical setup, our connector checklist misleads non-technical users.
**Validation path:** Walk through connector authorization for Google Drive and Gmail as a non-developer. Document exact flow.

### A5 — Cowork respects "confirm before delete" in Project custom instructions
**Confidence:** [ESTIMATED]
**Assumption:** Including the safety rule in Project custom instructions causes Cowork to prompt before any deletion.
**Risk:** HIGH. If this instruction is ignored, users remain exposed to the documented 11GB deletion scenario. Safety-critical assumption.
**Validation path:** Set up test workspace with safety instruction. Ask Cowork to "clean up" a folder. Verify Cowork prompts before deleting. Test with ≥3 deletion phrasings.
**Escalation:** If assumption fails, add prominent WARNING to README and SETUP-CHECKLIST.md.

### A6 — No public Cowork configuration API exists
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** No programmatic API for configuring Cowork. All configuration requires manual UI interaction.
**Risk:** Low — if API exists, our approach still works; API would be an upgrade for v2.
**Validation path:** Review Anthropic developer docs and Claude Help Center for any Cowork configuration API.

### A13 — Cowork Project memory does not auto-ingest context files
**Confidence:** [UNTESTED — unchanged]
**Assumption:** Cowork does not auto-ingest `about-me.md`, `cowork-profile.md`, or `writing-profile.md`. Users must manually seed memory.
**Risk:** If Cowork does auto-ingest, our manual memory-seeding guidance is redundant (harmless but unnecessary).
**Validation path:** Create Cowork Project with context files in project folder. Start fresh session and ask "What do you know about me?" without prompting. Document behavior.

### A14 — `/skill-creator` is a stable built-in Cowork command
**Confidence:** [ESTIMATED — carries from v1.1]
**Assumption:** `/skill-creator` is stable and produces valid `folder/SKILL.md` output. User-validated in one session (2026-04-15).
**Risk:** If deprecated or renamed, skill validation falls back to confirming file exists. Fallback path is a mandatory AC in F5.
**Validation path:** Before Phase 4: verify `/skill-creator` still exists in Cowork and produces expected output format.

### A15 — AskUserQuestion nudge causes Cowork to render clickable button UI
**Confidence:** [UNTESTED — carries from v1.1]
**Assumption:** The AskUserQuestion nudge MAY cause Cowork to render button UI.
**Risk:** Best-effort heuristic. No AC may require button rendering. Numbered list is the guaranteed fallback.
**Validation path:** Test by pasting starter file with nudge into fresh Cowork project. Observe whether buttons appear. Either outcome is acceptable.

---

## B — User Behavior Assumptions

### B1 — Non-technical users will follow a numbered checklist without abandoning
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** A non-technical user can follow the SETUP-CHECKLIST and complete setup in under 18 minutes (revised from 15 min to account for writing profile step).
**Risk:** Checklist drop-off if any step is ambiguous.
**Validation path:** Usability test with 3 non-technical users. Time from README open to first personalized session. Note every pause.

### B2 — Users are willing to complete a ≤12-step interview
**Confidence:** [ESTIMATED — REVISED for v1.2]
**v1.1 state:** 11-step interview with fast-track at Step 5.
**v1.2 change:** Writing profile adds 1 step → 12 steps. Fast-track pause moves to after Step 6.
**Alex's documented tolerance:** Alex has documented tolerance of "Minimal (2–3 max)." The 12-step plan directly contradicts this; fast-track mitigates. v1.2 fast-track pause is at Step 6 (after writing profile, before folder structure and skills).
**Mitigation:** Fast-track at Step 6 is the key mitigation. Alex can exit with a working workspace and writing profile (steps 1–6) without completing folder structure and skill discovery.
**Risk:** If >30% of users exit at fast-track without reaching skills steps, skill adoption will be low.
**Validation path:** Smoke test: measure % of test users who reach Step 9+ (first skill activation). If >40% fast-track and don't return for skill setup, consider making skills step shorter or moving it earlier.

### B3 — The 6 preset categories cover ≥80% of target user goals
**Confidence:** [ESTIMATED — revised]
**v1.2 update:** Dynamic wizard now handles novel goals (Career Manager, Home Renovation, Language Learning). The 80% coverage assumption is less critical — the wizard builds custom workspaces for the remaining 20%.
**Risk:** Reduced from v1.1. If presets are narrow, wizard's novel-goal branch handles the gap.
**Validation path:** Track novel-goal branches in test sessions and via GitHub issue analysis post-launch.

### B4 — Users have Cowork installed (or will install before using wizard)
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Target audience is "just installed Cowork, don't know what to do next." Wizard does not install Cowork.
**Validation path:** Consider adding "Have you installed Claude Cowork? Y/N" as wizard question 0.

### B5 — Users are willing to answer writing profile questions in non-writing workspaces [NEW v1.2]
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** Users setting up a Study or PM workspace will answer 3–4 writing style questions even though they don't think of themselves as "writers." They understand that Cowork produces written output for all tasks.
**Risk:** Users may skip the writing profile step ("I'm not a writer — skip"), resulting in `writing-profile.md` with only default values. The profile is still generated (not empty) but is less personalized.
**Mitigation:** Wizard framing: "Even in a study/research workspace, I'll be writing summaries and explanations for you — this helps me match your style." The profile generates with substantive defaults even if questions are skipped.
**Validation path:** In smoke test: for non-Writing presets, observe whether test users complete writing profile step or attempt to skip. If >40% skip, revise framing.

---

## C — Delivery & Community Assumptions

### C1 — GitHub + LinkedIn is sufficient for initial distribution
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** LinkedIn post + quality GitHub README generates ≥200 stars within 30 days.
**Validation path:** Track referral source for first 100 GitHub visitors via UTM parameters.

### C2 — Community contributors will add skills and presets
**Confidence:** [UNTESTED — revised for v1.2]
**v1.2 change:** Community contribution now includes two paths: (a) new preset PRs (same as v1.1), (b) skill entries to `curated-skills-registry.md`. The registry path is lower-friction than a full preset PR.
**Assumption:** ≥10 community skill entries will be submitted to `curated-skills-registry.md` within 60 days.
**Risk:** Registry remains sparse — users see fewer curated skill suggestions for novel goals.
**Validation path:** Track PRs against `curated-skills-registry.md` in first 60 days. If contributions are absent, add a "contribute a skill" workflow to CONTRIBUTING.md with a template.

### C3 — Users will use ZIP download, not git clone
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Non-technical users use GitHub's "Download ZIP." Wizard works without git installed.
**Validation path:** Download repo as ZIP and walk through full wizard flow. Verify no step requires git.

---

## D — Market/Timing Assumptions

### D1 — Cowork's non-technical user base is large enough
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Claude Pro/Max plans have a meaningful non-technical knowledge worker user base actively trying to use Cowork.
**Validation path:** Track referral sources from Claude subreddits and knowledge worker communities vs. developer communities.

### D2 — No competing product provides this wizard experience for Cowork specifically
**Confidence:** [ESTIMATED — carries from v1.1]
**v1.2 update:** Claude Code skill ecosystem has grown (22,000+ star repos, skills.sh marketplace, Anthropic official skills registry). All of this targets Claude Code users (developers), NOT Cowork users (knowledge workers). Gap remains unserved.
**Risk:** Anthropic ships native Cowork onboarding wizard. Mitigated by: pivot to "advanced configuration" and "preset expansion beyond defaults."
**Validation path:** Search GitHub and Product Hunt monthly for Cowork-specific onboarding tools.

### D3 — Skill security risk justifies curated-first approach [NEW v1.2]
**Confidence:** [CONFIRMED]
**Evidence:** Repello AI research (2026): 13.4% of community skills contain critical security issues. Snyk ToxicSkills research (2026): prompt injection in 36% of tested skills, 1,467 malicious payloads found. Cato Networks documented weaponized Claude skills using ransomware delivery.
**Assumption:** A curated Tier 1 default is required, not optional. Tier 2 opt-in with explicit warnings is the appropriate middle ground.
**Risk:** If we ship Tier 2 as default, we expose non-technical users (Alex, Maria) to 13.4% critical risk rate with no prior safety context. This is unacceptable.
**Validation path:** Already confirmed by security research. No additional validation required — this is a design constraint, not a hypothesis.

### D4 — `curated-skills-registry.md` is maintainable as a static file [NEW v1.2]
**Confidence:** [UNTESTED — LOW risk]
**Assumption:** A manually maintained markdown registry is sufficient for v1.2. Skills remain installable at their documented source URLs without a live API or package manager.
**Risk:** Skills at external URLs become unavailable (repo deleted, renamed, rate-limited). Registry entries become stale.
**Mitigation:** Vetting date in each registry entry. CONTRIBUTING.md instructs contributors to verify URL accessibility before submitting.
**Validation path:** After 60 days post-launch, audit registry entries for broken URLs. If >15% are stale, evaluate adding an automated URL health check to CI.

---

## v1.3.0 Assumptions

_Added: 2026-04-17T21:00:00Z — v1.3.0 Preset Skills Depth cycle_

### B10 — Users will complete the per-skill input session without fatigue [NEW v1.3.0]
**ID:** A-v1.3-1
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** The project owner will answer 4–6 targeted questions for each of the 3 Study skills during `/implement` without abandoning the session partway through. Total input load: 12–18 questions across 3 sessions.
**Risk:** If the owner fatigues mid-session, a skill may be drafted with incomplete quality criteria or a missing worked example, reducing the template's signal quality for future community contributors.
**Mitigation:** Only 3 skills in v1.3.0 (hybrid cadence). Sessions are spread across 3 separate commits, not batched. Orchestrator saves partial answers to `skill-inputs/<skill-name>.md` so a session can resume if interrupted.
**Validation path:** Monitor whether all 3 input files exist and are complete at Phase 5. If any file is missing answers for quality criteria or worked example, flag as incomplete before Phase 7 approval.

### A-v1.3-2 — The 9-section template fits all 18 preset skills [NEW v1.3.0]
**ID:** A-v1.3-2
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** The 9-section template (`When to use`, `Triggers`, `Instructions`, `Output format`, `Quality criteria`, `Anti-patterns`, `Example`, `Writing-profile integration`, `Example prompts`) is structurally appropriate for all 18 preset skills across 6 presets — not just Study.
**Risk:** A non-Study skill (e.g., `voice-matching` in Writing, or `ideation-partner` in Creative) may require a section that doesn't map cleanly to the template, forcing a template revision after v1.3.0 ships. If the template changes post-v1.3.0, the Study skills (already committed) may need retroactive updates.
**Mitigation:** Pilot `flashcard-generation` first. If the pilot reveals a structural mismatch, adjust the template before `note-taking` and `research-synthesis` are authored. Template is considered provisional until all 3 Study skills are approved.
**Validation path:** At Phase 1 design, @architect reviews the template against 1–2 non-Study skill examples (e.g., `voice-matching`, `status-update`) and confirms or adjusts fit. Document in ADR.

### A-v1.3-3 — Community contributors will accept the deeper template as the submission bar [NEW v1.3.0]
**ID:** A-v1.3-3
**Confidence:** [UNTESTED — LOW risk (aspirational)]
**Assumption:** When `templates/skill-template/SKILL.md` ships with v1.3.0 and `skill-depth-check` CI enforces the 9-section format, community Tier 2 contributors will adopt the template rather than submitting stub-quality skills or abandoning PRs.
**Risk:** If the template is perceived as too onerous, community contributions to `curated-skills-registry.md` and new preset PRs stall. This risks the v1.2 metric of ≥10 community registry entries within 60 days.
**Mitigation:** Template ships with clear inline placeholder comments. CONTRIBUTING.md PR checklist includes a reference to the template. `skill-depth-check` CI failure message is human-readable (not just "exit code 1").
**Validation path:** Track Tier 2 PR submissions after v1.3.0 launch. If zero PRs attempt the new template format within 30 days, add a "Getting started" tutorial section to CONTRIBUTING.md.

### A-v1.3-4 — CI allowlist approach is sustainable through v1.3.5 [NEW v1.3.0]
**ID:** A-v1.3-4
**Confidence:** [ESTIMATED — LOW risk (accepted trade-off)]
**Assumption:** Maintaining a path allowlist in `skill-depth-check` CI (widening by one preset per point release) is operationally sustainable for 6 releases (v1.3.0–v1.3.5) without accumulating technical debt. Each release requires a 1-line CI edit to add the new preset path.
**Risk:** If a preset is renamed or reorganized before its scheduled release, the allowlist entry must be updated manually. Missed update would silently skip enforcement for that preset.
**Mitigation:** CI job comment documents the rollout schedule and next-preset path explicitly. Each v1.3.x spec revision confirms the path before Phase 4.
**Validation path:** At v1.3.5, evaluate whether to consolidate to a global glob. If all 6 presets are on the new template format, replace the allowlist with `examples/**` and close the technical debt.

---

## v1.3.1 Assumptions

_Added: 2026-04-18T00:00:00Z — v1.3.1 Research Preset Depth + Carry-Forward Hygiene cycle_

No new assumptions for v1.3.1. Existing assumptions that carry forward and remain active:

- **A-v1.3-2** ([ESTIMATED]) — The 9-section template fits all 18 preset skills. v1.3.1 is the second validation point (Research preset). Template is still provisional until all 6 presets have at least one skill approved; v1.3.1 extends validation from Study to Research. If Research skills reveal structural gaps in the template, @architect Phase 1 may make targeted amendments before skill authoring.
- **A-v1.3-3** ([UNTESTED]) — Community contributors will accept the deeper template as the submission bar. v1.3.1 does not change this assumption; observable signal will arrive post-launch.
- **A-v1.3-4** ([ESTIMATED]) — CI allowlist approach is sustainable through v1.3.5. v1.3.1 widens to `"study research"` — this is the planned next step and does not change the risk profile.

**New observational signal (not a formal assumption):** The B10 "propose defaults + clarify" pattern validated in v1.3.0 for skills 2+ is being codified in H2 but remains [UNTESTED] as a controlled comparison. The v1.3.1 `source-analysis` and `research-synthesis` B10 sessions will be the second and third data points. If either session produces materially lower-quality skill output than the pilot, revisit whether the reduced-friction pattern sacrifices too much user input specificity.

---

## v1.4 Assumptions

_Added: 2026-04-19T00:00:00Z — v1.4 Personal Assistant Preset cycle_

### A-v1.4-1 — Users want a tactical personal-life PA separate from business-admin [NEW v1.4]
**ID:** A-v1.4-1
**Confidence:** [ESTIMATED]
**Assumption:** A meaningful segment of cowork-starter-kit users wants a personal-life PA preset that is distinct from the business-admin (work-focused) preset. The desired use cases are tactical and daily: morning briefing, relationship/commitment follow-up tracking, basic spend awareness.
**Evidence:** 5+ research sources (Superhuman blog, Copilot PA product surveys, Reclaim.ai user research, Motion feature prioritization data, Rabbit R1 post-mortem analysis) show daily-briefing rituals, commitment-tracking labor, and spend-awareness as the three highest-retention behaviors in personal AI assistant products. No current Cowork resource addresses this combination.
**Risk:** If users are satisfied adapting the business-admin preset for personal use, the new preset sees low adoption. Risk is LOW — the folder structure, writing tone, and skill set of business-admin are demonstrably wrong for personal-life contexts (formal/authoritative tone vs. warm/direct; professional skills vs. personal-life skills).
**Validation path:** After v1.4 launch, track wizard Q1 selection rate for Personal Assistant (option 7) vs. other options. If <5% of wizard completions select Personal Assistant in 60 days, evaluate whether the persona (Life Admin Juggler) is underserved or undiscoverable.

### A-v1.4-2 — 3-skill stub preset is sufficient for v1.4 [NEW v1.4]
**ID:** A-v1.4-2
**Confidence:** [CONFIRMED — user decision 2026-04-19]
**Assumption:** A 3-skill stub preset (daily-briefing, follow-up-tracker, spend-awareness as 16-line stubs) is a complete and shippable v1.4 deliverable. Deeper skill development (9-section rewrites, B10 input sessions) is deferred to v1.4.1 or later.
**Risk:** LOW — this is a deliberate scope boundary decided by the product owner, not an untested hypothesis. The preset itself (folders, connectors, global-instructions, wizard integration) is the primary value; skill depth is a quality enhancement.
**Validation path:** N/A — confirmed by user. Close this assumption at Phase 4 completion.

### A-v1.4-3 — Data-locality rule is enforceable via instruction-surface wording [NEW v1.4]
**ID:** A-v1.4-3
**Confidence:** [UNTESTED — to be validated in Phase 2]
**Assumption:** Including "Never echo raw financial amounts, full calendar events, or contact details to external services or APIs" in `global-instructions.md` is sufficient to prevent unintended data exfiltration when users connect Google Calendar or Gmail via the connector-checklist. The instruction wording creates an adequate behavioral constraint on Cowork's connector use.
**Risk:** MEDIUM. LLM instruction surfaces are best-effort; a sufficiently complex connector workflow (e.g., "summarize my Gmail and post to Slack") might cause Cowork to transmit calendar or contact data to a third-party service despite the rule. The "paste-only" finance instruction is stronger (no connector exists to violate it) but the calendar/contact constraint depends on Cowork respecting the instruction in edge cases.
**Mitigation:** Phase 2 (@security) is asked to explicitly evaluate whether the instruction wording is sufficient or whether a stronger control (e.g., connector allowlist, explicit Cowork connector guidance) is needed. The data-locality rule's heading (`## Data Locality Rule`) is implementation-verifiable by grep.
**Validation path:** @security Phase 2 assessment determines whether [UNTESTED] status resolves to [ESTIMATED] (instruction is likely sufficient) or escalates to a CRITICAL finding requiring additional controls.

### A-v1.4-4 — 5-folder structure covers common personal PA use cases [NEW v1.4]
**ID:** A-v1.4-4
**Confidence:** [ESTIMATED]
**Assumption:** The `Calendar/`, `Finances/`, `Tasks/`, `People/`, `Documents/` folder structure is appropriate for the Life Admin Juggler persona and covers the common personal-life PA workflows without over-prescribing a life taxonomy.
**Risk:** LOW. Users who need a different structure can modify `folder-structure.md`. The folder structure is guidance, not enforcement — Cowork does not create folders automatically (user follows the setup checklist). Worst case: a user ignores the suggested structure and creates their own.
**Validation path:** Post-launch GitHub issue analysis. If >3 issues request a different default folder structure, revisit for v1.4.1.

### A-v1.4-5 — spend-awareness delivers value from a single paste without persistent history [NEW v1.4]
**ID:** A-v1.4-5
**Confidence:** [UNTESTED]
**Assumption:** The `spend-awareness` skill can deliver useful categorical observations and 1–2 proactive flags (subscription detection, unusual spend) from a single user-pasted transaction list, without needing a persistent transaction schema, historical comparison, or live bank feed.
**Risk:** MEDIUM. "What's unusual?" requires some baseline. A single paste with no history limits the AI to intra-statement comparisons (e.g., "this category is larger than typical household ratios") rather than personal-baseline comparisons (e.g., "you spent 40% more on dining than last month"). The skill's value is real but is bounded by the single-paste constraint.
**Mitigation:** Stub instructions explicitly scope the skill to "categorized summary + 1–2 proactive observations from the provided data." No claim of historical trend analysis is made. The limitation is surfaced in the README positioning statement ("tactical awareness only").
**Validation path:** At v1.4.1 depth-rewrite, assess whether a structured input format (user pastes current month + prior month) would increase skill utility without introducing persistent storage. If yes, add as a v1.4.1 instruction enhancement.

---

## v1.3.3 Assumptions

_Added: 2026-04-20T00:00:00Z — v1.3.3 Project Management Preset Depth cycle_

No entirely new assumptions for v1.3.3. The template fit, CI approach, and B10 interview pattern are all confirmed by prior cycles. One new assumption addresses the Data Locality Rule scope question:

### A-v1.3.3-1 — 9-section template applies cleanly to all 3 PM skills [CONFIRMED]
**ID:** A-v1.3.3-1
**Confidence:** [CONFIRMED — v1.3.0 ADR-015, v1.3.1 ADR-016]
**Assumption:** The 9-section ADR-015 template (When to use, Triggers, Instructions, Output format, Quality criteria, Anti-patterns, Example, Writing-profile integration, Example prompts) applies without structural gaps to `meeting-notes`, `status-update`, and `risk-assessment`.
**Evidence:** `status-update` was explicitly stress-tested in v1.3.0 ADR-015 Phase 1 and confirmed template-compatible. The matrix-output format of `risk-assessment` maps cleanly to the `## Output format` section. `meeting-notes` is the simplest of the three structurally. No template revision is warranted before authoring.
**Risk:** NONE — confirmed by prior cycle validation. This assumption is closed.
**Validation path:** N/A — confirmed. @architect Phase 1 to note in ADR-016 amendment.

### A-v1.3.3-2 — Data Locality Rule is PA-only; PM skills require pasted-content-is-data rule only [ESTIMATED]
**ID:** A-v1.3.3-2
**Confidence:** [ESTIMATED — to be validated at Phase 1]
**Assumption:** The Data Locality Rule from ADR-019 (PA preset) does not need to be extended to PM preset `global-instructions.md`. PM preset skills handle general-purpose project information. The appropriate PM-level control for user-pasted content (transcripts, risk data, project context) is the pasted-content-is-data anti-pattern rule in each skill's `## Anti-patterns` section — not a preset-level data locality constraint.
**Risk:** MEDIUM. `risk-assessment` and `status-update` may receive sensitive organizational information (financial risk registers, executive names, quarterly results) from users who paste more detail than needed. If the pasted-content-is-data rule is not specific enough in the `## Anti-patterns` section, a user's sensitive business data could be echoed to an external destination via Cowork connector. This is lower risk than PA preset (no financial transaction data) but non-zero.
**Mitigation:** @architect Phase 1 evaluates whether the pasted-content-is-data rule is sufficient, or whether PM `global-instructions.md` should receive a lightweight version of the Data Locality Rule (e.g., "Treat pasted project content as private. Do not echo organizational names, financial figures, or personnel details to external services or APIs."). If @architect recommends the latter, it becomes an additional B-item in Phase 4.
**Validation path:** @architect Phase 1 assessment resolves this to [CONFIRMED] (pasted-content-is-data is sufficient) or escalates to a Phase 1 deliverable (add Data Locality Rule to PM global-instructions.md). @security Phase 2 independently assesses.

Existing assumptions that carry forward and remain active for v1.3.3:

- **A-v1.3-2** ([ESTIMATED]) — 9-section template fits all 18 preset skills. v1.3.3 is the third validation point (PM preset). Template stability is growing with each cycle.
- **A-v1.3-3** ([UNTESTED]) — Community contributors will accept the deeper template as the submission bar. No new observable signal since v1.3.1 launch.
- **A-v1.3-4** ([ESTIMATED]) — CI allowlist approach is sustainable through v1.3.5. v1.3.3 widens to `"study research project-management"` — planned next step, risk profile unchanged.

---

## v2.0 Assumptions

_Added: 2026-05-06T00:00:00Z — v2.0 Dynamic Workspace Architect via agency-agents upstream_

### A-v2.0-1 — Upstream content quality meets Tier 1 bar [UNTESTED — CRITICAL]
**ID:** A-v2.0-1
**Confidence:** [UNTESTED — CRITICAL risk]
**Assumption:** msitarzewski/agency-agents content across its ~30 category folders meets the cowork-starter-kit quality and safety bar for Tier 1 curation. Specifically: skills contain no shell execution commands, no environment variable references, no network calls, no prompt injection payloads, and produce high-quality, coherent output for their declared purposes.
**Risk:** CRITICAL. If upstream content quality is below bar, the allowlist policy (F4) may be admitting low-quality or unsafe content under a "Tier 1" label that users trust by default. This would undermine the core safety differentiator.
**Mitigation:** @security Phase 2 must audit a representative sample of upstream content before any allowlisted files are added to the lock file (F1). The allowlist policy (F4) `requires_review` list is the mechanism for flagging files that pass quality checks but warrant user-visible warnings. If audit finds systemic quality issues, the upstream may need to be reclassified as Tier 2 (opt-in, with warnings) rather than Tier 1 (default, trusted).
**Validation path:** @security Phase 2 audit of ≥3 files per allowlisted category folder. If >20% of audited files fail quality criteria, escalate to @pm for v2.0 scope re-evaluation (upstream = Tier 2, not Tier 1).

### A-v2.0-2 — Users accept upstream category suggestions without needing to know what "agency-agents" is [UNTESTED — MEDIUM risk]
**ID:** A-v2.0-2
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** Non-technical users (Jordan, Alex, Maria archetypes) will respond positively to upstream category suggestions in the wizard without requiring an explanation of the agency-agents repo, GitHub, or MIT licensing. The wizard's framing ("I found content in the [academic] workspace library for your goal") is sufficient for them to make a decision.
**Risk:** Users who don't understand where the content comes from may distrust it ("Why is it pulling from GitHub?") or, conversely, install everything without exercising judgment (over-trust). Both failure modes are possible.
**Mitigation:** Wizard framing avoids "GitHub" and "repository" language. Instead: "the upstream workspace library." Attribution block (F5) is present in installed files for users who want to trace provenance. SETUP-CHECKLIST.md includes a one-line explainer: "Content comes from a curated library of workspace configurations, verified and approved for use."
**Validation path:** User smoke test: present the v2.0 goal interview to 2–3 non-technical users. Observe whether they ask "where does this content come from?" and whether the attribution block causes confusion or reassurance. Adjust framing before Phase 7 if >50% of test users express confusion.

### A-v2.0-3 — LLM wizard can verify SHA-256 at install time [ESTIMATED — MEDIUM risk]
**ID:** A-v2.0-3
**Confidence:** [ESTIMATED — MEDIUM risk]
**Assumption:** The wizard (running as an LLM in a Cowork Project) can perform SHA-256 checksum comparison at install time by: (a) fetching the file content from the pinned URL, (b) computing or receiving the SHA-256 hash, and (c) comparing against the lock file value. The LLM has sufficient capability and context to perform this verification reliably.
**Risk:** LLMs do not natively compute cryptographic hashes. If the verification step requires hash computation, the wizard may fail silently or produce incorrect results. An incorrect hash comparison is worse than no comparison — it provides false assurance.
**Mitigation:** @architect Phase 1 must resolve the verification mechanism. Option A: the wizard trusts the CI-pre-verified lock file as the source of truth and simply confirms the URL is on the lock file's allowed list (no re-computation at runtime). Option B: the wizard fetches the content and the hash is pre-computed and stored in the lock file for comparison. Option A (trust the CI-vetted lock file) is safer given LLM limitations on cryptographic operations.
**Validation path:** @architect Phase 1 decision. Whichever Option is chosen, it becomes an AC in F1 and must be testable at Phase 5.

### A-v2.0-4 — Monthly /sync-agency cadence matches user expectations of content freshness [ESTIMATED — LOW risk]
**ID:** A-v2.0-4
**Confidence:** [ESTIMATED — LOW risk]
**Assumption:** Users who install agency-agents content via the v2.0 wizard will accept that the content reflects the upstream repo state at the last `/sync-agency` run (monthly cadence), not the live upstream HEAD. A 30-day staleness window is acceptable for workspace configuration content (unlike, e.g., a security patch or a live data feed).
**Risk:** If upstream releases a substantially improved skill in week 2 of a monthly window, users who install that week get the older version. This is a freshness gap, not a security gap (the pinned SHA is still integrity-verified). Risk is LOW for workspace configuration content.
**Mitigation:** Manual `workflow_dispatch` on the sync workflow allows an out-of-cycle bump when a significant upstream update is worth reviewing. CHANGELOG notes the last sync date. Users who want the absolute latest can trigger a manual sync.
**Validation path:** No specific validation required — this is an accepted design trade-off documented in F3 open questions. @architect Phase 1 finalizes the cadence decision.

### A-v2.0-5 — v1.x users accept examples/ relocation without significant friction [UNTESTED — LOW risk]
**ID:** A-v2.0-5
**Confidence:** [UNTESTED — LOW risk]
**Assumption:** Existing v1.x users who have installed preset content from `presets/<name>/` will successfully update their mental model to `examples/<name>/` without confusion or support requests. The migration is non-destructive (files are byte-identical) but the path change may break hardcoded references in user scripts or aliases.
**Risk:** LOW for most users (most have no scripted references to preset paths). MEDIUM for power users who have automated Cowork workspace refresh scripts or shared preset paths with teammates.
**Mitigation:** CHANGELOG `[2.0.0]` documents the path change prominently. README migration section includes a "find and replace" one-liner for users with hardcoded paths. `/setup-wizard --upgrade` flow surfaces the new paths explicitly.
**Validation path:** Monitor GitHub issues for "path not found" or "preset missing" reports in the 30 days post-v2.0 launch. If >3 reports cite the relocation as the cause, add a backward-compatibility symlink or redirect note.

### A-v2.0-6 — MIT license attribution in F5 satisfies license requirements for derivative works [CONFIRMED — pending /legal]
**ID:** A-v2.0-6
**Confidence:** [CONFIRMED — pending @compliance /legal validation at Phase 2]
**Assumption:** The MIT license from msitarzewski/agency-agents requires: (a) copyright notice preserved in all copies or substantial portions, and (b) the license text itself included. The F5 attribution block (source, upstream path, pinned commit, license statement, derivative-work notice) satisfies both requirements for files distributed via the cowork-starter-kit public repo.
**Risk:** MEDIUM if the attribution format is incomplete. Incorrect attribution creates legal exposure for the project and for users who distribute derivative work. @compliance must validate the exact format before Phase 4.
**Mitigation:** F5 attribution block is designed to cover both MIT requirements. @compliance (/legal Phase 2) is mandatory for this cycle precisely to validate this assumption.
**Validation path:** @compliance Phase 2 review of F5 attribution format. Output: either [CONFIRMED] with the exact attribution text approved, or a revised attribution format that satisfies MIT requirements. No Phase 4 implementation of F5 begins without @compliance sign-off.

### A-v2.0-7 — nexus-strategy.md architectural collision is a permanent constraint, not a temporary one [CONFIRMED]
**ID:** A-v2.0-7
**Confidence:** [CONFIRMED]
**Assumption:** The NEXUS framework in `nexus-strategy.md` defines a competing top-level orchestration model that directly conflicts with cowork-starter-kit's wizard orchestration and The-Council pipeline. This conflict is structural, not versional — a future version of NEXUS that resolves the collision would require a new architectural review before any unblocking is considered.
**Risk:** NONE — the block is permanent until explicitly reviewed and lifted by an architecture decision (Phase 1 ADR). This assumption is a design constraint, not a hypothesis.
**Validation path:** N/A — confirmed. The block is enforced by F4 CI check. Any future proposal to unblock nexus-strategy.md triggers a new @architect + @security review cycle.

---

## v2.1 Assumptions — FSM v2 Team-Composition + S3 ADR + Content Audit

### A-v2.1-1 — Users want compose-from-objective, not pick-a-preset [UNTESTED — HIGH risk]

**ID:** A-v2.1-1
**Confidence:** [UNTESTED — HIGH risk]
**Assumption:** The user's stated JTBD signal ("I want a workspace that composes a team of agents/skills for whatever objective I bring") represents a broadly held user preference — not just the project owner's mental model. The majority of cowork-starter-kit users approach setup with an objective in mind ("I'm launching a product," "I'm writing a thesis") rather than a domain category ("I need the academic preset").
**Risk:** HIGH. If most users actually prefer the preset-menu path and find objective-first language confusing or ambiguous, the v2.1 wizard rewrite (W2-F1) could degrade onboarding for the Alex/Jordan primary personas who have responded well to the current structured menu approach. The current wizard (CLAUDE.md) has never been tested with objective-first language against real users.
**Mitigation:** (a) The existing preset/category routing is preserved as the underlying routing engine — only the ENTRY LANGUAGE changes from "pick a category" to "describe your objective." If the objective-to-category mapping fails, the wizard can fall back to the menu. (b) The Riley product-launch stress-test at Phase 5 validates the happy-path. (c) Jordan/Alex single-category paths are explicitly protected in AC-W2-3 — no multi-category prompt for unambiguous objectives.
**Validation path:** This assumption requires pre-launch user testing before v2.2 doubles down on the objective-first paradigm. Recommended validation at Phase 3 gate: user acceptance review of the rewritten CLAUDE.md Phase 1 prompt (is it clearer or more confusing than the current menu?). Treat Phase 3 as the first validation checkpoint — @architect and @security should both review the rewritten prompt for clarity, not just security.

### A-v2.1-2 — Pinned-digest (content_sha256) is the optimal second trust anchor mechanism [ESTIMATED — MEDIUM risk]

**ID:** A-v2.1-2
**Confidence:** [ESTIMATED — MEDIUM risk]
**Assumption:** The pinned-digest approach (extending lock schema with `content_sha256` = SHA-256 of file content computed at sync-agency fetch time) is the right architectural choice for the second trust anchor — preferable to cosign/Sigstore (too heavy for v2.1 doc-only ADR) and file-hash-registry (circular failure mode).
**Risk:** MEDIUM. @architect may conclude that cosign is the right long-term architecture even if implemented in v2.2+, and that documenting pinned-digest in ADR-028 creates a dead-end (if the v2.2 implementation then chooses cosign, ADR-028 must be superseded). The risk is wasted ADR specification, not a security gap.
**Mitigation:** ADR-028 should explicitly state it is "the preferred mechanism pending v2.2 implementation review" — not a final commitment. If @architect's Phase 1 analysis concludes that cosign is clearly superior for v2.2 implementation, ADR-028 can document cosign as the decision while retaining pinned-digest as an intermediate milestone. The ADR purpose (closing S3 carry-forward architecturally) is served by specifying any concrete mechanism.
**Validation path:** @architect Phase 1 trade-off review. If @architect selects a different mechanism than pinned-digest, spec.md W1-F1 trade-off table should be updated to reflect the decision rationale.

### A-v2.1-3 — Objective-first CLAUDE.md rewrite fits within the ≤ 370-word soft target [ESTIMATED — LOW risk]

**ID:** A-v2.1-3
**Confidence:** [ESTIMATED — LOW risk]
**Assumption:** Rewriting CLAUDE.md Phase 1 from goal-discovery to objective-discovery language — while adding team-framing to the multi-category disambiguation path — will not push the total word count above the 370-word soft target (363 words current). The rewrite is a substitution of existing language, not an addition.
**Risk:** LOW. CLAUDE.md is currently at 363 words (7 words below the soft target). The Phase 1 rewrite is replacing existing prompt text, not adding new sections. The CI hard cap (400 words) provides a safety buffer of 37 words above the soft target.
**Mitigation:** If the rewrite exceeds 370 words, overflow moves to WIZARD.md per the ADR-021 overflow precedent. CI enforces the 400-word hard cap as the absolute gate.
**Validation path:** @dev confirms word count with `wc -w CLAUDE.md` before committing. CI word-count check is the automated gate.

### A-v2.1-4 — cowork-profile.md Objective field addition is backward-compatible [UNTESTED — LOW risk]

**ID:** A-v2.1-4
**Confidence:** [UNTESTED — LOW risk]
**Assumption:** Adding an `Objective` field to the cowork-profile.md template does not break existing v2.0.x user profiles. Existing profiles omit the Objective field; the resume path must treat an absent Objective as "ask the user" rather than an error.
**Risk:** LOW. cowork-profile.md is a user-owned file (not version-controlled). The wizard reads it for context but does not validate its schema. An absent field is already the expected state for new installs.
**Mitigation:** AC-W2-7 specifies that the resume path degrades gracefully when the Objective field is absent. The field is optional in the template (labeled "Objective: (fill in)") — wizard fills it during Phase 4 Full Setup, not as a required Q1 input.
**Validation path:** @qa Phase 5 test: open a v2.0.x cowork-profile.md (without Objective field) and run the resume flow — confirm the wizard asks for the objective rather than erroring or producing a broken flow.

### A-v2.1-5 — All 9 prior open issues are fully closed by v2.0.2 [CONFIRMED]

**ID:** A-v2.1-5
**Confidence:** [CONFIRMED]
**Assumption:** Issues #14, #15, #16, #17, #18, #19, #20, #21, #23 are all closed as of v2.0.2 merge. No code changes are required in v2.1 to address these issues.
**Risk:** NONE — confirmed via CHANGELOG audit in v2.1 Phase 0 discovery. Each issue has a corresponding CHANGELOG entry in v2.0.1 (#16) or v2.0.2 (#13–#15, #17–#21, #23).
**Mitigation:** N/A — confirmed.
**Validation path:** At Phase 4, @dev confirms no open issues labeled v2.0.1 remain on GitHub. If any are found open (GitHub label lag), they are closed by @dev with a comment referencing the resolving CHANGELOG entry — no code change required.


## v2.2 Assumptions

_Added: 2026-05-08T00:00:00Z — v2.2 Carry-Forward Closeout + Skills Roadmap Discovery_

### A-v2.2-1 — Anthropic runtime hosted skills remain available in Claude Code / Claude.ai sessions [ESTIMATED — LOW risk]
**ID:** A-v2.2-1
**Confidence:** [ESTIMATED — LOW risk]
**Assumption:** The Anthropic-hosted XLSX/PPTX/DOCX/PDF skills (referenced in WIZARD.md §Also and SETUP-CHECKLIST.md §63) remain available to Claude Code and Claude.ai sessions throughout v2.2 and v2.3 planning. The W2 coverage matrix treats these as RUNTIME coverage, not EMPTY gaps.
**Risk:** LOW. If Anthropic deprecates these hosted skills, J7 (data/spreadsheet) and J9 (slides) shift from RUNTIME to EMPTY in the coverage matrix — upgrading the urgency of external skill import or in-tree development. This would not block v2.2 delivery, but would make v2.3 recommendations more urgent.
**Validation path:** W2 author (@dev at Phase 4) should verify at time of writing that the hosted skills are still accessible. If deprecated, update matrix cells from RUNTIME to EMPTY and re-score the v2.3 candidate list accordingly.

### A-v2.2-2 — Stopword list of ~50 common English words is sufficient for all current stub descriptions [ESTIMATED — LOW risk]
**ID:** A-v2.2-2
**Confidence:** [ESTIMATED — LOW risk]
**Assumption:** The 12 stub skill descriptions currently in the registry are either (a) substantive (contain real keywords beyond stopwords) or (b) placeholder/stopword-only. A 50-word stopword filter is sufficient to distinguish these two cases for all current and near-future stub descriptions.
**Risk:** LOW. If a stub description has exactly one marginally meaningful word surrounded by stopwords, the filter may produce false positive (real description incorrectly triggering fallback). A borderline case would need a second @qa fixture beyond the primary "the a of" case.
**Validation path:** @dev at Phase 4 must test the stopword filter against all 12 current stub descriptions and confirm no false positives or false negatives.

### A-v2.2-3 — W2 skills-roadmap.md will not require @architect input at Phase 4 [ESTIMATED — MEDIUM risk]
**ID:** A-v2.2-3
**Confidence:** [ESTIMATED — MEDIUM risk]
**Assumption:** The W2 roadmap is a planning artifact (prose + tables), not an architectural decision. @dev can produce it from v2.2 research files and personas.md without requiring a Phase 1 ADR or Phase 2 review. The roadmap does not modify any existing architecture surfaces.
**Risk:** MEDIUM. If @dev's roadmap analysis produces a recommendation that contradicts an existing ADR or implies an architectural change in v2.2 scope, @pm must review before Phase 5. Gate: if skills-roadmap.md contains any statement implying a v2.2-cycle architectural commitment, escalate to @architect before Phase 5 sign-off.
**Validation path:** @qa Phase 5 confirms that skills-roadmap.md contains no v2.2-cycle architectural commitments — it is a v2.3+ planning artifact only.
