# ADR-0015: Treat Fedora Atomic as a future reference profile

## Status

Accepted

## Date

2026-06-24

## Context

The architecture includes a `fedora-atomic` profile.

This profile represents a future rebuildable Linux workstation pattern, potentially based on Fedora Silverblue, Fedora Atomic Desktop or a similar thin-host operating model.

However, the active implementation targets are currently:

- `macos-work`
- `windows-personal`

The Fedora Atomic profile is useful because it keeps the architecture honest about rebuildability, Podman-first services and minimal host mutation. But it should not be presented as an active peer implementation target during Milestone 1.

## Decision

`fedora-atomic` will be treated as a future reference profile, not an active implementation profile.

It will remain in the architecture and profile documentation as a design constraint and future target.

Milestone 1 will not implement Fedora Atomic bootstrap, runtime setup or validation beyond placeholder/reference documentation.

The active profiles for early implementation are:

```text
macos-work
windows-personal
```

The future/reference profile is:

```text
fedora-atomic
```

## Options Considered

### Option 1: Remove Fedora Atomic from the docs

Keep the docs focused only on active profiles.

Pros:

- avoids confusion
- simpler early implementation
- less stale documentation risk

Cons:

- loses useful rebuildability design pressure
- weakens future atomic workstation thinking
- may lead to macOS/Windows assumptions becoming too embedded

### Option 2: Treat Fedora Atomic as an active peer profile

Design and implement it alongside macOS and Windows.

Pros:

- strongest cross-platform discipline
- proves rebuildability early
- validates thin-host assumptions

Cons:

- too much scope for Milestone 1
- no current active device target
- requires separate runtime, bootstrap and validation work
- likely slows implementation

### Option 3: Treat Fedora Atomic as a future reference profile

Keep it documented as a future target, but label it clearly as not active.

Pros:

- preserves architectural intent
- avoids early implementation scope creep
- reduces confusion
- keeps rebuildability pressure visible
- allows future implementation when needed

Cons:

- profile may grow stale if not reviewed
- some details will remain unresolved
- requires clear labelling in docs

## Rationale

Fedora Atomic is valuable as a design constraint, but not as an immediate build target.

The project should focus Milestone 1 on the two real devices: macOS work and Windows personal. Fedora Atomic should influence the design, especially around rebuildability and containers, without creating false implementation obligations.

## Consequences

### Benefits

- Reduces Milestone 1 scope.
- Keeps active profiles clear.
- Preserves future rebuildability direction.
- Avoids stale implementation expectations.
- Prevents confusion about what is currently supported.

### Trade-offs

- Fedora-specific details remain unresolved.
- Future implementation will need its own bootstrap and validation work.
- Docs must clearly label it as future/reference.

### Risks or Follow-ups

- Ensure `docs/06-profiles.md` labels Fedora Atomic as future/reference.
- Ensure `docs/10-milestones.md` does not imply Fedora Atomic is part of Milestone 1.
- Review Fedora Atomic profile when a real Linux target exists.
- Avoid putting active validation requirements on Fedora Atomic too early.

## Implementation Impact

Profile documentation should use clear status labels:

| Profile | Status |
|---|---|
| `macos-work` | Active |
| `windows-personal` | Active |
| `fedora-atomic` | Future / reference |

Milestone 1 should include:

- active implementation for `macos-work`
- active implementation for `windows-personal`
- only placeholder/reference notes for `fedora-atomic`

Validation should not fail because Fedora Atomic is not implemented.

## Review Trigger

Review this decision if:

- I start using a Fedora Atomic device
- I need to prove Linux rebuildability
- Podman-first service design becomes a primary focus
- macOS/Windows assumptions start undermining future Linux support
- a new active Linux profile is required

## Related Documents

- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/08-rebuild-strategy.md`
- `docs/10-milestones.md`
