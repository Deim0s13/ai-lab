#!/usr/bin/env bash
set -euo pipefail

ensure_cli_gateway_key() {
  if ! secret_is_placeholder "${LITELLM_CLI_KEY:-}"; then
    return 0
  fi

  if ! LITELLM_CLI_KEY="$(
    resolve_profile_secret \
      "${profile}" \
      LITELLM_CLI_KEY \
      "${secret_fallback_file}"
  )"; then
    return 8
  fi

  export LITELLM_CLI_KEY
}

gateway_ready() {
  ensure_cli_gateway_key >/dev/null 2>&1 || return 1

  curl --max-time 3 -fsS "${GATEWAY_URL}/v1/models" \
    -H "Authorization: Bearer ${LITELLM_CLI_KEY}" \
    >/dev/null 2>&1
}

ask_model() {
  local model="$1"
  local prompt="$2"
  local payload=""

  check_python_runtime
  ensure_cli_gateway_key

  payload="$(
    .venv/bin/python -c '
import json
import sys

print(json.dumps({
    "model": sys.argv[1],
    "messages": [
        {
            "role": "user",
            "content": sys.argv[2],
        }
    ],
}))
' "$model" "$prompt"
  )"

  curl -fsS "${GATEWAY_URL}/v1/chat/completions" \
    -H "Authorization: Bearer ${LITELLM_CLI_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    | jq -r '.choices[0].message.content'
}
