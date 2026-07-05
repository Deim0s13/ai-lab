set shell := ["bash", "-uc"]

# ------------------------------------------------------------------------------
# Shared settings
# ------------------------------------------------------------------------------

gateway_url := env_var_or_default("AI_LAB_GATEWAY_URL", "http://localhost:4000")
gateway_key := env_var_or_default("LITELLM_MASTER_KEY", "")

litellm_image := "docker.io/litellm/litellm:1.90.0-rc.1"
litellm_container := "ai-lab-litellm"

mlx_fast_model := "mlx-community/Llama-3.2-3B-Instruct-4bit"
mlx_capable_model := "lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit"
mlx_code_model := "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit"

mlx_fast_port := "8080"
mlx_capable_port := "8081"
mlx_code_port := "8082"

promptfoo_timeout_ms := "1200000"

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------

default:
    just --list

# ------------------------------------------------------------------------------
# Validation
# ------------------------------------------------------------------------------

check-yaml:
    @.venv/bin/python -c 'import yaml; from pathlib import Path; paths=list(sorted(Path("config").rglob("*.yaml"))) + list(sorted(Path("profiles").rglob("*.yaml"))); [yaml.safe_load(p.open()) for p in paths]; [print(f"OK {p}") for p in paths]'

# ------------------------------------------------------------------------------
# LiteLLM gateway lifecycle
# ------------------------------------------------------------------------------

gateway-start:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @podman rm -f {{ litellm_container }} >/dev/null 2>&1 || true
    @podman run -d \
      --name {{ litellm_container }} \
      --platform linux/arm64 \
      -p 4000:4000 \
      -e LITELLM_MASTER_KEY="{{ gateway_key }}" \
      -v "$PWD/config/gateway/litellm/config.local.yaml:/app/config.yaml:ro" \
      {{ litellm_image }} \
      --config /app/config.yaml \
      --host 0.0.0.0 \
      --port 4000
    @echo "OK LiteLLM gateway started as {{ litellm_container }}"
    @just gateway-wait

gateway-wait:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @for i in {1..30}; do \
      if curl -fsS "{{ gateway_url }}/v1/models" -H "Authorization: Bearer {{ gateway_key }}" >/dev/null 2>&1; then \
        echo "OK LiteLLM gateway is ready"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "FAIL LiteLLM gateway did not become ready"; \
    podman logs {{ litellm_container }} | tail -50; \
    exit 8

gateway-stop:
    @podman rm -f {{ litellm_container }} >/dev/null 2>&1 || true
    @echo "OK LiteLLM gateway stopped"

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
# AI workstation lifecycle
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
# Ask helpers
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

# ------------------------------------------------------------------------------
# Ollama model helpers
# ------------------------------------------------------------------------------

models:
    @ollama list

model-aliases:
    @grep -n "ollama/" config/gateway/litellm/config.local.yaml || true
    @grep -n "openai/" config/gateway/litellm/config.local.yaml || true

# ------------------------------------------------------------------------------
# Model fitness evals
# ------------------------------------------------------------------------------

eval-model-fitness:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @mkdir -p tmp
    @PROMPTFOO_EVAL_TIMEOUT_MS={{ promptfoo_timeout_ms }} promptfoo eval \
      -c config/evals/model-fitness/promptfooconfig.yaml \
      --max-concurrency 1 \
      --no-cache \
      -o tmp/model-fitness-results.json

eval-model-fitness-mlx:
    @mkdir -p tmp
    @.venv/bin/python tools/evals/run_mlx_model_fitness.py

model-fitness-review:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @echo "== Checking MLX servers =="
    @just mlx-check
    @echo "== Checking YAML config =="
    @just check-yaml
    @echo "== Checking LiteLLM gateway routes =="
    @just gateway-models
    @just gateway-mlx-models
    @just gateway-routes
    @echo "== Checking gateway model routes =="
    @just gateway-routes
    @echo "== Checking MLX candidate routes =="
    @just gateway-mlx-models
    @echo "== Running Ollama/LiteLLM model fitness eval =="
    @just eval-model-fitness
    @echo "== Running direct MLX model fitness eval =="
    @just eval-model-fitness-mlx
    @echo "OK model fitness review completed"

# ------------------------------------------------------------------------------
# MLX server lifecycle
# ------------------------------------------------------------------------------

mlx-wait:
    @for i in {1..120}; do \
      if lsof -nP -iTCP:{{ mlx_fast_port }} -sTCP:LISTEN >/dev/null 2>&1 && \
         lsof -nP -iTCP:{{ mlx_capable_port }} -sTCP:LISTEN >/dev/null 2>&1 && \
         lsof -nP -iTCP:{{ mlx_code_port }} -sTCP:LISTEN >/dev/null 2>&1; then \
        echo "OK all MLX servers are listening"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "FAIL MLX servers did not all become ready"; \
    just mlx-logs; \
    exit 8
mlx-up:
    @just mlx-down
    @mkdir -p tmp
    @nohup .venv/bin/python -m mlx_lm server \
      --model {{ mlx_fast_model }} \
      --host 0.0.0.0 \
      --port {{ mlx_fast_port }} \
      > tmp/mlx-fast-server.log 2>&1 &
    @nohup .venv/bin/python -m mlx_lm server \
      --model {{ mlx_capable_model }} \
      --host 0.0.0.0 \
      --port {{ mlx_capable_port }} \
      > tmp/mlx-capable-server.log 2>&1 &
    @nohup .venv/bin/python -m mlx_lm server \
      --model {{ mlx_code_model }} \
      --host 0.0.0.0 \
      --port {{ mlx_code_port }} \
      > tmp/mlx-code-server.log 2>&1 &
    @echo "OK MLX servers starting"
    @just mlx-wait

mlx-check:
    @lsof -nP -iTCP:{{ mlx_fast_port }} -sTCP:LISTEN >/dev/null && echo "OK mlx fast server listening on {{ mlx_fast_port }}" || (echo "FAIL mlx fast server not listening on {{ mlx_fast_port }}" && exit 8)
    @lsof -nP -iTCP:{{ mlx_capable_port }} -sTCP:LISTEN >/dev/null && echo "OK mlx capable server listening on {{ mlx_capable_port }}" || (echo "FAIL mlx capable server not listening on {{ mlx_capable_port }}" && exit 8)
    @lsof -nP -iTCP:{{ mlx_code_port }} -sTCP:LISTEN >/dev/null && echo "OK mlx code server listening on {{ mlx_code_port }}" || (echo "FAIL mlx code server not listening on {{ mlx_code_port }}" && exit 8)

mlx-down:
    @pkill -f "mlx_lm server.*--port {{ mlx_fast_port }}" 2>/dev/null || true
    @pkill -f "mlx_lm server.*--port {{ mlx_capable_port }}" 2>/dev/null || true
    @pkill -f "mlx_lm server.*--port {{ mlx_code_port }}" 2>/dev/null || true
    @echo "OK MLX servers stopped"

mlx-logs:
    @echo "== mlx fast server =="
    @tail -50 tmp/mlx-fast-server.log 2>/dev/null || true
    @echo "== mlx capable server =="
    @tail -50 tmp/mlx-capable-server.log 2>/dev/null || true
    @echo "== mlx code server =="
    @tail -50 tmp/mlx-code-server.log 2>/dev/null || true
