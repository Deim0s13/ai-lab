# Open WebUI with Podman Quadlet

## Purpose

This document explains how Open WebUI is managed in the AI Lab workstation.

Open WebUI provides a local browser-based AI interface connected to Ollama. It allows local models to be used through a familiar chat interface while keeping the model runtime local to the workstation.

In this project, Open WebUI runs as a Podman container managed by a systemd user service using Podman Quadlet.

The goal is to move from:

```text
manual container startup
```

to:

```text
managed local AI service
```

This provides a more reliable and repeatable operating model.

---

## Current Architecture

```text
Windows Browser
    ↓
http://localhost:8080
    ↓
Open WebUI
    ↓
Podman container
    ↓
systemd user service
    ↓
Ollama API
    ↓
local GPU-backed models
```

Open WebUI connects to Ollama through:

```text
http://127.0.0.1:11434
```

Open WebUI itself is exposed on:

```text
http://localhost:8080
```

---

## Key Locations

The project separates source-controlled definitions from runtime data.

| Location                                            | Purpose                               | Stored in Git? |
| --------------------------------------------------- | ------------------------------------- | -------------- |
| `containers/open-webui/open-webui.container`        | Version-controlled Quadlet definition | Yes            |
| `~/.config/containers/systemd/open-webui.container` | Active Quadlet file used by systemd   | No             |
| `~/containers/open-webui`                           | Open WebUI runtime data               | No             |

This follows the project principle:

```text
Repo stores definitions.
Home directory stores runtime data.
Systemd config stores active service files.
```

---

## Why Quadlet?

Podman Quadlet allows containers to be described using systemd-style unit files.

This means Open WebUI can be managed with familiar service commands:

```bash
systemctl --user status open-webui.service
systemctl --user restart open-webui.service
journalctl --user -u open-webui.service -f
```

This is more operationally useful than relying on a one-off `podman run` command.

It also maps more closely to platform engineering concepts:

* declarative service definition
* container lifecycle management
* persistent storage
* restart policy
* logs and status
* separation of config and runtime data

---

## Quadlet Definition

The active Quadlet file should live here:

```text
~/.config/containers/systemd/open-webui.container
```

A version-controlled copy should be stored here:

```text
~/projects/ai-lab/containers/open-webui/open-webui.container
```

Example Quadlet definition:

```ini
[Unit]
Description=Open WebUI - Local AI Web Interface
Wants=network-online.target
After=network-online.target

[Container]
ContainerName=open-webui
Image=ghcr.io/open-webui/open-webui:main
Network=host
Environment=OLLAMA_BASE_URL=http://127.0.0.1:11434
Volume=%h/containers/open-webui:/app/backend/data

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target
```

---

## Explanation of Key Settings

### `ContainerName`

```ini
ContainerName=open-webui
```

Sets the container name to `open-webui`.

This keeps Podman commands predictable:

```bash
podman ps
podman logs open-webui
podman inspect open-webui
```

---

### `Image`

```ini
Image=ghcr.io/open-webui/open-webui:main
```

Uses the Open WebUI container image from GitHub Container Registry.

At this stage the project uses `main` for convenience. Later, this may be pinned to a specific version for better reproducibility.

---

### `Network`

```ini
Network=host
```

Uses host networking.

This makes it easier for the Open WebUI container to reach Ollama on the local host at:

```text
http://127.0.0.1:11434
```

This keeps the local workstation setup simple.

---

### `OLLAMA_BASE_URL`

```ini
Environment=OLLAMA_BASE_URL=http://127.0.0.1:11434
```

Tells Open WebUI where to find Ollama.

Ollama must be running and reachable at this address.

Validate with:

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

---

### `Volume`

```ini
Volume=%h/containers/open-webui:/app/backend/data
```

Mounts persistent Open WebUI data from:

```text
~/containers/open-webui
```

into the container at:

```text
/app/backend/data
```

This keeps Open WebUI data outside the Git repository.

---

### `Restart`

```ini
Restart=always
```

Tells systemd to restart the service if it stops unexpectedly.

---

## Initial Setup

Create the runtime data directory:

```bash
mkdir -p ~/containers/open-webui
```

Create the active Quadlet directory:

```bash
mkdir -p ~/.config/containers/systemd
```

Copy the version-controlled Quadlet into the active location:

```bash
cp ~/projects/ai-lab/containers/open-webui/open-webui.container \
  ~/.config/containers/systemd/open-webui.container
```

Reload systemd user units:

```bash
systemctl --user daemon-reload
```

Start Open WebUI:

```bash
systemctl --user start open-webui.service
```

Check status:

```bash
systemctl --user status open-webui.service
```

---

## Normal Lifecycle Commands

### Check service status

```bash
systemctl --user status open-webui.service
```

### Start Open WebUI

```bash
systemctl --user start open-webui.service
```

### Stop Open WebUI

```bash
systemctl --user stop open-webui.service
```

### Restart Open WebUI

```bash
systemctl --user restart open-webui.service
```

### Reload Quadlet changes

If the `.container` file changes:

```bash
systemctl --user daemon-reload
systemctl --user restart open-webui.service
```

---

## Logs

### View service logs

```bash
journalctl --user -u open-webui.service -f
```

