# Model Routing

## Purpose

This document explains the current model routing approach used in the AI Lab project.

Model routing is the first step toward model orchestration. Instead of sending every prompt to the same model, the workstation can select a model based on the type of task being requested.

The current implementation is intentionally simple. It uses rule-based routing in `ask-ollama` through the `--auto` option.

This moves the workflow from:

```text
prompt → fixed model → response
```

to:

```text
prompt → routing logic → selected model → response
```

This is not full semantic routing yet. It is routing v0.1.

---

## Why Routing Matters

Different models are better suited to different types of work.

Some models are better for:

* general explanation
* technical reasoning
* complex comparison
* concise rewriting
* structured summarisation
* quick lightweight responses

Using one model for everything is simple, but it does not teach how modern AI systems are commonly designed.

Many real AI platforms use some form of routing or orchestration to decide:

* which model to use
* whether to use a local or external model
* whether a request needs a larger model
* whether the request is sensitive
* whether the request needs reasoning, speed, low cost, or stronger writing quality

The current routing implementation is a small local version of that broader pattern.

---

## Current Models

The current local model set is:

| Model             | Intended Use                                                            |
| ----------------- | ----------------------------------------------------------------------- |
| `qwen3:14b`       | General architecture explanation and everyday reasoning                 |
| `deepseek-r1:14b` | Deeper reasoning, comparison, risk, trade-off and strategy work         |
| `llama3.1:8b`     | Lightweight rewrites, short responses, quick summaries and simple tasks |

---

## Current Routing Approach

Routing is currently implemented in `ask-ollama`.

The user can run:

```bash
ask-ollama --auto "Explain RAG"
```

The tool then:

1. reads the prompt
2. applies simple routing rules
3. selects a model
4. sends the prompt to the selected model
5. shows which model was selected

Example output:

```text
Routing selected model: qwen3:14b
```

---

## Current Routing Rules

The current routing logic is based on keyword and phrase matching.

| Prompt Type                                | Routed Model      |
| ------------------------------------------ | ----------------- |
| Explain / summarise / general architecture | `qwen3:14b`       |
| Compare / risk / trade-offs / strategy     | `deepseek-r1:14b` |
| Rewrite / concise / quick tasks            | `llama3.1:8b`     |

---

## Reasoning / Analysis Routing

Prompts are routed to:

```text
deepseek-r1:14b
```

when they include terms such as:

```text
compare
comparison
trade-off
tradeoff
risk
risks
challenge
assumption
strategy
strategic
evaluate
assess
analyse
analyze
decision
option
pros and cons
objection
concern
```

This is intended for tasks that require deeper reasoning, comparison, risk identification, or strategic judgement.

Example:

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker for a regulated bank"
```

Expected route:

```text
deepseek-r1:14b
```

---

## Fast / Writing Routing

Prompts are routed to:

```text
llama3.1:8b
```

when they include terms such as:

```text
rewrite
reword
make concise
shorten
summarise briefly
summarize briefly
talking points
bullet points
quick
simple
one paragraph
email
draft
```

This is intended for lightweight writing, quick rewrites, short summaries, and simple responses.

Example:

```bash
ask-ollama --auto "Rewrite this into concise talking points: OpenShift AI provides model serving and MLOps."
```

Expected route:

```text
llama3.1:8b
```

---

## Default Explanation Routing

If no specific routing keywords are detected, prompts are routed to:

```text
qwen3:14b
```

This is the default general-purpose model.

Example:

```bash
ask-ollama --auto "Explain RAG"
```

Expected route:

```text
qwen3:14b
```

---

## Manual Model Selection

Routing is optional.

A model can still be selected manually:

```bash
ask-ollama --model llama3.1:8b "Explain containers simply"
```

Manual model selection and automatic routing should not be used together.

This is invalid:

```bash
ask-ollama --auto --model llama3.1:8b "Explain RAG"
```

Expected error:

```text
Error: Use either --auto or --model, not both.
```

This keeps routing behaviour clear and avoids confusion.

---

## Routing with Context Files

Routing can be used with persona, style, and domain context.

Example:

```bash
ask-ollama --auto --persona architect --style writing-style "Explain RAG"
```

Example with banking context:

```bash
ask-ollama --auto --persona architect --style writing-style --domain banking "Compare OpenShift AI and SageMaker"
```

This combines:

```text
prompt
  ↓
context files
  ↓
routing logic
  ↓
selected model
  ↓
