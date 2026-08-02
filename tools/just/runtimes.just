# ------------------------------------------------------------------------------
# Podman readiness
# ------------------------------------------------------------------------------

podman-native-check:
    @podman info >/dev/null 2>&1 \
      && echo "OK native Podman API is ready" \
      || (echo "FAIL native Podman API is unavailable" && exit 8)

podman-compose-check:
    @if ! socket_path="$(podman machine inspect "{{ podman_machine }}" 2>/dev/null \
        | jq -er '.[0].ConnectionInfo.PodmanSocket.Path | select(type == "string" and length > 0)')"; then \
      echo "FAIL Podman Compose socket path could not be discovered"; \
      exit 8; \
    fi; \
    if [[ ! -S "$socket_path" ]]; then \
      echo "FAIL Podman Compose socket is unavailable"; \
      exit 8; \
    fi; \
    if ! response="$(curl \
        --max-time 2 \
        --unix-socket "$socket_path" \
        -fsS \
        http://localhost/_ping \
        2>/dev/null)"; then \
      echo "FAIL Podman Compose API is unavailable"; \
      exit 8; \
    fi; \
    if [[ "$response" != "OK" ]]; then \
      echo "FAIL Podman Compose API returned an unexpected response"; \
      exit 8; \
    fi; \
    echo "OK Podman Compose API is ready"

podman-ready:
    @if just podman-native-check >/dev/null 2>&1 \
        && just podman-compose-check >/dev/null 2>&1; then \
      echo "OK Podman is ready"; \
      exit 0; \
    fi; \
    machine_state="$(podman machine inspect "{{ podman_machine }}" | jq -er '.[0].State')"; \
    if [[ "$machine_state" != "running" ]]; then \
      echo "INFO Starting Podman machine {{ podman_machine }}"; \
      podman machine start \
        --quiet \
        --update-connection \
        "{{ podman_machine }}" \
        || { echo "FAIL Podman machine could not be started"; exit 8; }; \
    else \
      echo "INFO Waiting for Podman to recover after wake"; \
    fi; \
    for attempt in {1..30}; do \
      if just podman-native-check >/dev/null 2>&1 \
          && just podman-compose-check >/dev/null 2>&1; then \
        echo "OK Podman is ready"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "INFO Podman is running but its APIs remain unavailable"; \
    echo "INFO Restarting {{ podman_machine }}; this interrupts other Podman containers"; \
    podman machine stop "{{ podman_machine }}" \
      || { echo "FAIL Podman machine could not be stopped"; exit 8; }; \
    podman machine start \
      --quiet \
      --update-connection \
      "{{ podman_machine }}" \
      || { echo "FAIL Podman machine could not be restarted"; exit 8; }; \
    for attempt in {1..60}; do \
      if just podman-native-check >/dev/null 2>&1 \
          && just podman-compose-check >/dev/null 2>&1; then \
        echo "OK Podman recovered successfully"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "FAIL Podman APIs did not recover"; \
    echo "Try: podman machine stop {{ podman_machine }}"; \
    echo "Then: podman machine start {{ podman_machine }}"; \
    exit 8

# ------------------------------------------------------------------------------
# Ollama runtime
# ------------------------------------------------------------------------------

ollama-check:
    @ollama list >/dev/null 2>&1 \
      && echo "OK Ollama runtime is ready" \
      || (echo "FAIL Ollama runtime is unavailable" && exit 8)

ollama-up:
    @if ollama list >/dev/null 2>&1; then \
      echo "OK Ollama runtime is already ready"; \
      exit 0; \
    fi; \
    echo "INFO Restarting Ollama through Homebrew services"; \
    brew services restart ollama >/dev/null \
      || { echo "FAIL Homebrew could not restart Ollama"; exit 8; }; \
    for attempt in {1..30}; do \
      if ollama list >/dev/null 2>&1; then \
        echo "OK Ollama runtime is ready"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "FAIL Ollama did not become ready"; \
    echo "Try: brew services info ollama"; \
    exit 8

models:
    @ollama list

model-aliases:
    @grep -n "ollama/" config/gateway/litellm/config.local.yaml || true
    @grep -n "openai/" config/gateway/litellm/config.local.yaml || true

# ------------------------------------------------------------------------------
# Direct MLX model-fitness runtime
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

# ------------------------------------------------------------------------------
# Managed oMLX runtime
# ------------------------------------------------------------------------------

omlx-check:
    @omlx_key="${OMLX_API_KEY:-}"; \
      if [[ -z "${omlx_key}" && -f "{{ omlx_settings }}" ]]; then \
        omlx_key="$(jq -r '.auth.api_key // empty' "{{ omlx_settings }}")"; \
      fi; \
      if [[ -z "${omlx_key}" ]]; then \
        echo "FAIL oMLX API key is unavailable"; \
        exit 8; \
      fi; \
      if ! models="$(curl \
          --max-time 3 \
          -fsS \
          -H "Authorization: Bearer ${omlx_key}" \
          "{{ omlx_url }}/v1/models")"; then \
        echo "FAIL oMLX API is unavailable"; \
        exit 8; \
      fi; \
      if ! jq -e \
          --arg fast "mlx-community--Llama-3.2-3B-Instruct-4bit" \
          --arg capable "lmstudio-community--Qwen3-30B-A3B-Instruct-2507-MLX-4bit" \
          --arg code "lmstudio-community--Qwen3-Coder-30B-A3B-Instruct-MLX-5bit" \
          '([.data[].id] | index($fast)) != null and ([.data[].id] | index($capable)) != null and ([.data[].id] | index($code)) != null' \
          <<<"${models}" >/dev/null; then \
        echo "FAIL oMLX is missing one or more selected models"; \
        exit 8; \
      fi; \
      echo "OK oMLX runtime and selected models are ready"

omlx-up:
    @if just omlx-check >/dev/null 2>&1; then \
      echo "OK oMLX runtime is already ready"; \
      exit 0; \
    fi; \
    "{{ omlx_command }}" start \
      || { echo "FAIL oMLX could not be started"; exit 8; }; \
    for attempt in {1..60}; do \
      if just omlx-check >/dev/null 2>&1; then \
        echo "OK oMLX runtime is ready"; \
        exit 0; \
      fi; \
      sleep 1; \
    done; \
    echo "FAIL oMLX did not become ready"; \
    exit 8

omlx-down:
    @"{{ omlx_command }}" stop \
      || { echo "FAIL oMLX could not be stopped"; exit 8; }
    @echo "OK oMLX runtime stopped"

omlx-logs:
    @echo "== oMLX server log =="
    @tail -100 "{{ omlx_log }}" 2>/dev/null \
      || echo "INFO oMLX logs are unavailable"
