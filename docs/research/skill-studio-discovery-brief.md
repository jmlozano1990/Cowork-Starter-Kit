# Skill Studio — Discovery Brief (2026-07-19)

> **INTERNAL** — this brief names third-party tools/repos for research purposes. Per `no-competitor-naming-public`, none of that content may appear in public copy (README, CHANGELOG, release notes). Lives in `docs/research/` (excluded from the public archive per the release drop-list).

**Purpose:** feed a future Phase 0 `/spec` for **Skill Studio** — letting Cowork brainstorm a novel need with the user and author a new skill on the spot, instead of only assembling from the fixed pool. Owner directive (verbatim, 2026-07-19): *"We want that dynamism of Brainstorm the user and generate skills if needed"* — motivated by *"my study assistant not only allows me to learn or memorize, writes thesis with my voice."* This is a **discovery-first** pass per owner decision: no build this cycle. Governing precedent: **ADR-043** (adapt-vs-author sourcing).

---

## 1. Problem — the fixed-pool ceiling (evidenced, not assumed)

Cowork today can only **assemble** from a fixed 25-skill pool. The wizard installs; it never authors. Path C composes pool skills only, and on any external/novel input it says *"external skills are not yet supported."* So every time a real need didn't fit the pool, the user dropped out of Cowork and hand-wrote a `SKILL.md`.

Evidence — the owner's five real workspaces (researched 2026-07-19; see Council memory `cowork-real-workspaces`, internal):

