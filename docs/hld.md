# High-Level Design — Cowork as a Living Engine

**Status:** Planning (PURE-DOC). This document is a design horizon, not a committed build. Each rung named here earns its own spec, its own architecture decisions (ADRs), and its own security review before any of it merges. Nothing below changes the shipped kit until it goes through that pipeline.

**Baseline:** v2.15.0. This design picks up where the shipped kit stands today and describes where it is going.

> This is a public design document written at trust-model level. It describes the security posture the way [`TRUST.md`](../TRUST.md) does — honestly, including the limits — without publishing a step-by-step guide to attacking the kit. The sharp internal detail (exact scanner recipes, the full adversary bypass-class catalog, the detailed spawn-ceremony threat model) belongs in a `docs/internal/` companion, not here.

---

## 1. The reframe

The Cowork Starter Kit began as a **starter kit**: you clone it once, the wizard interviews you, and you walk away with a personalized workspace. That framing has a built-in ceiling — the moment setup ends, the kit is done with you. Improvements you'd benefit from never arrive. Skills you build never help anyone else. The workspace slowly drifts from the reference-quality state the wizard left it in.

This design retires "starter kit" and replaces it with three joined ideas:

- **A persistency layer.** A space stays connected to the pool it came from, so curated improvements can reach it over time — with your permission, never silently.
- **A bidirectional community registry.** Two directions over one shared substrate: **push** (a skill you built and proved flows *up* toward the curated pool) and **pull** (a curated improvement flows *down* into your space).
- **A space-spawning engine.** From inside a live space, you can ask for a new capability — "now help me manage my finances" — and the engine generates a new, fully-capable, isolated sibling space from the local pool. (A parent view that keeps the whole picture across spaces is a later, local-filesystem addition — see §8a.)

The one-time clone becomes a living relationship. The kit stops being a thing you *ran once* and becomes a thing your workspace *stays part of*.

## 2. North Star

**Cowork becomes the standard way to start a Claude Cowork space** — the framework any successful space started on. A living engine: spaces evolve themselves, stay organized, pull improvements, spawn new spaces on demand, and a community feeds the skill pool that all of this draws from.

**The yardstick for every trade-off is non-technical-user empowerment.** Not "what can a developer wire together," but "what can someone who has never touched a terminal actually do, safely, from a chat window." When two designs compete, the one that a non-coder can use without fear wins.

## 3. Design principles (binding)

These constrain every rung. They are not goals to aspire to; they are the frame the rungs are built inside.

1. **Curated-first trust.** The maintainer vets everything into the curated pool while the verification pipeline is being built and battle-tested. The auto-verified community tier is *defined early but stays closed* until the gate has proven itself on real, gated traffic. The curated pool is the brand and the reputation; it is guarded accordingly.
2. **No runtime internet (the axiom).** Cowork sessions commonly run with no internet access, and the kit is designed for that as the default, not an error (see [`WIZARD.md`](../WIZARD.md) "Network & Offline Rule"). Nothing is fetched in a live session. Upstream content enters the repo *only* through maintainer-side CI. The lock file and any `source_url` are integrity anchors, **not** runtime fetch targets. Any capability that appears to need the network must either be an explicit, user-initiated, out-of-session step, or must not exist. This axiom directly shapes the pull flow (§5).
3. **One functional idea per version.** Each release delivers exactly one fully-working capability, publishes as a tag plus a Release, and then the ladder keeps climbing. No half-shipped surfaces spread across versions.
4. **Every self-modifying surface is permanently security-sensitive.** Any surface that writes an instruction file — apply (Loop 1), the Steward, the Engine's spawn, a community contribution landing in a workspace — carries a mandatory, permanent security review from its first line, regardless of blast radius. This is not negotiable per-cycle; it is standing.
5. **Automation never "makes it safe."** A motivated adversary can out-run any automated content scanner (see §11). Safety is therefore built from honest labeling, opt-in, blast-radius containment, a Unicode-canonicalization pre-pass, and re-scanning on every edit — never from the belief that the scanner caught everything. Every safety clause ships as an **executable check with a firing negative control** — a check proven able to fail, not prose that asserts safety.
6. **Nothing modifies a workspace without an explicit, individual confirmation.** Every self-modification is confirmed one at a time. Batching confirmations is a deferred convenience feature, not a shortcut the machinery is allowed to take.

