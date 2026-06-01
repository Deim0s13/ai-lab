# AI Lab

Personal AI-augmented architecture workstation for experimenting with local LLMs, GPU-backed inference, AI workflow tooling, and architecture-focused CLI assistants.

This project is intentionally practical. It is not about building a production AI platform from day one. It is about learning modern AI infrastructure, model workflows, local inference, APIs, containers, GPU acceleration, and orchestration by building useful tools that support architecture work.

---

## Purpose

The purpose of this project is to build practical AI fluency through hands-on experimentation.

The focus areas are:

* local LLM inference
* GPU-backed model execution
* Ollama and local model runtimes
* API-driven AI workflows
* Podman-based container management
* Open WebUI as a local AI interface
* VS Code / Continue.dev integration
* CLI-based AI workflow tools
* architecture-focused prompting and context
* basic model routing and orchestration

The longer-term goal is to evolve this into a personal AI-augmented architecture platform that helps with customer preparation, technology comparison, risk analysis, architecture thinking, and enterprise AI learning.

---

## Current Architecture

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

---

## Core Components

| Component              | Purpose                                      |
| ---------------------- | -------------------------------------------- |
| WSL2 Ubuntu            | Linux-based working environment on Windows   |
| NVIDIA GPU passthrough | Enables GPU acceleration for local inference |
| Ollama                 | Local model runtime                          |
| Podman                 | Container runtime                            |
| Open WebUI             | Local browser-based AI interface             |
| Continue.dev           | AI assistant inside VS Code                  |
| CLI tools              | Workflow layer for local AI experimentation  |

---

## Current Models

| Model             | Intended Use                                                            |
| ----------------- | ----------------------------------------------------------------------- |
| `qwen3:14b`       | General architecture explanation and everyday reasoning                 |
| `deepseek-r1:14b` | Deeper reasoning, comparison, risk, trade-off and strategy work         |
| `llama3.1:8b`     | Lightweight rewrites, short responses, quick summaries and simple tasks |

---

## Project Structure

```text
~/projects/ai-lab/
├── tools/
│   ├── ask-ollama
│   ├── architect-ai
│   ├── ai-status
│   ├── ai-gpu-check
│   ├── ollama-api-test
│   └── context/
│       ├── architect.txt
│       ├── writing-style.txt
│       └── banking.txt
│
├── containers/
│   └── open-webui/
│       └── open-webui.container
│
├── docs/
│   ├── workstation-architecture.md
│   ├── troubleshooting.md
│   └── model-notes.md
│
└── README.md
```

---

## CLI Tools

| Tool              | Purpose                                       |
| ----------------- | --------------------------------------------- |
| `ask-ollama`      | General-purpose local AI CLI interface        |
| `architect-ai`    | Architecture-focused workflow wrapper         |
| `ai-status`       | Workstation health check and safe remediation |
| `ai-gpu-check`    | Focused GPU acceleration validation           |
| `ollama-api-test` | Direct Ollama API testing and learning tool   |

---

## Context Files

| File                | Purpose                                       |
| ------------------- | --------------------------------------------- |
| `architect.txt`     | Architecture persona and framing              |
| `writing-style.txt` | Preferred tone and communication style        |
| `banking.txt`       | Banking and financial services domain context |

The context system keeps the tools modular. For example:

```bash
ask-ollama --persona architect --style writing-style "Explain RAG"
```

Or with banking context:

```bash
ask-ollama --persona architect --style writing-style --domain banking "Explain RAG to a banking customer"
```

---

## Quick Start

Ensure the tools folder is in your `PATH`:

```bash
export PATH="$HOME/projects/ai-lab/tools:$PATH"
```

Check the workstation:

```bash
ai-status
```

Run a full health check with safe remediation and GPU probe:

```bash
ai-status --fix --probe
```

Check GPU acceleration:

```bash
ai-gpu-check --probe
```

Call the Ollama API directly:

```bash
ollama-api-test "Reply with exactly: ok"
```

Ask a local model a question:

```bash
ask-ollama "Explain RAG"
```

Use model routing:

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

Use the architecture workflow wrapper:

```bash
architect-ai explain "RAG"
```

Use banking context:

```bash
architect-ai banking compare "OpenShift AI vs SageMaker"
```

