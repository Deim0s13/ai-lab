# AI Lab / AI Dev Workstation — Agent Instructions

## Purpose

This repository is for **AI Dev Workstation as Code**: a rebuildable, local-first, gateway-led AI workstation for daily development, architecture, writing, research, and future controlled agent workflows.

The goal is not to build a custom AI platform from scratch.

The goal is to compose existing tools into a useful, durable workstation with a stable daily-use interface.

## Before starting work

Before making changes, inspect the relevant project documentation.

Start with:

- `docs/00-overview.md` — project orientation and documentation map
- `docs/01-vision.md` — north star and success criteria
- `docs/02-principles.md` — architecture principles
- `docs/03-architecture.md` — target architecture and layer model
- `docs/09-tool-selection.md` — tool selection rules and build-versus-adopt guidance
- `docs/10-milestones.md` — delivery sequence and current milestone intent
- `docs/11-cli-interface-contracts.md` — CLI behaviour contracts
- `docs/12-cli-habit-layer.md` — thin CLI habit-layer boundary
- `docs/adr/README.md` — ADR purpose and when to create one
- `docs/adr/0011-secrets-management-strategy.md` — Bitwarden-first secrets strategy
- `docs/adr/0016-use-existing-tools-for-routing-and-validation-where-practical.md` — key guardrail against custom-code creep
- `docs/adr/0017-select-librechat-as-browser-chat-ui.md` — selected browser UI and its boundaries
- `docs/adr/0018-select-opencode-for-supervised-cli-coding.md` — selected supervised coding frontend and its boundaries

When working on a tool evaluation, use:

- `docs/tool-evaluations/template.md`

When working on architecture-impacting decisions, use:

- `docs/adr/adr-template.md`

If a referenced document is missing or renamed, stop and report the mismatch rather than inventing a replacement path.

## Core project principles

Follow the project principles in `docs/02-principles.md`.

The most important operating principles are:

- Gateway-first model access
- CLI-native workflows
- Open-source-first adoption
- Rebuildable by default
- Disposable machine, durable repo
- Configuration over hard-coded behaviour
- Local-first, not local-only
- Profile-aware governance
- Secure secrets by default
- Capability-based design
- Stable workflows, replaceable implementations
- Observable and explainable routing
- Model fitness informs model choice
- Agents with guardrails
- Documented decisions
- Daily use over novelty

These principles are not optional. Use them to decide whether a change belongs in the repo.

## Architecture intent

The intended architecture is:

- `just` handles local task orchestration and repeatable operator workflows.
- LiteLLM or an equivalent gateway handles model/provider access where practical.
- oMLX is the preferred Apple Silicon runtime for `macos-work`; Ollama is the fallback and compatibility runtime.
- Profiles define work/personal posture and routing constraints.
- `bin/ai` provides the stable, thin daily-use habit layer.
- LibreChat is the selected browser UI and must use LiteLLM as its only model endpoint.
- OpenCode is the selected additional frontend for supervised, local-first repository coding. It must remain gateway-only, profile-aware and conservatively permissioned.
- `local-code` is the stable coding route; `local-code-mlx` remains the explicit implementation route for diagnostics.
- UI, coding and future agent tools should connect to the same gateway/configuration model where practical.
- Agents and RAG come later, after routing, context boundaries, and access controls are trusted.

Do not create separate AI environments for CLI, UI, IDE, and agents unless there is a documented reason.

OpenCode approval is limited to supervised coding. Do not infer approval for autonomous execution, subagents, MCP, ACP, external-directory access, unattended operation or broad work-profile agency from ADR-0018.

## Collaboration and authorization

The operator is learning and implementing this project deliberately.

Default to inspecting, explaining, planning and providing exact copy-and-paste changes for the operator to apply. Modify repository files, create commits, push changes, close issues, change milestones or mutate external services only when the operator explicitly asks for that action.

Read-only inspection and proportionate validation are acceptable when they help answer the request. Preserve unrelated work and never turn a narrow task into a broad refactor.

## Current drift warning

Be careful with `bin/ai`.

The `ai` command is intended to be a thin habit-layer interface. It should not become a large bespoke application that reimplements routing, validation, task-running, health checking, history systems, or orchestration that existing tools can provide.

Before adding more logic to `bin/ai`, check:

- `docs/12-cli-habit-layer.md`
- `docs/11-cli-interface-contracts.md`
- `docs/09-tool-selection.md`
- `docs/adr/0016-use-existing-tools-for-routing-and-validation-where-practical.md`

If a change would make `bin/ai` larger or more complex, first evaluate whether an existing tool should provide the generic capability instead.

Acceptable custom CLI code:

- project-specific command surface
- profile-aware explanation
- thin orchestration
- light validation glue
- user-friendly status output
- delegation to existing tools

