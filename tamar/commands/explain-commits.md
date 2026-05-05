---
description: Explain the last N commits on a branch in bounded, engineer-audience format.
argument-hint: "[branch] <N>"
allowed-tools: Bash, Task
---

You are running the `/explain-commits` command. Apply the `explain-commits` skill format strictly. Do not narrate this process to the user; just produce the final formatted output (or a fail-fast error).

## Raw arguments

`$ARGUMENTS`

## Argument parsing (fail-fast, no defaults beyond what is specified)

1. Split the raw arguments on whitespace.
2. Branch / N resolution:
   - **One arg**: if it parses as a positive integer, set `N` to that integer and `branch` to the current branch (`git rev-parse --abbrev-ref HEAD`). Otherwise fail-fast.
   - **Two args**: `branch = first`, `N = second`. `N` must parse as a positive integer.
   - **Zero or 3+ args**: fail-fast.
3. On any parse failure, output exactly:
   ```
   Usage: /explain-commits [branch] <N>
   Got: <raw arguments>
   Reason: <one-line reason>
   ```
   and stop.
4. Verify the branch exists locally with `git rev-parse --verify <branch>`. On non-zero exit, fail-fast and include the exact command and its stderr.

## Diff fetching

Invoke the `tamar-plugin:diff-fetcher` sub-agent via the Task tool (use the fully-qualified name with the `tamar-plugin:` prefix; the bare `diff-fetcher` name will not resolve). Pass it `branch` and `N`. It returns a structured per-commit list with trimmed `--stat` output (no full patches). Do not run `git show <sha>` yourself in the main thread. That is the whole reason the sub-agent exists.

## Rendering

Format the sub-agent's output per the `explain-commits` skill rules. The skill is the authority on output shape: read its `SKILL.md` and obey it.

If the sub-agent returns fewer than `N` commits because the branch has fewer, render every commit it returned and append on its own line:
`(only K commits available on <branch>)`

## What you must NOT do

- Do not summarize, group, or reorder commits.
- Do not output anything before, between, or after the stanzas except the optional "(only K commits…)" line.
- Do not run any git command that mutates state (`stash`, `reset`, `checkout --`, `clean`, etc.).
