# AI Command

The `ai` command is the user-facing entrypoint for the AI Dev Workstation.

It provides a simple way to use the local AI workstation without needing to remember lower-level `just` commands for starting MLX servers, starting the LiteLLM gateway, or checking routes.

The intended experience is simple: use `ai` for daily AI work, and use `just` for operator and maintenance tasks.

## Command Role

The project has two command layers:

| Layer  | Purpose                                                                                       |
| ------ | --------------------------------------------------------------------------------------------- |
| `ai`   | User-facing entrypoint for daily AI use                                                       |
| `just` | Operator/foundation layer for gateway lifecycle, MLX lifecycle, diagnostics and model fitness |

The `ai` command delegates foundation tasks to existing `just` recipes. It should not reimplement the gateway or MLX lifecycle logic.

## Basic Usage

Start or check the local AI workstation:

    ai

Ask a question using the default fast route:

    ai ask Explain what this command does

Ask using a specific mode:

    ai ask --mode capable Compare these two implementation options

Use a shortcut command:

    ai code Review this shell command for quoting issues

List available gateway routes:

    ai routes

Check workstation status:

    ai status

Show the active profile:

    ai profile

Stop the local gateway and MLX servers:

    ai down

## Prompt Input

The `ai` command accepts prompts in three ways.

Use a simple unquoted prompt:

    ai ask --mode code Review this command

Use a quoted prompt:

    ai ask --mode capable "Compare these two implementation options"

Use stdin:

    echo "Review this command: podman rm -f test" | ai code

Use a prompt plus stdin:

    cat justfile | ai ask --mode code Review this file for obvious issues

Simple prompts do not need quotes. Prompts with shell-special characters should use quotes or stdin.

## Modes and Routes

`ai ask` supports explicit mode selection.

| Mode      | Route               | Intended use                                         |
| --------- | ------------------- | ---------------------------------------------------- |
| `fast`    | `local-fast`        | Default daily questions and quick responses          |
| `capable` | `local-capable-mlx` | Longer explanations, planning and trade-off analysis |
| `code`    | `local-code-mlx`    | Coding, command and configuration assistance         |

Examples:

    ai ask --mode fast Summarise this in three bullets
    ai ask --mode capable Compare these options
    ai ask --mode code Review this command

The shortcut commands map to the same routes:

| Command      | Route               |
| ------------ | ------------------- |
| `ai fast`    | `local-fast`        |
| `ai capable` | `local-capable-mlx` |
| `ai code`    | `local-code-mlx`    |

## Status

`ai status` provides a one-glance view of the workstation.

Run:

    ai status

Example output:

    AI Dev Workstation Status

    Profile:    macos-work
    Posture:    local-first
    Gateway:    running
    Local:      fast (ready), capable (ready), code (ready)
    Frontier:   not configured
    Routes:     local-fast, local-capable-mlx, local-code-mlx
    Last route: not recorded yet

The purpose of `ai status` is to give confidence that the local workstation is ready before starting work.

## Profile Visibility

The `ai` command shows the active workstation profile.

Run:

    ai profile

Example output:

    AI Dev Workstation Profile

    Active profile:   macos-work
    Profile file:     profiles/macos-work/profile.yaml
    Profile status:   found
    Routing posture:  local-first
    Gateway:          local LiteLLM
    Frontier:         not configured

The active profile is read from `AI_LAB_PROFILE`.

If `AI_LAB_PROFILE` is not set, the default profile is:

    macos-work

Override the profile for a single command:

    AI_LAB_PROFILE=windows-personal ai profile

Profile switching is not implemented yet.

Future profile switching should be explicit:

    ai profile use macos-work
    ai profile use windows-personal

Profile context should be visible and deliberate so work and personal routing postures are not mixed accidentally.

## Routes

List available gateway routes:

    ai routes

Current route dry-run support is not implemented yet.

Future route testing should support:

    ai routes test Review this shell command
    ai routes test --mode code Review this shell command

The dry run should show:

- selected mode
- route that would be used
- backend model, where known
- whether the route is currently reachable

## Degraded-Mode Errors

The `ai` command should make common failures recoverable.

It should tell the user:

- what failed
- what to run next
- where to look for logs if further investigation is needed

Examples:

    LiteLLM gateway is not reachable.
    Try: just ai-up
    Logs: podman logs ai-lab-litellm

    MLX local model servers are not ready.
    Try: just mlx-up
    Logs: just mlx-logs

    Python runtime not found: .venv/bin/python
    Try: python -m venv .venv && .venv/bin/pip install -r requirements.txt

The CLI should keep error messages short and actionable. Detailed investigation should stay in existing `just` and log commands.

## Operator Commands

Use `just` for operator and maintenance workflows.

Examples:

    just ai-up
    just ai-down
    just mlx-up
    just mlx-check
    just mlx-logs
    just model-fitness-review

The `ai` command is for daily use. `just` remains the foundation layer.

## What `ai` Should Handle

The `ai` command should make the common path simple.

It should:

- set a local development default for `LITELLM_MASTER_KEY` if one is not already set
- start or check MLX servers by calling existing `just` recipes
- start or check the LiteLLM gateway by calling existing `just` recipes
- send prompts through LiteLLM
- keep model route selection explicit and understandable
- show the active profile and routing posture
- fail clearly when required tools or runtimes are missing

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

## CLI Feature Roadmap

The `ai` command should evolve from a thin entrypoint into a useful local workstation interface.

The goal is not to hide the foundations. The goal is to make the foundations easier to use, inspect and trust.

### Implemented or in progress

| Capability                                   | Status      |
| -------------------------------------------- | ----------- |
| `ai` entrypoint                              | Implemented |
| `ai ask`, `ai fast`, `ai capable`, `ai code` | Implemented |
| `ai ask --mode`                              | Implemented |
| Unquoted, quoted and stdin prompt input      | Implemented |
| `ai status` dashboard                        | Implemented |
| `ai profile` visibility                      | Implemented |
| Actionable degraded-mode errors              | Implemented |
| `ai routes`                                  | Implemented |

### Planned

| Capability                             | Purpose                                                     |
| -------------------------------------- | ----------------------------------------------------------- |
| `ai routes test`                       | Show what route would handle a prompt before sending it     |
| `ai history`                           | Show recent prompts, routes, models and latency             |
| `ai feedback`                          | Capture whether a response was good or bad                  |
| local-first escalation acknowledgement | Make frontier escalation visible and deliberate             |
| profile switching                      | Allow explicit switching between work and personal postures |

### Deferred

The following remain deferred until the basic CLI experience is stable:

- semantic routing
- provider fallback
- autonomous agents
- file editing
- RAG
- MCP server design
- desktop UI
