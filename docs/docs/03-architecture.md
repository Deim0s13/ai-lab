# Architecture

This document describes the target architecture for AI Dev Workstation as Code.

The architecture is designed to be:

- gateway-first
- CLI-native
- open-source-first
- local-first
- frontier-capable
- composable
- replaceable
- rebuildable
- profile-driven
- observable

The workstation should not be built around a single model, provider, tool or runtime. It should be built around stable workflows, replaceable capabilities and reusable configuration.

---

## 1. Architectural intent

The intent is to create a durable AI workstation foundation that can evolve over time.

The workstation should support multiple devices, multiple model providers and multiple interfaces without becoming a collection of disconnected tools.

The key architectural decision is:

```text
Do not build around tools.
Build around capabilities, contracts, profiles and replaceable adapters.
```

This allows the system to change as the AI tooling landscape changes.

---

## 2. High-level architecture

```text
CLI / IDE / Open WebUI / Agents
        ↓
Stable workstation commands
        ↓
Capability contracts
        ↓
Gateway and routing layer
        ↓
Provider adapters
        ↓
Local runtimes / Frontier providers
        ↓
Observability, model fitness and lifecycle review
```

The user should interact with stable commands and workflows.

The tools, models and providers underneath can change.

---

## 3. Logical architecture

```text
AI Dev Workstation as Code
├── Interface layer
│   ├── CLI
│   ├── IDE
│   ├── Open WebUI
│   └── future agents
│
├── Command layer
│   ├── ask-ai
│   ├── ai-route
│   ├── ai-status
│   ├── ai-model-review
│   ├── dev-ai
│   ├── architect-ai
│   ├── write-ai
│   └── research-ai
│
├── Gateway layer
│   ├── LiteLLM or equivalent
│   ├── model aliases
│   ├── routing policies
│   ├── provider abstraction
│   ├── fallback rules
│   └── escalation rules
│
├── Provider layer
│   ├── Ollama
│   ├── oMLX / MLX-compatible runtime
│   ├── Anthropic
│   ├── OpenAI
│   ├── Gemini
│   └── future providers
│
├── Capability layer
│   ├── coding assistant
│   ├── architecture assistant
│   ├── writing assistant
│   ├── research assistant
│   ├── chat UI
│   ├── model fitness
│   ├── RAG / memory
│   └── agent runner
│
├── Configuration layer
│   ├── profiles
│   ├── providers
│   ├── models
│   ├── routes
│   ├── policies
│   └── capabilities
│
└── Rebuild layer
    ├── bootstrap scripts
    ├── package declarations
    ├── container definitions
    ├── service definitions
    ├── validation checks
    └── documentation
```

---

## 4. Interface layer

The interface layer defines how the user interacts with the workstation.

Primary interface:

- CLI

Supporting interfaces:

- IDE
- Open WebUI
- future agent interfaces

The CLI is the primary interface because it supports the preferred working style and is easier to make consistent across devices.

The UI and IDE should not become separate environments. They should sit on top of the same gateway, routing and configuration model.

---

## 5. Command layer

The command layer provides stable user-facing workflows.

Initial commands:

```text
ask-ai
ai-route
ai-status
ai-model-review
```

Future commands:

```text
dev-ai
architect-ai
write-ai
research-ai
agent-ai
```

These commands should remain stable even if the tools underneath change.

For example:

```bash
architect-ai review platform-decision.md
```

should not be hard-coded to a specific provider or model. It should call the routing layer and use the best available implementation for that profile and task.

---

## 6. Gateway layer

The gateway layer is the control plane of the workstation.

Its role is to provide:

- provider abstraction
- model aliases
- local model routing
- frontier model escalation
- fallback behaviour
- consistent API access
- future cost controls
- future policy enforcement

The starting candidate for the gateway is LiteLLM or an equivalent open-source gateway.

The gateway should make it possible for CLI tools, Open WebUI, IDE tools and future agents to access models through a common interface.

---

## 7. Provider layer

