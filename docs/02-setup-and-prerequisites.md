# Setup and Prerequisites

## Purpose

This document captures the setup required to rebuild the AI Lab workstation.

The aim is not to document every possible installation option. The aim is to provide a practical rebuild path for the current workstation architecture:

```text
Windows 11
└── WSL2 Ubuntu
    ├── NVIDIA GPU passthrough
    ├── Ollama service
    ├── Local LLMs
    ├── Podman
    ├── Open WebUI via Podman Quadlet
    ├── VS Code + Continue.dev
    └── AI workflow tools
```

This document should be used if the workstation needs to be rebuilt, moved to another machine, or re-created after a clean install.

---

## Host Requirements

Current target environment:

| Component           | Requirement                  |
| ------------------- | ---------------------------- |
| Host OS             | Windows 11                   |
| Linux environment   | WSL2 Ubuntu                  |
| GPU                 | NVIDIA GPU with WSL2 support |
| Container runtime   | Podman                       |
| Local model runtime | Ollama                       |
| Editor              | VS Code                      |
| AI editor extension | Continue.dev                 |
| Web UI              | Open WebUI                   |

The current workstation uses an Alienware M18 with an NVIDIA RTX 4090 GPU.

---

## Windows Prerequisites

### Windows 11

Ensure Windows 11 is fully updated.

### NVIDIA Driver

Install a current NVIDIA Windows driver that supports CUDA in WSL2.

After installation, restart Windows.

From Windows PowerShell, confirm WSL is available:

```powershell
wsl --status
```

If WSL needs to be restarted:

```powershell
wsl --shutdown
```

Then reopen Ubuntu.

---

## Install WSL2 Ubuntu

From PowerShell:

```powershell
wsl --install -d Ubuntu
```

After installation:

1. Launch Ubuntu.
2. Create a Linux username and password.
3. Update the system.

Inside Ubuntu:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## Base Linux Packages

Install common tools:

```bash
sudo apt install -y \
  zsh \
  git \
  curl \
  wget \
  jq \
  unzip \
  tree \
  build-essential \
  podman
```

These tools are used by the workstation scripts, documentation, container workflows, and basic Linux operations.

---

## Terminal and Shell Setup

The workstation uses:

* Windows Terminal
* WSL2 Ubuntu
* zsh
* Starship prompt
* Nerd Font / Powerline-style prompt

### Set zsh as default shell

```bash
chsh -s "$(which zsh)"
```

Close and reopen the terminal.

Validate:

```bash
echo $SHELL
```

Expected:

```text
/usr/bin/zsh
```

### Install Starship

```bash
curl -sS https://starship.rs/install.sh | sh
```

Add to `~/.zshrc`:

```bash
eval "$(starship init zsh)"
```

Reload:

```bash
source ~/.zshrc
```

### PATH Configuration

Ensure the project tools directory is in the shell path.

Add this to `~/.zshrc`:

```bash
export PATH="$HOME/projects/ai-lab/tools:$PATH"
```

Reload:

```bash
source ~/.zshrc
hash -r
```

Validate later with:

```bash
which ask-ollama
which architect-ai
which ai-status
```

---

## GPU Validation in WSL2

Inside Ubuntu, confirm WSL2 can see the NVIDIA GPU:

```bash
nvidia-smi
```

Expected outcome:

* NVIDIA GPU is visible
* driver version is shown
* GPU memory is shown

The workstation also checks for CUDA library visibility:

```bash
ls -l /usr/lib/wsl/lib/libcuda.so.1
```

If the GPU is not visible, the issue is usually with the Windows NVIDIA driver, WSL2 integration, or needing to restart WSL:

```powershell
wsl --shutdown
```

---

## Install Ollama

Inside WSL2 Ubuntu:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Validate:

```bash
ollama --version
```

Check service status:

```bash
systemctl status ollama
```

---

## Configure Ollama Host Binding

The workstation uses Ollama as a local service and exposes it to local tools such as Open WebUI and Continue.dev.

Create or edit the Ollama systemd override:

```bash
sudo systemctl edit ollama
```

Add:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

Validate API access:

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

---

## Pull Local Models

Current model set:

```bash
ollama pull qwen3:14b
ollama pull deepseek-r1:14b
ollama pull llama3.1:8b
```

Validate:

```bash
ollama list
```

Current intended use:

| Model             | Intended Use                                                            |
| ----------------- | ----------------------------------------------------------------------- |
| `qwen3:14b`       | General architecture explanation and everyday reasoning                 |
| `deepseek-r1:14b` | Deeper reasoning, comparison, risk, trade-off and strategy work         |
| `llama3.1:8b`     | Lightweight rewrites, short responses, quick summaries and simple tasks |

---

## Confirm GPU-backed Inference

Run:

```bash
ollama run qwen3:14b "Reply with exactly: ok"
```

Then:

```bash
ollama ps
```

Expected processor output:

```text
100% GPU
```

The project also includes:

```bash
ai-gpu-check --probe
```

This provides a reusable GPU validation workflow once the tools have been restored.

---

