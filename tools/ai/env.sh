profile="${AI_LAB_PROFILE:-macos-work}"
gateway_env_file="$(
  printf '%s/containers/librechat/.env.%s.local' \
    "${AI_LAB_ROOT}" \
    "${profile}"
)"

if [[ -z "${LITELLM_MASTER_KEY:-}" && -r "${gateway_env_file}" ]]; then
  LITELLM_MASTER_KEY="$(
    awk '$0 ~ /^LITELLM_MASTER_KEY=/ {
      sub(/^LITELLM_MASTER_KEY=/, "")
      sub(/\r$/, "")
      print
      exit
    }' "${gateway_env_file}"
  )"
fi

export LITELLM_MASTER_KEY="${LITELLM_MASTER_KEY:-}"

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
