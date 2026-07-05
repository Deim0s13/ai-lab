# Model Fitness

This document defines how local models are assessed, selected, tested, promoted and decommissioned for the AI Dev Workstation.

The goal is not to create a formal benchmark suite. The goal is to maintain a practical model fitness loop so the workstation runs models that are well suited to the hardware, use cases and gateway roles.

The stable project interface is the gateway model group, not the specific model behind it.

## Purpose

Model fitness helps decide which local model/runtime combinations should back these gateway model groups:

- local-fast
- local-capable
- local-code

The model behind a gateway group can change over time without changing the daily CLI workflow.

## Documentation Boundary

This document should stay compact and durable.

It should contain:

- current model fitness criteria
- current candidate shortlist
- current testing approach
- current model group decisions
- current decommissioning rules

Temporary investigation detail, raw test output and working discussion should stay in GitHub issues or local scratch files.

Create additional model fitness documents only when there is a clear long-term maintenance reason.

## Model Fitness Loop

The intended loop is:

1. Detect hardware and identify suitable model candidates.
2. Apply project role criteria.
3. Install only selected candidates.
4. Test selected candidates against workstation prompts.
5. Promote winners into gateway model groups.
6. Park, reject or decommission models that are not useful.
7. Re-run the process periodically.

## Gateway Model Groups

### local-fast

local-fast is for quick, low-friction daily assistance.

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
- gateway compatibility, if the model is intended to back a gateway route

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
- cannot return usable content through the intended gateway path

## Runtime Position

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
- installed Ollama models should be treated as baselines, not the full candidate universe
- runtime efficiency should be compared with MLX where practical

### MLX / mlx-lm

MLX / mlx-lm is the current Apple silicon runtime candidate.

Direct proof path:

    just ask-mlx
      -> mlx-lm
      -> MLX model

Gateway proof path:

    LiteLLM
      -> OpenAI-compatible route
      -> mlx-lm server
      -> MLX model

Strengths:

- designed for Apple silicon
- direct access to MLX model builds
- strong candidate for efficient local inference on macOS
- can be exposed to LiteLLM through `mlx-lm server`

Considerations:

- `mlx-lm server` is suitable here as a local workstation service only
- `mlx-lm server` should not be exposed beyond the local workstation without further security review
- each selected MLX model must be checked through the gateway path before being promoted
- direct `mlx_lm generate` success does not guarantee gateway compatibility

Current MLX proof status:

- mlx-lm is installed in the project virtual environment
- direct MLX testing works through `just ask-mlx`
- gateway-routed MLX testing works through `mlx-lm server` and LiteLLM for selected routes
- lifecycle recipes exist for starting, checking and stopping MLX servers:
  - `just mlx-up`
  - `just mlx-check`
  - `just mlx-down`

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

- MLX is the dominant recommended runtime for this Apple silicon workstation.
- 3B-4B MLX instruction models are strong candidates for local-fast.
- larger non-reasoning MLX instruction models are strong candidates for local-capable.
- Qwen3-Coder-30B-A3B MLX variants appear to be strong local-code candidates.
- Raw tokens-per-second sorting is not sufficient because it surfaces tiny, random, internal-test and embedding models.
- Project criteria must filter llmfit results before install.
- Reasoning-style models require additional gateway compatibility checks because some return reasoning-only output instead of normal assistant content.

Selection rules:

- Install at most one candidate per role for the first pass.
- Keep installed Ollama models as baselines.
- Do not install tiny-random, internal-testing or embedding-only models as chat candidates.
- Do not install large reasoning/distill models just because they top the score table.
- Use llmfit for hardware-aware discovery, then apply project role criteria before installation.
- For gateway-backed routes, prefer models that return normal assistant content in `message.content`.

## Installed Baselines

Installed Ollama models are baselines, not the full test universe.

