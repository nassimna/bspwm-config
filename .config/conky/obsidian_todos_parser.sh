#!/usr/bin/env bash
set -euo pipefail

TODO_FILE="${TODO_FILE:-$HOME/drive/obsidian-vault/00 Dashboard/Todos.md}"
WRAP_WIDTH="${WRAP_WIDTH:-58}"

if [ ! -f "$TODO_FILE" ]; then
  printf 'Obsidian todo file not found:\n%s\n' "$TODO_FILE"
  exit 0
fi

strip_markdown() {
  local input="$1"
  # Convert common markdown patterns into readable plain text.
  printf '%s' "$input" | sed -E \
    -e 's/\[\[([^]|]+)\|([^]]+)\]\]/\2/g' \
    -e 's/\[\[([^]]+)\]\]/\1/g' \
    -e 's/\[([^]]+)\]\(([^)]+)\)/\1/g' \
    -e 's/`([^`]*)`/\1/g' \
    -e 's/\*\*([^*]+)\*\*/\1/g' \
    -e 's/__([^_]+)__/\1/g' \
    -e 's/\*([^*]+)\*/\1/g' \
    -e 's/_([^_]+)_/\1/g'
}

declare -a TASKS=()
in_todo_section=0

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    "## Todo List"*)
      in_todo_section=1
      continue
      ;;
    "## "*)
      if [ "$in_todo_section" -eq 1 ]; then
        break
      fi
      ;;
  esac

  if [ "$in_todo_section" -eq 0 ]; then
    continue
  fi

  line_trimmed="${line#"${line%%[![:space:]]*}"}"

  # Ignore code fences and blank lines in todo section.
  if [[ "$line_trimmed" == '```'* ]] || [[ "$line_trimmed" =~ ^[[:space:]]*$ ]]; then
    continue
  fi

  item=""
  if [ "${line_trimmed:0:6}" = "- [ ] " ]; then
    item="${line_trimmed:6}"
  elif [ "${line_trimmed:0:6}" = "- [x] " ] || [ "${line_trimmed:0:6}" = "- [X] " ]; then
    # Skip completed checkbox tasks.
    continue
  elif [ "${line_trimmed:0:2}" = "- " ]; then
    # Support plain bullet text items too.
    item="${line_trimmed:2}"
  else
    # Support free-form text lines in Todo List section.
    item="$line_trimmed"
  fi

  # Trim leading whitespace and simplify markdown formatting.
  item="${item#"${item%%[![:space:]]*}"}"
  item="$(strip_markdown "$item")"

  if [ -n "$item" ]; then
    TASKS+=("$item")
  fi
done < "$TODO_FILE"

COUNT=${#TASKS[@]}
printf 'Open Todos: %d\n\n' "$COUNT"

if [ "$COUNT" -eq 0 ]; then
  printf 'No open todos.\n'
  exit 0
fi

for task in "${TASKS[@]}"; do
  # Escape characters that Conky can interpret.
  safe_task=${task//\\/\\\\}
  safe_task=${safe_task//\$/\\$}
  first_line=1
  while IFS= read -r line; do
    if [ "$first_line" -eq 1 ]; then
      printf -- '- %s\n' "$line"
      first_line=0
    else
      printf '  %s\n' "$line"
    fi
  done < <(printf '%s\n' "$safe_task" | fold -s -w "$WRAP_WIDTH")
done
