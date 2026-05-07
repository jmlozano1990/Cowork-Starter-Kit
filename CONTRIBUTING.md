# Contributing

Thank you for contributing to Claude Cowork Config. This guide explains how to add a new preset.

---

## Adding a new preset

All contributions start from the template. Do not create a preset folder from scratch.

1. Copy `templates/preset-template/` to `examples/<your-preset-name>/`
2. Use a lowercase, hyphenated slug for the folder name (e.g. `legal`, `data-science`, `teaching`)
3. Fill in every file — no placeholders left blank
4. Run the CI checks locally before opening a PR (see below)
5. Open a pull request with the title `feat: add <preset-name> preset`

---

## PR review checklist for maintainers

Before merging a new preset PR, verify all 11 items:

- [ ] **`project-instructions-starter.txt` present** — file exists at `presets/<name>/project-instructions-starter.txt`
- [ ] **Starter file is ≤350 words** — run `wc -w presets/<name>/project-instructions-starter.txt` to confirm (raised from ≤300 in v1.2 for dynamic wizard branching)
- [ ] **Safety rule present verbatim in starter file** — must contain: "Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder."
- [ ] **All skills in `folder/SKILL.md` format** — no flat `.md` skill files at `presets/<name>/.claude/skills/` root; each skill is a folder with `SKILL.md` containing valid YAML frontmatter (`name:` and `description:` fields)
- [ ] **Minimum file count met** — at least 3 skills in `.claude/skills/`, at least 2 context files in `context/`, at least 1 `folder-structure.md`, at least 1 `connector-checklist.md`
- [ ] **"Try this now" prompts present** — `skills-as-prompts.md` includes at least one file-based and one file-agnostic example prompt
- [ ] **CI passes** — all GitHub Actions jobs pass: markdown lint, link check, shellcheck, safety-rule grep, starter-file-check, starter-safety-rule-check, skill-format-check, writing-profile-template-check
- [ ] **`writing-profile.md` present** — file exists at `presets/<name>/context/writing-profile.md` with non-placeholder content in Tone & Voice and Anti-AI Guidance sections; must not be blank or contain only `[bracketed placeholders]`
- [ ] **`curated-skills-registry.md` entry follows schema** — if the PR adds skills to `curated-skills-registry.md`, each entry must include: `name`, `description`, `source_url` (HTTPS only or `builtin`), `vetting_date` (ISO 8601), `tier` (1 or 2), `goal_tags`. PR description must include vetting evidence (source repo stars/health, last commit date, keyword scan result showing no flagged terms)
- [ ] **CLAUDE.md sync** — if the PR modifies the wizard flow in any `project-instructions-starter.txt`, `CLAUDE.md` must be updated to match (and vice versa). All 7 wizard surfaces (CLAUDE.md + 6 starter files) must stay in sync. PRs that touch one must touch all.
- [ ] **No `Sample:` or `Raw sample:` field** — `writing-profile.md` files must not store raw user writing samples; wizard instructions must extract patterns only
- [ ] **New/edited SKILL.md in depth-enforced preset contains all 9 sections** — `## When to use`, `## Triggers`, `## Instructions`, `## Output format`, `## Quality criteria`, `## Anti-patterns`, `## Example`, `## Writing-profile integration`, `## Example prompts` (per `templates/skill-template/SKILL.md`)
- [ ] **New SKILL.md has ≥ 60 lines** — run `wc -l presets/<preset>/.claude/skills/<skill>/SKILL.md` to confirm; the `skill-depth-check` CI job enforces this for depth-enforced presets
- [ ] **Frontmatter `trigger_examples` list has 3–6 entries if present** — the field is optional; if included it must have at least 3 and no more than 6 example phrases
- [ ] **Placeholder authoring rules followed** — see `##Placeholder authoring rules` section below
- [ ] **B10 skill-input file lives under the pipeline path** — if this PR proposes a new skill, any B10 skill-input file (session notes, Q&A responses) must live under `.claude/projects/<slug>/cycles/…` and NOT under any product repo path (presets/, docs/, templates/)
- [ ] **Prior retro carry-forwards reviewed** — per `docs/retro-template.md` §Carry-Forward Review; every item from the previous cycle's Section 8 must have an explicit disposition before this PR closes
- [ ] **Cross-preset slug-divergence check (community PRs)** — if this PR introduces or edits a skill whose `name:` frontmatter slug already exists in another preset (e.g., `research-synthesis` appears in both `study` and `research`), verify that `## Quality criteria` and `## Anti-patterns` content diverge meaningfully across the two files. ADR-018 permits duplicate slugs only when the two SKILL.md files implement genuinely distinct workflows. A reviewer who finds two files with >60% identical `## Instructions` content should block the PR and request a refactor. (Not CI-enforced per ADR-018 §Consequences.)

