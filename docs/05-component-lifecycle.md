# Component Lifecycle

This document defines how tools, runtimes, providers and components move through the AI Dev Workstation as Code project.

The AI tooling space moves quickly. New tools will appear, existing tools will change direction, and some tools will become obsolete.

This project should make it easy to trial new tools without turning the workstation into a messy collection of experiments.

---

## 1. Purpose

The component lifecycle provides a simple way to manage change.

It helps answer:

- Is this tool just being researched?
- Is it being trialled?
- Is it part of the standard build?
- Is it the preferred implementation?
- Is it being replaced?
- Has it been removed?

This avoids confusion and keeps the workstation maintainable.

---

## 2. Lifecycle states

Components move through the following states:

```text
Candidate → Trial → Adopted → Preferred → Deprecated → Removed
```

Not every component needs to reach every state.

Some candidates may never be trialled.

Some trials may be removed.

Some adopted tools may never become preferred.

---

## 3. Candidate

A candidate is a tool or component worth considering.

It has not yet been tested enough to become part of the workstation.

A candidate should have:

- a clear capability it may satisfy
- a reason for consideration
- a link to the project or documentation
- initial notes about fit
- any obvious risks

Example:

```yaml
name: OpenCode
capability: CLI Coding Assistant
status: Candidate
reason: Possible open-source coding agent for terminal and IDE workflows.
```

---

## 4. Trial

A trial component is being actively tested.

It may be installed on one profile or used in one workflow, but it is not yet considered standard.

A trial should define:

- test scope
- target profile
- success criteria
- failure criteria
- install method
- rollback or removal approach

Example:

```yaml
name: Aider
capability: CLI Coding Assistant
status: Trial
profile: windows-personal
success_criteria:
  - Can use local model through gateway
  - Can edit a small repo safely
  - Can escalate to frontier model when needed
```

---

## 5. Adopted

An adopted component is part of the workstation.

It is considered useful enough to keep and maintain.

An adopted component should have:

- documented install process
- configuration in the repo
- known role
- validation checks where practical
- replacement criteria

Example:

```yaml
name: Ollama
capability: Local Runtime
status: Adopted
profiles:
  - windows-personal
  - macos-work
```

---

## 6. Preferred

A preferred component is the default implementation for a capability.

There should usually be only one preferred component per capability per profile.

Example:

```yaml
capability: Model Gateway
preferred: LiteLLM
status: Preferred
```

Preferred does not mean permanent. It means default for now.

A preferred component can be replaced if a better option emerges.

---

## 7. Deprecated

A deprecated component is still present but should no longer be used for new work.

Deprecation should include:

- reason for deprecation
- replacement path
- expected removal timing
- migration notes

Example:

```yaml
name: Old ask-ollama script
status: Deprecated
replacement: ask-ai
reason: Hard-coded to Ollama and does not support gateway routing.
```

---

## 8. Removed

A removed component is no longer part of the workstation.

Before removal, consider whether the component should be archived.

Removed components should be noted if they were previously adopted or preferred.

Example:

```yaml
name: old-local-only-routing-script
status: Removed
reason: Replaced by gateway routing policy.
removed_in: v0.3
```

---

## 9. Component record

Each significant component should have a record.

This can start in a simple YAML file such as:

```text
config/capabilities/components.yaml
```

Example structure:

```yaml
components:
  litellm:
    name: LiteLLM
    capability: Model Gateway
    status: Trial
    profiles:
      - macos-work
      - windows-personal
    install_method: container
    replacement_criteria:
      - multiple provider support
      - OpenAI-compatible endpoint
      - local and frontier model support
      - active maintenance

  ollama:
    name: Ollama
    capability: Local Runtime
    status: Adopted
    profiles:
      - windows-personal
      - macos-work
    install_method: host
```

This can evolve over time.

---

## 10. Trial criteria

A component should only move from Candidate to Trial when it has a clear test purpose.

Questions to ask:

- What capability does it satisfy?
- Which profile will trial it?
- What workflow will test it?
- What does success look like?
- What does failure look like?
- How do we remove it cleanly?

Avoid trialling tools only because they are interesting.

---

## 11. Adoption criteria

A component should only move from Trial to Adopted when it has proven value.

Adoption criteria may include:

- supports a real recurring workflow
- works with the gateway or profile model
- can be installed reproducibly
- has clear documentation
- is actively maintained
- does not create unacceptable lock-in
- is easier to keep than remove

---

## 12. Preferred criteria

A component should only become Preferred when it is the default choice for a capability.

Preferred components should be:

- reliable
- documented
- rebuildable
- validated
- actively used
- aligned to project principles

Preferred components should still be replaceable.

---

## 13. Deprecation criteria

A component may be deprecated when:

- it no longer fits the architecture
- it has been replaced by a better tool
- it is no longer actively maintained
- it creates too much manual setup
- it bypasses the gateway unnecessarily
- it duplicates another preferred component
- it is not being used

Deprecation should be explicit, not silent.

---

## 14. Archive before delete

The project should generally archive before deleting.

This is especially true for:

- old scripts
- old setup notes
- previous routing approaches
- troubleshooting notes
- model notes
- legacy architecture notes

Archiving keeps history without confusing the current structure.

Suggested archive structure:

```text
archive/
├── 2026-v0-workstation-docs/
├── old-scripts/
├── old-docs/
├── experiments/
└── repo-inventory/
```

---

## 15. Review rhythm

The component lifecycle should be reviewed regularly.

Early project rhythm:

```text
Review components weekly while the workstation is being actively shaped.
```

Stable project rhythm:

```text
Review components monthly or when introducing a new major tool.
```

The review should check:

- what is adopted
- what is preferred
- what is still only a trial
- what should be deprecated
- what should be removed
- what needs documentation

---

## 16. Relationship to tool selection

Tool selection is covered in `docs/09-tool-selection.md`.

The lifecycle answers:

```text
Where is this component in its journey?
```

Tool selection answers:

```text
Should this component be considered at all?
```

Capability contracts answer:

```text
What must this component be able to do?
```

Together, these keep the workstation coherent.

---

## 17. Summary

The component lifecycle protects the workstation from tool sprawl.

It allows experimentation without losing control.

The guiding rule is:

```text
Trial deliberately.
Adopt carefully.
Prefer explicitly.
Deprecate honestly.
Remove cleanly.
```
