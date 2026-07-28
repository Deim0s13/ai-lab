# Tool Evaluation: Browser Chat UI

## Status

Accepted

## Date

2026-07-28

## Capability Area

UI

## Problem

The workstation needs a self-hosted browser chat interface that uses the same LiteLLM gateway, model aliases and profile posture as the CLI.

The selected UI must not become a separate AI environment, silently bypass the gateway or introduce unnecessary RAG, agent or infrastructure complexity.

## Requirements

The tool should support:

- self-hosted browser operation
- local and frontier model access exclusively through LiteLLM where practical
- LiteLLM's OpenAI-compatible API
- existing gateway model aliases
- containerised operation on macOS ARM64 and Windows/WSL2
- Podman-compatible deployment where practical
- repeatable, repository-managed configuration
- safe secret injection without committed credentials
- understood and removable persistent storage
- separate storage or instances for work and personal profiles
- localhost-only exposure by default
- disabling direct provider and runtime connections
- clear health, logs, validation and removal paths
- normal browser chat without requiring RAG, agents or enterprise authentication

## Options Considered

| Option      | Version researched | Notes                                                                                                                    | Screening outcome    |
| ----------- | -----------------: | ------------------------------------------------------------------------------------------------------------------------ | -------------------- |
| Open WebUI  |            v0.10.2 | Explicit LiteLLM support, but both official ARM64 image variants failed during application startup                       | Trial Failed         |
| LibreChat   |             v0.8.7 | MIT licence and declarative custom endpoints; substantially heavier default service stack                                | Proceed to Trial     |
| AnythingLLM |            v1.15.0 | MIT licence, single container and generic OpenAI support; RAG/workspace/agent focus exceeds this milestone               | Parked               |
| LobeHub     |            v2.2.11 | OpenAI proxy support, but current product direction is agent operations with broader infrastructure and a custom licence | Rejected for Chat UI |

## Mandatory Gate Screening

| Gate                             | Open WebUI                        | LibreChat                                                | AnythingLLM                            | LobeHub                                   |
| -------------------------------- | --------------------------------- | -------------------------------------------------------- | -------------------------------------- | ----------------------------------------- |
| Self-hosted                      | Pass                              | Pass                                                     | Pass                                   | Pass                                      |
| Open-source fit                  | Conditional: custom licence       | Pass: MIT                                                | Pass: MIT                              | Conditional: custom licence               |
| LiteLLM/OpenAI-compatible access | Strong documented fit             | Generic custom endpoint                                  | Generic OpenAI provider                | OpenAI proxy configuration                |
| Existing alias discovery         | Documented auto-discovery         | Model fetch supported; verify                            | Verify manually                        | Verify manually                           |
| Gateway-only operation           | Conditional configuration         | Configurable through custom-only endpoints               | UI configuration requires verification | Direct-provider posture remains a concern |
| Repeatable container deployment  | Strong                            | Pass, but multi-service                                  | Pass                                   | Operationally complex                     |
| Storage understood               | Single `/app/backend/data` volume | MongoDB, uploads, logs, MeiliSearch and pgvector storage | `/app/server/storage`                  | Database/authentication infrastructure    |
| Profile separation               | Separate volume/instance required | Separate Compose project/data required                   | Separate storage directory required    | Separate deployment required              |
| Scope fit                        | Strong                            | Good                                                     | Weak                                   | Weak                                      |

## Evaluation Criteria

| Criteria                      | Why it matters                                                                    |
| ----------------------------- | --------------------------------------------------------------------------------- |
| Open-source fit               | Aligns with the open-source-first principle and avoids unclear future constraints |
| Local-first support           | Must expose local gateway routes without creating a direct runtime path           |
| Gateway/profile compatibility | Must use LiteLLM and preserve work/personal boundaries                            |
| CLI compatibility             | Lifecycle and troubleshooting must remain operable through terminal workflows     |
| Config over code              | Configuration should be reproducible without custom application logic             |
| Rebuildability                | Installation, restart, recreation and removal must be repeatable                  |
| Security posture              | Direct providers, signup, secrets and network exposure must be controlled         |
| Maintenance burden            | The UI should not introduce more services than its recurring value justifies      |
| Replaceability                | UI state and configuration should not lock the workstation into one tool          |
| Daily usability               | Normal chat, model selection and history should be straightforward                |

