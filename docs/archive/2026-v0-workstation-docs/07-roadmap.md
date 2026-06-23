# Roadmap

## Purpose

This document captures the planned direction for the AI Lab project.

The roadmap is intentionally practical. It is not designed to turn the project into a large platform too quickly. The aim is to build capability in small, useful stages while deepening understanding of AI infrastructure, model workflows, local inference, routing, APIs, containers, and architecture-focused use cases.

The project should remain:

* useful
* understandable
* role-aligned
* portable
* version-controlled
* interesting enough to keep using

---

## Current State

The current project provides a working personal AI-augmented architecture workstation.

Current capabilities include:

* WSL2 Ubuntu-based Linux workflow
* NVIDIA GPU-backed local inference
* Ollama as the local model runtime
* Open WebUI as a local browser-based AI interface
* Open WebUI managed through Podman Quadlet
* Continue.dev connected to local models
* CLI-based AI workflow tools
* reusable persona, style, and domain context
* basic model routing
* health checks and safe remediation
* API testing against the Ollama HTTP API

Current tools:

| Tool              | Purpose                                       |
| ----------------- | --------------------------------------------- |
| `ask-ollama`      | General local AI CLI interface                |
| `architect-ai`    | Architecture-focused workflow wrapper         |
| `ai-status`       | Workstation health check and safe remediation |
| `ai-gpu-check`    | Focused GPU acceleration validation           |
| `ollama-api-test` | Direct Ollama API testing and learning tool   |

Current models:

| Model             | Intended Use                                                            |
| ----------------- | ----------------------------------------------------------------------- |
| `qwen3:14b`       | General architecture explanation and everyday reasoning                 |
| `deepseek-r1:14b` | Deeper reasoning, comparison, risk, trade-off and strategy work         |
| `llama3.1:8b`     | Lightweight rewrites, short responses, quick summaries and simple tasks |

---

## Completed Workstreams

| Workstream                    | Status   |
| ----------------------------- | -------- |
| Local inference understanding | Complete |
| API awareness                 | Complete |
| Container understanding       | Complete |
| GPU acceleration              | Complete |
| Linux workflow maturity       | Complete |
| Model orchestration v0.1      | Complete |

---

## Version Direction

The project is evolving in stages.

```text
v0.1 — Initial workstation setup
v0.2 — Core workstreams and validation tools
v0.3 — Workflow maturity and routing intelligence
v0.4 — vLLM exploration
v0.5 — Hybrid model providers
v0.6 — RAG and knowledge workflows
v0.7 — Kubernetes-native inference concepts
```

This may change as the project evolves.

---

# v0.1 — Initial Workstation Setup

## Theme

Build the first working local AI workstation.

## Focus

* install and configure WSL2 Ubuntu
* configure terminal and shell experience
* install Ollama
* run local models
* install Open WebUI
* configure Continue.dev
* create early CLI helpers

## Outcomes

* local models running
* browser-based AI interface available
* editor-based AI assistant available
* first terminal-based AI workflow created

## Status

Complete.

---

# v0.2 — Core Workstreams and Validation Tools

## Theme

Move from “installed tools” to a usable and observable local AI workstation.

## Focus

* understand local inference
* expose the API layer
* manage Open WebUI as a Podman service
* validate GPU acceleration
* organise the project for GitHub
* introduce basic model routing

## Delivered

### Local Inference Understanding

Created `ai-status` to check:

* Ollama runtime
* Ollama API
* available models
* active models
* Open WebUI
* safe remediation

### API Awareness

Created `ollama-api-test` to call the Ollama HTTP API directly.

This made the API path visible:

```text
CLI tool
  ↓
HTTP API
  ↓
Ollama runtime
  ↓
Local model
  ↓
Response
```

### Container Understanding

Moved Open WebUI to a Podman Quadlet-managed user service.

This introduced:

* container lifecycle
* persistent data
* systemd user services
* logs and restart behaviour
* service-based operation

### GPU Acceleration

Created `ai-gpu-check` to validate:

* NVIDIA GPU visibility
* CUDA library visibility
* Ollama service state
* active model processor usage

