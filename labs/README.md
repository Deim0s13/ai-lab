# `labs/README.md`

# labs

This directory contains learning notes, practical experiments and short-lived investigations for **AI Dev Workstation as Code**.

The purpose of `labs/` is to create a safe place to explore ideas before they become part of the workstation architecture.

Not every experiment should become a tool, capability or ADR.

---

## What belongs here

Use this directory for:

- tool trials
- runtime experiments
- model tests
- quick comparisons
- installation notes
- proof-of-concept workflows
- notes from trying open-source tools
- rough findings that are not yet architecture decisions

Examples:

```text
labs/litellm-trial.md
labs/open-webui-trial.md
labs/aider-local-model-test.md
labs/ollama-vs-omlx-notes.md
labs/bitwarden-cli-test.md
```

---

## What does not belong here

Do not use `labs/` for:

- accepted architecture decisions
- permanent configuration
- secrets
- production scripts
- committed API keys
- work/customer-sensitive content
- long-term documentation that belongs in `docs/`

If an experiment becomes part of the architecture, it should be moved into the proper process.

---

## Experiment lifecycle

The expected flow is:

```text
experiment in labs/
→ assess against a capability contract
→ update component lifecycle status
→ create ADR if architecturally significant
→ implement through config/bootstrap/tools if adopted
```

Examples:

| Lab outcome | Next step |
|---|---|
| LiteLLM proves suitable as the gateway | Create or update ADR, move component to Trial/Adopted. |
| Open WebUI works cleanly through gateway | Update capability contract and component lifecycle. |
| Aider does not fit local model workflow | Record rejection or keep lab note only. |
| Bitwarden CLI works for local secrets | Update secrets implementation notes. |
| oMLX is too limited for coding aliases | Update profile/runtime decision and model aliases. |

---

## Relationship to ADRs

Labs are for investigation.

ADRs are for decisions.

Create or update an ADR when an experiment:

- selects a preferred tool
- changes the architecture direction
- affects security or secrets handling
- affects work/personal separation
- changes routing or runtime behaviour
- creates a meaningful trade-off
- replaces a previous decision

A lab note can remain as supporting evidence, but the decision should live in `docs/adr/`.

---

## Relationship to component lifecycle

If an experiment involves a tool, runtime, provider or service, it should eventually align to the component lifecycle:

```text
Candidate → Trial → Adopted → Preferred → Deprecated → Removed
```

Relevant doc:

```text
docs/05-component-lifecycle.md
```

An experiment does not become part of the workstation just because it exists in `labs/`.

---

## Safety rules

Lab notes must not contain:

- secrets
- API keys
- customer information
- internal Red Hat material
- personal sensitive information
- private tokens
- production credentials

If a lab requires sensitive input, document the method using synthetic or redacted examples only.

---

## Summary

The rule for this directory is:

```text
Use labs to learn.
Use ADRs to decide.
Use component lifecycle to adopt.
Use docs/config/tools to make it real.
```
