# Architecture Principles

This document defines the architecture principles for AI Dev Workstation as Code.

These principles guide how I design, build, operate and evolve the workstation. They should be used when selecting tools, shaping the repo, deciding what to automate, introducing new capabilities, or reviewing whether something still belongs in the project.

Each principle is written with:

- **Statement** — the principle itself
- **Rationale** — why it matters
- **Implications** — what it means in practice

---

## 1. Gateway-first model access

### Statement

Model access should go through a common gateway wherever practical.

### Rationale

I do not want every tool, script, UI or agent to be wired directly to a specific model provider. That creates lock-in, duplication and brittle configuration.

A gateway-first approach gives me a common control point for local models, frontier models, routing, fallback behaviour, aliases, policy and future observability.

It also makes the workstation easier to evolve as new providers, runtimes or model tools become available.

### Implications

- CLI tools should call the gateway where practical.
- Open WebUI or other chat interfaces should use the same gateway rather than becoming separate AI environments.
- Coding tools should use routed model aliases where possible.
- Model names should be abstracted behind aliases such as `local_fast`, `local_code` or `frontier_reasoning`.
- Provider-specific configuration should live in config files rather than being scattered through scripts.
- Direct provider access is acceptable only when a tool cannot reasonably use the gateway or there is a clear reason to bypass it.

---

## 2. CLI-native workflows

### Statement

The CLI is a primary interface, not a fallback.

### Rationale

I already work heavily from the terminal, especially for AI-assisted development workflows. If this workstation is going to become part of my normal way of working, it needs to meet me where I already work.

UI and IDE integrations are useful, but they should not be the only way to use the system.

### Implications

- Important workflows should have a CLI path where practical.
- Commands such as `ask-ai`, `ai-route`, `ai-status`, `ai-model-review`, `dev-ai`, `architect-ai` and `write-ai` should be treated as stable user-facing interfaces.
- UI and IDE tools should complement the CLI rather than replace it.
- CLI commands should be scriptable, explainable and usable across devices.
- Where a workflow starts in a UI, there should be a clear equivalent or supporting CLI path where practical.

---

## 3. Open-source-first adoption

### Statement

I should adopt active open-source tools before building custom functionality.

### Rationale

The AI tooling ecosystem is moving quickly. Building custom tools too early creates unnecessary maintenance burden and risks duplicating work that already exists elsewhere.

Using open-source tools where they fit allows me to move faster, learn from existing projects, and keep the workstation more replaceable.

### Implications

- Before building a custom script or service, I should check whether an active open-source tool already satisfies the need.
- Custom code should usually be limited to wrappers, glue logic, validation checks, profile loading and project-specific workflow commands.
- Tool selection should consider activity, maintainability, CLI support, gateway compatibility, rebuildability and replacement options.
- Open-source-first does not mean open-source-only. Frontier providers and approved work tools may still be used where appropriate.
- If a custom tool is built, it should be small, understandable and replaceable.

---

## 4. Rebuildable by default

### Statement

The workstation must be rebuildable from code and configuration.

### Rationale

I do not want this environment to become dependent on undocumented machine state. If I rebuild a laptop, replace a device, or move to a more atomic operating system model, I should be able to recreate the workstation from the repo.

Rebuildability is central to making this project durable rather than experimental.

### Implications

- The repository is the source of truth.
- Bootstrap scripts should install and configure the environment where practical.
- Package declarations should be stored in the repo.
- Services should be defined as code.
- Configuration should be versioned where safe.
- Manual setup should be avoided or documented.
- Validation commands should confirm that the rebuild worked.
- The project should support a future Fedora Silverblue or atomic Linux style of working.

---

## 5. Disposable machine, durable repo

### Statement

The machine should be treated as disposable; the repo should be treated as durable.

### Rationale

A workstation can drift over time. Tools get installed manually, configs get changed, and local state becomes hard to reproduce. Treating the machine as disposable forces the project to capture what matters in code, config and documentation.

This is especially important if I want the environment to work across macOS, Windows, WSL2 and future atomic Linux setups.

### Implications

