# Semantic Routing Tool Evaluation

## Evaluation purpose

Evaluate and prove a semantic routing tool for `ai ask`.

The selected tool should allow the AI Dev Workstation to route prompts between local modes without hand-rolling a custom classifier.

This is not a paper-only evaluation. The selected approach must be proven locally and then wired into the `ai` command path where practical.

## Target behaviour

When no explicit mode is provided, `ai ask` should be able to select an appropriate local mode.

Target modes:

| Mode    | Route             | Purpose                                   |
| ------- | ----------------- | ----------------------------------------- |
| fast    | local-fast        | Simple questions and short summaries      |
| capable | local-capable-mlx | Planning, comparison and deeper reasoning |
| code    | local-code-mlx    | Code, shell, config and repo assistance   |

Explicit mode selection must still win:

```
ai ask --mode code Summarise this project
```

In that case, semantic routing should not override the user’s selected mode.

## Tool selection alignment

This evaluation aligns to `docs/09-tool-seleciton.md`.

Key principles applied:

- prefer existing tools over custom code
- preserve the LiteLLM gateway-first design where practical
- keep the workstation local-first
- keep routing decisions visible
- preserve explicit `--mode` override
- avoid unnecessary service complexity
- avoid frontier/provider escalation in this issue
- prove the selected approach through working implementation, not documentation alone

## Candidates

| Tool                            | Result                   | Rationale                                                                                                                   |
| ------------------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| LiteLLM Auto Routing            | Parked                   | Best architectural fit because routing would stay in the gateway, but the current project LiteLLM image does not support it |
| Semantic Router by Aurelio Labs | Selected for local proof | Purpose-built semantic decision layer, works locally, and avoids hand-rolling a router                                      |
| RouteLLM                        | Parked                   | More focused on strong/weak model routing and cost-quality routing than the current local fast/capable/code need            |
| vLLM Semantic Router            | Parked                   | Strategically interesting, but more platform/system-level than the current workstation CLI need                             |

## LiteLLM Auto Routing check

Result: parked for now.

LiteLLM Auto Routing is the best architectural fit because LiteLLM is already the project gateway. If available, it would allow routing decisions to stay inside the gateway layer rather than moving routing into the CLI.

However, the current project image is:

```
docker.io/litellm/litellm:1.90.0-rc.1
```

LiteLLM Auto Routing ships in the v1.94.x line.

Decision: do not upgrade LiteLLM inside #48 just to access Auto Routing.

Reason: #48 is about proving semantic routing for the `ai` command path. Upgrading the gateway image would expand the scope and risk destabilising the existing gateway foundation.

Follow-up: revisit LiteLLM Auto Routing in a future gateway upgrade issue.

## Semantic Router API compatibility check

Result: usable with installed API.

The installed package is:

```
semantic-router 0.0.20
```

The installed package does not expose the newer v1 API documented as:

```
from semantic_router.routers import SemanticRouter
```

or:

```
from semantic_router import SemanticRouter
```

The installed package exposes the older API:

```
from semantic_router import Route, RouteLayer
```

Decision: continue the local proof using the installed `RouteLayer` API rather than upgrading the package inside this issue.

Reason: #48 is about proving semantic routing through the `ai` path, not upgrading routing dependencies unless required.

## Semantic Router local proof

Result: passed.

The local proof used `semantic-router` version `0.0.20` with the installed `RouteLayer` API.

Proof command:

```
.venv/bin/python tools/routing/prove_semantic_router.py
```

Results:

| Prompt                               | Routed mode |
| ------------------------------------ | ----------- |
| Review this shell command            | code        |
| Compare these implementation options | capable     |
| Summarise this in three bullets      | fast        |

Finding: Semantic Router successfully classified the three initial workstation modes using local embeddings.

First-run behaviour: the first run downloaded the local embedding model files used by `HuggingFaceEncoder`. This is acceptable for the proof, but it should be noted because initial setup may require network access unless the embedding model is already cached.

## Proof requirements

The selected approach must prove:

- local-only routing between fast, capable and code
- no frontier escalation
- explicit `--mode` override still wins
- `ai routes test` can show the routing decision
- `ai ask` can use the selected routing approach when no mode is provided
- `ai history` records the selected mode and route
- rejected or parked tools have short reasons captured

## Selected approach

Selected approach: Semantic Router by Aurelio Labs, using the installed `RouteLayer` API.

Why selected:

- it is an existing semantic routing tool
- it works locally
- it avoids hand-rolling a custom classifier
- it can classify the project’s first three modes: fast, capable and code
- it can sit beside the `ai` command as a small routing helper
- it does not require a LiteLLM gateway upgrade
- it does not introduce frontier escalation

Implementation direction:

- keep Semantic Router logic in a Python helper under `tools/routing/`
- keep `bin/ai` as a thin shell entrypoint
- call the helper from `ai ask` only when no explicit `--mode` is provided
- call the helper from `ai routes test` when no explicit `--mode` is provided
- continue to route all prompts through LiteLLM after a mode has been selected

## ai command validation

Result: passed.

Validation commands:

    .venv/bin/python tools/routing/semantic_route.py Review this shell command
    .venv/bin/python tools/routing/semantic_route.py Compare these implementation options
    .venv/bin/python tools/routing/semantic_route.py Summarise this in three bullets

    ./bin/ai routes test Review this shell command
    ./bin/ai routes test Compare these implementation options
    ./bin/ai routes test Summarise this in three bullets
    ./bin/ai routes test --mode code Summarise this in three bullets
    ./bin/ai history --limit 5

Validated behaviour:

| Command                                           | Result                  |
| ------------------------------------------------- | ----------------------- |
| Semantic helper: shell command prompt             | code                    |
| Semantic helper: implementation comparison prompt | capable                 |
| Semantic helper: summary prompt                   | fast                    |
| ai routes test: shell command prompt              | code / semantic         |
| ai routes test: implementation comparison prompt  | capable / semantic      |
| ai routes test: summary prompt                    | fast / semantic         |
| ai routes test --mode code                        | code / explicit         |
| ai history                                        | Records decision source |

Finding:

Semantic routing is now proven through the `ai` command path. Explicit `--mode` still overrides semantic routing. History records whether the decision was semantic or explicit.

## Out of scope / deferred

| Excluded item                    | Why it is excluded now                                            | Where it will be picked up later               |
| -------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------- |
| LiteLLM Auto Routing integration | Requires a LiteLLM gateway upgrade beyond the current issue scope | Future gateway upgrade issue                   |
| Frontier escalation              | Escalation must be explicit, acknowledged and logged first        | #52 Add local-first escalation acknowledgement |
| Automatic provider switching     | Would weaken the local-first posture if introduced too early      | Future gateway/routing issue if justified      |
| Agent workflows                  | Agents depend on context, routing and access boundaries           | Controlled Agents milestone                    |
| RAG-based routing                | Private retrieval layer does not exist yet                        | Private RAG Layer milestone                    |
| Custom semantic classifier       | Existing tooling is available and has passed the local proof      | Not planned unless tools fail later            |

## Decision

Proceed with Semantic Router for #48.

LiteLLM Auto Routing remains the preferred future gateway-native option, but it is parked until a deliberate LiteLLM upgrade is undertaken.

RouteLLM and vLLM Semantic Router remain parked as later routing/runtime evaluation candidates.

Semantic routing in #48 should remain local-only, visible, and overrideable.