## Provisional Research Score

The issue weights are applied using:

- Strong fit: 5
- Good fit: 4
- Trial fit: 3
- Weak fit: 2
- Reject: 1

These scores are provisional until practical testing is completed.

| Candidate   | Gateway 25% | Rebuild/config 20% | Privacy/profile 20% | Complexity 15% | Usability 10% | Maintenance/licence 10% | Result |
| ----------- | ----------: | -----------------: | ------------------: | -------------: | ------------: | ----------------------: | -----: |
| Open WebUI  |           5 |                  4 |                   3 |              5 |             5 |                       4 | 86/100 |
| LibreChat   |           4 |                  3 |                   4 |              2 |             4 |                       5 | 72/100 |
| AnythingLLM |           3 |                  3 |                   3 |              4 |             4 |                       4 | 67/100 |
| LobeHub     |           3 |                  2 |                   2 |              1 |             4 |                       3 | 48/100 |

## Assessment

### Open WebUI

#### Strengths

- Explicit LiteLLM configuration and automatic model discovery
- Official macOS, ARM64, Podman and WSL guidance
- Single-container deployment for the required workflow
- Stable version tags are available
- Persistent data and removal procedures are documented
- Environment configuration can be made authoritative

#### Weaknesses / Risks

- Uses a custom licence with branding conditions
- `ENABLE_DIRECT_CONNECTIONS` currently defaults to `True`
- Ollama access defaults to enabled and could bypass LiteLLM
- Signup defaults to enabled
- Database-persisted settings override environment variables by default
- Configuration must disable unnecessary RAG, tools and provider access
- LiteLLM should eventually provide an inference-scoped key instead of exposing its management/master key

### LibreChat

#### Strengths

- MIT licence
- Gateway endpoints can be declared in `librechat.yaml`
- Keys can be supplied through environment variables
- Available endpoints can be restricted to the configured custom endpoint
- YAML configuration is validated at startup
- Strong authentication and multi-user controls

#### Weaknesses / Risks

- Default Compose stack currently contains six services
- MongoDB, MeiliSearch, pgvector and RAG are beyond basic UI parity
- More secrets, ports, volumes and upgrade paths must be maintained
- Tagged source currently references floating container tags
- Profile isolation spans several data locations
- Operational overhead may exceed the value of a personal browser UI

### AnythingLLM

#### Strengths

- MIT licence
- Single-container deployment
- Clear persistent storage mount
- Generic OpenAI-compatible provider support
- Active project and documented removal path

#### Weaknesses / Risks

- Designed around workspaces, vector storage, RAG and agents
- Generic gateway configuration is primarily managed through UI settings
- Adds a separate model-router concept
- Normal chat behavior includes document-similarity concepts
- Overlaps later RAG and controlled-agent milestones

### LobeHub

#### Strengths

- Self-hosted deployment is available
- OpenAI-compatible proxy configuration exists
- Active development and polished interface

#### Weaknesses / Risks

- Current direction is an agent operations platform rather than a focused chat UI
- Uses the LobeHub Community Licence
- Recommended deployment introduces database and authentication infrastructure
- Broader provider and agent behavior increases the risk of gateway bypass
- Significant capability overlap with later agent milestones
- More operational complexity than the current workflow justifies

## Fit Against Project Principles