- Host changes should be minimised.
- Platform services should be containerised where practical.
- User-space tools should be installed through repeatable package managers.
- Secrets should not be stored in shell profiles, dotfiles or scripts.
- Models should be represented through desired model lists and aliases, not stored in git.
- If something cannot be rebuilt, it should be treated as technical debt.

---

## 6. Configuration over hard-coded behaviour

### Statement

Behaviour should be defined in configuration wherever practical.

### Rationale

Hard-coded model names, providers, routes and tool paths make the workstation brittle. Configuration allows the system to evolve without rewriting workflows.

This matters because the best models, runtimes and tools will change over time.

### Implications

- Profiles should define machine intent and policy.
- Routing should be defined through config files.
- Provider details should be isolated in provider config.
- Model aliases should be used instead of hard-coded model names.
- Capability status should be tracked in configuration or documentation.
- Changing a default model, provider or route should usually be a config change, not a code change.
- Scripts should read config rather than embed assumptions.

---

## 7. Local-first, not local-only

### Statement

Local models should be the default route where appropriate, but frontier models should remain available when justified.

### Rationale

Local models provide privacy, speed, cost control and learning value. However, they will not always be the best tool for complex reasoning, large synthesis, customer-facing material, or difficult coding tasks.

The workstation should make local models easy to use without pretending they can do everything.

### Implications

- The default route should be local where practical.
- Frontier escalation should be deliberate and observable.
- Local models are preferred for simple explanations, summaries, rewrites, private notes, low-risk coding help, experimentation and learning.
- Frontier models may be used for complex reasoning, high-stakes writing, difficult debugging, architecture review or large synthesis.
- The system should support explicit controls such as `--local`, `--best` and `--explain-route`.
- Routing policy should make escalation criteria clear.

---

## 8. Profile-aware governance

### Statement

The workstation must behave differently depending on the selected profile and use case.

### Rationale

My MacBook Pro is a work device. My Windows laptop is a personal development device. They should share the same architecture, but they should not share the same assumptions, contexts or provider priorities.

The work profile must account for approved tools, data sensitivity and work-safe usage. The personal profile can allow more experimentation.

### Implications

- `macos-work`, `windows-personal` and `fedora-atomic` should be separate profiles.
- Work and personal context should not be mixed accidentally.
- The `macos-work` profile should prioritise approved work AI tools first, such as Gemini and Cursor, with other providers used only depending on use case, approval context and policy.
- The `windows-personal` profile can use OpenAI and Anthropic as primary frontier escalation paths for personal development and experimentation.
- Experimental agents should not be enabled by default on the work profile.
- Frontier escalation rules should differ by profile.
- Profile configuration should drive provider priority, enabled capabilities and privacy behaviour.

---

## 9. Secure secrets by default

### Statement

Secrets must be managed securely and must not be committed to the repository.

### Rationale

The workstation will need API keys and other sensitive values. Storing these in scripts, shell profiles, compose files or committed config would make the project unsafe and harder to share or review.

I already use Bitwarden, so the project should use Bitwarden as the preferred secrets source rather than introducing a heavier secrets platform.

### Implications

- Bitwarden should be the preferred secrets source.
- `.env.example` should be committed only as a template.
- `.env.local` may exist as an ignored local fallback.
- Secrets should not be stored in committed files, shell profiles, bootstrap scripts, container compose files, routing config or model config.
- Validation should check whether required secrets are available without exposing values.
- A future `ai-secrets` helper may be useful to avoid scattering Bitwarden commands through scripts.
- HashiCorp Vault or similar platforms are out of scope unless the project grows into something that genuinely needs them.

---

## 10. Capability-based design

### Statement

The workstation should be organised around capabilities, not specific tools.

### Rationale

Tools will change. Capabilities are more stable.

For example, I need a model gateway, a local runtime, a CLI coding assistant, a chat UI, a model fitness process and eventually an agent runner. The exact tools that implement those capabilities may change over time.

### Implications

- Tool choices should be documented as implementations of capabilities.
- Each capability should have a clear contract.
- New tools should be assessed against the relevant capability contract.
- A tool should not define the architecture.
- Replacing a tool should not require redesigning the workstation.
- Capability contracts should guide adoption, replacement and deprecation.

