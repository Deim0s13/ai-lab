# Rebuild Strategy

This document defines how AI Dev Workstation as Code should be made reproducible across devices.

The workstation should not depend on undocumented manual setup. It should be rebuildable from the repository using profiles, package declarations, container definitions, configuration and validation checks.

---

## 1. Core principle

```text
Rebuildable by default, disposable by design.
```

If a laptop is rebuilt, replaced or reset, the AI workstation should be recoverable from the repository with minimal manual effort.

The repository should be the source of truth.

---

## 2. Why rebuildability matters

The workstation is intended to become part of daily use.

If it cannot be rebuilt easily, it will become fragile and hard to trust.

Rebuildability supports:

- new devices
- clean rebuilds
- atomic operating systems
- consistent setup across machines
- easier troubleshooting
- safer experimentation
- better documentation
- reduced reliance on memory

---

## 3. Target rebuild pattern

The target rebuild pattern is:

```text
Clone repository
Select profile
Install package dependencies
Apply configuration
Start services
Install or verify models
Run validation checks
Use workstation
```

Example:

```bash
git clone https://github.com/Deim0s13/ai-lab.git
cd ai-lab
./bootstrap/bootstrap.sh --profile macos-work
ai-bootstrap-check
```

---

## 4. Thin-host approach

The workstation should follow a thin-host pattern.

```text
Host OS
= thin, stable and minimally modified

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

This approach fits macOS, Windows/WSL2 and future Fedora Atomic or Silverblue environments.

---

## 5. What should be containerised

Platform services should be containerised where practical.

Initial container candidates:

```text
LiteLLM or equivalent gateway
Open WebUI
future vector database
future memory service
future observability service
```

Container benefits:

- easier rebuild
- easier removal
- consistent service startup
- reduced host pollution
- clearer dependency boundaries

---

## 6. What should not be forced into containers

Not everything should be containerised.

The following may be better installed as host or user-space tools:

```text
Ollama
oMLX / MLX runtime
llmfit
Aider
OpenCode
Goose
CLI wrappers
shell configuration
editor integrations
```

Reasons:

- GPU or Apple Silicon access
- better filesystem integration
- simpler developer experience
- easier CLI usage
- better editor integration

The principle is:

```text
Containerise services.
Install user workflows natively or with isolated user package managers.
```

---

## 7. Platform strategy: macOS

The MacBook Pro should use a repeatable macOS setup.

Likely tools:

```text
Homebrew
pipx
uv
container runtime
repo-managed config
```

Potential package declaration:

```text
packages/brew/Brewfile
packages/pipx/tools.txt
```

Expected setup flow:

```bash
./bootstrap/bootstrap-macos.sh --profile macos-work
```

The script should:

- check for Homebrew
- install required packages
- install user-space Python tools
- configure shell environment
- prepare containers
- apply profile config
- run validation

---

## 8. Platform strategy: Windows

The Windows laptop should use a repeatable Windows plus WSL2 setup.

Likely tools:

```text
winget
WSL2
Ubuntu or selected WSL distro
Podman or Docker
Ollama
repo-managed config
```

Expected setup flow:

```powershell
.\bootstrap\bootstrap-windows.ps1 -Profile windows-personal
```

Then inside WSL if needed:

```bash
./bootstrap/bootstrap-wsl.sh --profile windows-personal
```

The setup should clearly separate:

- Windows host tasks
- WSL tasks
- container tasks
- model runtime tasks

---

## 9. Platform strategy: Fedora Atomic

The Fedora Atomic profile should favour minimal host changes.

Likely tools and patterns:

```text
rpm-ostree only when required
Podman for services
toolbox or distrobox for mutable development
Flatpak for GUI applications
systemd user services
user-space package managers where appropriate
```

Expected setup flow:

```bash
./bootstrap/bootstrap.sh --profile fedora-atomic
```

The profile should avoid relying on undocumented host state.

---

## 10. Bootstrap scripts

Bootstrap scripts should be idempotent.

That means they should be safe to run more than once.

Expected behaviour:

- if a tool exists, skip or update
- if a directory exists, reuse it
- if config exists, update carefully
- if service exists, restart or report status
- if a model exists, do not redownload unless requested
- if a secret is missing, warn clearly
- if a step fails, provide the next action

Suggested scripts:

```text
bootstrap/
├── bootstrap.sh
├── bootstrap-macos.sh
├── bootstrap-windows.ps1
└── bootstrap-wsl.sh
```

---

## 11. Package declarations

Package lists should live in the repo.

Suggested structure:

```text
packages/
├── brew/
│   └── Brewfile
├── winget/
│   └── packages.json
├── dnf/
│   └── packages.txt
└── pipx/
    └── tools.txt
```

Package declarations should be profile-aware where practical.

---

## 12. Services

Services should be defined in code.

Suggested structure:

```text
containers/
├── litellm/
│   ├── compose.yaml
│   └── config.yaml
├── open-webui/
│   └── compose.yaml
└── shared/
    └── network.env
```

Future Linux user services:

```text
systemd/
├── user/
│   ├── litellm.service
│   ├── open-webui.service
│   └── ollama.service
└── timers/
    └── ai-model-review.timer
```

---

## 13. Secrets

Secrets must never be committed to the repository.

Initial approach:

```text
.env.example committed
.env.local ignored
```

Initial expected secrets:

```text
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GEMINI_API_KEY=
```

Possible future options:

```text
1Password CLI
pass
sops + age
OS keychain
```

The first implementation can remain simple, but the project should avoid spreading secrets across machine state.

---

## 14. Models

Models should not be stored in git.

The repository should store:

- model aliases
- desired model list
- llmfit results
- model shortlist
- routing mappings

Suggested files:

```text
config/models/
├── model-shortlist.yaml
├── llmfit-windows.md
├── llmfit-macos.md
└── desired-models.yaml
```

Model installation should eventually be automated or at least validated.

---

## 15. Validation

Validation is essential.

A rebuild is not complete until the workstation can prove that it works.

Initial validation commands:

```text
ai-bootstrap-check
ai-status
```

These should check:

- selected profile
- required package managers
- container runtime
- gateway service
- local runtime
- frontier provider configuration
- Open WebUI service
- llmfit availability
- required models
- CLI tools
- route configuration

Example output:

```text
AI Workstation Check

Profile: macos-work

✓ Git installed
✓ Brew installed
✓ Container runtime available
✓ Gateway config found
✓ LiteLLM running
✓ oMLX reachable
✓ Ollama reachable
✓ Anthropic key present
✓ OpenAI key present
✓ ask-ai working
✗ Open WebUI not running

Next action:
podman compose -f containers/open-webui/compose.yaml up -d
```

---

## 16. Manual steps

Manual steps should be treated as technical debt.

If something must be manual, document it in:

```text
docs/manual-steps.md
```

The goal is to reduce this file over time.

---

## 17. Rebuild definition of done

A profile is considered rebuildable when:

- bootstrap script exists
- package declarations exist
- required services are defined
- provider config exists
- secrets approach is documented
- validation command exists
- setup can be repeated on a clean machine
- manual steps are documented
- the profile can run at least one local AI request through the gateway

---

## 18. Summary

The workstation should not be a manually assembled machine.

It should be a rebuildable environment.

The principle is:

```text
Clone it.
Bootstrap it.
Validate it.
Use it.
Rebuild it when needed.
```
