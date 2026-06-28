# Model Fitness Test Prompts

## Purpose

This document defines a lightweight set of prompts for testing local model fitness.

The goal is not to create a formal benchmark. The goal is to compare local models against realistic AI Dev Workstation tasks and decide which models are suitable for gateway model groups such as:

- local-fast
- local-capable
- local-code

The prompt set should be small enough to run manually and repeatable enough to compare results.

## How to Use These Prompts

Start the local gateway:

    export LITELLM_MASTER_KEY=sk-local-dev
    just ai-up
    just ai-check

Run each prompt with:

    just ask "PROMPT TEXT HERE"

Record observations using the model fitness criteria in:

    docs/model-fitness/criteria.md

For each model, record:

- model name
- runtime
- gateway model group tested
- prompt result
- strengths
- weaknesses
- latency notes
- suitability recommendation

## Scoring

Use simple judgement rather than numeric scoring.

Recommended result categories:

- pass
- partial
- fail

Recommended suitability decisions:

- accepted
- accepted with caveats
- rejected
- parked for later
- needs more testing

## Prompt Set

### Prompt 1: Quick general assistance

Purpose:

Test whether the model can give a concise, useful answer to a simple everyday workstation question.

Prompt:

    In three bullets, explain what this AI workstation is trying to achieve: local-first, gateway-first, CLI-native.

Expected qualities:

- concise
- clear
- no unnecessary architecture sprawl
- understands the three principles at a practical level

Best suited for:

- local-fast
- local-capable

### Prompt 2: Simple rewrite

Purpose:

Test whether the model can rewrite content clearly without overcomplicating it.

Prompt:

    Rewrite this so it is clearer and more direct: "The implementation of the gateway functionality has been completed and users can now utilise the command line interface to conduct model interactions."

Expected qualities:

- simpler language
- same meaning
- no added claims
- concise output

Best suited for:

- local-fast
- local-capable

### Prompt 3: Short summary

Purpose:

Test whether the model can summarise a short technical note.

Prompt:

    Summarise this in four bullets: LiteLLM is being used as the local AI gateway. The daily CLI workflow uses just recipes. The local-fast model group currently routes to Ollama. The project avoids custom wrappers unless there is a clear need.

Expected qualities:

- captures all key points
- does not add unsupported details
- keeps the structure requested
- no rambling

Best suited for:

- local-fast
- local-capable

### Prompt 4: Command-line help

Purpose:

Test whether the model can explain a shell command accurately and safely.

Prompt:

    Explain what this command does, including any risks: podman rm -f ai-lab-litellm >/dev/null 2>&1 || true

Expected qualities:

- explains forced container removal
- explains output redirection
- explains why || true is used
- mentions the risk of stopping/removing a running container
- does not exaggerate the risk

Best suited for:

- local-code
- local-capable

### Prompt 5: Shell quoting

Purpose:

Test whether the model can handle shell quoting and heredoc safety.

Prompt:

    I need to create a Markdown file from the shell using cat > file <<'EOF'. What is one common mistake to avoid when the Markdown content itself contains code fences?

Expected qualities:

- identifies nested heredoc/code fence copy-paste issues
- gives practical guidance
- does not produce an overly complex solution
- keeps answer focused

Best suited for:

- local-code
- local-capable

### Prompt 6: YAML/config reasoning

Purpose:

Test whether the model can reason about simple YAML configuration.

Prompt:

    This route class maps to a gateway model group. Explain what it means in plain English:

    route_classes:
      local_fast:
        type: local
        gateway_model_group: local-fast

Expected qualities:

- explains route class vs gateway model group
- does not claim a provider is directly selected
- mentions that execution is delegated to the gateway
- clear plain-English answer

Best suited for:

- local-code
- local-capable

### Prompt 7: Troubleshooting

Purpose:

Test whether the model can reason about a realistic gateway failure without jumping to conclusions.

Prompt:

    LiteLLM starts in a Podman container, but curl to localhost:4000 immediately returns "connection reset by peer". The container is still starting. What is the likely cause and what small change should I make to the justfile?

Expected qualities:

- identifies readiness/startup timing
- suggests wait/retry check
- avoids unnecessary architecture changes
- keeps fix small

Best suited for:

- local-code
- local-capable

### Prompt 8: Planning and trade-offs

Purpose:

Test whether the model can compare options without overengineering.

Prompt:

    Compare these options for the first ask command: a custom Python wrapper, a just recipe using curl and jq, or adopting a full LLM CLI tool. Recommend one for Milestone 2 and explain why.

Expected qualities:

- recommends the just recipe for the early milestone
- explains trade-offs
- respects thin custom layer principle
- does not dismiss future CLI tools entirely

Best suited for:

- local-capable

### Prompt 9: Boundary discipline

Purpose:

Test whether the model can respect project boundaries and avoid scope creep.

Prompt:

    We are working on the model fitness loop. Should we add RAG, agents, semantic routing and frontier provider fallback to this milestone? Give a practical answer.

Expected qualities:

- says no or not yet
- explains why those belong later
- keeps Milestone 3 focused
- does not over-expand scope

Best suited for:

- local-capable
- local-fast

### Prompt 10: Code/config review

Purpose:

Test whether the model can spot a likely issue in a small command.

Prompt:

    Review this just recipe line and explain what might go wrong:

    curl -fsS "$gateway_url/v1/chat/completions" -d "{model: local-fast, messages: [{role: user, content: $prompt}]}"

Expected qualities:

- identifies invalid JSON
- identifies unsafe/unquoted variable expansion
- mentions content-type/header if relevant
- suggests using jq or Python json generation
- keeps the fix practical

Best suited for:

- local-code

### Prompt 11: Documentation draft

Purpose:

Test whether the model can produce a short useful documentation paragraph.

Prompt:

    Write a short README paragraph explaining that local-fast is a stable gateway model group and the actual local model behind it can change over time.

Expected qualities:

- clear documentation style
- explains stable interface
- avoids naming a specific model unless necessary
- concise

Best suited for:

- local-capable
- local-fast

### Prompt 12: Unsuitable model signal

Purpose:

Test whether the model can identify when a model is not good enough.

Prompt:

    A local model gives fast responses but often ignores requested structure, invents project files, and produces broken shell commands. Which gateway model group should it be used for, if any?

Expected qualities:

- recognises unsuitable behaviour
- does not place it in local-code
- likely rejects or parks it
- explains that speed alone is not enough

Best suited for:

- local-capable
- local-code

## Minimum Test Runs

For each candidate model, run at least:

- Prompt 1
- Prompt 3
- Prompt 4
- Prompt 7
- Prompt 10
- Prompt 12

This gives a basic view across:

- general usefulness
- summarisation
- command explanation
- troubleshooting
- code/config review
- unsuitable behaviour judgement

## Full Test Runs

Use all prompts when deciding whether a model should back:

- local-capable
- local-code

A smaller minimum set may be enough for local-fast if the model is only being considered for quick simple tasks.

## Notes

The prompt set should evolve slowly.

Do not add many prompts unless they expose a recurring decision need.

If the prompt set becomes too large to run manually, it is too large for the current milestone.
