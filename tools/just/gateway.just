# ------------------------------------------------------------------------------
# LiteLLM gateway lifecycle
# ------------------------------------------------------------------------------

gateway-start:
    @test -n "{{ gateway_key }}" \
      || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @podman rm -f {{ litellm_container }} >/dev/null 2>&1 || true
    @omlx_key="${OMLX_API_KEY:-}"; \
      if [[ -z "${omlx_key}" && -f "{{ omlx_settings }}" ]]; then \
        omlx_key="$(jq -r '.auth.api_key // empty' "{{ omlx_settings }}")"; \
      fi; \
      if [[ -z "${omlx_key}" ]]; then \
        echo "FAIL oMLX API key is unavailable"; \
        exit 8; \
      fi; \
      podman run -d \
        --name {{ litellm_container }} \
        --platform linux/arm64 \
        -p 4000:4000 \
        -e LITELLM_MASTER_KEY="{{ gateway_key }}" \
        -e OMLX_API_KEY="${omlx_key}" \
        -v "$PWD/config/gateway/litellm/config.local.yaml:/app/config.yaml:ro" \
        {{ litellm_image }} \
        --config /app/config.yaml \
        --host 0.0.0.0 \
        --port 4000 >/dev/null
    @echo "OK LiteLLM gateway started as {{ litellm_container }}"
    @just gateway-wait

gateway-wait:
    @test -n "{{ gateway_key }}" \
      || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @for attempt in {1..60}; do \
      if just gateway-ready >/dev/null 2>&1; then \
        echo "OK LiteLLM gateway is ready"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "FAIL LiteLLM gateway did not become ready"; \
    podman logs --tail 50 {{ litellm_container }}; \
    exit 8

gateway-stop:
    @podman rm -f {{ litellm_container }} >/dev/null 2>&1 || true
    @echo "OK LiteLLM gateway stopped"

gateway-ready:
    @test -n "{{ gateway_key }}" \
      || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @curl --max-time 3 \
      -fsS \
      "{{ gateway_url }}/health/readiness" \
      -H "Authorization: Bearer {{ gateway_key }}" \
      >/dev/null
    @curl --max-time 3 \
      -fsS \
      "{{ gateway_url }}/v1/models" \
      -H "Authorization: Bearer {{ gateway_key }}" \
      | jq -e '.data | length > 0' >/dev/null
    @echo "OK LiteLLM gateway is ready"

gateway-status:
    @podman ps --filter name={{ litellm_container }}

gateway-logs:
    @podman logs -f {{ litellm_container }}

gateway-routes:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/v1/models" \
      -H "Authorization: Bearer {{ gateway_key }}" \
      | jq -r '.data[].id'

gateway-models:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/v1/models" \
      -H "Authorization: Bearer {{ gateway_key }}" \
      | jq -e '.data[] | select(.id == "local-fast")' >/dev/null
    @echo "OK local-fast listed by LiteLLM"

gateway-mlx-models:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/v1/models" -H "Authorization: Bearer {{ gateway_key }}" | jq -e '.data[] | select(.id == "local-fast-mlx")' >/dev/null
    @curl -fsS "{{ gateway_url }}/v1/models" -H "Authorization: Bearer {{ gateway_key }}" | jq -e '.data[] | select(.id == "local-capable-mlx")' >/dev/null
    @curl -fsS "{{ gateway_url }}/v1/models" -H "Authorization: Bearer {{ gateway_key }}" | jq -e '.data[] | select(.id == "local-code-mlx")' >/dev/null
    @echo "OK MLX candidate routes listed by LiteLLM"

gateway-health:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/health" \
      -H "Authorization: Bearer {{ gateway_key }}" \
      | jq -e '.healthy_count >= 1 and .unhealthy_count == 0' >/dev/null
    @echo "OK LiteLLM health reports healthy local endpoint"

# ------------------------------------------------------------------------------
# Daily gateway commands
# ------------------------------------------------------------------------------

ai-up: gateway-start
    @echo "OK AI workstation gateway is up"

ai-check: bootstrap-check
    @echo "OK AI workstation checks passed"

ai-down: gateway-stop
    @echo "OK AI workstation gateway is down"

bootstrap-check: check-yaml gateway-models gateway-health
    @echo "OK bootstrap check passed"

# ------------------------------------------------------------------------------
# User-facing AI commands
# ------------------------------------------------------------------------------

ask prompt:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/v1/chat/completions" \
      -H "Authorization: Bearer {{ gateway_key }}" \
      -H "Content-Type: application/json" \
      -d "$(.venv/bin/python -c 'import json, sys; print(json.dumps({"model": "local-fast", "messages": [{"role": "user", "content": sys.argv[1]}]}))' '{{ prompt }}')" \
      | jq -r '.choices[0].message.content'

ask-model model prompt:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @curl -fsS "{{ gateway_url }}/v1/chat/completions" \
      -H "Authorization: Bearer {{ gateway_key }}" \
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
    @just ask-model local-code-mlx "{{ prompt }}"
