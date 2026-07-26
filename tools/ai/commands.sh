#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
AI Dev Workstation

Usage:
  ai                                          Start/check the local AI workstation
  ai ask [options] prompt                     Ask using local-first routing
  ai fast prompt                              Shortcut for fast mode
  ai capable prompt                           Shortcut for capable mode
  ai code prompt                              Shortcut for code mode
  ai routes                                   List available gateway routes
  ai routes test prompt                       Show what route would handle a prompt
  ai status                                   Check local workstation status
  ai history                                  Show recent local AI usage history
  ai feedback good|bad [note]                 Mark the most recent prompt response
  ai profile                                  Show active profile and routing posture
  ai down                                     Stop local gateway and MLX servers

Ask options:
  --mode fast|capable|code                    Select a mode explicitly
  --frontier                                  Request frontier escalation
  --confirm-frontier                          Acknowledge frontier use

Operator commands remain available through just.

Prompts can be quoted, unquoted, or provided through stdin.
Use quotes or stdin when the prompt contains shell-special characters.

USAGE
}

routes_test() {
  local mode=""
  local route
  local provider
  local prompt
  local decision_source="semantic"

  if [[ "${1:-}" == "--mode" ]]; then
    mode="${2:-}"
    decision_source="explicit"
    shift 2
  fi

  prompt="$(read_prompt "$@")" || {
    error "No prompt provided."
    error "Usage: ai routes test [--mode fast|capable|code] prompt"
    error "Examples:"
    error "  ai routes test Review this shell command"
    error "  ai routes test --mode code Review this shell command"
    exit 2
  }

  check_dependencies

  if [[ -z "$mode" ]]; then
    mode="$(semantic_mode_for_prompt "$prompt")"
  fi

  route="$(route_for_mode "$mode")"
  provider="$(route_provider "$route")"

  ensure_gateway_ready

  echo "AI Route Dry Run"
  echo
  echo "Mode:       ${mode}"
  echo "Route:      ${route}"
  echo "Provider:   ${provider}"
  echo "Decision:   ${decision_source}"

  if gateway_ready; then
    echo "Gateway:    reachable"
  else
    echo "Gateway:    not reachable"
  fi

  echo "Action:     would route locally"
  echo "Prompt:     ${prompt}"

  log_history \
    "dry_run" \
    "routes test" \
    "$mode" \
    "$route" \
    "$provider" \
    "success" \
    "" \
    "$prompt" \
    "$decision_source"
}

show_profile() {
  local profile
  local path

  profile="$(active_profile)"
  path="$(profile_path)"

  echo "AI Dev Workstation Profile"
  echo
  echo "Active profile:   ${profile}"
  echo "Profile file:     ${path}"

  if profile_exists; then
    echo "Profile status:   found"
  else
    echo "Profile status:   missing"
    echo "                  Try: export AI_LAB_PROFILE=macos-work"
  fi

  echo "Routing posture:  $(profile_posture)"
  echo "Gateway:          local LiteLLM"
  echo "Frontier:         not configured"
}

handle_frontier_request() {
  local mode="$1"
  local prompt="$2"
  local confirmed="$3"
  local route
  local provider

  route="$(frontier_route_for_mode "$mode")"
  provider="$(route_provider "$route")"

  if [[ "$confirmed" != "true" ]]; then
    echo "Frontier escalation requested."
    echo
    echo "Profile:         $(active_profile)"
    echo "Local-first:     enabled"
    echo "Requested route: ${route}"
    echo "Acknowledgement: required"
    echo
    echo "No request was sent."
    echo "Rerun with --confirm-frontier to acknowledge frontier use."

    log_history \
      "frontier_escalation" \
      "ask" \
      "$mode" \
      "$route" \
      "$provider" \
      "blocked" \
      "" \
      "$prompt" \
      "frontier_unacknowledged"

    exit 7
  fi

  echo "Frontier escalation acknowledged."
  echo
  echo "Profile:         $(active_profile)"
  echo "Local-first:     enabled"
  echo "Requested route: ${route}"
  echo "Acknowledgement: confirmed"
  echo "Provider:        not configured"
  echo
  echo "No request was sent."
  echo "Frontier provider configuration is deferred to a future issue."

  log_history \
    "frontier_escalation" \
    "ask" \
    "$mode" \
    "$route" \
    "$provider" \
    "unavailable" \
    "" \
    "$prompt" \
    "frontier_acknowledged"

  exit 6
}

