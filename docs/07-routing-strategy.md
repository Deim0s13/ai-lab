# Routing Strategy

This document defines the routing strategy for AI Dev Workstation as Code.

Routing determines which provider, runtime and model should handle a task.

The workstation should be local-first, but frontier-capable. It should use local models where appropriate and escalate to Anthropic, OpenAI, Gemini or other providers when justified.

---

## 1. Purpose

The routing strategy exists to avoid hard-coding tools and models into daily workflows.

Instead of asking the user to remember which model to use for each task, the workstation should provide stable commands and use routing policy to select an appropriate path.

Example:

```bash
ask-ai "Explain this error"
```

The command should not need to know whether the answer comes from Ollama, oMLX, Anthropic, OpenAI or Gemini.

---

## 2. Routing principles

Routing should follow these principles:

- local-first
- frontier-capable
- profile-aware
- task-aware
- privacy-aware
- observable
- configurable
- replaceable

The system should prefer configuration over hard-coded routing logic.

---

## 3. Routing tiers

The workstation should use routing tiers.

```text
Tier 1 — local fast
Small or efficient local model for simple tasks.

Tier 2 — local capable
Larger local model for coding, summarisation and general reasoning.

Tier 3 — local specialist
Specialist local model for coding, embeddings, reranking, vision or other specific tasks.

Tier 4 — frontier
Anthropic, OpenAI, Gemini or another frontier provider for complex tasks.
```

---

## 4. Default route

The default route should be local.

Default behaviour:

```text
Use local unless there is a clear reason to escalate.
```

Reasons to escalate may include:

- task complexity
- poor local result
- customer-facing quality requirements
- complex coding task
- multi-file debugging
- strategic reasoning
- large synthesis
- explicit user request
- route policy

---

## 5. Explicit route controls

The CLI should allow explicit route control.

Examples:

```bash
ask-ai --local "Summarise this note"
ask-ai --best "Help me reason through this design"
ask-ai --explain-route "Fix this error"
```

Suggested meanings:

```text
--local
Force local route where possible.

--best
Use the best available route, including frontier if justified.

--explain-route
Show how the routing decision was made.
```

---

## 6. Task types

Routing should classify tasks into broad task types.

Initial task types:

```text
general_question
quick_rewrite
summarisation
coding_explanation
coding_generation
coding_debugging
architecture_review
writing_polish
research_synthesis
model_selection
agent_workflow
```

The classifier does not need to be sophisticated at first. It can start as simple rule-based matching and evolve over time.

---

## 7. Example task routing

| Task type | Default route | Escalation path |
|---|---|---|
| general question | local capable | frontier if complex |
| quick rewrite | local fast | frontier if high-stakes |
| summarisation | local capable | frontier for large synthesis |
| coding explanation | local code | frontier if complex |
| coding generation | local code | frontier for multi-file or architecture-heavy work |
| coding debugging | local code | frontier if local fails |
| architecture review | local reasoning | frontier for strategic/customer-facing work |
| writing polish | local capable | frontier for executive or sensitive outputs |
| research synthesis | local summary | frontier synthesis |
| model selection | local / llmfit-informed | none by default |
| agent workflow | route by workflow | frontier if policy allows |

---

## 8. Profile-aware routing

Routing must respect the selected profile.

### macos-work

Default posture:

```text
local-first
conservative frontier escalation
work context protected
architecture and writing workflows enabled
```

Example:

```yaml
profile: macos-work
default_route: local
require_confirmation_for_frontier: true
allow_work_context_to_frontier: false
```

### windows-personal

Default posture:

```text
local-first
more experimental
personal project workflows enabled
coding workflows enabled
```

Example:

```yaml
profile: windows-personal
default_route: local
require_confirmation_for_frontier: true
allow_personal_context_to_frontier: ask
```

### fedora-atomic

Default posture:

```text
local-first
thin-host
rebuildable
profile-specific privacy behaviour
```

---

## 9. Provider-aware routing

Initial provider categories:

```text
local:
  - ollama
  - omlx

frontier:
  - anthropic
  - openai
  - gemini
```

Provider selection should consider:

- profile
- task type
- model availability
- runtime availability
- privacy policy
- cost policy
- current model shortlist
- llmfit results

---

## 10. Model aliases

The system should use model aliases rather than hard-code model names into workflows.

Example aliases:

```yaml
aliases:
  local_fast:
    provider: ollama
    model: small-local-model

  local_capable:
    provider: ollama
    model: capable-local-model

  local_code:
    provider: ollama
    model: code-local-model

  local_macos_fast:
    provider: omlx
    model: mlx-fast-model

  frontier_reasoning:
    provider: anthropic
    model: claude-model

  frontier_general:
    provider: openai
    model: gpt-model

  frontier_alternative:
    provider: gemini
    model: gemini-model
```

The exact models should be updated over time based on llmfit, real usage and provider changes.

---

## 11. Escalation policy

Escalation should be deliberate.

A task may escalate when:

- local output is low quality
- local model cannot complete the task
- user asks for best quality
- route policy marks the task as complex
- coding task crosses a complexity threshold
- output is senior-facing or customer-facing
- research synthesis requires stronger reasoning

For work profile use, frontier escalation should require confirmation when work context may be involved.

---

## 12. Privacy-aware routing

Routing should consider content sensitivity.

Examples of content that should not be sent to frontier providers without explicit approval:

- customer confidential information
- credentials
- private internal documentation
- sensitive work notes
- personal information
- raw work context that has not been reviewed

Possible route decision:

```text
Task: architecture review
Profile: macos-work
Context: work
Default route: local_reasoning
Frontier escalation: blocked unless explicitly approved
```

---

## 13. Routing observability

The workstation should be able to explain its route.

Example output:

```text
Task type: coding_debugging
Profile: windows-personal
Route: local_code
Provider: ollama
Model: qwen-coder or configured equivalent
Reason: local-first policy, coding task, no frontier escalation requested
```

For frontier escalation:

```text
Task type: architecture_review
Profile: macos-work
Initial route: local_reasoning
Escalation route: frontier_reasoning
Status: confirmation required
Reason: customer-facing strategic output
```

---

## 14. Initial routing implementation

The first implementation can be simple.

Suggested first stage:

- YAML-based routes
- model aliases
- profile-aware defaults
- simple CLI flags
- basic route explanation
- manual escalation

The first implementation does not need advanced semantic routing.

The goal is to create a routing foundation that can evolve.

---

## 15. Future routing improvements

Future improvements may include:

- semantic classification
- prompt-size-based routing
- automatic retry and fallback
- quality checks
- cost-aware routing
- latency-aware routing
- model availability checks
- llmfit-informed model updates
- per-profile route tuning
- agent-specific routing

---

## 16. Routing configuration location

Suggested location:

```text
config/routing/
├── routes.yaml
├── aliases.yaml
├── policies.yaml
└── escalation-rules.yaml
```

These files should eventually be read by:

- gateway configuration
- CLI wrappers
- validation scripts
- future agent workflows

---

## 17. Summary

The routing strategy should keep daily workflows simple while allowing the model layer to evolve.

The principle is:

```text
User chooses the task.
The workstation chooses the route.
The route is explainable.
The configuration is replaceable.
```
