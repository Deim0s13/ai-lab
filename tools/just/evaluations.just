# ------------------------------------------------------------------------------
# Validation
# ------------------------------------------------------------------------------

check-yaml:
    @.venv/bin/python -c 'import yaml; from pathlib import Path; paths=list(sorted(Path("config").rglob("*.yaml"))) + list(sorted(Path("profiles").rglob("*.yaml"))); [yaml.safe_load(p.open()) for p in paths]; [print(f"OK {p}") for p in paths]'

# ------------------------------------------------------------------------------
# Model fitness evaluations
# ------------------------------------------------------------------------------

eval-model-fitness:
    @if ! key="$( \
        source tools/ai/secrets.sh; \
        resolve_profile_secret \
          "{{ workstation_profile }}" \
          LITELLM_EVAL_KEY \
          "{{ client_secret_fallback_file }}" \
      )"; then \
        exit 8; \
      fi; \
      mkdir -p tmp; \
      status_code=0; \
      LITELLM_EVAL_KEY="$key" \
      PROMPTFOO_EVAL_TIMEOUT_MS={{ promptfoo_timeout_ms }} \
        promptfoo eval \
          -c config/evals/model-fitness/promptfooconfig.yaml \
          --max-concurrency 1 \
          --no-cache \
          -o tmp/model-fitness-results.json \
        || status_code=$?; \
      unset key; \
      exit "$status_code"

eval-model-fitness-mlx:
    @mkdir -p tmp
    @.venv/bin/python tools/evals/run_mlx_model_fitness.py

eval-gateway-models:
    @if ! key="$( \
        source tools/ai/secrets.sh; \
        resolve_profile_secret \
          "{{ workstation_profile }}" \
          LITELLM_EVAL_KEY \
          "{{ client_secret_fallback_file }}" \
      )"; then \
        exit 8; \
      fi; \
      LITELLM_API_KEY="$key" just gateway-models || exit $?; \
      LITELLM_API_KEY="$key" just gateway-mlx-models || exit $?; \
      echo "== Evaluation-visible gateway routes =="; \
      LITELLM_API_KEY="$key" just gateway-routes || exit $?; \
      unset key

model-fitness-review:
    @echo "== Checking MLX servers =="
    @just mlx-check
    @echo "== Checking YAML config =="
    @just check-yaml
    @echo "== Checking LiteLLM gateway routes with scoped evaluation access =="
    @just eval-gateway-models
    @echo "== Running Ollama/LiteLLM model fitness eval =="
    @just eval-model-fitness
    @echo "== Running direct MLX model fitness eval =="
    @just eval-model-fitness-mlx
    @echo "OK model fitness review completed"
