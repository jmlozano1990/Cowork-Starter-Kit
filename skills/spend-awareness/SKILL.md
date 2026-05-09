---
name: spend-awareness
description: Summarize pasted transaction data by category in plain language to surface spending patterns — descriptive only, does not provide investment advice, budgeting recommendations, or savings plans
trigger_examples:
  - "Categorize my spending from these transactions"
  - "Where did my money go last month?"
  - "Summarize this spending data by category"
  - "What categories make up my recent purchases?"
---

## When to use

Use spend-awareness when the user pastes transaction data, bank exports, credit card statements, or a list of recent purchases and wants to understand where their money went. This skill produces a plain-language category summary — descriptive only. It surfaces patterns in what the user has already spent; it does not evaluate those patterns, recommend changes, or provide financial guidance of any kind. Use it when the user wants a clear picture of their spending, not advice about it.

## Triggers

- User says "categorize my spending", "where did my money go", or "summarize transactions" — direct invocation.
- User pastes a list of transactions, a bank export, or a statement and asks for a breakdown.
- User asks which categories they spent the most on with transaction data attached.
- User wants a plain-language summary of their purchases without financial advice.

## Instructions

1. **Read the full transaction data before categorizing.** Do NOT categorize on first pass — read all entries, then group. This prevents misclassification at the boundaries (e.g., a grocery order that includes household items).
2. **Assign each transaction to a category.** Use common-sense categories: Food & Dining, Transport, Subscriptions, Shopping, Health, Entertainment, Utilities, Services, and Other (for anything that doesn't fit). Apply categories consistently — do NOT invent new categories for one-off items; use Other instead.
3. **For each category, produce: category name, total amount, and transaction count.** Present as a plain-language bullet list. State totals in the same currency as the input. If multiple currencies are present, note it and do NOT convert.
4. **Surface patterns with neutral descriptive language only.** It is appropriate to note "Food & Dining is your largest category this period" or "Subscriptions accounts for 22% of total spend." It is NOT appropriate to evaluate whether this is good or bad, to compare to benchmarks, or to suggest changes.
5. **If the user asks for advice, redirect neutrally.** Use this exact phrase: "for planning, consider a financial advisor." Do NOT rephrase this as a suggestion to cut spending, to reconsider categories, or to set goals.
6. **Do not infer financial goals.** The user's spending pattern is data, not evidence of their priorities. Do NOT write sentences like "it looks like travel is a priority for you" or "you seem to be investing in your health." Describe the data; do not interpret it.

## Output format

Plain language bullet list in the chat. Format per category: `- [Category]: $[total] ([N] transactions)`. After the category list, add one summary line: total spend across all categories and the date range if determinable from the data. No JSON, no YAML, no Obsidian wikilinks. Output is portable — usable in a notes app, spreadsheet, or plain text.

## Quality criteria

1. All transactions are categorized — nothing is silently dropped.
2. Category totals and counts are accurate — verifiable against the source data.
3. Language is descriptive only — no recommendations, no benchmarks, no evaluations.
4. If the user requests financial guidance, the skill redirects with the exact phrase: "for planning, consider a financial advisor."
5. No financial goals are inferred from the spending pattern.

## Anti-patterns

- **Recommending investments** — any suggestion about where to put money, including low-risk or saving-focused suggestions, is investment advice and is outside this skill's scope. Do not provide investment advice.
- **Suggesting budgeting changes** — "you might consider reducing your dining spend" or "this category seems high" are budgeting recommendations. This skill describes; it does not recommend. Do not make budgeting recommendations.
- **Proposing savings plans** — "setting aside 10% from this category" or "if you cut subscriptions, you could save $X" are savings plans. This skill does not propose savings plans.
- **Inferring financial goals** — writing sentences that imply the user has a goal (saving, investing, cutting costs) based on their spending data. The data shows what happened; it does not reveal intent.
- **Moralizing spending categories** — labeling any category as excessive, unnecessary, indulgent, or problematic. Spending data is neutral. For any questions about planning, the appropriate redirect is: "for planning, consider a financial advisor."

## Example

**Input (pasted transactions — partial):**

```
2026-04-01  Whole Foods  $87.43
2026-04-02  Uber  $12.50
2026-04-03  Netflix  $15.99
2026-04-04  Whole Foods  $54.10
2026-04-05  Spotify  $9.99
2026-04-06  Pharmacy  $23.40
2026-04-07  Amazon  $67.00
2026-04-08  Gas Station  $48.00
```

**Output:**

- Food & Dining: $141.53 (2 transactions)
- Transport: $60.50 (2 transactions)
- Subscriptions: $25.98 (2 transactions)
- Health: $23.40 (1 transaction)
- Shopping: $67.00 (1 transaction)

Total: $318.41 across 8 transactions (April 1–8, 2026).

Food & Dining is the largest category this period, accounting for 44% of total spend.

## Writing-profile integration

Spend-awareness is a structured data-summary skill — category labels, totals, and counts are data fields and profile-neutral. The summary observation line ("Food & Dining is the largest category") is the only prose element where register applies. Consult `context/writing-profile.md` for tone on this line only: a formal profile produces "Food & Dining represents the largest expenditure category"; a conversational profile produces "Food & Dining is where most of the spending went." The redirect phrase "for planning, consider a financial advisor" is always verbatim, never adapted.

## Example prompts

- "Categorize my spending from these transactions: [paste]."
- "Where did my money go last month? [paste statement]."
- "Summarize this spending data by category: [paste]."
- "What categories make up my recent purchases? [paste]."
