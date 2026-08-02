# ------------------------------------------------------------------------------
# Workstation readiness helpers
# ------------------------------------------------------------------------------

workstation-preflight:
    @test -x "{{ omlx_command }}" \
      || (echo "FAIL oMLX command not found: {{ omlx_command }}" && exit 8)
    @test -r "{{ omlx_settings }}" \
      || (echo "FAIL oMLX settings are unavailable: {{ omlx_settings }}" && exit 8)
    @command -v podman >/dev/null 2>&1 || (echo "FAIL required command not found: podman" && exit 8)
    @command -v curl >/dev/null 2>&1 || (echo "FAIL required command not found: curl" && exit 8)
    @command -v jq >/dev/null 2>&1 || (echo "FAIL required command not found: jq" && exit 8)
    @command -v brew >/dev/null 2>&1 || (echo "FAIL required command not found: brew" && exit 8)
    @command -v ollama >/dev/null 2>&1 || (echo "FAIL required command not found: ollama" && exit 8)
    @test -x .venv/bin/python || (echo "FAIL Python runtime not found: .venv/bin/python" && exit 8)
    @test -f "{{ workstation_env_file }}" || (echo "FAIL missing {{ workstation_env_file }}; copy {{ ui_directory }}/.env.example and populate it" && exit 8)
    @key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "{{ workstation_env_file }}")"; \
      if [[ -z "$key" || "$key" == "replace-me" ]]; then \
        echo "FAIL LITELLM_MASTER_KEY is missing from {{ workstation_env_file }}"; \
        exit 8; \
      fi
    @podman machine inspect "{{ podman_machine }}" >/dev/null 2>&1 || (echo "FAIL Podman machine {{ podman_machine }} does not exist" && echo "Try: podman machine init {{ podman_machine }}" && exit 8)
    @echo "OK workstation preflight passed for {{ workstation_profile }}"

# ------------------------------------------------------------------------------
# AI workstation lifecycle
# ------------------------------------------------------------------------------

workstation-up:
    @just workstation-preflight
    @just podman-ready \
      || { echo "FAIL workstation startup stopped at Podman"; exit 8; }
    @just omlx-up \
      || { echo "FAIL workstation startup stopped at oMLX"; exit 8; }
    @just ollama-up \
      || { echo "FAIL workstation startup stopped at Ollama fallback"; exit 8; }
    @key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "{{ workstation_env_file }}")"; \
      if LITELLM_MASTER_KEY="$key" just gateway-ready >/dev/null 2>&1; then \
        echo "OK LiteLLM gateway is already ready"; \
      else \
        LITELLM_MASTER_KEY="$key" just gateway-start \
          || { echo "FAIL workstation startup stopped at LiteLLM"; exit 8; }; \
      fi
    @if just ui-status >/dev/null 2>&1; then \
      echo "OK LibreChat is already ready"; \
    else \
      just ui-up \
        || { echo "FAIL workstation startup stopped at LibreChat"; exit 8; }; \
    fi
    @just workstation-status
    @echo "OK complete AI workstation is ready for {{ workstation_profile }}"

workstation-status:
    @status_code=0; \
      key=""; \
      echo "AI Workstation Status"; \
      echo; \
      echo "Profile:        {{ workstation_profile }}"; \
      machine_state="$(podman machine inspect "{{ podman_machine }}" 2>/dev/null \
        | jq -r '.[0].State // empty' 2>/dev/null || true)"; \
      if [[ -n "$machine_state" ]]; then \
        echo "Podman machine: $machine_state"; \
      else \
        echo "Podman machine: unavailable"; \
        status_code=8; \
      fi; \
      if just podman-native-check >/dev/null 2>&1; then \
        echo "Podman API:     ready"; \
      else \
        echo "Podman API:     not ready"; \
        status_code=8; \
      fi; \
      if just podman-compose-check >/dev/null 2>&1; then \
        echo "Compose API:    ready"; \
      else \
        echo "Compose API:    not ready"; \
        status_code=8; \
      fi; \
      if ollama list >/dev/null 2>&1; then \
        echo "Ollama:         ready (fallback)"; \
      else \
        echo "Ollama:         not ready (fallback)"; \
        echo "                Try: just ollama-up"; \
        status_code=8; \
      fi; \
      if just omlx-check >/dev/null 2>&1; then \
        echo "oMLX:           ready (preferred)"; \
      else \
        echo "oMLX:           not ready (preferred)"; \
        echo "                Try: just omlx-up"; \
        status_code=8; \
      fi; \
      if [[ -f "{{ workstation_env_file }}" ]]; then \
        key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "{{ workstation_env_file }}")"; \
      fi; \
      if [[ -z "$key" || "$key" == "replace-me" ]]; then \
        echo "LiteLLM:        cannot check; profile key unavailable"; \
        status_code=8; \
      elif LITELLM_MASTER_KEY="$key" just gateway-ready >/dev/null 2>&1; then \
        echo "LiteLLM:        ready"; \
      else \
        echo "LiteLLM:        not ready"; \
        echo "                Try: just workstation-up"; \
        status_code=8; \
      fi; \
      if curl --max-time 2 -fsS "{{ ui_url }}" >/dev/null 2>&1; then \
        echo "LibreChat:      ready at {{ ui_url }}"; \
      else \
        echo "LibreChat:      not ready"; \
        echo "                Try: just workstation-up"; \
        status_code=8; \
      fi; \
      exit "$status_code"

workstation-logs:
    @echo "== Ollama service =="
    @brew services info ollama 2>&1 \
      || echo "INFO Ollama service information is unavailable"
    @echo
    @just omlx-logs
    @echo
    @echo "== LiteLLM gateway =="
    @podman logs --tail 100 {{ litellm_container }} 2>&1 \
      || echo "INFO LiteLLM logs are unavailable"
    @echo
    @echo "== LibreChat =="
    @if [[ ! -f "{{ workstation_env_file }}" ]]; then \
      echo "INFO LibreChat environment file is unavailable"; \
    elif ! just podman-compose-check >/dev/null 2>&1; then \
      echo "INFO LibreChat logs are unavailable because the Compose API is not ready"; \
    else \
      just ui-logs 2>&1 \
        || echo "INFO LibreChat logs could not be read"; \
    fi

workstation-down:
    @status_code=0; \
      if [[ "{{ workstation_profile }}" != "macos-work" ]]; then \
        echo "FAIL workstation lifecycle currently supports macos-work only"; \
        exit 8; \
      fi; \
      if [[ ! -f "{{ workstation_env_file }}" ]]; then \
        echo "FAIL missing {{ workstation_env_file }}"; \
        status_code=8; \
      elif just podman-compose-check >/dev/null 2>&1; then \
        just ui-down || status_code=8; \
      else \
        echo "FAIL LibreChat could not be stopped because the Compose API is unavailable"; \
        status_code=8; \
      fi; \
      if just podman-native-check >/dev/null 2>&1; then \
        just gateway-stop || status_code=8; \
      else \
        echo "FAIL LiteLLM could not be stopped because the Podman API is unavailable"; \
        status_code=8; \
      fi; \
      just omlx-down || status_code=8; \
      echo "INFO Podman machine {{ podman_machine }} remains running"; \
      echo "INFO Homebrew-managed Ollama remains running"; \
      if [[ "$status_code" -eq 0 ]]; then \
        echo "OK repo-managed AI workstation services are down"; \
      fi; \
      exit "$status_code"