| Principle              | Open WebUI                              | LibreChat            | AnythingLLM                 | LobeHub             |
| ---------------------- | --------------------------------------- | -------------------- | --------------------------- | ------------------- |
| Open-source-first      | Good, with licence caveat               | Strong               | Strong                      | Weak/conditional    |
| Gateway-first          | Strong if hardened                      | Good                 | Trial fit                   | Trial/weak          |
| CLI-native             | Good lifecycle support                  | Good Compose support | Good container support      | Operationally heavy |
| Config over code       | Good when persistent config is disabled | Strong               | Trial fit                   | Trial fit           |
| Thin custom layer      | Strong                                  | Good                 | Weak due capability overlap | Weak                |
| Rebuildable by default | Strong                                  | Good but complex     | Good                        | Weak                |
| Replaceable components | Strong                                  | Good                 | Trial fit                   | Weak                |

## Practical Trial Plan

Advance Open WebUI and LibreChat only.

For each candidate:

1. Use the exact researched release or an immutable image digest.
2. Start it in an isolated temporary deployment.
3. Bind only to `127.0.0.1`.
4. Configure only the existing LiteLLM endpoint.
5. Keep secrets outside committed files.
6. Confirm `local-fast`, `local-capable` and `local-code` aliases are visible where currently executable.
7. Send the same synthetic prompt through each UI.
8. Confirm the request appears in LiteLLM logs.
9. Stop LiteLLM and confirm the UI fails without direct-provider fallback.
10. Restart and recreate the UI and inspect persistence.
11. Record required containers, volumes, configuration files and secrets.
12. Record startup time, approximate memory use and subjective daily usability.
13. Remove the candidate and confirm the removal path is understood.

### Open WebUI trial controls

At minimum verify:

- `ENABLE_DIRECT_CONNECTIONS=False`
- `ENABLE_OLLAMA_API=False`
- `ENABLE_OPENAI_API=True`
- `ENABLE_OPENAI_API_PASSTHROUGH=False`
- `ENABLE_SIGNUP=False` after account provisioning
- `ENABLE_PERSISTENT_CONFIG=False`
- `OPENAI_API_BASE_URL=http://host.containers.internal:4000/v1`
- separate data volume per profile
- persistent `WEBUI_SECRET_KEY`
- pinned `v0.10.2` image or immutable digest

### LibreChat trial controls

At minimum verify:

- only the custom LiteLLM endpoint is enabled
- no `user_provided` direct-provider endpoints remain available
- LiteLLM credentials are injected through environment variables
- `librechat.yaml` is mounted read-only
- registration is disabled after initial provisioning
- supporting database/search/RAG services are not exposed externally
- separate Compose project and data directories are used per profile
- all container images are pinned by version or digest
- whether nonessential RAG and search services can be removed safely

## Practical Trial Results

The temporary Open WebUI and LibreChat deployments, profile-scoped volumes and trial secrets were removed after testing. Container images were left cached locally and may be removed independently.

### Open WebUI — Failed

Tested on the `macos-work` profile using Podman on macOS ARM64.

Images tested:

- `ghcr.io/open-webui/open-webui:v0.10.2`
- `ghcr.io/open-webui/open-webui:v0.10.2-slim`

Both images:

- used the official `linux/arm64` image
- matched the Podman VM's `aarch64` architecture
- started Bash and Python successfully
- exited with code `132` when launching the Open WebUI application through Uvicorn
- produced no application-level logs
- never reached the `/health` endpoint

The full and slim variants therefore fail the mandatory macOS ARM64 deployment gate. Gateway routing, persistence and daily usability could not be tested because the application did not start.

Further debugging of bundled native Python dependencies is outside this evaluation. Adopting Open WebUI would otherwise require maintaining a custom image or workaround, conflicting with the rebuildability and maintenance requirements.

### LibreChat — Passed

Tested LibreChat v0.8.7 on the `macos-work` profile using pinned ARM64 images for LibreChat and MongoDB.

The trial confirmed:

