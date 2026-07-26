#!/usr/bin/env bash
set -euo pipefail

read_prompt() {
  local prompt_args="$*"
  local stdin_content=""

  if [[ ! -t 0 ]]; then
    stdin_content="$(cat)"
  fi

  if [[ -n "$prompt_args" && -n "$stdin_content" ]]; then
    printf "%s\n\n%s" "$prompt_args" "$stdin_content"
  elif [[ -n "$prompt_args" ]]; then
    printf "%s" "$prompt_args"
  elif [[ -n "$stdin_content" ]]; then
    printf "%s" "$stdin_content"
  else
    return 1
  fi
}

missing_prompt() {
  local command="$1"

  echo "No prompt provided." >&2
  echo "Usage: ai ${command} prompt" >&2
  echo "Examples:" >&2

  case "$command" in
    ask)
      echo "  ai ask --mode code Review this command" >&2
      echo "  echo 'Review this command' | ai ask --mode code" >&2
      ;;
    fast)
      echo "  ai fast Summarise this in three bullets" >&2
      echo "  echo 'Summarise this' | ai fast" >&2
      ;;
    capable)
      echo "  ai capable Compare these two options" >&2
      echo "  echo 'Compare these options' | ai capable" >&2
      ;;
    code)
      echo "  ai code Review this shell command" >&2
      echo "  echo 'Review this command' | ai code" >&2
      ;;
  esac

  exit 2
}