- **Career Manager** hand-authored five skills the kit could never ship: `career-draft` and `linkedin-post` (welded to the owner's own narrative), plus `market-scan` / `resume-tailor` / `role-evaluation` (generic engines that read the profile at runtime).
- The *"study assistant that writes a thesis in my voice"* is literal: a DBA-thesis track composed with a personal voice/authenticity standard and writing skills — a cross-domain composition (study + voice + writing) that **no single preset can express**.
- The owner's own April note diagnosed the workspace as *"about 15% of what it could be… static. No custom skills"* — and the fix he then executed by hand was **a skill per real workflow**.

**Framing:** Skill Studio does not add more pool skills. It closes the gap between "assemble from a fixed pool" and "author what this user actually needs."

---

## 2. Recommendation — build a Cowork-native generator, cite prior art (ADR-043 pattern)

Anthropic ships a skill-that-writes-skills (a conversational skill-creation tool in its public skills repo). Adopt-vs-author scan:

- **License is not the blocker** — it is permissively licensed (Apache-2.0), genuinely adoptable (contrast v2.10's license-null repo, correctly adopt-blocked under ADR-043).
- **Two real blockers remain:** (a) **wrong output shape** — it emits the free-form Agent-Skills layout, not Cowork's strict 9-section ADR-015 template; the ADR-043 source scan already recorded this exact mismatch; (b) **too heavy** — it is a developer-facing iterate-and-benchmark harness (spawns eval runs, needs command-line plumbing), not a lightweight in-workspace brainstorm.

**Verdict (ADR-043 precedent):** author a Cowork-native generator that **mirrors the proven loop** (interview → draft → validate → sharpen triggers) but emits the 9-section house template and installs locally. Cite the Anthropic tool as prior art with attribution (ADR-024 / ADR-043 ceremony). This is the same honest outcome as v2.10: reuse the method, not the artifact, when no tested source fits the shape.

---

## 3. Interaction model (both triggers)

The same loop at both trigger points the owner confirmed:

**brainstorm need → propose a skill spec (name, description, 4–6 triggers, when-to-use) → user confirms → author a full 9-section `SKILL.md` → install into the workspace `.claude/skills/<slug>/` → validate locally → offer to refine**

- **Setup trigger:** hook the wizard's *existing* Path C zero-coverage branch. Today it routes a no-match goal to the closest pool skill; instead it offers *"author one for you,"* at the same confirmation cadence as F4.
- **In-use trigger:** a standalone `skill-studio` meta-skill, callable anytime — *"I keep needing X, make me a skill"* — independent of the wizard. This is how `career-draft` and `linkedin-post` were actually born.

---

## 4. Reuse map

| Rides existing rails | Genuinely new to build |
|---|---|
| `templates/skill-template/` (9-section scaffold, ADR-015) | The generator meta-skill itself |
| `skill-depth-check` rules (9 sections + 60-line floor) | A **portable in-workspace validator** (CI runs in the kit repo, not the user's workspace) |
| Injection-safety clauses (data-not-instruction; non-imperative-surfaced) | The brainstorm → skill-spec conversation protocol |
| CONTRIBUTING's 5 placeholder-authoring rules | How a local skill surfaces itself (it cannot join the registry) |
| `goal_tags` / `match_signals` as the trigger-vocabulary model | Decision layer for surfacing local skills in workspace instructions |

---

## 5. Safety model

A generated skill is **new instruction surface**, so it is gated the same way the pool is:

- **Local-only blast radius = one workspace.** Generated skills never touch the shared pool or registry. This sidesteps the entire supply-chain / poisoned-skill risk class that the 2025–26 skill-injection literature targets (OWASP LLM01 remains the top risk; specific published prevalence figures are secondary and should be primary-confirmed before any public citation).
- **Structural gate:** must pass the 9-section + 60-line structure locally before install.
- **Instruction-surface hygiene:** must carry the verbatim data-not-instruction line and the non-imperative-surfaced clause; must obey CONTRIBUTING's placeholder-authoring rules (never emit `Ignore` / `Disregard` / `Override` / `Instead` / `Always` in bodies; no safety-rule patterns — that surface is reserved).
- **Trigger discipline:** tightly-scoped, bounded triggers — the top quality risk is a greedy skill whose triggers hijack unrelated prompts.
- **Ingest-as-data:** any material the generator reads to author the skill is treated as data, never as instructions.

---

## 6. Phasing (owner decision 2026-07-19)

**Increment 1 — Walking skeleton (recommended first build):**

- In-use `skill-studio` meta-skill only.
- Full loop: brainstorm → skill-spec → author 9-section `SKILL.md` → install locally → structural validation (portable local depth-check).
- Local-only; **no registry membership**; no eval loop.
- Smallest end-to-end slice that lets the owner generate a real, safe skill in a real workspace and feel the capability.

**Full experience — KEPT IN PIPELINE as the destination (not dropped):**

- **Setup trigger** wired into the Path C zero-coverage branch.
- **Surfacing integration** — how a local skill's triggers / goal-tag-style matching wire into `global-instructions.md` proactive rules.
- **Eval-testing loop** — the with/without grading pass the prior-art tool uses, for generated-skill quality.
- **Promote-to-shared-pool path** — a local skill that proves excellent gets back-ported into the curated pool under full ADR-024 / ADR-043 ceremony + CMP byte-mirror.

This is the "both setup + anytime" experience the owner confirmed. It is **sequenced after the skeleton, not descoped** — this brief is the standing record that it remains queued.

---

## 7. Open questions for Phase 0 `/spec`

- **Registry exclusion is the key design line.** A local generated skill is not `builtin` and has no GitHub `source_url`, so it would fail `registry-cardinality` / `registry-url` / `wizard-consistency` CI. Resolution: local skills live **outside** the registry model and surface through workspace instructions, not registry rows. `CMP` byte-mirror applies to pool skills only — local skills are explicitly exempt (document this).
- **Validator parity:** the kit's `skill-depth-check` runs in the kit repo. Who maintains the ported in-workspace validator so "kit-quality" stays real over time?
- **Evals:** the skeleton ships on structural validation only; the benchmark loop lands with the full experience.
- **Trigger wiring:** generated triggers must not drift the CI-gated `match_signals` / `goal_tags` closed vocabularies — how do they attach to proactive rules without touching those?
- **Promotion mechanics:** the exact local → shared-pool back-port ceremony.

---

## 8. Precedent and inputs

- **Governing precedent:** ADR-043 (adapt-vs-author), ADR-015 (9-section template), ADR-016 (60-line floor + `skill-depth-check`), CONTRIBUTING placeholder-authoring rules.
- **Prior art (research 2026-07-19):** Anthropic Agent Skills (published as an open standard, Dec 2025); Anthropic's conversational skill-creation tool (Apache-2.0, public skills repo) as the loop blueprint; OWASP LLM01 + the 2025–26 skill-injection literature for the safety model.
- **Owner workspace evidence:** Council memory `cowork-real-workspaces` (internal; must not appear in public copy).

**Next step:** on owner greenlight, `/spec` converts this brief into a Phase 0 cycle scoped to Increment 1 (walking skeleton), with §6 "full experience" carried as the roadmap destination.
