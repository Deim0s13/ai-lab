# ADR-0009: Define runtime access patterns

## Status

Accepted

## Date

2026-06-24

## Context

The workstation supports multiple local runtimes.

The Windows personal profile has a clear primary runtime: Ollama.

The macOS work profile is less straightforward. It may use an oMLX / MLX-compatible runtime as the preferred Mac-native path, with Ollama as a fallback for compatibility.

These runtimes may have different:

- model formats
- APIs
- CLI commands
- installation paths
- model storage locations
- gateway integration patterns
- tool compatibility

The architecture needs to define which tools talk through the gateway and which tools may talk directly to runtimes.

## Decision

The workstation will use a gateway-first runtime access pattern.

The default access pattern is:

```text
tool or CLI command → gateway → runtime/provider
```

Direct runtime access is allowed only when explicitly documented.

The initial access rules are:

| Tool / capability | Preferred access | Direct access allowed? | Notes |
|---|---|---:|---|
| `ask-ai` | Gateway | Yes, local fallback only | Used for degraded local mode. |
| `ai-route` | Config only | No | Explains route, does not call runtime. |
| `ai-status` | Gateway and direct health checks | Yes | Health checks may inspect runtimes directly. |
| `ai-bootstrap-check` | Direct checks and gateway checks | Yes | Validation needs direct checks. |
| Open WebUI | Gateway | No initially | Avoid separate UI routing. |
| Aider / OpenCode | Gateway where practical | Yes, if tool requires it | Direct mode must be documented. |
| Goose / agents | Gateway | No initially | Agents need stronger controls. |
| llmfit / model fitness | Direct/runtime-specific or gateway-based | Yes | Model assessment may need direct runtime access. |

## Options Considered

### Option 1: Gateway-only runtime access

All tools must use the gateway.

Pros:

- cleanest architecture
- strongest routing consistency
- easiest provider abstraction
- lowest drift risk

Cons:

- some tools may not support gateway access cleanly
- model fitness may need direct runtime checks
- degraded local operation is harder
- runtime-specific health checks become limited

### Option 2: Gateway-first with documented direct exceptions

The gateway is the default, but direct runtime access is allowed for defined cases.

Pros:

- preserves gateway-first architecture
- supports practical tool limitations
- allows health checks and model fitness
- enables degraded local mode
- makes exceptions visible

Cons:

- requires documentation discipline
- creates some branching by runtime
- needs validation to avoid drift

### Option 3: Direct runtime access wherever convenient

Tools may use either gateway or direct runtime access.

Pros:

- flexible
- easy for tool-specific setup
- less gateway dependency

Cons:

- undermines routing strategy
- makes work/personal governance harder
- increases config duplication
- weakens rebuild reproducibility
- creates hidden behaviour

## Rationale

Gateway-first with documented direct exceptions is the right balance.

The project needs gateway consistency, but the macOS runtime split and local model tooling mean some direct access will be unavoidable.

The important architectural requirement is that direct runtime access is explicit, profile-aware and validated.

## Consequences

### Benefits

- Keeps the gateway as the normal model access path.
- Makes runtime exceptions visible.
- Reduces hidden drift between oMLX, Ollama and future runtimes.
- Supports profile-aware validation.
- Supports direct health checks and degraded local fallback.

### Trade-offs

- Requires runtime access metadata in profile or config.
- Some tools may need profile-specific configuration.
- Documentation must stay current.

### Risks or Follow-ups

- Avoid letting direct runtime access become the default.
- Track tool-specific direct access in capability contracts.
- Add validation for gateway and direct runtime paths.
- Revisit once macOS runtime choice is clearer.

## Implementation Impact

Profiles should include runtime access policy.

Example:

```yaml
runtime_access:
  default: gateway
  direct_local_fallback: true
  direct_frontier_fallback: false
  direct_allowed_for:
    - ai-status
    - ai-bootstrap-check
    - ai-model-review
```

Tool configuration should indicate whether a tool is gateway-only or direct-capable.

Validation should report:

- gateway reachable
- local runtime reachable
- direct fallback configured
- tools using direct runtime access

## Review Trigger

Review this decision if:

- oMLX / MLX-compatible runtime becomes the only macOS runtime
- Ollama becomes the single runtime across profiles
- gateway integration becomes universal
- coding tools require more direct access than expected
- agent workflows require runtime-specific execution

## Related Documents

- `docs/03-architecture.md`
- `docs/04-capability-contracts.md`
- `docs/06-profiles.md`
- `docs/07-routing-strategy.md`
- `docs/08-rebuild-strategy.md`
