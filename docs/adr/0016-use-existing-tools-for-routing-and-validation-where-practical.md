ADR-0016: Use existing tools for routing and validation where practical

Status

Proposed

Date

2026-06-25

Context

The project has started to introduce CLI commands such as:

* ai-status
* ai-route
* ai-bootstrap-check
* ask-ai

The first implementation of ai-status proved useful because it made profile and configuration state visible from the terminal.

However, it also raised an important architecture question:

Should this project build custom Python logic for routing, validation and orchestration, or should it use existing open-source tools where practical?

This matters because the project principles are:

* open-source-first
* gateway-first
* config over code
* composable and replaceable
* thin custom layer
* rebuildable by default
* daily use over novelty

There is a risk that the project could accidentally grow into a custom Python platform, even though existing tools already provide much of the generic functionality needed.

Examples:

* model/provider routing can be handled by a gateway/router such as LiteLLM
* repeated local commands can be handled by just
* YAML validation can be handled by yamllint
* YAML querying can be handled by yq if needed
* gateway health can be checked through gateway-native endpoints
* runtime health can be checked through runtime-native commands

The custom CLI should exist where it provides project-specific value, not where it duplicates generic tooling.

Decision

Use existing open-source tools for generic routing, validation and orchestration where practical.

Keep custom CLI commands as thin project-specific wrappers.

The intended split is:

Area	Preferred approach
Provider/model routing execution	LiteLLM or equivalent gateway/router
Route policy explanation	Thin custom ai-route wrapper
Workstation status summary	Thin custom ai-status wrapper
YAML validation	yamllint or equivalent
YAML loading inside Python commands	PyYAML where needed
YAML querying from shell workflows	yq if needed
Local task orchestration	just or equivalent
Gateway health	Gateway-native health endpoint
Local runtime health	Runtime-native commands or APIs
Secrets resolution	Bitwarden / future ai-secrets helper

Custom CLI commands should explain and orchestrate.

Existing tools should validate, route and execute wherever practical.

Options Considered

Option 1: Build custom Python tooling for everything

Build bespoke Python commands for status, validation, routing, gateway checks, runtime checks and config parsing.

Pros:

* full control
* one language
* easy to tailor to this repo
* fast to prototype

Cons:

* risks creating a custom platform
* duplicates existing tools
* increases maintenance burden
* makes the project less open-source-first
* makes future replacement harder
* can turn a personal project into unnecessary engineering overhead

Option 2: Use existing tools only

Avoid custom CLI commands and use tools like just, yq, yamllint, LiteLLM and shell scripts directly.

Pros:

* minimal custom code
* highly composable
* uses proven tools
* easy to replace individual parts

Cons:

* weaker user experience
* no single project-specific interface
* harder to explain profile/routing decisions in the project’s language
* can become a collection of commands rather than a coherent workstation

Option 3: Thin custom CLI over existing tools

Use custom CLI commands only where they provide project-specific value, while delegating generic behaviour to existing tools.

Pros:

* keeps stable user-facing commands
* aligns with CLI-native principle
* avoids duplicating routing/validation engines
* keeps implementation lighter
* preserves project-specific language and policy explanation
* supports future replacement of underlying tools

Cons:

* still requires some custom code
* requires discipline to avoid expanding wrappers too far
* some integration glue will still be needed

Decision Outcome

Use Option 3.

The project will keep commands such as ai-status and ai-route, but their role should be deliberately limited.

ai-status

ai-status should remain a human-friendly workstation status summary.

It may show:

* active profile
* profile status
* risk posture
* config file presence
* runtime access posture
* context boundaries
* approved workspaces
* secret requirements without values

Over time, generic checks should be delegated where practical:

* YAML validation to yamllint
* repeated checks to just
* runtime health to native runtime commands
* gateway health to gateway-native endpoints
* secrets availability to Bitwarden or ai-secrets

ai-status should not become a large custom validation framework.

ai-route

ai-route should explain policy-level routing decisions.

It should show:

* profile
* task type
* sensitivity
* selected route class
* intended gateway model group
* whether the route is local, approved work, frontier or blocked
* why the route was selected

