# CLI Habit Layer

The CLI habit layer is the day-to-day interface for the AI Dev Workstation.

It is intentionally thin. The project does not try to replace existing tools with custom code. Instead, it uses simple commands to orchestrate the local gateway, run checks, ask questions and inspect configuration.

## Purpose

The purpose of this layer is to make the workstation easy to use from a terminal.

The normal workflow should be:

- start the gateway
- check the workstation
- ask the local model
- inspect routing when needed
- stop the gateway

## Daily Workflow

Set the local LiteLLM key for the current terminal session:

    export LITELLM_MASTER_KEY=sk-local-dev

Start the local AI gateway:

    just ai-up

Run the workstation checks:

    just ai-check

Ask the local gateway a question:

    just ask "Say hello from the AI workstation in one short sentence."

Stop the local AI gateway:

    just ai-down

## Asking the Local Gateway

The first daily-use command is:

    just ask "Your question here"

This sends the prompt to the LiteLLM gateway using the local-fast gateway model group.

Current request path:

    just ask
      -> LiteLLM /v1/chat/completions
      -> local-fast
      -> Ollama
      -> local model

The command prints the assistant response in the terminal.

## Gateway Lifecycle

The daily lifecycle commands are:

    just ai-up
    just ai-check
    just ai-down

Lower-level gateway commands are also available:

    just gateway-start
    just gateway-wait
    just gateway-status
    just gateway-health
    just gateway-models
    just gateway-logs
    just gateway-stop

Use the daily commands for normal use. Use the lower-level commands when troubleshooting.

## Bootstrap Checks

Run:

    just bootstrap-check

or:

    just ai-check

The bootstrap check validates that:

- config and profile YAML can be parsed
- LiteLLM lists the local-fast model group
- LiteLLM reports a healthy local endpoint
- the gateway key is set without printing the value

## Routing Inspection

ai-route is an inspection-only command.

It explains configured route classes, gateway model groups and selected profile posture.

Example:

    tools/ai-route --profile macos-work --explain

It does not call:

- LiteLLM
- Ollama
- OpenAI
- Anthropic
- Gemini
- any other provider

Execution is delegated to LiteLLM or another configured gateway.

## Profiles

Profiles describe the posture of each workstation context.

Current profiles:

- macos-work
- windows-personal
- fedora-atomic

Examples:

    tools/ai-status --profile macos-work
    tools/ai-route --profile macos-work --explain

## Environment Variables

Required for local gateway use:

    export LITELLM_MASTER_KEY=sk-local-dev

Optional override:

    export AI_LAB_GATEWAY_URL=http://localhost:4000

The default gateway URL is:

    http://localhost:4000

## Current Default Model Group

The default local model group for the daily CLI workflow is:

    local-fast

The current proof backend for local-fast is an Ollama model behind LiteLLM.

The stable interface is the model group, not the specific local model. The local model can be replaced later without changing the daily command.

## Current Limitations

The CLI habit layer currently does not include:

- frontier provider routing
- semantic routing
- cost routing
- fallback routing
- RAG
- agents
- conversation memory
- streaming output
- prompt templates
- background startup
- automatic secret loading

These are future capabilities and should be added only when there is a clear need.

## Design Boundary

The CLI habit layer should stay thin.

Custom project commands may explain or orchestrate project-specific workflows, but generic execution, validation and routing should use existing tools where practical.

Current split:

- just: task orchestration
- curl: HTTP requests
- jq: JSON extraction
- LiteLLM: gateway execution
- Ollama: local model runtime
- ai-status: profile/status inspection
- ai-route: routing inspection

This keeps the workstation composable, replaceable and easy to rebuild.
