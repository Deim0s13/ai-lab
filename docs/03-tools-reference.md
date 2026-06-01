# Tools Reference

## Purpose

This document explains the CLI tools used in the AI Lab project.

The tools provide a workflow layer on top of the local AI workstation. They are designed to make the environment easier to use, easier to validate, and more useful for architecture-focused work.

The current toolset includes:

| Tool              | Purpose                                       |
| ----------------- | --------------------------------------------- |
| `ask-ollama`      | General-purpose local AI CLI interface        |
| `architect-ai`    | Architecture-focused workflow wrapper         |
| `ai-status`       | Workstation health check and safe remediation |
| `ai-gpu-check`    | Focused GPU acceleration validation           |
| `ollama-api-test` | Direct Ollama API testing and learning tool   |

---

## Tool Location

All tools are stored in:

```text
~/projects/ai-lab/tools
```

The tools directory should be added to the shell `PATH`:

```bash
export PATH="$HOME/projects/ai-lab/tools:$PATH"
```

Validate with:

```bash
which ask-ollama
which architect-ai
which ai-status
which ai-gpu-check
which ollama-api-test
```

Expected output should point to:

```text
/home/pleathen/projects/ai-lab/tools/...
```

---

## Context Files

The project uses reusable context files to shape responses without repeating instructions in every prompt.

Context files are stored in:

```text
~/projects/ai-lab/tools/context
```

Current context files:

| File                | Purpose                                        |
| ------------------- | ---------------------------------------------- |
| `architect.txt`     | Architecture persona and framing               |
| `writing-style.txt` | Preferred writing tone and communication style |
| `banking.txt`       | Banking and financial services domain context  |

These files can be combined through `ask-ollama`.

Example:

```bash
ask-ollama --persona architect --style writing-style "Explain RAG"
```

With banking context:

```bash
ask-ollama --persona architect --style writing-style --domain banking "Explain RAG to a banking customer"
```

---

# `ask-ollama`

## Purpose

`ask-ollama` is the general-purpose local AI CLI interface.

It is the core tool for sending prompts to local Ollama models from the terminal.

It supports:

* default model configuration
* persona context
* writing style context
* domain context
* simple last-response memory
* stdin input through pipes
* saving responses to markdown files
* basic model routing with `--auto`

---

## Basic Usage

```bash
ask-ollama "Explain RAG"
```

This sends the prompt to the default model.

Current default model:

```text
qwen3:14b
```

---

## Options

| Option                | Purpose                               |
| --------------------- | ------------------------------------- |
| `-h`, `--help`        | Show help                             |
| `-v`, `--version`     | Show tool version                     |
| `-l`, `--list-models` | List available Ollama models          |
| `-m`, `--model MODEL` | Specify model manually                |
| `--persona NAME`      | Load a persona context file           |
| `--style NAME`        | Load a writing style context file     |
| `--domain NAME`       | Load a domain context file            |
| `--continue`          | Include previous response as context  |
| `-s`, `--save FILE`   | Save output to a markdown file        |
| `--auto`              | Automatically route prompt to a model |

---

## List Available Models

```bash
ask-ollama --list-models
```

---

## Use a Specific Model

```bash
ask-ollama --model llama3.1:8b "Explain containers in simple terms"
```

---

## Use Persona and Style Context

```bash
ask-ollama --persona architect --style writing-style "Explain OpenShift AI"
```

This applies:

* architecture framing
* preferred writing style
* practical enterprise communication tone

---

## Add Banking Context

```bash
ask-ollama --persona architect --style writing-style --domain banking "Explain RAG to a banking customer"
```

This adds financial services context such as:

* BIAN alignment
* operational resilience
* regulatory considerations
* banking capability alignment
* security and risk management

---

## Use Model Routing

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

The tool selects a model based on simple routing rules.

Current routing:

| Task Type                                  | Model             |
| ------------------------------------------ | ----------------- |
| Explain / summarise / general architecture | `qwen3:14b`       |
| Compare / risk / trade-offs / strategy     | `deepseek-r1:14b` |
| Rewrite / concise / quick tasks            | `llama3.1:8b`     |

Example:

```bash
ask-ollama --auto "Explain RAG"
```

Expected routing:

```text
qwen3:14b
```

Example:

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

Expected routing:

```text
deepseek-r1:14b
```

Example:

```bash
ask-ollama --auto "Rewrite this into concise talking points: OpenShift AI provides model serving and MLOps."
```

Expected routing:

```text
llama3.1:8b
```

---

## Use Previous Response Memory

`ask-ollama` stores the last response in:

```text
~/.local/share/ask-ollama/last-response.md
```

Use the previous response as context:

```bash
ask-ollama --continue "Make that more concise"
```

