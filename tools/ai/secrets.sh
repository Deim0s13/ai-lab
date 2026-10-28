#!/usr/bin/env bash

# This file is a sourceable function library.
# It must not alter options in the caller's shell.

secret_is_placeholder() {
  local value="${1:-}"

  case "${value}" in
    ""|replace-me|replace-with-*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

secret_from_environment() {
  local secret_name="$1"
  local value="${!secret_name:-}"

  if ! secret_is_placeholder "${value}"; then
    printf '%s' "${value}"
    return 0
  fi

  return 1
}

secret_from_bitwarden() {
  local secret_ref="$1"
  local value=""

  command -v bw >/dev/null 2>&1 || return 1
  [[ -n "${BW_SESSION:-}" ]] || return 1

  if ! bw status \
    | jq -e '.status == "unlocked"' \
    >/dev/null 2>&1; then
    return 1
  fi

  value="$(
    bw get password "${secret_ref}" 2>/dev/null
  )"

  if ! secret_is_placeholder "${value}"; then
    printf '%s' "${value}"
    return 0
  fi

  return 1
}

secret_from_env_file() {
  local secret_name="$1"
  local env_file="$2"
  local value=""

  [[ -r "${env_file}" ]] || return 1

  value="$(
    awk \
      -v secret_name="${secret_name}" \
      '
        index($0, secret_name "=") == 1 {
          sub("^[^=]*=", "")
          sub(/\r$/, "")
          print
          exit
        }
      ' \
      "${env_file}"
  )"

  if ! secret_is_placeholder "${value}"; then
    printf '%s' "${value}"
    return 0
  fi

  return 1
}

resolve_profile_secret() {
  local profile="$1"
  local secret_name="$2"
  local fallback_file="$3"
  local secret_ref="ai-lab/${profile}/${secret_name}"
  local value=""

  if value="$(secret_from_environment "${secret_name}")"; then
    printf '%s' "${value}"
    return 0
  fi

  if value="$(secret_from_bitwarden "${secret_ref}")"; then
    printf '%s' "${value}"
    return 0
  fi

  if value="$(
    secret_from_env_file \
      "${secret_name}" \
      "${fallback_file}"
  )"; then
    printf '%s' "${value}"
    return 0
  fi

  echo "FAIL ${secret_name} is unavailable for profile ${profile}" >&2
  echo "Unlock Bitwarden or populate the ignored fallback file: ${fallback_file}" >&2
  return 8
}

materialize_litellm_env() {
  local profile="${1:-macos-work}"
  local root="${AI_LAB_ROOT:-}"
  local fallback_file=""
  local master_key=""
  local salt_key=""
  local database_password=""
  local temporary_file=""

  if [[ -z "${root}" ]]; then
    root="$(
      cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." \
        >/dev/null 2>&1
      pwd
    )"
  fi

  fallback_file="${root}/containers/litellm/.env.${profile}.local"

  if ! master_key="$(
    resolve_profile_secret \
      "${profile}" \
      LITELLM_MASTER_KEY \
      "${fallback_file}"
  )"; then
    return 8
  fi

  if ! salt_key="$(
    resolve_profile_secret \
      "${profile}" \
      LITELLM_SALT_KEY \
      "${fallback_file}"
  )"; then
    return 8
  fi

  if ! database_password="$(
    resolve_profile_secret \
      "${profile}" \
      LITELLM_DATABASE_PASSWORD \
      "${fallback_file}"
  )"; then
    return 8
  fi

  if [[ "${master_key}" != sk-* ]]; then
    echo "FAIL LITELLM_MASTER_KEY must start with sk-" >&2
    return 8
  fi

  if [[ "${salt_key}" != sk-* ]]; then
    echo "FAIL LITELLM_SALT_KEY must start with sk-" >&2
    return 8
  fi

  if [[ ! "${database_password}" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "FAIL LITELLM_DATABASE_PASSWORD must contain 64 hexadecimal characters" >&2
    return 8
  fi

  umask 077

  if ! temporary_file="$(
    mktemp \
      "${TMPDIR:-/tmp}/ai-lab-litellm-${profile}.XXXXXX"
  )"; then
    echo "FAIL could not create temporary LiteLLM environment" >&2
    return 8
  fi

  if ! printf \
    'LITELLM_MASTER_KEY=%s\nLITELLM_SALT_KEY=%s\nLITELLM_DATABASE_PASSWORD=%s\n' \
    "${master_key}" \
    "${salt_key}" \
    "${database_password}" \
    >"${temporary_file}"; then
    rm -f "${temporary_file}"
    return 8
  fi

  chmod 600 "${temporary_file}"

  unset \
    master_key \
    salt_key \
    database_password

  printf '%s\n' "${temporary_file}"
}

