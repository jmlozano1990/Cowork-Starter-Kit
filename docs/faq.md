# FAQ

## Is this safe to run?

See [`TRUST.md`](../TRUST.md) for the full plain-language threat model. Short version: every upstream skill file is SHA-pinned, vendored inside this repo (nothing fetched at runtime), attribution-injected before it reaches your workspace, and reviewed by a human before any upstream update ships. Independent research from Snyk and PromptArmor — cited in TRUST.md — documents why these controls matter for AI-agent skill ecosystems generally.

## Does setup need the internet?

No. Everything the wizard installs ships inside the download — skills are copied from the local `skills/` folder, never fetched. If Cowork ever says it can't reach the internet during setup, that's expected and blocks nothing; see `WIZARD.md`'s Network & Offline Rule.

## How long does setup actually take?

The hero claim ("15 minutes") is backed by 4 timed dry-runs across the interview's main paths — see the scorecard in [`tests/offline-smoke-test.md`](../tests/offline-smoke-test.md) for the raw numbers and the decision rule that governs the claim. It's a ceiling, not a target; a clear-goal run typically finishes faster.

## What if I can't open the folder as a Cowork Project?

Paste `examples/<preset>/project-instructions-starter.txt` into Project Settings > Custom Instructions. As of v2.8.0 every starter file is a fully self-contained copy of the same 3-turn interview — no folder access required, and no functional difference from opening the folder directly.

## What's in `docs/internal/`?

Dated QA reports, security reviews, and compliance artifacts from past release cycles. Nothing there is secret — the whole repository is MIT-licensed and public — it's separated so the `docs/` a visitor lands on leads with credibility assets (architecture, research, this page) instead of internal paperwork. See [`docs/how-it-works.md`](./how-it-works.md) for the full rationale.

## Can I add my own skill or preset?

Yes — see [`CONTRIBUTING.md`](../CONTRIBUTING.md). Skills follow a 9-section template and are reviewed against the same safety bar as everything else in the pool. Community (Tier 2) skills go through additional vetting before inclusion.

## What happens to the setup wizard after I finish?

Step 7's handover archives the entire installer — the wizard script, the skill pool, the vendored library — into `_setup-kit/` inside your workspace (moved, never deleted). Your project folder ends up containing your files, not setup machinery. `/setup-wizard` still works afterward; it finds the archived copy automatically.

## Where do I report a problem?

Open an issue on GitHub. If it's a security concern specifically, see the reporting guidance in `SETUP-CHECKLIST.md` and `CONTRIBUTING.md`.
