# containers

This directory will contain container and service definitions used by the workstation.

The goal is to keep services reproducible and easy to rebuild.

---

## Purpose

Container definitions may be used for:

- AI gateway services
- Open WebUI
- supporting services
- future RAG or memory services
- development utilities

---

## Expected structure

Possible future structure:

```text
containers/
├── gateway/
├── open-webui/
└── shared/
```

---

## Rules

Container definitions should:

- avoid embedded secrets
- use profile-aware configuration where practical
- document ports and volumes
- support rebuildability
- avoid hidden local state
- work with the selected container runtime for the profile

For Windows / WSL2 and future Fedora Atomic usage, Podman-compatible patterns are preferred where practical.

---

## Related docs

```text
docs/03-architecture.md
docs/08-rebuild-strategy.md
docs/09-tool-selection.md
```
