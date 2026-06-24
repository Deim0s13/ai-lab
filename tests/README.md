# `tests/README.md`

# tests

This directory contains validation and behavioural tests for **AI Dev Workstation as Code**.

The purpose of this directory is to make the workstation testable, not just documented.

Tests should prove that the workstation behaves the way the architecture says it should behave.

---

## Test philosophy

The first tests should focus on architecture behaviour and rebuild confidence.

They should answer questions such as:

- can the active profile be resolved?
- is the gateway reachable?
- are required local runtimes available?
- are required secrets available without exposing values?
- does routing select the expected provider or model alias?
- does local-first routing behave as expected?
- does the work profile prioritise approved tools first?
- does the personal profile allow the expected frontier routes?
- does degraded local mode work when the gateway is unavailable?
- are blocked contexts actually blocked?

These are not model quality benchmarks.

They are workstation behaviour tests.

---

## Initial test types

| Test type | Purpose |
|---|---|
| Bootstrap validation | Check whether a profile has been rebuilt correctly. |
| Runtime health checks | Confirm local runtimes such as Ollama or oMLX are available where expected. |
| Gateway health checks | Confirm the gateway is configured and reachable. |
| Provider availability checks | Confirm configured providers are available without printing secrets. |
| Routing assertions | Confirm specific tasks route to expected routes/providers. |
| Profile boundary checks | Confirm work/personal context restrictions are enforced. |
| Degraded-mode checks | Confirm expected behaviour when gateway is unavailable. |
| CLI contract checks | Confirm commands return expected output and exit codes. |

---

## Routing assertion examples

Routing tests should use synthetic prompts only.

Example routing tests:

| Test ID | Profile | Scenario | Expected behaviour |
|---|---|---|---|
| `route-001` | `macos-work` | Summarise internal note | Use `local_fast` or `local_capable`; no frontier escalation. |
| `route-002` | `macos-work` | Customer architecture review with `--best` | Use `approved_work` first; Gemini/Cursor before Anthropic/OpenAI. |
| `route-003` | `macos-work` | Restricted content | Local-only or blocked; no frontier provider. |
| `route-004` | `windows-personal` | Personal coding debug | Use `local_code` first, then OpenAI/Anthropic if needed. |
| `route-005` | `windows-personal` | Work context requested | Block context load and do not route. |
| `route-006` | Any active profile | Gateway down with local fallback configured | Use `degraded_local` mode. |

---

## Test data rules

Tests must not include:

- real work content
- customer information
- internal Red Hat material
- personal sensitive information
- API keys
- secrets
- private prompts

Use synthetic prompts only.

Examples:

```text
Summarise this synthetic internal note.
Review this fictional architecture option.
Debug this small example Python function.
```

---

## Expected future commands

Tests may eventually be run through commands such as:

```bash
ai-bootstrap-check --profile macos-work
ai-bootstrap-check --profile windows-personal
ai-route --test
ai-status --profile macos-work
```

Milestone 1 should focus on smoke tests and routing assertions.

More advanced test automation can come later.

---

## Relationship to documentation

Relevant docs:

```text
docs/06-profiles.md
docs/07-routing-strategy.md
docs/08-rebuild-strategy.md
docs/11-cli-interface-contracts.md
docs/adr/0013-routing-validation-and-observability.md
```

The tests in this directory should validate the behaviours described in those documents.
