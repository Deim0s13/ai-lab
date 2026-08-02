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

workstation_profile := env_var_or_default("AI_LAB_PROFILE", "macos-work")
podman_machine := env_var_or_default("AI_LAB_PODMAN_MACHINE", "podman-machine-default")
omlx_log := env_var("HOME") + "/.omlx/logs/server.log"
workstation_env_file := "containers/librechat/.env." + workstation_profile + ".local"

omlx_command := env_var_or_default("AI_LAB_OMLX_COMMAND", env_var("HOME") + "/.omlx/bin/omlx")
omlx_settings := env_var("HOME") + "/.omlx/settings.json"
omlx_url := "http://127.0.0.1:8000"

ui_profile := workstation_profile
ui_directory := "containers/librechat"
ui_env_file := workstation_env_file
ui_compose_file := ui_directory + "/compose.yaml"
ui_project := "ai-lab-librechat-" + ui_profile
ui_url := "http://127.0.0.1:3080"

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------

default:
    just --list

# ------------------------------------------------------------------------------
# Capability imports
# ------------------------------------------------------------------------------

import 'tools/just/evaluations.just'
import 'tools/just/gateway.just'
import 'tools/just/runtimes.just'
import 'tools/just/ui.just'
import 'tools/just/workstation.just'