---

## Tool Examples

### `ask-ollama`

General local AI interface.

```bash
ask-ollama "Explain Kubernetes operators"
```

With persona and style:

```bash
ask-ollama --persona architect --style writing-style "Explain OpenShift AI"
```

With banking context:

```bash
ask-ollama --persona architect --style writing-style --domain banking "Explain RAG to a banking customer"
```

With model routing:

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

With previous response memory:

```bash
ask-ollama --continue "Make that more concise"
```

Save output:

```bash
ask-ollama --auto "Explain local inference" --save docs/local-inference-notes.md
```

---

### `architect-ai`

Role-specific wrapper for architecture workflows.

```bash
architect-ai explain "RAG"
```

```bash
architect-ai risks "self-hosted AI platform"
```

```bash
architect-ai compare "OpenShift AI vs SageMaker"
```

```bash
architect-ai discovery "enterprise AI adoption"
```

```bash
architect-ai banking compare "OpenShift AI vs SageMaker"
```

---

### `ai-status`

Overall workstation health check.

```bash
ai-status
```

Apply safe fixes:

```bash
ai-status --fix
```

Run a model probe as part of the check:

```bash
ai-status --fix --probe
```

Safe remediation may start or restart known local services such as Ollama or Open WebUI. It does not change drivers, recreate containers, download models, or make destructive changes.

---

### `ai-gpu-check`

Focused GPU validation.

```bash
ai-gpu-check
```

With inference probe:

```bash
ai-gpu-check --probe
```

This confirms whether WSL2 can see the NVIDIA GPU and whether Ollama reports GPU usage for the active model.

---

### `ollama-api-test`

Direct API learning tool.

```bash
ollama-api-test "Explain RAG in one paragraph"
```

Show the request payload:

```bash
ollama-api-test --show-request "Explain model serving"
```

Show raw JSON response:

```bash
ollama-api-test --raw "Say hello"
```

Use streaming output:

```bash
ollama-api-test --stream "Explain Kubernetes operators simply"
```

---

## Open WebUI

Open WebUI is managed as a Podman Quadlet user service.

Active Quadlet location:

```text
~/.config/containers/systemd/open-webui.container
```

Version-controlled copy:

```text
containers/open-webui/open-webui.container
```

Runtime data location:

```text
~/containers/open-webui
```

Useful commands:

```bash
systemctl --user status open-webui.service
systemctl --user restart open-webui.service
journalctl --user -u open-webui.service -f
```

Open WebUI should be available at:

```text
http://localhost:8080
```

---

## Workstreams Completed

| Workstream                    | Status   |
| ----------------------------- | -------- |
| Local inference understanding | Complete |
| API awareness                 | Complete |
| Container understanding       | Complete |
| GPU acceleration              | Complete |
| Linux workflow maturity       | Complete |
| Model orchestration v0.1      | Complete |

---

## Current Capability

The workstation can now:

* run local models through Ollama
* use the NVIDIA GPU from WSL2
* expose models through Open WebUI
* use local models in Continue.dev
* call Ollama directly through API scripts
* run architecture-focused CLI workflows
* apply reusable persona, style, and domain context
* route prompts to different models using simple rules
* validate runtime health and apply safe remediation

---

## Roadmap

### v0.3 — Workflow Maturity and Routing Intelligence

Planned focus:

* improve project documentation
* improve `architect-ai` workflows
* add route explanation mode
* improve model routing from keyword-based to classifier-based routing
* improve troubleshooting documentation
* add changelog and clearer versioning

### Future Areas

Potential later phases:

* vLLM as a production-style local inference server
* OpenAI-compatible local serving
* LiteLLM or similar provider abstraction
* OpenAI / Claude integration
* semantic routing using embeddings or classifier models
* lightweight RAG and personal knowledge workflows
* llm-d and Kubernetes-native distributed inference concepts
* OpenShift AI alignment and platform architecture patterns

---

## Design Principles

This project should remain:

* practical
* useful
* understandable
* portable
* version-controlled
* role-aligned
* interesting enough to keep using

The goal is not to become a full-time AI engineer or developer. The goal is to become more fluent in AI systems, infrastructure patterns, and architecture-relevant workflows through hands-on experimentation.
