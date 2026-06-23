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