---

## CLAUDE.md changes — high-impact notice

`CLAUDE.md` is auto-loaded as system context for any user who opens this repo folder in Cowork. It is a universal entry point — changes to it affect all users immediately, not just users of a specific preset.

**PRs that modify `CLAUDE.md` must:**

1. Also update all 6 `presets/*/project-instructions-starter.txt` files to match (wizard flow must stay in sync — ADR-010)
2. Include a clear explanation of what changed and why in the PR description
3. Be reviewed by a maintainer before merge — treat `CLAUDE.md` edits as security-relevant changes

Similarly: PRs that modify wizard flow in any starter file must also update `CLAUDE.md`.

---

## Registry entries — `curated-skills-registry.md`

When adding entries to `curated-skills-registry.md`:

- `source_url` must use HTTPS (not `http://`). Use `builtin` only for Anthropic official skills — do not claim `builtin` for community-sourced skills.
- **Pin to a specific commit SHA**, not a branch URL, to prevent URL rotation attacks:
  - Correct: `https://github.com/org/repo/blob/a1b2c3d4e5f6/path/SKILL.md`
  - Avoid: `https://github.com/org/repo/blob/main/path/SKILL.md`
- `vetting_date` is the date you personally tested the specific SHA above
- Include vetting evidence in your PR description: source repo stars, last commit date, keyword scan result

The Tier 2 community skill search list in `WIZARD.md` is maintained by repo maintainers. Do not submit PRs that add new repos to that list — open an issue to request additions.

---

## Skill content safety