| Candidate               | Runtime | Target role                | Status    | Decision                                                             |
| ----------------------- | ------- | -------------------------- | --------- | -------------------------------------------------------------------- |
| llama3.2:3b             | Ollama  | local-fast                 | Installed | Baseline; proven behind LiteLLM                                      |
| llama3.1:8b             | Ollama  | local-capable              | Installed | Baseline; test as stronger general model                             |
| mistral:7b              | Ollama  | local-capable              | Installed | Baseline; test if useful                                             |
| qwen3.5:latest          | Ollama  | local-capable / local-code | Installed | Baseline; test as reasoning/code candidate                           |
| mistral:latest          | Ollama  | local-capable              | Installed | Likely duplicate or older baseline; review for decommissioning       |
| nomic-embed-text:latest | Ollama  | embeddings                 | Installed | Not a chat candidate; keep only if embedding/RAG work needs it later |

## Selected MLX Candidates

These candidates were selected through llmfit output plus project role criteria.

| Role                   | Candidate                                                           | Runtime | Reason                                                                                                                    | Status                                             |
| ---------------------- | ------------------------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| local-fast             | mlx-community/Llama-3.2-3B-Instruct-4bit                            | MLX     | Fast, low memory, comparable to current Ollama llama3.2:3b baseline                                                       | Installed; direct MLX proven; gateway route proven |
| local-fast alternate   | unsloth/Qwen3-4B-Instruct-2507-unsloth-bnb-4bit                     | MLX     | Fast Qwen 4B candidate with long context                                                                                  | Not installed; alternate                           |
| local-capable          | lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit             | MLX     | Non-reasoning instruct model selected after reasoning models returned reasoning-only/null content through `mlx-lm server` | Installed; gateway route proven                    |
| local-capable parked   | Jackrong/MLX-Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit | MLX     | Strong direct-generation candidate, but returns reasoning-only/null content through `mlx-lm server`                       | Parked for direct use only                         |
| local-capable rejected | microsoft/Phi-4-reasoning                                           | MLX     | Server starts, but returns reasoning-only output through `mlx-lm server`                                                  | Rejected for gateway route                         |
| local-code             | lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit            | MLX     | Code-focused candidate with strong estimated throughput                                                                   | Installed; direct MLX proven; gateway route proven |
| local-code alternate   | unsloth/Qwen3-Coder-30B-A3B-Instruct                                | MLX     | Same code-focused family; use if easier to install/run                                                                    | Not installed; alternate                           |

## MLX Gateway Routing

MLX gateway routing has been proven using `mlx-lm server` as an OpenAI-compatible backend behind LiteLLM.

Accepted routing pattern:

    LiteLLM
      -> OpenAI-compatible route
      -> mlx-lm server
      -> MLX model

Current route status:

| Gateway route     | Backend model                                            | Runtime               | Port | Status |
| ----------------- | -------------------------------------------------------- | --------------------- | ---- | ------ |
| local-fast-mlx    | mlx-community/Llama-3.2-3B-Instruct-4bit                 | MLX via mlx-lm server | 8080 | Proven |
| local-capable-mlx | lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit  | MLX via mlx-lm server | 8081 | Proven |
| local-code-mlx    | lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit | MLX via mlx-lm server | 8082 | Proven |

Decision:

Use non-reasoning MLX instruction models for gateway-backed capable routes unless reasoning-field handling is explicitly added later.

Gateway-backed MLX candidates must return usable assistant content in `message.content`. Reasoning-only output is not sufficient, even when the server starts and the model generates text.

Security note:

`mlx-lm server` is suitable here as a local workstation service only. It should not be exposed beyond the local workstation without further security review.

### MLX Gateway Compatibility Finding

Direct `mlx_lm generate` success is not sufficient to promote a model into a gateway-backed route.

A model must also return usable OpenAI-compatible chat content through `mlx-lm server` and LiteLLM.

Finding:

| Model                                                               | Direct MLX generation | mlx-lm server route              | LiteLLM route                  | Decision                                                             |
| ------------------------------------------------------------------- | --------------------- | -------------------------------- | ------------------------------ | -------------------------------------------------------------------- |
| Jackrong/MLX-Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit | Works                 | Returns reasoning-only output    | `message.content` is null      | Park for direct use only; do not use as gateway-backed local-capable |
| microsoft/Phi-4-reasoning                                           | Server starts         | Returns reasoning-only output    | `message.content` is null      | Reject as gateway-backed local-capable                               |
| lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit             | Works                 | Returns normal assistant content | `message.content` is populated | Use as gateway-backed local-capable candidate                        |

