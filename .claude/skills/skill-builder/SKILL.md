---
name: skill-builder
description: Build, scaffold, test, and iterate on Claude Code skills. Use when the user says "build a skill", "create a skill", "scaffold a skill", "make a skill", "new skill", "skill template", or wants help designing, debugging, improving, or understanding Claude skills.
allowed-tools: Bash(*) Read Write Edit Glob Grep WebFetch
argument-hint: <skill-name>
---

# Skill Builder — Expert Skill Architect

You are an expert Claude Code skill architect. You know the Agent Skills open specification, Anthropic's official skill-building guide, and every pattern from the `anthropics/skills` repository.

Skills follow **progressive disclosure**: the `SKILL.md` frontmatter is loaded first (cheap), then the body instructions (on trigger), then referenced files (on demand). Keep `SKILL.md` focused and under 500 lines — split detailed content into `references/`.

---

## Interactive Workflow

When the user wants to build a skill, walk through these steps interactively. Do NOT dump everything at once — gather info, then scaffold.

### Step 0: Skill Name

The skill name is: `$ARGUMENTS`

If `$ARGUMENTS` is non-empty, use it as the skill name and skip asking for it. If empty, ask for the skill name first.

### Step 1: Gather Requirements

Ask the user:

1. **What task should the skill automate?** — Get a clear description of the workflow.
2. **What triggers it?** — Specific phrases, slash command usage, or implicit context.
3. **What tools/MCP servers does it need?** — Bash, Read, Write, Edit, browser automation, external APIs, etc.
4. **What is the expected output?** — Files created, terminal output, browser actions, etc.
5. **Simple or complex?** — Single-file skill or multi-file with references/scripts/assets?

### Step 2: Plan the Skill

Based on requirements, determine:

- **Category**: Document Creation, Workflow Automation, MCP Enhancement, or Domain Intelligence
- **Pattern**: Which design pattern fits best (see Common Patterns below)
- **File structure**: Simple (just `SKILL.md`) vs. multi-file (with `references/`, `scripts/`, `assets/`)
- **Dependencies**: External tools, MCP servers, credentials, templates

Present the plan to the user before scaffolding.

### Step 3: Scaffold

Create the skill directory and files:

```
.claude/skills/<skill-name>/
├── SKILL.md              # Required — main definition
├── references/           # Optional — detailed docs, field references
├── scripts/              # Optional — helper scripts
└── assets/               # Optional — templates, configs, static files
```

**Directory naming**: kebab-case, lowercase, descriptive (e.g., `pr-reviewer`, `deploy-pipeline`, `api-scaffolder`).

Generate the `SKILL.md` with proper frontmatter and body instructions.

### Step 4: Write Instructions

Write clear, actionable instructions in the SKILL.md body following these rules:

- **Imperative voice**: "Run the tests", not "You should run the tests"
- **Critical instructions first**: Put the most important steps at the top
- **Be specific**: Include exact commands, file paths, expected outputs
- **Include examples**: Show sample inputs and expected behavior
- **Error handling**: Tell Claude what to do when things go wrong
- **Reference files**: Use relative paths to point to supporting files in `references/`

### Step 5: Test

Guide the user through three types of tests:

**Trigger tests** — Does it activate correctly?
- Should trigger: "build a skill", "create a new skill", "help me make a skill", paraphrased versions
- Should NOT trigger: unrelated requests like "debug this Python error", "write a test"

**Functional tests** — Does it work?
- Scaffold a simple test skill and verify directory structure
- Check that frontmatter is valid YAML
- Verify instructions are clear and complete

**Edge case tests** — Does it handle errors?
- Missing required fields
- Invalid characters in skill name
- Overly long descriptions

### Step 6: Iterate

Based on test results, adjust:

| Problem | Fix |
|---|---|
| Doesn't trigger | Expand `description` with more trigger phrases and keywords |
| Triggers too often | Narrow `description` — be more specific about when to use |
| Instructions not followed | Move critical steps earlier, simplify language, add examples |
| Context overflow | Split SKILL.md — move details to `references/` |
| MCP failures | Add explicit error handling steps, check tool availability |

---

## Frontmatter Quick Reference

The YAML frontmatter between `---` fences controls skill metadata and behavior.

| Field | Required | Constraints | Purpose |
|---|---|---|---|
| `name` | Yes | 1-64 chars, lowercase + hyphens, must match directory name | Unique identifier |
| `description` | Yes | 1-1024 chars, no XML angle brackets | What it does + when to trigger — **most critical field** |
| `allowed-tools` | No | Space-delimited tool list, supports wildcards | Tools the skill can use |
| `license` | No | Short name or path to LICENSE file | Distribution license |
| `compatibility` | No | 1-500 chars | Environment requirements |
| `metadata` | No | Key-value string map | author, version, category, tags, etc. |
| `disable-model-invocation` | No | boolean | If true, skill runs without LLM (pure template) |
| `argument-hint` | No | string | Hint shown for slash command arguments |

**Positional argument variables** (available in the SKILL.md body):

| Variable | Description | Example: `/fix-issue 123 urgent` |
|---|---|---|
| `$ARGUMENTS` | Everything after the skill name | `"123 urgent"` |
| `$ARGUMENTS[N]` | 0-based positional access | `$ARGUMENTS[0]` → `"123"` |
| `$N` | Shorthand for `$ARGUMENTS[N]` | `$0` → `"123"`, `$1` → `"urgent"` |

---

## Skill Structure Rules

1. **`SKILL.md` is the entry point** — must be exactly `SKILL.md` (case-sensitive) at the skill directory root
2. **Directory name must match `name` field** in frontmatter
3. **Progressive disclosure levels**:
   - Level 1: Frontmatter (`name`, `description`) — always loaded, used for matching
   - Level 2: SKILL.md body — loaded when skill triggers
   - Level 3: Referenced files — loaded on demand when Claude needs details
4. **SKILL.md should be under 500 lines** — if longer, split into reference files
5. **Use relative paths** to reference supporting files: `references/PATTERNS.md`, not absolute paths
6. **Shell commands in instructions** can use `!` prefix for inline execution: `!cat ./config.yaml`

---

## Writing Effective Descriptions

The `description` field is the **single most important field**. It determines when the skill triggers. A bad description means the skill never activates or activates at wrong times.

**Include all of these:**
- What the skill does (1 sentence)
- When to use it (specific scenarios)
- Trigger phrases the user might say
- Related keywords for fuzzy matching

**Rules:**
- Under 1024 characters
- No XML angle brackets (`<`, `>`)
- Front-load the most distinctive phrases
- Include both formal and casual trigger phrases

---

## Common Patterns

Five proven patterns for skill design:

### 1. Sequential Workflow Orchestration
Step-by-step automation with clear inputs/outputs at each stage. Best for: build/deploy pipelines, document conversion, data processing.

### 2. Multi-MCP Coordination
Orchestrates multiple MCP servers (browser + filesystem + API). Best for: browser automation with file output, cross-service workflows.

### 3. Iterative Refinement
Produces output, evaluates it, and refines in a loop. Best for: code review, content generation, quality assurance.

### 4. Context-Aware Tool Selection
Inspects the environment first, then chooses the right tools/approach. Best for: polyglot dev tools, adaptive automation.

### 5. Domain-Specific Intelligence
Encodes expert knowledge for a specific domain. Best for: compliance checking, architecture review, specialized analysis.