### View recent logs

```bash
journalctl --user -u open-webui.service -n 100 --no-pager
```

### View Podman logs

```bash
podman logs --tail 100 open-webui
```

---

## Container Commands

Although Open WebUI is managed through systemd, Podman is still useful for inspection.

### List running containers

```bash
podman ps
```

### List all containers

```bash
podman ps -a
```

### Inspect Open WebUI

```bash
podman inspect open-webui
```

### Inspect selected details

```bash
podman inspect open-webui | jq '.[0] | {
  Name: .Name,
  Image: .ImageName,
  State: .State.Status,
  NetworkMode: .HostConfig.NetworkMode,
  Mounts: .Mounts
}'
```

---

## Validate Open WebUI

### Check HTTP endpoint

```bash
curl -I http://127.0.0.1:8080
```

Expected result:

```text
HTTP/1.1 200 OK
```

or another valid HTTP response from Open WebUI.

### Open in browser

```text
http://localhost:8080
```

---

## Validate Ollama Connectivity

Open WebUI depends on Ollama.

Check Ollama API:

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

Check Ollama service:

```bash
systemctl status ollama
```

Check available models:

```bash
ollama list
```

---

## Using `ai-status`

The `ai-status` tool checks Open WebUI as part of the overall workstation health check.

Run:

```bash
ai-status
```

Run with safe remediation:

```bash
ai-status --fix
```

Run with safe remediation and model probe:

```bash
ai-status --fix --probe
```

For Open WebUI, `ai-status --fix` can:

* detect whether the Quadlet exists
* detect whether the user service is generated
* reload user systemd if required
* start the Open WebUI service if stopped
* restart the Open WebUI service if the HTTP endpoint is unreachable
* fall back to Podman start/restart only if the systemd user service is not available

It does not recreate the Open WebUI container or delete runtime data.

---

## Updating the Quadlet

If the version-controlled Quadlet file is changed, copy it to the active systemd location:

```bash
cp ~/projects/ai-lab/containers/open-webui/open-webui.container \
  ~/.config/containers/systemd/open-webui.container
```

Then reload and restart:

```bash
systemctl --user daemon-reload
systemctl --user restart open-webui.service
```

Validate:

```bash
systemctl --user status open-webui.service
curl -I http://127.0.0.1:8080
```

---

## Rebuild Steps

If rebuilding the workstation from the Git repo:

1. Restore the repository:

```bash
cd ~/projects/ai-lab
```

2. Create runtime data location:

```bash
mkdir -p ~/containers/open-webui
```

3. Restore active Quadlet location:

```bash
mkdir -p ~/.config/containers/systemd
```

4. Copy the Quadlet:

```bash
cp ~/projects/ai-lab/containers/open-webui/open-webui.container \
  ~/.config/containers/systemd/open-webui.container
```

5. Reload user systemd:

```bash
systemctl --user daemon-reload
```

6. Start Open WebUI:

```bash
systemctl --user start open-webui.service
```

7. Validate:

```bash
systemctl --user status open-webui.service
curl -I http://127.0.0.1:8080
```

---

## Common Issues

### Service is generated but cannot be enabled

You may see:

```text
Failed to enable unit: Unit ... is transient or generated
```

This can happen with Quadlet-generated services.

The important thing is that the service can be started and managed with:

```bash
systemctl --user start open-webui.service
systemctl --user status open-webui.service
```

The Quadlet file and `[Install]` section are used by the generator, but generated units may not behave exactly like manually written service files when using `enable`.

---

### Open WebUI cannot reach Ollama

Check Ollama:

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

Check that Ollama is running:

```bash
systemctl status ollama
```

Check Ollama host binding:

```bash
ss -tulnp | grep 11434
```

The workstation expects Ollama to be available at:

```text
http://127.0.0.1:11434
```

---

### Open WebUI is not reachable

Check service status:

```bash
systemctl --user status open-webui.service
```

Check logs:

```bash
journalctl --user -u open-webui.service -n 100 --no-pager
```

Restart:

```bash
systemctl --user restart open-webui.service
```

Validate:

```bash
curl -I http://127.0.0.1:8080
```

---

### Container exists but service is not running

Check Podman:

```bash
podman ps -a
```

Check systemd user service:

```bash
systemctl --user status open-webui.service
```

Reload user units:

```bash
systemctl --user daemon-reload
```

Start the service:

```bash
systemctl --user start open-webui.service
```

---

## Known Good State

Open WebUI is healthy when:

* `systemctl --user status open-webui.service` shows active running
* `podman ps` shows the `open-webui` container
* `curl -I http://127.0.0.1:8080` returns an HTTP response
* the browser can access `http://localhost:8080`
* Open WebUI can see Ollama models

Quick validation:

```bash
ai-status --fix --probe
```

---

## Notes

This setup is intentionally local and workstation-focused.

It is not intended to represent production Open WebUI deployment guidance. The purpose is to provide a reliable local AI interface and to build practical understanding of containerised AI service management.

Future improvements may include:

* pinning the Open WebUI image to a specific version
* documenting backup and restore of Open WebUI data
* adding update procedures
* adding a health check script specific to Open WebUI
* exploring Open WebUI integration with vLLM or OpenAI-compatible endpoints