Avoid custom CLI code that recreates:

- generic model routing
- retries and fallback engines
- task runners
- YAML validation
- generic health-check frameworks
- provider execution logic
- large bespoke command frameworks
- custom agent frameworks

## Build versus adopt rule

Use `docs/09-tool-selection.md` before introducing new custom implementation.

Default posture:

```text
custom CLI = project-specific interface
existing tools = generic execution capability
```

Before building custom code, answer:

1. What capability is needed?
2. Does an existing tool already provide it?
3. Is the custom code genuinely project-specific?
4. Can the behaviour be configuration rather than code?
5. Does this preserve gateway-first and profile-aware design?
6. Does this support daily use?
7. Can it be rebuilt and replaced later?
8. Does it reduce or increase maintenance burden?

If the answer points to existing tooling, prefer the tool.

If custom code is still needed, keep it small, understandable, and replaceable.

## Tool evaluation discipline

Use `docs/tool-evaluations/template.md` for meaningful tool evaluations.

A tool evaluation should include:

- capability area
- problem being solved
- requirements
- options considered
- fit against project principles
- what was actually tested
- strengths
- weaknesses and risks
- selected, rejected, or parked decision
- implementation notes
- follow-up issues
- review trigger
- related documents

Tool evaluations should not be paper-only when a small working proof is practical.

Do not adopt a tool just because it is interesting. It must support a real recurring workflow.

## ADR discipline

Use ADRs for decisions that affect architecture, durable tool choices, routing behaviour, provider posture, profile boundaries, secrets strategy, rebuild strategy, or significant capability direction.

Use:

- `docs/adr/adr-template.md`

Check:

- `docs/adr/README.md`

Create or update an ADR when:

- adopting or replacing a major tool
- changing the gateway or routing model
- changing work/personal profile behaviour
- changing secrets strategy
- changing runtime access patterns
- introducing agents, RAG, or persistent memory
- accepting a trade-off that future maintainers may question

Do not create ADRs for minor fixes, typos, simple refactors, or temporary experiments that are not adopted.

## Issue discipline

For implementation issues, keep the issue outcome practical.

Each issue should state:

- user-visible outcome
- relevant milestone or capability
- existing tool being used
- custom code being added, if any
- why custom code is unavoidable
- files likely to change
- validation commands
- deferred work
- out-of-scope items

If work is excluded, capture:

- what is excluded
- why it is excluded now
- where it will be picked up later

Prefer implementation issues with useful outcomes over documentation-only or decision-only issues.

## CLI behaviour expectations

Use `docs/11-cli-interface-contracts.md` and `docs/12-cli-habit-layer.md` before changing CLI behaviour.

The CLI should be:

- stable
- profile-aware
- gateway-first
- local-first
- explainable
- scriptable
- safe by default
- config-driven
- thin

The CLI habit layer should make the workstation easy to use from the terminal. It should not replace existing tools with custom code.

Important expectation:

```text
The habit should outlive the tool.
```

## Profiles and privacy

Respect profile boundaries.

Known profiles:

- `macos-work`
- `windows-personal`
- `fedora-atomic`

Work profile behaviour should be conservative and work-safe.

Personal profile behaviour may allow more experimentation.

Do not mix work and personal context accidentally.

Do not add frontier escalation that is silent, automatic, or unlogged.

Do not store secrets in committed files.

Use the existing secrets strategy and relevant ADRs before changing provider or credential behaviour.

Bitwarden is the preferred source. Committed `.env.example` files contain variable names and placeholders only. Ignored `.env.*.local` files are temporary local fallbacks, not the desired long-term source. Never introduce usable default credentials, print secret values, include them in diffs or duplicate the gateway master key into client configuration when scoped credentials are available.

## Routing expectations

Routing should remain:

- gateway-first where practical
- local-first by default
- profile-aware
- explainable
- observable
- overrideable
- safe for work/personal boundaries

Actual provider/model routing should be delegated to LiteLLM or another selected gateway where practical.

Custom routing code should be limited to policy explanation, mode selection, or thin project-specific glue unless a documented evaluation proves existing tools do not fit.

Frontier escalation must be explicit, visible, and logged.

## Validation expectations

Prefer existing tools for generic validation.

Use existing commands and tool-native checks where practical.

Do not build a custom validation framework unless a tool evaluation shows that existing tools are not fit.

Validation output should be clear and actionable.

When making changes, provide the commands run and the result.

Useful validation patterns may include:

```bash
bash -n bin/ai tools/ai/*.sh
just --fmt --check
just check-yaml
just workstation-status
just ui-check
just opencode-config-check
just opencode-check
AI_LAB_PROFILE=macos-work bin/ai status
AI_LAB_PROFILE=macos-work bin/ai routes test "Review this shell command"
AI_LAB_PROFILE=macos-work bin/ai history --limit 5
```

