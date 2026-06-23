# Architecture

## 1. Purpose

This document describes the target architecture for **AI Dev Workstation as Code**.

I am building this as a local-first, gateway-led AI workstation that can support development, architecture, writing, research and future agent workflows across multiple devices.

The architecture is intended to be:

- rebuildable
- modular
- profile-aware
- secure by default
- CLI-native
- local-first
- frontier-capable
- replaceable over time

This is not intended to be a production enterprise AI platform. It is a personal AI workstation architecture that borrows useful platform patterns: gateway, routing, profiles, policy, validation, component lifecycle and infrastructure-as-code style rebuildability.

---

## 2. Architecture goals

The architecture should allow me to:

- use local models by default
- route complex tasks to frontier models when justified
- keep work and personal usage separated
- use approved work AI tools first on the work profile
- use OpenAI and Anthropic more freely on the personal profile
- work primarily from the CLI
- support UI and IDE workflows without creating separate AI environments
- add and replace tools as the ecosystem changes
- rebuild the workstation from code and configuration
- validate whether the environment is healthy
- introduce agents later without redesigning the system

---

## 3. Architectural approach

The chosen approach is:

```text
Gateway-first, profile-aware, workstation-as-code.
```

This means:

- user-facing workflows should be stable
- model providers and local runtimes should be replaceable
- routing should happen through a common control point where practical
- profiles should drive behaviour by device and use case
- bootstrap and validation should make the workstation rebuildable
- custom code should be thin and focused on glue, validation and workflow consistency

---

## 4. High-level architecture

```mermaid
flowchart TD
    User[Me / Workstation User]

    CLI[CLI Commands]
    IDE[IDE / Editor]
    UI[Open WebUI or Chat UI]
    Agents[Future Agents]

    Gateway[AI Gateway / Router]
    Policy[Profiles, Policy and Routing Config]

    Local[Local Model Runtimes]
    Frontier[Frontier / Approved AI Providers]

    Ollama[Ollama]
    OMLX[oMLX / MLX Runtime]
    Gemini[Gemini / Approved Work AI]
    Cursor[Cursor / Approved Work AI]
    OpenAI[OpenAI]
    Anthropic[Anthropic]

    Validation[Validation and Health Checks]
    Fitness[llmfit / Model Fitness]
    Secrets[Bitwarden Secrets]

    User --> CLI
    User --> IDE
    User --> UI
    User --> Agents

    CLI --> Gateway
    IDE --> Gateway
    UI --> Gateway
    Agents --> Gateway

    Policy --> Gateway
    Secrets --> Gateway
    Fitness --> Policy
    Validation --> Gateway

    Gateway --> Local
    Gateway --> Frontier

    Local --> Ollama
    Local --> OMLX

    Frontier --> Gemini
    Frontier --> Cursor
    Frontier --> OpenAI
    Frontier --> Anthropic
```

The key architectural point is that the CLI, UI, IDE and future agents should not each become separate AI environments. Where practical, they should use the same gateway, profile and routing model.

---

## 5. System context

```mermaid
flowchart LR
    Me[Me]

    Repo[ai-lab Repository]
    Workstation[AI Dev Workstation]

    LocalModels[Local Models]
    ApprovedWorkTools[Approved Work AI Tools]
    FrontierProviders[Frontier Providers]
    Bitwarden[Bitwarden]
    GitHub[GitHub]

    Me --> Workstation
    Me --> Repo

    Repo --> Workstation
    Workstation --> LocalModels
    Workstation --> ApprovedWorkTools
    Workstation --> FrontierProviders
    Workstation --> Bitwarden
    Repo --> GitHub
```

The repository is the source of truth for the workstation. Local machine state should be treated as rebuildable or disposable.

---

## 6. Architecture layers

