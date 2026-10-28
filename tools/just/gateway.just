# ------------------------------------------------------------------------------
# LiteLLM gateway lifecycle
# ------------------------------------------------------------------------------

gateway-start:
    @if ! environment_file="$(source tools/ai/secrets.sh; materialize_litellm_env "{{ workstation_profile }}")"; then \
        exit 8; \
      fi; \
        trap 'rm -f "$environment_file"' EXIT; \
        master_key="$(awk -F= '$1 == "LITELLM_MASTER_KEY" { print $2; exit }' "$environment_file")"; \
        salt_key="$(awk -F= '$1 == "LITELLM_SALT_KEY" { print $2; exit }' "$environment_file")"; \
        database_password="$(awk -F= '$1 == "LITELLM_DATABASE_PASSWORD" { print $2; exit }' "$environment_file")"; \
        omlx_key="${OMLX_API_KEY:-}"; \
        if [[ -z "$omlx_key" && -f "{{ omlx_settings }}" ]]; then \
          omlx_key="$(jq -r '.auth.api_key // empty' "{{ omlx_settings }}")"; \
        fi; \
        if [[ -z "$omlx_key" ]]; then \
          echo "FAIL oMLX API key is unavailable"; \
          exit 8; \
        fi; \
        LITELLM_MASTER_KEY="$master_key" \
        LITELLM_SALT_KEY="$salt_key" \
        LITELLM_DATABASE_PASSWORD="$database_password" \
        OMLX_API_KEY="$omlx_key" \
          podman compose \
            --env-file "$environment_file" \
            --project-name "{{ gateway_project }}" \
            --file "{{ gateway_compose_file }}" \
            up -d --remove-orphans; \
        LITELLM_MASTER_KEY="$master_key" just gateway-wait
    @echo "OK LiteLLM gateway and persistent key database started"

gateway-wait:
    @test -n "{{ gateway_key }}" \
      || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @for attempt in {1..120}; do \
      if just gateway-ready >/dev/null 2>&1; then \
        echo "OK LiteLLM gateway is ready"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "FAIL LiteLLM gateway did not become ready"; \
    just gateway-log-tail; \
    exit 8

gateway-stop:
    @OMLX_API_KEY=replace-me \
      podman compose \
        --env-file "{{ gateway_example_env_file }}" \
        --project-name "{{ gateway_project }}" \
        --file "{{ gateway_compose_file }}" \
        down --remove-orphans
    @echo "OK LiteLLM gateway stopped; persistent key data retained"

gateway-binding-check:
    @binding="$(OMLX_API_KEY=replace-me \
        podman compose \
          --env-file "{{ gateway_example_env_file }}" \
          --project-name "{{ gateway_project }}" \
          --file "{{ gateway_compose_file }}" \
          port "{{ gateway_service }}" "{{ gateway_port }}" 2>/dev/null \
        | tail -n 1)"; \
      expected="{{ gateway_bind_host }}:{{ gateway_port }}"; \
      if [[ "$binding" != "$expected" ]]; then \
        echo "FAIL LiteLLM has unexpected runtime binding: ${binding:-unavailable}"; \
        echo "Expected: $expected"; \
        echo "Try: just workstation-up"; \
        exit 8; \
      fi; \
      echo "OK LiteLLM runtime is bound to $expected"

gateway-ready:
    @test -n "{{ gateway_auth_key }}" \
      || (echo "FAIL LITELLM_API_KEY or LITELLM_MASTER_KEY is not set" && exit 8)
    @just gateway-binding-check
    @curl --max-time 3 \
      -fsS \
      "{{ gateway_url }}/health/readiness" \
      -H "Authorization: Bearer {{ gateway_auth_key }}" \
      >/dev/null
    @curl --max-time 3 \
      -fsS \
      "{{ gateway_url }}/v1/models" \
      -H "Authorization: Bearer {{ gateway_auth_key }}" \
      | jq -e '.data | length > 0' >/dev/null
    @echo "OK LiteLLM gateway is ready"

gateway-status:
    @OMLX_API_KEY=replace-me \
      podman compose \
        --env-file "{{ gateway_example_env_file }}" \
        --project-name "{{ gateway_project }}" \
        --file "{{ gateway_compose_file }}" \
        ps

gateway-log-tail:
    @OMLX_API_KEY=replace-me \
      podman compose \
        --env-file "{{ gateway_example_env_file }}" \
        --project-name "{{ gateway_project }}" \
        --file "{{ gateway_compose_file }}" \
        logs --tail 100 "{{ gateway_service }}"

