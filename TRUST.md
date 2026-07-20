# Trust & Safety

Plain-language answer to the question a security-conscious evaluator actually asks: *what could go wrong with an AI-agent starter kit, and what does this one do about it?*

## What this kit is (and isn't)

Cowork Starter Kit is a Markdown/YAML/Bash configuration bundle — an onboarding wizard, 25 pool skills, and 7 example presets — that Claude Cowork reads as instructions. It is **not** a plugin marketplace, a code-execution sandbox, or a network service. There is no server, no telemetry, no account. Everything it does happens inside your own Cowork session, against files in your own workspace.

## What could go wrong with an AI-agent starter kit

Three realistic threats, in the order a new adopter should worry about them:

1. **Malicious or flawed community skills.** Agent-skill ecosystems are new and largely unvetted. Snyk's February 2026 ToxicSkills study scanned 3,984 public agent skills across the open community-skill landscape and found 36.82% (1,467 skills) had at least one security flaw, with 76 confirmed-malicious payloads designed for credential theft, backdoor installation, or data exfiltration.
2. **Prompt injection via pasted or uploaded content.** Any text a skill or a document puts in front of the model is an instruction-injection surface. PromptArmor disclosed in January 2026 that Claude Cowork could be tricked, via a booby-trapped file, into exfiltrating a user's data through an allowlisted API endpoint — a vivid demonstration that "the AI agent trusts its context" is a real, exploitable assumption.
3. **Supply-chain tampering.** A skill's content can change after you first trusted it, or a "curated" registry entry can point somewhere it shouldn't.

## What this kit does about it

- **SHA-pinning.** Every upstream file this kit vendors is pinned to an exact commit SHA in `cowork.lock.json`, not a branch or a mutable ref.
- **Vendored, not fetched.** The reviewed upstream library ships inside this repo at `vendored/agency-agents/` — nothing is downloaded at setup time, and CI re-verifies the vendored tree against the lock on every pull request.
- **Attribution injection (ADR-024, non-overridable).** Every file sourced from upstream gets a 6-field attribution block injected before it ever reaches your workspace; if the block can't be injected, the wizard refuses the install and surfaces an error instead of installing silently.
- **A ≤400-word bootstrap ceiling (ADR-011).** `CLAUDE.md`, the file Cowork auto-loads, is capped and CI-enforced — a structural limit on how much instruction surface exists before you've even started the interview.
- **Data-locality defaults (ADR-019).** Sensitive categories (financial amounts, health info, credentials) are paste-only by convention in the presets that touch them — never sent to a connector by default.
- **Human review before merge.** The `/sync-agency` workflow that pulls in upstream updates opens a PR, runs an 8-pattern content scan, and enforces a 24-hour soak before two humans can approve — nothing from upstream reaches a release without that gate.
- **Promotion ingress is PR-gated too (new).** The curated pool can now also grow from a skill a user built and proved in their own workspace with `skill-studio`, via a documented [`PROMOTE.md`](PROMOTE.md) ceremony — never a direct write. Before a promotion PR can even be opened, the ceremony re-runs the skill's quality and safety grading fresh (never trusting an older result), re-scans it for forbidden tokens, and surfaces the entire body text to the promoter for an explicit "confirm nothing private is in here" check. The PR itself is then reviewed the same way any other curated-pool addition is — this is a new *ingress path* into the pool, not a new *tier* or a weaker bar than any other Tier 1 skill clears. (This is scoped to the ingress path only; it is not a claim that a self-modifying local instruction surface — Skill Studio's broader generative capability — is a fourth threat class on this page. That's a separate, larger question, tracked for whenever this kit's Loop 1 self-modification work ships.)
- **Everything is reviewable.** No compiled artifacts, no obfuscation — the entire kit is Markdown, YAML, and Bash you can read before you run it.

## Third-party evidence

Both figures above were independently re-verified against their primary sources before publication, not copied from a secondary summary:

- **Snyk, "ToxicSkills"** (Feb 5, 2026): [snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub](https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/) — 3,984 skills scanned, 36.82% (1,467) with at least one security flaw, 76 confirmed-malicious payloads.
- **PromptArmor, "Claude Cowork Exfiltrates Files"** (Jan 14, 2026): [promptarmor.com/resources/claude-cowork-exfiltrates-files](https://www.promptarmor.com/resources/claude-cowork-exfiltrates-files) — indirect prompt injection via an uploaded file, disclosed two days after Cowork's release.

Neither Snyk nor PromptArmor endorses this kit — they are cited as independent research establishing why these controls matter, not as reviewers of this repository.

## Trust boundary

`cowork.lock.json` is the integrity anchor for all vendored upstream content. If you cloned this repo from an untrusted fork, or modified the lock file locally, the SHA-pinning and vendored-integrity guarantees no longer apply to you — always install from a trusted clone of this repository's main branch.

## How to verify it yourself

Don't take this page's word for it:

- `docs/architecture.md` — every ADR and Phase 1 design record, from v1.0 to present, including the ones cited above.
- `docs/project-audit-v2.6.1.md` — an independent audit of the kit's own claims against its own code.
- `docs/research/` — the raw research this kit's design decisions are based on, including the 16-agent swarm test behind `docs/how-it-works.md`.
- `docs/faq.md` — answers to the questions evaluators ask most often.
