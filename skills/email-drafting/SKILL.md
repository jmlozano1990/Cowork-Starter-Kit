---
name: email-drafting
description: Draft professional emails in the appropriate tone and format for the recipient and desired outcome
trigger_examples:
  - "Draft an email declining the vendor's proposal professionally"
  - "Follow-up email after the meeting with the client team"
  - "Sensitive email to a client about a late delivery"
  - "Reply to this thread — match the tone"
---

## When to use

Use email-drafting when the user needs a professional email written for a specific recipient and purpose: declining a request, following up, communicating a decision, handling sensitive correspondence, or matching an existing thread's tone. This skill calibrates formality to the recipient relationship and ensures the email structure serves the desired outcome. Use it any time the user has the intent but not the words — or when they have the words but not the structure.

## Triggers

- User says "draft an email", "write an email", or "email-drafting" — direct invocation.
- User describes a situation that requires a professional email: a request to decline, a follow-up to write, a decision to communicate, a sensitive message to handle.
- User pastes an existing email thread and asks to reply, match the tone, or follow up.
- User asks for help with a subject line, opening, or call to action for an email already in progress.

## Instructions

1. **Gather the three essential inputs.** Before drafting, confirm: (a) the recipient and their relationship to the sender (internal colleague, external client, executive, vendor, someone you've never met); (b) the desired outcome — what should happen after the recipient reads the email; (c) any constraints on tone (e.g., "keep it warm but direct", "formal only", "can't seem defensive"). If the relationship and desired outcome are clear from context, proceed without asking.
2. **Calibrate formality to the recipient relationship.** Internal peer → conversational and direct. Executive → brief and outcome-focused. External client → professional but not stiff. Cold outreach → respectful and to-the-point. Vendor → transactional and clear. Do NOT over-formalize a casual recipient or under-formalize an executive.
3. **For sensitive communications, flag before drafting.** If the email involves difficult news, an apology, an escalation, or any content that could affect the relationship, state the tone choice you are making and ask for confirmation before presenting the draft. Do NOT draft sensitive content and present it as final without flagging.

   **Pre-send verification (4 items — check before presenting draft):**
   - [ ] Recipient relationship confirmed and formality calibrated
   - [ ] Subject line is specific and matches the email purpose
   - [ ] Tone matches the recipient relationship and any stated constraints
   - [ ] Sensitive-content scan: if draft contains difficult news, apologies, escalations, or financial/legal content, flag before presenting

4. **Draft with this structure.** Subject line (output separately, before the body): specific and clear — not "Quick follow-up" or "Checking in". Opening: get to the point in the first sentence — state the purpose without preamble. Body: only what the recipient needs to act. Keep under 200 words unless the content requires more. Closing: clear call to action or next step — one specific ask, not a list.
5. **Output subject line separately.** Present the subject line on its own line before the email body. Label it `Subject:`. Do NOT embed the subject in the email body.
6. **Offer a shorter variant if the draft exceeds 150 words.** After the primary draft, offer a version trimmed to under 100 words unless brevity would omit essential information. Let the user choose.

## Output format

Plain text formatted as an email draft. Structure: `Subject: [line]` → blank line → salutation → body → closing → signature placeholder. No JSON, no YAML, no markdown headers inside the email body. Output is copy-paste-ready for any email client.

## Quality criteria

1. Subject line is specific and action-oriented — not generic.
2. Formality matches the recipient relationship.
3. Opening sentence states the purpose — no throat-clearing preamble.
4. Call to action or next step is clear and specific (one ask, not a list).
5. Sensitive content was flagged and tone was confirmed before presenting the draft.

## Anti-patterns

- **Over-formalizing casual recipients** — writing "Dear [Name], I hope this message finds you well" to an internal colleague who sends Slack messages. Match the relationship, not a template.
- **Burying the ask** — placing the key request or decision in the third paragraph after context-setting. The purpose belongs in the first sentence.
- **Softening critical safety or legal information** — toning down a message about a compliance deadline, legal risk, or safety issue to seem less alarming. Flag the content instead.
- **Drafting sensitive content without flagging** — producing an apology, escalation, or difficult-news email without confirming the tone approach first. Sensitive content requires explicit confirmation before drafting.
- **Auto-adding disclaimers** — appending legal disclaimers, confidentiality notices, or boilerplate the user did not request. Include these only when the user explicitly asks or when they are clearly required by context.

## Example

**Input:** "Draft a follow-up email to a client who hasn't responded to our proposal in two weeks. Keep it warm but professional — they're a long-term relationship."

**Output:**

Subject: Following up on the [Project Name] proposal

Hi [Name],

I wanted to follow up on the proposal I sent two weeks ago. I know things get busy, so I wanted to make sure it didn't get buried.

Happy to answer any questions or adjust anything based on how your priorities have shifted. Let me know if now is still a good time to move forward, or if a quick call would help.

[Your name]

---
*Shorter variant (82 words):*

Subject: Quick follow-up — [Project Name] proposal

Hi [Name], following up on the proposal from two weeks ago — want to make sure it didn't get lost in the shuffle. Happy to answer questions or revisit the scope. Just let me know. [Your name]

## Writing-profile integration

Email-drafting consults `context/writing-profile.md` for two purposes: (1) applying documented register preferences to the email body (e.g., a profile that says "avoid hedging" produces a more direct draft); (2) matching documented phrase preferences or anti-patterns (e.g., "never start with 'I hope this email finds you well'"). The pre-send verification step and subject line are always profile-neutral — these are structural requirements, not voice choices.

## Example prompts

- "Draft an email declining [request] while keeping the relationship warm."
- "Follow-up email after the meeting with [name/team]."
- "Sensitive email to a client about [difficult topic]: [context]."
- "Reply to this thread — match the tone: [paste thread]."