response
```

---

## Routing Through `architect-ai`

`architect-ai` acts as a higher-level workflow wrapper around `ask-ollama`.

It removes the need to repeatedly type:

```bash
--persona architect --style writing-style
```

It can also apply banking context when required.

Example:

```bash
architect-ai explain "RAG"
```

Example with banking context:

```bash
architect-ai banking compare "OpenShift AI vs SageMaker"
```

The intended direction is for `architect-ai` to use model routing automatically so common architecture workflows select an appropriate model without extra effort.

---

## Example Routing Scenarios

### General Explanation

```bash
ask-ollama --auto "Explain RAG"
```

Expected model:

```text
qwen3:14b
```

Reason:

```text
General explanation task.
```

---

### Architecture Comparison

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

Expected model:

```text
deepseek-r1:14b
```

Reason:

```text
Comparison and trade-off task.
```

---

### Risk Analysis

```bash
ask-ollama --auto "What are the risks of self-hosted AI platforms in a regulated enterprise?"
```

Expected model:

```text
deepseek-r1:14b
```

Reason:

```text
Risk and governance-oriented task.
```

---

### Concise Rewrite

```bash
ask-ollama --auto "Rewrite this into concise talking points: OpenShift AI provides an enterprise platform for model serving and MLOps."
```

Expected model:

```text
llama3.1:8b
```

Reason:

```text
Concise writing and talking-points task.
```

---

### Banking Scenario

```bash
ask-ollama --auto --persona architect --style writing-style --domain banking "Compare local AI platforms and managed cloud AI services for a bank"
```

Expected model:

```text
deepseek-r1:14b
```

Reason:

```text
Comparison, architecture trade-off, and regulated banking context.
```

---

## Current Limitations

The current routing implementation is deliberately basic.

It has several limitations:

* it relies on keywords
* it does not understand meaning deeply
* it does not use embeddings
* it does not estimate prompt complexity
* it does not consider model availability beyond validation
* it does not consider privacy or sensitivity
* it does not route between local and external models
* it does not learn from previous usage

This is acceptable for the current stage.

The purpose of routing v0.1 is to make the orchestration pattern visible and useful without adding too much complexity.

---

## Why Not Full Semantic Routing Yet?

Full semantic routing would require additional components such as:

* embeddings
* vector similarity
* classifier prompts
* intent schemas
* policy rules
* provider abstraction
* possibly external model APIs

Those are useful future areas, but starting there too early would make the project more complex before the basic pattern is understood.

The current routing approach is intentionally transparent and easy to modify.

---

## Future Routing v0.2 — Classifier-Based Routing

The next improvement should be classifier-based routing.

Instead of matching only keywords, the tool could ask a small model to classify the task.

Example task categories:

| Task Type             | Suggested Model              |
| --------------------- | ---------------------------- |
| explanation           | `qwen3:14b`                  |
| comparison            | `deepseek-r1:14b`            |
| risk_analysis         | `deepseek-r1:14b`            |
| strategy              | `deepseek-r1:14b`            |
| rewrite               | `llama3.1:8b`                |
| summary               | `qwen3:14b` or `llama3.1:8b` |
| discovery_questions   | `qwen3:14b`                  |
| challenge_assumptions | `deepseek-r1:14b`            |

The flow would become:

```text
prompt
  ↓
classification prompt
  ↓
task type
  ↓
model selection
  ↓
response generation
```

This would be more flexible than keyword matching while remaining lightweight.

---

## Future Routing v0.3 — Route Explanation Mode

A useful enhancement would be an explicit route explanation option.

Example:

```bash
ask-ollama --auto --explain-route "Compare OpenShift AI and SageMaker"
```

Possible output:

```text
Selected model: deepseek-r1:14b
Reason: The prompt asks for comparison and trade-off analysis.
```

This would make model orchestration more transparent and easier to learn from.

---

## Future Routing v0.4 — Semantic Routing

Semantic routing could later use embeddings or similarity matching to understand the intent of a prompt more deeply.

The flow could become:

```text
prompt
  ↓
embedding / semantic classifier
  ↓
intent match
  ↓
policy check
  ↓
model selection
  ↓
response
```

Potential routing signals:

* task type
* domain
* sensitivity
* prompt complexity
* required reasoning depth
* desired output format
* local vs external provider preference
* cost or performance considerations
* privacy requirements

---

## Future Routing v0.5 — Hybrid Provider Routing

A later phase may introduce external model providers such as OpenAI or Claude.

At that point, routing might decide between:

| Scenario                       | Possible Route          |
| ------------------------------ | ----------------------- |
| local/private prompt           | local Ollama model      |
| complex strategic reasoning    | Claude or OpenAI        |
| quick rewrite                  | local lightweight model |
| customer-sensitive content     | local model             |
| general high-quality reasoning | external model          |
| offline usage                  | local model only        |

The future architecture could become:

```text
prompt
  ↓
routing layer
  ├── local Ollama
  ├── vLLM
  ├── OpenAI
  ├── Claude
  └── other providers
```

---

## Future Routing v0.6 — vLLM and llm-d

Later phases may explore more advanced inference infrastructure.

### vLLM

vLLM would introduce a more production-style local inference server with OpenAI-compatible APIs.

This would help explore:

* model serving
* OpenAI-compatible local endpoints
* runtime performance patterns
* serving configuration
* API compatibility

### llm-d

llm-d would introduce Kubernetes-native distributed inference concepts.

This would help explore:

* distributed inference
* model placement
* Kubernetes-native routing
* gateway-based inference
* OpenShift AI alignment
* production platform patterns

These are future phases, not part of the current routing v0.1 implementation.

---

## Current Design Principle

Routing should remain:

* visible
* understandable
* easy to modify
* useful in daily workflows
* simple enough to debug
* aligned to practical architecture use cases

The aim is not to build a complex orchestration platform immediately. The aim is to build intuition for how AI systems can route work to different models based on task, context, and constraints.

---

## Quick Validation

Run these commands to confirm routing works:

```bash
ask-ollama --auto "Explain RAG"
```

Expected:

```text
Routing selected model: qwen3:14b
```

```bash
ask-ollama --auto "Compare OpenShift AI and SageMaker"
```

Expected:

```text
Routing selected model: deepseek-r1:14b
```

```bash
ask-ollama --auto "Rewrite this into concise talking points: OpenShift AI provides model serving and MLOps."
```

Expected:

```text
Routing selected model: llama3.1:8b
```

Also confirm that manual model selection conflicts with routing:

```bash
ask-ollama --auto --model llama3.1:8b "Explain RAG"
```

Expected:

```text
Error: Use either --auto or --model, not both.
```

---

## Summary

Model routing v0.1 is now implemented as a simple, transparent orchestration layer.

It provides a foundation for more advanced routing later, including:

* classifier-based routing
* route explanation
* semantic routing
* local vs external model routing
* vLLM-based serving
* llm-d and Kubernetes-native inference patterns

This is an important step in moving from local AI usage toward AI workflow and platform architecture understanding.
