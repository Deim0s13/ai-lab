# ------------------------------------------------------------------------------
# Workstation validation baseline
# ------------------------------------------------------------------------------

validation-static:
    @bash -n bin/ai tools/ai/*.sh
    @just --fmt --check
    @just check-yaml
    @just opencode-config-check
    @git diff --check
    @echo "OK static workstation validation passed"

validation-live: validation-static
    @if [[ "{{ workstation_profile }}" != "macos-work" ]]; then \
      echo "FAIL live validation currently supports macos-work only"; \
      exit 8; \
    fi
    @just workstation-preflight
    @just workstation-status
    @just ollama-check
    @just omlx-check
    @just ui-check
    @just opencode-check
    @echo "OK live workstation validation passed for {{ workstation_profile }}"
