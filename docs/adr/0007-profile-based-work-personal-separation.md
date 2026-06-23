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
