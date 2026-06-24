# tools

This directory will contain CLI wrappers and helper scripts for the workstation.

The CLI is a first-class interface for this project.

---

## Initial tools

The first commands are expected to be:

| Command | Purpose |
|---|---|
| `ask-ai` | General AI prompt entry point. |
| `ai-route` | Explain and test routing decisions. |
| `ai-status` | Show workstation health and profile state. |
| `ai-bootstrap-check` | Validate a rebuilt profile. |
| `ai-model-review` | Review model fitness and aliases. |

---

## Expected structure

Possible future structure:

```text
tools/
├── ask-ai
├── ai-route
├── ai-status
├── ai-bootstrap-check
├── ai-model-review
└── lib/
```

---

## Rules

Tools should be:

- thin wrappers
- profile-aware
- gateway-first where practical
- explicit about degraded modes
- clear in failure
- consistent with the CLI interface contract
- free of hard-coded secrets

Tools should read config rather than embedding policy.

---

## Related docs

```text
docs/11-cli-interface-contracts.md
docs/07-routing-strategy.md
docs/08-rebuild-strategy.md
docs/adr/0003-cli-native.md
```
