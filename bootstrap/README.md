# bootstrap

This directory will contain scripts and instructions for setting up or rebuilding an AI workstation profile.

The goal is to make each supported profile reproducible from the repo.

---

## Purpose

Bootstrap should help answer:

```text
Can I rebuild this workstation from a clean machine or fresh environment?
```

Bootstrap logic should eventually support:

- checking host prerequisites
- installing required packages
- preparing profile-specific configuration
- validating local runtimes
- preparing gateway configuration
- checking secrets availability
- running `ai-bootstrap-check`

---

## Expected structure

Possible future structure:

```text
bootstrap/
├── macos-work/
├── windows-personal/
└── shared/
```

`fedora-atomic` is a future/reference profile and does not need active bootstrap implementation during Milestone 1.

---

## Rules

Bootstrap scripts should be:

- idempotent where practical
- profile-aware
- safe to re-run
- explicit about manual steps
- clear when they fail
- free of secrets

Manual steps are allowed early, but they should be documented as technical debt.

---

## Related docs

```text
docs/06-profiles.md
docs/08-rebuild-strategy.md
docs/10-milestones.md
docs/11-cli-interface-contracts.md
```
