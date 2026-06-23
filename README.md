# AI Lab

AI Lab is evolving into an **AI Dev Workstation as Code**.

This repository defines a rebuildable, open-source-first, CLI-native AI development and productivity workstation. It is designed to support local-first AI usage, routed access to frontier models, development workflows, work/persona contexts, model fitness checks and future agent-based workflows.

The aim is not to build a one-off local chatbot or a pile of scripts. The aim is to create a durable AI workstation foundation that can be rebuilt, adapted and extended over time.

---

## Current Status

This project is in the **foundation design and build phase**.

The current focus is:

- documenting the architecture
- defining the project principles
- creating the profile model
- defining the routing strategy
- establishing rebuildability
- selecting initial open-source tools
- preparing the first gateway-based implementation

The first implementation milestone is:

```text
Milestone 1 — Rebuildable Gateway Foundation
```

---

## What This Is

AI Lab is intended to become a personal AI workstation layer that can run across multiple devices.

It should support:

- local model usage
- model routing
- frontier model escalation
- CLI-first workflows
- Open WebUI or similar chat UI support
- development and vibe coding workflows
- architecture and writing workflows
- model fitness review
- work and personal profile separation
- future controlled agents
- future RAG and project memory workflows
- reproducible rebuilds on new or refreshed devices

---

## What This Is Not

This project is not:

- a production enterprise AI platform
- a single-model chatbot
- a replacement for every frontier AI tool
- a benchmark project for its own sake
- a manually assembled workstation
- a collection of disconnected experiments

The user already has access to Claude, OpenAI, Codex and Gemini. This project does not need to immediately replace those tools.

Instead, it provides a local and routed AI workstation foundation that can become part of daily use.

---

## Architectural Direction

The selected direction is:

```text
Open-source-first, CLI-native, gateway-first, composable, rebuildable AI Dev Workstation.
```

The project should be:

- **open-source-first** — adopt active open-source tools before building custom functionality
- **CLI-native** — the terminal is a first-class interface
- **gateway-first** — route model access through a common control plane where practical
- **local-first** — use local models by default where appropriate
- **frontier-capable** — escalate to Anthropic, OpenAI, Gemini or other providers when justified
- **composable** — build around capabilities, not fixed tools
- **replaceable** — allow components to be swapped as better options emerge
- **rebuildable** — recover the environment from code and configuration
- **observable** — explain routing and provider decisions where practical
- **profile-driven** — support different behaviour per device and use case

---

## Target Devices

### MacBook Pro

Profile:

```text
macos-work
```

Primary purpose:

- work AI workstation
- architecture workflows
- writing and summarisation
- customer preparation
- local-first coding assistance
- work-safe routing

Expected local runtimes:

- oMLX / MLX-compatible runtime
- Ollama fallback

Expected frontier providers:

- Anthropic
- OpenAI
- Gemini, if useful

---

### Windows Laptop

Profile:

```text
windows-personal
```

Primary purpose:

- personal AI development lab
- vibe coding
- local model experimentation
- personal project work
- routing experiments
- future agent experimentation

Expected local runtime:

- Ollama

Expected environment:

- Windows
- WSL2
- local GPU where available
- container runtime

---

### Future Atomic Linux Workstation

Profile:

```text
fedora-atomic
```

Potential targets:

- Fedora Silverblue
- Fedora Atomic Desktop
- other rebuildable or atomic Linux environments

Design pattern:

- thin host
- Podman-first services
- user-space tools
- declarative configuration
- repeatable bootstrap

---

## Initial Tool Candidates

These are initial candidates and may change as the project evolves.

| Capability | Initial Candidate |
|---|---|
| Model gateway | LiteLLM |
| Windows local runtime | Ollama |
| macOS local runtime | oMLX / MLX-compatible runtime |
| macOS fallback runtime | Ollama |
| Chat UI | Open WebUI |
| CLI coding assistant | Aider / OpenCode |
| Agent runner | Goose |
| Model fitness | llmfit |
| Frontier providers | Anthropic, OpenAI, Gemini |

