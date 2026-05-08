# Global Instructions Base — Safety Rule

This file is the single source of truth for the safety rule that must appear in every preset's `global-instructions.md`.

---

## The canonical safety rule

Every preset's `global-instructions.md` MUST include this exact sentence, verbatim:

> **Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.**

This sentence must not be paraphrased, shortened, or moved to a footnote. It must appear in the main body of the instructions block.

---

## Why this rule matters

Claude Cowork has direct access to your local file system. A vague instruction like "clean up my folder" could cause Cowork to delete files permanently if no safety rule is in place. This rule was added in direct response to a documented incident where a user lost 11GB of files after giving Cowork an ambiguous cleanup instruction.

The safety rule does not limit what Cowork can do — it only requires Cowork to ask before taking irreversible actions. This is always the right default.

---

## How to include this rule in a preset

In your preset's `global-instructions.md`, include the following line in the working rules section:

```
Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.
```

The CI safety-rule grep job checks for this exact string in every `examples/*/global-instructions.md` file. If it is missing, the CI job will fail and the PR cannot be merged.

---

## Enforcement

This rule is enforced at three layers:

1. **Template layer** (this file) — single source of truth
2. **Preset layer** — every `global-instructions.md` includes the rule verbatim
3. **CI layer** — the `safety-rule-check` job in `.github/workflows/quality.yml` greps all presets and fails if any are missing the rule
