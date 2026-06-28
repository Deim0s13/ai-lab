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

Installed baseline candidates:

| Candidate | Runtime | Target role | Status | Notes |
|---|---|---|---|---|
| llama3.2:3b | Ollama | local-fast | Installed | Current local-fast proof backend |
| llama3.1:8b | Ollama | local-capable | Installed | Stronger installed baseline |
| mistral:7b | Ollama | local-capable | Installed | General baseline |
| mistral:latest | Ollama | local-capable | Installed | Check whether this duplicates mistral:7b |
| qwen3.5:latest | Ollama | local-capable / local-code | Installed | Candidate for reasoning or code-oriented tasks |

Do not test embedding-only models as chat candidates.

Additional candidates to consider before download:

| Candidate | Runtime | Target role | Status | Notes |
|---|---|---|---|---|
| Qwen3 4B MLX quant | MLX | local-fast / local-capable | Consider | Tests MLX efficiency for fast/capable role |
| Qwen3 Coder MLX quant | MLX | local-code | Consider | Tests MLX for code-oriented role |
| Qwen3 8B MLX quant | MLX | local-capable | Parked | Consider after smaller MLX candidate |
| Gemma 3 4B Ollama or MLX | Ollama / MLX | local-fast / local-capable | Parked | Useful later if first candidates disappoint |

Initial rule:

Download at most two additional candidates before the first test pass.

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
| local-fast | llama3.2:3b via Ollama | Provisional | Proven through LiteLLM; still needs fitness comparison |
| local-capable | Not assigned | Pending | To be decided after testing |
| local-code | Not assigned | Pending | To be decided after testing |

## Review Triggers

Review model fitness decisions when:

- a model performs poorly in daily use
- a better local candidate becomes available
- hardware changes
- runtime support improves
- gateway model groups change
- local-fast, local-capable or local-code no longer match their intended roles

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