gateway-logs:
    @OMLX_API_KEY=replace-me \
      podman compose \
        --env-file "{{ gateway_example_env_file }}" \
        --project-name "{{ gateway_project }}" \
        --file "{{ gateway_compose_file }}" \
        logs -f "{{ gateway_service }}"

gateway-routes:
    @test -n "{{ gateway_client_key }}" \
      || (echo "FAIL LITELLM_API_KEY is not set" && exit 8)
    @curl --max-time 3 -fsS "{{ gateway_url }}/v1/models" \
      -H "Authorization: Bearer {{ gateway_client_key }}" \
      | jq -r '.data[].id'

gateway-models:
    @test -n "{{ gateway_auth_key }}" \
      || (echo "FAIL LITELLM_API_KEY or LITELLM_MASTER_KEY is not set" && exit 8)
    @curl --max-time 3 -fsS "{{ gateway_url }}/v1/models" \
      -H "Authorization: Bearer {{ gateway_auth_key }}" \
      | jq -e \
          '([.data[].id] | index("local-fast")) != null and ([.data[].id] | index("local-code")) != null' \
          >/dev/null
    @echo "OK required stable model groups listed by LiteLLM"

gateway-mlx-models:
    @test -n "{{ gateway_auth_key }}" \
      || (echo "FAIL LITELLM_API_KEY or LITELLM_MASTER_KEY is not set" && exit 8)
    @curl --max-time 3 -fsS "{{ gateway_url }}/v1/models" \
      -H "Authorization: Bearer {{ gateway_auth_key }}" \
      | jq -e '([.data[].id] | index("local-fast-mlx")) != null and ([.data[].id] | index("local-capable-mlx")) != null and ([.data[].id] | index("local-code-mlx")) != null' \
      >/dev/null
    @echo "OK MLX candidate routes listed by LiteLLM"

gateway-health:
    @test -n "{{ gateway_key }}" \
      || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @if ! health="$(curl --max-time 20 -fsS "{{ gateway_url }}/health" \
        -H "Authorization: Bearer {{ gateway_key }}")"; then \
      echo "FAIL LiteLLM aggregate provider health is unavailable or exceeded 20 seconds"; \
      exit 8; \
    fi; \
    if ! jq -e '.healthy_count >= 1 and .unhealthy_count == 0' \
        <<<"$health" >/dev/null; then \
      echo "FAIL one or more configured LiteLLM endpoints are unhealthy"; \
      exit 8; \
    fi
    @echo "OK all configured LiteLLM endpoints are healthy"

# ------------------------------------------------------------------------------
# Daily gateway commands
# ------------------------------------------------------------------------------

ai-up: gateway-start
    @echo "OK AI workstation gateway is up"

ai-check: bootstrap-check
    @echo "OK AI workstation checks passed"

ai-down: gateway-stop
    @echo "OK AI workstation gateway is down"

bootstrap-check: check-yaml gateway-ready gateway-models
    @echo "OK bootstrap check passed"

# ------------------------------------------------------------------------------
# User-facing AI commands
# ------------------------------------------------------------------------------

ask prompt:
    @test -n "{{ gateway_client_key }}" \
      || (echo "FAIL LITELLM_API_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/v1/chat/completions" \
      -H "Authorization: Bearer {{ gateway_client_key }}" \
      -H "Content-Type: application/json" \
      -d "$(.venv/bin/python -c 'import json, sys; print(json.dumps({"model": "local-fast", "messages": [{"role": "user", "content": sys.argv[1]}]}))' '{{ prompt }}')" \
      | jq -r '.choices[0].message.content'

ask-model model prompt:
    @test -n "{{ gateway_client_key }}" \
      || (echo "FAIL LITELLM_API_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/v1/chat/completions" \
      -H "Authorization: Bearer {{ gateway_client_key }}" \
      -H "Content-Type: application/json" \
      -d "$(.venv/bin/python -c 'import json, sys; print(json.dumps({"model": sys.argv[1], "messages": [{"role": "user", "content": sys.argv[2]}]}))' '{{ model }}' '{{ prompt }}')" \
      | jq -r '.choices[0].message.content'

ask-mlx model prompt:
    @.venv/bin/python -m mlx_lm.generate \
      --model "{{ model }}" \
      --prompt "{{ prompt }}" \
      --max-tokens 300

ai-fast prompt:
    @just ask-model local-fast-mlx "{{ prompt }}"

ai-capable prompt:
    @just ask-model local-capable-mlx "{{ prompt }}"

ai-code prompt:
    @just ask-model local-code "{{ prompt }}"
