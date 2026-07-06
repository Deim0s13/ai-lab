# AI Command

The `ai` command is the user-facing entrypoint for the AI Dev Workstation.

It provides a simpler way to use the local AI workstation without needing to remember the lower-level `just` commands for starting MLX servers, starting the LiteLLM gateway or checking routes.

The intended experience is similar in spirit to tools like Claude Code: type one command to enter or use the local AI environment, while the tool handles the required local setup.

## Command Role

The project has two command layers:

| Layer | Purpose |
|---|---|
| `ai` | User-facing entrypoint for daily AI use |
| `just` | Operator/foundation layer for gateway lifecycle, MLX lifecycle, diagnostics and model fitness |

The `ai` command should delegate foundation tasks to existing `just` recipes. It should not reimplement the gateway or MLX lifecycle logic.

## Basic Usage

Start or check the local AI workstation:

    ai

Ask a quick question using the default daily route:

    ai ask "Explain what this command does"

Use the fast local route:

    ai fast "Summarise this in three bullets"

Use the capable local route:

    ai capable "Compare these two implementation options"

Use the code-focused local route:

    ai code "Review this shell command for quoting issues"

List available gateway routes:

    ai routes

Check workstation status:

    ai status

Stop the local gateway and MLX servers:

    ai down

## Route Mapping

| Command | Route | Intended use |
|---|---|---|
| `ai ask` | `local-fast` | Default daily questions |
| `ai fast` | `local-fast-mlx` | Fast local responses |
| `ai capable` | `local-capable-mlx` | Longer explanations, planning and trade-off analysis |
| `ai code` | `local-code-mlx` | Coding, command and configuration assistance |
| `ai routes` | none | Lists LiteLLM gateway routes |
| `ai status` | none | Checks local workstation readiness |
| `ai down` | none | Stops local services |

## What `ai` Should Handle

The `ai` command should make the common path simple.

It should:

- set a local development default for `LITELLM_MASTER_KEY` if one is not already set
- start or check MLX servers by calling existing `just` recipes
- start or check the LiteLLM gateway by calling existing `just` recipes
- send prompts through LiteLLM
- keep model route selection explicit and understandable
- fail clearly when required tools are missing

## What `ai` Should Not Do Yet

The first version of `ai` should stay small.

It should not yet implement:

- semantic routing
- provider fallback
- file editing
- agent workflows
- RAG
- background scheduling
- a desktop UI
- a replacement for `just`

## Operator Commands

Use `just` for operator and maintenance workflows.

Examples:

    just ai-up
    just ai-down
    just mlx-up
    just mlx-check
    just model-fitness-review

The `ai` command is for daily use. `just` remains the foundation layer.
