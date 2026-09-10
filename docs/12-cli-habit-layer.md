# CLI Habit Layer

The CLI habit layer is the day-to-day interface for the AI Dev Workstation.

It is intentionally thin. The project does not try to replace existing tools with custom code. Instead, it uses simple commands to orchestrate the local gateway, run checks, ask questions and inspect configuration.

## Purpose

The purpose of this layer is to make the workstation easy to use from a terminal.

The normal workflow should be:

- start or recover the workstation
- check the workstation
- ask the local model
- inspect routing when needed
- stop repo-managed workstation services when intended

## Daily Workflow

Start or recover the complete local workstation:

    ai

Check its authoritative status:

    ai status

Ask the local gateway a question:

    ai ask "Say hello from the AI workstation in one short sentence."

Stop repo-managed workstation services:

    ai down

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

## Workstation and Gateway Lifecycle

Use the unified workstation recipes for normal lifecycle operations:

    just workstation-up
    just workstation-status
    just workstation-logs
    just workstation-down

Lower-level gateway commands remain available for focused diagnostics:

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

- configuration and profile YAML can be parsed
- LiteLLM readiness responds successfully
- LiteLLM exposes the required stable model groups
- the gateway key is set without printing its value

Use `just gateway-health` when an explicit, bounded aggregate check of every configured backend is required.

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

## Repository-Aware Coding

Use `ai code` for a direct coding prompt. Use the selected OpenCode frontend when the task needs repository inspection, supervised edits or test execution:

```bash
just workstation-up
just opencode /path/to/project
```

OpenCode is an existing tool above the habit layer, not another custom command framework. It uses LiteLLM's stable `local-code` route and keeps `bin/ai` focused on thin prompt and routing workflows. See `docs/end-user-experience/development-workflow.md` for the approval and verification process.

## Frontier Escalation Acknowledgement

The CLI includes a safe acknowledgement stub for future frontier routing.

    ai ask --frontier "Review this synthetic problem"

The request is not sent until frontier use is explicitly acknowledged:

    ai ask --frontier --confirm-frontier "Review this synthetic problem"

Frontier providers are not configured, so acknowledged requests are logged and reported as unavailable. The default `ai ask` path remains local-first.

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
- configured frontier provider execution
- automatic frontier escalation
- provider fallback

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
