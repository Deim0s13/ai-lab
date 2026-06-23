# Profiles

Profiles define how AI Dev Workstation as Code behaves on different devices.

The same repository should support multiple machines, but each machine has a different purpose, runtime, privacy posture and workflow emphasis.

Profiles allow the workstation to stay consistent while avoiding a one-size-fits-all setup.

---

## 1. Purpose

Profiles define:

- device purpose
- local runtimes
- frontier providers
- enabled capabilities
- disabled capabilities
- default routes
- privacy rules
- escalation behaviour
- work or personal context boundaries

The goal is to use the same architecture across machines without forcing every machine to behave the same way.

---

## 2. Initial profiles

The initial profiles are:

```text
macos-work
windows-personal
fedora-atomic
```

Each profile should be treated as a declared machine intent.

---

## 3. Profile: macos-work

### Purpose

The `macos-work` profile is for the MacBook Pro work laptop.

It is intended to support:

- architecture workflows
- writing and summarisation
- customer preparation
- work-safe local AI usage
- local-first coding assistance
- controlled frontier escalation

This profile should be more conservative than the personal profile because it may interact with work-related context.

---

### Expected runtimes

Preferred local runtime:

```text
oMLX / MLX-compatible runtime
```

Fallback local runtime:

```text
Ollama
```

The MacBook Pro should be able to use both where practical:

- oMLX or MLX-based tooling for Mac-native local inference
- Ollama as a compatibility fallback where models or tools require it

---

### Expected providers

Local providers:

```text
oMLX / MLX-compatible runtime
Ollama
```

Frontier providers:

```text
Anthropic
OpenAI
Gemini, if useful later
```

---

### Enabled capabilities

Initial enabled capabilities:

```text
ask-ai
ai-status
ai-route
ai-model-review
gateway
model-fitness
architecture-assistant
writing-assistant
research-assistant
open-webui
```

Future enabled capabilities:

```text
controlled-agents
rag-project-memory
cli-coding-assistant
```

---

### Disabled or restricted capabilities

The following should be restricted by default:

```text
personal-project-memory
experimental-agents
uncontrolled-file-editing-agents
automatic-frontier-routing-for-work-context
```

---

### Privacy posture

The default privacy posture is conservative.

Rules:

- local-first by default
- confirm before frontier escalation
- do not send sensitive work context to frontier models unless explicitly approved
- keep work context separate from personal context
- avoid storing work-sensitive material in shared memory stores
- prefer summary or redacted context when escalation is required

---

### Example profile intent

```yaml
profile: macos-work
purpose: work-ai-workstation

runtimes:
  primary_local: omlx
  fallback_local: ollama

providers:
  local:
    - omlx
    - ollama
  frontier:
    - anthropic
    - openai
    - gemini

enabled_capabilities:
  - ask-ai
  - ai-status
  - ai-route
  - ai-model-review
  - gateway
  - open-webui
  - architecture-assistant
  - writing-assistant
  - research-assistant

disabled_capabilities:
  - personal-project-memory
  - experimental-agents

privacy:
  default_route: local
  require_confirmation_for_frontier: true
  allow_work_context_to_frontier: false
```

---

## 4. Profile: windows-personal

### Purpose

The `windows-personal` profile is for the Windows personal AI development laptop.

It is intended to support:

- personal development
- vibe coding
- local model experimentation
- routing experiments
- Open WebUI usage
- model testing
- future agent experimentation

This profile can be more experimental than the work profile.

---

### Expected runtimes

Preferred local runtime:

```text
Ollama
```

Expected environment:

```text
Windows
WSL2
local GPU where available
container runtime
```

---

### Expected providers

Local providers:

```text
Ollama
```

Frontier providers:

```text
Anthropic
OpenAI
Gemini
```

---

### Enabled capabilities

Initial enabled capabilities:

```text
ask-ai
ai-status
ai-route
ai-model-review
gateway
model-fitness
open-webui
cli-coding-assistant
```

Future enabled capabilities:

```text
controlled-agents
rag-project-memory
personal-project-memory
research-assistant
```

---

