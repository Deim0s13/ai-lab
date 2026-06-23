# Tool Selection

This document defines how tools, runtimes, providers and frameworks are selected for AI Dev Workstation as Code.

The project is open-source-first, but not open-source-only. The workstation should adopt active open-source tools where they make sense, while still allowing frontier providers such as Anthropic, OpenAI and Gemini where justified.

The goal is to avoid unnecessary custom development and avoid tool sprawl.

---

## 1. Purpose

The AI tooling space changes quickly.

New tools will appear. Existing tools will change direction. Some projects will become less active. Some tools will be useful for a short time and then be replaced.

This document helps decide:

- whether a tool should be considered
- whether it should be trialled
- whether it should become part of the standard workstation
- whether it should be replaced
- whether custom code is justified

---

## 2. Selection principles

Tool selection should follow the project principles:

- open-source-first
- CLI-native
- gateway-first
- rebuildable
- composable
- replaceable
- local-first
- frontier-capable
- profile-aware
- observable

A tool should support the architecture rather than force the architecture to bend around the tool.

---

## 3. Adopt before build

Before building a custom script, wrapper or service, check whether an active open-source project already satisfies the need.

The decision flow is:

```text
1. Does an active open-source tool already do this?
2. Does it support CLI usage where relevant?
3. Does it support local models?
4. Does it support frontier models or gateway access?
5. Does it work across the target profiles?
6. Can it be installed reproducibly?
7. Can it be configured rather than manually tuned?
8. Can it be replaced cleanly later?
9. If no suitable tool exists, build the smallest useful custom layer.
```

Custom code should normally be limited to:

- thin wrappers
- profile loading
- configuration glue
- validation checks
- route explanation
- documentation helpers

---

## 4. Selection checklist

When considering a tool, assess it against this checklist.

### Capability fit

- What capability does this tool satisfy?
- Is the capability already covered?
- Is this a replacement, complement or experiment?
- Does this tool overlap with something already adopted?

### Architecture fit

- Does it support gateway-first usage?
- Does it support OpenAI-compatible APIs or equivalent integration?
- Does it work with local and frontier providers?
- Can it be used without hard-coding provider decisions?
- Can it be configured cleanly?

### CLI fit

- Does it support CLI usage?
- Is the CLI experience natural enough to become a habit?
- Can common workflows be run from the terminal?
- Can output be saved, redirected or scripted?

### Rebuild fit

- Can it be installed from code?
- Does it support Homebrew, winget, pipx, uv, containers or another reproducible method?
- Can it be configured from files?
- Can it be validated after install?
- Can it be removed cleanly?

### Profile fit

- Does it make sense for `macos-work`?
- Does it make sense for `windows-personal`?
- Does it make sense for `fedora-atomic`?
- Does it respect work/personal separation?
- Can it be disabled per profile?

### Maintenance fit

- Is the project actively maintained?
- Is there recent release activity?
- Is the documentation usable?
- Is the community or issue activity healthy?
- Are there signs of abandonment or major direction change?

### Safety and privacy fit

- Does it make it clear where data goes?
- Can it be restricted to local models?
- Can frontier escalation be controlled?
- Does it store data locally?
- Does it support profile-aware privacy boundaries?

---

## 5. Tool status

Tools should be tracked using the component lifecycle.

```text
Candidate → Trial → Adopted → Preferred → Deprecated → Removed
```

Tool selection decides whether a tool should be considered.

Component lifecycle tracks where that tool sits after consideration.

See:

```text
docs/05-component-lifecycle.md
```

---

## 6. Initial tool candidates

The following are initial candidates based on the current workstation direction.

These are not permanent choices.

---

## 6.1 Model gateway

### Capability

Model Gateway

### Candidate

LiteLLM

### Why it is being considered

LiteLLM is being considered because it can act as a common gateway across local and frontier model providers.

It supports the gateway-first architecture by allowing CLI tools, Open WebUI, IDE integrations and future agents to call a common model access layer.

### Selection questions

- Can it route to local providers reliably?
- Can it route to Anthropic, OpenAI and Gemini?
- Can it be configured cleanly?
- Can it run as a local service?
- Can Open WebUI and CLI tools use it as a common endpoint?
- Does it support the level of routing required for the first milestones?

### Initial status

Candidate / Trial

---

## 6.2 Local runtime — Windows

### Capability

Local Runtime

### Candidate

Ollama

### Why it is being considered

Ollama is already part of the existing AI lab direction and is a strong fit for local model experimentation, especially on the Windows personal development machine.

### Selection questions

- Does it perform well on the Windows device?
- Does it work cleanly with WSL2 or the Windows host setup?
- Can the gateway call it reliably?
- Can required models be installed reproducibly?
- Can llmfit use or assess it effectively?

