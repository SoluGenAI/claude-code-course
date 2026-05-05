---
name: explain-commits
description: Format rules for explaining git commits to an engineer-audience. Activated by the /explain-commits slash command. Defines stanza shape, indentation, and the list of things never to write.
---

# Explain-Commits Format Rules

You are formatting commit explanations for an engineer who knows this codebase, reading next week. Your single responsibility is format discipline. The slash command and sub-agent handle parsing and git work.

## Output format

Per commit, produce exactly two lines:

```
<short-sha> <one-line what>
        <one-sentence why>
```

- **Line 1**: 7-char SHA, single space, present-tense summary of the change. Subject-line voice ("Bump cache TTL", not "This commit bumps the cache TTL").
- **Line 2**: 8 spaces of indent (aligning the text under `<one-line what>`), one sentence explaining the *why*: the constraint, bug, or goal that motivated the change.
- **Separator**: one blank line between stanzas. No separator after the last stanza.

## Hard rules

1. **No code blocks.** No triple-backtick fences. No inline backticks around code identifiers (file names and SHAs are fine without backticks).
2. **No process narration.** Never write "I looked at the diff", "Let me explain", "Here are the commits", "Based on the changes", or any first-person commentary.
3. **No filler.** Never write "It's worth noting", "This is significant because", "As we can see", "Importantly", "Note that".
4. **Domain terms allowed and unexplained.** Bedrock, Alembic, MinIO, RDS, ORM, dedup, etc. Use them, do not gloss them.
5. **One commit per stanza.** Do not merge, group, or summarize multiple commits into one stanza.
6. **Length cap.** Each stanza is exactly the SHA-line plus one why-line. If you need a third line, you are including filler. Cut it.
7. **Subject voice.** "Add", "Bump", "Fix", "Refactor", "Remove", not "Added", "Bumps", "Fixes".

## Failure-mode output (still inside the format)

- **Purpose unclear from diff**: render `<sha> <subject>: purpose unclear from diff` as a single-line stanza. Do not invent a why.
- **Fewer commits than requested**: render every available stanza, then on its own line: `(only K commits available on <branch>)`.

## Examples

Good:

```
bea1943 Bump Bedrock cache TTL to 5min
        Reduces system-prompt re-reads when the classifier fires multiple calls in a session.

98b4b8f Add child-level parallelization to extraction runner
        Wall-time was bottlenecked on serial OCR; child-level fan-out cuts it 48%.
```

Bad (and what makes it bad):

```
bea1943 - This commit bumps the cache TTL    ← past-tense, "This commit", em-dash filler
        I looked at the diff and it appears  ← process narration
        that it's worth noting...            ← filler
```
