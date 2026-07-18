# How It Works

This page is the "how we build" credibility page — a plain-language look at how this kit's design decisions actually get made, for anyone evaluating whether to trust it beyond the README's summary.

## The interview, end to end

Open the folder as a Cowork Project (or paste a starter file — see the [README](../README.md)) and the wizard runs a 3-turn interview:

1. **Q1 — Goal.** One open-ended question: "What do you need help with?" The wizard routes your answer to the closest of 7 selection presets (or a custom, from-scratch bundle if nothing fits) using keyword matching plus judgment — not a rigid menu.
2. **Bundle confirm.** You see the proposed skill team and can add, remove, or start from scratch. The moment you confirm, a `cowork-profile.md` checkpoint is written to disk — so even if you stop here, you have real files, not nothing.
3. **Q2 — Name, role, deadlines.** One bundled turn, plus an optional voice-calibration turn (Q3) if you want Cowork to write in your style.

Setup ends with a **handover** (Step 7): your personalized `CLAUDE.md` replaces the setup-bootstrap version, and the entire installer — wizard script, skill pool, vendored library — moves (never deletes) into `_setup-kit/`, so your workspace contains your files, not setup machinery.

Full script: [`WIZARD.md`](../WIZARD.md).

## How decisions get made

This repository is developed through a structured pipeline: a written spec with acceptance criteria, an architecture/design phase that records every decision as an ADR (Architecture Decision Record), an implementation phase, and a testing phase — all before anything merges. Every ADR from v1.0 to present lives in [`docs/architecture.md`](./architecture.md), including the ones behind the controls TRUST.md describes.

## How we test

Beyond unit tests and CI gates, this kit has been stress-tested with an unusual method: a **16-agent swarm campaign** (documented in [`docs/research/v2.7-usercase-test-and-improvement-research.md`](./research/v2.7-usercase-test-and-improvement-research.md)) where AI agents played *both* sides of a full onboarding session — the assistant bound to the actual interview script, and a scripted user — then adversarially audited the result against the spec. That test caught two real failures that shipped in earlier versions: a fast-track exit that silently left users with zero files on disk despite a "workspace ready" message, and a crash-recovery path that couldn't actually recover anything. Both are fixed as of v2.7.

An independent audit of the kit's own claims against its own code is published at [`docs/project-audit-v2.6.1.md`](./project-audit-v2.6.1.md).

## Why the docs/ split

Internal QA reports, security reviews, and compliance artifacts live under `docs/internal/` and are excluded from release archives — not because they're secret (this whole repository is public and MIT-licensed), but so a first-time visitor to `docs/` sees credibility assets (architecture, research, this page) instead of ~40 dated internal review documents. See [`TRUST.md`](../TRUST.md) for the security model these processes support.

## Questions?

See [`docs/faq.md`](./faq.md), or open an issue.