The provider layer contains the actual model backends.

Initial provider candidates:

```text
Ollama
oMLX / MLX-compatible runtime
Anthropic
OpenAI
Gemini
```

Provider responsibilities:

- expose models to the gateway
- support task-specific model selection
- allow local and frontier routing
- be replaceable where possible

The provider layer should not leak into the user’s day-to-day workflow. Users should not need to remember which model or runtime is best for every task.

---

## 8. Capability layer

The capability layer defines what the workstation can do.

Capabilities are not tools. Tools are implementations of capabilities.

Initial capabilities:

- model gateway
- local runtime
- CLI coding assistant
- chat UI
- model fitness
- architecture assistant
- writing assistant
- research assistant
- agent runner
- RAG / memory

Each capability should have a contract describing:

- what it must do
- what tool currently implements it
- how it can be replaced
- what status it has

This keeps the architecture flexible.

---

## 9. Configuration layer

The configuration layer is the source of behaviour.

Configuration should define:

- profiles
- providers
- model aliases
- routing rules
- privacy rules
- enabled capabilities
- disabled capabilities
- fallback behaviour
- escalation rules

The workstation should prefer configuration over hard-coded behaviour.

Changing a model, provider or default route should usually require a config change, not a code change.

---

## 10. Rebuild layer

The rebuild layer makes the workstation reproducible.

It should include:

- bootstrap scripts
- package declarations
- container definitions
- service definitions
- validation checks
- documentation

The aim is for a new or rebuilt device to be able to clone the repository, apply a profile, install required tools, start services and validate the environment.

The machine should be disposable. The repo should be the source of truth.

---

## 11. Profile-driven design

Profiles define how the workstation behaves on each device.

Initial profiles:

```text
macos-work
windows-personal
fedora-atomic
```

Each profile should define:

- purpose
- local runtimes
- frontier providers
- enabled capabilities
- disabled capabilities
- privacy rules
- default routes
- escalation policy

Profiles allow the same architecture to support different use cases without mixing concerns.

---

## 12. Local-first, frontier-capable routing

Local models should be the default route where appropriate.

Frontier providers should be used when justified by:

- complexity
- reasoning requirements
- customer-facing quality
- local model failure
- coding difficulty
- user request
- policy

Routing should be observable.

Where practical, the system should be able to explain:

- task type
- selected route
- provider
- model
- whether it stayed local
- whether escalation occurred
- why the route was selected

---

## 13. Rebuildable workstation pattern

The workstation should follow a thin-host pattern.

Recommended pattern:

```text
Host OS
= thin, stable, minimal

Containers
= services such as gateway, Open WebUI and future memory services

User-space tools
= CLI tools, wrappers, model utilities and developer tools

Configuration repo
= source of truth

Secrets
= externalised and never committed

Models
= reproducible model list, not stored in git
```

This is suitable for macOS, Windows/WSL2 and future Fedora Silverblue or atomic Linux environments.

---

## 14. Tool replacement model

Tools should be replaceable.

For example:

```text
CLI coding assistant
Current candidate: Aider
Alternative candidate: OpenCode
Future replacement: any tool satisfying the same capability contract
```

The architecture should not care which tool is preferred, as long as the capability contract is met.

This means the system should use stable command names, model aliases and configuration-driven routing wherever possible.

---

## 15. Target repository structure

```text
ai-lab/
├── README.md
├── bootstrap/
├── profiles/
├── packages/
├── containers/
├── config/
├── contexts/
├── dotfiles/
├── tools/
├── systemd/
├── docs/
├── tests/
├── labs/
└── archive/
```

The repository should contain both the documentation and the rebuildable implementation.

---

## 16. Architecture summary

The architecture should make it easy to:

- add a new provider
- replace a local runtime
- trial a new coding tool
- add a new profile
- update routing policy
- rebuild a machine
- validate the setup
- introduce agents later
- keep daily workflows stable

The key architectural stance is:

```text
Stable way of working.
Replaceable implementation.
Rebuildable environment.
```
