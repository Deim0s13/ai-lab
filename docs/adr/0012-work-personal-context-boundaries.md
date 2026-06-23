# ADR-0012: Define work and personal context boundaries

## Status

Accepted

## Date

2026-06-24

## Context

The workstation has separate profiles for work and personal use.

The `macos-work` profile may involve work context, customer context, internal notes, architecture materials and approved-tool posture.

The `windows-personal` profile is for personal development, experimentation, coding workflows and future agents.

The architecture already defines profiles, but context boundaries need to be explicit. Work context must not accidentally flow into personal workflows, and personal experimentation must not pollute work workflows.

This becomes increasingly important as the project adds:

- context files
- writing personas
- architecture personas
- RAG/project memory
- agents
- routing logs
- provider escalation

## Decision

The workstation will enforce work and personal context boundaries through profile-aware context access rules.

Initial context categories are:

| Context | Description |
|---|---|
| `work` | Work-related context, customer material, internal notes, work personas. |
| `personal` | Personal projects, personal notes and experiments. |
| `shared` | Non-sensitive reusable context safe for both profiles. |
| `project` | Project-specific context, such as this repo’s own documentation. |

Initial access rules:

| Profile | Allowed context | Blocked context |
|---|---|---|
| `macos-work` | `work`, `shared`, selected `project` | `personal` |
| `windows-personal` | `personal`, `shared`, selected `project` | `work-sensitive` |
| `fedora-atomic` | TBD | TBD |

Work-sensitive context must not be available to personal profile workflows by default.

## Options Considered

### Option 1: Rely on manual judgement

Let me decide what context to load each time.

Pros:

- simple
- flexible
- no configuration overhead

Cons:

- easy to make mistakes
- weak compliance posture
- unsafe for future RAG and agents
- not testable
- does not support profile-aware automation

### Option 2: Separate repos or directories with no shared access

Keep work and personal context entirely separate.

Pros:

- strong separation
- simple mental model
- lower accidental leakage risk

Cons:

- duplicates shared context
- makes project-level reuse harder
- too rigid for shared architecture docs
- less convenient for daily use

### Option 3: Profile-aware context access rules

Use one architecture with explicit context categories and profile access rules.

Pros:

- clear boundaries
- supports shared non-sensitive context
- supports work-safe routing
- prepares for RAG and agents
- testable through validation
- aligns with profile model

Cons:

- requires context metadata or conventions
- requires validation and discipline
- future RAG will need careful index separation

## Rationale

Profile-aware context access rules best match the architecture.

The project can stay flexible while making boundaries explicit. This is especially important for the work profile, where approved-tool posture and data sensitivity matter.

Context boundaries should be defined before agents or RAG are introduced.

## Consequences

### Benefits

- Reduces risk of work/personal context leakage.
- Makes work-safe routing more meaningful.
- Prepares the project for RAG and agents.
- Supports validation and testing.
- Makes profile behaviour easier to explain.

### Trade-offs

- Requires context metadata or directory conventions.
- Adds policy checks to context loading.
- May require some manual tagging at first.

### Risks or Follow-ups

- Define context directory structure.
- Add validation for blocked context access.
- Ensure routing logs do not store sensitive prompt content.
- Keep work and personal RAG indexes separate if RAG is added.
- Ensure agents inherit context restrictions.

## Implementation Impact

Context directory structure should make boundaries obvious.

Example:

```text
contexts/
├── shared/
├── work/
├── personal/
└── project/
```

Context loading should check the active profile before loading context.

Example:

```bash
architect-ai --profile macos-work --context work/customer-notes.md
write-ai --profile windows-personal --context personal/project-style.md
```

If a blocked context is requested, the CLI should fail clearly.

Example:

```text
Context blocked
Profile: windows-personal
Requested context: work/customer-notes.md
Reason: work context is not available to personal profile
```

## Review Trigger

Review this decision if:

- work and personal workflows need stronger isolation
- RAG/project memory is introduced
- agent workflows are introduced
- Red Hat or work approval guidance changes
- a new profile requires different context access rules

## Related Documents

- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/07-routing-strategy.md`
- `docs/10-milestones.md`
