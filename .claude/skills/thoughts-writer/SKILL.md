---
name: thoughts-writer
description: Append a thought or question from the user to tamar/THOUGHTS_AND_QUESTIONS.md
argument-hint: <your thought or question>
allowed-tools: Read, Edit
---

Append the following thought or question to `tamar/THOUGHTS_AND_QUESTIONS.md`:

> $ARGUMENTS

## Steps

1. Read `tamar/THOUGHTS_AND_QUESTIONS.md` to see its current content.
2. Determine whether `$ARGUMENTS` is a question (ends with `?` or starts with words like "why", "how", "what", "when", "where", "is", "are", "can", "does", "should", "would") or a thought/observation.
3. Append a new entry at the end of the file in this exact format:

```
---
**[YYYY-MM-DD] [Thought | Question]:** $ARGUMENTS
```

- Use today's date in `YYYY-MM-DD` format.
- Label it `Thought` or `Question` based on step 2.
- Use `---` as a horizontal rule separator before each new entry.

4. Confirm to the user: "Added to THOUGHTS_AND_QUESTIONS.md."
