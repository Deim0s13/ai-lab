# Containers

This directory contains reproducible service definitions used by the workstation.

## Implemented services

LibreChat provides the selected browser chat UI. It runs with MongoDB and uses LiteLLM as its only model endpoint.

```text
containers/
└── librechat/
    ├── compose.yaml
    ├── librechat.yaml
    ├── .env.example
    └── README.md
```

Profile-local files such as `.env.macos-work.local` and `.env.windows-personal.local` are ignored. The lifecycle recipes use profile-specific Compose project names so persistent volumes and conversation state are not shared accidentally.

## Rules

Container definitions should:

- avoid embedded secrets
- use profile-aware configuration where practical
- document ports and volumes
- support rebuildability
- avoid hidden local state
- work with the selected container runtime for the profile

For Windows / WSL2 and future Fedora Atomic usage, Podman-compatible patterns are preferred where practical.

## Related docs

```text
docs/03-architecture.md
docs/08-rebuild-strategy.md
docs/09-tool-selection.md
```
