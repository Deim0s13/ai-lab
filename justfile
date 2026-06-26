set shell := ["bash", "-uc"]

gateway_url := env_var_or_default("AI_LAB_GATEWAY_URL", "http://localhost:4000")
gateway_key := env_var_or_default("LITELLM_MASTER_KEY", "")
litellm_image := "docker.io/litellm/litellm:1.90.0-rc.1"
litellm_container := "ai-lab-litellm"

default:
    just --list

check-yaml:
    .venv/bin/python -c 'import yaml; from pathlib import Path; paths=list(sorted(Path("config").rglob("*.yaml"))) + list(sorted(Path("profiles").rglob("*.yaml"))); [yaml.safe_load(p.open()) for p in paths]; [print(f"OK {p}") for p in paths]'

gateway-start:
    test -n "{{gateway_key}}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    podman rm -f {{litellm_container}} >/dev/null 2>&1 || true
    podman run -d \
      --name {{litellm_container}} \
      --platform linux/arm64 \
      -p 4000:4000 \
      -e LITELLM_MASTER_KEY="{{gateway_key}}" \
      -v "$PWD/config/gateway/litellm/config.local.yaml:/app/config.yaml:ro" \
      {{litellm_image}} \
      --config /app/config.yaml \
      --host 0.0.0.0 \
      --port 4000
    echo "OK LiteLLM gateway started as {{litellm_container}}"

gateway-stop:
    podman rm -f {{litellm_container}} >/dev/null 2>&1 || true
    echo "OK LiteLLM gateway stopped"

gateway-status:
    podman ps --filter name={{litellm_container}}

gateway-logs:
    podman logs -f {{litellm_container}}

gateway-models:
    test -n "{{gateway_key}}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    curl -fsS "{{gateway_url}}/v1/models" -H "Authorization: Bearer {{gateway_key}}" | jq -e '.data[] | select(.id == "local-fast")' >/dev/null
    echo "OK local-fast listed by LiteLLM"

gateway-health:
    test -n "{{gateway_key}}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    curl -fsS "{{gateway_url}}/health" -H "Authorization: Bearer {{gateway_key}}" | jq -e '.healthy_count >= 1 and .unhealthy_count == 0' >/dev/null
    echo "OK LiteLLM health reports healthy local endpoint"

bootstrap-check: check-yaml gateway-models gateway-health
    echo "OK bootstrap check passed"
