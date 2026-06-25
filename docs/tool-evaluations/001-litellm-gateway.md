# Tool Evaluation: LiteLLM Gateway

## Status

Proposed

## Date

2026-06-26

## Capability Area

gateway, routing, provider abstraction

## Problem

The AI Dev Workstation needs a gateway layer that can sit between local CLI/UI tools and model providers or local runtimes.

The gateway should avoid every tool calling models directly and should support the project’s gateway-first architecture.

The gateway should help with:

- provider abstraction
- model group naming
- local and frontier model access
- retries and fallback behaviour
- a consistent API surface for CLI/UI tools
- future routing and observability
- keeping custom routing code thin

The project should not build a custom model/provider routing engine in Python if a suitable open-source gateway already exists.

## Current Project Direction

The intended routing split is:

```text
ai-route
= inspect or explain profile/policy route classes

LiteLLM or equivalent gateway
= execute model/provider routing

profile + task + sensitivity
= route class

route class
= gateway model group

gateway model group
= actual provider/model execution
```

This means `ai-route` should remain a thin inspection or policy explanation tool. It should not implement provider retries, fallback, load balancing, semantic routing or model execution.

## Requirements

The gateway should support:

- Open-source-first project direction
- local-first usage
- OpenAI-compatible API surface where practical
- local runtime support, especially Ollama initially
- future macOS local runtime support, including oMLX or MLX-compatible paths if possible
- frontier provider support where policy allows
- model groups or aliases
- retry and fallback behaviour
- basic local development setup
- config-driven behaviour
- no committed secrets
- replaceability if a better gateway is selected later

## Options Considered

| Option | Notes | Outcome |
|---|---|---|
| LiteLLM | Open-source AI gateway/proxy with provider abstraction, OpenAI-compatible API, model routing, retries and fallbacks. | Preferred candidate |
| Portkey AI Gateway | Strong AI gateway product with routing, observability and guardrail features. Potentially more platform-like than needed now. | Parked for later comparison |
| RouteLLM | Interesting learned/cost-quality router between stronger and weaker models. Better fit for future model fitness or cost routing work. | Parked |
| Custom Python routing | Maximum control, but risks duplicating existing gateway functionality and growing custom code. | Rejected for provider/model routing |
| Direct provider usage | Simple initially, but violates gateway-first direction and makes tools harder to control consistently. | Rejected |

## LiteLLM Assessment

LiteLLM appears to fit the initial gateway requirement well.

