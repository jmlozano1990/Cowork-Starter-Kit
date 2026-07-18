# UX Review — Claude Cowork Config

## Phase: Pre-implementation (Phase 2 gate input)
## Date: 2026-04-14T00:00:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Area | Description |
|----|----------|------|-------------|
| U1 | WARNING | Wizard flow (F1/F2) | Q2 (tools) placed before Q3 (output format) — wrong priority order for Alex |
| U2 | WARNING | Wizard flow (F1/F2) | Custom goal fuzzy-match confirmation step buries the escape hatch |
| U3 | WARNING | SETUP-CHECKLIST (F7) | Steps 4 and 6 require context not yet available to a first-time user |
| U4 | WARNING | SETUP-CHECKLIST (F7) | "Try this now" prompt assumes folder already populated — will fail for net-new users |
| U5 | WARNING | Error recovery (F8 gap) | Skill failure recovery path references `skills-as-prompts.md` not specified elsewhere in the output package |
| U6 | WARNING | First-session prompts (F6) | All "Try this now" prompts read PDFs or files — but a brand-new user's folders are empty |
| U7 | INFO | Safety note (F5) | Safety note mentions SkillRisk.org — a domain name that is not recognizable to non-technical users without any context |
| U8 | INFO | README CTA (F8) | "Star this repo if it helped you" is placed above-the-fold before the user has gotten value — premature ask |
| U9 | INFO | Accessibility | No alt text guidance for any visual element specified in the README (ASCII diagram or table) |
| U10 | INFO | Wizard flow (F1) | Model check note is non-blocking but appears at wizard open — Alex will skip it without reading |
| U11 | INFO | Connector checklist (F6) | Managed Google Workspace note is buried at the connector level — Alex with a university account will hit this wall silently |
| U12 | WARNING | Wizard flow (F1/F2) | Q5 (safety check) asks about folder risk before the user has been told what Cowork can do to files — informed consent gap |

---

### CRITICAL

No CRITICAL findings. All blockers are WARNINGs that degrade the first-session experience but do not prevent setup completion.

---

### WARNING

- [ ] **U1 — Question order: Q2 (tools) before Q3 (output format) misserves Alex.** Alex does not think in terms of "what tools do I use" — he uses Google Drive because his professor requires it, not because it is a deliberate choice. Asking about tools second, before establishing how he wants Claude to communicate with him, front-loads an IT-adjacent question at the moment his engagement is highest. The output format preference (Q3) directly shapes every response he will ever get. It should be Q2. Connector mapping (currently Q2) can be Q4 or later since it is lower urgency for a student and the connector checklist is a post-wizard step anyway. Recommended order: Q1 Goal → Q2 Output format → Q3 Preset-specific context (role/subject) → Q4 Tools → Q5 Safety.

- [ ] **U2 — Fuzzy match escape hatch is a dead end without a visible fallback.** The spec says: "It sounds like [Research] — is that right? If not, I'll show you all 6 options." That conditional is fine in prose, but WIZARD.md must make the "no" path visually clear. A non-technical user who types a custom goal and gets the wrong match will likely either accept the wrong preset (silent failure) or abandon. The "no" path needs to be a concrete, visible action: "Say 'no' and I'll show you all 6 options." The current spec AC implies this but does not require that WIZARD.md include explicit "yes/no" response guidance. Add: WIZARD.md must include a labeled response prompt ("Reply YES to continue or NO to see all 6 options") after every fuzzy-match confirmation.

- [ ] **U3 — SETUP-CHECKLIST step 4 assumes user knows how to open a markdown file.** Step 4 reads: "Open `context/about-me.md` in any text editor → fill in your name, role, and goals → save." For Alex, "any text editor" is not obvious. On macOS, markdown files may open in Preview (read-only) or an app that does not make editing obvious. The spec says "zero code barrier" and "executable by a user who has never opened a terminal" — this step currently has a gap. Add explicit parenthetical: "(On Mac: right-click the file → Open With → TextEdit. On Windows: right-click → Open With → Notepad.)" This is micro-copy, but it is the difference between Alex completing setup and Alex giving up.

