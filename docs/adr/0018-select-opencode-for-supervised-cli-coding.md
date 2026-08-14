# ADR-0018: Select OpenCode for Supervised CLI Coding

## Status

Accepted

## Date

2026-08-14

## Context

The workstation needs a repository-aware terminal coding workflow that complements `ai code`, Claude Code, Codex and Cursor without creating a custom coding or agent platform.

Issue #40 evaluated OpenCode, Goose, Aider, Qwen Code and Cline CLI. The evaluation considered current supervised coding quality, LiteLLM compatibility, local-model usefulness, repository and command safety, rebuildability and the potential to support future controlled workflows.

No candidate demonstrated reliable autonomous completion with `local-code-mlx`. However, autonomous operation is not required for the initial capability.

OpenCode produced the strongest functional result in the realistic comparative trial. It correctly added the stable gateway alias and changed actual code-mode routing while preserving unrelated work and respecting repository, secret and gateway boundaries.

OpenCode also provides granular permissions, OpenAI-compatible providers, MCP, ACP, subagents, headless operation and a server interface. These capabilities offer a credible future path, but they expand the available tool surface and must not be enabled without separate validation.

The trial also identified significant limitations:

- gateway failures retry indefinitely and require manual interruption
- local-model planning and tool calling are inconsistent
- context use can be inefficient
- completion signalling is not always reliable
- generated plans, edits, validation and completion claims require review

A decision is required before adding permanent, reproducible configuration.

## Decision

Select OpenCode as the preferred additional CLI coding frontend for supervised interactive use.

The adopted workflow will:

- use LiteLLM as the only model-provider endpoint
- initially use the tested `local-code-mlx` route and move to the stable `local-code` alias when delivered
- require explicit approval for edits and commands
- restrict access to the selected repository
- exclude secrets, ignored files and external directories
- keep web access, MCP, subagents and sharing disabled initially
- keep configuration and state local, inspectable and removable
- preserve existing working-tree changes
- require operator review of plans, diffs, commands, tests and final claims
- remain complementary to Claude Code, Codex, Cursor and `ai code`

OpenCode is not approved for:

- autonomous or unattended execution
- background or scheduled workflows
- headless coding automation
- automatic frontier escalation
- direct provider access that bypasses LiteLLM
- broad work-profile context access
- silently enabled MCP servers, subagents or external tools

The indefinite gateway retry is accepted only as an interactive limitation. The operator may interrupt the session when the gateway is unavailable.

No external timeout wrapper, custom agent framework or additional `bin/ai` orchestration will be added to compensate for this behaviour.

This decision does not enable controlled agents under `macos-work`. OpenCode is initially a supervised coding interface, not an autonomous agent runner. Broader capabilities remain governed by ADR-0014.

## Options Considered

### Option 1: OpenCode

OpenCode is a repository-aware coding frontend with custom OpenAI-compatible providers, granular permissions, MCP, ACP, subagents and server support.

Pros:

- strongest functional result in the realistic comparison
- preferred coding-oriented terminal experience
- remained gateway-bound during testing
- preserved unrelated changes and ignored secrets
- granular, tool-native permission controls
- credible evolution path without custom project frameworks
- open-source and replaceable

Cons:

- gateway failures retry indefinitely
- planning and completion were inconsistent with the selected local model
- context use was inefficient during the realistic task
- rejected permissions can stop a turn
- autonomous use was not proven safe or reliable

### Option 2: Goose

Goose provides CLI, desktop and API interfaces, approval modes, recipes, MCP, ACP and subagents.

Pros:

- clear interactive approvals
- visible gateway failure within seconds
- broad workflow-consolidation potential
- small and inspectable runtime state

Cons:

- implemented less of the realistic task than OpenCode
- native tool calling was inconsistent
- final reporting materially overstated completion
- provider failures returned exit code `0`
- context use and compaction were excessive

### Option 3: Aider

Aider provides a focused terminal pair-programming workflow with Git-based recovery and OpenAI-compatible provider support.

Pros:

- most reliable narrow editing behaviour
- mature Git-oriented workflow
- smaller default agent and tool surface
- preserved unrelated work and ignored secrets

Cons:

- weaker future integration and consolidation path
- uneven analysis quality
- gateway failure was slow and returned exit code `0`
- insufficient incremental value over existing coding tools

### Option 4: Qwen Code

Qwen Code provides a Qwen-native coding harness, granular permissions, bounded execution, MCP, skills and subagents.

Pros:

- strong architectural and permission model
- explicit timeout, retry, turn and tool-call limits
- successful LiteLLM authentication
- isolated and inspectable state

Cons:

