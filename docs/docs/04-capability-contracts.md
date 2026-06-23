# Capability Contracts

This document defines the major capabilities required by AI Dev Workstation as Code.

A capability is a function the workstation must provide.

A tool is only an implementation of a capability.

This distinction is important because the AI tooling landscape is moving quickly. Tools may change, but the required capabilities should remain relatively stable.

---

## 1. Purpose

Capability contracts help keep the workstation modular and replaceable.

Each capability should define:

- what it is responsible for
- what it must support
- current candidate tools
- replacement criteria
- current status

This allows tools to be added, trialled, replaced or removed without redesigning the whole system.

---

## 2. Contract status values

Each capability implementation should have a status.

```text
Candidate → Trial → Adopted → Preferred → Deprecated → Removed
```

Status definitions are described in `docs/05-component-lifecycle.md`.

---

## 3. Capability: Model Gateway

### Purpose

Provide a common access layer between user-facing tools and model providers.

### Must support

- multiple providers
- local and frontier models
- OpenAI-compatible API access where practical
- model aliases
- routing or fallback behaviour
- CLI clients
- UI clients
- IDE or agent clients where practical
- configuration-driven behaviour

### Current candidate

- LiteLLM

### Replacement criteria

A replacement must provide:

- provider abstraction
- local and frontier support
- OpenAI-compatible access or equivalent interoperability
- simple configuration
- active maintenance
- usable local deployment
- compatibility with CLI and UI clients

### Current status

Candidate / Trial

---

## 4. Capability: Local Runtime

### Purpose

Run local models on the target device.

### Must support

- local model execution
- API access
- model management
- reasonable performance on the target device
- integration with the gateway
- CLI usability
- repeatable installation

### Current candidates

- Ollama
- oMLX / MLX-compatible runtime

### Replacement criteria

A replacement must provide:

- local model execution
- stable API or gateway integration
- device-appropriate performance
- active maintenance
- usable model management
- clear installation path

### Current status

Ollama: Adopted for Windows personal profile  
oMLX / MLX-compatible runtime: Candidate for macOS work profile  
Ollama on macOS: Candidate fallback

---

## 5. Capability: Frontier Provider

### Purpose

Provide access to frontier models for tasks that justify escalation.

### Must support

- high-quality reasoning
- coding support
- summarisation and writing support
- API access
- gateway integration
- clear cost and privacy controls

### Current candidates

- Anthropic
- OpenAI
- Gemini

### Replacement criteria

A replacement must provide:

- strong model quality
- reliable API
- gateway compatibility
- clear model naming
- acceptable cost and privacy characteristics

### Current status

Candidate

---

## 6. Capability: CLI General Assistant

### Purpose

Provide a terminal-first way to ask questions, summarise content, rewrite text, test routing and interact with the gateway.

### Must support

- CLI use
- gateway access
- local-first routing
- explicit frontier escalation
- output to terminal
- optional output saving
- optional context loading
- route explanation where practical

### Current candidate

- `ask-ai` wrapper

### Replacement criteria

A replacement must provide:

- reliable CLI usage
- gateway compatibility
- simple invocation
- configurable model routes
- local and frontier support

### Current status

Planned

---

## 7. Capability: CLI Coding Assistant

### Purpose

Support terminal-native development and vibe coding.

### Must support

- CLI-first usage
- repo-aware coding
- code explanation
- code generation
- code editing
- test-fix workflows
- local model support
- frontier model support
- gateway integration where practical
- safe file modification behaviour

### Current candidates

- Aider
- OpenCode

### Replacement criteria

A replacement must provide:

- mature CLI workflow
- repo awareness
- model provider flexibility
- active maintenance
- local model support
- frontier model support
- usable file editing model
- good developer experience

### Current status

Candidate

---

## 8. Capability: Chat UI

### Purpose

Provide a self-hosted chat interface that can use the same gateway and provider layer as the CLI.

### Must support

- self-hosting
- local model usage
- OpenAI-compatible endpoint support
- gateway integration
- reasonable usability
- profile-aware configuration where practical

### Current candidate

- Open WebUI

### Replacement criteria

A replacement must provide:

