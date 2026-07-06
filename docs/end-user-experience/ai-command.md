# AI Command

The `ai` command is the user-facing entrypoint for the AI Dev Workstation.

It provides a simpler way to use the local AI workstation without needing to remember the lower-level `just` commands for starting MLX servers, starting the LiteLLM gateway or checking routes.

The intended experience is similar in spirit to tools like Claude Code: type one command to enter or use the local AI environment, while the tool handles the required local setup.

## Command Role

The project has two command layers:

| Layer  | Purpose                                                                                       |
| ------ | --------------------------------------------------------------------------------------------- |
| `ai`   | User-facing entrypoint for daily AI use                                                       |
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

| Command      | Route               | Intended use                                         |
| ------------ | ------------------- | ---------------------------------------------------- |
| `ai ask`     | `local-fast`        | Default daily questions                              |
| `ai fast`    | `local-fast-mlx`    | Fast local responses                                 |
| `ai capable` | `local-capable-mlx` | Longer explanations, planning and trade-off analysis |
| `ai code`    | `local-code-mlx`    | Coding, command and configuration assistance         |
| `ai routes`  | none                | Lists LiteLLM gateway routes                         |
| `ai status`  | none                | Checks local workstation readiness                   |
| `ai down`    | none                | Stops local services                                 |

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

## CLI Feature Roadmap

The `ai` command should evolve from a thin entrypoint into a useful local workstation interface.

The goal is not to hide the foundations. The goal is to make the foundations easier to use, inspect and trust.

### 1. Useful status

`ai status` should become a useful one-glance workstation dashboard, not just a health check.

It should show:

- active profile
- gateway state
- local runtime state
- loaded or reachable local models
- provider reachability
- current routing posture
- last routing decision, when available

Target experience:

    Profile:    macos-work
    Gateway:    running (local-only)
    Local:      local-fast, local-capable, local-code — ready
    Frontier:   not configured
    Last route: local_fast -> local-fast -> llama3.2:3b (2m ago)

The purpose of `ai status` is to give confidence that the workstation is ready before starting work.

Check workstation status:

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

### 2. Mode-based ask

`ai ask` should support a mode flag early.

The user should not need to understand internal route names for common overrides.

Target experience:

    ai ask "Summarise this"
    ai ask --mode fast "Summarise this quickly"
    ai ask --mode capable "Compare these options"
    ai ask --mode code "Review this command"

Initial modes:

| Mode    | Route             |
| ------- | ----------------- |
| fast    | local-fast        |
| capable | local-capable-mlx |
| code    | local-code-mlx    |

This keeps route selection understandable while still preserving the gateway-first design.

### 3. Route dry-run

`ai routes` should support a dry-run mode so the user can see what would happen before sending a prompt.

Target experience:

    ai routes
    ai routes test "Review this shell command"
    ai routes test --mode code "Review this shell command"

The dry-run should show:

- selected mode
- route that would be used
- backend model, where known
- whether the route is currently reachable

This closes the observability loop without requiring the user to inspect LiteLLM configuration directly.

### 4. Actionable degraded-mode errors

Failures should tell the user what to do next.

The CLI should avoid generic errors such as:

    ERROR: gateway not reachable

Prefer actionable messages:

    Gateway not reachable.
    Try: just gateway-start

    MLX code server is not listening on 8082.
    Try: just mlx-up
    Logs: just mlx-logs

    LITELLM_MASTER_KEY is not set.
    For local development, try:
      export LITELLM_MASTER_KEY=sk-local-dev

The goal is for degraded mode to feel recoverable.

### 5. Profile visibility and deliberate context switching

Profile context should be visible and deliberate.

The CLI should make it obvious which workstation profile is active and what routing posture it implies.

Target experience:

    ai profile

Example output:

    Active profile: macos-work
    Routing posture: local-first
    Gateway: local LiteLLM
    Frontier providers: not configured

Future profile switching should be explicit:

    ai profile use macos-work
    ai profile use windows-personal

The user should not accidentally route work prompts through a personal posture, or personal prompts through a work posture.

## Deferred

The following remain deferred until the basic CLI experience is stable:

- semantic routing
- provider fallback
- autonomous agents
- file editing
- RAG
- MCP server design
- desktop UI
