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
}

check_python_runtime() {
  if [[ ! -x ".venv/bin/python" ]]; then
    error "Python runtime not found: .venv/bin/python"
    error "Try: python -m venv .venv && .venv/bin/pip install -r requirements.txt"
    exit 8
  fi
}

ensure_gateway_ready() {
  if gateway_ready; then
    return 0
  fi

  if AI_LAB_PROFILE="$(active_profile)" \
    just workstation-up >/dev/null 2>&1; then
    return 0
  fi

  error "LiteLLM gateway is not reachable."
  error "Try: just workstation-up"
  error "Logs: just workstation-logs"
  exit 8
}

ensure_ready() {
  check_dependencies
  check_python_runtime

  if AI_LAB_PROFILE="$(active_profile)" \
    just workstation-status >/dev/null 2>&1; then
    return 0
  fi

  if AI_LAB_PROFILE="$(active_profile)" \
    just workstation-up >/dev/null 2>&1; then
    return 0
  fi

  error "AI workstation is not ready."
  error "Try: just workstation-up"
  error "Logs: just workstation-logs"
  exit 8
}