Reason:

Some reasoning-style MLX models return reasoning fields such as `reasoning` / `reasoning_content`, but do not populate the normal OpenAI-compatible `message.content` field. This makes them unsuitable as LiteLLM-backed gateway routes without additional adaptation.

The working `local-capable-mlx` route is:

    lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit

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

Start the local gateway for Ollama-backed testing:

    export LITELLM_MASTER_KEY=sk-local-dev
    just ai-up
    just ai-check

Run Ollama/LiteLLM candidates with promptfoo:

    just eval-model-fitness

Run direct MLX candidates with the project MLX eval script:

    just eval-model-fitness-mlx

Run gateway-routed MLX candidates by starting the MLX servers and LiteLLM gateway:

    export LITELLM_MASTER_KEY=sk-local-dev
    just mlx-up
    just mlx-check
    just ai-up

For each candidate model, record:

- model name
- runtime
- intended gateway role
- prompt result
- strengths
- weaknesses
- latency notes
- gateway compatibility notes
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

| Model                                                               | Runtime            | Intended role                       | Prompt result                                                                              | Decision                                                               |
| ------------------------------------------------------------------- | ------------------ | ----------------------------------- | ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| llama3.2:3b                                                         | Ollama via LiteLLM | local-fast baseline                 | 6/6 ran successfully through promptfoo                                                     | Keep as baseline; quality caveats                                      |
| llama3.1:8b                                                         | Ollama via LiteLLM | local-capable baseline              | 6/6 ran successfully through promptfoo                                                     | Keep as baseline; compare                                              |
| qwen3.5:latest                                                      | Ollama via LiteLLM | local-capable / local-code baseline | 6/6 ran successfully through promptfoo                                                     | Stronger but slower; compare carefully                                 |
| mlx-community/Llama-3.2-3B-Instruct-4bit                            | MLX                | local-fast                          | 6/6 ran successfully through direct MLX eval; gateway route proven                         | Strong candidate for local-fast                                        |
| Jackrong/MLX-Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit | MLX                | local-capable                       | 6/6 ran successfully through direct MLX eval; gateway route returns null `message.content` | Park for direct use only; not suitable as gateway-backed local-capable |
| microsoft/Phi-4-reasoning                                           | MLX                | local-capable                       | Server starts; returns reasoning-only output and null `message.content`                    | Reject as gateway-backed local-capable                                 |
| lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit             | MLX                | local-capable                       | Gateway route proven through `mlx-lm server` and LiteLLM                                   | Strong candidate for local-capable                                     |
| lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit            | MLX                | local-code                          | 6/6 ran successfully through direct MLX eval; gateway route proven                         | Strong candidate for local-code                                        |

Notes:

- promptfoo is used for LiteLLM/Ollama gateway-backed model fitness testing.
- Direct MLX testing uses `just eval-model-fitness-mlx`.
- A promptfoo Python provider for MLX was attempted but parked because it caused macOS Python crash dialogs and noisy/unstable provider behaviour.
- MLX gateway routing now uses `mlx-lm server` behind LiteLLM.
- Results currently confirm execution, first-pass usefulness and gateway compatibility status.
- Stable model group promotion should happen only after the selected backend is both useful and gateway-routable.

## Current Model Group Decisions

| Gateway model group | Provisional selected model                               | Runtime | Proven path                                 | Active gateway route status                                      | Decision status    |
| ------------------- | -------------------------------------------------------- | ------- | ------------------------------------------- | ---------------------------------------------------------------- | ------------------ |
| local-fast          | mlx-community/Llama-3.2-3B-Instruct-4bit                 | MLX     | direct MLX and LiteLLM via `local-fast-mlx` | Candidate route proven; stable `local-fast` not yet repointed    | Provisional winner |
| local-capable       | lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit  | MLX     | LiteLLM via `local-capable-mlx`             | Candidate route proven; stable `local-capable` not yet repointed | Provisional winner |
| local-code          | lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit | MLX     | direct MLX and LiteLLM via `local-code-mlx` | Candidate route proven; stable `local-code` not yet repointed    | Provisional winner |

