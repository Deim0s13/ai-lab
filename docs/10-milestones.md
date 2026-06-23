# Milestones

This document defines the delivery milestones for AI Dev Workstation as Code.

The project should evolve in small, usable stages. Each milestone should add durable capability without overbuilding.

The aim is not to rush to a complete AI workstation. The aim is to build a foundation that becomes useful, trusted and reusable over time.

---

## 1. Delivery approach

The selected approach is:

```text
Gateway-first, usage-led build.
```

This means:

- build the control plane first
- make the CLI useful early
- add model fitness as a discipline
- connect UI and coding tools to the same gateway
- introduce work personas after routing is stable
- introduce agents only after the foundation is trusted

---

## 2. Milestone summary

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

---

# Milestone 1 — Rebuildable Gateway Foundation

## Goal

Create a reproducible foundation that can install, configure, run and validate the AI gateway layer on a target device.

This milestone establishes the spine of the workstation.

## Deliverables

- repository structure
- foundation documentation
- profile definitions
- package declaration placeholders
- `.env.example`
- ignored `.env.local`
- LiteLLM or equivalent gateway configuration
- provider placeholders
- Ollama provider configuration
- Anthropic provider placeholder
- OpenAI provider placeholder
- Gemini provider placeholder
- basic routing configuration
- initial container configuration
- basic `ask-ai`
- basic `ai-status`
- basic `ai-route`
- basic `ai-bootstrap-check`
- llmfit result capture location

## Success criteria

The user can clone the repo, select a profile, run bootstrap, start the gateway and validate that the workstation foundation is working.

Example:

```bash
git clone https://github.com/Deim0s13/ai-lab.git
cd ai-lab
./bootstrap/bootstrap.sh --profile macos-work
ai-bootstrap-check
ask-ai "Explain what this workstation does"
```

## Not included yet

- full semantic routing
- full Open WebUI setup
- coding agent workflow
- RAG
- agents
- polished cross-platform bootstrap

---

# Milestone 2 — CLI Habit Layer

## Goal

Make the CLI useful enough that it becomes the default local AI entry point for simple tasks.

## Deliverables

- improved `ask-ai`
- route flags
- model aliases
- local route
- frontier route
- explicit `--local`
- explicit `--best`
- explicit `--explain-route`
- optional output saving
- basic context loading
- shell aliases

## Example commands

```bash
ask-ai "Explain this concept"
ask-ai --local "Summarise this note"
ask-ai --best "Help me reason through this design"
ask-ai --explain-route "Fix this Python error"
```

## Success criteria

The user starts using `ask-ai` for small everyday tasks rather than going directly to a standalone model UI.

## Not included yet

- advanced task classification
- agents
- deep IDE integration
- complex memory

---

# Milestone 3 — Model Fitness Loop

## Goal

Use llmfit to inform which models should be used on each device for each task type.

## Deliverables

- llmfit installed
- llmfit results captured per device
- model shortlist created
- desired model list created
- routing configuration updated from results
- `ai-model-review` created
- review rhythm documented

## Output files

```text
config/models/llmfit-windows.md
config/models/llmfit-macos.md
config/models/model-shortlist.yaml
config/models/desired-models.yaml
```

## Success criteria

Model choices are based on actual device and task fit rather than assumptions.

The project can answer:

- what models fit this machine
- what models should be used for coding
- what models should be used for summarisation
- what models should be avoided
- what routes should be updated

## Not included yet

- automated benchmarking platform
- complex dashboards
- automatic model downloads unless needed

---

# Milestone 4 — UI Parity

## Goal

Connect Open WebUI to the same gateway used by the CLI.

The UI should not become a separate AI environment.

## Deliverables

- Open WebUI container configuration
- Open WebUI connected to gateway
- local route available in UI
- frontier routes available in UI where configured
- basic documentation
- profile-aware notes

## Success criteria

The user can access the same model routing layer from both the CLI and Open WebUI.

## Not included yet

- complex multi-user setup
- production hardening
- advanced Open WebUI customisation

