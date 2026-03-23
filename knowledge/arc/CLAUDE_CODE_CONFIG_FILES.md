# Claude Code Configuration Files

## Table of Contents

- [Summary](#summary)
- [1. ~/.claude.json — Global State](#1-claudejson--global-state)
- [2. ~/.claude/settings.json — User Settings](#2-claudesettingsjson--user-settings)
- [3. .claude/settings.json — Project Settings](#3-claudesettingsjson--project-settings)
- [4. .claude/settings.local.json — Local Settings](#4-claudesettingslocaljson--local-settings)
- [5. ~/.claude/CLAUDE.md — Personal Instructions](#5-claudeclaudemd--personal-instructions)
- [6. CLAUDE.md / .claude/CLAUDE.md — Project Instructions](#6-claudemd--claudeclaudemd--project-instructions)
- [7. .claude/rules/ and ~/.claude/rules/ — Rules Directories](#7-clauderules-and-clauderules--rules-directories)
- [8. .mcp.json — Project MCP Servers](#8-mcpjson--project-mcp-servers)
- [9. Managed Policy Files — Organization-Wide Enforcement](#9-managed-policy-files--organization-wide-enforcement)
- [10. .claude/agents/ and ~/.claude/agents/ — Subagent Definitions](#10-claudeagents-and-claudeagents--subagent-definitions)
- [11. .claude/skills/ and ~/.claude/skills/ — Skills](#11-claudeskills-and-claudeskills--skills)
- [12. ~/.claude/keybindings.json — Custom Keyboard Shortcuts](#12-claudekeybindingsjson--custom-keyboard-shortcuts)
- [13. ~/.claude/projects/ — Per-Project State and Auto Memory](#13-claudeprojects--per-project-state-and-auto-memory)
- [14. ~/.claude/.credentials.json — Credential Storage](#14-claudecredentialsjson--credential-storage)
- [15. ~/.claude/plugins/ — Installed Plugins](#15-claudeplugins--installed-plugins)
- [Scope Priority](#scope-priority)
- [Complete File Map](#complete-file-map)
- [References](#references)

---

## Summary

Claude Code uses a layered configuration system spanning four scopes: **Managed** (org-enforced), **User** (personal, all projects), **Project** (team-shared, version-controlled), and **Local** (personal per-project, git-ignored). Configuration is split between **settings files** (JSON, controlling behavior), **CLAUDE.md files** (markdown, providing instructions), **MCP configuration** (tool integrations), and a **global state file** (authentication and preferences). Beyond configuration, Claude Code also manages **agents**, **skills**, **auto memory**, **keybindings**, **credentials**, **session transcripts**, and **plugins** — all documented in this file.

---

## 1. `~/.claude.json` — Global State

**Scope:** User (private, all projects on this machine)

This is **not** a settings file — it's a state file. It stores authentication, preferences, and MCP server registrations. Do not confuse it with `~/.claude/settings.json`.

**What it contains:**

| Contents | Notes |
|----------|-------|
| OAuth session and authentication state | On macOS, credentials are stored in the encrypted Keychain instead |
| Theme preference | Also configurable via `/config` |
| Auto-update channel | `"stable"` or `"latest"` |
| MCP server definitions (user and local scopes) | User-scoped servers are available across all projects; local-scoped servers are keyed by project path |
| Per-project state | Allowed tools, trust settings |
| Various caches | Internal use |

**Key distinction:** Settings like `permissions`, `env`, and `hooks` belong in `settings.json` files — not here. Adding settings keys to `~/.claude.json` will trigger a schema validation error.

**Some preferences are stored here, not in settings.json:**

| Key | Purpose |
|-----|---------|
| `editorMode` | Key binding mode (`"normal"` or `"vim"`) |
| `autoConnectIde` | Auto-connect to a running IDE from external terminal |
| `showTurnDuration` | Show turn duration messages after responses |
| `terminalProgressBarEnabled` | Show terminal progress bar in supported terminals |

**Add a user-scoped MCP server (stored here):**

```bash
claude mcp add --scope user <server-name> <url>
```

---

## 2. `~/.claude/settings.json` — User Settings

**Scope:** User (private, all projects on this machine)

Controls permissions, environment variables, hooks, and other behavioral settings that apply globally across all your projects.

**Key fields:**

| Field | Purpose |
|-------|---------|
| `permissions.allow` | Tool permission rules to auto-approve (e.g., `"Bash(npm test)"`) |
| `permissions.ask` | Tool permission rules requiring confirmation |
| `permissions.deny` | Tool permission rules to always deny |
| `env` | Environment variables injected into Claude Code sessions |
| `hooks` | Lifecycle hooks (shell commands triggered by events) |
| `model` | Override the default model |
| `effortLevel` | `"low"`, `"medium"`, or `"high"` |
| `outputStyle` | Adjust response style |
| `sandbox` | Sandboxing configuration for bash commands |

**Example:**

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run test *)",
      "Bash(uv run pytest*)",
      "Read"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(./.env)"
    ]
  },
  "env": {
    "UV_PYTHON": "3.12"
  }
}
```

> **Tip:** The `$schema` line enables autocomplete and inline validation in VS Code, Cursor, and other editors that support JSON schema.

---

## 3. `.claude/settings.json` — Project Settings

**Scope:** Project (shared with team, committed to git)

Same format as user settings, but lives in the repository's `.claude/` directory. Defines team-shared permissions, hooks, environment variables, and other settings.

**Git-tracked:** Yes — this file is checked into source control.

**Use for:** Team-wide permission rules, shared hooks, project-specific environment variables, and standardized tooling configuration.

---

## 4. `.claude/settings.local.json` — Local Settings

**Scope:** Local (personal, this repository only)

Same format as the other settings files. Provides personal overrides for a specific project without affecting teammates.

**Git-tracked:** No — Claude Code automatically configures git to ignore this file when it's created.

**Use for:** Personal project overrides, testing configurations before sharing with the team, machine-specific settings.

---

## 5. `~/.claude/CLAUDE.md` — Personal Instructions

**Scope:** User (private, all projects on this machine)

A markdown file containing free-form instructions that Claude reads at the start of every session. Use it for personal coding standards, preferred tools, communication style, and project-agnostic conventions.

**Common contents:**

- Preferred language/framework conventions
- Error handling style
- Git workflow rules
- Communication preferences
- Company-specific context

> **Priority:** User-level `CLAUDE.md` has lower priority than project-level `CLAUDE.md`, `.claude/rules/` files, and managed policy `CLAUDE.md`.

---

## 6. `CLAUDE.md` / `.claude/CLAUDE.md` — Project Instructions

**Scope:** Project (shared with team, committed to git)

A project CLAUDE.md can be stored in **either** location — they are equivalent:

- `./CLAUDE.md` (project root — recommended for visibility)
- `./.claude/CLAUDE.md` (inside the `.claude/` directory)

**Loading behavior:** Claude walks up the directory tree from the current working directory, loading all CLAUDE.md files found along the way. CLAUDE.md files in subdirectories below the working directory load on demand when Claude reads files in those subdirectories.

**Imports:** CLAUDE.md files can import other files using `@path/to/file` syntax. Relative paths resolve relative to the importing file. Maximum depth: 5 hops.

```text
See @README.md for project overview and @package.json for available npm commands.
```

**Excluding files:** In monorepos, use the `claudeMdExcludes` setting to skip irrelevant CLAUDE.md files:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

> **Note:** Run `/init` to auto-generate a starting CLAUDE.md based on your codebase. If one already exists, `/init` suggests improvements.

---

## 7. `.claude/rules/` and `~/.claude/rules/` — Rules Directories

Rules let you organize instructions into modular files instead of one large CLAUDE.md.

### Project Rules (`.claude/rules/`)

**Scope:** Project (shared with team, committed to git)

```
.claude/
├── CLAUDE.md
└── rules/
    ├── code-style.md
    ├── testing.md
    ├── security.md
    └── api/
        └── endpoints.md
```

- Rules **without** `paths` frontmatter load unconditionally at session start (same priority as `.claude/CLAUDE.md`)
- Rules **with** `paths` frontmatter load on demand only when Claude reads matching files

**Path-specific rule example:**

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
---

# API Development Rules

- All endpoints must include input validation
- Use the standard error response format
```

**Symlinks are supported** — you can link shared rules across projects:

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
```

### User Rules (`~/.claude/rules/`)

**Scope:** User (private, all projects on this machine)

Same format as project rules, but personal and applied everywhere. User-level rules load **before** project rules, giving project rules higher priority.

---

## 8. `.mcp.json` — Project MCP Servers

**Scope:** Project (shared with team, committed to git)

Lives in the project root. Defines MCP servers that anyone cloning the repo will have available.

**Example:**

```json
{
  "mcpServers": {
    "my-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    },
    "remote-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp"
    }
  }
}
```

**Add a project-scoped MCP server:**

```bash
claude mcp add --scope project <server-name> <url>
```

**MCP scope options:**

| Scope | Storage | Shared? |
|-------|---------|---------|
| `local` (default) | `~/.claude.json` (keyed by project path) | No — you only, this project |
| `project` | `.mcp.json` in project root | Yes — committed to git |
| `user` | `~/.claude.json` | No — you, all projects |

> **Security:** Claude Code prompts for approval before using project-scoped servers from `.mcp.json`. Use `claude mcp reset-project-choices` to reset these approvals.

---

## 9. Managed Policy Files — Organization-Wide Enforcement

For organizations deploying Claude Code across teams. These files **cannot be overridden** by user or project settings.

### Managed CLAUDE.md

| OS | Path |
|----|------|
| Linux / WSL | `/etc/claude-code/CLAUDE.md` |
| macOS | `/Library/Application Support/ClaudeCode/CLAUDE.md` |
| Windows | `C:\Program Files\ClaudeCode\CLAUDE.md` |

Cannot be excluded by individual `claudeMdExcludes` settings. Has the **highest priority** of all CLAUDE.md files.

### Managed Settings (`managed-settings.json`)

| OS | Path |
|----|------|
| Linux / WSL | `/etc/claude-code/managed-settings.json` |
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

Same JSON format as regular settings files, but supports additional managed-only keys:

| Key | Purpose |
|-----|---------|
| `disableBypassPermissionsMode` | Prevent `bypassPermissions` mode |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed hooks run |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `strictKnownMarketplaces` | Restrict which plugin marketplaces users can add |
| `blockedMarketplaces` | Blocklist of marketplace sources |

**Additional delivery mechanisms:**

- **Server-managed settings:** Delivered from Anthropic's servers via the Claude.ai admin console (requires Claude for Teams or Enterprise)
- **macOS MDM:** `com.anthropic.claudecode` managed preferences domain (Jamf, Kandji, etc.)
- **Windows Group Policy:** `HKLM\SOFTWARE\Policies\ClaudeCode` registry key

### Managed MCP (`managed-mcp.json`)

Same system-level paths as `managed-settings.json`. Controls which MCP servers users can access organization-wide.

**Deployment:** Typically via configuration management (Ansible, Chef, Puppet, MDM) or the admin console for server-managed settings.

---

## 10. `.claude/agents/` and `~/.claude/agents/` — Subagent Definitions

Subagents are reusable agent configurations defined as markdown files with YAML frontmatter. They specify a system prompt, allowed tools, and optional model override.

### Project Agents (`.claude/agents/`)

**Scope:** Project (shared with team, committed to git)

```
.claude/
└── agents/
    ├── code-reviewer.md
    ├── test-writer.md
    └── security-auditor.md
```

**Example agent file (`.claude/agents/code-reviewer.md`):**

```markdown
---
model: sonnet
allowedTools:
  - Read
  - Grep
  - Glob
---

You are a code reviewer. Review the provided code for bugs,
performance issues, and style violations. Do not make edits.
```

Invoke with: `claude --agent code-reviewer` or via the Agent tool with `subagent_type`.

### User Agents (`~/.claude/agents/`)

**Scope:** User (private, all projects on this machine)

Same format as project agents, but available across all your projects.

### Agent Memory

Subagents can maintain persistent memory (when configured with `memory: user` or `memory: project`):

| Scope | Location |
|-------|----------|
| User | `~/.claude/agent-memory/<agent-name>/MEMORY.md` |
| Project | `.claude/agent-memory/<agent-name>/MEMORY.md` |

---

## 11. `.claude/skills/` and `~/.claude/skills/` — Skills

Skills are packaged workflows that load on demand (via slash commands or when Claude determines they're relevant). They replaced the older `.claude/commands/` directory.

### Project Skills (`.claude/skills/`)

**Scope:** Project (shared with team, committed to git)

```
.claude/
└── skills/
    ├── deploy/
    │   └── SKILL.md
    └── review-pr/
        └── SKILL.md
```

Each skill is a directory containing a `SKILL.md` file. The skill name comes from the directory name.

### User Skills (`~/.claude/skills/`)

**Scope:** User (private, all projects on this machine)

Same structure, but available across all your projects.

> **Legacy:** `.claude/commands/` still works for backward compatibility but is superseded by `.claude/skills/`.

---

## 12. `~/.claude/keybindings.json` — Custom Keyboard Shortcuts

**Scope:** User (private, all projects on this machine)

Defines custom keyboard shortcuts and chord bindings for Claude Code's interactive REPL. Changes are picked up automatically without restart.

**Example:**

```json
{
  "bindings": [
    {
      "key": "ctrl+s",
      "action": "submit"
    },
    {
      "key": "ctrl+k ctrl+c",
      "action": "copy_last_response"
    }
  ]
}
```

---

## 13. `~/.claude/projects/` — Per-Project State and Auto Memory

**Scope:** User (private, machine-local)

Claude Code maintains a per-project directory under `~/.claude/projects/` keyed by the git repository (or project root if not in a git repo). All worktrees and subdirectories within the same git repository share one project directory.

### Auto Memory (`~/.claude/projects/<project>/memory/`)

When auto memory is enabled (on by default), Claude saves learnings here across sessions.

```
~/.claude/projects/<project>/memory/
├── MEMORY.md              # Index — first 200 lines loaded every session
├── debugging.md           # Detailed notes (loaded on demand)
├── api-conventions.md     # Architecture decisions
└── ...
```

- `MEMORY.md` is the entrypoint; Claude keeps it concise and moves details to topic files
- Topic files are **not** loaded at startup — Claude reads them on demand
- These are plain markdown files you can edit or delete at any time
- Browse with the `/memory` command

**Custom memory location:** Set `autoMemoryDirectory` in user or local settings to redirect memory storage.

### Session Transcripts (`~/.claude/projects/<project>/<sessionId>/`)

Full JSONL conversation transcripts are stored per session. These enable `/resume` to pick up where you left off.

- Cleaned up automatically based on `cleanupPeriodDays` setting (default: 30 days)
- Subagent transcripts stored in `subagents/` subdirectory within each session

---

## 14. `~/.claude/.credentials.json` — Credential Storage

**Scope:** User (private, machine-local)

| Platform | Storage |
|----------|---------|
| **macOS** | macOS Keychain (encrypted by OS) — **not** stored as a file |
| **Linux** | `~/.claude/.credentials.json` with file mode `0600` (owner read/write only) |
| **Windows** | `~/.claude/.credentials.json` with user profile access controls |

Contains OAuth tokens, API keys, and cloud provider authentication tokens. If corrupted or deleted, re-authenticate with `/login`.

> This file is never committed to git. Treat it as sensitive.

---

## 15. `~/.claude/plugins/` — Installed Plugins

**Scope:** User (private, machine-local)

| Path | Purpose |
|------|---------|
| `~/.claude/plugins/cache/{plugin-id}/` | Installed plugin files (copied from marketplace for security) |
| `~/.claude/plugins/data/{plugin-id}/` | Persistent plugin data (`${CLAUDE_PLUGIN_DATA}` env var) — survives plugin updates |

Plugins can bundle MCP servers, skills, agents, and rules. They're installed from marketplaces and managed via settings. You don't typically edit these directories directly.

---

## Scope Priority

### Settings Precedence (highest to lowest)

```
1. Managed settings          (cannot be overridden)
2. CLI flags                 (temporary session overrides)
3. .claude/settings.local.json  (personal project overrides, git-ignored)
4. .claude/settings.json        (team-shared project settings)
5. ~/.claude/settings.json      (personal defaults)
```

### CLAUDE.md Precedence (highest to lowest)

```
1. Managed CLAUDE.md              (org-enforced, cannot be excluded)
2. Project CLAUDE.md / rules      (./CLAUDE.md, .claude/CLAUDE.md, .claude/rules/)
3. User CLAUDE.md / rules         (~/.claude/CLAUDE.md, ~/.claude/rules/)
```

User-level rules load before project rules, giving project rules higher priority. Within permission rules, evaluation order is **deny → ask → allow**, and a deny at any layer cannot be overridden by an allow at another.

### MCP Server Precedence (highest to lowest)

```
1. Local scope   (~/.claude.json, keyed by project path)
2. Project scope (.mcp.json)
3. User scope    (~/.claude.json, user-wide)
```

---

## Complete File Map

A quick-reference of every file and directory, organized by location.

### User Home (`~/.claude/`)

| Path | Type | Purpose | Editable? |
|------|------|---------|-----------|
| `~/.claude.json` | State | Global state, MCP servers, preferences | Rarely (use CLI/`/config`) |
| `~/.claude/.credentials.json` | Credentials | OAuth/API tokens (Linux/Windows only) | Never |
| `~/.claude/settings.json` | Config | User-wide settings | Yes |
| `~/.claude/CLAUDE.md` | Instructions | Personal instructions | Yes |
| `~/.claude/rules/*.md` | Instructions | User-level path-specific rules | Yes |
| `~/.claude/agents/*.md` | Agents | User-level subagent definitions | Yes |
| `~/.claude/skills/*/SKILL.md` | Skills | User-level skill definitions | Yes |
| `~/.claude/keybindings.json` | Config | Custom keyboard shortcuts | Yes |
| `~/.claude/projects/<project>/memory/` | Auto memory | Per-project learnings (MEMORY.md + topics) | Yes |
| `~/.claude/projects/<project>/<sessionId>/` | Transcripts | Session conversation logs (.jsonl) | Read-only |
| `~/.claude/agent-memory/<name>/` | Auto memory | Subagent persistent memory | Yes |
| `~/.claude/plugins/cache/` | Plugins | Installed plugin files | No (managed by CLI) |
| `~/.claude/plugins/data/` | Plugins | Persistent plugin data | No (managed by plugins) |

### Project Root (`.claude/` and root)

| Path | Type | Git-tracked? | Purpose |
|------|------|-------------|---------|
| `./CLAUDE.md` | Instructions | Yes | Project instructions (option A) |
| `.claude/CLAUDE.md` | Instructions | Yes | Project instructions (option B — equivalent) |
| `.claude/settings.json` | Config | Yes | Team-shared settings |
| `.claude/settings.local.json` | Config | No | Personal project overrides |
| `.claude/rules/*.md` | Instructions | Yes | Path-specific rules |
| `.claude/agents/*.md` | Agents | Yes | Project subagent definitions |
| `.claude/skills/*/SKILL.md` | Skills | Yes | Project skill definitions |
| `.claude/agent-memory/<name>/` | Auto memory | Yes | Subagent project-scope memory |
| `.mcp.json` | MCP | Yes | Project MCP server definitions |

### System-Level (Managed)

| Path | Type | Purpose |
|------|------|---------|
| `/etc/claude-code/CLAUDE.md` | Instructions | Org-enforced instructions (Linux/WSL) |
| `/Library/Application Support/ClaudeCode/CLAUDE.md` | Instructions | Org-enforced instructions (macOS) |
| `/etc/claude-code/managed-settings.json` | Config | Org-enforced settings (Linux/WSL) |
| `/Library/Application Support/ClaudeCode/managed-settings.json` | Config | Org-enforced settings (macOS) |
| `/etc/claude-code/managed-mcp.json` | MCP | Org-enforced MCP config (Linux/WSL) |
| `/Library/Application Support/ClaudeCode/managed-mcp.json` | MCP | Org-enforced MCP config (macOS) |

> Windows equivalents use `C:\Program Files\ClaudeCode\` for all managed files.

---

## References

All information in this document was verified against the official Claude Code documentation:

- **Settings:** [code.claude.com/docs/en/settings](https://code.claude.com/docs/en/settings) — configuration scopes, settings files, available fields, precedence
- **Memory & CLAUDE.md:** [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory) — CLAUDE.md locations, loading order, rules directories, auto memory
- **MCP Configuration:** [code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp) — .mcp.json format, scopes, managed MCP
- **Permissions:** [code.claude.com/docs/en/permissions](https://code.claude.com/docs/en/permissions) — permission rule syntax, managed-only settings
- **Hooks:** [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks) — hook configuration in settings files
- **Subagents:** [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents) — agent definitions, agent memory, subagent configuration
- **Skills:** [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills) — skill file format, user and project skills
- **Plugins:** [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins) — plugin installation, plugin-provided MCP servers

*Last verified: March 2026, against Claude Code documentation at code.claude.com/docs*
