# `contexts/README.md`

# contexts

This directory contains context material used by **AI Dev Workstation as Code**.

Context may include shared instructions, profile-specific guidance, persona prompts, project notes and future RAG/project-memory inputs.

Because context can influence model behaviour, this directory needs clear boundaries.

---

## Purpose

The purpose of this directory is to support profile-aware workflows such as:

- architecture assistance
- writing assistance
- research assistance
- coding assistance
- future controlled agents
- future RAG/project memory

Context should make the workstation more useful without mixing work and personal material accidentally.

---

## Context categories

Initial context categories are:

| Context | Purpose |
|---|---|
| `shared` | Non-sensitive reusable context safe for both work and personal profiles. |
| `work` | Work-related context, work personas and work-safe guidance. |
| `work-sensitive` | Work context that must never be available to personal workflows. |
| `personal` | Personal projects, preferences and experiments. |
| `project` | Context specific to this repo and the AI workstation project. |

Possible structure:

```text
contexts/
├── shared/
├── work/
├── work-sensitive/
├── personal/
└── project/
```

Directories can be added when they are actually needed.

---

## Profile access rules

Context access must be profile-aware.

| Profile | Allowed context | Blocked context |
|---|---|---|
| `macos-work` | `work`, `work-sensitive`, `shared`, selected `project` | `personal` |
| `windows-personal` | `personal`, `shared`, selected `project` | `work`, `work-sensitive` |
| `fedora-atomic` | `shared`, selected `project` | `work-sensitive` until explicitly enabled |

The rule is:

```text
A profile can only load context that it is explicitly allowed to use.
```

---

## Work-safe context

The `macos-work` profile may use work context, but it should remain conservative.

Work-safe context rules:

- approved work AI tools should be prioritised first
- restricted material should not be routed externally
- customer or internal material should use explicit sensitivity flags
- agents should not load work context by default
- work context should not be available to `windows-personal`

If there is any doubt, use synthetic or redacted context.

---

## Personal context

The `windows-personal` profile may use personal and project context.

It must not load work or work-sensitive context by default.

This matters because the personal profile may be used for:

- OpenAI and Anthropic experimentation
- coding assistants
- agent trials
- RAG experiments
- local model testing

Those workflows should not accidentally include work material.

---

## Context loading behaviour

Commands that load context should check the active profile before loading files.

Example allowed usage:

```bash
architect-ai --profile macos-work --context work/architecture-style.md
write-ai --profile windows-personal --context personal/writing-style.md
```

Example blocked usage:

```bash
research-ai --profile windows-personal --context work/customer-notes.md
```

Expected failure:

```text
Context blocked
Profile: windows-personal
Requested context: work/customer-notes.md
Reason: work context is not available to windows-personal profile
```

---

## RAG and project memory

Future RAG or project-memory workflows must respect these same boundaries.

If indexes are created later, work and personal indexes must be separate.

Possible future structure:

```text
contexts/
├── indexes/
│   ├── work/
│   ├── personal/
│   └── project/
```

No broad indexing of work or personal files should happen by default.

---

## Safety rules

Context files must not contain:

- API keys
- secrets
- credentials
- private tokens
- unredacted customer information unless explicitly intended and policy-safe
- internal work material that should not be committed
- personal sensitive information

This repo may be public, so context files must be safe to commit unless explicitly ignored.

---

## Relationship to ADRs

Relevant ADR:

```text
docs/adr/0012-work-personal-context-boundaries.md
```

Context boundaries should also align with:

```text
docs/06-profiles.md
docs/07-routing-strategy.md
docs/11-cli-interface-contracts.md
```

---

## Summary

The context rule is:

```text
Useful context.
Explicit boundaries.
Profile-aware loading.
No accidental work/personal mixing.
```
