# Model Fitness

This document defines how local models are assessed, selected and mapped for the AI Dev Workstation.

The goal is not to create a formal benchmark suite. The goal is to decide which local models are good enough for the real tasks this workstation needs to support.

The stable project interface is the gateway model group, not the specific local model behind it.

## Purpose

Model fitness helps decide which local model/runtime combinations should back gateway model groups such as:

- local-fast
- local-capable
- local-code

The model behind a gateway group can change over time without changing the daily CLI workflow.

## Documentation Boundary

Model fitness documentation should stay compact.

This document should contain durable decisions and current operating practice.

Issues can hold temporary investigation detail, test notes and working discussion.

Create additional model fitness documents only when there is a clear long-term maintenance reason.

## Gateway Model Groups

### local-fast

local-fast is for quick, low-friction assistance.

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
- avoids unnecessary complexity
- is useful enough for day-to-day terminal use

A model is not fit for local-fast if it is too slow, too verbose, frequently ignores simple instructions, or produces unreliable basic answers.

### local-capable

local-capable is for more involved local work.

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
- handles structured output
- recognises trade-offs
- avoids confident unsupported claims
- produces usable first drafts

A model is not fit for local-capable if it loses the thread quickly, produces shallow responses to complex prompts, or needs heavy correction before the output is useful.

### local-code

local-code is for development and command-line assistance.

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

All local models should be assessed against:

- instruction following
- usefulness
- accuracy
- groundedness
- proportionality
- safety and caution
- latency
- local suitability

A model does not need to be perfect to be useful. It needs to be good enough for the role it is being asked to perform.

## Unsuitable Model Signals

A model should not be selected for a gateway model group if it commonly:

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

## Runtime Candidates

### Ollama

Ollama is the current proven runtime behind LiteLLM.

Current proof path:

    just ask
      -> LiteLLM
      -> Ollama
      -> local model

Strengths:

- already working
- simple model management
- easy to integrate with LiteLLM
- broad model availability
- good baseline runtime

```text
MLX proof note:

- mlx-lm is installed in the project venv
- mlx-community/Qwen3-4B-4bit has been run locally
- MLX testing currently uses just ask-mlx directly
- MLX is not yet routed through LiteLLM
```

Considerations:

- may not always be the most Apple-silicon-optimised path
- runtime efficiency should be compared with MLX where practical

### MLX / mlx-lm

MLX / mlx-lm is a candidate runtime for Apple silicon.

Strengths:

- designed for Apple silicon
- direct access to MLX model builds
- strong candidate for efficient local inference on macOS
- useful comparison against Ollama on the same hardware

Considerations:

- not yet proven through this project's LiteLLM gateway path
- may need additional local setup
- operational workflow may be less simple than Ollama initially
- integration path needs to be decided before becoming a daily runtime

## Candidate Selection Criteria

Candidate models should be selected based on:

- target gateway model group
- expected quality for the role
- expected speed on Apple silicon
- memory footprint
- availability in Ollama or MLX format
- runtime maturity
- ease of operation
- whether the model adds useful diversity over already installed models
- whether testing it would inform a real project decision

Do not download models only because they are popular.

## Candidate Shortlist

Installed models are baselines, not the full test universe.

### Installed baseline candidates

| Candidate | Runtime | Target role | Status | Decision |
|---|---|---|---|---|
| llama3.2:3b | Ollama | local-fast | Installed | Baseline; keep as proven local-fast reference |
| llama3.1:8b | Ollama | local-capable | Installed | Baseline; test as stronger general model |
| mistral:7b | Ollama | local-capable | Installed | Baseline; test if time allows |
| qwen3.5:latest | Ollama | local-capable / local-code | Installed | Baseline; test as likely stronger reasoning/code candidate |
| mistral:latest | Ollama | local-capable | Installed | Likely duplicate/older baseline; review for decommissioning |
| nomic-embed-text:latest | Ollama | embeddings | Installed | Not a chat candidate; keep only if embedding/RAG work needs it later |

### First-pass additional candidates

