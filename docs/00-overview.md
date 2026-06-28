# AI Dev Workstation as Code — Overview

## What this is

AI Dev Workstation as Code is my rebuildable, open-source-first, CLI-native AI workstation project.

I am building it to give myself a consistent AI development and productivity environment across multiple devices, while still allowing each device to use the most appropriate local runtime, model provider and workflow tools.

The workstation is intended to support:

- local-first AI usage
- routed access to local and frontier models
- CLI-based workflows
- IDE and UI support where useful
- model fitness checks
- development and vibe coding workflows
- architecture, writing and research workflows
- future agent-based workflows
- reproducible rebuilds on new or refreshed devices

This is not intended to become a one-off experiment or a collection of disconnected scripts. I want it to become a durable AI capability layer that I can keep using, rebuilding and improving over time.

---

## Why I am building this

The AI tooling space is moving quickly. New local runtimes, coding agents, model gateways, frontier models and developer tools are appearing constantly.

Rather than build around a single tool, model or provider, I want this project to take a gateway-first and capability-based approach.

The aim is to keep my way of working stable while allowing the tools underneath to change.

In practice, that means:

```text
Use a stable way of working.
Keep components replaceable.
Keep the environment rebuildable.
Use local models first.
Escalate to frontier models when justified.
Document decisions as the system evolves.
```

---

## Target devices

The initial target devices are:

### Windows laptop

Primary purpose:

- personal AI development lab
- vibe coding
- local model experimentation
- personal project work
- routing experiments
- agent experiments

Likely runtime:

- Ollama

### MacBook Pro

Primary purpose:

- work AI workstation
- architecture workflows
- writing and summarisation
- customer preparation
- local-first coding assistance
- work-safe model routing

Likely runtimes:

- oMLX or MLX-based runtime as the preferred Mac-native path
- Ollama as fallback and compatibility runtime

Approved / first-use AI tools:

- Gemini
- Cursor

Additional frontier providers, depending on use case and approval context:

- Anthropic
- OpenAI

The `macos-work` profile should prioritise approved work AI tools first. Other frontier providers may be used depending on the use case, data sensitivity, approval status and routing policy.

### Future atomic Linux environment

Potential future target:

- Fedora Silverblue
- Fedora Atomic Desktop
- other rebuildable Linux workstation models

Design implications:

- thin host
- containerised services
- user-space tools
- declarative configuration
- minimal manual state
- repeatable bootstrap

---

## What this project is not

This project is not:

- a replacement for every frontier AI tool
- a single-model local chatbot
- a one-off coding setup
- a manually assembled workstation
- a production enterprise AI platform
- a benchmark project for its own sake

I already have access to Claude, OpenAI, Codex and Gemini, so this project is not trying to replace those tools from day one.

Instead, I want to build my own local and routed AI workstation foundation that can become part of my daily workflow.

---

## Architectural north star

The workstation should be:

- open-source-first
- CLI-native
- gateway-first
- local-first
- frontier-capable
- composable
- replaceable
- rebuildable
- observable
- profile-driven
- work/personal aware
- model-fitness informed
- agent-ready

The workflows I build around should remain stable even when tools underneath are replaced.

---

## Current strategy

The chosen approach is:

```text
Gateway-first, usage-led AI workstation.
```

This means the first priority is not to build a coding agent or UI. The first priority is to establish the AI control plane:

- profiles
- providers
- gateway
- routing
- model aliases
- CLI access
- validation checks
- rebuildable setup

Once the control plane exists, I can add coding tools, Open WebUI, work personas, model fitness checks and agents in a controlled way.

---

## Documentation map

The documentation is split into focused files:

```text
docs/00-overview.md
docs/01-vision.md
docs/02-principles.md
docs/03-architecture.md
docs/04-capability-contracts.md
docs/05-component-lifecycle.md
docs/06-profiles.md
docs/07-routing-strategy.md
docs/08-rebuild-strategy.md
docs/09-tool-selection.md
docs/10-milestones.md
docs/11-cli-interface-contracts.md
docs/12-cli-habit-layer.md
docs/adr/
```

Start with:

- `00-overview.md` for orientation
- `01-vision.md` for the north star
- `02-principles.md` for design rules
- `10-milestones.md` for delivery sequence

---

## Project mantra

Build the way of working, not just the tool.

Keep the interface stable.

Keep the components replaceable.

Keep the environment rebuildable.

Use local models first.

Escalate when justified.

Document everything.
