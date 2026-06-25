# Tool Evaluations

This folder contains lightweight evaluations of tools considered for the AI Dev Workstation.

Tool evaluations are used to compare options, capture rationale and avoid turning every tool choice into an ADR.

They are intentionally practical and lightweight.

## Purpose

Tool evaluations help answer:

- What problem are we trying to solve?
- Which tools were considered?
- Which tool is preferred?
- Why was it selected?
- What are the trade-offs?
- What risks or follow-up checks are needed?
- Is this decision temporary, provisional or durable?

## Relationship to ADRs

Tool evaluations are not ADRs.

Use a tool evaluation when assessing a tool or comparing options.

Use an ADR when the decision changes the architecture or creates a durable constraint for the project.

A tool evaluation may later feed into an ADR if the decision becomes architecturally significant.

## Relationship to `docs/09-tool-selection.md`

`docs/09-tool-selection.md` captures the overall tool selection principles and current posture.

This folder holds the detailed evaluations so the main tool selection document does not become bloated.

## Naming

Use numbered files with a short topic name:

```text
001-litellm-gateway.md
002-just-task-runner.md
003-yamllint-yq-validation.md
```

## Evaluation Status

Suggested statuses:

- `Proposed`
- `Accepted`
- `Rejected`
- `Parked`
- `Superseded`

## Review

Tool choices should be revisited when:

- the tool becomes painful to use
- the tool no longer aligns with the project principles
- the project scope changes
- a better open-source option appears
- the tool introduces unacceptable security, licensing or operational risk
- custom code starts growing around a tool in ways that suggest poor fit
