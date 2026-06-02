# Changelog

All notable changes to this project will be documented in this file.

This project uses lightweight versioning to track learning milestones, workstation capability, and workflow maturity. Versions are not intended to represent production-grade releases. They are used to show how the AI Lab evolves over time.

---

## v0.3.0 — Workflow Maturity and Routing Intelligence

### Status

In progress.

### Theme

Make the project easier to understand, easier to rebuild, and more useful as a practical AI-augmented architecture workflow platform.

### Planned Changes

* Improve the main `README.md`
* Add structured documentation under `docs/`
* Add a roadmap document
* Add this changelog
* Refine `architect-ai` workflows
* Improve model routing beyond basic keyword matching
* Add route explanation capability
* Improve examples and validation commands
* Capture known troubleshooting lessons
* Prepare the project for more mature future phases

### Documentation Added

* `docs/01-workstation-overview.md`
* `docs/02-setup-and-prerequisites.md`
* `docs/03-tools-reference.md`
* `docs/04-open-webui-podman-quadlet.md`
* `docs/05-gpu-and-ollama-troubleshooting.md`
* `docs/06-model-routing.md`
* `docs/07-roadmap.md`

### Planned Enhancements

* Add `--explain-route` to `ask-ollama`
* Improve `architect-ai` command outputs
* Add clearer examples for banking and architecture workflows
* Introduce classifier-based routing as routing v0.2
* Update documentation after routing improvements are complete

---

## v0.2.0 — Core Workstreams and Validation Tools

### Status

Complete.

### Theme

Move from a working local AI setup to a more observable, useful, and structured AI workstation.

### Added

* `ai-status`

  * workstation health check
  * Ollama runtime validation
  * Ollama API validation
  * model availability check
  * Open WebUI service check
  * safe remediation with `--fix`
  * inference probe with `--probe`

* `ai-gpu-check`

  * NVIDIA GPU visibility check
  * CUDA library visibility check
  * Ollama GPU usage validation
  * focused inference probe

* `ollama-api-test`

  * direct Ollama API testing
  * raw JSON response mode
  * streaming response mode
  * API request visibility
  * stdin input support

* Open WebUI Podman Quadlet

  * Open WebUI moved from manual container startup to a user-level systemd managed Podman service
  * version-controlled Quadlet definition added under `containers/open-webui/`
  * runtime data kept outside the repository

* Basic model routing in `ask-ollama`

  * added `--auto`
  * routes prompts to different local models based on simple task patterns
  * prevents `--auto` and `--model` being used together

### Changed

* Standardised project folder as:

```text
~/projects/ai-lab
```

* Consolidated tools under:

```text
~/projects/ai-lab/tools
```

* Consolidated reusable context files under:

```text
~/projects/ai-lab/tools/context
```

* Updated shell `PATH` to use the project tools directory

### Current Tools

* `ask-ollama`
* `architect-ai`
* `ai-status`
* `ai-gpu-check`
* `ollama-api-test`

### Current Context Files

* `architect.txt`
* `writing-style.txt`
* `banking.txt`

### Current Models

* `qwen3:14b`
* `deepseek-r1:14b`
* `llama3.1:8b`

### Workstreams Completed

* Local inference understanding
* API awareness
* Container understanding
* GPU acceleration
* Linux workflow maturity
* Model orchestration v0.1

---

## v0.1.0 — Initial AI Workstation

### Status

Complete.

### Theme

Create the first working version of the local AI workstation.

### Added

* WSL2 Ubuntu working environment
* Windows Terminal configuration
* zsh shell setup
* Starship prompt configuration
* Powerline-style terminal appearance
* Ollama installation
* local model execution
* Open WebUI installation
* Continue.dev integration with local Ollama models
* early `ask-ollama` script
* early `architect-ai` wrapper
* initial persona and writing-style thinking

### Initial Capabilities

* Run local models through Ollama
* Use Open WebUI as a local browser-based AI interface
* Use Continue.dev with local models in VS Code
* Ask local models questions from the terminal
* Apply basic architecture persona guidance
* Begin exploring local AI workflows

---

## Future Versions

### v0.4.0 — vLLM Exploration

Planned focus:

* explore vLLM as a production-style local inference server
* expose an OpenAI-compatible local API
* compare Ollama and vLLM
* test Open WebUI or CLI tools against vLLM
* document inference serving concepts

### v0.5.0 — Hybrid Model Providers

Planned focus:

* introduce external model providers
* explore OpenAI and Claude integration
* introduce provider abstraction
* route between local and external models
* consider privacy, cost, quality, and governance trade-offs

### v0.6.0 — RAG and Knowledge Workflows

Planned focus:

* introduce lightweight retrieval-augmented generation
* ingest local markdown or documentation
* explore embeddings and vector search
* build simple architecture knowledge workflows

### v0.7.0 — Kubernetes-Native Inference Concepts

Planned focus:

* explore llm-d concepts
* understand distributed inference
* map local workstation patterns to Kubernetes and OpenShift AI
* document platform architecture implications

---

## Versioning Notes

This project uses versions to mark learning and capability milestones.

The version numbers are not tied to production stability. They are intended to help track:

* what has been built
* what has been learned
* what has changed
* what is planned next

A version can be considered complete when the relevant tools, documentation, and validation commands are working and committed to Git.
