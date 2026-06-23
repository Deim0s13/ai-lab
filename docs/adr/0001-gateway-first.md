# `docs/adr/0001-gateway-first.md`

# ADR-0001: Use a gateway-first architecture

## Status

Accepted

## Date

2026-06-23

## Context

AI Dev Workstation as Code needs to support multiple ways of interacting with AI models, including CLI commands, UI tools, IDE integrations, coding assistants and future agents.

It also needs to support different model providers and runtimes across different profiles:

- local runtimes such as Ollama and oMLX / MLX-compatible runtimes
- approved work AI tools such as Gemini and Cursor
- frontier providers such as OpenAI and Anthropic
- future providers or runtimes that may become better fits over time

Without a common gateway or routing layer, each tool would need to be configured separately. That would create duplication, make provider changes harder, increase the chance of work/personal profile drift, and make routing decisions less visible.

## Decision

I will use a gateway-first architecture.

Where practical, CLI tools, chat UI tools, coding tools and future agents should access models through a common gateway or routing layer rather than connecting directly to individual providers.

The gateway should provide a common control point for:

- model aliases
- provider abstraction
- local and frontier routing
- fallback behaviour
- profile-aware policies
- future observability
- future cost or usage controls

The initial gateway candidate is LiteLLM or an equivalent open-source model gateway.

## Options Considered

### Option 1: Direct tool-to-provider configuration

Each tool would connect directly to the model provider or local runtime it needs.

Pros:

- simple for one-off tools
- fewer moving parts at the start
- easier to test individual tools quickly

Cons:

- duplicates configuration across tools
- makes provider changes harder
- makes routing harder to explain
- increases risk of profile drift
- creates separate AI environments for CLI, UI and IDE workflows
- makes future agents harder to govern

### Option 2: Gateway-first architecture

Tools connect to a common gateway where practical.

Pros:

- creates a common model access point
- supports model aliases and provider abstraction
- makes routing more consistent
- supports local-first and frontier-capable behaviour
- helps keep CLI, UI and IDE workflows aligned
- allows providers and runtimes to be replaced more easily
- supports profile-aware routing and governance

Cons:

- introduces another component
- requires gateway configuration and validation
- may not work cleanly with every tool
- may require some tools to bypass the gateway where unavoidable

### Option 3: Gateway later

Start with direct provider access and introduce a gateway once multiple tools are in use.

Pros:

- fastest initial experimentation
- avoids early gateway setup
- useful if tool direction is uncertain

Cons:

- likely creates migration work later
- encourages scattered configuration
- risks locking early workflows to provider-specific assumptions
- delays the core architectural control point

## Rationale

The gateway-first option best supports the project’s architecture principles.

This project is intended to be a durable workstation, not a set of disconnected experiments. A gateway gives the workstation a stable control plane while allowing tools, providers and local runtimes to change over time.

The gateway also supports the profile model. The `macos-work` profile can prioritise approved work AI tools first, while the `windows-personal` profile can use OpenAI and Anthropic more freely for personal experimentation.

## Consequences

### Benefits

- More consistent model access across CLI, UI, IDE and future agents.
- Easier provider replacement.
- Better support for local-first routing.
- Better support for profile-aware policy.
- Easier to explain routing decisions.
- Lower risk of creating separate AI environments.

### Trade-offs

- Adds a component that must be configured and validated.
- Some tools may not integrate cleanly with the gateway.
- The first implementation may need simple external routing before gateway-native routing is mature.

### Risks or Follow-ups

- Validate that the selected gateway works with local runtimes and approved frontier providers.
- Confirm Open WebUI can use the gateway cleanly.
- Confirm CLI wrappers can route through the gateway.
- Avoid overbuilding routing logic too early.

## Implementation Impact

Milestone 1 should include:

- gateway configuration
- provider placeholders
- local runtime integration
- basic model aliases
- basic route configuration
- `ask-ai` calling the gateway
- `ai-route` explaining simple routing decisions
- `ai-status` checking gateway health

## Review Trigger

Review this decision if:

- the selected gateway becomes difficult to maintain
- the gateway blocks important tools
- provider compatibility becomes poor
- routing needs are better handled elsewhere
- a clearly better gateway option emerges

## Related Documents

- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/04-capability-contracts.md`
- `docs/07-routing-strategy.md`
- `docs/10-milestones.md`

---

# `docs/adr/0002-open-source-first.md`

# ADR-0002: Use open-source-first tool selection

## Status

Accepted

## Date

2026-06-23

## Context

The AI tooling ecosystem is moving quickly. There are many active tools for model gateways, local runtimes, chat UIs, coding assistants, agents, model assessment and workflow automation.

It would be easy to start building custom scripts and services too early. That would create maintenance burden and could duplicate functionality that already exists in active open-source projects.

At the same time, this project does not need to be open-source-only. Some approved work tools and frontier providers may be commercial or externally hosted.

## Decision

I will use an open-source-first approach when selecting tools for the workstation.

Before building custom functionality, I will check whether an active open-source tool already satisfies the capability.

Custom code should usually be limited to:

- thin wrappers
- profile loading
- routing helpers
- validation checks
- configuration glue
- project-specific CLI commands
- documentation helpers

Commercial or hosted tools may still be used where they are the approved or appropriate tool for a profile or use case.

## Options Considered

### Option 1: Build custom tooling

Build project-specific scripts and services for most workstation needs.

Pros:

- full control over behaviour
- tailored exactly to my workflow
- fewer external tool assumptions

Cons:

- high maintenance burden
- slower delivery
- likely duplicates existing tools
- harder to keep up with the ecosystem
- risks building a private platform too early

### Option 2: Open-source-first adoption

Adopt active open-source tools where they fit and build only thin project-specific layers.

Pros:

- faster progress
- less custom maintenance
- better alignment with the project’s replaceability principle
- easier to trial and remove tools
- supports learning from existing projects
- avoids unnecessary platform building

Cons:

- depends on external project quality and maintenance
- may require integration work
- some tools may not fit perfectly
- selected tools may need replacing later

### Option 3: Commercial-tool-first

Use commercial or hosted AI tools directly and avoid local/open-source tooling unless needed.

Pros:

- high-quality capabilities immediately
- less local setup
- strong frontier model access

Cons:

- weaker local-first posture
- less rebuildable
- less control over routing and policy
- harder to align work and personal profile behaviour
- does not build the local workstation foundation I want

## Rationale

Open-source-first is the best fit for the project because the workstation is meant to be rebuildable, composable and replaceable.

The aim is not to build every capability myself. The aim is to create a durable personal workstation architecture that uses good existing components and adds a thin layer of workflow consistency.

This also supports the component lifecycle model. Tools can be candidates, trials, adopted, preferred, deprecated or removed as the ecosystem changes.

## Consequences

### Benefits

- Reduces custom maintenance.
- Speeds up early implementation.
- Keeps the workstation replaceable.
- Supports experimentation without permanent commitment.
- Aligns with the project’s open-source-first architecture principle.

### Trade-offs

- Requires active tool selection and review.
- Some tools may not fit the architecture perfectly.
- Tool replacement may be needed over time.

### Risks or Follow-ups

- Avoid adopting tools just because they are interesting.
- Track tool status through the component lifecycle.
- Use capability contracts to guide selection.
- Create ADRs when selecting major default tools.

## Implementation Impact

Tool selection should follow the process in `docs/09-tool-selection.md`.

Initial candidates include:

- LiteLLM or equivalent for model gateway
- Ollama for Windows local runtime
- oMLX / MLX-compatible runtime for macOS local runtime
- Open WebUI for chat UI
- Aider / OpenCode for CLI coding assistant
- Goose or equivalent for future agents
- llmfit for model fitness
- Bitwarden for secrets management

## Review Trigger

Review this decision if:

- open-source tools are consistently failing to meet the project’s needs
- a commercial tool becomes the only practical implementation of a key capability
- custom code starts growing beyond thin wrappers and glue
- the project’s scope changes significantly

## Related Documents

- `docs/02-principles.md`
- `docs/04-capability-contracts.md`
- `docs/05-component-lifecycle.md`
- `docs/09-tool-selection.md`

---

# `docs/adr/0003-cli-native.md`

# ADR-0003: Treat the CLI as a first-class interface

## Status

Accepted

## Date

2026-06-23

## Context

The workstation needs to support multiple interaction models, including CLI, UI, IDE and future agent workflows.

I already work heavily from the terminal and prefer CLI-native AI workflows, particularly for development and architecture-related work. A UI is useful, but it should not become the only or primary way to use the workstation.

If the project is going to become part of my daily workflow, it needs to support stable, memorable CLI commands.

## Decision

The CLI will be treated as a first-class interface.

Important workstation workflows should have a CLI path where practical.

Initial CLI commands may include:

- `ask-ai`
- `ai-route`
- `ai-status`
- `ai-bootstrap-check`
- `ai-model-review`
- `dev-ai`
- `architect-ai`
- `write-ai`
- `research-ai`

The UI and IDE should complement the CLI rather than replace it.

## Options Considered

### Option 1: UI-first workstation

Prioritise Open WebUI or another chat interface as the primary way to use the workstation.

Pros:

- easy to use
- good for exploration
- familiar chat interface
- useful for comparing models

Cons:

- less aligned with my preferred workflow
- harder to script
- risks becoming separate from CLI and coding workflows
- may hide routing decisions
- less useful for repeatable architecture and development tasks

### Option 2: IDE-first workstation

Prioritise editor extensions and coding assistants as the primary interface.

Pros:

- strong coding workflow fit
- useful for repo-aware tasks
- integrates with development tools

Cons:

- too narrow for architecture, writing and research workflows
- may depend heavily on specific editors or tools
- can create tool lock-in
- does not provide a general workstation entry point

### Option 3: CLI-native workstation

Make CLI workflows primary and add UI/IDE support on top.

Pros:

- aligns with how I prefer to work
- scriptable and repeatable
- supports development, architecture, writing and validation
- makes routing easier to expose
- fits rebuildable workstation principles
- creates stable habits independent of tools

Cons:

- requires some custom wrapper commands
- less immediately friendly than a UI
- CLI ergonomics need careful design

## Rationale

CLI-native is the best fit because this project is about building a durable way of working.

The CLI gives me a stable interface even when underlying providers, models and tools change. It also works well with the gateway-first architecture because commands can route through the same model control plane.

The UI and IDE still matter, but they should sit on top of the same gateway, profiles and routing model.

## Consequences

### Benefits

- Creates stable daily workflows.
- Supports scriptable and repeatable usage.
- Makes routing easier to explain.
- Works across macOS, Windows/WSL2 and future Linux profiles.
- Helps avoid UI and IDE drift.

### Trade-offs

- Requires maintaining project-specific CLI wrappers.
- Some workflows may still be better in a UI or IDE.
- The command design needs to stay simple to avoid friction.

### Risks or Follow-ups

- Avoid building a large custom CLI platform.
- Keep wrappers thin.
- Ensure CLI commands remain gateway-aware and profile-aware.
- Add UI parity later without creating a separate AI environment.

## Implementation Impact

Milestone 1 and Milestone 2 should include:

- basic `ask-ai`
- basic `ai-route`
- basic `ai-status`
- `ai-bootstrap-check`
- support for profile selection
- support for local-only routing
- support for best-available routing
- route explanation

## Review Trigger

Review this decision if:

- CLI workflows do not become part of daily use
- UI or IDE workflows become clearly more valuable
- CLI wrappers become too complex
- a selected tool provides a better stable interface than custom commands

## Related Documents

- `docs/01-vision.md`
- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/07-routing-strategy.md`
- `docs/10-milestones.md`

