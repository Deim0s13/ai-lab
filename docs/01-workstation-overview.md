# Workstation Overview

## Purpose

This project is a personal AI-augmented architecture workstation.

The aim is to build practical AI fluency through hands-on experimentation, rather than studying AI concepts in isolation. It provides a local environment for exploring how modern AI systems work across inference, APIs, containers, GPU acceleration, model routing, workflow tooling, and architecture-focused use cases.

This is not intended to be a production AI platform. It is a learning and workflow environment that helps build confidence with the technologies, patterns, and trade-offs that sit behind modern AI platforms.

The project is designed to support:

* local LLM experimentation
* GPU-backed inference
* API-driven model interaction
* containerised AI tooling
* architecture-focused CLI workflows
* model routing and orchestration
* practical learning around AI infrastructure patterns
* better preparation for customer and architecture conversations

---

## Why This Exists

The main goal is to become more fluent in AI systems by building and using a practical workstation.

Rather than approaching AI only through browser-based chat tools, this project exposes the underlying layers:

```text
User workflow
  ↓
CLI tool / Web UI / Editor integration
  ↓
API call
  ↓
Model runtime
  ↓
Local model
  ↓
GPU-backed inference
  ↓
Response
```

This helps make AI more understandable from an architecture perspective.

The project also supports day-to-day architecture work by providing reusable tools for:

* explaining technical concepts
* comparing platforms
* identifying risks and trade-offs
* preparing customer discovery questions
* creating executive summaries
* using financial services context where relevant
* applying a consistent writing tone and communication style

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

## Architecture Layers

### Host Layer

The workstation runs on Windows 11 to take advantage of the Alienware M18 hardware and consumer-grade NVIDIA GPU.

Windows acts primarily as the host operating system and GPU driver layer.

### Linux Workflow Layer

WSL2 Ubuntu provides the main working environment.

This gives a Linux-native CLI experience while still using the Windows host for hardware access, gaming, and general desktop use.

This layer includes:

* zsh
* Starship prompt
* common Linux CLI tools
* Git
* project tooling
* local scripts

### GPU Acceleration Layer

The NVIDIA GPU is exposed into WSL2 and used by Ollama for local model inference.

The key validation tools are:

```bash
nvidia-smi
ollama ps
ai-gpu-check --probe
```

The expected outcome is that active models report GPU usage, ideally:

```text
100% GPU
```

### Model Runtime Layer

Ollama is used as the current local model runtime.

It provides:

* local model management
* local inference
* CLI access
* HTTP API access
* integration with Open WebUI
* integration with Continue.dev
* integration with local workflow scripts

Current models include:

| Model             | Intended Use                                                            |
| ----------------- | ----------------------------------------------------------------------- |
| `qwen3:14b`       | General architecture explanation and everyday reasoning                 |
| `deepseek-r1:14b` | Deeper reasoning, comparison, risk, trade-off and strategy work         |
| `llama3.1:8b`     | Lightweight rewrites, short responses, quick summaries and simple tasks |

### Container Layer

Podman is used as the container runtime.

Open WebUI runs as a Podman container managed through a Quadlet user service. This provides a more mature operating model than manually running a container.

Open WebUI is managed through:

```bash
systemctl --user status open-webui.service
systemctl --user restart open-webui.service
journalctl --user -u open-webui.service -f
```

### Interface Layer

The workstation currently provides three main user interfaces:

| Interface    | Purpose                                       |
| ------------ | --------------------------------------------- |
| Open WebUI   | Browser-based local AI chat interface         |
| Continue.dev | VS Code-based AI assistant using local models |
| CLI tools    | Local AI workflows from the terminal          |

### Workflow Layer

The CLI workflow layer is where the workstation becomes personally useful.

Current tools include:

| Tool              | Purpose                                       |
| ----------------- | --------------------------------------------- |
| `ask-ollama`      | General local AI CLI interface                |
| `architect-ai`    | Architecture-focused workflow wrapper         |
| `ai-status`       | Workstation health check and safe remediation |
| `ai-gpu-check`    | Focused GPU acceleration validation           |
| `ollama-api-test` | Direct Ollama API testing and learning tool   |

### Context Layer

Reusable context files shape the responses without having to repeat instructions each time.

Current context files:

| File                | Purpose                                       |
| ------------------- | --------------------------------------------- |
| `architect.txt`     | Architecture persona and framing              |
| `writing-style.txt` | Preferred tone and communication style        |
| `banking.txt`       | Banking and financial services domain context |

These can be combined through `ask-ollama`:

```bash
ask-ollama --persona architect --style writing-style "Explain RAG"
```

or:

```bash
ask-ollama --persona architect --style writing-style --domain banking "Explain RAG to a banking customer"
```

---

## Current Capabilities

The workstation can currently:

* run local models through Ollama
* use the NVIDIA GPU from WSL2
* expose local models through Open WebUI
* use local models in Continue.dev
* call Ollama directly through its HTTP API
* run architecture-focused AI workflows from the CLI
* apply reusable persona, style, and domain context
* route prompts to different models using basic rules
* validate workstation health
* safely restart known local services when appropriate

---

## What This Is Not

This project is not currently:

* a production AI platform
* a replacement for enterprise AI governance
* a full RAG platform
* a Kubernetes-native inference platform
* an agentic automation platform
* a benchmarking lab
* a model training or fine-tuning environment

Those areas may be explored later, but the current focus is on practical fluency and useful local workflows.

---

## Learning Goals

The core learning goals are:

### Local Inference

Understand what it means to run models locally, how model runtimes work, and how local inference differs from using hosted AI services.

### APIs

Understand how tools interact with model runtimes through HTTP APIs and JSON payloads.

### Containers

Understand how AI tools can be packaged, run, persisted, and managed as containerised services.

### GPU Acceleration

Understand the practical runtime path between Windows, WSL2, NVIDIA drivers, CUDA visibility, Ollama, and model execution.

### Linux Workflows

Build confidence with Linux-native tooling, shell scripts, service management, Git, PATH configuration, and repeatable project structures.

### Model Orchestration

Understand how different models can be used for different tasks and how routing logic can select the most appropriate model.

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

## Current Design Principles

The project should remain:

* practical
* understandable
* portable
* version-controlled
* role-aligned
* useful for real architecture work
* interesting enough to keep using

The goal is not to become a full-time AI engineer or developer. The goal is to become more fluent in AI systems, infrastructure patterns, and architecture-relevant workflows through hands-on experimentation.

---

## Future Direction

The likely next areas of exploration are:

* improved documentation and rebuild instructions
* smarter model routing
* route explanation mode
* classifier-based routing
* vLLM as a production-style local inference server
* OpenAI-compatible serving patterns
* LiteLLM or similar provider abstraction
* OpenAI and Claude integration
* lightweight RAG and personal knowledge workflows
* llm-d and Kubernetes-native distributed inference concepts
* OpenShift AI alignment and platform architecture patterns