Tools are treated as implementations of capabilities. They can be trialled, adopted, replaced or removed over time.

---

## Repository Structure

Target structure:

```text
ai-lab/
├── README.md
├── CHANGELOG.md
├── bootstrap/
├── profiles/
├── packages/
├── containers/
├── config/
├── contexts/
├── dotfiles/
├── tools/
├── systemd/
├── docs/
├── tests/
├── labs/
└── archive/
```

Key directories:

| Directory | Purpose |
|---|---|
| `docs/` | Project architecture, principles, milestones and decisions |
| `docs/adr/` | Architecture Decision Records |
| `profiles/` | Device and use-case profiles |
| `config/` | Providers, routing, models, policies and capabilities |
| `containers/` | Containerised services such as gateway and chat UI |
| `bootstrap/` | Rebuild and setup scripts |
| `tools/` | CLI wrappers and workstation commands |
| `contexts/` | Shared, work, personal and persona context |
| `tests/` | Validation and health checks |
| `labs/` | Learning notes and practical experiments |
| `archive/` | Legacy notes, previous experiments and historical material |

---

## Documentation

Start here:

| Document | Purpose |
|---|---|
| `docs/00-overview.md` | Project overview and orientation |
| `docs/01-vision.md` | Long-term vision and direction |
| `docs/02-principles.md` | Design principles |
| `docs/03-architecture.md` | Target architecture |
| `docs/04-capability-contracts.md` | Capability-based design |
| `docs/05-component-lifecycle.md` | How tools move from candidate to preferred or removed |
| `docs/06-profiles.md` | Device profile model |
| `docs/07-routing-strategy.md` | Local and frontier routing approach |
| `docs/08-rebuild-strategy.md` | Rebuildability and workstation-as-code approach |
| `docs/09-tool-selection.md` | How tools are selected |
| `docs/10-milestones.md` | Delivery roadmap |

Architecture decisions are recorded in:

```text
docs/adr/
```

---

## Milestones

The planned delivery path is:

```text
Milestone 1 — Rebuildable Gateway Foundation
Milestone 2 — CLI Habit Layer
Milestone 3 — Model Fitness Loop
Milestone 4 — UI Parity
Milestone 5 — Development Workflow
Milestone 6 — Work Persona Layer
Milestone 7 — Controlled Agents
Milestone 8 — RAG / Project Memory
```

The project will evolve in small, usable stages.

Each milestone should produce durable capability rather than novelty.

---

## Milestone 1: Rebuildable Gateway Foundation

The first milestone establishes the spine of the workstation.

Expected deliverables:

- profile definitions
- package declaration placeholders
- `.env.example`
- gateway configuration
- provider placeholders
- basic routing configuration
- container configuration
- basic `ask-ai`
- basic `ai-status`
- basic `ai-route`
- basic `ai-bootstrap-check`
- llmfit result capture location

Success looks like:

```bash
git clone https://github.com/Deim0s13/ai-lab.git
cd ai-lab
./bootstrap/bootstrap.sh --profile macos-work
ai-bootstrap-check
ask-ai "Explain what this workstation does"
```

This will evolve as implementation begins.

---

## Rebuildability

The workstation should be rebuildable from code and configuration.

The target rebuild flow is:

```text
Clone repository
Select profile
Install package dependencies
Apply configuration
Start services
Install or verify models
Run validation checks
Use workstation
```

The repository should be the source of truth.

Manual machine state should be avoided or documented.

---

## Secrets

Secrets must not be committed to the repository.

The initial approach is:

```text
.env.example   committed
.env.local     ignored
```

Expected secrets may include:

```text
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GEMINI_API_KEY=
```

Future options may include 1Password CLI, `pass`, `sops` with `age`, or OS keychain integration.

---

## Working Principles

The project is guided by these principles:

```text
Build the way of working, not just the tool.

Keep the interface stable.

Keep the components replaceable.

Keep the environment rebuildable.

Use local models first.

Escalate when justified.

Document everything.
```

---

## Current Project Mantra

```text
Stable workflow.
Replaceable components.
Rebuildable workstation.
```