run_prompt_command() {
  local command_name="$1"
  local mode="$2"
  local route="$3"
  local prompt="$4"
  local decision_source="${5:-explicit}"
  local provider
  local start_ns
  local end_ns
  local latency_ms
  local output
  local status_code

  provider="$(route_provider "$route")"

  start_ns="$(.venv/bin/python -c 'import time; print(time.monotonic_ns())')"

  set +e
  output="$(ask_model "$route" "$prompt" 2>&1)"
  status_code="$?"
  set -e

  end_ns="$(.venv/bin/python -c 'import time; print(time.monotonic_ns())')"
  latency_ms="$(((end_ns - start_ns) / 1000000))"

  if [[ "$status_code" -eq 0 ]]; then
    log_history \
      "prompt" \
      "$command_name" \
      "$mode" \
      "$route" \
      "$provider" \
      "success" \
      "$latency_ms" \
      "$prompt" \
      "$decision_source"

    printf "%s\n" "$output"
  else
    log_history \
      "prompt" \
      "$command_name" \
      "$mode" \
      "$route" \
      "$provider" \
      "failure" \
      "$latency_ms" \
      "$prompt" \
      "$decision_source"

    printf "%s\n" "$output" >&2
    exit "$status_code"
  fi
}

command_default() {
  ensure_ready
  echo "AI Dev Workstation is ready."
  echo
  usage
}

command_ask() {
  local mode=""
  local decision_source="semantic"
  local frontier_requested="false"
  local frontier_confirmed="false"
  local prompt
  local model

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --mode)
        if [[ "$#" -lt 2 ]]; then
          error "Missing value for --mode."
          error "Supported modes: fast, capable, code"
          exit 2
        fi

        mode="$2"
        decision_source="explicit"
        shift 2
        ;;
      --frontier)
        frontier_requested="true"
        shift
        ;;
      --confirm-frontier)
        frontier_confirmed="true"
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ "$frontier_confirmed" == "true" &&
    "$frontier_requested" != "true" ]]; then
    error "--confirm-frontier requires --frontier."
    exit 2
  fi

  prompt="$(read_prompt "$@")" || missing_prompt "ask"

  if [[ -z "$mode" ]]; then
    mode="$(semantic_mode_for_prompt "$prompt")"
  fi

  if [[ "$frontier_requested" == "true" ]]; then
    handle_frontier_request \
      "$mode" \
      "$prompt" \
      "$frontier_confirmed"
  fi

  model="$(route_for_mode "$mode")"

  ensure_ready
  run_prompt_command \
    "ask" \
    "$mode" \
    "$model" \
    "$prompt" \
    "$decision_source"
}

command_fast() {
  local prompt

  prompt="$(read_prompt "$@")" || missing_prompt "fast"

  ensure_ready
  run_prompt_command \
    "fast" \
    "fast" \
    "local-fast" \
    "$prompt" \
    "explicit"
}

command_capable() {
  local prompt

  prompt="$(read_prompt "$@")" || missing_prompt "capable"

  ensure_ready
  run_prompt_command \
    "capable" \
    "capable" \
    "local-capable-mlx" \
    "$prompt" \
    "explicit"
}

command_code() {
  local prompt

  prompt="$(read_prompt "$@")" || missing_prompt "code"

  ensure_ready
  run_prompt_command \
    "code" \
    "code" \
    "local-code-mlx" \
    "$prompt" \
    "explicit"
}

command_routes() {
  case "${1:-}" in
    "")
      check_dependencies
      check_python_runtime
      ensure_gateway_ready
      just gateway-routes
      ;;
    test)
      shift
      routes_test "$@"
      ;;
    *)
      error "Unknown routes command: ${1}"
      error "Usage:"
      error "  ai routes"
      error "  ai routes test [--mode fast|capable|code] prompt"
      exit 2
      ;;
  esac
}

command_status() {
  local fast_ready="not ready"
  local capable_ready="not ready"
  local code_ready="not ready"

  check_dependencies

  echo "AI Dev Workstation Status"
  echo

  echo "Profile:    $(active_profile)"
  echo "Posture:    $(profile_posture)"

  if curl -fsS "${GATEWAY_URL}/v1/models" \
    -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" >/dev/null 2>&1; then
    echo "Gateway:    running"
  else
    echo "Gateway:    not reachable"
    echo "            Try: just ai-up"
  fi

  if lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null 2>&1; then
    fast_ready="ready"
  fi

  if lsof -nP -iTCP:8081 -sTCP:LISTEN >/dev/null 2>&1; then
    capable_ready="ready"
  fi

  if lsof -nP -iTCP:8082 -sTCP:LISTEN >/dev/null 2>&1; then
    code_ready="ready"
  fi

  echo "Local:      fast (${fast_ready}), capable (${capable_ready}), code (${code_ready})"

  if [[ "$fast_ready" != "ready" ||
    "$capable_ready" != "ready" ||
    "$code_ready" != "ready" ]]; then
    echo "            Try: just mlx-up"
  fi

  echo "Frontier:   not configured"
  echo "Routes:     local-fast, local-capable-mlx, local-code-mlx"
  echo "Last route: $(last_route_summary)"
}

command_history() {
  show_history "$@"
}

command_feedback() {
  record_feedback "$@"
}

command_profile() {
  check_dependencies
  show_profile
}

command_down() {
  just ai-down
  just mlx-down
}

unknown_command() {
  local command="$1"

  echo "Unknown command: ${command}" >&2
  echo >&2
  usage >&2
  exit 2
}