Example workflow:

```bash
ask-ollama --persona architect --style writing-style "Explain RAG"
ask-ollama --continue "Turn that into executive talking points"
```

---

## Pipe Input Into `ask-ollama`

```bash
cat notes.md | ask-ollama "Summarise the input content into key themes"
```

This is useful when passing file content into a prompt.

Example:

```bash
cat docs/workstation-architecture.md | ask-ollama --persona architect "Summarise the architecture"
```

---

## Save Output

```bash
ask-ollama --auto "Explain local inference" --save docs/local-inference-notes.md
```

The saved file includes:

* model used
* persona file
* style file
* domain file
* question
* response

---

## Common Examples

```bash
ask-ollama "Explain RAG"
```

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

```bash
ask-ollama --persona architect --style writing-style "Explain Kubernetes operators"
```

```bash
ask-ollama --persona architect --style writing-style --domain banking "Explain platform engineering to a bank"
```

```bash
ask-ollama --continue "Make that shorter and more executive friendly"
```

---

# `architect-ai`

## Purpose

`architect-ai` is a role-specific wrapper around `ask-ollama`.

It removes the need to repeatedly enter:

```bash
--persona architect --style writing-style
```

It also provides architecture-focused workflow commands.

`architect-ai` is intended for:

* architecture explanation
* technology comparison
* customer risk analysis
* discovery preparation
* executive summaries
* positioning guidance
* talking points
* banking-specific framing

---

## Basic Usage

```bash
architect-ai explain "RAG"
```

---

## Optional Domain

The current supported domain is:

```text
banking
```

Example:

```bash
architect-ai banking explain "RAG"
```

This applies:

* architect persona
* writing style
* banking domain context
* model routing

---

## Commands

| Command          | Purpose                                                                 |
| ---------------- | ----------------------------------------------------------------------- |
| `explain`        | Explain a concept for an architecture audience                          |
| `risks`          | Identify risks, objections, governance concerns and adoption challenges |
| `compare`        | Compare technologies or approaches                                      |
| `summary`        | Create an executive-level summary                                       |
| `discovery`      | Generate customer discovery questions                                   |
| `talking-points` | Create concise talking points                                           |
| `challenge`      | Challenge assumptions and identify blind spots                          |
| `position`       | Create positioning guidance for a customer conversation                 |

---

## Explain

```bash
architect-ai explain "RAG"
```

Use this when you want a clear architecture-oriented explanation of a concept.

Example with banking context:

```bash
architect-ai banking explain "RAG"
```

---

## Risks

```bash
architect-ai risks "self-hosted AI platform"
```

Use this to identify:

* customer risks
* likely objections
* governance concerns
* operational considerations
* adoption challenges
* decision-maker sensitivities

Example with banking context:

```bash
architect-ai banking risks "self-hosted AI platform"
```

---

## Compare

```bash
architect-ai compare "OpenShift AI vs SageMaker"
```

Use this for technology comparison and trade-off analysis.

Example with banking context:

```bash
architect-ai banking compare "OpenShift AI vs SageMaker"
```

---

## Summary

```bash
architect-ai summary "platform engineering"
```

Use this to create a concise executive-level summary.

---

## Discovery

```bash
architect-ai discovery "enterprise AI adoption"
```

Use this to generate practical customer discovery questions grouped by areas such as:

* strategy
* business outcomes
* current state
* technical constraints
* governance and security
* operating model
* decision criteria

---

## Talking Points

```bash
architect-ai talking-points "OpenShift AI for platform teams"
```

Use this to generate concise points for a customer or leadership conversation.

---

## Challenge

```bash
architect-ai challenge "self-hosted AI platform"
```

Use this to identify:

* assumptions
* blind spots
* underestimated risks
* alternative perspectives
* questions to ask before proceeding

---

## Position

```bash
architect-ai position "OpenShift AI for regulated enterprises"
```

Use this to create:

* a simple positioning statement
* customer relevance
* likely objections
* suggested responses
* conversation openers

---

# `ai-status`

## Purpose

`ai-status` is the main workstation health check and safe remediation tool.

It checks:

* Ollama CLI
* Ollama service
* Ollama API
* available models
* GPU visibility
* active model processor usage
* Open WebUI user service
* Open WebUI Podman container
* Open WebUI HTTP endpoint

---

## Basic Usage

```bash
ai-status
```

---

## Options

| Option            | Purpose                                                  |
| ----------------- | -------------------------------------------------------- |
| `-h`, `--help`    | Show help                                                |
| `-v`, `--version` | Show version                                             |
| `--probe`         | Run a lightweight model prompt before checking GPU usage |
| `--fix`           | Apply safe remediation actions                           |

---

## Full Health Check

