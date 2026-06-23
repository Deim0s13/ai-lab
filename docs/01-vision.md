# Vision

## Project vision

AI Dev Workstation as Code is my rebuildable AI development and productivity environment.

I want this project to become part of my normal daily workflow, not just another experiment that gets abandoned after a few weeks.

The workstation should make it easier for me to:

- use local models safely and effectively
- understand which models fit each device and task
- route work between local and frontier models
- work from the CLI, IDE or UI
- support development and vibe coding
- support architecture, writing and research workflows
- introduce agents in a controlled way
- rebuild the environment on a new or refreshed machine

---

## The problem I am trying to solve

AI tooling is fragmented.

There are local runtimes, frontier models, coding agents, chat UIs, CLI tools, IDE extensions, agent frameworks, model routers and model assessment tools. Each can be useful, but without structure the workstation can quickly become messy, fragile or easy to abandon.

The risk is building a novelty stack:

```text
Interesting for a few weeks.
Hard to maintain.
Hard to rebuild.
Hard to remember.
Easy to replace with ChatGPT, Claude, Codex or Gemini.
```

I want to avoid that outcome.

---

## The goal

The goal is to build a durable AI workstation foundation.

I want the system to help me answer:

- What models can this machine run well?
- Which provider should this task use?
- Should this stay local or escalate to a frontier model?
- Which tools are part of the standard build?
- What is experimental?
- What is replaceable?
- How do I rebuild this on another machine?
- How do I keep the CLI as the primary workflow?
- How do I add future tools without redesigning everything?

---

## The direction

The direction for this project is:

```text
Open-source-first, CLI-native, gateway-first, composable, rebuildable AI Dev Workstation.
```

This means I want to:

- use open-source tools where practical
- keep the CLI as a first-class interface
- route model access through a gateway where possible
- prefer local models by default
- allow frontier escalation when justified
- keep providers and tools replaceable
- define behaviour in configuration
- make the environment rebuildable from code
- document decisions as the project evolves

---

## Why gateway-first

The gateway is the control plane.

Instead of every tool calling a specific model or provider directly, I want tools to call a common gateway where practical.

This makes it possible to change:

- local runtime
- model provider
- default model
- fallback behaviour
- escalation policy
- cost controls
- routing rules

without changing the workflows I build around.

For example:

```text
ask-ai
dev-ai
architect-ai
write-ai
Open WebUI
coding tools
agents
```

should not need to care whether the task is handled by Ollama, oMLX, Gemini, Anthropic, OpenAI or a future provider.

---

## Why CLI-native

The CLI is the primary interface because it matches how I prefer to work.

I already spend time in CLI-based AI workflows, particularly with tools such as Claude Code. This workstation should build on that habit rather than force a new one.

The principle is:

```text
If it is useful in the UI, it should also be possible from the CLI where practical.
```

The UI and IDE are important, but they should not become separate AI environments. They should sit on top of the same gateway, routing and configuration model.

---

## Why rebuildable

The workstation should not rely on undocumented machine state.

If I rebuild, replace or reset a laptop, I should be able to recover the environment from the repository with minimal manual effort.

This is especially important for atomic or ephemeral operating system patterns such as Fedora Silverblue or Fedora Atomic Desktop.

The repo should define:

- packages
- bootstrap scripts
- profiles
- services
- containers
- config
- tools
- validation checks
- documentation

The machine should be disposable. The repo should be the source of truth.

---

## Long-term target

The long-term target is a personal AI operating layer that supports:

- local model usage
- frontier escalation
- model routing
- CLI-first workflows
- Open WebUI parity
- IDE integration
- vibe coding
- project-aware development
- architecture support
- writing support
- research support
- model fitness review
- constrained agents
- future RAG and memory workflows

The system does not need to reach this state immediately. I want to build it in milestones, with each milestone adding durable capability.

---

## Success looks like

This project is successful if I start using it as my default local AI entry point.

Early success means:

```text
ask-ai becomes useful.
ai-status becomes trusted.
ai-route explains decisions.
llmfit informs model choices.
Open WebUI connects to the same gateway.
Coding tools can use the same provider layer.
```

Longer-term success means:

```text
The workstation becomes my normal way to access local AI, route complex tasks, test models, support coding, and prepare architecture or writing outputs.
```

---

## Guiding statement

Build the thing that helps me choose, route and govern AI usage first.

Then plug in coding, agents and workflows.