Routing note:

The selected model and active route are related but separate.

- selected model = the preferred model for the role
- active route = the model currently reachable through the gateway-backed daily workflow

The `*-mlx` routes are proven candidate routes. The stable route names `local-fast`, `local-capable` and `local-code` should only be repointed after the daily workflow has been tested using the MLX lifecycle recipes.

## Model Lifecycle and Decommissioning

The model fitness loop should prevent local model sprawl.

Models should not remain installed simply because they were tested once. Each model should have a lifecycle state and a reason for being kept.

### Lifecycle States

| State     | Meaning                                                                            | Keep installed?   |
| --------- | ---------------------------------------------------------------------------------- | ----------------- |
| active    | Backs a stable gateway model group such as local-fast, local-capable or local-code | Yes               |
| baseline  | Installed reference model used for comparison                                      | Yes, while useful |
| candidate | Currently being tested for a defined role                                          | Yes, temporarily  |
| parked    | Not currently used, but kept for a specific reason                                 | Maybe             |
| rejected  | Tested or reviewed and not suitable                                                | No                |
| duplicate | Functionally overlaps another installed model without adding value                 | No                |
| obsolete  | Replaced by a better model/runtime choice                                          | No                |

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
    grep -n "openai/" config/gateway/litellm/config.local.yaml

Check installed Ollama models:

    ollama list

Check MLX server routes:

    just mlx-check

Do not remove a model if it backs:

- local-fast
- local-capable
- local-code
- an active candidate alias still being tested
- a proven `*-mlx` candidate route still under evaluation

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

Until the MLX runtime path is promoted, MLX cleanup should be handled carefully based on the actual installation method used.

Do not add broad cache deletion commands until the project has confirmed where selected MLX models are installed and how they are referenced.

### Current Decommissioning Review

| Model                                                               | Runtime | Current state                   | Action                                                         |
| ------------------------------------------------------------------- | ------- | ------------------------------- | -------------------------------------------------------------- |
| llama3.2:3b                                                         | Ollama  | active / baseline               | Keep                                                           |
| llama3.1:8b                                                         | Ollama  | baseline / candidate            | Keep for testing                                               |
| mistral:7b                                                          | Ollama  | baseline / candidate            | Keep for testing                                               |
| qwen3.5:latest                                                      | Ollama  | baseline / candidate            | Keep for testing                                               |
| mistral:latest                                                      | Ollama  | likely duplicate / obsolete     | Review for removal                                             |
| nomic-embed-text:latest                                             | Ollama  | parked                          | Keep only if embedding/RAG work is expected later              |
| mlx-community/Llama-3.2-3B-Instruct-4bit                            | MLX     | candidate; gateway route proven | Keep for testing                                               |
| Jackrong/MLX-Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit | MLX     | parked for direct use only      | Keep only if direct testing remains useful                     |
| microsoft/Phi-4-reasoning                                           | MLX     | rejected for gateway route      | Remove unless needed for further reasoning-model investigation |
| lmstudio-community/Qwen3-30B-A3B-Instruct-2507-MLX-4bit             | MLX     | candidate; gateway route proven | Keep for testing                                               |
| lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit            | MLX     | candidate; gateway route proven | Keep for testing                                               |

Initial likely decommissioning candidate:

    mistral:latest

Reason:

- older than mistral:7b in the current local model list
- likely overlaps with the installed mistral:7b baseline
- does not currently back a gateway model group

## Review Triggers

Review model fitness decisions when:

- a model performs poorly in daily use
- llmfit identifies a better hardware-fit candidate
- a better local candidate becomes available
- hardware changes
- runtime support improves
- gateway model groups change
- local-fast, local-capable or local-code no longer match their intended roles
- a direct MLX candidate fails gateway compatibility
- `mlx-lm server` behaviour changes after upgrades

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
