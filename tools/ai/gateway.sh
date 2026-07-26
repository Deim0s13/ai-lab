#!/usr/bin/env bash
set -euo pipefail

gateway_ready() {
  curl -fsS "${GATEWAY_URL}/v1/models" \
    -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" >/dev/null 2>&1
}

ask_model() {
  local model="$1"
  local prompt="$2"
  local payload=""

  check_python_runtime

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
    -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    | jq -r '.choices[0].message.content'
}