```bash
ai-status --fix --probe
```

This:

* checks the AI workstation
* starts/restarts known services where safe
* runs a small inference probe
* confirms active model processor usage

---

## Safe Remediation

`ai-status --fix` can safely:

* start Ollama if stopped
* restart Ollama if the API is unreachable
* reload user systemd units if needed
* start Open WebUI if stopped
* restart Open WebUI if the endpoint is unreachable

It does not:

* change GPU drivers
* rewrite service configuration
* download models
* recreate containers
* delete runtime data
* change network configuration

---

## Common Usage

```bash
ai-status
```

```bash
ai-status --probe
```

```bash
ai-status --fix
```

```bash
ai-status --fix --probe
```

---

# `ai-gpu-check`

## Purpose

`ai-gpu-check` is a focused GPU acceleration validation tool.

It checks:

* NVIDIA GPU visibility inside WSL2
* NVIDIA driver information
* GPU memory
* CUDA library visibility
* Ollama service/process status
* active model processor usage

---

## Basic Usage

```bash
ai-gpu-check
```

---

## With Inference Probe

```bash
ai-gpu-check --probe
```

This runs a small prompt to load the default model, then checks:

```bash
ollama ps
```

The desired result is:

```text
100% GPU
```

---

## Useful Supporting Commands

```bash
nvidia-smi
```

```bash
ollama ps
```

```bash
systemctl status ollama
```

---

## Interpreting Results

| Result                                       | Meaning                        |
| -------------------------------------------- | ------------------------------ |
| `nvidia-smi` works and `ollama ps` shows GPU | GPU path is working            |
| `nvidia-smi` works but `ollama ps` shows CPU | Ollama is not using GPU        |
| `nvidia-smi` missing                         | WSL2 cannot see the NVIDIA GPU |
| no active models                             | Run `ai-gpu-check --probe`     |

---

# `ollama-api-test`

## Purpose

`ollama-api-test` is a learning tool for calling the Ollama HTTP API directly.

It exists to make the API layer visible.

It is intentionally different from `ask-ollama`:

| Tool              | Purpose                          |
| ----------------- | -------------------------------- |
| `ask-ollama`      | Practical day-to-day prompting   |
| `ollama-api-test` | Learn and validate the API layer |

---

## Basic Usage

```bash
ollama-api-test "Explain RAG in one paragraph"
```

This calls:

```text
http://127.0.0.1:11434/api/generate
```

---

## Options

| Option                | Purpose                        |
| --------------------- | ------------------------------ |
| `-h`, `--help`        | Show help                      |
| `-v`, `--version`     | Show version                   |
| `-m`, `--model MODEL` | Specify model                  |
| `--stream`            | Use streaming API output       |
| `--raw`               | Print raw JSON response        |
| `--show-request`      | Show endpoint and JSON payload |
| `-s`, `--save FILE`   | Save response to markdown      |

---

## Show API Request

```bash
ollama-api-test --show-request "Explain model serving"
```

This shows:

* endpoint
* JSON payload
* response

---

## Show Raw JSON Response

```bash
ollama-api-test --raw "Say hello"
```

This is useful for seeing the full API response object.

---

## Use Streaming Output

```bash
ollama-api-test --stream "Explain Kubernetes operators simply"
```

This demonstrates the difference between:

```text
stream: false
```

and:

```text
stream: true
```

---

## Pipe Input

```bash
echo "OpenShift AI provides model serving and MLOps capabilities." \
  | ollama-api-test "Summarise the input content"
```

---

## Save Output

```bash
ollama-api-test "Explain local inference" --save docs/local-inference-api-test.md
```

---

# Common Workflows

## Check Everything

```bash
ai-status --fix --probe
```

## Confirm GPU Usage

```bash
ai-gpu-check --probe
```

## Test Ollama API

```bash
ollama-api-test "Reply with exactly: ok"
```

## Ask a General Question

```bash
ask-ollama "Explain RAG"
```

## Use Routing

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

## Use Architecture Workflow

```bash
architect-ai explain "RAG"
```

## Use Banking Context

```bash
architect-ai banking compare "OpenShift AI vs SageMaker"
```

## Refine Previous Output

```bash
ask-ollama --continue "Make that more concise"
```

---

# Current Tooling Model

```text
Terminal
  ↓
CLI tool
  ↓
Context files / routing logic
  ↓
Ollama CLI or API
  ↓
Local model
  ↓
GPU-backed inference
  ↓
Response
```

---

# Design Principles

The tools should remain:

* simple
* readable
* useful
* role-aligned
* easy to modify
* easy to version control
* easy to rebuild

The goal is not to create a complex framework. The goal is to build practical AI workflow capability while learning how AI systems fit together.