- self-hosted operation
- gateway compatibility
- local and frontier model support
- active maintenance
- usable chat interface

### Current status

Candidate / Trial

---

## 9. Capability: Model Fitness

### Purpose

Assess which models are appropriate for each device and task.

### Must support

- hardware detection
- model suitability assessment
- local runtime awareness
- repeatable reporting
- CLI usage
- model shortlist input

### Current candidate

- llmfit

### Replacement criteria

A replacement must provide:

- device-aware model assessment
- usable CLI output
- support for local runtimes
- repeatable model review process
- clear results that can inform routing decisions

### Current status

Candidate

---

## 10. Capability: Architecture Assistant

### Purpose

Support architecture thinking, customer preparation, platform comparison, option analysis and decision review.

### Must support

- CLI usage
- work profile support
- context loading
- architecture persona
- local-first behaviour
- frontier escalation when justified
- clear output suitable for refinement

### Current candidate

- `architect-ai` wrapper over the gateway

### Replacement criteria

A replacement must provide:

- stable CLI workflow
- context and persona support
- gateway compatibility
- local and frontier routing
- output quality suitable for architecture work

### Current status

Planned

---

## 11. Capability: Writing Assistant

### Purpose

Support writing, rewriting, summarising and tone refinement.

### Must support

- CLI usage
- local-first rewriting
- optional frontier escalation
- writing style context
- output saving
- support for work-safe workflows

### Current candidate

- `write-ai` wrapper over the gateway

### Replacement criteria

A replacement must provide:

- strong CLI workflow
- context loading
- tone/style control
- local and frontier support
- gateway compatibility

### Current status

Planned

---

## 12. Capability: Research Assistant

### Purpose

Support topic exploration, comparison, note synthesis and structured research workflows.

### Must support

- CLI usage
- local summarisation
- frontier escalation for synthesis
- source capture where applicable
- future agent support
- future RAG support

### Current candidate

- `research-ai` wrapper or future agent workflow

### Replacement criteria

A replacement must provide:

- repeatable research workflow
- local and frontier support
- source/context management
- CLI access
- gateway compatibility

### Current status

Planned

---

## 13. Capability: Agent Runner

### Purpose

Run constrained multi-step workflows for coding, research, writing, architecture review and future task automation.

### Must support

- CLI usage
- provider flexibility
- tool use
- constrained scope
- explicit permissions
- local and frontier model options
- future MCP or equivalent integration where useful

### Current candidate

- Goose

### Replacement criteria

A replacement must provide:

- active maintenance
- CLI support
- tool use
- provider flexibility
- safety controls
- local and frontier model support
- good workflow ergonomics

### Current status

Candidate for later milestone

---

## 14. Capability: RAG / Project Memory

### Purpose

Allow the workstation to answer questions from local notes, project documents, repo documentation and selected context.

### Must support

- local document indexing
- retrieval
- embedding model support
- profile-aware context boundaries
- local-first behaviour
- future integration with agents and CLI tools

### Current candidates

- Not yet selected

### Replacement criteria

A replacement must provide:

- local-first operation
- clear data storage model
- good CLI or API integration
- gateway compatibility
- replaceable storage and embedding options
- understandable rebuild process

### Current status

Future

---

## 15. Capability: Validation

### Purpose

Check that the workstation is installed, configured and running correctly.

### Must support

- profile detection
- provider checks
- gateway health checks
- CLI checks
- container/service checks
- secret presence checks
- model availability checks
- action-oriented output

### Current candidate

- `ai-bootstrap-check`
- `ai-status`

### Replacement criteria

A replacement must provide:

- reliable local validation
- clear pass/fail output
- suggested next actions
- cross-platform support where practical

### Current status

Planned

---

## 16. Capability review process

When a new tool is considered, it should be assessed against the relevant capability contract.

Questions to ask:

- What capability does this tool satisfy?
- Is there already a tool in that capability?
- Is this a replacement, complement or experiment?
- Does it support CLI usage?
- Does it support local models?
- Does it support frontier models?
- Does it integrate with the gateway?
- Is it actively maintained?
- Can it be installed reproducibly?
- Can it be removed cleanly?

The goal is not to collect tools.

The goal is to build durable capabilities.