---

## 11. Stable workflows, replaceable implementations

### Statement

The workflows I build habits around should remain stable even when the implementation changes.

### Rationale

This project will only last if it becomes part of my normal way of working. If every tool change forces me to relearn the workflow, the workstation will become friction rather than leverage.

Stable commands and patterns help the workstation survive changes in models, providers and tooling.

### Implications

- Commands such as `ask-ai`, `dev-ai`, `architect-ai` and `write-ai` should remain stable where possible.
- Underlying providers, models and tools can change through config.
- Model aliases should be used instead of direct model names in daily workflows.
- Wrappers should be thin and replaceable.
- A workflow should not depend unnecessarily on one provider or runtime.
- The habit should outlive the tool.

---

## 12. Observable and explainable routing

### Statement

The workstation should be able to explain routing decisions.

### Rationale

Routing is only useful if I can understand and trust it. If the system silently sends tasks to different providers, it becomes harder to debug, govern and learn from.

Observable routing helps with trust, cost awareness, privacy and model improvement.

### Implications

- Routing commands should be able to explain the selected provider, model, route and task type.
- Frontier escalation should be visible.
- Work profile routing should show when confirmation is required.
- `ai-route` should provide a human-readable explanation of routing decisions.
- Logs or summaries may be useful later, but the first implementation can start with simple route explanation.
- If routing cannot be explained, it should not be automated too aggressively.

---

## 13. Model fitness informs model choice

### Statement

Model selection should be informed by device fit and task fit, not hype.

### Rationale

Different devices will run different models well. A model that works on the Windows laptop may not be suitable for the MacBook Pro, and vice versa.

Using llmfit or an equivalent process helps keep model choices grounded in actual hardware and workload fit.

### Implications

- llmfit should be used to assess model suitability.
- Results should be captured per device.
- Model shortlists should be updated over time.
- Routing aliases should reflect actual model fit.
- Models that are too slow, too large or not useful should be demoted or removed.
- Model review should become a recurring maintenance activity.

---

## 14. Agents with guardrails

### Statement

Agents should be introduced gradually, with clear scope and controls.

### Rationale

Agents can be useful, but they can also create risk and complexity if introduced too early or given too much freedom.

The project should build a trusted gateway, CLI, routing and model fitness foundation before relying on agents for multi-step workflows.

### Implications

- Agents should not be part of the first foundation milestone unless needed for evaluation.
- Initial agents should be constrained to specific workflows.
- File modification rights should be explicit.
- Work profile agents should be more restricted than personal profile agents.
- Agent routing should still use the gateway where practical.
- Agent activity should be observable.
- Agents should be adopted only if they support real recurring workflows.

---

## 15. Documented decisions

### Statement

Significant architecture and tooling decisions should be captured as ADRs.

### Rationale

This project will evolve over time. Without decision records, it will become hard to remember why a tool was selected, why a pattern was chosen, or when a decision should be revisited.

ADRs help preserve the reasoning behind the project.

### Implications

- Major architecture decisions should have ADRs.
- Tool adoption or replacement should be documented when significant.
- ADRs should capture context, decision, options, rationale, consequences, implementation impact and review triggers.
- ADRs should not be deleted when decisions change; they should be superseded.
- The ADR template should be used consistently.

---

## 16. Daily use over novelty

### Statement

A component should earn its place by supporting a real recurring workflow.

### Rationale

The goal is not to install every interesting AI tool. The goal is to build a workstation that I actually use.

Novelty creates clutter. Recurring value creates habits.

### Implications

- New tools should be tied to a clear workflow.
- Experimental tools should be marked as candidates or trials.
- Unused tools should be deprecated or removed.
- Milestones should produce usable capability, not just interesting infrastructure.
- The project should optimise for durable daily use rather than completeness.

---

## Summary

These principles are intended to keep the project coherent as it evolves.

The overall direction is:

```text
Stable workflows.
Replaceable components.
Rebuildable workstation.
Local-first by default.
Frontier-capable when justified.
Secure and profile-aware.
Documented as it evolves.
```
