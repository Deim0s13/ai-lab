# `config/README.md`

# config

This directory will contain shared configuration for the AI workstation.

Configuration should define behaviour without hard-coding it into scripts.

---

## Purpose

Config may include:

- provider definitions
- model aliases
- routing rules
- gateway configuration
- logging settings
- validation settings
- profile defaults

---

## Expected structure

Possible future structure:

```text
config/
├── providers.yaml
├── models.yaml
├── routes.yaml
├── logging.yaml
└── gateway/
```

The exact structure may change during implementation.

---

## Rules

Config should be:

- readable
- profile-aware
- safe to commit
- free of secrets
- easy to validate

Secrets should be referenced by name and resolved through Bitwarden or approved fallback mechanisms.

---

## Related docs

```text
docs/03-architecture.md
docs/07-routing-strategy.md
docs/08-rebuild-strategy.md
docs/11-cli-interface-contracts.md
docs/adr/0011-secrets-management-strategy.md
```
