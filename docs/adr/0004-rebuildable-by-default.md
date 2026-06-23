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
