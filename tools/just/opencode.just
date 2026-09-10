# ------------------------------------------------------------------------------
# OpenCode installation and configuration
# ------------------------------------------------------------------------------

opencode_manifest := "packages/macos-work/opencode.env"
opencode_config := "config/opencode/opencode.json"
opencode_env_file := "config/opencode/.env." + workstation_profile + ".local"
opencode_binary := env_var("HOME") + "/.opencode/bin/opencode"

opencode-config-check:
    @test -f "{{ opencode_manifest }}" \
      || (echo "FAIL missing {{ opencode_manifest }}" && exit 8)
    @test -f "{{ opencode_config }}" \
      || (echo "FAIL missing {{ opencode_config }}" && exit 8)
    @test -f "config/opencode/.env.example" \
      || (echo "FAIL missing config/opencode/.env.example" && exit 8)
    @example_key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "config/opencode/.env.example")"; \
      if [[ "$example_key" != "replace-me" ]]; then \
        echo "FAIL config/opencode/.env.example must contain the replace-me placeholder"; \
        exit 8; \
      fi
    @bash -n "{{ opencode_manifest }}" \
      || (echo "FAIL invalid OpenCode package manifest" && exit 8)
    @source "{{ opencode_manifest }}"; \
      for variable in \
        OPENCODE_VERSION \
        OPENCODE_PLATFORM \
        OPENCODE_ARCHIVE \
        OPENCODE_SHA256 \
        OPENCODE_INSTALL_DIR; do \
        if [[ -z "${!variable:-}" ]]; then \
          echo "FAIL ${variable} is missing from {{ opencode_manifest }}"; \
          exit 8; \
        fi; \
      done; \
      if [[ ! "$OPENCODE_SHA256" =~ ^[0-9a-f]{64}$ ]]; then \
        echo "FAIL OPENCODE_SHA256 is invalid"; \
        exit 8; \
      fi; \
      echo "OK OpenCode package manifest selects version ${OPENCODE_VERSION}"
    @jq -e \
      '.model == "ai-lab/local-code" \
       and .small_model == "ai-lab/local-code" \
       and .default_agent == "plan" \
       and .autoupdate == false \
       and .share == "disabled" \
       and .enabled_providers == ["ai-lab"] \
       and (.provider | keys) == ["ai-lab"] \
       and .provider["ai-lab"].npm == "@ai-sdk/openai-compatible" \
       and .provider["ai-lab"].options.baseURL == "http://127.0.0.1:4000/v1" \
       and .provider["ai-lab"].options.apiKey == "{env:LITELLM_MASTER_KEY}" \
       and (.provider["ai-lab"].models | keys) == ["local-code"] \
       and .permission["*"] == "ask" \
       and .permission.edit == "ask" \
       and .permission.task == "deny" \
       and .permission.skill == "deny" \
       and .permission.webfetch == "deny" \
       and .permission.websearch == "deny" \
       and .permission.external_directory == "deny" \
       and .permission["mcp_*"] == "deny" \
       and (.mcp | length) == 0 \
       and (.plugin | length) == 0' \
      "{{ opencode_config }}" >/dev/null \
      || (echo "FAIL OpenCode configuration violates the macos-work policy" && exit 8)
    @git check-ignore -q "{{ opencode_env_file }}" \
      || (echo "FAIL {{ opencode_env_file }} is not ignored by Git" && exit 8)
    @if git check-ignore -q "config/opencode/.env.example"; then \
      echo "FAIL config/opencode/.env.example is ignored by Git"; \
      exit 8; \
    fi
    @echo "OK OpenCode committed configuration is gateway-only and conservative"

opencode-install: opencode-config-check
    @if [[ "{{ workstation_profile }}" != "macos-work" ]]; then \
      echo "FAIL OpenCode installation currently supports macos-work only"; \
      exit 8; \
    fi
    @source "{{ opencode_manifest }}"; \
      if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then \
        echo "FAIL OpenCode package requires Apple Silicon macOS"; \
        exit 8; \
      fi; \
      binary="${OPENCODE_INSTALL_DIR}/opencode"; \
      installed_version=""; \
      if [[ -x "$binary" ]]; then \
        installed_version="$(OPENCODE_DISABLE_AUTOUPDATE=true "$binary" --version 2>/dev/null || true)"; \
      fi; \
      if [[ "$installed_version" == "$OPENCODE_VERSION" ]]; then \
        echo "OK OpenCode ${OPENCODE_VERSION} is already installed"; \
        exit 0; \
      fi; \
      tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ai-lab-opencode.XXXXXX")"; \
      trap 'rm -rf "$tmp_dir"' EXIT; \
      archive_path="${tmp_dir}/${OPENCODE_ARCHIVE}"; \
      release_url="https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/${OPENCODE_ARCHIVE}"; \
      echo "INFO Downloading OpenCode ${OPENCODE_VERSION}"; \
      curl -fsSL "$release_url" -o "$archive_path" \
        || { echo "FAIL OpenCode download failed"; exit 8; }; \
      actual_sha="$(shasum -a 256 "$archive_path" | awk '{print $1}')"; \
      if [[ "$actual_sha" != "$OPENCODE_SHA256" ]]; then \
        echo "FAIL OpenCode archive checksum does not match"; \
        exit 8; \
      fi; \
      mkdir -p "${tmp_dir}/unpacked" "$OPENCODE_INSTALL_DIR"; \
      unzip -q "$archive_path" -d "${tmp_dir}/unpacked"; \
      test -x "${tmp_dir}/unpacked/opencode" \
        || { echo "FAIL OpenCode archive does not contain the expected executable"; exit 8; }; \
      install -m 0755 \
        "${tmp_dir}/unpacked/opencode" \
        "${OPENCODE_INSTALL_DIR}/opencode"; \
      installed_version="$(OPENCODE_DISABLE_AUTOUPDATE=true "${OPENCODE_INSTALL_DIR}/opencode" --version)"; \
      if [[ "$installed_version" != "$OPENCODE_VERSION" ]]; then \
        echo "FAIL installed OpenCode version is ${installed_version}"; \
        exit 8; \
      fi; \
      echo "OK OpenCode ${installed_version} installed at ${OPENCODE_INSTALL_DIR}/opencode"