materialize_librechat_env() {
  local profile="${1:-macos-work}"
  local root="${AI_LAB_ROOT:-}"
  local client_fallback_file=""
  local librechat_env_file=""
  local client_key=""
  local jwt_secret=""
  local jwt_refresh_secret=""
  local creds_key=""
  local creds_iv=""
  local allow_registration=""
  local debug_logging=""
  local temporary_file=""

  if [[ -z "${root}" ]]; then
    root="$(
      cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." \
        >/dev/null 2>&1
      pwd
    )"
  fi

  client_fallback_file="${root}/config/secrets/.env.${profile}.local"
  librechat_env_file="${root}/containers/librechat/.env.${profile}.local"

  if [[ ! -r "${librechat_env_file}" ]]; then
    echo "FAIL LibreChat environment is unavailable: ${librechat_env_file}" >&2
    return 8
  fi

  if ! client_key="$(
    resolve_profile_secret \
      "${profile}" \
      LITELLM_LIBRECHAT_KEY \
      "${client_fallback_file}"
  )"; then
    return 8
  fi

  if ! jwt_secret="$(
    secret_from_env_file JWT_SECRET "${librechat_env_file}"
  )"; then
    echo "FAIL JWT_SECRET is unavailable in ${librechat_env_file}" >&2
    return 8
  fi

  if ! jwt_refresh_secret="$(
    secret_from_env_file JWT_REFRESH_SECRET "${librechat_env_file}"
  )"; then
    echo "FAIL JWT_REFRESH_SECRET is unavailable in ${librechat_env_file}" >&2
    return 8
  fi

  if ! creds_key="$(
    secret_from_env_file CREDS_KEY "${librechat_env_file}"
  )"; then
    echo "FAIL CREDS_KEY is unavailable in ${librechat_env_file}" >&2
    return 8
  fi

  if ! creds_iv="$(
    secret_from_env_file CREDS_IV "${librechat_env_file}"
  )"; then
    echo "FAIL CREDS_IV is unavailable in ${librechat_env_file}" >&2
    return 8
  fi

  allow_registration="$(
    secret_from_env_file \
      LIBRECHAT_ALLOW_REGISTRATION \
      "${librechat_env_file}" \
      2>/dev/null \
      || printf 'false'
  )"

  debug_logging="$(
    secret_from_env_file \
      LIBRECHAT_DEBUG_LOGGING \
      "${librechat_env_file}" \
      2>/dev/null \
      || printf 'false'
  )"

  if [[ "${client_key}" != sk-* ]]; then
    echo "FAIL LITELLM_LIBRECHAT_KEY must start with sk-" >&2
    return 8
  fi

  if [[ ! "${jwt_secret}" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "FAIL JWT_SECRET must contain 64 hexadecimal characters" >&2
    return 8
  fi

  if [[ ! "${jwt_refresh_secret}" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "FAIL JWT_REFRESH_SECRET must contain 64 hexadecimal characters" >&2
    return 8
  fi

  if [[ ! "${creds_key}" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "FAIL CREDS_KEY must contain 64 hexadecimal characters" >&2
    return 8
  fi

  if [[ ! "${creds_iv}" =~ ^[0-9a-fA-F]{32}$ ]]; then
    echo "FAIL CREDS_IV must contain 32 hexadecimal characters" >&2
    return 8
  fi

  umask 077

  if ! temporary_file="$(
    mktemp \
      "${TMPDIR:-/tmp}/ai-lab-librechat-${profile}.XXXXXX"
  )"; then
    echo "FAIL could not create temporary LibreChat environment" >&2
    return 8
  fi

  if ! printf \
    'LITELLM_LIBRECHAT_KEY=%s\nJWT_SECRET=%s\nJWT_REFRESH_SECRET=%s\nCREDS_KEY=%s\nCREDS_IV=%s\nLIBRECHAT_ALLOW_REGISTRATION=%s\nLIBRECHAT_DEBUG_LOGGING=%s\n' \
    "${client_key}" \
    "${jwt_secret}" \
    "${jwt_refresh_secret}" \
    "${creds_key}" \
    "${creds_iv}" \
    "${allow_registration}" \
    "${debug_logging}" \
    >"${temporary_file}"; then
    rm -f "${temporary_file}"
    return 8
  fi

  chmod 600 "${temporary_file}"

  unset \
    client_key \
    jwt_secret \
    jwt_refresh_secret \
    creds_key \
    creds_iv

  printf '%s\n' "${temporary_file}"
}
