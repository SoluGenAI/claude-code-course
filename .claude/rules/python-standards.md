---
paths:
  - "**/*.py"
  - "**/*.pyi"
---

# Python Code Standards

## Imports

- Standard library first, then third-party, then local — separated by blank lines.
- Use absolute imports. Relative imports only within the same package.
- Never use wildcard imports (`from module import *`).

## Type Hints

- All function signatures must include type hints for parameters and return values.
- Use `collections.abc` types (`Sequence`, `Mapping`) over `typing` equivalents.
- Use `X | None` syntax (PEP 604), not `Optional[X]`.

## Docstrings

- Public functions and classes require a one-line docstring at minimum.
- Use Google-style docstrings when args/returns documentation is needed.

## Naming

- `snake_case` for functions, variables, and modules.
- `PascalCase` for classes.
- `UPPER_SNAKE_CASE` for constants.
- Prefix private helpers with a single underscore.