opencode-check: opencode-config-check
    @test -x "{{ opencode_binary }}" \
      || (echo "FAIL OpenCode is not installed; try: just opencode-install" && exit 8)
    @source "{{ opencode_manifest }}"; \
      installed_version="$(OPENCODE_DISABLE_AUTOUPDATE=true "{{ opencode_binary }}" --version 2>/dev/null || true)"; \
      if [[ "$installed_version" != "$OPENCODE_VERSION" ]]; then \
        echo "FAIL installed OpenCode version is ${installed_version:-unavailable}; expected ${OPENCODE_VERSION}"; \
        exit 8; \
      fi; \
      echo "OK OpenCode ${installed_version} is installed"
    @test -f "{{ opencode_env_file }}" \
      || (echo "FAIL missing {{ opencode_env_file }}; copy config/opencode/.env.example and populate it" && exit 8)
    @git check-ignore -q "{{ opencode_env_file }}" \
      || (echo "FAIL {{ opencode_env_file }} is not ignored by Git" && exit 8)
    @key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "{{ opencode_env_file }}")"; \
      if [[ -z "$key" || "$key" == "replace-me" ]]; then \
        echo "FAIL LITELLM_MASTER_KEY is unavailable"; \
        exit 8; \
      fi; \
      if ! LITELLM_MASTER_KEY="$key" just gateway-ready >/dev/null 2>&1; then \
        echo "FAIL LiteLLM gateway is unavailable; try: just workstation-up"; \
        exit 8; \
      fi; \
      config_content="$(jq -c . "{{ opencode_config }}")"; \
      if ! models="$( \
          LITELLM_MASTER_KEY="$key" \
          OPENCODE_DISABLE_AUTOUPDATE=true \
          OPENCODE_CONFIG_CONTENT="$config_content" \
          OPENCODE_DISABLE_DEFAULT_PLUGINS=true \
          OPENCODE_DISABLE_CLAUDE_CODE=true \
          OPENCODE_DISABLE_LSP_DOWNLOAD=true \
          OPENCODE_DISABLE_MODELS_FETCH=true \
          "{{ opencode_binary }}" --pure models ai-lab 2>/dev/null \
        )"; then \
        echo "FAIL OpenCode could not load the AI Lab provider"; \
        exit 8; \
      fi; \
      if ! grep -qx 'ai-lab/local-code' <<<"$models"; then \
        echo "FAIL OpenCode does not list ai-lab/local-code"; \
        exit 8; \
      fi; \
      echo "OK OpenCode can select ai-lab/local-code through LiteLLM"

opencode-models:
    @test -f "{{ opencode_env_file }}" \
      || (echo "FAIL missing {{ opencode_env_file }}" && exit 8)
    @key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "{{ opencode_env_file }}")"; \
      if [[ -z "$key" || "$key" == "replace-me" ]]; then \
        echo "FAIL LITELLM_MASTER_KEY is unavailable"; \
        exit 8; \
      fi; \
      config_content="$(jq -c . "{{ opencode_config }}")"; \
      LITELLM_MASTER_KEY="$key" \
      OPENCODE_CONFIG_CONTENT="$config_content" \
      OPENCODE_DISABLE_DEFAULT_PLUGINS=true \
      OPENCODE_DISABLE_CLAUDE_CODE=true \
      OPENCODE_DISABLE_LSP_DOWNLOAD=true \
      OPENCODE_DISABLE_MODELS_FETCH=true \
      OPENCODE_DISABLE_AUTOUPDATE=true \
      "{{ opencode_binary }}" --pure models ai-lab

# ------------------------------------------------------------------------------
# OpenCode supervised workflow
# ------------------------------------------------------------------------------

opencode project=invocation_directory():
    @test -d "{{ project }}" \
      || (echo "FAIL OpenCode project directory does not exist: {{ project }}" && exit 8)
    @just opencode-check
    @key="$(awk '$0 ~ /^LITELLM_MASTER_KEY=/ { sub(/^LITELLM_MASTER_KEY=/, ""); sub(/\r$/, ""); print; exit }' "{{ opencode_env_file }}")"; \
      config_content="$(jq -c . "{{ opencode_config }}")"; \
      cd "{{ project }}"; \
      export LITELLM_MASTER_KEY="$key"; \
      export OPENCODE_CONFIG_CONTENT="$config_content"; \
      export OPENCODE_DISABLE_DEFAULT_PLUGINS=true; \
      export OPENCODE_DISABLE_CLAUDE_CODE=true; \
      export OPENCODE_DISABLE_LSP_DOWNLOAD=true; \
      export OPENCODE_DISABLE_MODELS_FETCH=true; \
      export OPENCODE_DISABLE_AUTOUPDATE=true; \
      exec "{{ opencode_binary }}" --pure .
