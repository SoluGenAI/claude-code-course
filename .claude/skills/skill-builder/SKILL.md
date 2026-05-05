---
name: skill-builder
description: Creates a new Claude Code skill. Invoke when the user asks to create, scaffold, add, or build a new skill or slash command.
argument-hint: [skill-name] [what it should do]
allowed-tools: Read, Write, Bash(mkdir -p *)
---

Build a new Claude Code skill based on: $ARGUMENTS

## Step 1 — Gather Requirements

If $ARGUMENTS is empty or ambiguous, ask:
- What should the skill do? (one clear sentence)
- Skill name in kebab-case?
- Does it take arguments? If so, what are they?
- Should it auto-invoke when Claude detects relevance, or only via `/skill-name`?
- Scope: personal (`~/.claude/skills/`) or project (`.claude/skills/`)?

## Step 2 — Design the Frontmatter

Select fields based on requirements:
- `description` — precise and specific; this is what drives auto-invocation matching. Write it as a trigger sentence.
- `argument-hint` — add if the skill takes user-supplied args
- `disable-model-invocation: true` — user-only invocation (suppress auto-load)
- `user-invocable: false` — Claude-only (hide from `/` menu)
- `allowed-tools` — minimum set of tools the skill needs; scope Bash commands tightly e.g. `Bash(mkdir -p *)`
- `context: fork` + `agent: Explore` — if the skill should run in an isolated subagent without conversation history

## Step 3 — Write the Skill Instructions

Instructions are a prompt that Claude will follow when the skill runs. They should be:
- Directive and unambiguous — numbered steps, not prose
- Parameterized with `$ARGUMENTS`, `$0`, `$1` etc. where the skill takes input
- Using `!`command`` for dynamic shell context injection where useful (e.g. `!`cat ${CLAUDE_SKILL_DIR}/SKILL.md``)
- Scoped to a single clear responsibility

## Step 4 — Create and Write the File

1. Run: `mkdir -p <scope>/<skill-name>`
2. Write the complete SKILL.md
3. Display the full generated content to the user for review before finalizing

## Step 5 — Verify

Suggest to the user:
- Test with `/<skill-name>` for manual invocation
- Or describe a scenario where auto-invocation should trigger, and confirm Claude loads it
