# ADR-0008: Define gateway failure and degraded operation

## Status

Accepted

## Date

2026-06-24

## Context

The workstation uses a gateway-first architecture, but the gateway must not be treated as infallible.

If the gateway is unavailable, misconfigured, or unhealthy, the whole workstation should not become useless. This matters because the gateway is part of the local workstation foundation and can fail for normal reasons:

- service not started
- container failure
- invalid configuration
- provider configuration issue
- local runtime unavailable
- port conflict
- dependency update
- corrupted local config

The architecture needs a clear degraded operation model before Milestone 1 implementation begins.

## Decision

The workstation will support three operating modes:

| Mode | Description |
|---|---|
| Normal | CLI, UI and tools use the gateway where practical. |
| Degraded local | If the gateway is unavailable, selected CLI commands may fall back to direct local runtime access where configured. |
| Degraded manual | If automated fallback is not available, the CLI should explain the failure and provide a clear manual next step. |

The gateway remains the preferred path, but it should not be the only possible path for basic local use.

`ask-ai --local` may support direct local fallback to Ollama or oMLX / MLX-compatible runtime where that fallback is explicitly configured for the active profile.

UI tools and agents should not silently bypass the gateway unless a specific future decision allows it.

## Options Considered

### Option 1: Gateway required for all use

All workflows fail if the gateway is unavailable.

Pros:

- simple architecture
- one consistent model access path
- easier to reason about routing

Cons:

- gateway becomes a hard single point of failure
- local-first workstation becomes fragile
- poor developer experience during rebuilds
- makes troubleshooting harder

### Option 2: Gateway preferred with controlled local fallback

The gateway is the normal path, but selected local CLI workflows can fall back to direct runtime access.

Pros:

- preserves gateway-first architecture
- improves resilience
- supports local-first use even during gateway failure
- makes rebuild and troubleshooting easier
- keeps fallback explicit and controlled

Cons:

- adds fallback logic
- requires clear runtime access rules
- risks drift if direct paths become overused

### Option 3: Fully independent direct access for every tool

Every tool can connect directly to local runtimes and providers.

Pros:

- maximum flexibility
- fewer gateway dependencies
- easier for tools that do not support gateway access

Cons:

- undermines gateway-first architecture
- duplicates configuration
- weakens routing governance
- increases work/personal profile risk
- makes observability harder

## Rationale

The best fit is gateway preferred with controlled local fallback.

This preserves the gateway-first architecture while recognising that a local workstation needs a graceful degradation path. Basic local use should remain possible even when the gateway needs repair.

Fallback must be explicit, profile-aware and visible. It should not become a second hidden architecture.

## Consequences

### Benefits

- The workstation remains usable during gateway failure.
- `ask-ai --local` can still support basic local workflows.
- Troubleshooting becomes easier.
- Gateway health becomes part of validation.
- The architecture is more resilient without abandoning gateway-first principles.

### Trade-offs

- CLI tools need fallback logic.
- Direct local runtime access must be documented.
- Runtime-specific behaviour may differ between macOS and Windows.
- Validation must check both gateway health and fallback availability.

### Risks or Follow-ups

- Avoid allowing every tool to bypass the gateway.
- Keep fallback local-only at first.
- Do not allow silent fallback to frontier providers.
- Log or explain when degraded mode is used.
- Add routing tests for gateway-down scenarios.

## Implementation Impact

Milestone 1 should include:

- gateway health check in `ai-status`
- gateway health check in `ai-bootstrap-check`
- `ask-ai --local` direct local fallback where configured
- clear error message when gateway is unavailable
- profile config for whether direct local fallback is allowed
- routing test for gateway unavailable behaviour

Example degraded output:

```text
Gateway: unavailable
Profile: windows-personal
Requested route: local
Fallback: direct Ollama
Mode: degraded_local
```

If no fallback is available:

```text
Gateway: unavailable
Profile: macos-work
Fallback: not configured
Next action: start gateway or run direct runtime command documented for this profile
Mode: degraded_manual
```

## Review Trigger

Review this decision if:

- gateway stability is high enough that fallback is unnecessary
- fallback paths start becoming the default
- tools require direct access more often than expected
- agent workflows need a different failure model
- gateway replacement changes the failure behaviour

## Related Documents

- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/07-routing-strategy.md`
- `docs/08-rebuild-strategy.md`
- `docs/10-milestones.md`
