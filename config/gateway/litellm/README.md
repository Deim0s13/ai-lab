# LiteLLM Gateway Config

This folder contains the initial LiteLLM gateway configuration for the AI Dev Workstation.

The purpose of this config is to map project route classes to gateway model groups without building custom provider/model routing logic.

## Current Status

This is a Milestone 1 local-only starting point.

It is intended to support the next proof step:

route class -> gateway model group -> LiteLLM -> local runtime

## Files

| File | Purpose |
|---|---|
| config.local.yaml | Minimal local-only LiteLLM config for initial gateway proof |

## Route Class Mapping

The project routing config lives in:

config/routing/routes.yaml

Route classes currently map to gateway model groups like this:

| Route class | Route type | Gateway model group | Status |
|---|---|---|---|
| local_fast | local | local-fast | configured |
| local_capable | local | local-capable | configured |
| local_code | local | local-code | configured |
| approved_work | approved_work | work-approved-reasoning | placeholder |
| frontier_reasoning | frontier | frontier-reasoning | placeholder |
| frontier_code | frontier | frontier-code | placeholder |

Only the local model groups are configured in config.local.yaml.

Frontier and work-approved groups are intentionally not configured yet because they require provider decisions, secrets and policy confirmation.

## Why LiteLLM

LiteLLM is the preferred Milestone 1 gateway candidate, subject to local proof.

The evaluation is documented in:

docs/tool-evaluations/001-litellm-gateway.md

## Design Rules

- Do not commit secrets.
- Keep the first proof local-only.
- Do not add frontier providers until the local gateway path works.
- Do not make ai-route execute provider/model routing.
- Keep route policy in project config.
- Let LiteLLM handle gateway/provider execution.

## Local Runtime Assumption

The initial local path assumes Ollama is available on the host.

For Docker-based LiteLLM, the config uses:

http://host.docker.internal:11434

If running LiteLLM directly on the host, this may need to become:

http://localhost:11434

## Required Environment Variables

The config references:

LITELLM_MASTER_KEY

This should be set locally and never committed.

Example local-only value:

LITELLM_MASTER_KEY=sk-local-dev

## Next Step

The next issue should prove one local model path through the gateway.

That proof should confirm:

- Ollama is running
- the selected local model exists
- LiteLLM can start with this config
- a simple prompt can be sent through the LiteLLM gateway
- no external provider or secret is required

## Bootstrap Check

The gateway-aware bootstrap check is implemented as a `just` recipe rather than custom Python.

Run:

just bootstrap-check

The check validates:

- config and profile YAML can be parsed
- LiteLLM `/v1/models` lists `local-fast`
- LiteLLM `/health` reports at least one healthy endpoint
- `LITELLM_MASTER_KEY` is set locally without printing the value

This keeps bootstrap validation tool-based and avoids building a custom health-check framework.

## Asking the Local Gateway

The first CLI habit workflow uses a `just` recipe rather than a custom wrapper.

Run:

just ask "Say hello"

This sends the prompt to the LiteLLM gateway using the `local-fast` model group and prints the assistant response.

The recipe uses:

- LiteLLM `/v1/chat/completions`
- `local-fast`
- `curl`
- `jq`

It does not add custom Python and does not call frontier providers.
