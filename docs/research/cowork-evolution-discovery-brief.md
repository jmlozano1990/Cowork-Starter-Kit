# Cowork Evolution Program — Discovery Brief (2026-07-19)

> **Research note** — this brief cites third-party research (Snyk, PromptArmor — both already cited in [`TRUST.md`](../../TRUST.md)) and the maintainer's own internal orchestration tooling ("Council") as a source of reusable process patterns, the same way this repo already documents its own development pipeline in [`docs/patterns.md`](../patterns.md), [`docs/retro.md`](../retro.md), and every `CHANGELOG.md` entry. None of that is a competing product for Cowork's end users; per the `no-competitor-naming-public` convention, none of it belongs in end-user-facing copy (README, CHANGELOG, release notes) — it stays in `docs/research/`, same as its precedent below.

**Purpose:** feed a future Phase 0 `/spec` for the **Cowork Evolution Program** — a workspace that keeps learning after setup ends, instead of being a one-time assembly. Owner directive (verbatim, 2026-07-19): *"keeps evolving and improving… mechanisms to create other skills, self improve itself and have a loop of learning and improving. (Kind of what council can do or a little of Hermes capabilities)… the end polish."* Plus, on the growth model: *"ask people to SUBMIT their skills to the repo, so it SELFS GROW… This will need security verifications etc etc but is a scalable idea."* This is a **discovery-first** pass per owner decision: no build this cycle, no changes outside this one file. Governing precedent: [`skill-studio-discovery-brief.md`](./skill-studio-discovery-brief.md) (PR #68), same discovery-first shape.

---

## 1. Problem — the workspace stops learning where the kit stops shipping

Every mechanism this kit ships today runs **once**, at setup, or **on demand**, per call. Nothing in a generated workspace watches its own use over time, notices a repeated friction, or proposes a fix. Skill Studio (v2.11.0/v2.12.0) closed the *authoring* gap — a workspace can now generate a skill it didn't ship with — but a generated skill still just sits there once installed. Nothing grades whether it's actually good, nothing promotes it if it is, and nothing carries the lesson back to anyone but the one user who found it.

Three concrete gaps, each evidenced against this repo's own record rather than assumed:

- **No feedback loop inside a workspace.** The kit's own development process runs a mini-retrospective after every cycle ([`docs/patterns.md`](../patterns.md) — the WATCH ledger promotes a recurring finding to a binding rule at three instances). A generated *workspace* has no equivalent: nothing notices "I've hand-corrected this skill's output the same way three times" and turns that into a proposal.
- **Generation without a grading pass.** [`CHANGELOG.md`](../../CHANGELOG.md)'s own Deferred sections name this directly — v2.11.0 deferred *"Quality evaluation beyond structural validation"* and *"A promotion path from a local generated skill into the shared pool"*; v2.12.0 repeats both, now dated for v2.13 and v2.14. Skill Studio can author a skill and check its shape (9 sections, 60-line floor); nothing checks whether it's actually *good* at the job, and nothing carries a proven-good skill anywhere beyond the one workspace that generated it.
- **A one-way registry.** [`curated-skills-registry.md`](../../curated-skills-registry.md) only ever grows through a maintainer-authored PR (see [`CONTRIBUTING.md`](../../CONTRIBUTING.md)'s preset-PR flow). A skill a user proves useful in their own daily use has no path back into the pool other than the maintainer independently deciding to build the same thing. [`docs/architecture.md`](../architecture.md) ADR-012 shipped a Tier 2 "community skill" model at v1.2 — but it was never wired into the live wizard flow (`WIZARD.md` has zero references to it today); it is dormant scaffolding, not a running loop.

**Framing:** the Cowork Evolution Program does not add more pool skills or a bigger wizard. It closes the gap between "a workspace that was assembled once" and "a workspace that keeps getting better because it's being used" — and, at the far end, lets a skill proven in real use travel back to benefit the next user. The maintainer's own daily-use workspaces are the motivating evidence for the authoring gap (see the linked precedent brief above for the detailed case); the same lived-in-workspace pattern — skills hand-corrected the same way repeatedly, with no mechanism to notice or fix that automatically — motivates this program.

---

## 2. Recommendation — one flywheel, three loops

Study all three loops together in this one brief (owner decision), because each loop produces the evidence or machinery the next one needs — but build them in phases (§9), not as one cycle.

| Loop | What it does | Status |
|---|---|---|
| **1 — Personal** | A workspace notices its own recurring friction and proposes a fix to itself, gated by user confirmation and an executable check. | New — this program's core build |
| **2 — Skill lifecycle** | A generated skill gets graded, then promoted into the shared local pool if it earns it. | Already queued (v2.13 eval-loop, v2.14 promote-to-pool) — this program gives it a home in the bigger picture, doesn't re-scope it |
| **3 — Community** | A skill proven across Loops 1+2 can be submitted upstream to the shared repo, verified automatically, and distributed to other users. | New — highest scope, highest safety bar |

Each loop is a superset of the one before it: Loop 2 needs Loop 1's evidence trail (a skill has actually been used and corrected) to know what to grade; Loop 3 needs Loop 2's grading pass (a skill has already earned local promotion) before it's a credible upstream submission. This is why §9 phases them in this order rather than building Loop 3 first for maximum "scalable idea" impact — an ungraded skill arriving at the community tier is exactly the failure mode §8 exists to prevent.

---

## 3. Loop 1 — Personal (mini-Council in the workspace)

The workspace runs its own small version of the maintainer's development discipline, scoped to itself.

**Trigger (owner decision — both, not either/or):**

- **Periodic:** riding the existing `weekly-review` cross-domain skill (`curated-skills-registry.md`, vetted 2026-07-19) — a Collect → Process → Review → Plan pass already built for exactly this cadence gains a fifth step: surface anything from the week's use worth turning into a lessons-ledger entry.
- **Threshold:** an immediate proposal the moment a friction repeats a third time — mirroring [`docs/patterns.md`](../patterns.md)'s own WATCH 1/3 → 2/3 → 3/3-BINDING promotion rule, at workspace scale instead of Council-portfolio scale.

**The loop, end to end:**

1. Workspace memory notices/records a friction (a correction, a repeated ask, a skill that keeps missing).
2. At the periodic or threshold trigger, the workspace drafts a proposed self-improvement (a skill edit, a new proactive-surfacing rule, a `CLAUDE.md` tweak).
3. The proposal is presented to the user in a plain-language confirmation surface (§6 — not a raw diff).
4. On confirmation, the change is applied.
5. The applied change must pass an executable verifier before it's considered "landed," not just "written" (§7).

**Why this is the highest-scrutiny loop despite being the smallest in scope:** it is the only loop that lets a workspace rewrite its *own* instructions without a human writing the diff by hand. See §8.

---

## 4. Loop 2 — Skill lifecycle (already queued, this program gives it a home)

This loop does not need new scoping — it is already committed on the roadmap, named explicitly in both the v2.11.0 and v2.12.0 `CHANGELOG.md` Deferred sections:

- **v2.13 — eval-loop.** Grades a generated skill's actual output quality (the with/without benchmark pattern [`docs/architecture.md`](../architecture.md) ADR-044 names as prior art, never adopted at Increment 1 because it was too heavy for a walking skeleton). Per the owner's known carry-forwards (F1/F2) and the external-link-check resilience item, v2.13 also absorbs those — this brief does not re-litigate that scope, only records that it is Loop 2's first increment.
- **v2.14 — promote-to-pool.** The back-port ceremony ADR-044 explicitly deferred: a local skill that earns it graduates from one workspace's `.claude/skills/` into the shared curated pool, under the existing ADR-024/ADR-043 attribution and sourcing ceremony.

This program's only addition to Loop 2 is context: it is not an isolated quality feature, it is the middle stage of the flywheel — Loop 1 supplies the "this skill has been used and corrected" evidence that makes a v2.13 grade meaningful, and a v2.14 promotion is the qualifying bar Loop 3 submissions should already have cleared.

---

## 5. Loop 3 — Community (self-growing repo, two-tier)

**Model (owner decision — two-tier, same repo, not a separate community repo):**

| Tier | Vetting | Where it lives | Install |
|---|---|---|---|
| **Curated** (today's pool) | Maintainer-vetted, SHA-pinned, `vetting_date` recorded | `curated-skills-registry.md` Tier 1 rows | Default — offered in the normal wizard flow |
| **Community** (new) | Automated CI verification only (no maintainer content review required to land) | A quarantined folder, clearly labeled, separate from the curated tree | Opt-in only, never offered by default |

This recycles machinery that already exists rather than building a parallel system:

- **The registry's own `tier` column** (`curated-skills-registry.md` schema: `tier` = `1` curated / `2` community) already anticipates exactly this split — Tier 2 currently reads *"No Tier 2 entries at v1.2 launch"*. This program is what finally populates it, through a real pipeline instead of a one-off PR.
- **`CONTRIBUTING.md`'s existing gates** — the 4-pattern automated scan the kit already runs on every incoming skill (9-section depth check, forbidden-token scan, injection-safety review, SHA-pinning verification) is the exact machine a community submission needs to clear before it can quarantine-land. No new CI concept, only a new trigger path feeding it.
- **The `SkillRisk.org` scan rule + DCO sign-off** (`CONTRIBUTING.md` §Skill content safety, §Developer Certificate of Origin) — already the contributor-facing bar; a community submission inherits it unchanged.

**What's genuinely new:** a submission does not arrive as a cold PR. Per the owner's framing, it arrives *pre-proven* — carrying a Loop 1/2 evidence trail (this skill was used, corrected until it stopped needing correction, and locally promoted) as part of what a maintainer or the automated gate is evaluating. §10 KDQ-4 names the open question of how that trail travels without leaking personal workspace data.

**Registry-dormant precedent, now resolved with intent:** ADR-012's Tier 2 design was correct in shape but never wired to a live trigger. This program does not redesign it — it finally builds the submission path that makes the existing schema real.

---

## 6. Council-recycle port table

Every mechanism this program needs already exists at Council-portfolio scale, in the maintainer's own development tooling for this repo. The program is substantially a port of proven process down to workspace scale, not a new invention:

| Council mechanism | Workspace/kit port |
|---|---|
| `docs/retro.md` per-cycle retrospective | Workspace mini-retro, run by the `weekly-review` ritual (§3) |
| `docs/patterns.md` WATCH 1/3 → 2/3 → 3/3-BINDING thresholds | Workspace lessons ledger (§3 threshold trigger) |
| `/self-improve` ceremony (propose → user-confirm → apply → verify) | Loop 1's four-step apply cycle (§3 steps 2–5) |
| Guard Change Summary (plain-language 4-part: what changed / what could break / what's protected / what to verify) | The confirmation surface for every workspace self-modification (§7) |
| Executable-check + firing-negative-control discipline | The verifier gate on every applied Loop 1 change (§7, §8) |
| ADR-043 author-not-adopt sourcing + SHA-pinning + registry tiers | Submission vetting machinery for Loop 3 (§5) |
| The v2.12.0 QA-1 lesson (independent fresh-fixture verification caught what two prior passes missed) | Independent fresh-fixture verification required before any self-modification lands (§8) |

This table is the honest accounting of "what's reusable vs. genuinely new" the owner asked for: every row on the left is proven machinery; every row on the right is a scoped, smaller-radius port of it, not a reinvention.

---

## 7. Hermes grounding — memory + verifier-gated learning, not RL

The owner's *"a little of Hermes capabilities"* reference is to NousResearch's Hermes line. Two properties of it map cleanly onto this program, and the mapping should stay honest about what does and doesn't transfer:

- **Verifier-gated acceptance.** Hermes 4's training keeps only trajectories that pass task-specific verifiers out of a much larger sampled set — a strict "did this actually work" filter before anything is kept. That is the *same shape* as this kit's own check-that-cannot-fail discipline (`docs/patterns.md`'s own WATCH ledger, §6 row 7): a change is not accepted because it looks right, it's accepted because an executable check — proven able to fail — passed. Loop 1's verifier gate (§8) is this principle at workspace scale.
- **Persistent memory across sessions.** Hermes Agent's memory survives beyond a single context window. Workspace memory (§10 KDQ-1) is the same property scoped to one workspace: what Loop 1 needs to notice a friction on its third occurrence is memory that outlives any one session.

**What this is not:** this program does not train a model, run reinforcement learning, or sample-and-filter trajectories at scale. The honest claim is narrower — *verifier-gated acceptance* and *persistent memory* are the two transferable ideas; the training methodology itself is out of scope and should never be implied in any spec or public copy that follows this brief.

---

## 8. Safety model

Headline first: **this is the biggest security surface the kit would ever have, and the two loops carry very different blast radii.**

**Loop 1 is a self-modifying instruction surface.** A workspace proposing and applying edits to its own `CLAUDE.md` / `SKILL.md` files is a categorically bigger risk than Skill Studio's one-shot generation, because it runs repeatedly, unattended between confirmations, against files that are auto-loaded as instructions every session. Binding program invariant: **every build increment that touches Loop 1 carries the mandatory Phase-2 `@security` hard gate, permanently** — this is not a one-time review that clears the feature, it is a standing requirement for every future change to it, the same way ADR-044 already made any edit to `skill-studio/SKILL.md` a permanent Phase 2 trigger.

Every safety clause in Loop 1 ships as **an executable check with a firing negative control** — never prose-only. This repo's own recent history is the receipt for why that's non-negotiable, not a hypothetical:

- v2.10.0/v2.11.0 (`docs/patterns.md` WATCH 2/3): the entire generator safety model was documented in prose and enforced by nothing except a structure-only validator, until Phase 4 converted all seven clauses into executable, negative-control-proven gates.
- v2.12.0 (`docs/patterns.md` WATCH 1/3, new row): a check that *was* executable and *was* proven firing — twice, by two separate passes — still shipped wrong, because a line-oriented `grep -E` anchor didn't hold across an embedded newline. It was caught only because Phase 5 `@qa` built a fresh fixture instead of re-running the design pass's own test set.

Both rows land on the same conclusion this program adopts as binding: **independent, fresh-fixture verification is not optional ceremony for Loop 1 — it is the only thing that has actually caught a real defect of this exact shape in this repo.**

**Loop 3 turns the kit into the exact thing its own [`TRUST.md`](../../TRUST.md) warns about.** The 36.82%-flawed / 76-confirmed-malicious Snyk figure and the PromptArmor injection disclosure are this kit's *own* cited threat model for why community skill ecosystems are dangerous by default. A community tier that doesn't out-verify that baseline is not a lesser version of the feature — it is disqualifying. What's reusable: `CONTRIBUTING.md`'s "community-maintained" posture, the SkillRisk rule, DCO sign-off, and the registry's tier/vetting_date/source_url columns (§5, §6). What's genuinely new: making the automated verification pipeline strong enough to be the actual product, not a formality in front of it.

**A gap this program surfaces in `TRUST.md` itself:** today's three-threat framing (malicious community skills / prompt injection / supply-chain tampering) does not name a fourth threat class — *a self-modifying local instruction surface* — because nothing in the kit has one yet. When Loop 1 ships, `TRUST.md` should gain a fourth entry. Flagged here as a follow-up, not scope for this discovery pass.

**Blast radius stays separated throughout the program:** Loop 1 changes are local-blast-radius (one workspace, reversible by the one user who confirmed them). Loop 3 is distribution-blast-radius (a bad submission could reach every future installer). The two are never allowed to share a confirmation surface or a verification bar — Loop 3's bar is strictly higher.

---

## 9. Phasing (proposal, for owner reaction)

**v2.13 eval-loop → v2.14 promote-to-pool (Loop 2, already queued) → Loop 1 mini-Council increments → Loop 3 community tier.**

Why this order, not a different one:

1. **Loop 2 is already committed and nearly free to sequence first** — it's on the roadmap regardless of this program, and it produces the grading machinery (§4) that both later loops depend on to know what "proven" means.
2. **Loop 1 before Loop 3** because Loop 3's core safety claim (§8) is that submissions arrive pre-proven by real use — that claim is only true if Loop 1 (the thing that produces "real use" evidence inside a workspace) exists first. Building Loop 3 first would mean shipping the community tier's verification promise before the evidence it's supposed to verify can even be generated.
3. **Loop 3 last** because it carries the highest blast radius (§8) and needs the most build-out (automated verification strong enough to be trusted as the product, not a formality).

**Where the owner could resequence:** if the "SUBMIT to the repo, self grows" idea is the priority the owner most wants visible progress on, Loop 3's *two-tier registry scaffolding* (populating the dormant Tier 2 schema, wiring the quarantine folder, no submission-provenance requirement yet) could be pulled forward as a structural-only slice — mirroring how Skill Studio's own Increment 1 shipped structural validation before quality grading. That would be a deliberate, named trade-off (shipping the container before the thing that proves what goes in it is safe), not a default recommendation.

---

## 10. Open questions for Phase 0 `/spec`

- **KDQ-1 — Workspace memory.** Where does it live, and what's its schema? Must survive a session boundary without exceeding the same word-budget discipline `CLAUDE.md` already lives under (ADR-011).
- **KDQ-2 — What is a "verifier" for a prose change?** Council's model verifies code with runnable checks. A Loop 1 change is usually a `SKILL.md` or `CLAUDE.md` edit — what's the executable proxy for "this instruction-surface edit actually does what it claims"?
- **KDQ-3 — Does the lessons ledger become an instruction surface itself?** The same class of risk `docs/patterns.md` row 7 (§8) names for a validated slug applies here: a ledger that's meant to be read as data must not be readable as instructions if it's ever surfaced back into a proactive context.
- **KDQ-4 — Submission provenance.** How does a Loop-1/2 evidence trail travel with a Loop 3 community PR without leaking personal workspace data (the exact content of what a user corrected, asked, or pasted)?
- **KDQ-5 — Quarantine folder mechanics.** Where does it live relative to `.claude/skills/`, and what's the opt-in install gesture — a wizard step, a standalone command, both?
- **KDQ-6 — Maintainer-gate cost.** What does reviewing a community submission cost the maintainer per item, and how much of that does the existing 4-pattern automated scan (§5) actually absorb versus just filter?
- **KDQ-7 — Threshold counting.** Is the "3rd repeat" trigger (§3) measured per-skill-need or per-session, and what resets the counter? Undefined, this could fire too eagerly or never at all.
- **KDQ-8 — Confirmation fatigue.** If Loop 1 proposes on a weekly cadence, does the plain-language confirmation surface (§6/§8) get batched or shortened over time — and if so, does that erode the "user MUST confirm every self-modification" hard requirement the owner set at shaping?

---

## 11. Precedent and inputs

- **Governing precedent:** [`skill-studio-discovery-brief.md`](./skill-studio-discovery-brief.md) (discovery-first shape, PR #68); ADR-012 (Tier 1/Tier 2 registry model, Tier 2 dormant since v1.2); ADR-041 (`goal_tags` — a second example of dormant-schema-activated-later, same pattern as this program's Tier 2 activation); ADR-043 (adapt-vs-author sourcing); ADR-044/045 (Skill Studio Increment 1 — generation + portable validator); ADR-046/047 (v2.12.0 — proactive surfacing + setup-trigger hook).
- **This repo's own process record, cited as reusable pattern (§6):** `docs/patterns.md` WATCH ledger; `docs/retro.md`; `CONTRIBUTING.md`'s existing verification gates.
- **Third-party research (research citations, per `TRUST.md` precedent):** Snyk "ToxicSkills" (Feb 2026); PromptArmor's Cowork disclosure (Jan 2026); NousResearch's Hermes line (verifier-gated acceptance + persistent memory, §7 — cited as a grounding analogy, not a training-methodology claim).
- **Owner workspace evidence:** referenced generically per this brief's privacy scope; full detail lives in the linked precedent brief (§1), not repeated here.

**Next step:** on owner greenlight, `/spec` converts this brief into a Phase 0 cycle. Recommended first increment per §9: v2.13 (eval-loop), already queued — this program's job is making sure the cycle after it (Loop 1's first mini-Council increment) is scoped with the full flywheel in view, not as an isolated feature.