- failed to produce a usable realistic plan
- initial planning exceeded its 12-minute limit
- recovery and plan finalisation were unreliable
- emitted malformed tool-call output with the selected stack

### Option 5: Cline CLI

Cline provides a shared coding-agent core across CLI, IDE, ACP and SDK interfaces.

Pros:

- strong cross-interface convergence potential
- explicit timeout, retry and compaction controls
- sandboxing, checkpoints and permission policies
- broad OpenAI-compatible provider support

Cons:

- official Apple Silicon binaries failed macOS signature verification
- macOS terminated the tested executables before startup
- no provider or realistic workflow trial was possible
- local re-signing would undermine rebuildability and artifact trust

### Option 6: Select no additional tool

Continue using only Claude Code, Codex, Cursor and `ai code`.

Pros:

- no additional installation or maintenance
- avoids accepting known OpenCode limitations
- retains existing established workflows

Cons:

- loses a useful supervised local-first coding frontend
- does not use the strongest functional result from the evaluation
- delays practical experience with MCP, ACP and replaceable coding interfaces

## Rationale

OpenCode offers the best balance of current supervised usefulness and future replaceability.

It aligns with the gateway-first, CLI-native, open-source-first, local-first, config-over-code and composable-and-replaceable principles. LiteLLM remains authoritative for model access and routing, so OpenCode can be replaced without changing the workstation’s core route contracts.

The selection deliberately distinguishes supervised coding from autonomous agents. OpenCode’s broader capabilities do not need to be enabled to provide current value.

Known retry, context and completion limitations are acceptable because the initial workflow remains interactive and operator-controlled. They would not be acceptable for headless, autonomous or background execution.

Selecting OpenCode also avoids creating a custom coding frontend, timeout layer or agent framework inside this repository.

## Consequences

### Benefits

- Adds a supervised local-first repository coding workflow.
- Reuses the existing LiteLLM gateway and model aliases.
- Avoids new routing or provider logic in `bin/ai`.
- Provides granular approval and repository controls.
- Preserves a path to MCP, ACP and subagent capabilities after future validation.
- Keeps the coding frontend replaceable.

### Trade-offs

- Adds another installed development tool and local state.
- Gateway failures may require manual interruption.
- Operator review remains mandatory.
- Local-model planning and tool calling may need correction or retry.
- OpenCode does not replace existing frontier coding tools.
- The selected workflow cannot currently be used for dependable automation.

### Risks or Follow-ups

- Pin and validate OpenCode upgrades because configuration changes rapidly.
- Confirm that permission defaults remain conservative.
- Keep MCP, subagents, web access and sharing disabled until separately evaluated.
- Verify that no provider configuration bypasses LiteLLM.
- Monitor gateway retry behaviour for a native bounded-session fix.
- Reassess the workflow if it is not useful in regular supervised work.
- Do not infer autonomous reliability from supervised success.

## Implementation Impact

Issue #60 should add reproducible, profile-aware OpenCode installation and configuration using tool-native mechanisms.

The implementation should:

- pin the selected OpenCode version
- configure LiteLLM as the only provider endpoint
- use environment-based credential injection
- adopt the stable `local-code` alias when available
- define conservative permissions for `macos-work`
- disable MCP, subagents, web access, sharing and external directories
- document inspectable configuration, session, log and cache locations
- provide clean removal and rebuild steps
- avoid adding provider, retry or agent logic to `bin/ai`

Issue #61 should validate and document the supervised workflow, including startup, repository selection, approvals, diff review, verification, gateway failure, state inspection and cleanup.

## Review Trigger

Review this decision if:

- OpenCode cannot remain gateway-only
- permission or secret-handling behaviour weakens
- the workflow is not useful in regular supervised development
- gateway retry behaviour makes interactive use impractical
- OpenCode becomes unmaintained or its licence changes
- configuration or state cannot remain rebuildable and removable
- local-model tool calling materially improves or degrades
- a competing tool provides materially better supervised outcomes
- autonomous or work-profile agent use becomes a requirement

## Related Documents

- `docs/tool-evaluations/003-cli-coding-assistant.md`
- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/09-tool-selection.md`
- `docs/10-milestones.md`
- `docs/11-cli-interface-contracts.md`
- `docs/12-cli-habit-layer.md`
- `docs/adr/0001-gateway-first.md`
- `docs/adr/0002-open-source-first.md`
- `docs/adr/0004-rebuildable-by-default.md`
- `docs/adr/0005-composable-and-replaceable.md`
- `docs/adr/0014-controlled-agent-guardrails.md`
- `docs/adr/0016-use-existing-tools-for-routing-and-validation-where-practical.md`
- GitHub issues #40, #59, #60 and #61
