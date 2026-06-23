# AI Dev Workstation as Code — Overview

## What this is

AI Dev Workstation as Code is a rebuildable, open-source-first, CLI-native AI workstation project.

It is designed to provide a consistent AI development and productivity environment across multiple devices, while still allowing each device to use the most appropriate local runtime, model provider and workflow tools.

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

This project is not intended to be a one-off experiment or a collection of disconnected scripts. It is intended to become a durable AI capability layer that can evolve over time.

---

## Why this exists

The AI tooling space is moving quickly. New local runtimes, coding agents, model gateways, frontier models and developer tools are appearing constantly.

Rather than building around a single tool, model or provider, this project takes a gateway-first and capability-based approach.

The aim is to keep the user-facing workflow stable while allowing the tools underneath to change.

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

The user already has access to Claude, OpenAI, Codex and Gemini. This project does not need to immediately replace those tools.

Instead, it provides the user’s own local and routed AI workstation foundation.

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

The user-facing workflow should remain stable even when tools underneath are replaced.

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

Once the control plane exists, coding tools, Open WebUI, work personas, model fitness checks and agents can be added in a controlled way.

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
