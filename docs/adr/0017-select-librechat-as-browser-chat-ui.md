# ADR-0017: Select LibreChat as the Browser Chat UI

## Status

Accepted

## Date

2026-07-28

## Context

The workstation needs a self-hosted browser chat interface that uses the same LiteLLM gateway, model aliases and profile posture as the CLI. The UI must not become a separate AI environment, bypass the gateway or introduce RAG and agent infrastructure before those capabilities are intentionally evaluated.

Issue #55 compared Open WebUI, LibreChat, AnythingLLM and LobeHub. Open WebUI and LibreChat advanced to practical trials on the `macos-work` profile.

Open WebUI v0.10.2 failed the mandatory macOS ARM64 startup gate with exit code 132 in both its full and slim official images. LibreChat v0.8.7 passed startup, gateway-only routing, model discovery, persistence, profile separation and usability testing.

## Decision

Select LibreChat as the browser chat UI, using v0.8.7 as the tested implementation baseline.

The standard deployment will:

- use a minimal LibreChat and MongoDB service pair
- bind the browser interface to localhost by default
- expose only a custom LiteLLM endpoint
- inject gateway credentials without committing them
- pin container versions or immutable digests
- keep configuration, state and volumes separate by profile
- omit the admin panel, MeiliSearch, pgvector and RAG services until separately required

Permanent lifecycle implementation is deferred to issue #56.

## Options Considered

### Option 1: Open WebUI

Open WebUI offered explicit LiteLLM support and a single-container deployment.

Pros:

- documented LiteLLM integration and model discovery
- low expected operational overhead
- official Podman and ARM64 guidance

Cons:

- both tested v0.10.2 ARM64 variants failed during application startup
- custom licence and branding conditions
- gateway-bypass features require explicit hardening
- adoption would require maintaining an unsupported workaround or custom image

### Option 2: LibreChat

LibreChat provides a configurable OpenAI-compatible custom endpoint and a familiar browser chat interface.

Pros:

- MIT licensed with an active contributor community
- passed gateway-only and gateway-failure testing
- discovered and used existing LiteLLM model aliases
- persisted accounts and conversations across recreation
- worked without its optional search, vector, RAG and administration services

Cons:

- requires MongoDB for persistent operation
- used approximately 678 MB of memory in the recorded two-container sample
- default Compose configuration is broader than the required capability
- Apple Silicon requires an older compatible MongoDB image

### Option 3: AnythingLLM

AnythingLLM supports self-hosting and generic OpenAI-compatible providers.

Pros:

- MIT licensed
- single-container deployment
- clear persistent-storage model

Cons:

- primarily designed around workspaces, RAG and agents
- overlaps later project milestones
- adds a separate model-router concept and more UI-managed configuration

### Option 4: LobeHub

LobeHub provides a polished self-hosted interface with OpenAI-compatible proxy support.

Pros:

- active development
- broad provider support
- polished user experience

Cons:

- current product direction is an agent operations platform
- custom community licence
- broader infrastructure and provider surface than UI parity requires
- increased risk of gateway bypass and future capability overlap

## Rationale

LibreChat is the only candidate that passed every mandatory practical gate. It preserves the gateway-first architecture, uses configuration rather than custom application code and provides a familiar daily-use browser experience.

The minimal two-service deployment supports the required workflow without introducing premature RAG or agent infrastructure. Its MongoDB dependency and measured resource use are acceptable for the capability.

This decision aligns with the open-source-first, local-first, config-over-code, rebuildable-by-default and composable-and-replaceable principles. LiteLLM remains authoritative for model access and routing, so LibreChat can be replaced without changing the workstation's core interface contracts.

## Consequences

### Benefits

- Adds browser chat without creating a second routing environment.
- Preserves existing LiteLLM aliases, policies and observability.
- Requires no custom UI, provider or routing implementation.
- Supports profile-scoped configuration and persistent state.
- Uses an established open-source project with an active community.

### Trade-offs

- Adds a MongoDB service and persistent volume.
- Requires a project-managed minimal Compose definition instead of the default stack.
- Requires explicit registration, endpoint, network and secret controls.
- Uses more resources than a single-container UI.
- Requires macOS configuration files to live in a path shared with the Podman VM.

### Risks or Follow-ups

- Pin and test every LibreChat and MongoDB upgrade; the evaluated LibreChat release is marked as a prerelease.
- Monitor project health because maintenance remains somewhat founder-centred despite broad contribution.
- Replace the local LiteLLM master key with an inference-scoped key when the gateway supports the required credential workflow.
- Treat the missing-RAG startup warning as expected unless it obscures actionable errors.
- Re-evaluate optional RAG, search, agent and administration services in their own milestones.

## Implementation Impact

Issue #56 will add the permanent, profile-aware service definition and lifecycle commands. It should include:

- pinned LibreChat and MongoDB images
- localhost-only exposure
- a read-only `librechat.yaml`
- environment-based secret injection
- `ENDPOINTS=custom` with LiteLLM as the only endpoint
- separate Compose project names and volumes per profile
- registration lock after initial account provisioning
- documented startup, health, logs, recreation and removal commands

Issue #57 will validate UI parity and update user-facing documentation. No LibreChat-specific routing or UI logic should be added to `bin/ai`.

## Review Trigger

Review this decision if:

- LibreChat cannot enforce gateway-only operation
- profile state cannot remain isolated
- operational or resource overhead outweighs daily use
- the project becomes unmaintained or its licence changes
- supported releases cease working on required workstation platforms
- a materially simpler open-source browser UI passes the same practical gates

## Related Documents

- `docs/tool-evaluations/002-browser-chat-ui.md`
- `docs/04-capability-contracts.md`
- `docs/05-component-lifecycle.md`
- `docs/09-tool-selection.md`
- `docs/10-milestones.md`
- `docs/adr/0001-gateway-first.md`
- `docs/adr/0002-open-source-first.md`
- `docs/adr/0004-rebuildable-by-default.md`
- `docs/adr/0005-composable-and-replaceable.md`
- GitHub issues #55, #56 and #57
