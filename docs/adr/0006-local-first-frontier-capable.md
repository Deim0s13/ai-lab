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