---

# Milestone 5 — Development Workflow

## Goal

Add terminal-native coding and vibe coding workflows.

## Deliverables

- evaluate Aider
- evaluate OpenCode
- select preferred CLI coding tool
- document trial results
- connect selected tool through gateway where practical
- define local code route
- define frontier code escalation route
- add `dev-ai` wrapper only if useful

## Success criteria

The user can use a CLI coding assistant for real personal project work, with local-first behaviour and frontier escalation where justified.

## Not included yet

- replacing all Claude Code or Codex usage
- fully autonomous coding agents
- complex multi-agent coding workflows

---

# Milestone 6 — Work Persona Layer

## Goal

Add MBP-specific work workflows for architecture, writing and customer preparation.

## Deliverables

- architect context
- writing style context
- banking / regulated industry context
- customer-prep workflow
- `architect-ai`
- `write-ai`
- work-safe routing policy
- frontier escalation confirmation for work context

## Success criteria

The MacBook Pro profile supports useful local-first architecture and writing workflows without mixing work and personal context.

## Not included yet

- uncontrolled work document ingestion
- automatic upload of sensitive work context to frontier models
- large-scale RAG

---

# Milestone 7 — Controlled Agents

## Goal

Introduce agents only after the gateway, CLI, routing and model fitness foundations are stable.

## Candidate workflows

- coding companion
- architecture reviewer
- writing assistant
- research assistant
- project memory assistant

## Deliverables

- select agent runner candidate
- trial Goose or equivalent
- define agent permissions
- define local and frontier routing rules for agents
- define file access boundaries
- document agent trial
- decide whether to adopt

## Success criteria

At least one constrained agent workflow is useful, understandable and safe enough to keep.

## Not included yet

- uncontrolled autonomous agents
- broad system access
- unsupervised work context ingestion

---

# Milestone 8 — RAG / Project Memory

## Goal

Allow the workstation to answer questions from local notes, project documents, repo documentation and selected context.

## Deliverables

- define RAG scope
- select storage/indexing approach
- select embedding approach
- index local project docs
- profile-aware context boundaries
- CLI query workflow
- future agent integration path

## Success criteria

The user can ask questions over selected local project material while maintaining profile boundaries and rebuildability.

## Not included yet

- enterprise-scale RAG
- sensitive work document indexing by default
- complex memory without clear governance

---

## 3. Milestone sequencing

Recommended order:

```text
1. Rebuildable Gateway Foundation
2. CLI Habit Layer
3. Model Fitness Loop
4. UI Parity
5. Development Workflow
6. Work Persona Layer
7. Controlled Agents
8. RAG / Project Memory
```

This order creates a stable control plane before adding more complex workflows.

---

## 4. Definition of done for foundation phase

The foundation phase is complete when:

- the repository has a clear structure
- documentation exists
- the gateway can run
- at least one local provider can be reached
- at least one frontier provider can be configured
- the selected profile can be loaded
- `ask-ai` can send a prompt
- `ai-status` can report health
- `ai-bootstrap-check` can validate the setup
- llmfit has a place in the workflow
- the next phase is clearly documented

---

## 5. Working backlog

## Immediate

- finalise foundation docs
- write initial ADRs
- create profile templates
- create `.env.example`
- add gateway config skeleton
- add bootstrap skeleton
- add validation skeleton

## Next

- add Ollama provider
- add Anthropic provider
- add OpenAI provider
- add Gemini provider
- add Open WebUI compose file
- add initial `ask-ai`
- add initial `ai-status`
- add initial `ai-route`

## Later

- add oMLX / MLX path
- add Aider evaluation
- add OpenCode evaluation
- add Goose evaluation
- add work personas
- add RAG-lite
- add controlled agents
- add model review automation

---

## 6. Guiding delivery rule

Each milestone should produce something usable.

The project should not optimise for novelty or completeness.

The guiding rule is:

```text
Build durable capability.
Use it.
Learn from it.
Then extend it.
```
