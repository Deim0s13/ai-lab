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
