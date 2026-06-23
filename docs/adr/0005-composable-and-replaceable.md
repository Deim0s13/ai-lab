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
