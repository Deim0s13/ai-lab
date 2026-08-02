# ------------------------------------------------------------------------------
# Browser chat UI lifecycle
# ------------------------------------------------------------------------------

ui-check:
    @just check-yaml >/dev/null
    @test -f "{{ ui_env_file }}" \
      || (echo "FAIL missing {{ ui_env_file }}" && exit 8)
    @git check-ignore -q "{{ ui_env_file }}" \
      || (echo "FAIL {{ ui_env_file }} is not ignored by Git" && exit 8)
    @.venv/bin/python -c 'import yaml; from pathlib import Path; compose=yaml.safe_load(Path("containers/librechat/compose.yaml").read_text()); config=yaml.safe_load(Path("containers/librechat/librechat.yaml").read_text()); api=compose["services"]["api"]; custom=config["endpoints"]["custom"]; assert api["environment"]["ENDPOINTS"] == "custom"; assert api["ports"] == ["127.0.0.1:3080:3080"]; assert api["restart"] == "no"; assert set(config["endpoints"]) == {"custom"}; assert len(custom) == 1; assert custom[0]["baseURL"] == "http://host.containers.internal:4000/v1"; assert custom[0]["models"]["fetch"] is True; print("OK LibreChat committed configuration is gateway-only and localhost-bound")'
    @just podman-compose-check >/dev/null 2>&1 \
      || (echo "FAIL Podman Compose API is unavailable; try: just workstation-up" && exit 8)
    @podman compose \
      --env-file "{{ ui_env_file }}" \
      --project-name "{{ ui_project }}" \
      --file "{{ ui_compose_file }}" \
      config >/dev/null 2>&1 \
      || (echo "FAIL LibreChat Compose configuration is invalid" && exit 8)
    @just ui-status >/dev/null 2>&1 \
      || (echo "FAIL LibreChat is unavailable; try: just workstation-up" && exit 8)
    @binding="$(podman compose \
        --env-file "{{ ui_env_file }}" \
        --project-name "{{ ui_project }}" \
        --file "{{ ui_compose_file }}" \
        port api 3080 2>/dev/null \
        | tail -n 1)"; \
      if [[ "$binding" != "127.0.0.1:3080" ]]; then \
        echo "FAIL LibreChat has unexpected runtime binding: ${binding:-unavailable}"; \
        exit 8; \
      fi; \
      echo "OK LibreChat runtime is bound to 127.0.0.1:3080"
    @key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "{{ ui_env_file }}")"; \
      if [[ -z "$key" || "$key" == "replace-me" ]]; then \
        echo "FAIL LITELLM_MASTER_KEY is unavailable"; \
        exit 8; \
      fi; \
      if ! LITELLM_MASTER_KEY="$key" just gateway-ready >/dev/null 2>&1; then \
        echo "FAIL LiteLLM gateway is unavailable"; \
        exit 8; \
      fi; \
      if ! models="$(curl \
          --max-time 3 \
          -fsS \
          "{{ gateway_url }}/v1/models" \
          -H "Authorization: Bearer ${key}")"; then \
        echo "FAIL LiteLLM model aliases are unavailable"; \
        exit 8; \
      fi; \
      if ! jq -e \
          '([.data[].id] | index("local-fast")) != null and ([.data[].id] | index("local-fast-mlx")) != null and ([.data[].id] | index("local-capable-mlx")) != null and ([.data[].id] | index("local-code-mlx")) != null' \
          <<<"$models" >/dev/null; then \
        echo "FAIL one or more required LiteLLM model aliases are unavailable"; \
        exit 8; \
      fi; \
      echo "OK required LiteLLM model aliases are available"
    @echo "OK LibreChat UI validation passed for profile {{ ui_profile }}"

ui-up:
    @test -f "{{ ui_env_file }}" || (echo "FAIL missing {{ ui_env_file }}; copy {{ ui_directory }}/.env.example and populate it" && exit 8)
    @podman compose \
      --env-file "{{ ui_env_file }}" \
      --project-name "{{ ui_project }}" \
      --file "{{ ui_compose_file }}" \
      up -d
    @for attempt in {1..150}; do \
      if curl -fsS "{{ ui_url }}" >/dev/null 2>&1; then \
        echo "OK LibreChat is ready at {{ ui_url }} for profile {{ ui_profile }}"; \
        exit 0; \
      fi; \
      sleep 2; \
    done; \
    echo "FAIL LibreChat did not become ready at {{ ui_url }}"; \
    podman compose \
      --env-file "{{ ui_env_file }}" \
      --project-name "{{ ui_project }}" \
      --file "{{ ui_compose_file }}" \
      ps; \
    podman compose \
      --env-file "{{ ui_env_file }}" \
      --project-name "{{ ui_project }}" \
      --file "{{ ui_compose_file }}" \
      logs --tail 100 api; \
    exit 8

ui-status:
    @test -f "{{ ui_env_file }}" || (echo "FAIL missing {{ ui_env_file }}; copy {{ ui_directory }}/.env.example and populate it" && exit 8)
    @podman compose \
      --env-file "{{ ui_env_file }}" \
      --project-name "{{ ui_project }}" \
      --file "{{ ui_compose_file }}" \
      ps
    @if curl -fsS "{{ ui_url }}" >/dev/null 2>&1; then \
      echo "OK LibreChat is ready at {{ ui_url }} for profile {{ ui_profile }}"; \
    else \
      echo "FAIL LibreChat is not ready at {{ ui_url }} for profile {{ ui_profile }}"; \
      exit 8; \
    fi

ui-logs:
    @test -f "{{ ui_env_file }}" || (echo "FAIL missing {{ ui_env_file }}; copy {{ ui_directory }}/.env.example and populate it" && exit 8)
    @podman compose \
      --env-file "{{ ui_env_file }}" \
      --project-name "{{ ui_project }}" \
      --file "{{ ui_compose_file }}" \
      logs --tail 100

ui-down:
    @test -f "{{ ui_env_file }}" || (echo "FAIL missing {{ ui_env_file }}; copy {{ ui_directory }}/.env.example and populate it" && exit 8)
    @podman compose \
      --env-file "{{ ui_env_file }}" \
      --project-name "{{ ui_project }}" \
      --file "{{ ui_compose_file }}" \
      down --remove-orphans
    @echo "OK LibreChat stopped for profile {{ ui_profile }}; persistent data retained"