### Linux Workflow Maturity

Organised the project into a Git-backed structure:

```text
~/projects/ai-lab/
├── tools/
├── tools/context/
├── containers/
└── docs/
```

### Model Orchestration v0.1

Added `--auto` routing to `ask-ollama`.

Current routing:

| Task Type                                  | Model             |
| ------------------------------------------ | ----------------- |
| Explain / summarise / general architecture | `qwen3:14b`       |
| Compare / risk / trade-offs / strategy     | `deepseek-r1:14b` |
| Rewrite / concise / quick tasks            | `llama3.1:8b`     |

## Status

Complete.

---

# v0.3 — Workflow Maturity and Routing Intelligence

## Theme

Make the project more coherent, documented, repeatable, and intelligent.

## Goal

Move from a working set of tools to a more polished personal AI workflow platform.

## Planned Focus Areas

### 1. Documentation Improvement

Create and improve:

```text
README.md
docs/
├── 01-workstation-overview.md
├── 02-setup-and-prerequisites.md
├── 03-tools-reference.md
├── 04-open-webui-podman-quadlet.md
├── 05-gpu-and-ollama-troubleshooting.md
├── 06-model-routing.md
└── 07-roadmap.md
```

The purpose is to make the project easy to understand, rebuild, and continue after time away.

### 2. Improve `architect-ai`

Make `architect-ai` feel more like a proper architecture workflow assistant.

Potential improvements:

* refine command prompts
* ensure `--auto` routing is used by default
* improve consistency of output structure
* add clearer help text
* add examples for banking scenarios
* add customer-facing workflow commands

Potential command examples:

```bash
architect-ai banking compare "OpenShift AI vs SageMaker"
architect-ai banking risks "self-hosted AI platform"
architect-ai summary "platform engineering"
architect-ai discovery "enterprise AI adoption"
architect-ai position "OpenShift Virtualization"
architect-ai challenge "AI platform operating model"
```

### 3. Add Route Explanation Mode

Add a way to show why a model was selected.

Potential example:

```bash
ask-ollama --auto --explain-route "Compare OpenShift AI and SageMaker"
```

Expected output:

```text
Selected model: deepseek-r1:14b
Reason: The prompt appears to require comparison, trade-off analysis, and strategic evaluation.
```

This would make orchestration more transparent and useful for learning.

### 4. Improve Routing v0.2

Move from simple keyword routing to a slightly smarter classifier-based approach.

Current:

```text
keyword match
  ↓
model selection
```

Future:

```text
prompt
  ↓
classify task type
  ↓
select model
  ↓
generate response
```

Potential task types:

| Task Type             | Suggested Model              |
| --------------------- | ---------------------------- |
| explanation           | `qwen3:14b`                  |
| comparison            | `deepseek-r1:14b`            |
| risk_analysis         | `deepseek-r1:14b`            |
| strategy              | `deepseek-r1:14b`            |
| rewrite               | `llama3.1:8b`                |
| executive_summary     | `qwen3:14b` or `llama3.1:8b` |
| discovery_questions   | `qwen3:14b`                  |
| challenge_assumptions | `deepseek-r1:14b`            |

### 5. Add Project Versioning

Add basic version tracking.

Potential files:

```text
CHANGELOG.md
VERSION
```

Initial changelog structure:

```markdown
# Changelog

## v0.3.0 — Workflow Maturity and Routing Intelligence
- Improved documentation
- Improved architect-ai workflows
- Added route explanation mode
- Improved model routing
- Added clearer roadmap

## v0.2.0 — Core Workstreams and Validation Tools
- Added ai-status
- Added ai-gpu-check
- Added ollama-api-test
- Added Open WebUI Quadlet
- Added basic model routing

## v0.1.0 — Initial Workstation Setup
- Installed Ollama
- Configured Open WebUI
- Configured Continue.dev
- Created ask-ollama and architect-ai
```

## Definition of Done

v0.3 is complete when:

* README is improved
* docs are structured and populated
* `architect-ai` is refined
* route explanation mode exists
* routing v0.2 is implemented or clearly planned
* changelog exists
* roadmap is updated
* project is easier to understand and resume

---

# v0.4 — vLLM Exploration

## Theme

Explore production-style local inference serving.

## Goal

Move beyond Ollama as the only local runtime and understand a more production-oriented model serving pattern.

## Why vLLM Matters

Ollama is excellent for local experimentation and workflow building.

vLLM introduces concepts closer to production model serving:

* model server process
* OpenAI-compatible API
* serving configuration
* runtime performance considerations
* model loading behaviour
* API compatibility
* integration with tools that expect OpenAI-style endpoints

## Potential Focus Areas

* install vLLM in WSL2
* run a local model through vLLM
* expose an OpenAI-compatible endpoint
* call vLLM with `curl`
* compare the developer experience with Ollama
* test whether Open WebUI can point at vLLM
* test whether local workflow scripts can call vLLM
* understand where vLLM fits architecturally

## Possible Deliverables

* `vllm-api-test`
* vLLM setup notes
* OpenAI-compatible endpoint example
* comparison document: Ollama vs vLLM
* updated architecture diagram

## Key Learning Questions

* What does vLLM provide that Ollama does not?
* How does OpenAI-compatible serving work?
* What changes when the model runtime exposes a different API?
* What would be relevant in an enterprise AI platform conversation?
* How does vLLM relate to OpenShift AI model serving patterns?

---

# v0.5 — Hybrid Model Providers

## Theme

Introduce local and external model provider orchestration.

## Goal

Move from local-only AI to hybrid model access.

Potential providers:

* local Ollama
* local vLLM
* OpenAI
* Claude
* Gemini
* other OpenAI-compatible endpoints

## Why This Matters

Real AI architectures are often hybrid.

Different workloads may require different providers depending on:

* privacy
* sensitivity
* latency
* cost
* quality
* reasoning depth
* offline availability
* enterprise controls

## Potential Focus Areas

* introduce provider abstraction
* store API keys safely
* call external providers from CLI tools
* add provider selection logic
* route local/private prompts to local models
* route complex strategic work to external providers when appropriate
* compare local and external responses

## Potential Tools or Patterns

* LiteLLM or similar abstraction layer
* provider config files
* local-only mode
* external-enabled mode
* policy-aware routing

## Possible Deliverables

* provider configuration file
* external API test script
* routing rules for local vs external models
* updated `ask-ollama` or new generic `ask-ai`
* documentation for provider trade-offs

## Key Learning Questions

* When should local models be preferred?
* When are external models worth using?
* How should sensitive prompts be handled?
* How do provider APIs differ?
* What does abstraction add?
* What governance concerns emerge?

---

# v0.6 — RAG and Knowledge Workflows

## Theme

Introduce local knowledge augmentation.

## Goal

Move from prompting models directly to grounding responses in local knowledge.

## Why RAG Matters

RAG introduces an important AI architecture pattern:

```text
user question
  ↓
retrieve relevant context
  ↓
send context + question to model
  ↓
generate grounded response
```

This is relevant to:

* enterprise knowledge assistants
* architecture repositories
* customer context
* policy and standards search
* platform documentation
* personal knowledge workflows

## Potential Focus Areas

* simple document ingestion
* local markdown notes
* embeddings
* vector store
* search and retrieval
* context injection
* answer generation
* source visibility

## Possible Deliverables

* `ask-docs`
* simple RAG pipeline
* local vector store
* documentation ingestion workflow
* comparison of naive search vs semantic retrieval
* architecture notes search

## Key Learning Questions

* What problem does RAG actually solve?
* What are embeddings?
* What is retrieved?
* How much context is enough?
* How do poor documents affect answer quality?
* How does this relate to enterprise knowledge systems?

---

# v0.7 — Kubernetes-Native Inference Concepts

## Theme

Explore AI inference patterns closer to enterprise platform architecture.

## Goal

Move from a single workstation to understanding Kubernetes-native AI serving and distributed inference concepts.

Potential areas:

* OpenShift AI
* Kubernetes model serving
* llm-d
* Gateway API inference patterns
* distributed inference
* model placement
* inference routing
* platform operations

## Why This Matters

This project is not only about personal productivity. It is also about understanding patterns that matter in enterprise AI platform discussions.

Kubernetes-native inference introduces questions such as:

* Where should models run?
* How are requests routed?
* How are GPUs shared?
* How is capacity managed?
* How is model serving governed?
* How does this integrate with platform teams?
* What does operational maturity look like?

## Potential Focus Areas

* understand llm-d concepts
* map workstation learnings to Kubernetes concepts
* compare local Ollama/vLLM to platform serving
* explore OpenShift AI model serving architecture
* document enterprise platform implications

## Possible Deliverables

* concept notes on llm-d
* architecture comparison: workstation vs OpenShift AI
* model serving reference architecture
* platform operating model notes
* customer discussion guide

## Key Learning Questions

* What changes when inference moves from a workstation to Kubernetes?
* How does routing work in a cluster?
* How does GPU scheduling matter?
* What role does OpenShift AI play?
* Where does llm-d fit?
* What should architects understand before discussing enterprise AI platforms?

---

# Potential Future Areas

These are not committed phases yet, but they may become useful later.

## Agents and Safe Automation

The current project includes safe remediation through `ai-status --fix`.

Future work could explore:

* `ai-doctor`
* diagnosis and explanation
* proposed repair plans
* human-approved remediation
* limited agentic operations

The principle should remain:

```text
observe first
recommend second
fix safely only where the action is known and reversible
```

---

## Evaluation and Quality Comparison

This should not become benchmark obsession, but lightweight quality comparison may be useful.

Potential focus:

* compare model outputs
* capture strengths and weaknesses
* evaluate for architecture usefulness
* compare local vs external models
* compare reasoning and writing quality

---

## Architecture Content Workflows

Potential future workflows:

* customer prep assistant
* executive summary generator
* architecture trade-off assistant
* platform comparison assistant
* objection handling assistant
* discovery question generator
* risk framing assistant

Some of this already exists in `architect-ai`, but it could be improved over time.

---

## Personal Knowledge System

Potential future direction:

* local architecture notes
* customer-safe knowledge capture
* reusable prompts
* architecture patterns
* decision records
* lessons learned
* search and retrieval

This should remain low-friction. The aim is useful knowledge augmentation, not maintaining a complex note-taking system.

---

# Roadmap Principles

## Build Small Useful Capabilities

Each phase should produce something useful.

Avoid large abstract projects that do not improve the workstation or learning.

## Learn Through Use

The project should teach through practical usage, not through theory alone.

## Keep It Architect-Aligned

The goal is not to become a full-time developer or AI engineer.

The goal is to build enough hands-on fluency to have more credible, grounded architecture and customer conversations.

## Avoid Premature Complexity

Do not introduce complex tooling before the pattern is understood.

Examples:

* learn API calls before provider abstraction
* learn routing rules before semantic routing
* learn Ollama before vLLM
* learn local serving before Kubernetes-native inference
* learn safe remediation before agents

## Prefer Rebuildable and Version-Controlled

The workstation should be easy to recreate.

Store in Git:

* tools
* context files
* documentation
* container definitions
* examples

Do not store in Git:

* model files
* runtime data
* secrets
* local caches
* Open WebUI runtime state

---

# Near-Term Next Steps

The likely next v0.3 tasks are:

1. finish documentation refresh
2. add `CHANGELOG.md`
3. refine `architect-ai`
4. add `--explain-route`
5. improve routing to classifier-based routing
6. update examples and validation commands
7. tag or mark the project as v0.3.0 when complete

---

# Summary

The AI Lab project has moved from a workstation setup into a practical AI learning and workflow platform.

The next stage should focus on maturity rather than adding complexity too quickly.

Near-term priority:

```text
make it understandable
make it repeatable
make it useful
make routing smarter
```

Later priorities:

```text
explore vLLM
add hybrid providers
introduce RAG
explore Kubernetes-native inference
connect lessons back to enterprise architecture
```
