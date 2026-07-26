#!/usr/bin/env bash
set -euo pipefail

error() {
  echo "$1" >&2
}

require_command() {
  local command="$1"

  if ! command -v "$command" >/dev/null 2>&1; then
    error "Required command not found: ${command}"
    error "Install ${command}, then retry."
    exit 8
  fi
}

check_dependencies() {
  require_command just
  require_command curl
  require_command jq
  require_command lsof
}

check_python_runtime() {
  if [[ ! -x ".venv/bin/python" ]]; then
    error "Python runtime not found: .venv/bin/python"
    error "Try: python -m venv .venv && .venv/bin/pip install -r requirements.txt"
    exit 8
  fi
}

mlx_ready() {
  lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null 2>&1 &&
    lsof -nP -iTCP:8081 -sTCP:LISTEN >/dev/null 2>&1 &&
    lsof -nP -iTCP:8082 -sTCP:LISTEN >/dev/null 2>&1
}

ensure_mlx_ready() {
  if mlx_ready; then
    return 0
  fi

  if just mlx-up >/dev/null 2>&1; then
    return 0
  fi

  error "MLX local model servers are not ready."
  error "Try: just mlx-up"
  error "Logs: just mlx-logs"
  exit 8
}

ensure_gateway_ready() {
  if gateway_ready; then
    return 0
  fi

  if just ai-up >/dev/null 2>&1; then
    return 0
  fi

  error "LiteLLM gateway is not reachable."
  error "Try: just ai-up"
  error "Logs: podman logs ai-lab-litellm"
  exit 8
}

ensure_ready() {
  check_dependencies
  check_python_runtime
  ensure_mlx_ready
  ensure_gateway_ready
}
