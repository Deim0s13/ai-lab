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
    test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    podman rm -f {{ litellm_container }} >/dev/null 2>&1 || true
    podman run -d \
      --name {{ litellm_container }} \
      --platform linux/arm64 \
      -p 4000:4000 \
      -e LITELLM_MASTER_KEY="{{ gateway_key }}" \
      -v "$PWD/config/gateway/litellm/config.local.yaml:/app/config.yaml:ro" \
      {{ litellm_image }} \
      --config /app/config.yaml \
      --host 0.0.0.0 \
      --port 4000
    echo "OK LiteLLM gateway started as {{ litellm_container }}"
    just gateway-wait

gateway-wait:
    test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    for i in {1..30}; do \
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
    podman rm -f {{ litellm_container }} >/dev/null 2>&1 || true
    echo "OK LiteLLM gateway stopped"

gateway-status:
    podman ps --filter name={{ litellm_container }}

gateway-logs:
    podman logs -f {{ litellm_container }}

gateway-models:
    test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    curl -fsS "{{ gateway_url }}/v1/models" -H "Authorization: Bearer {{ gateway_key }}" | jq -e '.data[] | select(.id == "local-fast")' >/dev/null
    echo "OK local-fast listed by LiteLLM"

gateway-health:
    test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    curl -fsS "{{ gateway_url }}/health" -H "Authorization: Bearer {{ gateway_key }}" | jq -e '.healthy_count >= 1 and .unhealthy_count == 0' >/dev/null
    echo "OK LiteLLM health reports healthy local endpoint"

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

ai-up: gateway-start
    @echo "OK AI workstation gateway is up"

ai-check: bootstrap-check
    @echo "OK AI workstation checks passed"

ai-down: gateway-stop
    @echo "OK AI workstation gateway is down"

bootstrap-check: check-yaml gateway-models gateway-health
    echo "OK bootstrap check passed"

models:
    @ollama list

model-aliases:
    @grep -n "ollama/" config/gateway/litellm/config.local.yaml

eval-model-fitness:
    @test -n "{{ gateway_key }}" || (echo "FAIL LITELLM_MASTER_KEY is not set" && exit 8)
    @mkdir -p tmp
    @PROMPTFOO_EVAL_TIMEOUT_MS=1200000 promptfoo eval \
      -c config/evals/model-fitness/promptfooconfig.yaml \
      --max-concurrency 1 \
      --no-cache \
      -o tmp/model-fitness-results.json

eval-model-fitness-mlx:
    @mkdir -p tmp
    @.venv/bin/python tools/evals/run_mlx_model_fitness.py

mlx-up:
    @just mlx-down
    @mkdir -p tmp
    @nohup .venv/bin/python -m mlx_lm server \
      --model mlx-community/Llama-3.2-3B-Instruct-4bit \
      --host 0.0.0.0 \
      --port 8080 \
      > tmp/mlx-fast-server.log 2>&1 &
    @nohup .venv/bin/python -m mlx_lm server \
      --model lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit \
      --host 0.0.0.0 \
      --port 8081 \
      > tmp/mlx-capable-server.log 2>&1 &
    @nohup .venv/bin/python -m mlx_lm server \
      --model lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit \
      --host 0.0.0.0 \
      --port 8082 \
      > tmp/mlx-code-server.log 2>&1 &
    @echo "OK MLX servers starting"

mlx-check:
    @lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null && echo "OK mlx fast server listening on 8080" || (echo "FAIL mlx fast server not listening on 8080" && exit 8)
    @lsof -nP -iTCP:8081 -sTCP:LISTEN >/dev/null && echo "OK mlx capable server listening on 8081" || (echo "FAIL mlx capable server not listening on 8081" && exit 8)
    @lsof -nP -iTCP:8082 -sTCP:LISTEN >/dev/null && echo "OK mlx code server listening on 8082" || (echo "FAIL mlx code server not listening on 8082" && exit 8)

mlx-down:
    @pkill -f "mlx_lm server.*--port 8080" 2>/dev/null || true
    @pkill -f "mlx_lm server.*--port 8081" 2>/dev/null || true
    @pkill -f "mlx_lm server.*--port 8082" 2>/dev/null || true
    @echo "OK MLX servers stopped"
