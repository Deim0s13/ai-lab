set shell := ["bash", "-uc"]

gateway_url := env_var_or_default("AI_LAB_GATEWAY_URL", "http://localhost:4000")
gateway_key := env_var_or_default("LITELLM_MASTER_KEY", "")

default:
    just --list

check-yaml:
    .venv/bin/python -c 'import yaml; from pathlib import Path; paths=list(sorted(Path("config").rglob("*.yaml"))) + list(sorted(Path("profiles").rglob("*.yaml"))); [yaml.safe_load(p.open()) for p in paths]; [print(f"OK {p}") for p in paths]'

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