- [ ] **U4 — "Try this now" prompts will fail for a user who follows the checklist in order.** Steps 1–8 in SETUP-CHECKLIST walk the user through creating the project structure, but the "Try this now" prompt (step 8) tells Alex to ask Cowork to "Read the PDFs in my Papers/ folder." The Papers/ folder is brand new and empty. This will produce either an error message ("I don't see any PDFs") or a generic response, both of which deflate the first-session high the prompt is designed to create. Two fixes required: (a) Add a preflight note before "Try this now": "For this first test, you can copy one PDF or document into your Papers/ folder now. If you don't have one, try [alternative prompt that works on an empty folder]." (b) Provide an empty-folder fallback prompt for each preset. Example for Study: "Ask Cowork: 'I'm a [your subject] student. Help me plan a study schedule for next week.'" — this works with zero files.

- [ ] **U5 — Error recovery path references `skills-as-prompts.md` with no specification for what that file contains.** The "What if something goes wrong?" section directs a user with failing skills to: "Open `skills-as-prompts.md` in your preset folder. Copy the skill content you want and paste it at the start of your message." This file is not specified anywhere in the F7 output package AC list, nor in F9 preset contents. If it ships, great — but if a developer implements the spec without noticing this cross-reference, the error recovery path will point to a file that does not exist. Add `skills-as-prompts.md` to F9 AC as a required file in each preset folder, and specify its format (one section per skill, copy-paste ready).

- [ ] **U6 — All 6 "Try this now" prompts are file-dependent on day one.** This is a systemic variant of U4. Every single preset's first-session prompt asks Cowork to read files from a specific folder. A brand-new user has an empty workspace. The emotional failure of "I did everything right and nothing happened" at the final step is a significant churn risk. The North Star metric is "actively using Cowork within 7 days" — a failed first prompt is the most direct threat to that metric. Each preset needs both a file-dependent prompt AND a file-agnostic fallback prompt. The file-agnostic prompt should be the default, with the file-dependent prompt offered as "once you add some files, try this."

- [ ] **U12 — Q5 (safety) asks about file risk before the user has been told what Cowork can do.** The safety check question is: "Does Cowork have access to any folders with files you'd never want deleted?" For Alex, who has just answered 4 questions about his study goals, this question arrives as a non-sequitur. He does not yet have a mental model of Cowork's file access capabilities because the wizard has not explained them. This inverts informed consent: you are asking for risk disclosure before disclosure of capability. Fix: before Q5, include one sentence of context in WIZARD.md: "Cowork can read, write, and delete files in any folder you give it access to. The next setting makes sure it always asks you first before deleting anything." Then ask Q5. This also makes the safety rule feel like protection, not bureaucracy.

---

### INFO

- **U7 — SkillRisk.org in the safety note is opaque to a non-technical user.** The note says "scan them first at SkillRisk.org." For a beginner, this creates two unknowns: what does "scan" mean in this context, and what is SkillRisk.org? The note should say: "check them at SkillRisk.org, a free tool that scans skills for hidden instructions." This adds 7 words and eliminates both unknowns. The reassurance in the safety note is the right tone — brief, friendly, non-alarming. It just needs one more word of explanation for the domain name.

- **U8 — "Star this repo if it helped you" CTA above the fold is a premature ask.** A user who has just opened the README has not yet gotten any value. Stars are given after value delivery, not before. Move the CTA to below the "What you get" section, which is the first point where the user has understood the product's value proposition. Above the fold should be: product description, who it's for, and how to start. The star ask is a community growth lever that requires earned trust — it should not be the first thing a user sees. An alternative above-fold hook: "Used by [N] knowledge workers and students." (social proof). If the repo is brand-new, use: "Share this with someone who just installed Claude Cowork." Both are less premature than a star request.

