# ADR-0014: Define controlled agent guardrails before agent implementation

## Status

Accepted

## Date

2026-06-24

## Context

The milestone roadmap includes controlled agents as a later capability.

Agents may eventually support multi-step workflows for coding, research, writing, architecture review and project memory.

However, agents introduce higher risk than simple prompt-response tools because they may:

- read files
- modify files
- execute commands
- call external providers
- load context
- use network access
- chain multiple steps
- act with partial autonomy

The project needs to define what “controlled agents” means before agents are implemented.

## Decision

Agents will be introduced only after gateway, routing, validation and profile boundaries are trusted.

Initial agent guardrails are:

| Area | Guardrail |
|---|---|
| Profile enablement | Agents disabled by default on `macos-work`; trial first on `windows-personal`. |
| Gateway usage | Agents must use the gateway where practical. |
| Direct provider access | Not allowed initially unless explicitly approved by future ADR. |
| File access | Limited to selected project directories. |
| File modification | Must be explicit and visible. |
| Context loading | Must follow profile context boundary rules. |
| Network access | Disabled or limited unless required by the workflow. |
| Work profile | No broad agent access to work context by default. |
| Logging | Agent route and key actions should be observable. |
| Human control | Agent workflows should be manually triggered, not background/autonomous. |

## Options Considered

### Option 1: No agents

Do not include agents in the workstation.

Pros:

- lowest risk
- simpler architecture
- easier profile governance

Cons:

- misses potentially useful workflows
- does not explore an important AI development pattern
- may limit future productivity

### Option 2: Agents with strong guardrails

Introduce agents later, with explicit profile, file, provider and context controls.

Pros:

- allows experimentation safely
- aligns with profile model
- supports future workflows
- keeps work profile conservative
- allows personal profile trials

Cons:

- requires guardrail design
- may limit agent usefulness initially
- adds validation and policy complexity

### Option 3: Broad agent enablement

Allow agents to access files, tools and providers freely.

Pros:

- maximum capability
- easier to test powerful workflows
- less policy friction

Cons:

- too risky
- poor fit for work profile
- can modify files unexpectedly
- can leak context
- undermines routing governance
- not aligned with controlled architecture

## Rationale

Agents may be useful, but they should not be introduced before the workstation has trusted boundaries.

Strong guardrails allow experimentation without compromising work/personal separation, routing policy or rebuildability.

The Windows personal profile is the right first place to trial agents. The work profile should remain restricted.

## Consequences

### Benefits

- Agent risk is considered before implementation.
- Work profile remains conservative.
- Personal profile can still experiment.
- Agents inherit gateway and context rules.
- Future agent decisions have a clear baseline.

### Trade-offs

- Initial agents may feel constrained.
- More policy and validation is needed.
- Some tools may not support all desired controls.

### Risks or Follow-ups

- Agent tool choice must be assessed against guardrails.
- Goose or any equivalent agent runner must be trialled carefully.
- File modification model must be understood before adoption.
- Work profile agent support should require a separate decision.

## Implementation Impact

Milestone 7 should not begin until these foundations exist:

- gateway health
- routing policy
- context boundaries
- secrets handling
- profile-aware validation
- routing logs

Initial agent profile policy:

```yaml
agents:
  enabled: false
  allowed_profiles:
    - windows-personal
  blocked_profiles:
    - macos-work
  require_gateway: true
  allow_direct_provider: false
  allow_network: false
  file_access:
    mode: allowlist
    paths:
      - ./labs
      - ./docs
```

## Review Trigger

Review this decision if:

- agent workflows become a higher priority
- a specific agent runner has strong built-in controls
- work profile agent use becomes necessary
- file access or network access requirements change
- RAG/project memory is added

## Related Documents

- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/04-capability-contracts.md`
- `docs/06-profiles.md`
- `docs/07-routing-strategy.md`
- `docs/10-milestones.md`