---

# `docs/adr/0004-rebuildable-by-default.md`

# ADR-0004: Make the workstation rebuildable by default

## Status

Accepted

## Date

2026-06-23

## Context

AI Dev Workstation as Code should not depend on undocumented machine state.

The project needs to support multiple devices and future rebuild scenarios:

- MacBook Pro work device
- Windows personal AI development lab
- future Fedora Atomic or similar rebuildable Linux environment

If the workstation is manually assembled and not captured in the repo, it will become fragile and hard to recover. It will also be difficult to understand which tools, models, services and configs are actually part of the standard build.

## Decision

The workstation will be rebuildable by default.

The repository should be the source of truth for:

- profiles
- packages
- bootstrap scripts
- service definitions
- configuration
- routing rules
- provider definitions
- model aliases
- validation checks
- documentation
- ADRs

Manual steps are allowed early, but they must be documented and treated as technical debt.

## Options Considered

### Option 1: Manual workstation setup

Install and configure tools manually as needed.

Pros:

- fastest for early experimentation
- low initial structure
- easy to try tools quickly

Cons:

- hard to reproduce
- hard to debug
- easy to forget steps
- creates hidden machine state
- weak support for multiple devices
- not aligned with workstation-as-code

### Option 2: Rebuildable from the beginning

Capture setup in repo structure, scripts, config and documentation from the start.