### Initial status

Adopted for Windows personal profile

---

## 6.3 Local runtime — macOS

### Capability

Local Runtime

### Candidates

- oMLX / MLX-compatible runtime
- Ollama fallback

### Why they are being considered

The MacBook Pro should use a Mac-native local inference path where practical, while keeping Ollama as a fallback for compatibility and broader model/tool support.

### Selection questions

- Which runtime performs best for the MBP hardware?
- Which models are available through each runtime?
- Can the gateway call the runtime cleanly?
- Does it work with CLI tools?
- Does it support the work profile’s privacy posture?
- Is the setup reproducible?

### Initial status

oMLX / MLX-compatible runtime: Candidate  
Ollama on macOS: Candidate fallback

---

## 6.4 Chat UI

### Capability

Chat UI

### Candidate

Open WebUI

### Why it is being considered

Open WebUI provides a self-hosted chat interface and can support local model usage and OpenAI-compatible endpoints.

It should sit on top of the same gateway as CLI tools, rather than becoming a separate AI environment.

### Selection questions

- Can it connect cleanly to the gateway?
- Can it access local and frontier routes through that gateway?
- Can it be containerised?
- Can it be configured reproducibly?
- Does it create any separate state that needs to be backed up or managed?
- Does it support the intended profile separation?

### Initial status

Candidate / Trial

---

## 6.5 CLI coding assistant

### Capability

CLI Coding Assistant

### Candidates

- Aider
- OpenCode

### Why they are being considered

The workstation should support terminal-native coding and vibe coding workflows.

Aider is a strong candidate because it is mature and terminal-first.

OpenCode is a candidate because it is positioned around open-source coding agent workflows across terminal and editor experiences.

### Selection questions

- Which tool best matches the preferred CLI workflow?
- Which works best with local models?
- Which works best through the gateway?
- Which handles file edits safely and clearly?
- Which supports frontier escalation?
- Which is easiest to install and rebuild?
- Which is less likely to create lock-in?

### Initial status

Candidate

---

## 6.6 Agent runner

### Capability

Agent Runner

### Candidate

Goose

### Why it is being considered

Goose is being considered for future constrained agent workflows across coding, research, writing and architecture support.

It is not part of the first foundation milestone.

### Selection questions

- Does it support CLI workflows?
- Does it support provider flexibility?
- Does it support local and frontier models?
- Does it support tool use safely?
- Can workflows be constrained?
- Can it be installed and configured reproducibly?
- Does it fit the profile model?

### Initial status

Candidate for later milestone

---

## 6.7 Model fitness

### Capability

Model Fitness

### Candidate

llmfit

### Why it is being considered

llmfit supports the model fitness loop by helping assess which models are appropriate for a device and task.

It is important because model choices should be based on fit, not hype.

### Selection questions

- Can it assess models relevant to the user’s devices?
- Does it support the local runtimes being used?
- Is the output useful for model routing decisions?
- Can results be captured and compared over time?
- Can it become part of a regular model review rhythm?

### Initial status

Candidate / Planned

---

## 7. When to build custom

Custom code is justified when:

- no suitable open-source tool exists
- an existing tool is too heavy for the need
- only a small wrapper is required
- profile-aware behaviour is needed
- routing explanation is needed
- validation is needed
- glue between tools is needed

Custom code should avoid becoming a full platform unless there is a clear reason.

Examples of acceptable custom code:

```text
ask-ai
ai-route
ai-status
ai-model-review
ai-bootstrap-check
architect-ai
write-ai
```

These should be thin, understandable and replaceable.

---

## 8. Tool trial process

When trialling a tool, document:

- capability
- reason for trial
- install method
- target profile
- test workflow
- success criteria
- failure criteria
- rollback approach
- decision outcome

Suggested location:

```text
docs/tool-trials/
```

or as part of:

```text
config/capabilities/components.yaml
```

---

## 9. Tool replacement process

A tool can be replaced when:

- it no longer fits the architecture
- a better tool satisfies the same capability
- it is no longer maintained
- it is difficult to rebuild
- it bypasses the gateway unnecessarily
- it creates too much lock-in
- it is no longer used

Replacement should be documented in an ADR if the tool was significant.

---

## 10. Tool sprawl guardrail

The project should avoid collecting tools simply because they are interesting.

Before adding a new tool, ask:

```text
What recurring workflow will this improve?
What capability does it satisfy?
What will it replace or complement?
How will it be rebuilt?
How will it be removed?
```

If those questions are not clear, the tool should remain a note, not part of the workstation.

---

## 11. Summary

The goal is not to install every useful AI tool.

The goal is to build durable, reusable capabilities.

The guiding rule is:

```text
Adopt before build.
Trial deliberately.
Prefer explicitly.
Replace cleanly.
```
