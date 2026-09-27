# Security and Control Posture

## Purpose

This document defines the practical security posture for AI Dev Workstation as Code.

The objective is to reduce credible harm to files, secrets, context, services and external accounts without making normal supervised workflows unusable. Controls should become stronger as data sensitivity, tool capability or the consequence of an error increases.

This is a personal workstation security model, not an enterprise compliance framework. It does not promise zero risk.

## Operating principles

- Use the least restrictive control that meaningfully limits the likely harm.
- Treat model output, repository instructions and generated commands as untrusted until reviewed.
- Keep actions visible, deliberate and recoverable.
- Prefer scoped credentials, selected context and local-only services.
- Distinguish application permissions from operating-system containment.
- Default-deny new autonomy, integrations and external access; enable them only after a bounded proof.
- Redesign repetitive, low-value prompts instead of training the operator to approve them automatically.
- Use existing tool controls before adding custom security machinery.

## Protected assets

| Asset | Protection objective |
| --- | --- |
| Tracked and untracked work | Prevent unnoticed loss, overwrite or unrelated modification. |
| Secrets and credentials | Keep values out of Git, prompts, logs and unnecessary processes. |
| Work and personal context | Prevent unintended profile crossover or provider disclosure. |
| Gateway and local services | Restrict access to the intended local clients and interfaces. |
| Persistent application data | Preserve LibreChat conversations, configuration and other durable state. |
| External accounts and repositories | Require explicit operator intent before remote or irreversible actions. |
| Host availability and integrity | Bound runaway work and avoid unnecessary elevated access. |

## Trust boundaries

The operator is the final decision-maker, but an approval can still be mistaken. Approval prompts reduce accidental action; they are not a sandbox.

Model responses and repository content may be incorrect, malicious or affected by prompt injection. They must not silently expand permissions.

OpenCode and other frontends enforce useful application-level permissions. Unless separately isolated, their processes still run with the permissions of the logged-in user.

LiteLLM is the normal model-access boundary. Local runtimes and approved frontier providers sit behind or alongside that boundary according to profile policy.

Podman isolates containerised services from the host to a degree, but it does not sandbox host-native coding tools. Published ports, mounted directories, credentials and control sockets still define the effective boundary.

Bitwarden is the preferred secret source. A process receiving a secret must still be treated as trusted for that secret's scope and lifetime.

## Credible failure cases

The workstation should actively reduce:

- accidental or model-driven file deletion and destructive edits;
- approval requests that disguise a broader command or effect;
- prompt injection from source files, documentation or retrieved context;
- secret disclosure through prompts, command output, logs or committed files;
- work and personal context crossing profile boundaries;
- local services listening beyond the intended host interface;
- unintended GitHub, provider or other external-service actions;
- compromised, unexpected or incompatible component updates;
- runaway retries, loops, tool calls or resource use;
- false claims that work, tests or validation completed successfully.

## Control levels

The control level depends on both the sensitivity of the information and the consequence of the available actions.

| Level | Typical use | Required boundary | Normal friction |
| --- | --- | --- | --- |
| 1. Advisory | Chat, explanation, review and planning | No approved file changes or command execution | Minimal |
| 2. Supervised editing | Daily repository work in OpenCode | Explicit repository, approvals and independent review | Low and purposeful |
| 3. Isolated execution | Unattended, destructive, untrusted or materially higher-risk work | Disposable workspace plus process, credential, network and lifecycle controls | Higher by design |

### Level 1 — Advisory

Use for prompt-response tools, LibreChat, `ai` commands and OpenCode planning where no file or command changes are approved.

Required controls:

- select only the context needed for the task;
- follow the active profile's context and provider policy;
- keep secrets out of prompts and outputs;
- use the gateway or an explicitly approved workspace;
- verify important advice before acting on it.

An operating-system sandbox is not required merely because content is sensitive. A read-only workflow may use sensitive content only when the selected runtime, provider, account and profile are approved for that content.

### Level 2 — Supervised editing

This is the normal OpenCode coding posture.

Required controls:

- launch against an explicitly selected repository;
- require approval for edits and commands;
- deny secrets, external directories, subagents, MCP, web tools and remote Git operations by default;
- inspect commands before approval and review the resulting diff;
- preserve unrelated changes and independently run relevant validation;
- keep Git history or another proven recovery path available;
- stop the session when behaviour, scope or retry activity becomes unclear.

OpenCode permissions are guardrails, not containment. Once an action is approved, the process may exercise the logged-in user's access. Valuable, unfamiliar or poorly recoverable repositories should use a disposable worktree or the stronger isolated level.

### Level 3 — Isolated execution

Use before unattended execution and whenever the likely consequence exceeds what operator review and ordinary recovery can reasonably contain.

Required controls:

- use a disposable clone, worktree or equivalent workspace;
- keep the primary checkout read-only or unavailable;
- isolate the process using an evaluated existing container, virtual machine or operating-system mechanism;
- provide only scoped, short-lived credentials required for the task;
- restrict tools, writable paths and network destinations;
- exclude the home directory, SSH agent, container-engine socket and unrelated secrets;
- define time, tool-call, retry and resource limits plus a reliable cancellation path;
- retain observable action and validation evidence without recording sensitive content;
- require operator review before promoting changes or enabling external effects.

Level 3 is a prerequisite for future unattended agents. It is not automatically required for every supervised edit.

## Escalation triggers

Move to a stronger control level when a workflow introduces any of the following:

- unattended, scheduled or background execution;
- broad or recursive modification across a repository;
- destructive commands or difficult recovery;
- execution of instructions from an untrusted repository or retrieved source;
- access beyond the selected project directory;
- credentials, restricted context or external-service mutation;
- network access beyond the selected gateway or approved provider;
- elevated privileges, host control sockets or persistent processes;
- repeated tool use, retries or uncertain stopping behaviour.

If the stronger level is unavailable, reduce the task scope, perform the sensitive step manually or defer the work. Do not silently treat an approval prompt as equivalent isolation.

## Profile posture

`macos-work` remains conservative. Advisory and supervised workflows may be used when their context, route and tool are approved. Unattended agents and broad work-context access remain disabled.

`windows-personal` may trial more experimental workflows, but Level 3 controls are still required before unattended execution. A personal profile is not permission for unrestricted access.

`fedora-atomic` remains a future reference profile and may later provide a useful stronger-isolation pattern.

## Accepted residual risk

The project consciously accepts that:

- the operator can approve an unsafe request or manually bypass a control;
- application permission rules cannot cover every indirect destructive effect;
- Level 2 tools currently run with the logged-in user's operating-system permissions;
- local administrators and an already-compromised host are outside this model;
- a model can produce misleading advice or completion claims;
- not every low-risk prompt will run in a disposable sandbox;
- no enterprise DLP, SIEM or compliance platform is planned without a demonstrated need.

These risks are accepted to preserve a useful workstation. They must not be used to justify unattended execution, broad secrets access or invisible external actions.

## Implementation map

- Issue #71 restricts and validates local network exposure.
- Issue #64 introduces Bitwarden-backed scoped gateway credentials.
- Issue #72 evaluates and implements practical OpenCode containment.
- Issue #65 establishes controlled component updates and rollback.
- Issue #73 creates the security regression baseline and recovery drill.
- Issue #63 must inherit Level 3 requirements before controlled agents are adopted.

## Review triggers

Review this posture when unattended agents, remote gateway access, private RAG, broad work context, new external integrations or a materially different coding frontend is introduced. Also review it after a security incident or when a control repeatedly obstructs legitimate daily work.