It should not implement provider/model routing itself.

Actual provider/model routing, retries, fallbacks and load balancing should be handled by LiteLLM or an equivalent gateway/router.

LiteLLM

LiteLLM is the preferred initial candidate for gateway and model/provider routing execution.

It should be used to provide:

* unified model/provider access
* model groups
* provider routing
* fallbacks
* retries
* gateway-compatible access for CLI/UI/tools where practical

This project’s routing policy should decide which gateway model group is allowed. LiteLLM should execute the provider/model route within that group.

just

just is the preferred initial candidate for local task orchestration.

It may be used for repeatable commands such as:

just check-yaml
just status macos-work
just route-test
just bootstrap-check macos-work

This keeps common project workflows discoverable without putting everything into Python.

YAML tooling

Use:

* yamllint for repo-level YAML validation
* PyYAML where Python CLI commands need to load YAML
* yq later if shell workflows need YAML querying

Do not add yq until there is a concrete need.

Rationale

This decision keeps the project aligned to its principles.

The project should not build a custom AI platform. It should build a personal AI workstation that composes good open-source tools behind stable, profile-aware workflows.

The custom layer is valuable when it provides:

* project-specific vocabulary
* profile awareness
* work/personal boundary explanation
* sensitivity-aware policy explanation
* consistent CLI experience
* clear status output

The custom layer is not valuable when it recreates:

* generic model routing
* retries
* fallbacks
* YAML linting
* task running
* health-check mechanics that existing tools already expose

Consequences

Benefits

* Reduces custom code.
* Keeps the project easier to maintain.
* Aligns with open-source-first.
* Keeps CLI commands useful without making them heavy.
* Allows LiteLLM or another gateway to be replaced later.
* Prevents early stubs from becoming accidental platforms.
* Makes future review easier.

Trade-offs

* Requires integrating multiple tools.
* Some wrapper code will still exist.
* ai-status and ai-route need clear boundaries.
* Tool installation and bootstrap need to be documented.
* The project may need a justfile and basic tool dependency list.

Risks or Follow-ups

* Avoid adding tools just because they are interesting.
* Keep the toolchain small.
* Review whether LiteLLM remains the right gateway after initial implementation.
* Review whether just, yamllint and yq are actually needed before making them required.
* Reassess ai-status after Milestone 1 to avoid custom-code creep.
* Reassess ai-route before adding provider execution logic.

Implementation Impact

Issue #8 should be updated so that ai-route is a policy explanation stub, not a custom routing engine.

The route config should evolve toward:

profile + task + sensitivity
→ route class
→ gateway model group
→ gateway/router execution

Example:

Profile: macos-work
Task: architecture_review
Sensitivity: customer
Selected route class: approved_work
Gateway model group: work-approved-reasoning
Execution: delegated to LiteLLM

The existing ai-status stub may remain for now, but a backlog issue should review whether generic validation should be delegated to existing tools.

A later review milestone should reassess:

* LiteLLM as gateway/router
* ai-status implementation
* ai-route implementation
* just
* yamllint
* yq
* Bitwarden CLI versus Bitwarden Secrets Manager
* oMLX/Ollama runtime split
* model alias structure

Review Trigger

Review this decision if:

* custom CLI code starts growing quickly
* LiteLLM does not meet gateway/router needs
* ai-status starts duplicating validation tools
* ai-route starts implementing provider/model routing directly
* just, yamllint or yq become unnecessary or burdensome
* another tool provides a simpler, more coherent fit
* the project moves beyond a personal workstation into a shared platform

Related Documents

* README.md
* docs/02-principles.md
* docs/04-capability-contracts.md
* docs/05-component-lifecycle.md
* docs/07-routing-strategy.md
* docs/08-rebuild-strategy.md
* docs/09-tool-selection.md
* docs/10-milestones.md
* docs/11-cli-interface-contracts.md
* docs/adr/0001-gateway-first.md
* docs/adr/0002-open-source-first.md
* docs/adr/0003-cli-native.md
* docs/adr/0013-routing-validation-and-observability.md
