# Local Model and Runtime Candidates

## Purpose

This document records candidate local model/runtime combinations for the AI Dev Workstation.

The goal is to choose a small set of models to test before downloading large numbers of models.

This document supports the model fitness loop:

- define criteria
- define prompts
- shortlist candidates
- test selected candidates
- decide gateway model group mappings

The stable project interface is the gateway model group, not the specific model behind it.

## Hardware and Profile Context

Primary current profile:

- macos-work

Primary current hardware/runtime context:

- Apple silicon Mac
- Podman for gateway runtime
- LiteLLM as gateway
- Ollama already proven behind LiteLLM
- MLX / mlx-lm is a candidate runtime for Apple silicon

Secondary/future profile context:

- windows-personal
- fedora-atomic

This candidate set is initially focused on the macOS Apple silicon workstation.

## Runtime Candidates

### Ollama

Ollama is already proven in this project.

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
- model packaging and quantisation choices are abstracted
- runtime efficiency should be compared with MLX where practical

### MLX / mlx-lm

MLX is a candidate runtime for Apple silicon.

MLX LM is a Python package for generating text and fine-tuning large language models on Apple silicon with MLX. It supports Hugging Face Hub integration and quantisation workflows.

Strengths:

- designed for Apple silicon
- direct access to MLX model builds
- strong candidate for efficient local inference on macOS
- useful for comparing against Ollama on the same hardware

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

## Gateway Model Groups

The candidate model groups are:

- local-fast
- local-capable
- local-code

### local-fast

This group needs a fast, reliable model for daily terminal use.

Priority:

- speed
- concise responses
- basic instruction following
- low operational friction

### local-capable

This group needs a stronger local model for more involved reasoning and drafting.

Priority:

- quality
- coherence
- structured responses
- useful trade-off analysis

### local-code

This group needs a model that is useful for command-line, configuration and coding tasks.

Priority:

- command accuracy
- shell quoting awareness
- config reasoning
- safe troubleshooting
- small practical fixes

## Installed Baseline Candidates

Update this list from:

    ollama list

| Candidate | Runtime | Target role | Why consider it | Download status | Test status |
|---|---|---|---|---|---|
| llama3.2:3b | Ollama | local-fast | Already proven through LiteLLM as the first local-fast backend | Installed | Pending |
| llama3.1:8b | Ollama | local-capable | Already installed; likely stronger than the 3B baseline | Installed | Pending |
| mistral:7b | Ollama | local-capable | Already installed; useful general baseline | Installed | Pending |
| mistral:latest | Ollama | local-capable | Already installed; may duplicate mistral:7b and should be checked | Installed | Pending |
| qwen3.5:latest | Ollama | local-capable / local-code | Already installed; likely useful for reasoning or code-oriented tasks | Installed | Pending |

Do not test embedding-only models as chat candidates.

## Additional Candidate Shortlist

This shortlist is intentionally small.

| Candidate | Runtime | Target role | Why consider it | Download decision | Test status |
|---|---|---|---|---|---|
| Qwen3 4B MLX quant | MLX | local-fast / local-capable | Apple silicon optimised candidate; useful comparison against llama3.2:3b and llama3.1:8b | Consider | Not downloaded |
| Qwen3 8B MLX quant | MLX | local-capable | Stronger Apple silicon candidate for reasoning and structured output | Consider | Not downloaded |
| Qwen3 Coder MLX quant | MLX | local-code | Coding-focused Apple silicon candidate | Consider | Not downloaded |
| Gemma 3 4B Ollama or MLX | Ollama / MLX | local-fast / local-capable | Lightweight candidate with broad availability | Consider | Not downloaded |

## Initial Download Rule

Download at most two additional candidates before the first test pass.

Recommended first additional candidates:

1. Qwen3 4B MLX quant
2. Qwen3 Coder MLX quant

Rationale:

- they test MLX as an Apple silicon runtime
- they map to different roles
- they avoid downloading many large models
- they provide useful comparison against installed Ollama models

## Candidate Decisions

| Candidate | Decision | Reason |
|---|---|---|
| llama3.2:3b | Baseline | Already proven as local-fast backend |
| llama3.1:8b | Test | Already installed and likely useful |
| mistral:7b | Test | Already installed baseline |
| mistral:latest | Check duplicate | May duplicate mistral:7b |
| qwen3.5:latest | Test | Already installed and likely useful |
| Qwen3 4B MLX quant | Consider download | Tests MLX efficiency for fast/capable role |
| Qwen3 8B MLX quant | Park initially | Consider after 4B result |
| Qwen3 Coder MLX quant | Consider download | Tests MLX for local-code role |
| Gemma 3 4B | Park initially | Useful later if first candidates disappoint |

## References

- MLX LM is designed for running LLMs on Apple silicon with MLX and integrates with Hugging Face Hub.
- The MLX Community on Hugging Face hosts ready-to-use MLX model builds.
- Ollama remains the current proven runtime behind LiteLLM in this project.

## Next Step

After this candidate shortlist is agreed:

1. confirm installed Ollama models
2. check whether mistral:latest duplicates mistral:7b
3. select up to two additional MLX candidates
4. install only selected candidates
5. run the minimum prompt set
6. record results in docs/model-fitness/results/
