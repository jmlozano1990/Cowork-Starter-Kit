---
name: flashcard-generation
description: Generate Anki-ready flashcards from source material using spaced-repetition best practices (atomicity, cloze deletion, minimum information principle).
trigger_examples:
  - "Make flashcards from this"
  - "Give me flashcards on [topic]"
  - "Help me study [topic]"
  - "Help me memorize this material"
  - "I have an exam next week on [topic]"
---

## When to use

Use this skill when the user asks for flashcards from provided source material for study or recall practice. Also use it when the user shares study material under exam or deadline pressure and needs retrieval practice. If the user needs conceptual understanding rather than recall, prefer summary-synthesis over flashcard generation.

## Triggers

- User says "Make flashcards" or "Give me flashcards" with an explicit file or topic reference — highest-confidence direct invocation.
- User says "Flashcards on [topic]" — direct request variant without source material attached.
- User says "Help me study [topic]" or "Help me memorize [topic]" — intent without naming the skill; offer flashcard generation as one option.
- User shares study material and mentions an exam, quiz, or test deadline — proactively offer to generate a card set.
- User shares notes, a chapter excerpt, or a dense reading and asks what to review — implicit retrieval-practice signal.

## Instructions

1. Read the full source material the user provided before generating any cards.
2. Identify atomic facts — one concept each; exclude compound facts, enumerations, and ambiguous claims.
3. For each fact, choose the clearest format: plain Q/A for discrete facts, cloze deletion for facts-in-context where surrounding words aid retrieval.
4. Generate at minimum 10 cards; target 15–20 for substantial sources.
5. Review each card against the 6 Quality criteria before output — discard any card that fails.
6. Render the cards in human-readable format first: numbered list, Q/A pairs and cloze sentences.
7. Render the Anki-importable TSV block immediately below the human-readable version.
8. End with a one-line summary stating how many cards were generated and what topic tag was applied.

## Output format

Two blocks in sequence, separated by a blank line and a `---` divider.

**(a) Human-readable block** (for user review before import):

```
1. Q: [question text]
   A: [answer, ≤ 3 sentences]

2. Cloze: [sentence with {{c1::hidden text}} inline]
```

**(b) Anki TSV block** (tab-separated, paste directly into Anki File > Import):

```
question[TAB]answer[TAB]tags
cloze-sentence-with-{{c1::syntax}}[TAB][TAB]tags
```

Tags: one space-separated tag string derived from the source topic (e.g. `biology cell-biology mitochondria`), applied uniformly to every card unless the user specifies per-card tags. Card order preserves logical source order. Card count target is 10–20 unless the user overrides.

## Quality criteria

- Each card tests exactly one concept (atomicity — no compound questions).
- Each fact is expressed with minimum information: the narrowest phrasing that still carries full meaning.
- Each question is specific and unambiguous — "What is X's role in Y?" not "Tell me about X."
- Cloze deletion is used when context matters to retrieval; plain Q/A is used when it does not.
- The card set contains ≥ 10 cards (target 15–20 for substantial sources).
- Each card references the source snippet or topic for retrieval cue — no free-floating facts.

## Anti-patterns

- Compound cards that test multiple concepts at once — ungradeable by spaced-repetition algorithms.
- Yes/no questions that permit guessing without active recall.
- Vague "Tell me about X" questions with no single correct answer.
- Cards where both the question and answer copy source sentences verbatim — defeats retrieval practice.
- Single card demanding full enumeration ("Name all 5 stages of X") — split into 5 separate cards or clozes.
- Leading questions that telegraph the answer ("The powerhouse of the cell is the ___?") — no cognitive work required.

## Example

**Input (source snippet):**

> The mitochondrion is a membrane-bound organelle found in most eukaryotic cells. It generates most of the cell's supply of ATP through oxidative phosphorylation, which occurs across the inner membrane. Mitochondria have their own DNA, inherited maternally, and are thought to have evolved from endosymbiotic bacteria.

**Output (human-readable):**

```
1. Q: What cellular process generates most ATP in eukaryotic cells?
   A: Oxidative phosphorylation.

2. Q: In which organelle does oxidative phosphorylation occur?
   A: The mitochondrion.

3. Cloze: Oxidative phosphorylation occurs across the {{c1::inner membrane}} of the mitochondrion.

4. Q: From which parent is mitochondrial DNA inherited?
   A: The mother (maternally inherited).

5. Q: According to endosymbiotic theory, what did mitochondria evolve from?
   A: Endosymbiotic bacteria.

6. Cloze: Mitochondria are found in most {{c1::eukaryotic}} cells.
```

---

**Anki TSV block:**

<!-- markdownlint-disable MD010 -->
```tsv
What cellular process generates most ATP in eukaryotic cells?	Oxidative phosphorylation.	biology cell-biology mitochondria
In which organelle does oxidative phosphorylation occur?	The mitochondrion.	biology cell-biology mitochondria
Oxidative phosphorylation occurs across the {{c1::inner membrane}} of the mitochondrion.		biology cell-biology mitochondria
From which parent is mitochondrial DNA inherited?	The mother (maternally inherited).	biology cell-biology mitochondria
According to endosymbiotic theory, what did mitochondria evolve from?	Endosymbiotic bacteria.	biology cell-biology mitochondria
Mitochondria are found in most {{c1::eukaryotic}} cells.		biology cell-biology mitochondria
```
<!-- markdownlint-enable MD010 -->

*6 cards generated. Topic tag: `biology cell-biology mitochondria`.*

## Writing-profile integration

Flashcard content is structured data (< 100 words per card) — `context/writing-profile.md` is NOT consulted for card content itself. If Cowork appends an explanatory summary paragraph after the card set (≥ 100 words), that summary consults `context/writing-profile.md` and applies the user's tone, sentence-length preferences, and pet peeves.

## Example prompts

- "Make flashcards from this biology chapter on photosynthesis."
- "Help me memorize the key cases from this legal opinion — I have the exam Tuesday."
- "/flashcard-generation — generate 20 cards from my linguistics notes."
