# Architecture Decision Records

This folder contains Architecture Decision Records, or ADRs, for AI Dev Workstation as Code.

ADRs capture important decisions about the project’s architecture, tooling, design principles and implementation direction.

They help explain not just **what** was decided, but **why** it was decided.

---

## Purpose

ADRs are used to preserve decision history.

They help future readers understand:

- why the project is gateway-first
- why certain tools were selected or rejected
- why some components are preferred, trialled or deprecated
- how trade-offs were considered
- when a decision should be revisited

The goal is not to create heavy documentation. The goal is to make important decisions easy to understand later.

---

## When to create an ADR

Create an ADR when a decision:

- affects the overall architecture
- introduces, replaces or removes a major tool
- changes the rebuild strategy
- changes routing, provider or model behaviour
- changes the work/personal profile model
- introduces a new capability
- creates a meaningful trade-off
- may be questioned later

Examples:

- choosing LiteLLM as the model gateway
- deciding that the CLI is the primary interface
- adopting Ollama for the Windows personal profile
- adding Open WebUI as the chat UI
- selecting Aider or OpenCode as the preferred coding assistant
- introducing Goose for constrained agents
- changing how secrets are managed
- replacing a local runtime or model provider

---

## When an ADR is not needed

An ADR is usually not needed for:

- small documentation edits
- minor script fixes
- typo corrections
- simple refactoring with no architectural impact
- temporary experiments that are not adopted
- adding notes that do not change direction

If a temporary experiment becomes part of the standard build, create an ADR then.

---

## ADR numbering

ADRs should use a four-digit number and a short kebab-case title.

Example:

```text
0001-gateway-first.md
0002-open-source-first.md
0003-cli-native.md
```

The number should not be reused.

If a decision is replaced later, create a new ADR and mark the old one as superseded.

---

## ADR status values

Use one of the following status values:

```text
Proposed
Accepted
Superseded
Deprecated
```

### Proposed

The decision is being considered but has not yet been accepted.

### Accepted

The decision is current and should guide implementation.

### Superseded

The decision has been replaced by a newer ADR.

### Deprecated

The decision is still part of the history but should no longer guide new work.

---

## How to use the template

Use the standard ADR template:

```text
docs/adr/0000-template.md
```

To create a new ADR:

1. Copy the template.
2. Rename it using the next available ADR number.
3. Replace the title with the decision title.
4. Set the status.
5. Fill in the sections.
6. Keep it concise, but include enough context to understand the decision later.

Example:

```bash
cp docs/adr/0000-template.md docs/adr/0008-use-litellm-as-gateway.md
```

---

## Writing style

ADRs should be clear, practical and easy to read.

Good ADRs:

- state the decision directly
- explain the context
- describe options considered
- capture the trade-offs
- explain implementation impact
- include a review trigger

Avoid making ADRs too long. If a decision needs detailed implementation notes, link to a separate document.

---

## Review and maintenance

ADRs are not deleted when decisions change.

Instead:

- mark the old ADR as `Superseded`
- link to the new ADR
- explain what changed

This keeps the decision history intact.

The guiding rule is:

```text
Document the decision clearly enough that future you understands why it made sense at the time.
```