Pros:

- supports repeatability
- makes the repo the source of truth
- supports multiple profiles
- supports future atomic Linux patterns
- reduces drift
- improves trust in the workstation

Cons:

- more up-front discipline
- slower than quick manual setup
- early scripts may need refactoring

### Option 3: Rebuildability later

Experiment manually first and formalise rebuildability later.

Pros:

- fast initial experimentation
- fewer early decisions
- useful if the direction is uncertain

Cons:

- likely accumulates hidden state
- harder to retrofit clean rebuilds later
- risks losing track of what matters
- undermines the project’s core purpose

## Rationale

Rebuildability is central to the project.

The goal is not just to install AI tools. The goal is to create a durable workstation foundation that I can rebuild, adapt and extend over time.

Starting with rebuildability makes every later milestone more stable.

## Consequences

### Benefits

- Easier recovery on new or reset devices.
- Clearer repo structure.
- Better support for profile-specific setup.
- Less configuration drift.
- Better long-term maintainability.
- Stronger foundation for future Fedora Atomic style setup.

### Trade-offs

- More documentation and structure up front.
- Bootstrap scripts may start simple and evolve.
- Some tools may require manual steps until automation is practical.

### Risks or Follow-ups

- Avoid overengineering bootstrap too early.
- Document manual steps clearly.
- Add validation to prove rebuild health.
- Keep platform-specific logic separated where useful.

## Implementation Impact

Milestone 1 should include:

- profile files
- `.env.example`
- Bitwarden-oriented secrets approach
- initial config structure
- gateway service definition
- basic bootstrap entry point
- `ai-bootstrap-check`
- `ai-status`
- documented manual steps

## Review Trigger

Review this decision if:

- rebuildability work prevents useful progress
- bootstrap complexity becomes too high
- profile-specific setup diverges too much
- a better rebuild mechanism becomes available

## Related Documents

- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/08-rebuild-strategy.md`
- `docs/10-milestones.md`

---

# `docs/adr/0005-composable-and-replaceable.md`

# ADR-0005: Build around composable and replaceable components

## Status

Accepted

## Date

2026-06-23

## Context

AI tooling is changing quickly. The best gateway, local runtime, coding assistant, chat UI, agent runner or model assessment tool may change over time.

If the workstation is built around specific tools rather than stable capabilities, it will become difficult to evolve. It may also become cluttered with experiments that were never properly adopted or removed.

The project needs a way to support experimentation without losing architectural coherence.

## Decision

The workstation will be designed around composable and replaceable components.

Capabilities should be defined before tools are selected.

Tools should move through a lifecycle:

```text
Candidate → Trial → Adopted → Preferred → Deprecated → Removed
```

Components should be replaceable without redesigning the whole workstation.

## Options Considered

### Option 1: Tool-centric design

Select tools first and build the workstation around them.

Pros:

- fast to start
- simple for small setups
- allows hands-on experimentation quickly

Cons:

- creates tool lock-in
- makes replacement harder
- weakens architecture consistency
- risks tool sprawl
- makes docs and config harder to maintain

### Option 2: Capability-based component model

Define capabilities and select tools as implementations of those capabilities.

Pros:

- keeps the architecture stable
- makes tools replaceable
- supports clear selection criteria
- reduces tool sprawl
- supports lifecycle governance
- aligns with architecture practice

Cons:

- requires more documentation
- can feel heavier at the start
- needs periodic review

### Option 3: Minimal governance

Trial tools freely and only document major decisions later.

Pros:

- lightweight
- flexible
- fast for experimentation

Cons:

- likely creates clutter
- harder to know what is active
- weak replacement discipline
- does not support long-term maintainability

## Rationale

Capability-based design is the right fit because this project is intended to evolve.

The workstation should not depend on one specific gateway, runtime, coding tool or UI forever. It should define stable capabilities and allow the implementation to change.

This also matches how I would approach a proper architecture: separate required capability from current implementation.

## Consequences

### Benefits

- Reduces tool sprawl.
- Makes replacement easier.
- Supports structured experimentation.
- Keeps the architecture coherent.
- Makes docs easier to maintain.
- Creates better decision history.

### Trade-offs

- Requires capability contracts.
- Requires lifecycle tracking.
- Some lightweight experiments may not need full records.

### Risks or Follow-ups

- Avoid making component governance too bureaucratic.
- Keep records lightweight.
- Use ADRs only for meaningful architecture decisions.
- Periodically remove unused components.

## Implementation Impact

The project should maintain:

- `docs/04-capability-contracts.md`
- `docs/05-component-lifecycle.md`
- `docs/09-tool-selection.md`
- ADRs for significant component decisions

Tool-specific config should be isolated so components can be replaced.

## Review Trigger

Review this decision if:

- lifecycle tracking becomes too heavy
- the project is slowed down by governance
- components are still becoming hard to replace
- the capability model no longer reflects real usage

## Related Documents

- `docs/02-principles.md`
- `docs/04-capability-contracts.md`
- `docs/05-component-lifecycle.md`
- `docs/09-tool-selection.md`

---

# `docs/adr/0006-local-first-frontier-capable.md`

# ADR-0006: Use local-first but frontier-capable routing

## Status

Accepted

## Date

2026-06-23

## Context

The workstation should support local AI usage, but local models will not be suitable for every task.

Local models are valuable for privacy, speed, cost control, learning and offline-style workflows. They are well suited to simple explanations, summarisation, rewriting, low-risk coding help and experimentation.

However, frontier models and approved AI tools may be needed for complex reasoning, difficult coding, high-quality writing, architecture review, customer-facing preparation or large synthesis.

The workstation needs a balanced approach.

## Decision

The workstation will be local-first, but frontier-capable.

Local models should be the default route where appropriate.

Frontier or approved AI tools may be used when:

- the task is complex
- local models are not good enough
- higher-quality reasoning is required
- the task is customer-facing
- coding complexity exceeds local capability
- I explicitly request best-available output
- the selected profile allows or requires that route

Routing must be profile-aware and explainable.

## Options Considered

### Option 1: Local-only

Use only local models.

Pros:

- strongest privacy posture
- no API costs
- simpler secrets management
- useful for learning local model capability

Cons:

- local models may underperform
- weak for complex reasoning
- weak for difficult coding
- may lead me back to separate frontier tools
- not realistic for all workflows

### Option 2: Frontier-first

Use frontier models by default and local models only occasionally.

Pros:

- high-quality output
- strong coding and reasoning
- less need to tune local models

Cons:

- weaker local-first learning
- higher cost
- more external dependency
- weaker privacy posture
- less aligned to workstation purpose

### Option 3: Local-first, frontier-capable

Use local models first where appropriate and escalate deliberately when justified.

Pros:

- balances privacy, cost and quality
- supports local model learning
- keeps frontier models available for hard tasks
- works across work and personal profiles
- supports model fitness and routing strategy

Cons:

- routing logic is needed
- requires clear profile policy
- requires route explanation
- requires secrets management for providers

## Rationale

Local-first but frontier-capable best matches the project goals.

The workstation should make local AI useful, but it should not pretend local models can do everything. The routing layer should help decide when local is enough and when escalation is justified.

This decision also supports the work/personal profile model. The work profile can prioritise approved tools first, while the personal profile can use OpenAI and Anthropic more freely.

## Consequences

### Benefits

- Better balance between privacy and quality.
- Supports real daily usage.
- Encourages local model experimentation.
- Allows complex work to use stronger models when justified.
- Supports profile-aware governance.

### Trade-offs

- Requires routing strategy.
- Requires secrets management.
- Requires model aliases and model fitness review.
- Frontier use must be explainable and controlled.

### Risks or Follow-ups

- Avoid silent frontier escalation.
- Add `--local`, `--best` and `--explain-route`.
- Use llmfit to inform local model aliases.
- Keep work profile conservative.

## Implementation Impact

Routing should support:

- local-first defaults
- profile-aware provider priority
- approved work tool posture
- personal frontier routes
- model aliases
- explicit local-only mode
- explicit best-available mode
- route explanation

## Review Trigger

Review this decision if:

- local models become consistently strong enough for most tasks
- frontier provider usage becomes too costly or risky
- work approval posture changes
- model routing becomes too complex
- local runtime choices change significantly

## Related Documents

- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/07-routing-strategy.md`
- `docs/10-milestones.md`

