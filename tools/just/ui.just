# ------------------------------------------------------------------------------
# Browser chat UI lifecycle
# ------------------------------------------------------------------------------

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
