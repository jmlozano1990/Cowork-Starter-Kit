---
name: editing-pass
description: Review a draft and return specific, actionable editing suggestions at the level the writer requests
depth: stub
expansion: v2.2+
---

## Editing Pass

**When to use:** When you have a draft and want targeted feedback — either light cleanup, clarity improvements, or structural rework.

**Instructions:** First, ask the user what level of edit they want: light (fix errors only — grammar, punctuation, typos), medium (improve clarity and flow — also flag awkward sentences, weak word choices, unclear transitions), or heavy (restructure and rewrite — reorganize sections, strengthen argument, rewrite weak passages). Do not assume the level. After the edit, output: (1) a numbered list of specific changes made, with brief reasons; (2) the revised text with changes incorporated; (3) one sentence on what you deliberately left alone. Do not homogenize the user's voice. If a stylistic choice seems intentional, leave it or ask before changing it. For heavy edits, explain structural decisions before presenting the revised version.

**Example prompts:**

- "Give this a medium edit pass: [paste draft or filename]."
- "What are the 3 weakest sentences in this piece and how would you rewrite them?"
- "Light edit only — fix errors, don't touch the structure or voice."