- operation with only LibreChat and MongoDB
- no requirement for MeiliSearch, pgvector, RAG API or the admin panel
- localhost-only exposure on port 3080
- configuration through a read-only `librechat.yaml`
- credentials supplied through environment variables
- only the custom LiteLLM endpoint enabled
- existing gateway model aliases discovered
- successful synthetic chat through `local-fast`
- requests visible in LiteLLM logs
- visible failure when LiteLLM was stopped, with no provider fallback
- registration disabled after initial provisioning
- account and conversation persistence after full recreation
- profile-scoped MongoDB storage
- familiar, ChatGPT-like daily usability

The two-container deployment used approximately 678 MB of memory during the recorded sample.

Operational caveats:

- MongoDB 4.4.18 is required on Apple Silicon because the default MongoDB image requires unsupported AVX instructions.
- Bind-mounted configuration must live beneath `/Users` so it is shared with the Podman VM.
- The minimal Compose definition must pin images instead of using the floating tags in LibreChat's default Compose file.
- LibreChat logs a non-blocking warning when the intentionally omitted RAG API is unavailable.

### Community and Maintenance Health

LibreChat has a large and active contributor community. At the time of evaluation, the project had approximately 41,350 GitHub stars, 8,520 forks and 384 contributors.

During the preceding three months, 682 pull requests were merged from approximately 72 distinct authors. Of 405 issues opened during the same period, 293 had already closed. The project also maintains active documentation, GitHub Discussions, a published roadmap and a Discord community reported to exceed 9,000 members.

Maintenance remains somewhat centralized around the founder, and the large issue and pull-request backlogs indicate triage pressure. Recent releases are also marked as prereleases. These risks are acceptable provided deployments remain version- and digest-pinned, upgrades are tested, and the UI remains replaceable.

## Decision

Accepted.

Select LibreChat v0.8.7 as the browser chat UI for the current workstation capability.

- Reject Open WebUI because both official v0.10.2 ARM64 variants failed the mandatory startup gate.
- Park AnythingLLM for possible future RAG evaluation.
- Reject LobeHub for this capability because its agent-platform scope and operational complexity exceed UI parity.

## Rationale

LibreChat passed every mandatory practical gate and provides a familiar daily-use chat interface through the existing LiteLLM gateway.

A minimal two-container deployment removes the default search, vector, RAG and administration services without affecting normal chat. The remaining MongoDB dependency and approximately 678 MB sampled memory are acceptable for the capability.

The selection requires configuration and Compose orchestration, but no custom application or routing code. Gateway access, model aliases and profile boundaries remain authoritative and replaceable.

## Implementation Notes

- Permanent service definitions are deferred to #56.
- Final validation and adoption are deferred to #57.
- Temporary proof material may be kept under `labs/` if evidence needs to be retained.
- Do not add UI behavior to `bin/ai`.
- Do not configure direct provider credentials.
- Use synthetic prompts only.

## Follow-up Issues

- #56 — Add reproducible browser chat UI service lifecycle
- #57 — Validate and document browser UI parity

## Review Trigger

Review this evaluation if:

- practical gateway testing contradicts the documentation assessment
- Open WebUI licence terms no longer fit the project
- LibreChat provides a supported minimal deployment without RAG/search services
- the selected tool cannot enforce gateway-only operation
- profile state cannot be separated safely
- operational overhead outweighs recurring use
- a materially simpler open-source browser UI emerges

## Related Documents

- `docs/04-capability-contracts.md`
- `docs/05-component-lifecycle.md`
- `docs/09-tool-selection.md`
- `docs/10-milestones.md`
- `docs/adr/0001-gateway-first.md`
- `docs/adr/0002-open-source-first.md`
- `docs/adr/0004-rebuildable-by-default.md`
- `docs/adr/0005-composable-and-replaceable.md`
- GitHub issue #55
- https://docs.openwebui.com/
- https://www.librechat.ai/docs/
- https://docs.anythingllm.com/
- https://github.com/lobehub/lobehub
