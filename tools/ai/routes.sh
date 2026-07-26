#!/usr/bin/env bash
set -euo pipefail

route_for_mode() {
  local mode="$1"

  case "$mode" in
    fast)
      echo "local-fast"
      ;;
    capable)
      echo "local-capable-mlx"
      ;;
    code)
      echo "local-code-mlx"
      ;;
    *)
      error "Unknown mode: ${mode}"
      error "Supported modes: fast, capable, code"
      exit 2
      ;;
  esac
}

frontier_route_for_mode() {
  local mode="$1"

  case "$mode" in
    fast|capable)
      echo "frontier-reasoning"
      ;;
    code)
      echo "frontier-code"
      ;;
    *)
      error "Unknown mode: ${mode}"
      error "Supported modes: fast, capable, code"
      exit 2
      ;;
  esac
}

route_provider() {
  local route="$1"

  case "$route" in
    local-*)
      echo "local"
      ;;
    frontier-*)
      echo "frontier"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

semantic_mode_for_prompt() {
  local prompt="$1"
  local mode

  check_python_runtime

  if [[ ! -f "tools/routing/semantic_route.py" ]]; then
    error "Semantic routing helper not found: tools/routing/semantic_route.py"
    error "Use an explicit mode instead:"
    error "  ai ask --mode fast prompt"
    error "  ai ask --mode capable prompt"
    error "  ai ask --mode code prompt"
    exit 8
  fi

  if ! mode="$(.venv/bin/python tools/routing/semantic_route.py "$prompt")"; then
    error "Semantic routing failed."
    error "Use an explicit mode instead:"
    error "  ai ask --mode fast prompt"
    error "  ai ask --mode capable prompt"
    error "  ai ask --mode code prompt"
    exit 8
  fi

  case "$mode" in
    fast|capable|code)
      echo "$mode"
      ;;
    *)
      error "Semantic routing returned an unknown mode: ${mode}"
      error "Use an explicit mode instead:"
      error "  ai ask --mode fast prompt"
      error "  ai ask --mode capable prompt"
      error "  ai ask --mode code prompt"
      exit 8
      ;;
  esac
}
