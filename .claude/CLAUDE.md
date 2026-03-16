## Project Context

This project is part of a Claude Code Course for software developers who specialize in AI engineering.

---

## Communication

**Terminology correction is mandatory.** When I ask a question or describe something using incorrect, imprecise, or non-standard terminology — correct me explicitly before answering. Do NOT silently "understand my intention" and move on. State the correct term, briefly explain why, then proceed with the answer using the correct terminology. This applies to engineering concepts, agentic coding terms, design patterns, communication between components, data structures, and any technical term that an engineering expert would notice as off.

---

## Core Principles

- **Fail-fast error handling.** Break and stop on unexpected behavior with descriptive error logs. No fallbacks.
- **Simpler is better.**
- **SOLID design — Single Responsibility first.** Every class, module, and function should have one clear reason to change. Apply the full SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion), with SRP as the guiding default. Use healthy judgement — oversplitting into too many tiny units is just as harmful as God classes. Three related lines in one place beat a premature abstraction across three files.
- Use `uv` for Python virtual env management, not `pip`.
- Don't include time estimations for task planning.
- **When planning a feature or a bug fix, follow the TDD (Test Driven Development) approach: Make sure you define clear methods and marks that would allow you to measure success. If more clarity from the developer is needed - you are encouraged to ask clarification questions. 

## Documentation Guidelines

### Changelog

On significant code or spec changes, update both the project's `CLAUDE.md` and `knowledge/changelog/CHANGELOG_{YY-MM-DD}.md` - the date being today's date. Each entry: what, why, when. Maintain a clickable TOC. When the file becomes longer than 200 lines, archive it, and start a fresh one, with the current date as the filename's suffix.

### Documentation Files

- **Never create README or doc files in the project root.** All internal docs go in `knowledge/`.
- Use logical subdirectories (`knowledge/setup/`, `knowledge/plans/`, etc).
- Naming convention of doc files: `UPPERCASE_NAME.md`. 
- **Each md file must start with a clickable TOC**; first section should always be a concise summary of the doc's actionable content.

## Python Project Standards

### Project Structure

All Python projects use the **src layout**. Initialize with `uv init --package <project-name>`.

```
project-name/
├── .env / .env.example / .gitignore / .dockerignore / .cursorignore
├── pyproject.toml          # NO requirements.txt
├── uv.lock
├── src/
│   ├── __init__.py
│   ├── constants.py        # App-wide constants
│   ├── config.py           # Pydantic Settings (YAML + env)
│   ├── main.py
│   ├── custom_types/       # All schemas and type definitions
│   │   ├── api_schemas.py / db_models.py / llm_schemas.py / domain_types.py
│   └── services/
├── data/                   # raw/, processed/, etc.
├── frontend/               # React/Next.js (if applicable)
├── tests/
│   ├── unit/
│   └── integration/
├── knowledge/
│   ├── plans/
│   ├── setup/
│   └── changelogs/
└── .claude/CLAUDE.md
```

**Root must be clean:** no loose Python files, no stray files, keep the filesystem logically organized according to the strucutre the developer defined. If such a definition is lacking, ask the developer to clarify the filesystem's intended strucutre.

### File Management

- snake_case, specific domain names (not generic). Prefer `<domain>_<type>.py` pattern.
- Split large files (files with more than 500 lines) by domain, not into generic overflow files. Unless there is an architectually justified reason not to.

### Constants and Configs

Constants are truly-immutable values only. They belong in a `constants.py` file. 
Configurable values belong in `config.py`.

### String Literals and Hardcoded Numbers

**Hard-coded values are NOT welcome.** Every behavior-affecting string or number MUST be defined as a constant or enum member and imported — never inline.

Includes: API endpoints, DB table/column names, cache keys, queue names, status values, file paths, service identifiers, header names, error codes, and any other string in conditional logic.

Exceptions: user-facing display text, debug log messages, test fixtures.

**Enum `__str__` rule:** 
String enums MUST use `StrEnum` (Python 3.11+) or define `def __str__(self) -> str: return self.value`. Code should not reference `.value` on enum members.

- `StrEnum` for closed sets of related string values (statuses, roles, categories)
- Plain `UPPER_SNAKE_CASE` constants for one-off strings

### Error Handling (Python)

Every function MUST have try-except with descriptive errors:
- Include context in messages (IDs, key params, function name)
- Use specific exception types, never bare `except:`
- Re-raise after logging — fail fast, never swallow errors
- Log levels: `error` for failures, `warning` for recoverable, `info` for operations
- Log errors as json using the python "extra" field

### Frontend Logging (React/Next.js)

All frontend code MUST include structured logging:
- Create a `logger` utility with debug/info/warn/error levels
- Log component mount/unmount, all API calls (start/success/failure), user interactions
- Include IDs and key state as structured context objects
- Wrap all async operations in try-catch with error logging

## Planning Guidelines

- Save all plans to `knowledge/plans/{PLAN_NAME}.md`. **NEVER save to `.claude/plans/`.**
- Once a plan has been fully implemented, ask the developer if it is now safe to transform the content from `plans` to the relevant changlog file.

## Git Workflow

**NEVER run `git commit`, `git add`, or `git push`** — in any context (main assistant, agents, subagents, skills, commands). Only the user, manually, is allowed to run git operations.