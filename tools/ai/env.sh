profile="${AI_LAB_PROFILE:-macos-work}"

secret_fallback_file="$(
  printf '%s/config/secrets/.env.%s.local' \
    "${AI_LAB_ROOT}" \
    "${profile}"
)"

export LITELLM_CLI_KEY="${LITELLM_CLI_KEY:-}"

GATEWAY_URL="${AI_LAB_GATEWAY_URL:-http://localhost:4000}"

GATEWAY_URL="${AI_LAB_GATEWAY_URL:-http://localhost:4000}"

active_profile() {
  echo "${AI_LAB_PROFILE:-macos-work}"
}

profile_path() {
  echo "profiles/$(active_profile)/profile.yaml"
}

profile_exists() {
  [[ -f "$(profile_path)" ]]
}

profile_posture() {
  echo "local-first"
}

state_root() {
  echo "${AI_LAB_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/ai-lab}"
}

profile_state_dir() {
  echo "$(state_root)/profiles/$(active_profile)"
}

history_file() {
  echo "$(profile_state_dir)/history.jsonl"
}