| Candidate | Runtime | Target role | Status | Decision |
|---|---|---|---|---|
| Qwen3 4B MLX quant | MLX / mlx-lm | local-fast / local-capable | Installed/proven| Select for first-pass MLX comparison on Apple silicon |
| Qwen3 Coder practical local variant | MLX or Ollama | local-code | Not installed | Select only if a realistic local-size candidate is available |
| Qwen3 8B MLX quant | MLX / mlx-lm | local-capable | Not installed | Park until 4B result shows whether MLX is worth expanding |
| Gemma 3 4B Ollama or MLX | Ollama / MLX | local-fast / local-capable | Not installed | Park unless Qwen candidates disappoint |

### Selection rules

- Download at most two additional candidates before the first test pass.
- Do not download models only because they are popular.
- Do not download models that are clearly too large for the hardware.
- Installed Ollama models are baselines, not the final answer.
- MLX candidates are included because the primary workstation is Apple silicon.
- A model must have a target role before it is installed.
- Models that are rejected, duplicate or obsolete should be removed later through the decommissioning workflow.

## Hardware-Aware Candidate Selection

Tool evaluated:

- llmfit

Decision:

- Accepted as the hardware-aware candidate discovery tool for the model fitness loop.

Detected hardware:

- CPU: Apple M4 Pro, 14 cores
- RAM: 48 GB unified memory
- Available RAM during test: approximately 38 GB
- Backend: Metal
- GPU: Apple M4 Pro unified memory

Observed recommendation pattern:

- MLX is the dominant recommended runtime for this hardware.
- 3B–4B MLX models are strong candidates for local-fast.
- 9B–15B MLX models are strong candidates for local-capable.
- Qwen3-Coder-30B-A3B appears to be a strong local-code candidate, subject to install and prompt testing.
- 22B–30B reasoning/distill models fit the hardware but should not be installed blindly.

First-pass candidate shortlist:

| Role | Candidate | Runtime | Reason | Status |
|---|---|---|---|---|
| local-fast | mlx-community/Llama-3.2-3B-Instruct-4bit | MLX | Fast, low memory, comparable to current Ollama baseline | Shortlisted |
| local-fast | unsloth/Qwen3-4B-Instruct-2507-unsloth-bnb-4bit | MLX | Fast 4B Qwen candidate with long context | Alternate |
| local-capable | microsoft/Phi-4-reasoning | MLX | Strong reasoning candidate with reasonable memory use | Shortlisted |
| local-capable | Jackrong/MLX-Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit | MLX | Faster 9B reasoning/distill option | Alternate |
| local-code | lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-8bit | MLX | Code-focused candidate with strong estimated throughput | Shortlisted |

Selection rule:

- Install at most one candidate per role for the first pass.
- Keep installed Ollama models as baselines.
- Do not install large reasoning/distill models unless smaller candidates fail to meet the role.

## Test Prompt Set

Use this minimum prompt set for first-pass testing.

### Prompt 1: Quick general assistance

    In three bullets, explain what this AI workstation is trying to achieve: local-first, gateway-first, CLI-native.

### Prompt 2: Short summary

    Summarise this in four bullets: LiteLLM is being used as the local AI gateway. The daily CLI workflow uses just recipes. The local-fast model group currently routes to Ollama. The project avoids custom wrappers unless there is a clear need.

### Prompt 3: Command-line help

    Explain what this command does, including any risks: podman rm -f ai-lab-litellm >/dev/null 2>&1 || true

### Prompt 4: Troubleshooting

    LiteLLM starts in a Podman container, but curl to localhost:4000 immediately returns "connection reset by peer". The container is still starting. What is the likely cause and what small change should I make to the justfile?

### Prompt 5: Code/config review

    Review this just recipe line and explain what might go wrong: curl -fsS "$gateway_url/v1/chat/completions" -d "{model: local-fast, messages: [{role: user, content: $prompt}]}"

### Prompt 6: Unsuitable model signal

    A local model gives fast responses but often ignores requested structure, invents project files, and produces broken shell commands. Which gateway model group should it be used for, if any?

## Test Method

Start the local gateway:

    export LITELLM_MASTER_KEY=sk-local-dev
    just ai-up
    just ai-check

Run each prompt with:

    just ask "PROMPT TEXT HERE"

For each candidate model, record:

- model name
- runtime
- gateway model group tested
- prompt result
- strengths
- weaknesses
- latency notes
- suitability recommendation

Recommended prompt result categories:

- pass
- partial
- fail

Recommended suitability decisions:

- accepted
- accepted with caveats
- rejected
- parked for later
- needs more testing

## Current Test Results

