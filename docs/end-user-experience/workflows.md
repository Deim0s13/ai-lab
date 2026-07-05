# End-User Workflows

This document defines the core daily workflows the AI Dev Workstation should support.

The purpose is to give Milestone 4 enough direction to separate user-facing commands from operator commands and decide what the first end-user command pattern should look like.

This is not an architecture document and it should stay compact.

## Principles

The end-user experience should:

- keep LiteLLM as the stable gateway interface
- make daily AI use feel separate from workstation maintenance
- use clear route choices before introducing hidden routing behaviour
- prefer existing tools and small command patterns before custom application code
- keep operator workflows available without making them the centre of daily use

## Workflow Groups

| Group | Purpose | Examples |
|---|---|---|
| User workflows | Daily AI use | ask, explain, summarise, review, code help |
| Operator workflows | Running and maintaining the workstation | gateway lifecycle, MLX lifecycle, model fitness, diagnostics |

## User Workflows

| Workflow | Purpose | Preferred route/group | Current command pattern | Future command feel |
|---|---|---|---|---|
| Quick ask | Short answers, simple help, command reminders | local-fast | `just ask` | `ai ask` |
| Explain / summarise | Explain concepts, summarise notes, structure information | local-fast for short work; local-capable for longer work | `just ask` or `just ask-model local-capable-mlx` | `ai explain`, `ai summarise` |
| Planning / trade-off analysis | Compare options, structure decisions, plan implementation | local-capable | `just ask-model local-capable-mlx` | `ai plan`, `ai ask --route local-capable` |
| Command / config review | Review shell, YAML, Markdown, LiteLLM config or just recipes | local-code | `just ask-model local-code-mlx` | `ai review`, `ai explain-command` |
| Coding assistance | Help with scripts, errors, tests and repo structure | local-code | `just ask-model local-code-mlx` | `ai code`, OpenCode if proven useful |
| Route / model inspection | Show available routes and current aliases | none | `just gateway-routes`, `just gateway-mlx-models`, `just model-aliases` | `ai routes`, `ai models` |

## Operator Workflows

| Workflow | Purpose | Current commands |
|---|---|---|
| Gateway lifecycle | Start, stop and check LiteLLM | `just ai-up`, `just ai-check`, `just ai-down` |
| MLX lifecycle | Start, stop and check MLX model servers | `just mlx-up`, `just mlx-check`, `just mlx-down`, `just mlx-logs` |
| Model fitness review | Run repeatable model fitness checks | `just model-fitness-review`, `just eval-model-fitness`, `just eval-model-fitness-mlx` |
| Diagnostics | Inspect config, routes and installed models | `just check-yaml`, `just gateway-routes`, `just gateway-mlx-models`, `just model-aliases`, `just models` |
| Decommissioning | Review and remove unused models | documented in `docs/model-fitness/README.md` |

## Route Mapping

| Gateway group | Current candidate route | Intended use |
|---|---|---|
| local-fast | local-fast-mlx | Default daily help and quick responses |
| local-capable | local-capable-mlx | Longer explanations, planning and trade-off analysis |
| local-code | local-code-mlx | Coding, command, config and repository assistance |

## Current Direction

For now, `just` remains the operator layer and the working command interface.

Milestone 4 should use this workflow map to decide:

- which commands should feel user-facing
- which commands should remain operator/admin commands
- whether existing tools like `llm`, `aichat` or OpenCode are a better fit
- whether a thin `ai` command is justified

The project should not build a full application until the daily workflows and command boundaries are clearer.

## Out of Scope

This workflow map does not implement:

- a new CLI wrapper
- semantic routing
- provider fallback
- OpenCode integration
- a desktop app
- scheduled model fitness automation
