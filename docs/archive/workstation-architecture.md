# Workstation Architecture

## Current Architecture

```text
Windows 11
└── WSL2 Ubuntu
    ├── NVIDIA GPU passthrough
    ├── Ollama service
    ├── Podman
    ├── Open WebUI via Podman Quadlet
    ├── VS Code + Continue.dev
    └── AI workflow tools
```

## Runtime Layer

```text
Ollama
├── qwen3:14b
├── deepseek-r1:14b
└── llama3.1:8b
```

## Interface Layer

```text
Open WebUI
Continue.dev
CLI tools
```

## Workflow Layer

```text
ask-ollama
architect-ai
ai-status
ai-gpu-check
ollama-api-test
```

## Context Layer

```text
architect.txt
writing-style.txt
banking.txt
```

## Key Concepts

- local inference
- GPU acceleration
- API-driven model access
- containerised AI tooling
- service-managed local AI components
- reusable workflow wrappers