LiteLLM provides both a Python SDK and a Proxy Server / AI Gateway, with a centralized API gateway, model/provider abstraction, virtual keys, spend tracking, logging, guardrails and routing capabilities. The project’s GitHub repository describes router support with retry and fallback logic across deployments. ([GitHub](https://github.com/BerriAI/litellm/?utm_source=chatgpt.com))

LiteLLM’s router documentation describes support for load balancing, cooldowns, fallbacks, timeouts, and retries across multiple deployments/providers. This aligns with the project’s desire to avoid implementing provider/model routing logic in custom Python. ([LiteLLM](https://docs.litellm.ai/docs/routing?utm_source=chatgpt.com))

LiteLLM also supports an OpenAI-compatible API surface and provider abstraction across many providers, which should make it easier for CLI tools, UI tools and future coding assistants to use a consistent gateway endpoint rather than provider-specific APIs. ([LiteLLM](https://docs.litellm.ai/?utm_source=chatgpt.com))

For local-first use, LiteLLM documents Ollama provider support. This is important because `windows-personal` currently expects Ollama as the primary local runtime, and `macos-work` may use Ollama as a fallback local runtime. ([LiteLLM](https://docs.litellm.ai/docs/providers/ollama?utm_source=chatgpt.com))

## Security / Supply Chain Consideration

LiteLLM had a reported supply-chain incident in March 2026 involving compromised PyPI package versions `1.82.7` and `1.82.8`.

LiteLLM’s own security update states that affected PyPI packages were compromised, and that users of LiteLLM Cloud and the official LiteLLM AI Gateway Docker image were not impacted. ([LiteLLM](https://docs.litellm.ai/blog/security-update-march-2026?utm_source=chatgpt.com))

The LiteLLM GitHub security issue states that the affected packages were deleted and that current releases are free of the compromised component. ([GitHub](https://github.com/BerriAI/litellm/issues/24518?utm_source=chatgpt.com))

External reporting also described the PyPI incident as involving malicious code in versions `1.82.7` and `1.82.8`, with risk to credentials and secrets. ([IT Pro](https://www.itpro.com/security/litellm-pypi-compromise-everything-we-know-so-far?utm_source=chatgpt.com))

This does not automatically disqualify LiteLLM, but it does change the implementation posture.

The project should:

- avoid affected versions `1.82.7` and `1.82.8`
- prefer a deliberate, pinned install path
- consider using the official LiteLLM AI Gateway Docker image for initial evaluation
- avoid installing LiteLLM casually into the main workstation Python environment
- keep secrets out of repo config
- document the selected install path
- review release provenance before adopting a package version

## Fit Against Project Principles

| Principle | Fit | Notes |
|---|---|---|
| Open-source-first | Strong | LiteLLM is open source and widely used. |
| Gateway-first | Strong | LiteLLM directly supports the gateway/proxy role. |
| CLI-native | Good | CLI tools can target an OpenAI-compatible gateway endpoint. |
| Local-first | Good | Ollama support gives a practical local model path. |
| Config over code | Good | Model groups and routing can be expressed in gateway config. |
| Thin custom layer | Strong | Lets `ai-route` avoid becoming a custom routing engine. |
| Rebuildable by default | Good | Can be run locally with documented config and pinned versions/images. |
| Replaceable components | Good | The route-class to model-group pattern should allow gateway replacement later. |

## Strengths

- Good fit for gateway-first architecture.
- Reduces need for custom provider/model routing code.
- Provides a consistent API surface for local tools.
- Supports routing, retries, fallbacks and load balancing concepts.
- Supports Ollama for local runtime use.
- Supports frontier providers for personal and approved work contexts where allowed.
- Helps map project route classes to gateway model groups.
- Allows `ai-route` to stay as an inspection/explanation tool.

## Weaknesses / Risks

- Supply-chain incident history means installation must be deliberate and pinned.
- Adds another service to run locally.
- Gateway configuration may become complex if too many providers/models are added too early.
- Some provider-specific behaviours may leak through the abstraction.
- oMLX / MLX-compatible runtime support still needs confirmation.
- Work-approved provider use depends on actual organisational approval and data handling rules.
- It may be more gateway capability than the project needs at the very beginning.

## Decision

Accepted as the preferred Milestone 1 gateway candidate, subject to a minimal local proof.

LiteLLM should be used for the initial gateway evaluation and minimal gateway configuration.

This is not yet a permanent architecture lock-in. The decision should remain reviewable until a local model path has been proven and the gateway has been used through the initial CLI workflow.

## Rationale

LiteLLM best matches the project’s current needs:

- it supports gateway-first architecture
- it avoids custom routing engine work
- it supports local and frontier provider abstraction
- it can expose a common API surface
- it aligns with route classes and gateway model groups
- it lets custom CLI tools remain thin
- it is replaceable later if needed

The main caution is supply-chain hygiene. The project should not install or run LiteLLM casually. The evaluation should use a pinned and documented install path, with known-bad versions excluded.

## Implementation Direction

For Milestone 1, use LiteLLM only to prove the gateway foundation.

Initial implementation should focus on:

1. Create a minimal LiteLLM gateway config.
2. Define model groups matching the current route classes:
   - `local-fast`
   - `local-capable`
   - `local-code`
   - `work-approved-reasoning`
   - `frontier-reasoning`
   - `frontier-code`
3. Start with one local model group only.
4. Prove one local model path through the gateway.
5. Keep frontier/work-approved model groups as placeholders until secrets and approval are ready.
6. Do not commit secrets.
7. Do not add complex fallback or semantic routing yet.
8. Do not expand `ai-route` into a routing engine.

## Proposed Initial Install / Runtime Posture

Preferred first evaluation path:

- Use an isolated environment.
- Prefer the official LiteLLM AI Gateway Docker image or a pinned package version.
- Avoid affected PyPI versions `1.82.7` and `1.82.8`.
- Avoid installing LiteLLM into the repo’s general `.venv` until the install path is selected.
- Document the selected version/image.
- Keep the first proof local-only.

## Initial Success Criteria

LiteLLM is suitable for Milestone 1 if:

- a local gateway can start successfully
- a `local-fast` model group can be configured
- a simple prompt can be sent through the gateway
- the response comes from a local runtime path
- no secrets are required for the first test
- the command sequence is documented
- `ai-route` can refer to the gateway model group without executing it

## Follow-up Issues

- Create minimal gateway configuration for route classes.
- Prove one local model path through the gateway.
- Add gateway-aware bootstrap check.
- Reassess `ai-route` once gateway execution is proven.
- Reassess LiteLLM during the later tooling review milestone.

## Review Trigger

Review this decision if:

- LiteLLM cannot support the required local runtime path
- LiteLLM creates too much operational overhead
- LiteLLM config becomes too complex for the project
- supply-chain concerns make the tool unacceptable
- another gateway provides a simpler or safer fit
- custom code starts growing around LiteLLM in ways that suggest poor fit
- the project moves from personal workstation to shared platform

## Related Documents

- `docs/09-tool-selection.md`
- `docs/tool-evaluations/README.md`
- `docs/tool-evaluations/template.md`
- `docs/07-routing-strategy.md`
- `docs/11-cli-interface-contracts.md`
- `docs/adr/0001-gateway-first.md`
- `docs/adr/0002-open-source-first.md`
- `docs/adr/0016-use-existing-tools-for-routing-and-validation.md`