```mermaid
flowchart TD
    A[Interface Layer<br/>CLI, IDE, Open WebUI, Agents]
    B[Command Layer<br/>ask-ai, ai-route, ai-status, dev-ai, architect-ai]
    C[Gateway Layer<br/>LiteLLM or equivalent, model aliases, routing]
    D[Policy and Config Layer<br/>profiles, providers, routes, capabilities]
    E[Provider Layer<br/>Ollama, oMLX, Gemini, Cursor, OpenAI, Anthropic]
    F[Rebuild Layer<br/>bootstrap, packages, containers, validation]
    G[Governance Layer<br/>ADRs, component lifecycle, tool selection]

    A --> B
    B --> C
    C --> D
    C --> E
    D --> C
    F --> A
    F --> C
    F --> E
    G --> D
```

---

## 7. Layer responsibilities

| Layer | Responsibility |
|---|---|
| Interface layer | Provides the ways I interact with the workstation: CLI, IDE, UI and future agents. |
| Command layer | Provides stable commands and habits such as `ask-ai`, `ai-route`, `ai-status`, `dev-ai`, `architect-ai` and `write-ai`. |
| Gateway layer | Provides a common model access point, routing, aliases and provider abstraction. |
| Policy and config layer | Defines profiles, routes, providers, capabilities, model aliases and privacy rules. |
| Provider layer | Connects to local runtimes and frontier or approved AI providers. |
| Rebuild layer | Makes the workstation reproducible through bootstrap scripts, packages, containers and validation. |
| Governance layer | Captures principles, ADRs, component lifecycle and tool selection decisions. |

---

## 8. Profile architecture

Profiles define the workstation’s behaviour by device and use case.

```mermaid
flowchart TD
    Profiles[Profiles]

    Mac[macos-work]
    Win[windows-personal]
    Fedora[fedora-atomic]

    Profiles --> Mac
    Profiles --> Win
    Profiles --> Fedora

    Mac --> MacLocal[oMLX primary<br/>Ollama fallback]
    Mac --> MacFrontier[Gemini and Cursor first<br/>Anthropic/OpenAI by use case]
    Mac --> MacPolicy[Conservative work-safe policy]

    Win --> WinLocal[Ollama primary]
    Win --> WinFrontier[OpenAI and Anthropic first<br/>Gemini where useful]
    Win --> WinPolicy[More experimental personal policy]

    Fedora --> FedoraLocal[Local runtime TBD]
    Fedora --> FedoraServices[Podman-first services]
    Fedora --> FedoraPolicy[Thin-host rebuildable policy]
```

### macos-work

The `macos-work` profile is for my work laptop.

It should prioritise:

- approved work AI tools first
- local-first workflows where practical
- conservative routing
- work-safe policy
- architecture and writing workflows

Approved / first-use AI tools:

- Gemini
- Cursor

Additional providers depending on use case and approval context:

- Anthropic
- OpenAI

### windows-personal

The `windows-personal` profile is for my personal AI development lab.

It should prioritise:

- local experimentation
- vibe coding
- personal projects
- OpenAI and Anthropic as primary frontier escalation paths
- more experimental tools and agents over time

### fedora-atomic

The `fedora-atomic` profile is a future target for testing rebuildability on a more atomic or ephemeral Linux workstation model.

It should prioritise:

- thin host
- Podman-first services
- repeatable bootstrap
- minimal manual state
- user-space tools

---

## 9. Runtime and provider architecture

```mermaid
flowchart LR
    Gateway[AI Gateway / Router]

    subgraph Local["Local Runtime Providers"]
        Ollama[Ollama]
        OMLX[oMLX / MLX]
    end

    subgraph WorkApproved["Approved Work AI Tools"]
        Gemini[Gemini]
        Cursor[Cursor]
    end

    subgraph PersonalFrontier["Personal / Use-case Frontier Providers"]
        OpenAI[OpenAI]
        Anthropic[Anthropic]
    end

    Gateway --> Ollama
    Gateway --> OMLX
    Gateway --> Gemini
    Gateway --> Cursor
    Gateway --> OpenAI
    Gateway --> Anthropic
```

The gateway should hide provider-specific details from day-to-day workflows where practical.

For example, I should be able to use:

```bash
ask-ai --local "Summarise this note"
ask-ai --best "Help me reason through this design"
ai-route "Review this architecture decision"
```

