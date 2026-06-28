# Model Fitness Criteria

## Purpose

Model fitness defines whether a local model is good enough for a specific workstation role.

The project should not choose models based only on popularity, benchmark claims or subjective impressions. Models should be assessed against practical tasks that reflect how the AI Dev Workstation will actually be used.

The goal is a lightweight, repeatable decision process.

## Principles

Model fitness should be:

- practical rather than academic
- repeatable without a large benchmark framework
- based on real workstation tasks
- clear enough to support model replacement
- lightweight enough to run manually
- aligned to the gateway-first architecture

The stable interface is the gateway model group. The local model behind that group can change over time.

## Gateway Model Groups

The current local gateway model groups are:

- local-fast
- local-capable
- local-code

Each group has a different role and should be assessed differently.

## local-fast

local-fast is for quick, low-friction assistance.

It should be used when speed and convenience matter more than deep reasoning.

Typical tasks:

- short answers
- quick explanations
- simple rewrites
- command reminders
- lightweight summaries
- small planning prompts

Fitness criteria:

- responds quickly
- follows simple instructions
- gives concise answers when asked
- handles basic CLI and developer questions
- avoids excessive rambling
- does not invent unnecessary complexity
- is useful enough for day-to-day terminal use

A model is not fit for local-fast if it is too slow, too verbose, frequently ignores simple instructions, or produces unreliable basic answers.

## local-capable

local-capable is for more involved local work.

It should be used when the task needs better reasoning, more context handling or more careful explanation than local-fast.

Typical tasks:

- multi-step explanations
- structured planning
- comparing options
- summarising longer notes
- drafting technical documentation
- reviewing proposed changes
- explaining trade-offs

Fitness criteria:

- follows multi-step instructions
- maintains coherence across a longer response
- explains reasoning at a useful level
- handles structured output
- recognises trade-offs
- asks for clarification only when genuinely needed
- avoids confident unsupported claims
- produces usable first drafts

A model is not fit for local-capable if it loses the thread quickly, produces shallow responses to complex prompts, or needs heavy correction before the output is useful.

## local-code

local-code is for development and command-line assistance.

It should be used when the task involves code, configuration, scripts or troubleshooting.

Typical tasks:

- explain shell commands
- suggest small scripts
- review config files
- explain errors
- create simple tests
- reason about repository structure
- help with YAML, Markdown, Python, shell and GitHub CLI commands

Fitness criteria:

- produces syntactically plausible code
- explains commands accurately
- avoids destructive commands unless explicitly requested
- handles shell quoting carefully
- respects existing project conventions
- suggests small changes rather than large rewrites
- can reason about config and file structure
- can identify likely causes of common errors

A model is not fit for local-code if it frequently produces broken commands, unsafe changes, invalid syntax, or large unnecessary rewrites.

## General Assessment Criteria

All local models should be assessed against these criteria:

### Instruction following

The model should follow the actual request, including constraints such as brevity, format, tone and scope.

### Usefulness

The response should help the user move forward without requiring major correction.

### Accuracy

The response should avoid obvious factual, technical or procedural errors.

### Groundedness

The model should avoid inventing project facts that are not present in the prompt or known configuration.

### Proportionality

The response should match the size of the task. Small tasks should receive small answers.

### Safety and caution

The model should avoid risky, destructive or inappropriate actions unless the user clearly requests them and the action is valid.

### Latency

The model should be fast enough for its intended role.

local-fast has the highest latency expectation. local-capable and local-code may be slower if the output quality is materially better.

### Local suitability

The model should be useful locally without requiring frontier escalation for routine work.

## Unsuitable Model Signals

A model should not be selected for a gateway model group if it commonly shows any of these behaviours:

- ignores the prompt
- produces broken commands
- invents files, tools or project decisions
- gives overly generic answers
- rambles when asked to be concise
- cannot handle simple structured output
- makes unsafe assumptions
- fails basic coding/configuration tasks
- is too slow for the intended role
- requires repeated correction for routine tasks

## Recording Results

Each model test should record:

- model name
- local runtime
- gateway model group tested
- test date
- test prompt or prompt set
- observed strengths
- observed weaknesses
- latency notes
- suitability recommendation
- final decision

Recommended decisions:

- accepted
- accepted with caveats
- rejected
- parked for later
- needs more testing

## Decision Rule

A model does not need to be perfect to be useful.

The decision should be based on whether the model is good enough for the role it is being asked to perform.

A smaller, faster model may be better for local-fast even if a larger model produces better answers.

A slower model may be better for local-capable or local-code if it materially improves quality.

## Out of Scope

This criteria document does not define:

- automated benchmarking
- public leaderboard comparison
- frontier model evaluation
- RAG evaluation
- agent evaluation
- cost routing
- semantic routing
- provider fallback behaviour

Those may be considered in later milestones.