---

# `docs/adr/0007-profile-based-work-personal-separation.md`

# ADR-0007: Separate work and personal behaviour through profiles

## Status

Accepted

## Date

2026-06-23

## Context

The workstation will run across different devices and use cases.

The MacBook Pro is a work device. It needs a conservative posture, approved-tool-first behaviour and careful treatment of work or customer context.

The Windows laptop is a personal AI development lab. It can support more experimentation, personal projects, OpenAI/Anthropic frontier use, coding tool trials and future agents.

A future Fedora Atomic profile may be used to test rebuildability and thin-host patterns.

Using the same defaults everywhere would create risk and confusion.

## Decision

The workstation will separate behaviour through profiles.

Initial profiles are:

- `macos-work`
- `windows-personal`
- `fedora-atomic`

Profiles should control:

- local runtime priority
- provider priority
- routing policy
- approved tool posture
- enabled capabilities
- restricted capabilities
- secrets scope
- context boundaries
- validation expectations
- risk posture

## Options Considered

### Option 1: Single global configuration

Use one global workstation configuration for all devices and use cases.

Pros:

- simplest configuration
- less duplication
- easier initial implementation

Cons:

- weak work/personal separation
- poor fit for different devices
- harder to respect approved work tools
- risky for context boundaries
- difficult to tune local runtimes per device

### Option 2: Separate repos per device

Create separate projects for work, personal and future Linux setups.

Pros:

- strong separation
- each repo can be tailored
- less risk of cross-profile contamination

Cons:

- duplicates architecture and docs
- harder to keep patterns consistent
- harder to share tooling
- more maintenance overhead
- weakens the workstation-as-code concept

### Option 3: Shared architecture with profiles

Use one repo and shared architecture, with profile-specific behaviour.

Pros:

- keeps one source of truth
- supports work/personal separation
- allows device-specific runtimes
- supports approved-tool posture
- supports different levels of experimentation
- keeps architecture consistent

Cons:

- requires profile configuration
- validation must be profile-aware
- routing must respect profile policy

## Rationale

A shared architecture with profiles gives the best balance.

It allows one coherent workstation architecture while still recognising that work and personal usage have different constraints.

This is especially important for the `macos-work` profile. It should document Gemini and Cursor as the first-use approved work AI tools, with Anthropic and OpenAI only depending on use case, data sensitivity, approval context and routing policy.

The `windows-personal` profile can use OpenAI and Anthropic as primary frontier escalation paths for personal development and experimentation.

## Consequences

### Benefits

- Clear separation between work and personal usage.
- Better support for approved work AI posture.
- Better support for device-specific runtimes.
- Safer context handling.
- More accurate validation.
- More useful routing.

### Trade-offs

- More configuration to maintain.
- Profile-aware validation is required.
- Routing must load and respect active profile.
- Some capabilities may behave differently by profile.

### Risks or Follow-ups

- Avoid profile config becoming too complex.
- Ensure active profile is visible in CLI output.
- Prevent work-sensitive context from being used in personal workflows.
- Keep experimental agents out of the work profile until explicitly approved and controlled.

## Implementation Impact

Milestone 1 should create:

- `profiles/macos-work/profile.yaml`
- `profiles/windows-personal/profile.yaml`
- active profile selection
- profile-aware routing placeholders
- profile-aware validation placeholders

Future work should add:

- context boundaries
- profile-specific model aliases
- profile-specific provider priorities
- profile-specific agent permissions
- profile-specific RAG indexes if RAG is added

## Review Trigger

Review this decision if:

- profile configuration becomes too complex
- a device needs a significantly different architecture
- work approval posture changes
- personal and work workflows need stronger separation than profiles provide
- a future machine requires a new profile

## Related Documents

- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/07-routing-strategy.md`
- `docs/08-rebuild-strategy.md`
