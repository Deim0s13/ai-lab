# Principles

This document defines the design principles for AI Dev Workstation as Code.

These principles should guide architecture decisions, tool selection, implementation choices and future refactoring.

---

## 1. Gateway first

All tools should go through a common AI gateway where practical.

The gateway provides:

- provider abstraction
- model aliases
- local and frontier routing
- fallback behaviour
- escalation policy
- future cost controls
- consistent access for CLI, UI, IDE and agents

Tools should not be hard-coded to a specific model or provider unless there is a clear reason.

---

## 2. CLI native

The CLI is a first-class interface.

The terminal should not be treated as a fallback for the UI. It should be the primary way to operate the workstation.

Every important workflow should have a CLI path where practical.

Examples:

```text
ask-ai
ai-route
ai-status
ai-model-review
dev-ai
architect-ai
write-ai
research-ai
```

The UI and IDE should complement the CLI, not replace it.

---

## 3. Open source first

Before building custom functionality, check whether an active open-source project already satisfies the need.

Custom code should be limited to:

- thin wrappers
- configuration
- glue logic
- validation checks
- profile loading
- documentation helpers

Build custom tools only when there is a genuine gap.

---

## 4. Rebuildable by default

The workstation must be rebuildable from code and configuration.

A new or rebuilt device should be able to clone the repository, run a bootstrap process, apply a profile, and validate the environment.

Important setup should not live only as undocumented machine state.

The repository is the source of truth.

---

## 5. Disposable by design

The machine should be treated as replaceable.

This is especially important for atomic or ephemeral operating system models such as Fedora Silverblue, Fedora Atomic Desktop, or future rebuildable workstation patterns.

The design should favour:

- thin host
- containerised services
- user-space tools
- externalised secrets
- declarative configuration
- validation scripts

---

## 6. Config over code

Prefer configuration over hard-coded behaviour.

Configuration should define:

- profiles
- providers
- model aliases
- routing rules
- privacy rules
- enabled capabilities
- disabled capabilities
- fallback behaviour
- escalation rules

Changing a model or provider should not require rewriting the workflow.

---

## 7. Local first

Local models should be the default route.

Local-first does not mean local-only. It means the workstation should try to use local capability first where appropriate.

Local models are preferred for:

- simple explanations
- summarisation
- rewriting
- private notes
- low-risk coding help
- experimentation
- learning
- tasks where speed and privacy matter more than frontier-quality reasoning

---

## 8. Frontier capable

The workstation should support frontier model escalation.

Frontier models may be used when:

- the task is complex
- the output is customer-facing
- the local model struggles
- deep reasoning is required
- large synthesis is required
- coding complexity exceeds local capability
- the user explicitly asks for best quality

Frontier escalation should be deliberate, observable and policy-controlled.

---

## 9. Composable by default

The workstation should be built from replaceable components.

Each component should satisfy a capability rather than define the architecture.

Examples:

```text
model gateway
local runtime
CLI coding assistant
chat UI
agent runner
model fitness tool
RAG/memory layer
```

If a better tool appears later, the component should be replaceable without redesigning the whole system.

---

## 10. Stable interface, replaceable implementation

User-facing commands and workflows should remain stable.

Underlying tools can change.

For example:

```text
architect-ai review decision.md
```

should remain a stable workflow even if the model provider, runtime or tool implementation changes underneath.

The habit should outlive the tool.

---

## 11. Observable routing

The workstation should be able to explain routing decisions.

Where practical, it should show:

- selected provider
- selected model
- selected route
- task type
- whether the task stayed local
- whether frontier escalation occurred
- why the route was selected

This is important for learning, trust and debugging.

---

## 12. Work and personal separation

Work and personal usage should be separated through profiles, context boundaries and routing policies.

The initial profiles are:

- `macos-work`
- `windows-personal`
- `fedora-atomic`

The MacBook Pro work profile should enable architecture, writing and work-safe workflows.

The Windows personal profile should enable personal development, experimentation and agent trials.

Work context should not accidentally flow into personal workflows.

Personal experimentation should not pollute the work profile.

---

## 13. Model fitness loop

Model selection should be informed by actual device and task fit.

The workstation should use llmfit or an equivalent process to review:

- what models fit the device
- what models are too slow
- what models are appropriate for coding
- what models are appropriate for summarisation
- what models are appropriate for reasoning
- which models should be removed or demoted

Model choices should evolve over time.

---

## 14. Agents with guardrails

Agents should be introduced gradually and deliberately.

They should begin as constrained workflows, not uncontrolled autonomous systems.

Agent workflows should have:

- clear scope
- explicit permissions
- observable model usage
- limited file modification rights
- local-first routing where practical
- frontier escalation only where justified

---

## 15. Document decisions

Major design decisions should be recorded as ADRs.

Every new tool or major change should explain:

- why it was considered
- what capability it satisfies
- what status it has
- how it can be replaced
- what consequences it introduces

Documentation should make the workstation easier to evolve, not harder to use.

---

## 16. Build the way of working

The project should not optimise for novelty.

It should optimise for daily use.

A component should earn its place by supporting a real recurring workflow.

The goal is not to install every interesting AI tool. The goal is to build a durable way of working.