## Install and Configure Podman

Podman is installed through the base package step:

```bash
sudo apt install -y podman
```

Validate:

```bash
podman --version
```

The workstation uses Podman for Open WebUI.

---

## Open WebUI Runtime Locations

The project separates source-controlled definitions from runtime data.

| Location                                            | Purpose                               |
| --------------------------------------------------- | ------------------------------------- |
| `containers/open-webui/open-webui.container`        | Version-controlled Quadlet definition |
| `~/.config/containers/systemd/open-webui.container` | Active Quadlet file                   |
| `~/containers/open-webui`                           | Runtime Open WebUI data               |

The runtime data directory should not be stored in Git.

Create the runtime data directory:

```bash
mkdir -p ~/containers/open-webui
```

---

## Restore Open WebUI Quadlet

Copy the version-controlled Quadlet definition into the active systemd user location:

```bash
mkdir -p ~/.config/containers/systemd

cp ~/projects/ai-lab/containers/open-webui/open-webui.container \
  ~/.config/containers/systemd/open-webui.container
```

Reload user systemd:

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

Validate the container:

```bash
podman ps
```

Validate the endpoint:

```bash
curl -I http://127.0.0.1:8080
```

Open in browser:

```text
http://localhost:8080
```

---

## VS Code and Continue.dev

Install VS Code on Windows.

Install the following VS Code extensions:

| Extension           | Purpose                                |
| ------------------- | -------------------------------------- |
| Remote - WSL        | Work inside WSL2 Ubuntu from VS Code   |
| Continue.dev        | Local AI assistant connected to Ollama |
| GitLens             | Git visibility                         |
| Markdown All in One | Markdown editing support               |

From WSL2, open the project:

```bash
cd ~/projects/ai-lab
code .
```

If `code` is not available inside WSL, open VS Code on Windows and install the shell command or reopen the folder through the Remote WSL extension.

---

## Continue.dev Configuration

Continue.dev should connect to Ollama models running inside WSL2.

The local Continue config should live under:

```text
~/.continue/config.yaml
```

Example configuration:

```yaml
name: Local AI Workstation
version: 0.0.1
schema: v1

models:
  - name: Qwen3 14B
    provider: ollama
    model: qwen3:14b
    apiBase: http://127.0.0.1:11434
    roles:
      - chat
      - edit
      - apply

  - name: DeepSeek R1 14B
    provider: ollama
    model: deepseek-r1:14b
    apiBase: http://127.0.0.1:11434
    roles:
      - chat
      - edit
      - apply

  - name: Llama 3.1 8B
    provider: ollama
    model: llama3.1:8b
    apiBase: http://127.0.0.1:11434
    roles:
      - chat
      - edit
      - apply
```

Validate inside Continue.dev by selecting a local model and asking a simple question.

---

## Restore Project Tools

Clone or restore the Git repository to:

```text
~/projects/ai-lab
```

Expected tools:

```text
tools/
├── ask-ollama
├── architect-ai
├── ai-status
├── ai-gpu-check
├── ollama-api-test
└── context/
```

Make tools executable:

```bash
chmod +x ~/projects/ai-lab/tools/*
```

The `context` directory may generate a harmless warning because it is not a file.

Validate:

```bash
which ask-ollama
which architect-ai
which ai-status
which ai-gpu-check
which ollama-api-test
```

Expected paths:

```text
/home/pleathen/projects/ai-lab/tools/ask-ollama
/home/pleathen/projects/ai-lab/tools/architect-ai
/home/pleathen/projects/ai-lab/tools/ai-status
/home/pleathen/projects/ai-lab/tools/ai-gpu-check
/home/pleathen/projects/ai-lab/tools/ollama-api-test
```

---

## Validate Workstation Health

Run:

```bash
ai-status
```

Run full health check with safe remediation and inference probe:

```bash
ai-status --fix --probe
```

Run focused GPU validation:

```bash
ai-gpu-check --probe
```

Run API test:

```bash
ollama-api-test "Reply with exactly: ok"
```

Run model routing test:

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

Run architecture workflow test:

```bash
architect-ai banking compare "OpenShift AI vs SageMaker"
```

---

## Known Good State

A healthy workstation should have:

* WSL2 Ubuntu working
* NVIDIA GPU visible via `nvidia-smi`
* Ollama service running
* Ollama API reachable on `127.0.0.1:11434`
* local models available via `ollama list`
* active model showing GPU usage via `ollama ps`
* Open WebUI running as a user service
* Open WebUI reachable at `http://localhost:8080`
* Continue.dev able to use local Ollama models
* CLI tools available from anywhere in the terminal

Quick validation:

```bash
ai-status --fix --probe
```

---

## Rebuild Principle

The project follows this principle:

```text
Repo stores definitions and tools.
Home directory stores runtime data.
Systemd config stores active service definitions.
Ollama stores local model data.
```

The Git repository should contain:

* tools
* context files
* documentation
* Quadlet definitions
* examples

The Git repository should not contain:

* model files
* runtime data
* secrets
* local caches
* Open WebUI database/runtime state
