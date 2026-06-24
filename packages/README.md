# packages

This directory will contain package lists or install manifests for supported profiles.

The goal is to make workstation dependencies visible and reproducible.

---

## Purpose

Package definitions may cover:

- CLI tools
- local runtimes
- gateway dependencies
- container tooling
- developer utilities
- validation tools

---

## Expected structure

Possible future structure:

```text
packages/
├── macos-work/
│   └── Brewfile
├── windows-personal/
│   └── packages.md
└── shared/
    └── cli-tools.md
```

---

## Rules

Package lists should be:

- profile-aware
- minimal
- documented
- safe to run or easy to review
- aligned with the component lifecycle

Adding a package should be tied to a capability, not added because it is interesting.

---

## Related docs

```text
docs/04-capability-contracts.md
docs/05-component-lifecycle.md
docs/08-rebuild-strategy.md
docs/09-tool-selection.md
```
