# ------------------------------------------------------------------------------
# Workstation validation baseline
# ------------------------------------------------------------------------------

validation-static:
    @bash -n bin/ai tools/ai/*.sh
    @just --fmt --check
    @just check-yaml
    @just opencode-config-check
    @git diff --check
    @echo "OK static workstation validation passed"

local-exposure-check:
    @just gateway-binding-check
    @omlx_host="$(jq -r '.server.host // empty' "{{ omlx_settings }}")"; \
      if [[ "$omlx_host" != "{{ mlx_bind_host }}" ]]; then \
        echo "FAIL oMLX is configured for an unexpected host: ${omlx_host:-unavailable}"; \
        echo "Expected: {{ mlx_bind_host }}"; \
        exit 8; \
      fi; \
      echo "OK oMLX is configured for loopback"
    @for item in \
        "Ollama:11434:required" \
        "oMLX:8000:required" \
        "MLX-fast:{{ mlx_fast_port }}:optional" \
        "MLX-capable:{{ mlx_capable_port }}:optional" \
        "MLX-code:{{ mlx_code_port }}:optional"; do \
      label="${item%%:*}"; \
      remainder="${item#*:}"; \
      port="${remainder%%:*}"; \
      requirement="${item##*:}"; \
      listeners="$(lsof -nP -iTCP:"$port" -sTCP:LISTEN -F n 2>/dev/null \
        | sed -n 's/^n//p')"; \
      if [[ -z "$listeners" ]]; then \
        if [[ "$requirement" == "required" ]]; then \
          echo "FAIL $label has no listener on port $port"; \
          exit 8; \
        fi; \
        continue; \
      fi; \
      while IFS= read -r listener; do \
        case "$listener" in \
          "127.0.0.1:${port}"|"[::1]:${port}") ;; \
          *) \
            echo "FAIL $label has a non-loopback listener: $listener"; \
            exit 8 ;; \
        esac; \
      done <<<"$listeners"; \
      echo "OK $label listener is loopback-only"; \
    done
    @echo "OK local service exposure validation passed"

validation-live: validation-static
    @if [[ "{{ workstation_profile }}" != "macos-work" ]]; then \
      echo "FAIL live validation currently supports macos-work only"; \
      exit 8; \
    fi
    @just workstation-preflight
    @just workstation-status
    @just ollama-check
    @just omlx-check
    @just local-exposure-check
    @just ui-check
    @just opencode-check
    @echo "OK live workstation validation passed for {{ workstation_profile }}"
