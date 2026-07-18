# QA Report — v2.6.1 Release Archive Hygiene

## Phase: 5
## Date: 2026-05-11T04:04:32Z
## Status: CONDITIONAL PASS

---

## Executive Summary

All 6 ACs pass. One CI check (`Link Check (External)`) fails on a pre-existing 404 broken link in `docs/security-audit-v2.5.md` (line 124/188: `https://github.com/jmlozano1990/Cowork-Starter-Kit`). That file: (a) was not modified by this PR — last touched in v2.5.2 on main; (b) is explicitly DROP'd from the release archive via `.gitattributes`. The failure is pre-existing, unrelated to v2.6.1 changes, and does not affect the product surface. All other CI checks PASS (20/20 non-link checks pass). Recommendation: APPROVE with note to fix the pre-existing broken link in a follow-on patch.

---

## AC Verification Table

| AC | Description | Evidence | Result |
|----|-------------|----------|--------|
| AC1 | `.gitattributes` exists; all DROP entries have `export-ignore` | `test -f .gitattributes` exits 0. 52 `export-ignore` lines, 70 total lines. All 9 spec DROP categories verified: `.gitignore`, `.markdownlint.jsonc`, `.markdownlintignore`, `CHANGELOG.md`, `CONTRIBUTING.md`, `.github/`, `tests/`, `upstream-contribution/`, `scripts/install-pre-commit.sh`, `.gitattributes` (self). Per-file docs/ enumeration + folder-level dirs all present. | **PASS** |
| AC2 | Archive contains only KEEP files; no DROP leaks | `git archive --format=zip HEAD` → 231 entries. DROP leak grep: empty (0 matches). docs/ entries: only `docs/` prefix entry + `docs/architecture.md` (correct). All 10 KEEP files confirmed: VERSION, README.md, LICENSE, WIZARD.md, SETUP-CHECKLIST.md, cowork.lock.json, CLAUDE.md, scripts/setup-folders.sh, scripts/setup-folders.ps1, docs/architecture.md — all PASS. | **PASS** |
| AC3 | CI regression guard exits non-zero on injected DROP file | YAML syntax valid (python3 yaml.safe_load: no errors). CI step logic: (a) extracts ZIP, (b) loops DROP_PATHS (19 entries) → exits 1 on any hit, (c) loops KEEP_PATHS (10 entries) → exits 1 on any miss, (d) prints offending file name, (e) `set -euo pipefail` ensures non-zero exit. Inject test: Python zipfile injected `CHANGELOG.md` into clean archive; simulation of CI grep loop caught the entry. Regression guard fires correctly. | **PASS** |
| AC4 | Version bump complete: VERSION=2.6.1, CHANGELOG [2.6.1] entry, README badge updated, Next-up teaser present | `cat VERSION` = `2.6.1`. `head -10 CHANGELOG.md` shows `## [2.6.1] - 2026-05-11` (within first 8 lines). README line 5: `version-2.6.1-green` badge confirmed. Next-up teaser at README line 163: "Next up (v2.7+): Multi-tool skill authoring" — forward-looking, references v2.7+. All 4 checks pass. | **PASS** |
| AC5 | No functional regression; only 6 expected files changed | `git diff --name-only main release/v2.6.1` = exactly: `.gitattributes`, `.github/workflows/release-assets.yml`, `CHANGELOG.md`, `README.md`, `SETUP-CHECKLIST.md`, `VERSION` — the 6 expected files. Product folders (`.claude/`, `skills/`, `prompts/`, `templates/`, `examples/`) byte-unchanged: `git diff --stat main release/v2.6.1 -- .claude skills prompts templates examples` = 0 output. | **PASS** |
| AC6 | No remaining relative links to CHANGELOG.md or CONTRIBUTING.md | `grep -nE '\((CHANGELOG\.md\|CONTRIBUTING\.md)\)' README.md SETUP-CHECKLIST.md` = 0 matches. Parent-relative form check also 0 matches. Link rewrite complete — all references now absolute GitHub URLs. | **PASS** |

---

## CI Check Status

Run: https://github.com/jmlozano1990/Cowork-Starter-Kit/actions/runs/25649545861

| Check | Status | Notes |
|-------|--------|-------|
| Link Check (External) | **FAIL** | Pre-existing 404: `https://github.com/jmlozano1990/Cowork-Starter-Kit` in `docs/security-audit-v2.5.md` lines 124+188. File last modified v2.5.2 (not this PR). File is DROP'd from release archive. |
| Link Check (Internal) | PASS | 0 errors |
| /sync-agency Dry-Run (v2.0.3) | PASS | |
| Attribution Survives Render (S5) | PASS | |
| CLAUDE.md Safety Rule Check | PASS | |
| CLAUDE.md Word Count Check | PASS | |
| Lock Content-SHA Fault Injection (AC-F1-3) | PASS | |
| Lock File Zero-SHA Rejection (S9) | PASS | |
| Markdown Lint | PASS | |
| Registry Cardinality Check | PASS | |
| Registry URL Integrity Check | PASS | |
| Safety Rule Check | PASS | |
| ShellCheck | PASS | |
| Skill Depth Check | PASS | |
| Skill Format Check | PASS | |
| Starter File Check | PASS | |
| Starter File Word Count Check | PASS | |
| Starter Safety Rule Check | PASS | |
| THIRD-PARTY-NOTICES.md Check | PASS | |
| Verbatim Attribution Rule Check (ADR-024) | PASS | |
| Writing Profile Template Check | PASS | |
| lock-content-sha-cross-check (C-v2.5-19) | PASS | |

**Summary: 1 FAIL (pre-existing, unrelated to v2.6.1), 20+ PASS**

---

## Security Classification

**STANDARD**

Rationale: v2.6.1 touches only packaging config (`.gitattributes`), CI workflow sanity step (no new auth surface, no secrets, no external API), version bump artifacts (VERSION, CHANGELOG.md, README.md, SETUP-CHECKLIST.md). No auth changes, no schema migrations, no AI instruction changes, no new dependencies, no permission/role changes. Phase 6 `/audit` can be SKIPPED.

---

## Risks Not Covered by ACs

1. **Pre-existing Link Check (External) failure** — `docs/security-audit-v2.5.md` contains `https://github.com/jmlozano1990/Cowork-Starter-Kit` (404). Not introduced by v2.6.1. File is DROP'd from archive so users never see it. Recommended fix: add to lychee exclude list or update the URL in a follow-on patch. LOW severity; does not affect product.

2. **docs/ per-file enumeration completeness** — `.gitattributes` lists 40 specific docs/ files. If new internal docs are added in future cycles without adding an `export-ignore` entry, they would leak into the archive. Mitigated by the AC3 CI regression guard (negative assertions catch specific canary files; general `docs/*.md` leak of a new file would require an explicit canary addition). This is the intended risk posture per spec Out-of-Scope §3.

---

## Recommendation

**APPROVE** — All 6 ACs pass. CI failure is pre-existing in a DROP'd file, not introduced by this PR. Product surface unchanged. Release archive hygiene goal achieved.

Follow-on: fix `docs/security-audit-v2.5.md` broken link (either update URL or add to lychee `.lycheeignore`) in next patch or maintenance cycle.
