# ADR-0001: Use a gateway-first architecture

## Status

Accepted

## Date

2026-06-23

## Context

AI Dev Workstation as Code needs to support multiple ways of interacting with AI models, including CLI commands, UI tools, IDE integrations, coding assistants and future agents.

It also needs to support different model providers and runtimes across different profiles:

- local runtimes such as Ollama and oMLX / MLX-compatible runtimes
- approved work AI tools such as Gemini and Cursor
- frontier providers such as OpenAI and Anthropic
- future providers or runtimes that may become better fits over time

Without a common gateway or routing layer, each tool would need to be configured separately. That would create duplication, make provider changes harder, increase the chance of work/personal profile drift, and make routing decisions less visible.

## Decision

I will use a gateway-first architecture.

Where practical, CLI tools, chat UI tools, coding tools and future agents should access models through a common gateway or routing layer rather than connecting directly to individual providers.

The gateway should provide a common control point for:

- model aliases
- provider abstraction
- local and frontier routing
- fallback behaviour
- profile-aware policies
- future observability
- future cost or usage controls

The initial gateway candidate is LiteLLM or an equivalent open-source model gateway.

## Options Considered

### Option 1: Direct tool-to-provider configuration

Each tool would connect directly to the model provider or local runtime it needs.

Pros:

- simple for one-off tools
- fewer moving parts at the start
- easier to test individual tools quickly

Cons:

- duplicates configuration across tools
- makes provider changes harder
- makes routing harder to explain
- increases risk of profile drift
- creates separate AI environments for CLI, UI and IDE workflows
- makes future agents harder to govern

### Option 2: Gateway-first architecture

Tools connect to a common gateway where practical.

Pros:

- creates a common model access point
- supports model aliases and provider abstraction
- makes routing more consistent
- supports local-first and frontier-capable behaviour
- helps keep CLI, UI and IDE workflows aligned
- allows providers and runtimes to be replaced more easily
- supports profile-aware routing and governance

Cons:

- introduces another component
- requires gateway configuration and validation
- may not work cleanly with every tool
- may require some tools to bypass the gateway where unavoidable

### Option 3: Gateway later

Start with direct provider access and introduce a gateway once multiple tools are in use.

Pros:

- fastest initial experimentation
- avoids early gateway setup
- useful if tool direction is uncertain

Cons:

- likely creates migration work later
- encourages scattered configuration
- risks locking early workflows to provider-specific assumptions
- delays the core architectural control point

## Rationale

The gateway-first option best supports the project’s architecture principles.

This project is intended to be a durable workstation, not a set of disconnected experiments. A gateway gives the workstation a stable control plane while allowing tools, providers and local runtimes to change over time.

The gateway also supports the profile model. The `macos-work` profile can prioritise approved work AI tools first, while the `windows-personal` profile can use OpenAI and Anthropic more freely for personal experimentation.

## Consequences

### Benefits

- More consistent model access across CLI, UI, IDE and future agents.
- Easier provider replacement.
- Better support for local-first routing.
- Better support for profile-aware policy.
- Easier to explain routing decisions.
- Lower risk of creating separate AI environments.

### Trade-offs

- Adds a component that must be configured and validated.
- Some tools may not integrate cleanly with the gateway.
- The first implementation may need simple external routing before gateway-native routing is mature.

### Risks or Follow-ups

- Validate that the selected gateway works with local runtimes and approved frontier providers.
- Confirm Open WebUI can use the gateway cleanly.
- Confirm CLI wrappers can route through the gateway.
- Avoid overbuilding routing logic too early.

## Implementation Impact

Milestone 1 should include:

- gateway configuration
- provider placeholders
- local runtime integration
- basic model aliases
- basic route configuration
- `ask-ai` calling the gateway
- `ai-route` explaining simple routing decisions
- `ai-status` checking gateway health

## Review Trigger

Review this decision if:

- the selected gateway becomes difficult to maintain
- the gateway blocks important tools
- provider compatibility becomes poor
- routing needs are better handled elsewhere
- a clearly better gateway option emerges

## Related Documents

- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/04-capability-contracts.md`
- `docs/07-routing-strategy.md`
- `docs/10-milestones.md`