- **U9 — The README's ASCII diagram/table has no accessibility guidance.** Screen readers handle ASCII art and table-based diagrams poorly. The spec requires "a visual (ASCII diagram or table) showing the wizard flow." No guidance is given to @dev about alt-text equivalents for screen reader users who access the GitHub README. Recommendation: the diagram or table should be followed immediately by a plain-text description of the wizard flow as a numbered list, serving as both the accessible alternative and a useful summary for skimmers. This satisfies both sighted and screen reader users with one artifact.

- **U10 — Model check note at wizard open will be skipped by Alex.** The model check is designed to surface before the first question. For a student who opened WIZARD.md and is eager to start, any preamble is invisible. The spec marks it as "non-blocking" which is correct. But for the note to have any effect, it should appear as a check-box item: "[ ] I've confirmed I'm using Sonnet or higher (recommended). Tap the model selector if not — or continue anyway." The checkbox format creates micro-commitment and is more likely to be read than a parenthetical paragraph. This is polish, not blocking.

- **U11 — Google Workspace note is buried at step 5 of SETUP-CHECKLIST.** The "If your Google account is managed by an organization (school or employer), your IT admin must authorize Claude in Google Workspace Admin Console before your personal authorization will work" note is specified at the connector level. For Alex (a university student), his university Google account is almost certainly managed by his institution. He will hit this wall at step 5, after investing significant time in the wizard. The Workspace block should be surfaced earlier — at Q2 (tools question) in the wizard — as a proactive heads-up: "If you use a Google account provided by your school or employer, there may be an extra step. We'll cover that when we get to connectors." This does not block the wizard. It prevents a surprise failure late in setup.

---

### Skills Run

| Skill | Triggered | Status |
|-------|-----------|--------|
| U1: Heuristics | Yes — WIZARD.md, SETUP-CHECKLIST.md are prose UI surfaces | WARN |
| U2: Accessibility | Yes — markdown is an accessibility surface (screen readers, no alt text in diagrams) | WARN |
| U3: Obsidian | No — no manifest.json, not an Obsidian plugin | SKIP |
| U4: CSS Quality | No — no CSS or SCSS files specified | SKIP |

---

### Summary

The spec is well-structured and the product concept is strong. The wizard question sequence, the "Try this now" prompts, and the error recovery paths are the three areas that carry the most first-session risk for the primary persona (Alex, the non-technical student).

The most important finding is **U6/U4**: every single first-session prompt in every preset depends on files that do not exist yet. This is the most direct threat to the North Star metric (active use within 7 days). A user who completes setup and gets a null response on their first prompt will not return. This needs a file-agnostic fallback for each preset before implementation begins.

The second highest-impact finding is **U1**: the question order in the wizard front-loads a low-salience question (tools) at the moment of peak engagement, before asking about output format, which shapes every future interaction. Reordering costs zero implementation effort and significantly improves the emotional arc of the wizard.

**U12** (safety consent ordering) is also worth addressing at spec level — it is a single sentence of WIZARD.md copy that transforms a bureaucratic-feeling question into a trust-building moment.

All other findings are incremental polish. No findings block implementation, but **U4, U5, U6** should be resolved in the spec before @dev writes SETUP-CHECKLIST.md, as they require structural changes (new file in output package, fallback prompts per preset) rather than copy edits.

**Recommended pre-implementation actions:**
1. Add empty-folder fallback "Try this now" prompts to each preset in the F7 AC (resolves U4 + U6)
2. Reorder wizard questions: Goal → Output format → Preset context → Tools → Safety (resolves U1)
3. Add `skills-as-prompts.md` to F9 AC required file list (resolves U5)
4. Add one sentence of capability context before Q5 in WIZARD.md spec (resolves U12)
5. Add "right-click → Open With" micro-copy to SETUP-CHECKLIST step 4 AC (resolves U3)