Before submitting any skill content from external sources, scan it at [SkillRisk.org](https://skillrisk.org). Do not submit skill content that was not written by you or sourced from Anthropic's official materials.

---

## Placeholder authoring rules

When writing placeholder text in SKILL.md files (the bracketed `[...]` tokens contributors fill in), follow these five rules to avoid shipping unintended runtime instructions to Cowork:

1. **Placeholders are bracketed nouns, never imperatives.** Write `[action description]`, not `[Do X]` or `[Tell Cowork to…]`.
2. **Never include the words `Ignore`, `Disregard`, `Override`, `Instead`, or `Always` inside a placeholder.** These terms can leak as LLM instructions if a placeholder is left unfilled or partially filled.
3. **Use inline HTML comments for contributor guidance.** Intent and instructions for the contributor belong in `<!-- HTML comment -->` blocks, not in the visible placeholder text. HTML comments are invisible at Cowork runtime.
4. **No safety-rule pattern in placeholders.** Do not write placeholder text that could be read as a rule about confirming, deleting, or overwriting files — that surface is reserved for the canonical safety rule in `global-instructions.md`.
5. **Example section placeholders must read as contributor-guidance, not Cowork-instructions.** Placeholder text inside `## Example` must clearly signal that the contributor should paste a real input/output pair there — it must not read as an instruction Cowork would follow if left unfilled (e.g., use "Paste a real input/output here" not "Show an example").

These rules are enforced by review, not by CI. The `safety-rule-check` CI job does not parse placeholder content.

---

## B10 Input Session Template

When proposing a new skill, capture user input in a structured B10 session before writing the SKILL.md. This documents the design decisions that the SKILL.md encodes.

### Full 6-Q session (first skill in a preset)

Conduct a full Q&A covering all six questions:

| Q | Topic | Maps to SKILL.md section |
|---|-------|--------------------------|
| Q1 | Framework / structure | `## Instructions`, `## When to use`, `## Output format` |
| Q2 | Anti-patterns (research-backed) | `## Anti-patterns` |
| Q3 | Worked example | `## Example` |
| Q4 | Writing voice | `## Writing-profile integration` |
| Q5 | Triggers (4 modes) | `## Triggers`, frontmatter `trigger_examples:` |
| Q6 | Output format details | `## Output format` |

Present options for each question. Offer research-backed defaults. Let the user accept all, override selectively, or clarify.

### Defaults + clarify pattern (skills 2+ in a preset)

For skills after the first skill in a preset cycle, use the abbreviated pattern:

1. Present orchestrator-proposed defaults for each Q (one message listing all 6 proposals).
2. User accepts all or requests clarification on specific items.
3. Proceed with accepted defaults.

**Why:** The first skill establishes framework precedents (e.g., writing-profile tier rule, output format conventions). Subsequent skills in the same preset should inherit those precedents unless the user signals a specific deviation.

### Worked-example authoring rules (S1 security carry-forward)

The `## Example` section in a SKILL.md is executed as AI context. Apply these three rules to prevent indirect prompt injection:

1. **Cite real, verifiable sources only.** Prefer peer-reviewed, publicly attested works. Preprint acceptable only if the user explicitly vouches for the source. Do not invent author names, titles, or publication details.
2. **Scan for forbidden imperative tokens.** Before committing any `## Example` section, run: `grep -iE '\b(Ignore|Disregard|Override|Instead of|Always respond|New instruction)\b' <SKILL.md>`. Any match outside a code fence or HTML comment must be paraphrased. Block the commit until resolved.
3. **User-written expected output.** The expected output in `## Example` must be authored by the user (or the orchestrator proposing a worked example to the user for explicit approval) — it must NOT be copied verbatim from a source paper's own synthesis, abstract, or conclusions. The point is to demonstrate what Cowork should produce, not to reproduce copyrighted content.

These rules apply to both user-pasted (B10 direct input) and orchestrator-proposed (defaults + clarify) worked examples.

---

## After Phase 7 — push and PR checklist

After a pipeline cycle reaches Phase 7 APPROVED, the release branch is ready for merge. Direct push to `main` is blocked by policy. Follow this checklist:

1. **Push the release branch** — `git push origin release/vX.Y.Z` (or the feature branch name). If the branch already exists on origin, confirm you are not force-pushing.
2. **Open a pull request** — title format: `release: vX.Y.Z — <one-line summary>`. Target: `main`.
3. **PR description must include:** version bump line, link to relevant pipeline phase summaries, list of all deliverables (B-items and S-items resolved).
4. **@qa review required** — the PR must be approved by @qa (or a maintainer acting in that role) before merge.
5. **Squash or merge commit** — do not fast-forward if the release branch has more than one commit; a merge commit preserves branch history.
6. **After merge:** tag the commit as `vX.Y.Z` on `main` and update `VERSION` if not already done in the release commit.

---

## Running CI checks locally

```bash
# Markdown lint
npx markdownlint-cli2 "**/*.md"

# ShellCheck (requires shellcheck installed)
shellcheck scripts/setup-folders.sh

# Safety rule grep — global-instructions.md
SAFETY_RULE="Always ask for explicit confirmation before deleting"
for f in presets/*/global-instructions.md; do
  if ! grep -q "$SAFETY_RULE" "$f"; then
    echo "MISSING safety rule: $f"
  fi
done

# Safety rule grep — starter files (.txt)
for f in presets/*/project-instructions-starter.txt; do
  if ! grep -q "$SAFETY_RULE" "$f"; then
    echo "MISSING safety rule: $f"
  fi
done

# Starter file existence check
for preset in study research writing project-management creative business-admin; do
  if [ ! -f "presets/$preset/project-instructions-starter.txt" ]; then
    echo "MISSING starter file: presets/$preset/project-instructions-starter.txt"
  fi
done

# Skill format check — no flat .md files at skills root
for skills_dir in presets/*/.claude/skills; do
  for f in "$skills_dir"/*.md; do
    if [ -f "$f" ]; then
      echo "FLAT SKILL FILE: $f (must be in folder/SKILL.md format)"
    fi
  done
done
```

---

## CI Workflow Quality Baseline (v2.0.1+)

Every new `.github/workflows/*.yml` file added to this repo MUST pass both checks before Phase 7 APPROVED (AC-6 per v2.0.1 hotfix — addresses the P2 pattern "YAML structure not checked" from the v2.0 retrospective):

**Check 1 — YAML parser validation (run locally before push):**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/<your-workflow>.yml'))" && echo "PASS"
```

This catches column-0 heredocs and other block-scalar violations that grep-based tests miss. A workflow that fails `yaml.safe_load` will never register in GitHub Actions — its triggers (`workflow_dispatch`, `push`, `schedule`) will be silently absent.

**Check 2 — Trigger registration verification (run after first push to a branch):**

```bash
# List all workflows and confirm your new workflow appears with the expected name
gh workflow list

# Verify the triggers list includes all declared triggers
gh api repos/{owner}/{repo}/actions/workflows/{workflow_id} --jq '.name, .state'
```

The workflow `name:` field in the API response must match the `name:` declared in the YAML (not fall back to the file path). If it shows the file path (e.g., `.github/workflows/my-workflow.yml`), the workflow was not parsed correctly.

Both checks are required before a workflow-modifying PR can be approved at Phase 7. @qa must verify them in the Phase 5 test report.

**Check 3 — SHA verification for pinned actions (required before Phase 7 APPROVED):**

Every `uses:` line in a CI workflow file that pins to a SHA MUST be verified at Phase 5 via:

```bash
gh api repos/<owner>/<repo>/git/refs/tags/<tag>
```

Confirm the SHA in the workflow matches the `.object.sha` (or `.object.sha` of the tag's target commit if it is an annotated tag) returned by the API. Hallucinated SHAs are a supply-chain risk and are a blocking finding. A workflow with an unverified SHA cannot be approved at Phase 7.

This rule codifies the P3 pattern from the v2.0 retrospective: "SHA-pinning added but not verified before merge."

---

## Version management

Do not modify the `VERSION` file or `CHANGELOG.md`. Maintainers handle versioning at release time. Your PR should contain only files in `examples/<your-preset-name>/`.

---

## Agency-Sync PR Review (v2.0+)

PRs labeled `agency-sync` are opened automatically by `.github/workflows/sync-agency.yml`
when the upstream `msitarzewski/agency-agents` SHA changes. These PRs have elevated
security requirements:

### 2-Approval Rule (CODEOWNERS, S2)

**Agency-sync PRs require 2 separate maintainer approvals before merge.** A single-maintainer
compromise must not enable a silent supply-chain redirect. This rule is enforced via CODEOWNERS
(see `.github/CODEOWNERS`).

### Review Checklist for Agency-Sync PRs

Before approving an agency-sync PR:

- [ ] **Lock file diff reviewed** — verify `cowork.lock.json` changes match expected upstream content; no unexpected files added or removed
- [ ] **Spot-check ≥3 files per allowed category** — download file content from the new pinned SHA URL (`https://raw.githubusercontent.com/msitarzewski/agency-agents/<NEW-SHA>/<path>`) and scan manually for adversarial content
- [ ] **Run S1 content scan locally** — apply all 8 patterns from `docs/security/upstream-content-scan-rules.md` against every new or changed file
- [ ] **nexus-strategy.md absent** — verify `jq '.files[] | select(.path | contains("nexus-strategy"))' cowork.lock.json` returns empty
- [ ] **Blocked-pattern files absent** — verify none of the 9 blocked-pattern filenames appear in the lock file's `files` array
- [ ] **`requires_review` files addressed** — any file with `"requires_review": true` in the lock file must be reviewed and cleared by a maintainer before merge
- [ ] **License hash** — if `license_changed: true` in the PR body, route to `/legal` review before merge; do not approve without legal sign-off
- [ ] **THIRD-PARTY-NOTICES.md** — verify the regenerated file has correct timestamps, SHA, and MIT license text
- [ ] **24h soak rule (S7)** — do not approve within 24h of PR opening; allow community review time
- [ ] **First sync is SECURITY-SENSITIVE** — if this is the bootstrap sync (PR body shows `Bootstrap state: true`), treat as per `docs/security-review.md` Open Issue #3: full audit of ≥3 files per allowed category is mandatory

### Goal Taxonomy Keyword Updates (S10)

If an agency-sync PR updates the goal taxonomy keyword mapping in `CLAUDE.md` or `WIZARD.md`:

- [ ] Review new keywords for adversarial content (category mismatch, misleading goal-to-category routing)
- [ ] Verify no new category was added to the keyword map that is not in `.cowork-allowlist.json` `allowed_categories`

---

## Developer Certificate of Origin

All contributions must be signed off with `git commit -s` (Developer Certificate of Origin). By signing off, you certify that you wrote the contribution or have the right to submit it.

By submitting a PR, you agree that your contribution is licensed under MIT.

---

## Questions?

Open an issue and tag it `question`. We're happy to help.