Only use commands that actually exist in the current repo.

Run lifecycle commands such as `just workstation-up`, `just workstation-down`, `just ui-up` or `just ui-down` only when runtime mutation is relevant and authorized. Static checks should not start services, modify live containers or read secret values.

## Working style

Before editing:

1. Inspect the current files.
2. Identify the relevant docs or ADRs.
3. State the intended outcome.
4. Confirm how the change aligns to the principles.
5. Prefer existing tooling over new custom code.

When responding after work:

- summarize changed files
- state validation commands run
- state results
- call out deferred work
- call out any increase in custom code
- call out any architecture concern
- do not hide uncertainty

Do not make broad refactors while completing a narrow issue.

Do not add unrelated improvements.

Do not introduce new dependencies without checking `docs/09-tool-selection.md` and using the tool evaluation template when appropriate.

Do not commit, push, close issues or change GitHub metadata unless the operator explicitly requests it. Before editing in a dirty worktree, inspect `git status --short` and preserve all unrelated changes.

## Strong guardrail

If the work starts turning into building a private platform, stop and reassess.

The project mantra is:

```text
Build the way of working, not just the tool.
Keep the interface stable.
Keep the components replaceable.
Keep the environment rebuildable.
Use local models first.
Escalate when justified.
Document everything.
```

Daily usefulness is more important than novelty.

## Repository Guidelines

### Project Structure & Module Organization

`bin/ai` is the thin user-facing habit layer. Its shell modules live in `tools/ai/`; reusable `just` orchestration is split by capability under `tools/just/`. Routing and evaluation utilities live under `tools/routing/` and `tools/evals/`. Declarative gateway, routing, policy, provider, model and OpenCode settings belong in `config/`. LibreChat deployment belongs in `containers/librechat/`, while pinned host-tool manifests belong in `packages/<profile>/`. Machine-specific policy lives in `profiles/<profile>/profile.yaml`; never duplicate profile policy in scripts. Architecture, ADRs, proofs and workflows live in `docs/`. Reusable context belongs in `contexts/`. Treat `tmp/` as generated output and `archive/` as historical reference.

### Build, Test, and Development Commands

Run `just` to list available recipes. Common checks and workflows are:

- `just check-yaml` — parse all YAML under `config/` and `profiles/`.
- `just workstation-up` / `just workstation-down` — start or stop the complete repo-managed workstation stack.
- `just workstation-status` — report Podman, runtimes, LiteLLM and LibreChat readiness.
- `just ai-check` — validate core configuration, gateway models and health.
- `just ui-check` — validate committed LibreChat policy and its live gateway path.
- `just opencode-config-check` — validate pinned OpenCode configuration without requiring a live model call.
- `just opencode-check` — validate the installed OpenCode version and gateway-only model selection.
- `just eval-model-fitness` — run Promptfoo evaluation through LiteLLM.
- `just eval-model-fitness-mlx` — run direct MLX/oMLX fitness evaluation.
- `AI_LAB_PROFILE=macos-work bin/ai status` — exercise the CLI for a profile.

Python commands expect `.venv/bin/python`; workstation workflows require `just`, Podman, `curl` and `jq`. Runtime checks also require the profile-selected local runtimes.

### Coding Style & Naming Conventions

Use four spaces in Python, `snake_case` identifiers, type hints where they clarify interfaces, and `pathlib.Path` for repository paths. Bash scripts must begin with `#!/usr/bin/env bash` and use `set -euo pipefail`; quote expansions and prefer lowercase function names. Use two-space indentation in YAML and kebab-case for recipe, command, and directory names (`gateway-health`, `macos-work`). Keep scripts thin and policy in configuration. Do not hard-code credentials or provider secrets.

### Testing Guidelines

The current test strategy emphasizes static policy checks, behaviour checks and smoke tests rather than a general unit-test framework. Before submitting, run `just --fmt --check`, `just check-yaml` and the smallest relevant recipe or CLI command. Gateway changes should pass `just ai-check`; UI changes should pass `just ui-check`; OpenCode changes should pass `just opencode-config-check` and, when runtime validation is relevant, `just opencode-check`. Model changes should run the relevant fitness evaluation. Use only synthetic prompts and data—never customer, work, personal or secret material. Add future behavioural tests under `tests/` and give stable routing cases identifiers such as `route-001`.

### Commit & Pull Request Guidelines

Recent history uses short, imperative subjects such as `Add AI history command` and `Improve AI prompt input handling`. Keep each commit focused and avoid mixing generated `tmp/` output with implementation unless it is intentional evidence. Pull requests should explain the user-visible behavior, affected profiles/configuration, validation commands run, and any architecture or security implications. Link relevant issues or ADRs; include terminal output or screenshots when CLI/UI behavior changes.