## 4. The shared substrate (the architecture spine)

The whole program rests on one insight: **push and pull are the same machine pointed in two directions.** Rather than build a contribution pipeline and, separately, an update pipeline, the design builds one substrate first and layers both flows on top of it.

The substrate is **deliberately slim** — it carries only what a curated-only world actually needs, and no more. It has five parts:

1. **A standardized contribution format.** An extension of the existing 9-section skill standard already enforced in [`CONTRIBUTING.md`](../CONTRIBUTING.md) and `templates/skill-template/SKILL.md`. Both a community submission and a curated update speak this one format.
2. **A canonicalization pre-pass.** Unicode NFKC normalization, strip zero-width characters, flag mixed-script content — the cheap, deterministic step that neutralizes the lowest-effort evasion classes before anything else runs.
3. **A deterministic pattern scan.** The existing forbidden-token scan (ADR-055), extended, plus re-scanning on every edit (a one-time gate is not enough; content that changes after it was trusted is re-checked).
4. **A lock upgrade *and* a per-workspace install manifest (the KDQ-MANIFEST deliverable).** Today `cowork.lock.json` pins vendored upstream to exact commit SHAs (ADR-020) but records nothing about *which curated version of which skill a given workspace installed*. The substrate closes that gap: it adds a `last_synced_upstream_sha256` notion so a component carries *both* a version answer ("is something newer?") and a content-hash answer ("did the user edit this since they installed it?"), and it defines the per-workspace install manifest that records install provenance. Those together produce the update trichotomy the pull flow needs — and **the pull flow (v2.19) is this deliverable's first real consumer**, which is exactly why building it here, with a consumer waiting, keeps it honest (§5).
5. **A minimal two-tier registry schema.** The curated/community tier distinction from ADR-012, given just enough concrete schema for curated content to ride it. The community tier is **defined but closed** — the shape exists so both tiers share one skeleton, but no community-specific machinery is built ahead of need.

**What is deliberately *not* in the substrate: the LLM-judge.** A semantic "read this for injection intent" stage is real work, but on **curated-only** traffic it adds cost without adding safety — the maintainer's own review of every curated submission is strictly stronger than an automated judge. The LLM-judge is therefore **deferred to the intake rung (v2.20)**, where genuinely untrusted content first arrives and the judge finally earns its keep. Building the substrate curated-only means it hardens against friendly, gated traffic under human review *before* any automated judge is ever load-bearing for untrusted content.

## 5. The pull flow (persistency layer)

**The problem:** a curated skill improves. How does that reach a workspace that installed the older version months ago, without silently overwriting the personalization the user added?

**The mechanism — a trichotomy from one comparison.** For each installed component, compare the user's copy against the curated latest, using the lock's version field and content hash together:

- **Untouched** (matches the version the user installed, unedited) → *offer* the update in plain language.
- **User-customized** (edited since install) → *surface the conflict*; never overwrite a personalization. The user decides.
- **User-authored / not in the pool** → *never touched.* Their own skills are theirs.

Every offer is a plain-language, per-component confirmation. Personalization is never silently discarded. Because pull distributes **only curated content**, it is safe by construction — a user pulling updates is pulling from the pool the maintainer already guards.

**The binding constraint (the axiom, §3.2).** Pull cannot be a silent in-session fetch from GitHub — the kit's whole trust story is that a live space never phones home. So the *transport* of "is there something newer" is an open design question, carried as **KDQ-PULL**:

- **Option A — explicit opt-in online update step.** A capability the user deliberately turns on (mirroring Cowork's own user-side web-access toggle) that checks the curated registry once, on demand, out of the normal session flow. More capable; costs a small, honestly-labeled crack in the no-network default.
- **Option B — out-of-session nudge + guided re-download.** The kit never reaches the network from a session at all; updates arrive the way upstream already does — through a maintainer-published release the user re-downloads and the wizard reconciles against their workspace. Fully preserves the axiom; asks more of the user.

The recommended default is **out-of-session re-download (Option B)** because the no-network property is a load-bearing part of the trust model, not a convenience — an in-session fetch trades away the kit's clearest trust guarantee for a small UX gain. KDQ-PULL stays open and resolves at the pull rung's own `/spec`; the default going in is "preserve the axiom."

**Where per-workspace install state lives — now a substrate deliverable (KDQ-MANIFEST, resolved).** Today `cowork.lock.json` records the *maintainer-side vendored upstream*, and after the wizard's Step-7 handover it is archived into `_setup-kit/`. It does **not** record "which curated version of which skill this workspace installed" — and the trichotomy above cannot function without that record. This is no longer left open: the **per-workspace install manifest is an explicit deliverable of the Substrate rung (v2.18, §4.4)**, and the pull flow is its first consumer. The precise mechanism (extend the copied lock vs. a small standalone workspace manifest) is settled inside the substrate's own `/spec`; that a manifest exists is decided. The pull flow does not function without it.

## 6. The push flow (contribute up)

**The problem:** a non-technical user built a skill in their own workspace that genuinely works. How do they contribute it back without needing git, a fork, or a PR workflow?

**The mechanism — a cheap front door onto the existing ceremony:**

1. **Issue-form → bot.** The user fills a structured GitHub issue form — no git, no clone. A bot reads the form and scaffolds the pull request for them.
2. **The verification pipeline runs** — the substrate's canonicalize → deterministic scan (§4), **plus the LLM-judge, which is introduced at this rung.** Intake is the first place genuinely untrusted content arrives, so it is the first place the semantic injection-intent judge earns its cost. On the curated-only traffic before intake, a maintainer's own review was strictly stronger than an automated judge; here, at volume, the judge becomes a real second layer.
3. **The submission lands in the maintainer review queue** as a curated-pool candidate — it does *not* auto-publish. This reuses the existing [`PROMOTE.md`](../PROMOTE.md) promotion ceremony (ADR-051): fresh quality-and-safety re-grading at submission time, a forbidden-token re-scan, and a plain-language "confirm nothing private is in here" check.
4. **A maintainer approves** it into the curated pool, or doesn't.

A hosted, guided web form is a better non-coder experience still, but it carries real build cost — it is a *later* upgrade (§ Later, roadmap), taken only if submission volume justifies it. The issue-form is the cheap thing that ships first.

**Intake is demand-gated, not calendar-gated.** It ships when a real demand signal appears — roughly five organic "how do I contribute?" issues from actual users — not on a fixed quarter slot. Building the contribution front door before anyone is asking to walk through it would be speculative; the demand signal is the trigger.

Curated-first (§3.1) means this whole flow runs in *curated mode* first: contributions are possible and fully gated, and the pipeline hardens against real submissions long before the community tier is ever opened.

## 7. The Steward (a space that keeps itself reference-quality)

A workspace drifts. Files pile up in the wrong place; the folder structure the wizard set up on day one stops matching reality; the same friction recurs and nobody notices. The Steward is the capability that keeps a space at the quality the wizard left it in — **always by proposing, never by acting silently.**

Three behaviors, all reusing the confirm → apply → verify → rollback machinery that Loop 1's apply step establishes:

- **Auto-cleaning.** The Steward notices drift and *proposes* an archive or a move — a confirmed file operation, never a silent one. (This is a lower-risk write than an instruction-content edit: it moves files the user already has, it does not ingest new instruction text.)
- **Living organization.** The workspace's `folder-structure.md` becomes a *maintained contract* rather than a setup-day artifact — the Steward keeps it honest as the space evolves.
- **Promote-repetitive-to-Skill.** The v2.15 memory-of-use ledger already notices when the same friction recurs. The Steward routes that noticed repetition into a proposal to build a Skill for it (via Skill Studio) — closing the loop from "you keep doing this by hand" to "here is a skill that does it."

The Steward is a genuine second self-modifying surface, so it inherits every §3.4 and §3.5 obligation. Its file-move operations are the lightest of those obligations; its promote-to-Skill path is the heaviest, and reuses the fully-gated Skill Studio + promotion machinery rather than inventing a new one.

## 8. The Engine (space-spawning) — the North-Star release

This is the release where "starter kit" dies and the engine is born. From inside a live space, a user says "now help me manage my finances," and the engine **generates a new, fully-capable, isolated sibling space** from the local pool, carrying the latest installed skills.

**v3.0 is spawn-only, deliberately.** The parent / hub view — the single pane that keeps the full picture across all of a user's spaces — is **decoupled into a separate, later rung (v3.x, §8a).** Spawning is what makes "the engine is born" true; it stands entirely on its own and does not need the hub to be valuable. Coupling the two would have held the North-Star release hostage to a platform-isolation question that — as the completed feasibility spike now confirms (§8a) — has no native answer. So spawn ships first; the hub follows later as a local-filesystem design.

**Forward-compatibility note (cheap now, avoids rework at v3.x).** Because the hub can only ever be a *local-filesystem* view (§8a), v3.0 spawn must lay the groundwork for it while it is free to do so: **each new sibling space is seeded under a shared parent directory, and each is given a status-card write obligation** — a compact, on-disk status file (the `registry.json` + `pipeline.md` pattern The-Council uses on itself) that a future hub space can read. This costs almost nothing at spawn time and is the difference between a v3.x hub that just works and one that requires re-spawning every existing space.

**It is tractable under the axiom.** Spawning generates from the *local pool* — no fetch is needed, so the no-network constraint (§3.2) does not block it. "With updated skills" simply chains the pull flow (v2.19) first: update the pool, then spawn carries the latest. Spawning and pulling compose cleanly — and because pull ships well before v3.0, "spawn the latest" is real by the time the Engine exists.

**It is the biggest blast-radius surface the kit will ever have.** Loop 1's apply edits *one* instruction file; the Engine writes an *entire new instruction tree*. Its spawn ceremony must therefore reuse and *exceed* Loop 1's confirm → apply → verify gate — this is not a place to relax the discipline, it is the place it matters most.

**The open question that stays with v3.0:**

- **KDQ-SPAWN-SEC — the spawn ceremony.** Writing a whole new instruction tree is the maximal self-modification. What does a gate stronger than Loop 1's apply look like, and how is the generated tree verified before it becomes a live space the user trusts? This belongs to v3.0's own dedicated design cycle.

**This rung needs its own dedicated design cycle** — its own spec and its own plan. It is deliberately the least-designed rung here, and the rest of the ladder is built so it does **not** depend on the Engine's internals. The persistency layer and the community registry stand on their own; the Engine is the capstone they enable, not a prerequisite they wait on.

### 8a. The hub view (v3.x — local-filesystem design)

The parent / hub view answers "let a user see and coordinate all their spawned spaces from one place." A feasibility spike ran this question ahead of the ladder to retire the program's biggest structural unknown early — and it has **completed with a clear verdict.**

**KDQ-HUB — answered. A native cross-space hub view is NOT feasible, and never will be.** Claude Cowork Projects are hard-isolated by platform design: each project is an isolated context and nothing leaks across projects, there is no cross-project reference mechanism, and none is announced (the only adjacent item is an *unshipped* request for subfolders *within* a single project). No amount of design gets a parent space to natively read a sibling's live context. That door is closed.

**But v3.x survives — re-scoped as a local-filesystem hub.** The spike also found two workarounds that hold entirely inside the no-runtime-internet axiom, because Cowork Projects are backed by real local folders:

1. **Filesystem hub.** A designated "hub" space rooted at the *parent* directory reads every sibling space's on-disk files directly — plain filesystem access, not a platform API. Its honest limit: it sees only what siblings have *written to disk*, never a sibling's live in-session context. That is a real constraint, not a defect — it is the most any local design can offer, and it is stated plainly rather than papered over.
2. **Registry + status-card pattern.** Each sibling writes a compact status card to a shared path; the hub reads them to reconstruct a full picture. This mirrors the `registry.json` + `pipeline.md` design The-Council already uses on itself — a proven, pull-based, offline-consistent shape.

This is why v3.0 spawn carries the forward-compatibility obligation in §8 (shared parent directory + a status-card write on every spawn): it is what makes either workaround possible without re-spawning existing spaces later. v3.x is no longer gated on *whether* a hub is possible — that is settled — only on *when* the local-filesystem design is scheduled.

*Sources (trust-model level): the Claude Cowork / Projects support documentation on project isolation, Anthropic's Projects announcement, and the Claude Code cross-project reference request (issue #68262) — all consulted directly during the spike, not recalled.*

## 9. The two-tier trust model

Two tiers, one schema (§4.5):

- **Curated tier.** Maintainer-vetted. This is the brand asset — the maintainer's name on the content. It is what pull distributes and what a contribution aspires to land in.
- **Community tier.** Honestly labeled, opt-in, quarantined, blast-radius-contained. This is the *funnel* — the volume path that lets the pool grow faster than one maintainer can author. It is **defined at substrate time but stays closed** until the verification gate has proven itself, and it only opens with a documented promotion-to-curated path (roadmap v3.1).

The split is deliberate and honest: because automation cannot fully out-review a motivated adversary (§11), the curated tier carries the trust and the community tier carries the volume, and users always know which one they are looking at.

## 10. How this reuses what already exists

Almost nothing here is built from scratch. The program is, deliberately, a *composition of primitives the kit already has* — which is what makes an ambitious roadmap tractable for a small maintainer team.

| New capability | Reuses (already shipped or committed) |
|---|---|
| The verifier on every applied change (Steward, Engine) | v2.16 confirm → apply → verify → rollback machinery (Loop 1) |
| The behavioral grader inside that verifier | v2.13 eval-loop grader (Loop 2, already shipped) |
| Promote-repetitive-to-Skill (Steward) | v2.15 memory-of-use ledger + Skill Studio |
| The contribution format (substrate) | The 9-section standard in `CONTRIBUTING.md` + `templates/skill-template/SKILL.md` |
| The deterministic scan layer (substrate) | The forbidden-token scan (`CONTRIBUTING.md`, ADR-055) |
| The lock upgrade (substrate) | `cowork.lock.json` + SHA-pinning (ADR-020) |
| Curated-promotion (push intake, community-tier promotion) | The `PROMOTE.md` ceremony (ADR-051) |
| The two-tier registry | The Tier 1/Tier 2 model (ADR-012), finally activated |
| The template a space is spawned from (Engine) | The clone-once preset template (ADR-034) |
| Attribution on any community content in a workspace | The non-overridable attribution injection (ADR-024) |

The reuse is also a design *constraint*: the shared substrate must stay a set of independently-testable primitives (canonicalize, scan, lock-trichotomy, tier labels), not congeal into one monolithic verification module that push, pull, Steward, and spawn all hang off. One over-loaded module would be a single point of failure for four surfaces at once.

## 11. Security posture (trust-model level)

The honest limit, stated plainly: **a solo maintainer cannot out-review a motivated adversary, and neither can an automated scanner.** Content-scanning defenses — pattern matching and even an LLM judge — are evaded by known techniques (homoglyphs, zero-width characters, diacritics, encoding, splitting an instruction across sections). Independent research puts the bypass rate for these techniques high enough that "the scanner makes it safe" is simply false.

So the kit does not claim the scanner makes it safe. It builds safety from the parts that *do* hold up:

- **Honest labeling.** A user always knows whether they are looking at curated (vetted, the maintainer's name on it) or community (opt-in, quarantined) content.
- **Opt-in and blast-radius containment.** Untrusted content is never load-bearing by default; the community tier stays closed until its gate is proven; every self-modification is individually confirmed.
- **A Unicode-canonicalization pre-pass** that neutralizes the cheapest evasion classes before any scan runs, plus **re-scanning on every edit** so content that changes after it was trusted is re-checked.
- **Executable checks with firing negative controls.** Every safety clause the kit ships is a check *demonstrated able to fail* on a crafted input — never a prose assertion of safety. A verifier that cannot fail is not a verifier.

**The defenses roll out in the order the threat arrives — automation is added only where it earns its cost.** While the pool is curated-only, the layers are canonicalization + the deterministic scan + the maintainer's own review, and that human review is strictly stronger than any automated judge on gated traffic. The **LLM-judge is not built into the curated-only substrate; it arrives with the intake rung (§6)**, the first point untrusted content actually flows in. This is the honest-labeling principle applied to the defenses themselves: no security theater, no automated stage standing in for a stronger human one it cannot match, and no untrusted-content machinery built before untrusted content exists.

This is the same discipline [`TRUST.md`](../TRUST.md) already commits to, extended to the self-modifying and community surfaces this program adds. The curated tier is the reputation; the community tier is the funnel; the honesty about the limit is what makes both trustworthy.

## 12. Consolidated open questions (for owner resolution)

These are the program-level decisions that shape the roadmap. Several were resolved in the owner's strategy stress-test; the rest resolve inside the rung that owns them. Each rung will also carry its own narrower questions into its own spec.

**Resolved (this planning cycle):**

| ID | Question | Resolution |
|---|---|---|
| **KDQ-SEQ** | After the substrate, does push-intake or pull-updates ship first? | **RESOLVED — pull first.** Pull is on the critical path to the v3.0 engine (spawn carries the latest skills) while intake feeds only the later community tier; pull forces KDQ-MANIFEST closed early with a real consumer; pull is the cheaper security spend (curated-only, safe by construction); and on the empowerment yardstick pull reaches *every* existing user, not just contributors. |
| **KDQ-MANIFEST** | Where does per-workspace install state live so the update trichotomy can function? | **RESOLVED — a per-workspace install manifest, delivered by the Substrate rung (v2.18).** That a manifest exists is decided; the exact mechanism (extend the copied lock vs. a standalone manifest) resolves in the substrate's own `/spec`. The pull rung (v2.19) is its first consumer. |
| **KDQ-PLACEMENT** | Do these two docs stay public, and where does sharp security detail live? | **RESOLVED — both public** (owner-confirmed), written at trust-model level. A `docs/internal/` companion may later hold the sharp detail deliberately kept out here (§13). |
| **KDQ-HUB** | *Can* a parent space see isolated child spaces at all under today's Cowork platform isolation? | **RESOLVED by the feasibility spike — no native capability exists** (Cowork Projects are hard-isolated; no cross-project reference mechanism, none announced). v3.x is therefore re-scoped as a **local-filesystem hub** (filesystem read of sibling folders + a registry/status-card pattern, §8a). v3.0 spawn carries the forward-compat obligation that makes it possible. |
| **KDQ-SUCCESS** | The 12-month success image, once the sequencing tie-breaker. | **No longer load-bearing for sequencing** (KDQ-SEQ is resolved without it). Remains useful context for later prioritization, but it is not gating anything now. |

**Still open (resolve at the owning rung's `/spec`):**

| ID | Question | Direction going in |
|---|---|---|
| **KDQ-PULL** | How does pull learn "something is newer" without violating the no-runtime-internet axiom? | **Default = preserve the axiom** via an out-of-session re-download nudge, not an in-session fetch. Resolves at the pull rung's `/spec` (v2.19). |
| **KDQ-SPAWN-SEC** | What gate — stronger than Loop 1's apply — governs writing an entire new instruction tree? | Belongs to v3.0's dedicated design cycle; must exceed, never relax, the apply gate. |
| **KDQ-BATCH** | Confirmation fatigue over many individual confirms. | Constraint now (confirm each self-modification individually); the batching *feature* stays deferred. |
| **KDQ-COMMUNITY-OPEN** | What measurably counts as "the gate is proven" before the community tier opens? | Define the exit criteria at substrate time so the community-tier rung has a bar to clear, not a vibe; the gate proves on real intake (v2.20) traffic. |

## 13. Document placement (RESOLVED — public)

**Decision: both documents stay public** (owner-confirmed, KDQ-PLACEMENT resolved). `docs/hld.md` and `docs/roadmap.md` are **not** under `docs/internal/`, and per the kit's default-internal convention (ADR-037) a new `docs/*.md` file ships to the public release archive unless placed under `docs/internal/`. Ground-truth against the release archive confirms both files export publicly, which is the intended outcome.

Both are therefore written at **trust-model level** — the security posture is advertised the way `TRUST.md` advertises it, with no exhaustive bypass-technique catalog and no step-by-step attack playbook. The sharp internal detail deliberately kept out of these public docs (exact scanner recipes, the full bypass-class taxonomy, the detailed spawn-ceremony threat model) **may later be recorded in a `docs/internal/` companion**, which the release archive excludes — authored if and when a rung's `/spec` needs that depth, not preemptively.

## 14. What this document is not

This is a design horizon, not a build order and not an architecture record. It writes **no ADRs** — every decision sketched here becomes a real, reviewed ADR inside the spec of the rung that implements it. It commits nothing. Each rung on the [roadmap](./roadmap.md) enters its own `/spec`, produces its own architecture, and passes its own security review before it ships. The one thing this document *does* commit to is the shape: one shared substrate, two directions over it, a Steward that keeps a space honest, and an Engine that lets a space spawn its own siblings — all measured against whether a non-technical user can use it safely.