without needing to remember which model is currently best for each task.

---

## 10. Routing architecture

Routing should be local-first, profile-aware and explainable.

```mermaid
flowchart TD
    Request[Task Request]

    Classify[Classify Task Type]
    Profile[Load Active Profile]
    Policy[Apply Policy and Privacy Rules]
    Fitness[Use Model Fitness / Shortlist]
    Route[Select Route]
    Confirm{Frontier confirmation required?}
    Local[Local Model]
    Frontier[Frontier / Approved Provider]
    Explain[Explain Route]

    Request --> Classify
    Classify --> Profile
    Profile --> Policy
    Policy --> Fitness
    Fitness --> Route
    Route --> Confirm

    Confirm -->|No| Local
    Confirm -->|No, frontier allowed| Frontier
    Confirm -->|Yes| Explain
    Explain --> Route
```

Initial routing does not need to be overly complex. The first implementation can be configuration-led and rule-based.

Routing should eventually consider:

- selected profile
- task type
- local runtime availability
- model fitness results
- data sensitivity
- approved tool posture
- frontier escalation rules
- user flags such as `--local`, `--best` and `--explain-route`

---

## 11. Rebuild architecture

The workstation should be recoverable from the repository.

```mermaid
flowchart TD
    Clone[Clone ai-lab Repository]
    Profile[Select Profile]
    Packages[Install Packages]
    Secrets[Resolve Secrets from Bitwarden]
    Config[Apply Config]
    Services[Start Services]
    Models[Install or Verify Models]
    Validate[Run Validation]
    Use[Use Workstation]

    Clone --> Profile
    Profile --> Packages
    Packages --> Secrets
    Secrets --> Config
    Config --> Services
    Services --> Models
    Models --> Validate
    Validate --> Use
```

The target flow is:

```bash
git clone https://github.com/Deim0s13/ai-lab.git
cd ai-lab
./bootstrap/bootstrap.sh --profile macos-work
ai-bootstrap-check
```

Manual steps should be treated as technical debt and documented until automated.

---

## 12. Secrets architecture

Secrets must not be committed to the repository.

```mermaid
flowchart LR
    Bitwarden[Bitwarden]
    EnvExample[.env.example<br/>Committed template]
    EnvLocal[.env.local<br/>Ignored fallback]
    Bootstrap[Bootstrap Scripts]
    Gateway[Gateway / Services]
    Tools[CLI Tools]

    Bitwarden --> Bootstrap
    EnvLocal --> Bootstrap
    EnvExample -. documents required values .-> EnvLocal

    Bootstrap --> Gateway
    Bootstrap --> Tools
```

Bitwarden is the preferred secrets source.

`.env.local` may be used as an ignored local fallback, but it should not become the primary long-term pattern.

The architecture should avoid storing secrets in:

- committed files
- shell profiles
- bootstrap scripts
- container compose files
- routing configuration
- model configuration

---

## 13. Component model

The workstation is built around capabilities rather than fixed tools.

```mermaid
flowchart TD
    Capability[Capability]
    Contract[Capability Contract]
    Tool[Current Tool]
    Status[Lifecycle Status]
    Replacement[Replacement Option]

    Capability --> Contract
    Contract --> Tool
    Tool --> Status
    Contract --> Replacement
```

Examples:

| Capability | Current / Candidate Implementation |
|---|---|
| Model gateway | LiteLLM |
| Local runtime — Windows | Ollama |
| Local runtime — macOS | oMLX / MLX, Ollama fallback |
| Chat UI | Open WebUI |
| CLI coding assistant | Aider / OpenCode |
| Agent runner | Goose |
| Model fitness | llmfit |
| Secrets management | Bitwarden |

A tool can move through the lifecycle:

```text
Candidate → Trial → Adopted → Preferred → Deprecated → Removed
```

This allows me to experiment without turning the workstation into a messy collection of tools.

---

## 14. Repository architecture

The target repository structure is:

```text
ai-lab/
├── README.md
├── CHANGELOG.md
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

Key directories:

| Directory | Responsibility |
|---|---|
| `bootstrap/` | Setup and rebuild scripts |
| `profiles/` | Device-specific profiles |
| `packages/` | Package declarations |
| `containers/` | Gateway, Open WebUI and future service definitions |
| `config/` | Providers, routing, models, policies and capabilities |
| `contexts/` | Shared, work, personal and persona context |
| `tools/` | CLI wrappers and workstation commands |
| `tests/` | Validation and health checks |
| `docs/` | Architecture, principles, decisions and roadmap |
| `archive/` | Legacy material and historical experiments |

---

## 15. Initial implementation view

Milestone 1 focuses on the smallest useful gateway foundation.

```mermaid
flowchart TD
    CLI[ask-ai / ai-status / ai-route]
    Gateway[LiteLLM or equivalent]
    Ollama[Ollama]
    Frontier[Configured frontier provider placeholder]
    Profile[Profile config]
    Secrets[Bitwarden or .env.local fallback]
    Validate[ai-bootstrap-check]

    CLI --> Gateway
    Gateway --> Ollama
    Gateway --> Frontier
    Profile --> CLI
    Profile --> Gateway
    Secrets --> Gateway
    Validate --> CLI
    Validate --> Gateway
    Validate --> Ollama
```

Milestone 1 should prove that:

- the repo structure works
- a profile can be selected
- the gateway can start
- at least one local provider can be reached
- frontier providers can be configured safely
- basic CLI commands can call the gateway
- validation can report health
- the setup can be rebuilt

---

## 16. Key architecture decisions

These decisions should be captured or expanded through ADRs:

| Decision | ADR |
|---|---|
| Use a gateway-first architecture | `docs/adr/0001-gateway-first.md` |
| Use open-source tools before building custom tools | `docs/adr/0002-open-source-first.md` |
| Treat the CLI as a first-class interface | `docs/adr/0003-cli-native.md` |
| Make the workstation rebuildable from code and config | `docs/adr/0004-rebuildable-by-default.md` |
| Build around composable and replaceable components | `docs/adr/0005-composable-and-replaceable.md` |
| Use local-first but frontier-capable routing | `docs/adr/0006-local-first-frontier-capable.md` |
| Separate work and personal behaviour through profiles | `docs/adr/0007-profile-based-work-personal-separation.md` |

Additional ADRs should be created for major tool decisions such as LiteLLM, Open WebUI, Bitwarden, Aider, OpenCode, Goose and oMLX.

---

## 17. Constraints and assumptions

### Constraints

- The project should be rebuildable.
- The work profile must respect approved AI tooling and data sensitivity.
- Secrets must not be committed.
- The CLI should remain a primary interface.
- The architecture should avoid unnecessary custom platform development.
- The system should remain understandable and maintainable.

### Assumptions

- The AI tooling landscape will continue to change quickly.
- Local models will improve and model choices will change.
- Some tools may be replaced over time.
- The workstation will be built incrementally.
- The first implementation does not need advanced semantic routing.
- Rebuildability and documentation are more important than speed.

---

## 18. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Tool sprawl | Use capability contracts and component lifecycle. |
| Work/personal context mixing | Use profiles, context boundaries and routing policy. |
| Secrets leakage | Use Bitwarden, `.env.example`, ignored local fallback and validation. |
| Overbuilding too early | Use milestones and adopt-before-build principle. |
| Local models underperforming | Use llmfit and frontier escalation. |
| Gateway becomes too complex | Start with simple routing and evolve gradually. |
| UI and CLI drift apart | Route both through the same gateway where practical. |
| Project gets abandoned | Prioritise daily-use workflows and stable commands. |

---

## 19. Architecture summary

The architecture is designed around a simple idea:

```text
Stable workflows.
Replaceable components.
Rebuildable workstation.
```

The first milestone should build the control plane, not the entire future state.

Once the gateway, profile, routing, secrets and validation foundations are in place, the workstation can safely grow into coding workflows, Open WebUI parity, work personas, model fitness, controlled agents and future RAG/project memory.
