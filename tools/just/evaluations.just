# ------------------------------------------------------------------------------
# Validation
# ------------------------------------------------------------------------------

check-yaml:
    @.venv/bin/python -c 'import yaml; from pathlib import Path; paths=list(sorted(Path("config").rglob("*.yaml"))) + list(sorted(Path("profiles").rglob("*.yaml"))); [yaml.safe_load(p.open()) for p in paths]; [print(f"OK {p}") for p in paths]'

# ------------------------------------------------------------------------------
# Model fitness evaluations
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
    @echo "== Running Ollama/LiteLLM model fitness eval =="
    @just eval-model-fitness
    @echo "== Running direct MLX model fitness eval =="
    @just eval-model-fitness-mlx
    @echo "OK model fitness review completed"
