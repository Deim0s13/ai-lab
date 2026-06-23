# ADR-0013: Define routing validation and observability

## Status

Accepted

## Date

2026-06-24

## Context

Routing is a central part of the workstation architecture.

The workstation should be able to decide whether a task should use:

- local runtime
- approved work AI tool
- frontier provider
- direct local fallback
- blocked or manual route

Without validation and observability, routing can drift silently. A route may start going to the wrong provider, work profile policy may be bypassed, or local-first behaviour may stop working without being noticed.

The project needs routing tests and basic decision logging from the start.

## Decision

The workstation will include routing validation and basic routing observability.

Routing validation should test expected route decisions for known scenarios.

Routing observability should record basic metadata about routing decisions without storing sensitive prompt content.

A simple JSONL log file is sufficient for the early implementation.

Example log event:

```json
{
  "timestamp": "2026-06-24T10:00:00+12:00",
  "profile": "macos-work",
  "task_type": "summarise",
  "sensitivity": "internal",
  "route": "local_fast",
  "provider": "omlx",
  "model_alias": "local_fast",
  "mode": "normal",
  "prompt_hash": "sha256:...",
  "latency_ms": 1234,
  "status": "success"
}
```

Prompt text should not be logged by default.

## Options Considered

### Option 1: No routing tests or logs initially

Rely on manual observation.

Pros:

- simplest start
- no logging implementation needed
- no test design needed

Cons:

- routing drift will be hard to detect
- profile policy violations may be missed
- model fitness loop has less data
- debugging will be harder
- weakens trust in routing

### Option 2: Basic routing validation and JSONL logs

Add simple route tests and metadata logging from the start.

Pros:

- low infrastructure
- makes routing behaviour observable
- supports debugging
- supports model fitness review
- helps confirm profile boundaries
- provides evidence that local-first and approved-tool posture work

Cons:

- requires log design
- requires privacy care
- adds implementation work to Milestone 1

### Option 3: Full observability stack

Use metrics, traces, dashboards and structured event pipelines.

Pros:

- powerful
- rich analysis
- useful for larger systems

Cons:

- overkill for a personal workstation
- adds operational complexity
- distracts from Milestone 1
- not needed yet

## Rationale

Basic routing validation and JSONL logs are the right level.

They provide useful evidence without adding a heavy observability stack. This supports the architecture principle of observable routing while keeping the implementation simple.

## Consequences

### Benefits

- Routing decisions become testable.
- Work profile provider posture can be verified.
- Local-first behaviour can be checked.
- Gateway failure and degraded mode can be tested.
- Model fitness can use real routing data later.
- Debugging becomes easier.

### Trade-offs

- Need to design log format.
- Need to avoid logging sensitive content.
- Need simple test fixtures.

### Risks or Follow-ups

- Do not log prompt text by default.
- Hash prompts only if useful.
- Make logs profile-aware.
- Consider separate logs for work and personal profiles.
- Add log rotation or pruning later if needed.

## Implementation Impact

Milestone 1 should include a minimal routing test catalogue.

Initial routing tests:

| Test | Profile | Scenario | Expected route |
|---|---|---|---|
| Local summary | `macos-work` | summarise internal note | `local_fast` or `local_capable` |
| Customer architecture review | `macos-work` | `--best --sensitivity customer` | `approved_work` first |
| Restricted work note | `macos-work` | `--sensitivity restricted` | local-only or blocked frontier |
| Personal coding debug | `windows-personal` | coding debug | `local_code` then `frontier_code` |
| Gateway down local | any | `--local` with gateway unavailable | degraded local fallback if configured |
| Block work context from personal | `windows-personal` | request work context | blocked |

Possible commands:

```bash
ai-route --test
ai-route --profile macos-work --sensitivity customer --task architecture_review --explain
```

Logs may live under:

```text
logs/routing/
```

or an ignored local application data directory.

## Review Trigger

Review this decision if:

- routing logs become too noisy
- privacy concerns emerge
- logs become useful enough to formalise
- routing becomes more complex
- semantic routing or cost-aware routing is added

## Related Documents

- `docs/03-architecture.md`
- `docs/07-routing-strategy.md`
- `docs/08-rebuild-strategy.md`
- `docs/10-milestones.md`
