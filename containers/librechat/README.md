# LibreChat

LibreChat is the adopted browser chat UI for AI Lab. It connects only to the LiteLLM gateway and never directly to oMLX, Ollama or external providers.

## Architecture

The deployment uses:

- LibreChat v0.8.7
- MongoDB 4.4.18 for accounts and conversations
- LiteLLM at `http://host.containers.internal:4000/v1`
- oMLX as the preferred Apple Silicon runtime
- Ollama as the local fallback runtime
- localhost port `3080`
- profile-scoped Compose projects and MongoDB volumes

The images are pinned to tested versions. Optional RAG, agents, search, prompts and marketplace services are disabled.

## Prerequisites

The `macos-work` deployment requires:

- Podman Desktop and its Podman machine
- Podman Compose support
- `just`, `curl` and `jq`
- the repository Python virtual environment
- oMLX and Ollama configured for the workstation

Validate the host before starting:

```bash
just workstation-preflight
```

## Local configuration

Create the ignored environment file for the active profile:

```bash
cp containers/librechat/.env.example \
  containers/librechat/.env.macos-work.local

chmod 600 containers/librechat/.env.macos-work.local
```

Populate `LITELLM_API_KEY` with the same value used by `LITELLM_MASTER_KEY`. Generate independent LibreChat secrets with:

```bash
openssl rand -hex 32
openssl rand -hex 16
```

Use 64-character values for `JWT_SECRET`, `JWT_REFRESH_SECRET`, `CREDS_KEY` and `SESSION_SECRET`. Use the 32-character value for `CREDS_IV`.

Profile-local `.env.<profile>.local` files are ignored by Git and must never be committed.

## First run

Start the complete workstation:

```bash
just workstation-up
```

Temporarily enable registration:

```bash
just ui-down
LIBRECHAT_ALLOW_REGISTRATION=true just ui-up
```

Open <http://127.0.0.1:3080> and create the initial account. Then disable registration by recreating LibreChat normally:

```bash
just ui-down
just ui-up
```

## Daily lifecycle

Use the unified workstation commands for normal operation:

```bash
just workstation-up
just workstation-status
just workstation-logs
just workstation-down
```

`workstation-up` starts or recovers Podman, oMLX, Ollama, LiteLLM and LibreChat in dependency order. It is safe to run when the workstation is already running.

Component-level commands remain available for focused diagnostics:

```bash
just ui-check
just ui-status
just ui-logs
just gateway-ready
```

## Gateway and model access

LibreChat discovers model aliases through LiteLLM. Required aliases include:

- `local-fast`
- `local-fast-mlx`
- `local-capable-mlx`
- `local-code-mlx`

Run the focused configuration and runtime check with:

```bash
just ui-check
```

If LiteLLM is stopped, LibreChat may remain accessible, but model requests must fail. A successful response while the gateway is down would indicate an unsupported direct-provider bypass.

## Storage and profile separation

MongoDB stores accounts and conversations in a named Podman volume. The Compose project and volume names include the active profile, preventing work and personal chat data from being shared accidentally.

`ui-down` and `workstation-down` remove containers while preserving the MongoDB volume. Conversations therefore survive container recreation, Podman machine recovery and normal workstation shutdown.

To inspect the active volumes:

```bash
podman volume ls \
  --filter label=com.docker.compose.project=ai-lab-librechat-macos-work
```

Deleting the MongoDB volume permanently removes LibreChat accounts and conversation history. Do not use `podman compose down --volumes` unless a full profile reset is intended.

## Privacy and security

- LibreChat listens only on `127.0.0.1:3080`.
- Model access is gateway-only.
- Registration is disabled during normal use.
- Secrets remain in ignored profile-local environment files.
- Work and personal profiles use separate Compose projects and storage.
- Synthetic data should be used for validation.
- Frontier escalation remains subject to gateway and profile policy.

## Validation

After configuration changes, run:

```bash
just --fmt --check
just check-yaml
just ui-check
```

For a manual gateway-path test:

1. Submit a synthetic prompt through `local-fast-mlx`.
2. Run `just gateway-stop`.
3. Confirm another prompt fails without producing a model response.
4. Run `just workstation-up`.
5. Confirm the earlier conversation remains and prompting works again.

## Troubleshooting

After sleep or a network transition, inspect the workstation:

```bash
just workstation-status
```

If the Podman or Compose API is unavailable, run:

```bash
just workstation-up
```

The startup workflow waits for recovery and can restart the Podman machine when its APIs remain stale. Restarting the machine interrupts other Podman containers.

If LibreChat loads but models are unavailable, run:

```bash
just omlx-check
just ollama-check
just gateway-ready
just ui-check
```

Use `just workstation-logs` for combined runtime, gateway and UI logs.
