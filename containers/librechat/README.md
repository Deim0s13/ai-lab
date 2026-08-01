# LibreChat

LibreChat is the selected browser chat UI. It connects only to the LiteLLM gateway and does not configure model providers or runtimes directly.

## Architecture

The service uses:

- LibreChat v0.8.7
- MongoDB 4.4.18 for accounts and conversations
- LiteLLM at `http://host.containers.internal:4000/v1`
- localhost port `3080`
- profile-scoped Compose projects and MongoDB volumes

The images are pinned to tested versions. Optional RAG, agents, search and administration services are not included.

## Local configuration

Copy the environment template for the active profile:

```bash
cp containers/librechat/.env.example \
  containers/librechat/.env.macos-work.local

chmod 600 containers/librechat/.env.macos-work.local
```

Populate the existing LiteLLM key and generate independent LibreChat secrets. Use `openssl rand -hex 32` for the 64-character values and `openssl rand -hex 16` for `CREDS_IV`.

Profile-local environment files are ignored by Git and must never be committed.

## First run

Start LiteLLM first:

```bash
just ai-up
```

Temporarily enable registration:

```bash
LIBRECHAT_ALLOW_REGISTRATION=true just ui-up
```

Open <http://127.0.0.1:3080> and create the initial account. Then recreate the services with registration disabled:

```bash
just ui-down
just ui-up
```

## Daily lifecycle

```bash
just ui-up
just ui-status
just ui-logs
just ui-down
```

Set another profile explicitly when required:

```bash
AI_LAB_PROFILE=windows-personal just ui-up
```

Each profile requires its own `.env.<profile>.local` file. The Compose project name and MongoDB volume include the active profile, preventing work and personal conversation state from being shared.

`ui-down` removes the containers and network but retains the MongoDB volume. Never use `podman compose down --volumes` unless account and conversation data should be deleted.

The services use `restart: "no"` intentionally. Unified recovery and optional always-on startup are tracked in issue #58.

## Expected failure behaviour

If LiteLLM is unavailable, LibreChat may remain accessible but model requests must fail. It must not fall back to a directly configured provider or runtime.
