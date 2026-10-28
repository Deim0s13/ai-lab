# LiteLLM Gateway Config

This folder contains the initial LiteLLM gateway configuration for the AI Dev Workstation.

The purpose of this config is to map project route classes to gateway model groups without building custom provider/model routing logic.

## Current Status

LiteLLM is the persistent, local gateway for the workstation. It runs through
the profile-aware Compose deployment in `containers/litellm/`, with PostgreSQL
retaining virtual-key state.

The active path is:

route class -> gateway model group -> LiteLLM -> local runtime

## Files

| File              | Purpose                                                     |
| ----------------- | ----------------------------------------------------------- |
| config.local.yaml | Minimal local-only LiteLLM config for initial gateway proof |

## Route Class Mapping

The project routing config lives in:

config/routing/routes.yaml

Route classes currently map to gateway model groups like this:

| Route class        | Route type    | Gateway model group     | Status      |
| ------------------ | ------------- | ----------------------- | ----------- |
| local_fast         | local         | local-fast              | configured  |
| local_capable      | local         | local-capable           | configured  |
| local_code         | local         | local-code              | configured  |
| approved_work      | approved_work | work-approved-reasoning | placeholder |
| frontier_reasoning | frontier      | frontier-reasoning      | placeholder |
| frontier_code      | frontier      | frontier-code           | placeholder |

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
- Publish the gateway only on `127.0.0.1:4000`.
- Treat the internal container listener and the host-published address as separate boundaries.
- Remote gateway access requires a separate security decision.

## Local Runtime Assumption

The initial local path assumes Ollama is available on the host.

For Docker-based LiteLLM, the config uses:

http://host.docker.internal:11434

If running LiteLLM directly on the host, this may need to become:

http://localhost:11434

## Required Secrets

Gateway startup resolves the high-entropy master key, persistent salt key and
PostgreSQL password from Bitwarden. The master key is reserved for gateway
administration. Normal clients use separate LiteLLM virtual keys with scoped
model and route access.

See `docs/secrets-and-credentials.md` for item names, fallback locations,
rotation, revocation and rebuild procedures. Never use a predictable local
development master key or copy the master key into client configuration.

## Bootstrap Check

The gateway-aware bootstrap check is implemented as a `just` recipe rather than custom Python.

Resolve an authorized credential without printing it, then run:

```bash
key="$(bw get password ai-lab/macos-work/LITELLM_MASTER_KEY)"
LITELLM_MASTER_KEY="${key}" just bootstrap-check
unset key
```

The check validates:

- configuration and profile YAML can be parsed
- LiteLLM `/health/readiness` responds successfully
- LiteLLM `/v1/models` exposes the required stable model groups
- an authorized gateway credential is available without printing its value

The aggregate `/health` check remains available through `just gateway-health` as a bounded, on-demand diagnostic. It is not part of routine bootstrap validation because probing every configured backend can be slow or intermittent.

This keeps bootstrap validation tool-based and avoids building a custom health-check framework.

## Asking the Local Gateway

The first CLI habit workflow uses a `just` recipe rather than a custom wrapper.

Run with the scoped CLI key:

```bash
key="$(bw get password ai-lab/macos-work/LITELLM_CLI_KEY)"
LITELLM_API_KEY="${key}" just ask "Say hello"
unset key
```

This sends the prompt to the LiteLLM gateway using the `local-fast` model group
and the caller's scoped inference credential, then prints the assistant
response.

The recipe uses:

- LiteLLM `/v1/chat/completions`
- `local-fast`
- `curl`
- `jq`

It does not add custom Python and does not call frontier providers.
