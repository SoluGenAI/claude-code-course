#!/bin/bash
# PostToolUse hook: auto-format Python files with ruff after edits.
# Reads tool_input.file_path from stdin JSON.
# Exits silently for non-Python files. Best-effort: won't block Claude on format errors.

# Read stdin (hook payload)
input=$(cat)

# Extract file_path from JSON
file_path=""
if command -v jq &>/dev/null; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
  file_path=$(echo "$input" | grep -oP '"file_path"\s*:\s*"\K[^"]+' 2>/dev/null)
fi

# Guard: skip if not a .py file
[[ "$file_path" != *.py ]] && exit 0

# Guard: skip if file doesn't exist
[[ ! -f "$file_path" ]] && exit 0

# Find ruff
ruff_cmd=""
if command -v ruff &>/dev/null; then
  ruff_cmd="ruff"
elif command -v uvx &>/dev/null; then
  ruff_cmd="uvx ruff"
else
  echo "ruff not found in PATH and uvx not available" >&2
  exit 2
fi

# Run ruff format + check (best-effort, don't block Claude)
$ruff_cmd format "$file_path" || true
$ruff_cmd check --fix "$file_path" || true

exit 0