| Model | Runtime | local-fast | local-capable | local-code | Decision |
|---|---|---|---|---|---|
| llama3.2:3b | Ollama | Pending | Pending | Pending | Baseline |
| llama3.1:8b | Ollama | Pending | Pending | Pending | Test |
| mistral:7b | Ollama | Pending | Pending | Pending | Test |
| qwen3.5:latest | Ollama | Pending | Pending | Pending | Test |
| Qwen3 4B MLX quant | MLX | Pending | Pending | Pending | Consider download |
| Qwen3 Coder MLX quant | MLX | Pending | Pending | Pending | Consider download |

## Current Model Group Decisions

| Gateway model group | Current backend | Decision status | Notes |
|---|---|---|---|
| local-fast | llama3.2:3b via Ollama | Provisional baseline | Proven through LiteLLM; compare against Qwen3 4B MLX |
| local-capable | Not assigned | Pending | Compare installed 8B/general candidates and selected MLX candidate |
| local-code | Not assigned | Pending | Identify practical Qwen/code-focused local candidate before install |

## Review Triggers

Review model fitness decisions when:

- a model performs poorly in daily use
- a better local candidate becomes available
- hardware changes
- runtime support improves
- gateway model groups change
- local-fast, local-capable or local-code no longer match their intended roles

## Model Lifecycle and Decommissioning

The model fitness loop should prevent local model sprawl.

Models should not remain installed simply because they were tested once. Each model should have a lifecycle state and a reason for being kept.

### Lifecycle States

| State | Meaning | Keep installed? |
|---|---|---|
| active | Backs a stable gateway model group such as local-fast, local-capable or local-code | Yes |
| baseline | Installed reference model used for comparison | Yes, while useful |
| candidate | Currently being tested for a defined role | Yes, temporarily |
| parked | Not currently used, but kept for a specific reason | Maybe |
| rejected | Tested or reviewed and not suitable | No |
| duplicate | Functionally overlaps another installed model without adding value | No |
| obsolete | Replaced by a better model/runtime choice | No |

### Keep Rules

Keep a model installed when:

- it backs an active gateway model group
- it is being tested as a current candidate
- it is a useful baseline for comparison
- it is deliberately parked with a clear reason

Do not keep a model installed when:

- it failed model fitness testing
- it duplicates another installed model
- it has been replaced by a better candidate
- it is not attached to a current or future use case
- it was installed only for curiosity

### Active Model Safety Check

Before removing a model, check whether it is referenced by the local gateway config.

Check the LiteLLM config:

    grep -n "ollama/" config/gateway/litellm/config.local.yaml

Check installed Ollama models:

    ollama list

Do not remove a model if it backs:

- local-fast
- local-capable
- local-code
- an active candidate alias still being tested

### Ollama Decommissioning

Remove an unused Ollama model with:

    ollama rm <model-name>

Example:

    ollama rm mistral:latest

After removing a model, confirm the remaining local models:

    ollama list

Then restart and check the gateway if any aliases changed:

    just ai-down
    just ai-up
    just ai-check

### MLX Decommissioning

MLX decommissioning is not fully defined yet.

Until the MLX runtime path is proven, MLX cleanup should be handled carefully based on the actual installation method used.

Do not add broad cache deletion commands until the project has confirmed where selected MLX models are installed and how they are referenced.

### Current Decommissioning Review

| Model | Runtime | Current state | Action |
|---|---|---|---|
| llama3.2:3b | Ollama | active / baseline | Keep |
| llama3.1:8b | Ollama | baseline / candidate | Keep for testing |
| mistral:7b | Ollama | baseline / candidate | Keep for testing |
| qwen3.5:latest | Ollama | baseline / candidate | Keep for testing |
| mistral:latest | Ollama | likely duplicate / obsolete | Review for removal |
| nomic-embed-text:latest | Ollama | parked | Keep only if embedding/RAG work is expected later |

Initial likely decommissioning candidate:

    mistral:latest

Reason:

- older than mistral:7b in the current local model list
- likely overlaps with the installed mistral:7b baseline
- does not currently back a gateway model group

## Out of Scope

This model fitness loop does not currently include:

- automated benchmarking
- public leaderboard comparison
- frontier model evaluation
- RAG evaluation
- agent evaluation
- semantic routing
- cost routing
- provider fallback behaviour
