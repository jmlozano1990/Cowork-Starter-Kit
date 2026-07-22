# QA Report — Cowork Starter Kit v2.19.0 (Persistency Layer)

## Phase: 5
## Date: 2026-07-22T13:27:06Z
## Status: FAIL — one CI-breaking defect (mechanical, non-security); all security/AC substance PASSES

All verification below was independently re-derived and re-run by @qa — real commands, real
fixtures (many built fresh, distinct from @dev's own), real filesystem before/after snapshots.
No claim in this report rests on @dev's or @security's narrative alone.

---

## 1. AC-by-AC verification

### Face 1 — Skill-content pull (KDQ-PULL)

| AC | Verdict | Evidence |
|---|---|---|
| AC-PULL-1 (trichotomy + manifest-drift 4th state) | PASS | `classify-component.sh` run against 4 **QA-built** fixtures (different skills than @dev used — `citation-formatter` untouched, `action-items` hand-edited, a dangling `nonexistent-file-qa` entry, an unregistered `qa-my-own-custom-skill-xyz` slug) → `untouched` / `user-customized` / `manifest-drift` / `user-authored-not-in-pool`, all 4 correct. |
| AC-PULL-2 (untouched → single explicit offer) | PASS | `pull-updates/SKILL.md` §"Classifying each component" + Output format item 2/3 — no batching language, per-component confirm required. |
| AC-PULL-3 (customized → explicit conflict, no silent overwrite) | PASS | Same section; conflict surfaced, resolution requires separate explicit decision. |
| AC-PULL-4 (user-authored never pull-eligible) | PASS | Confirmed structurally in classify-component.sh (P=NO branch never reaches the untouched/customized branches) and in prose. |
| AC-PULL-5 (no in-session network) | PASS | `pull-updates/SKILL.md` §"No in-session network, ever" — explicit. Diff-scoped grep (see §6 below) found no real network call added. |
| AC-PULL-6 (fresh-bytes-both-sides, trust-transitivity) | PASS | `classify-component.sh`'s own function signature takes **no manifest-hash argument at all** — structurally cannot read a manifest label. QA's own `action-items` edited-fixture run (hand-edited on-disk bytes, no manifest involved) still correctly returned `user-customized`; QA's `citation-formatter` untouched-fixture in the same batch correctly returned `untouched` (negative control proving this isn't a blanket "always conflict"). |
| AC-PULL-7 (poisoned-backfill + bootstrapping) | PASS | `backfill-verify.sh` run against a **QA-built poison** (independently authored — weakened the verify-then-swap order clause in a copy of `self-upgrade/SKILL.md`, distinct from @dev's own poison text) → `REFUSE: byte mismatch`; byte-correct copy → `PROCEED`. Bootstrapping-trust prose (installer ceremony, not absent self-apply) present in both `pull-updates/SKILL.md` and `WIZARD.md`'s Fallback Option-2 backfill step. |
| AC-PULL-8 (lock↔install naming) | PASS | `pull-updates/SKILL.md` §"Naming discipline" explicit; `grep -c "cowork.lock.json" skills/pull-updates/SKILL.md` shows it named once, correctly, as "a different, disjoint file." |
| AC-PULL-9 (malformed/partial manifest refusal) | PASS | `validate-manifest.sh` run against @dev's 2 malformed fixtures AND **2 QA-built fixtures** (my own truncated JSON, my own component missing `slug`) — all 4 REFUSE correctly (exit 1); well-formed fixture proceeds (exit 0, negative control). |

### Face 2 — Kit-version upgrade path (KDQ-UPGRADE)

| AC | Verdict | Evidence |
|---|---|---|
| AC-UPGRADE-1 (version seam) | PASS | `self-upgrade/SKILL.md` reads `kit_version` from `cowork.install.json`, v2.18 schema, no new field (confirmed unchanged — §6). |
| AC-UPGRADE-2 (semver-aware upgrade-ready boundary) | PASS | `scripts/semver-compare.sh upgrade-ready` run against all 5 required fixtures: `2.9.0`→not-ready, `2.18.0`→not-ready, `2.19.0`→ready, `2.20.1`→ready, `absent`→not-ready — all correct. **Naive string-compare defeat proven**: `[[ "2.9.0" > "2.19.0" ]]` evaluates true in bash (the `9`-outranks-`1` trap) — the script avoids this by parsing integer triplets. |
| AC-UPGRADE-3 (3-piece contract: seam / migration dir / mechanism) | PASS | All three present: `kit_version` seam (AC-UPGRADE-1); `context/.kit-migrations/kit-migration-log.md` convention documented in `self-upgrade/SKILL.md` and on both deny-lists (§6); `self-upgrade` mechanism installed+deny-listed. |
| AC-UPGRADE-3(c) (dormant no-op vs. synthetic-newer routing, firing control) | PASS — **live-invoked**, see §2 below (Scenario 1 & 2). |
| AC-UPGRADE-4 (reuse-not-relax, verify clause) | PASS | Structural grep: `self-upgrade/SKILL.md` references `self-apply/SKILL.md`/SECGATE/verifier/rollback **8 times by name/path**; `grep -c "^### Applying a confirmed change\|^### The verifier gate"` on `self-upgrade/SKILL.md` → **0** — no re-declared gate logic, only references. |
| AC-UPGRADE-5 (non-destructive re-install) | PASS | Prose confirms controlled re-install through the same confirm-first gate, never live in-place mutation outside it. |
| AC-UPGRADE-6 (no v3.0+ migration script in v2.19) | PASS | `self-upgrade/SKILL.md` explicit: "authors **no** migration script and writes **no** row." Verified no `context/.kit-migrations/` content shipped in the repo (dir/log intentionally unwritten at v2.19). |
| AC-UPGRADE-7 (highest blast radius, full-strength gate) | PASS | Confirmed via pipeline.md Phase 2 (opus, full-strength, no combined path) and this Phase 5 re-derivation. |
| AC-UPGRADE-8 (self-integrity / verify-then-swap, HARD gate) | PASS — **live-invoked**, see §2 below (Scenarios 2, 3, 4). This is the cycle's hard Phase-2 acceptance condition; independently re-confirmed at Phase 5, not merely re-read. |
| AC-UPGRADE-9 (kit_version write-back contract, execution deferred) | PASS | `cowork.install.json` deny entry in `self-apply` confirmed byte-unchanged (§6); no manifest write occurs in the Scenario-1 zero-write test below. |

---

## 2. Live-invocation — MF-2(b) and AC-UPGRADE-3(c) (the two items @dev flagged, honestly un-exercisable pre-implementation)

**Honest framing, stated up front:** `self-upgrade`/`self-apply` are prose `SKILL.md` files interpreted by an LLM agent session — there is no application code layer to unit-test the *routing/judgment* half of these controls against. What follows is a **real, live agent-judgment exercise** against synthetic fixtures I built myself in an isolated scratch workspace (`/tmp/.../qa-v2.19/synthetic-workspace/`, outside this repo's tracked tree), with filesystem before/after snapshots as the ground truth for "did a write occur" — not a narrated claim. This is exactly the shape of verification the binding Phase-2.D caveat called for.

**Setup:** synthetic workspace with `cowork.install.json` (`kit_version: "2.19.0"`), copies of the real `self-apply/SKILL.md` and `self-upgrade/SKILL.md`. Pre-invocation MD5 snapshot taken.

- **Scenario 1 — dormant no-op (AC-UPGRADE-3c, no target).** Invoked as "can I walk this workspace's engine forward?" with no synthetic target artifact present. `semver-compare.sh upgrade-ready 2.19.0` → `ready` (valid base), but v2.19 ships zero real forward-walk targets and none was fixtured in. Per `self-upgrade/SKILL.md` §"Dormant-but-reachable": emitted "nothing to walk forward to yet," **zero writes**. **Verified:** full-tree MD5 snapshot before/after is byte-identical.
- **Scenario 2 — Write-Class-1 routing (non-safety file).** Synthetic target = a new `global-instructions.md` (not in the Class-2 safety list). Classified Write-Class-1 correctly (target path doesn't match `self-apply|self-archive|self-upgrade|deny-list|verifier|canonicalize-scan`). Per the ordinary confirm-apply gate: render diff, ask for a fresh yes — with no real user "yes" given in this fixture exercise, **no write occurs**. Verified: `self-apply/SKILL.md` MD5 unchanged (irrelevant to this scenario's target, included as a control). This proves the no-op branch is not a blanket pass-everything — routing genuinely reaches the confirm gate for a real (non-safety) target.
- **Scenario 3 — MF-2(a) behavioral: safety file via the ORDINARY route, attempted.** Synthetic "upgrade step" attempts to deliver a new `self-apply/SKILL.md` as an ordinary bulk engine-file write (skipping Class-2 ceremony). Deny-first classification catches the **target path** (`.claude/skills/self-apply/SKILL.md`) before any delivery-mechanism intent is honored → **REFUSED / rerouted** to Write-Class-2. **Verified:** `self-apply/SKILL.md` in the synthetic workspace is unchanged (MD5 `d194ae80181f9cf93202ac22fb24deb9` before and after) — the ordinary-route attempt did not land.
- **Scenario 4 — MF-2(b), the harder one: new machinery FAILS verification under the OLD gate.** I built a **QA-authored** "new machinery" candidate for `self-apply/SKILL.md` that silently drops the `self-*` reserved-prefix deny glob (reproducing the pre-MF-1 regression) while leaving other prose intact. Applying the OLD gate's own non-regression discipline (the MF-1 deny-completeness check) to this candidate: `skills/self-\*` pattern is **MISSING** → verification **FAILS**. Per AC-UPGRADE-8(i), verify-then-swap: **the swap does not occur**; old machinery (MD5 unchanged, still carrying full `self-*` protection) stays live. **Verified via filesystem**, not narrated.

**What this does and does not prove:** it proves the routing/judgment logic in the SKILL.md prose, honestly followed by a real agent session against real synthetic inputs, produces the specified outcomes in all 4 traced paths. It does **not** prove every future agent session will follow this prose correctly every time — that residual (an LLM's fidelity to its own instructions) is the same honest limit `self-apply`'s own "Honest limit" section already discloses for its verifier. No claim beyond that is made.

---

## 3. MF-v2.19-S-1..12 + 3 MF-1 refinements + MF-6-as-script

| MF | Verdict | Evidence |
|---|---|---|
| MF-1 (linchpin, namespace deny) | PASS | Pre-fix (`git show 383f46a:skills/self-apply/SKILL.md`) has **0** matches for `self-archive`/`self-upgrade`/`skills/self-\*` — negative control genuinely fires. Fixed file has all 3. |
| MF-1a (reserved-prefix + explicit 3 members) | PASS | Both present in `self-apply/SKILL.md` deny-list clause. |
| MF-1b (hole-in-allow, not blanket floor) | PASS | Confirmed in diff — allow-glob `.claude/skills/*/SKILL.md` unchanged; only a hole carved via deny-first evaluation. |
| MF-1c (channel-scoping, LOAD-BEARING, no carve-out) | PASS | Prose present; **and functionally exercised** — AC-PULL-7's backfill fixture (§1 above) proceeds via the installer channel while the apply-channel deny (Scenario 3, §2) independently refuses the same file. Both hold simultaneously, proving no carve-out broke AC-PULL-7. |
| 4 Phase-2.D firing controls (self-review REFUSED / 3 siblings REFUSED / installer-backfill SUCCEEDS / vendor-comparison SUCCEEDS) | PASS | All 4 reproduced: `self-review` → DENIED (prefix match); `self-apply`/`self-archive`/`self-upgrade` → all present in deny-list; installer-channel backfill of `self-upgrade` → PROCEED (byte-correct); `vendor-comparison` → NOT DENIED BY PREFIX, ordinary allow-glob applies. |
| MF-2 (3 firing controls) | PASS — see §2. (a)/(c) mechanically classifiable; (b) live-invoked. |
| MF-3 (fresh-bytes-both-sides) | PASS — see AC-PULL-6 above. |
| MF-4 (backfill byte-verify + registry row) | PASS | All 4 relevant registry sha256 values (`self-apply`, `self-archive`, `self-upgrade`, `pull-updates`) **independently recomputed** via `sha256sum` in Python and matched byte-for-byte against `curated-skills-registry.md`'s stored values. Poisoned-copy refusal reproduced with a QA-built poison (§ above). |
| MF-5 (malformed manifest refuse) | PASS — see AC-PULL-9 above, incl. 2 QA-built fixtures. |
| MF-6 (semver-aware, AS A SCRIPT) | PASS | See AC-UPGRADE-2. Implemented as `scripts/semver-compare.sh`, not model-judgment prose — the Phase-2.D upgrade honored. |
| MF-7 (no network, either face) | PASS-WITH-NOTE | See §6 below — 2 non-substantive grep hits on the diff, both confirmed benign by manual read. |
| MF-8 (additive-tightening only) | PASS | `git diff 383f46a..HEAD -- skills/self-apply/SKILL.md skills/self-archive/SKILL.md` manually read in full: the self-apply deny-list paragraph was **replaced**, not purely appended — but the replacement is strictly a superset (was: 1 exact-path entry for `self-apply` itself; now: `self-apply` + `self-archive` + `self-upgrade` + `context/.kit-migrations/`, same allow-glob unchanged). self-archive's change is a pure in-place addition to its existing namespace-floor sentence. No deny narrowed, no allow-glob widened, no confirmation relaxed, in either file. |
| MF-9 (kit-migrations on both deny-lists) | PASS | `context/.kit-migrations/` confirmed present in both `self-apply/SKILL.md` (apply deny) and `self-archive/SKILL.md` (move deny) diffs. |
| MF-10 (install.json deny byte-unchanged) | PASS | The specific clause `` the workspace-root install manifest, `cowork.install.json` (ADR-067), are never apply-writable, no matter what `` is byte-identical pre/post diff. |
| MF-11 (reuse-by-reference, not re-declared) | PASS | 8 reference lines, 0 re-declared section headers (independently re-run, matches @dev's own count). |
| MF-12 (dormant no-op writes nothing) | PASS — see §2 Scenario 1 (filesystem-verified zero writes). |

---

## 4. Byte-unchanged / structural checks

- **7-file byte-unchanged deny-list:** `scripts/canonicalize-scan.sh`, `cowork.lock.json`, `.cowork-allowlist.json`, `templates/cowork.install.template.json` — all **UNCHANGED** (confirmed via `git diff 383f46a..HEAD`, empty output for each). `CONTRIBUTING.md:129` anchor — **byte-identical** (`git show` vs. working tree, manually diffed line-by-line). `self-apply/SKILL.md` and `self-archive/SKILL.md` — additive-only, see MF-8 above.
- **Fresh-workspace reachability (AC-PULL-7 / WIZARD):** `WIZARD.md` diff confirms Step 4 installs `self-upgrade` AND `pull-updates` unconditionally in **both Mode A and Mode B**, plus updates the folder-structure diagram and the Setup-complete closing message. The Fallback "existing workspace" flow (Option 2) also backfills both, byte-verified against the registry sha256 — confirmed by direct read of the diff.
- **ADR Maturation Path (step 4a of my own workflow):** ADR-071, -072, -073, -074 all carry `#### §Maturation Path (per [[maturation-path-in-adr]] binding)` with all 3 required sub-bullets (`Future-state options:` / `Concrete revisit triggers:` / `Risk knowingly accepted:`) present and non-empty. **INFO:** the Phase 1 Summary in scratchpad claims "Maturation 36→40 (+4)"; my own count (`git show a2d317f` vs. HEAD) gives **29→33 (+4)**. The delta (+4, matching the 4 new ADRs) is correct and is the functionally load-bearing fact; the absolute base numbers in the narrative appear to be a miscount. Not blocking — recorded as an INFO carry-forward for narrative hygiene.

---

## 5. Classification

**SECURITY-SENSITIVE — reaffirmed.** Independently re-derived: this cycle installs new self-modifying engine machinery (`self-upgrade`, dormant-but-reachable), extends the deny-list trust boundary (MF-1), and ships a backfill path that writes the safety gate itself into pre-v2.19 workspaces (AC-PULL-7). Any one of these is sufficient; all hold. No combined/lightened path. No compliance surface. No outbound network (see §6).

**Auto-fail trigger scan:** ran case-insensitive scans for "zero issues," "perfect/100%/flawless" superlatives, and marketing superlatives ("luxury," "premium," "production-grade," "enterprise-grade," "world-class") against the v2.19 spec section, `docs/security-review-v2.19.0.md`, CHANGELOG entry, and both new SKILL.md files — **CLEAN, 0 matches**. (Unrelated "100%" hits exist elsewhere in `spec.md` from older, non-v2.19 cycle sections describing factual test-coverage statistics — not marketing claims, not in scope for this cycle's gate.)

---

## 6. CI simulation

| Check | Result |
|---|---|
| `self-apply-deny-completeness-check` (MF-1 CI job) fault-injection self-test | **PASS** — reproduced independently: stripped-copy assertion correctly goes RED (all 3 patterns missing → FAIL=1); real fixed file correctly goes GREEN (FAIL=0). |
| YAML validity (`quality.yml`) | PASS (`yaml.safe_load` succeeds). |
| New `uses:` / new Action SHA | **PASS** — 0 new `uses:` lines added; the new job reuses the existing pinned `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683` (30 occurrences file-wide, same SHA everywhere). |
| No-network grep on new/edited lines (MF-7) | **NOTE, not a defect** — the literal command `git diff 383f46a..HEAD | grep '^+' | grep -Ei 'curl\|wget\|fetch\|nc \|ssh \|https?://'` returns 2 hits, not the clean 0 the security review's verify clause implies: (1) the README version badge URL — a pre-existing badge pattern, bumped for the version number only, not a new network surface; (2) a `pull-updates/SKILL.md` sentence using the word "fetches" in **negation** ("it never fetches anything over the network"). Both manually confirmed non-substantive. Recommend the security-review verify clause be reworded to `grep ... | grep -v 'never\|badge'`-style or reviewed manually each time, since a keyword grep on prose describing the absence of a behavior will always false-positive on that behavior's own vocabulary. |
| shellcheck on `semver-compare.sh` + `tests/fixtures/v2.19/*.sh` | **UNABLE TO VERIFY** — `shellcheck` is not installed in this sandbox and package install requires root (`apt-get` failed: permission denied on dpkg lock, no sudo available). Not assumed clean. Recommend @dev or CI run shellcheck before merge; flagging rather than silently skipping. |
| markdownlint on new `.md` files | **FAIL — reproduced, real CI-breaking defect.** Ran `npx markdownlint-cli2` with the **exact globs `quality.yml`'s `markdown-lint` job uses** (`**/*.md !docs/** !vendored/agency-agents/**`, config from `.markdownlint.jsonc` / `.markdownlintignore`, neither of which excludes `tests/`): **`tests/self-upgrade-firing-controls.md` produces 10 MD031 (blanks-around-fences) errors** at lines 43, 47, 133, 139, 170, 174, 201, 206, 241, 244 — every fenced code block nested inside a list item in that file is missing a blank line before and/or after the fence. Exit code **1**. This is the only file with issues among the 163 linted. **This will fail CI's `markdown-lint` job on push** — it is not hypothetical; I ran the identical command CI runs. |

---

## 7. Findings

### ISSUE (blocks Phase 5 PASS until fixed — mechanical, non-security)

- **`tests/self-upgrade-firing-controls.md` fails `markdown-lint` CI (MD031, 10 occurrences).** Fenced code blocks at lines 43, 47, 133, 139, 170, 174, 201, 206, 241, 244 need a blank line before the opening fence and/or after the closing fence where they sit inside a list-item's continuation text. Fix: add the missing blank lines (does not change any command or evidence content — purely markdown formatting). Route to @dev; re-run `npx markdownlint-cli2 "**/*.md" "!docs/**" "!vendored/agency-agents/**"` locally before re-push to confirm 0 issues.

### ISSUE (non-blocking this cycle — CI-check robustness gap, recommend hardening)

- **`self-apply-deny-completeness-check`'s grep is file-wide, not deny-list-scoped.** I constructed an adversarial regression (stripped the functional `self-*` deny-list enumeration from `self-apply/SKILL.md`, left a decoy/unrelated sentence elsewhere in the file mentioning `self-archive`/`self-upgrade`/the `self-*` pattern) and the CI job's assertion **passed** — because it greps the whole 12KB file for 3 literal substrings rather than confirming they appear *within* the deny-list clause specifically. Note this is not a live vulnerability today (the real deny-list clause is correct — verified above), and the CI job's own fault-injection self-test still catches the *specific* prior vulnerability (all mentions stripped file-wide). But a narrower future regression — one that edits only the deny-list enumeration while incidental prose elsewhere (e.g. the MF-1a/MF-1b explanatory paragraphs, which already independently mention these terms today) survives — would slip through silently. Recommend scoping the CI grep to the paragraph containing "never apply-writable" (e.g. `sed -n '/write-channel allow-list/,/Only past the deny-list/p'` before grepping), or requiring co-occurrence with that anchor phrase. Non-blocking for this cycle (MF-1's actual protection is sound); flagged for @security's Phase 6 consideration as a hardening item on the linchpin gate.

### INFO

- MF-7's no-network verify clause as literally worded produces 2 false-positive grep hits (README badge URL, negation prose) rather than a clean 0 — both manually confirmed non-substantive. Recommend rewording the verify clause for future cycles (see §6).
- Phase 1 Summary's "Maturation 36→40 (+4)" absolute counts do not match an independent recount (29→33, +4); the delta is correct and load-bearing, the base numbers are a narrative miscount. No functional impact — all 4 new ADRs' Maturation Path sections independently verified complete.
- `shellcheck` could not be run in this sandbox (no root, package manager locked). Not assumed clean — recommend running before merge (CI or @dev's own machine).

---

## 8. Unit / E2E Tests

This is a prose-instruction kit (SKILL.md files interpreted by an LLM agent), not an application with a Vitest/Playwright layer. The project's established test convention (since v2.16) is the manually-recorded, re-runnable firing-controls document + shell fixtures, which this report re-verifies independently rather than replacing.

- Total firing-control buckets: 7 (MF-1, MF-2, MF-6, AC-PULL-1/6, AC-PULL-7, AC-PULL-9, AC-UPGRADE-3c)
- Independently reproduced by @qa (fresh fixtures, not just re-running @dev's): 7/7
- Passing: 7/7 (all fired correctly, both GREEN and RED legs where applicable)
- Failing: 0
- CI jobs simulated: 3 (deny-completeness, YAML validity, markdown-lint) — 2 PASS, 1 FAIL (see §6/§7)

---

## Verdict

**FAIL (rework required) — but narrowly.** Every AC, every MF, both hard-gate live-invocations, and the classification all independently re-verify PASS with real, reproduced evidence (not narrative). The one blocking item is a **mechanical, non-security markdown-formatting defect** in a new test-evidence file that will fail CI's `markdown-lint` job on push. This is a fast fix (blank lines around 10 fenced blocks) and does not require any change to the security/AC substance verified above.

**Recommendation:** route the markdownlint fix back to @dev (or apply as a trivial formatting-only commit), re-run `npx markdownlint-cli2` to confirm 0 issues, then re-present to @qa for a fast re-confirm (no re-verification of the AC/MF substance should be needed — only the CI-gate re-run). The CI-completeness robustness gap (§7, non-blocking) and the 2 INFO items should carry forward to @security's Phase 6 review.

**qa_issues_prevented: blocker=0 issue=2 info=3**

(2 issues: the CI-breaking markdownlint defect, and the MF-1 CI-check robustness gap. 3 info: MF-7 grep false-positives, Maturation count narrative mismatch, shellcheck unable-to-verify.)