### Privacy posture

The default privacy posture is still local-first, but this profile may allow more experimentation.

Rules:

- local-first by default
- allow more flexible frontier escalation
- confirm before sending sensitive or private content to frontier providers
- allow personal project memory when explicitly enabled
- allow experimental agents only when deliberately activated

---

### Example profile intent

```yaml
profile: windows-personal
purpose: personal-ai-dev-lab

runtimes:
  primary_local: ollama

providers:
  local:
    - ollama
  frontier:
    - anthropic
    - openai
    - gemini

enabled_capabilities:
  - ask-ai
  - ai-status
  - ai-route
  - ai-model-review
  - gateway
  - open-webui
  - cli-coding-assistant
  - model-fitness

disabled_capabilities:
  - work-context
  - uncontrolled-agents

privacy:
  default_route: local
  require_confirmation_for_frontier: true
  allow_personal_context_to_frontier: ask
```

---

## 5. Profile: fedora-atomic

### Purpose

The `fedora-atomic` profile is a future target profile for atomic or ephemeral Linux workstation patterns.

It is intended to test whether the workstation can run in a rebuildable, thin-host model.

Potential targets:

```text
Fedora Silverblue
Fedora Atomic Desktop
other immutable or atomic desktop environments
```

---

### Expected design pattern

The profile should favour:

- minimal host mutation
- Podman-first services
- toolbox or distrobox for mutable development environments
- Flatpak for GUI applications where appropriate
- user-space package managers where appropriate
- systemd user services
- repeatable bootstrap
- no undocumented manual setup

---

### Expected runtimes

Possible local runtime:

```text
Ollama or equivalent local runtime
```

Expected services:

```text
LiteLLM or equivalent gateway
Open WebUI
future memory or vector services
```

---

### Enabled capabilities

Initial enabled capabilities:

```text
gateway
open-webui
ask-ai
ai-status
ai-bootstrap-check
model-fitness
```

Future enabled capabilities:

```text
cli-coding-assistant
controlled-agents
rag-project-memory
```

---

### Privacy posture

Rules:

- local-first by default
- same privacy model as selected use case
- avoid machine-specific state
- keep secrets externalised
- keep all configuration in the repository where safe

---

### Example profile intent

```yaml
profile: fedora-atomic
purpose: rebuildable-atomic-ai-workstation

runtimes:
  primary_local: ollama

providers:
  local:
    - ollama
  frontier:
    - anthropic
    - openai
    - gemini

enabled_capabilities:
  - ask-ai
  - ai-status
  - ai-route
  - ai-bootstrap-check
  - gateway
  - open-webui
  - model-fitness

host_strategy:
  thin_host: true
  prefer_containers: true
  prefer_user_services: true
  avoid_manual_state: true

privacy:
  default_route: local
  require_confirmation_for_frontier: true
```

---

## 6. Profile configuration files

Profiles should eventually be represented in code.

Suggested location:

```text
profiles/
├── macos-work/
│   └── profile.yaml
├── windows-personal/
│   └── profile.yaml
└── fedora-atomic/
    └── profile.yaml
```

A profile file should be readable by bootstrap scripts, validation scripts and CLI tools.

---

## 7. Profile selection

Bootstrap commands should require or detect a profile.

Example:

```bash
./bootstrap/bootstrap.sh --profile macos-work
```

or:

```powershell
.\bootstrap\bootstrap-windows.ps1 -Profile windows-personal
```

Profile selection should determine:

- package set
- runtime setup
- enabled tools
- container services
- default model routes
- privacy settings
- validation checks

---

## 8. Profile boundaries

Profiles should prevent accidental mixing of work and personal usage.

Examples:

- work context should not be loaded in the personal profile
- personal project memory should not be active by default on the work profile
- experimental agents should not be enabled by default on the work profile
- frontier escalation should be more restrictive on the work profile

This is important for safety, clarity and long-term trust in the workstation.

---

## 9. Summary

Profiles allow the same AI workstation architecture to support different devices and use cases.

The principle is:

```text
Same architecture.
Different intent.
Profile-driven behaviour.
```
