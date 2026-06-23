# ADR-0010: Use a replaceable model fitness approach

## Status

Accepted

## Date

2026-06-24

## Context

The workstation needs a way to decide which local models are suitable for each device and task.

The current candidate for model fitness is llmfit. It may be useful, but it has lower adoption and less obvious community depth than some other components in the architecture.

The project principle is that components should be replaceable. The model fitness capability should not depend permanently on one tool unless that tool proves itself.

## Decision

Model fitness will be treated as a capability, not as a commitment to llmfit.

The model fitness capability may be implemented through:

| Approach | Description |
|---|---|
| llmfit | External tool used to assess device/model fit if it proves useful. |
| Gateway-based fitness checks | Project-owned prompt and task checks run through the workstation gateway. |
| Manual review notes | Lightweight human assessment captured per profile until automation is useful. |

llmfit remains a candidate, not a fixed architectural dependency.

The preferred long-term model is a repeatable model fitness process that can inform routing aliases such as:

- `local_fast`
- `local_capable`
- `local_code`
- `frontier_reasoning`
- `frontier_code`

## Options Considered

### Option 1: Adopt llmfit as the model fitness tool

Use llmfit as the primary way to assess model/device fit.

Pros:

- purpose-built for model fit assessment
- may save time
- avoids building custom tests early

Cons:

- low adoption risk
- unclear long-term maintenance
- may not fit all runtimes
- could become a weak dependency

### Option 2: Build gateway-based fitness checks

Create a project-owned prompt/test suite and run it through the same routes used by the workstation.

Pros:

- fully aligned to the gateway architecture
- controlled by the project
- tests the actual routing path
- easy to tailor to real workflows
- no external dependency risk beyond existing tools

Cons:

- requires custom design
- may be less sophisticated than a specialised tool
- needs scoring and interpretation discipline

### Option 3: Use both, with llmfit as candidate

Trial llmfit, but keep gateway-based checks as a fallback or complement.

Pros:

- keeps the capability replaceable
- allows llmfit to prove value
- supports project-owned fallback
- aligns with capability-over-tool principles
- avoids premature commitment

Cons:

- requires deciding how to reconcile results
- may create two sources of model fitness information early on

## Rationale

Using both, with llmfit as a candidate, is the best fit.

Model fitness is important, but the architecture should not depend on a tool that may not prove durable. A gateway-based fitness approach may ultimately be more aligned to the workstation because it tests the actual routes and tasks I care about.

## Consequences

### Benefits

- Avoids overcommitting to llmfit.
- Keeps model fitness replaceable.
- Allows project-specific model checks.
- Supports routing aliases with actual evidence.
- Provides a fallback if llmfit is not useful.

### Trade-offs

- More work may be needed to define project-owned checks.
- Early model fitness results may be qualitative.
- The model review process may start manually.

### Risks or Follow-ups

- Do not treat llmfit output as authoritative until tested.
- Define a small set of repeatable task prompts.
- Store results per profile/device.
- Use results to update model aliases.

## Implementation Impact

Milestone 3 should include:

- llmfit trial
- gateway-based model fitness prompt set
- profile-specific result capture
- model alias recommendations
- initial `ai-model-review` helper or documented process

Possible result structure:

```text
models/
├── reviews/
│   ├── macos-work/
│   └── windows-personal/
└── fitness-prompts/
```

## Review Trigger

Review this decision if:

- llmfit proves clearly useful and maintained
- llmfit does not support the required runtimes
- gateway-based fitness checks become sufficient
- model routing needs more formal evaluation
- model aliases become stale or unreliable

## Related Documents

- `docs/04-capability-contracts.md`
- `docs/07-routing-strategy.md`
- `docs/09-tool-selection.md`
- `docs/10-milestones.md`
