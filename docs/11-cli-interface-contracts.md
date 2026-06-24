# CLI Interface Contracts

## 1. Purpose

This document defines the initial CLI interface contracts for **AI Dev Workstation as Code**.

The CLI is a first-class interface for this project. These commands should become stable surfaces that I can build habits around, even if the underlying gateway, runtime, model or provider changes later.

The goal of this document is to define the expected behaviour of the first CLI tools before implementation starts.

This helps avoid the implementation becoming the specification.

---

## 2. Scope

This document covers the initial CLI commands planned for the early milestones:

| Command | Purpose | Initial milestone |
|---|---|---|
| `ask-ai` | General AI prompt entry point. | Milestone 1 / 2 |
| `ai-route` | Explain and test routing decisions. | Milestone 1 / 2 |
| `ai-status` | Show workstation health and active profile state. | Milestone 1 |
| `ai-bootstrap-check` | Validate a rebuild or initial setup. | Milestone 1 |
| `ai-model-review` | Review model fitness and alias suitability. | Milestone 3 |

Future commands such as `dev-ai`, `architect-ai`, `write-ai`, `research-ai` and `agent-ai` should follow the same conventions when they are introduced.

---

## 3. CLI design principles

| Principle | Meaning |
|---|---|
| Stable interface | Command names and core flags should remain stable where practical. |
| Profile-aware | Commands should know which profile is active or allow one to be specified. |
| Gateway-first | Commands should use the gateway where practical. |
| Degraded-mode aware | Commands should behave clearly when the gateway is unavailable. |
| Explainable | Routing and validation commands should explain decisions in plain language. |
| Scriptable | Commands should support predictable exit codes and optional machine-readable output later. |
| Safe by default | Commands should not leak secrets, prompt content or sensitive context in logs. |
| Local-first | General commands should prefer local routes where appropriate. |
| Config-driven | Commands should read profiles, routes, aliases and policies from config. |
| Thin wrappers | Commands should coordinate existing tools and config, not become a private platform. |

---

## 4. Common conventions

### 4.1 Profile selection

Commands should use an active profile.

The active profile may come from:

1. an explicit `--profile` flag
2. a local active-profile setting
3. a sensible default only if safe and documented

Explicit flag wins.

Example:

```bash id="h01mz8"
ask-ai --profile macos-work --local "Summarise this note"
```

If no profile can be resolved, commands should fail clearly.

Example:

```text id="486nqr"
Error: no active profile selected.

Use:
  ask-ai --profile macos-work "..."
  ask-ai --profile windows-personal "..."
```

### 4.2 Output modes

Initial output should be human-readable text.

Future commands may support:

```bash id="h1r6zv"
--json
```

for machine-readable output, but JSON output is not required for the first implementation unless easy.

### 4.3 Exit codes

Commands should use consistent exit codes.

| Exit code | Meaning |
|---:|---|
| `0` | Success. |
| `1` | General failure. |
| `2` | Invalid arguments or missing required input. |
| `3` | Missing or invalid profile. |
| `4` | Gateway unavailable. |
| `5` | Local runtime unavailable. |
| `6` | Provider unavailable or missing secret. |
| `7` | Policy block. |
| `8` | Validation failed. |
| `9` | Context access denied. |

These do not need to be perfect on day one, but the convention should guide implementation.

### 4.4 Logging

Commands that make routing decisions should write metadata-only routing logs where configured.

Prompt text should not be logged by default.

Allowed log metadata may include:

- timestamp
- command
- active profile
- task type
- sensitivity
- route
- provider
- model alias
- mode
- gateway used
- degraded mode
- status
- latency
- prompt hash, if enabled

Logs must be excluded from git.

### 4.5 Sensitivity

Commands that route prompts should support a sensitivity concept.

Initial sensitivity levels:

| Sensitivity | Meaning |
|---|---|
| `public` | Public or non-sensitive content. |
| `internal` | Internal but low-risk content. |
| `customer` | Customer-specific or commercially sensitive content. |
| `personal` | Personal information or personal project material. |
| `restricted` | Content that should not be routed externally. |

Example:

```bash id="v1na2s"
ask-ai --profile macos-work --sensitivity customer --best "Review this fictional architecture option"
```

### 4.6 Degraded modes

Commands should recognise three operating modes:

| Mode | Meaning |
|---|---|
| `normal` | Gateway is healthy and used. |
| `degraded_local` | Gateway is unavailable, but direct local fallback is allowed and used. |
| `degraded_manual` | Gateway is unavailable and no automatic fallback is available. |

Commands should make degraded mode visible in output.

---

# 5. `ask-ai`

## 5.1 Purpose

`ask-ai` is the general terminal-first AI entry point.

It should be the simplest way to ask a question, summarise text, rewrite content or send a prompt through the workstation routing layer.

## 5.2 Contract

`ask-ai` must:

- use the active profile
- use the gateway where practical
- support local-only routing
- support best-available routing
- support route explanation
- support sensitivity flags
- support degraded local mode where configured
- avoid logging prompt text by default
- return clear errors when routing is blocked or unavailable

## 5.3 Initial syntax

```bash id="mjdxs4"
ask-ai [options] "prompt"
```

## 5.4 Initial flags

| Flag | Required? | Meaning |
|---|---:|---|
| `--profile <name>` | No | Use a specific profile. |
| `--local` | No | Force local-only route. |
| `--best` | No | Use best available route allowed by profile and policy. |
| `--explain-route` | No | Show why the route was selected. |
| `--sensitivity <level>` | No | Declare sensitivity level. |
| `--provider <name>` | No | Request a specific provider where policy allows. |
| `--model <name>` | No | Request a specific model where supported. |
| `--no-frontier` | No | Prevent frontier escalation. |
| `--save <path>` | No | Save output to file. |
| `--stdin` | No | Read prompt/input from stdin. |
| `--json` | Future | Machine-readable output. |

## 5.5 Examples

```bash id="u7fy18"
ask-ai --local "Explain what this workstation does"
```

```bash id="s0emcz"
ask-ai --profile macos-work --sensitivity internal "Summarise this synthetic note"
```

```bash id="zxxi7c"
ask-ai --profile windows-personal --best --explain-route "Debug this small Python example"
```

```bash id="x1ffkz"
cat notes.md | ask-ai --profile macos-work --local --stdin "Summarise this"
```

## 5.6 Expected human-readable output

Normal mode:

```text id="ggwzqc"
Profile: macos-work
Route: local_fast
Provider: omlx
Mode: normal

<model response>
```

With `--explain-route`:

```text id="v5eiy2"
Profile: macos-work
Task type: summarise
Sensitivity: internal
Route: local_fast
Provider: omlx
Model alias: local_fast
Mode: normal

Reason:
- macos-work defaults to local-first.
- summarise can usually be handled locally.
- sensitivity is internal, so local is preferred.
- no frontier escalation was requested.

Response:
<model response>
```

Degraded local mode:

```text id="u6laur"
Profile: windows-personal
Route: local_fast
Provider: ollama
Mode: degraded_local

Warning:
Gateway is unavailable. Using configured direct local fallback.

Response:
<model response>
```

Policy block:

```text id="4fys89"
Request blocked by policy.

Profile: macos-work
Sensitivity: restricted
Requested route: frontier_reasoning

Reason:
Restricted content cannot be routed to a frontier provider.
Use --local or remove restricted content.
```

## 5.7 Exit code expectations

| Scenario | Exit code |
|---|---:|
| Prompt completed successfully | `0` |
| Missing prompt | `2` |
| Missing profile | `3` |
| Gateway unavailable and no fallback | `4` |
| Local runtime unavailable | `5` |
| Provider unavailable or missing secret | `6` |
| Policy block | `7` |
| Context access denied | `9` |

---

# 6. `ai-route`

## 6.1 Purpose

`ai-route` explains and tests routing decisions.

It should allow me to understand where a request would go before sending content to a model.

## 6.2 Contract

`ai-route` must:

- load the active or specified profile
- evaluate routing config
- explain selected route
- support synthetic test scenarios
- support sensitivity and task type
- avoid sending real prompts to model providers during dry-run route checks
- support routing validation tests

## 6.3 Initial syntax

```bash id="bl5f1g"
ai-route [options] ["prompt"]
```

## 6.4 Initial flags

| Flag | Required? | Meaning |
|---|---:|---|
| `--profile <name>` | No | Use a specific profile. |
| `--task <type>` | No | Declare task type. |
| `--sensitivity <level>` | No | Declare sensitivity level. |
| `--local` | No | Force local-only decision. |
| `--best` | No | Evaluate best allowed route. |
| `--provider <name>` | No | Evaluate requested provider. |
| `--explain` | No | Show detailed reasoning. |
| `--test` | No | Run routing validation tests. |
| `--json` | Future | Machine-readable output. |

## 6.5 Examples

```bash id="qxwi76"
ai-route --profile macos-work --task summarise --sensitivity internal --explain
```

```bash id="dsr6qs"
ai-route --profile macos-work --task architecture_review --sensitivity customer --best --explain
```

```bash id="ymxwks"
ai-route --test
```

## 6.6 Expected output

Route explanation:

```text id="32pawj"
Profile: macos-work
Task type: architecture_review
Sensitivity: customer
Requested mode: best

Selected route: approved_work
Provider priority:
- gemini
- cursor

Reason:
- macos-work prioritises approved work AI tools.
- customer sensitivity requires approved-tool posture.
- architecture_review may need stronger reasoning.
- Anthropic/OpenAI are use-case dependent and are not first route.
```

Routing test output:

```text id="ae0jmp"
Routing validation

route-001  macos-work        summarise/internal              PASS
route-002  macos-work        architecture_review/customer    PASS
route-003  macos-work        restricted content              PASS
route-006  windows-personal  coding_debug/best               PASS
route-009  gateway-down      degraded local fallback         PASS

Result: PASS
```

## 6.7 Exit code expectations

| Scenario | Exit code |
|---|---:|
| Route resolved successfully | `0` |
| Routing tests passed | `0` |
| Invalid task or sensitivity | `2` |
| Missing profile | `3` |
| Routing tests failed | `8` |
| Policy block | `7` |

---

# 7. `ai-status`

## 7.1 Purpose

`ai-status` shows the current health of the workstation.

It should answer:

```text id="jvze7f"
What profile is active?
Is the gateway healthy?
Are local runtimes available?
Are required providers/secrets available?
Are model aliases resolved?
Are there any warnings before I use the workstation?
```

## 7.2 Contract

`ai-status` must:

- show active profile
- show profile status
- check gateway health
- check local runtime health
- check required secrets availability without exposing values
- check provider configuration
- check model alias resolution
- show degraded mode availability
- show relevant warnings
- avoid printing secrets

## 7.3 Initial syntax

```bash id="qubls0"
ai-status [options]
```

## 7.4 Initial flags

| Flag | Required? | Meaning |
|---|---:|---|
| `--profile <name>` | No | Check a specific profile. |
| `--verbose` | No | Show more detail. |
| `--json` | Future | Machine-readable output. |

## 7.5 Example

```bash id="kj6m4q"
ai-status --profile macos-work
```

## 7.6 Expected output

Healthy profile:

```text id="v9xws4"
AI Lab Status

Profile: macos-work
Profile status: active
Risk posture: conservative

Gateway: OK
Secrets: OK
Local runtimes:
- omlx: OK
- ollama: OK fallback

Providers:
- gemini: configured
- cursor: available/manual
- anthropic: optional
- openai: optional

Routing:
- default: local_first
- approved tools first: true
- direct local fallback: limited

Model aliases:
- local_fast: configured
- local_capable: configured
- local_code: unresolved

Status: WARN
Next action:
- configure local_code alias or run ai-model-review
```

Gateway down:

```text id="qa4rf4"
AI Lab Status

Profile: windows-personal
Profile status: active

Gateway: FAIL
Local runtimes:
- ollama: OK

Degraded mode:
- direct local fallback: available for ask-ai --local

Status: WARN
Next action:
- start gateway service
- or use ask-ai --local for direct local fallback
```

## 7.7 Exit code expectations

| Scenario | Exit code |
|---|---:|
| All required checks pass | `0` |
| Warnings present, but usable | `0` |
| Required check fails | `8` |
| Missing profile | `3` |
| Gateway unavailable | `4`, if gateway is required for selected check |
| Local runtime unavailable | `5`, if required |
| Required secret unavailable | `6` |

---

# 8. `ai-bootstrap-check`

## 8.1 Purpose

`ai-bootstrap-check` validates whether a profile has been rebuilt or set up correctly.

It is stricter than `ai-status`.

`ai-status` answers:

```text id="zp8uoy"
What is the current health?
```

`ai-bootstrap-check` answers:

```text id="g6s772"
Is this profile set up enough to be considered rebuilt?
```

## 8.2 Contract

`ai-bootstrap-check` must:

- load selected profile
- check expected directories
- check required package/tool availability
- check secrets approach
- check gateway config exists
- check gateway can start or is reachable where required
- check local runtime availability
- check required config files
- check basic routing config
- check CLI commands are available
- run basic routing validation where practical
- report clear failures and next actions

## 8.3 Initial syntax

```bash id="brnlsb"
ai-bootstrap-check [options]
```

## 8.4 Initial flags

| Flag | Required? | Meaning |
|---|---:|---|
| `--profile <name>` | Yes initially | Validate a specific profile. |
| `--skip-gateway` | No | Skip live gateway check if still setting up. |
| `--verbose` | No | Show detailed checks. |
| `--json` | Future | Machine-readable output. |

## 8.5 Example

```bash id="mqg7wf"
ai-bootstrap-check --profile macos-work
```

## 8.6 Expected output

Passing with warnings:

```text id="w3ul7e"
Bootstrap check: macos-work

Directories:
- profiles/: OK
- config/: OK
- tools/: OK
- tests/: OK

Config:
- profile.yaml: OK
- providers.yaml: OK
- routes.yaml: OK
- models.yaml: WARN local_code unresolved

Secrets:
- Bitwarden: OK
- .env.local fallback: not used

Gateway:
- config: OK
- service: OK
- health: OK

Local runtimes:
- omlx: OK
- ollama fallback: OK

Routing:
- route-001: PASS
- route-002: PASS
- route-003: PASS

Status: WARN
Result:
Profile is usable, but model aliases need review.
```

Failing:

```text id="d7id6h"
Bootstrap check: windows-personal

Config:
- profile.yaml: OK
- providers.yaml: OK
- routes.yaml: missing

Gateway:
- config: missing
- health: skipped

Local runtimes:
- ollama: FAIL not reachable

Secrets:
- Bitwarden: OK
- OPENAI_API_KEY: missing
- ANTHROPIC_API_KEY: missing

Status: FAIL

Next actions:
1. create config/routes.yaml
2. start Ollama or install local runtime
3. configure required provider secrets in Bitwarden or .env.local fallback
```

## 8.7 Exit code expectations

| Scenario | Exit code |
|---|---:|
| Bootstrap check passed | `0` |
| Passed with warnings | `0` |
| Invalid arguments | `2` |
| Missing profile | `3` |
| Required gateway check failed | `4` |
| Required local runtime check failed | `5` |
| Required secret missing | `6` |
| Validation failed | `8` |

---

# 9. `ai-model-review`

## 9.1 Purpose

`ai-model-review` supports the model fitness loop.

It should help me review which local models are suitable for each profile and which aliases should map to which models.

This command belongs to Milestone 3, but the contract is defined early because routing depends on model aliases.

## 9.2 Contract

`ai-model-review` should:

- run or summarise model fitness checks
- support profile-specific reviews
- use llmfit where useful
- support gateway-based prompt checks as fallback or complement
- capture results in a repeatable location
- recommend updates to model aliases
- avoid treating any one tool as a permanent dependency

## 9.3 Initial syntax

```bash id="yw6bdi"
ai-model-review [options]
```

## 9.4 Initial flags

| Flag | Required? | Meaning |
|---|---:|---|
| `--profile <name>` | Yes | Review models for a profile. |
| `--runtime <name>` | No | Review a specific runtime. |
| `--alias <name>` | No | Review suitability for a specific alias. |
| `--run` | No | Run model checks. |
| `--summarise` | No | Summarise existing results. |
| `--json` | Future | Machine-readable output. |

## 9.5 Example

```bash id="un32z4"
ai-model-review --profile macos-work --run
```

```bash id="wprssl"
ai-model-review --profile windows-personal --alias local_code
```

## 9.6 Expected output

```text id="19284i"
Model review: macos-work

Runtime:
- omlx: available
- ollama: available fallback

Aliases:
- local_fast: candidate model tbd
- local_capable: candidate model tbd
- local_code: unresolved

Findings:
- local_fast needs a small, responsive model.
- local_capable should prioritise summarisation and reasoning quality.
- local_code may be better served by Ollama fallback if oMLX model support is limited.

Recommendations:
1. run llmfit or gateway-based checks for local_fast
2. test local_code through Ollama fallback
3. update config/models.yaml once candidates are selected
```

## 9.7 Exit code expectations

| Scenario | Exit code |
|---|---:|
| Review completed | `0` |
| Invalid arguments | `2` |
| Missing profile | `3` |
| Runtime unavailable | `5` |
| Review could not run | `8` |

---

# 10. Future command conventions

Future commands should follow the same contract pattern.

Expected future commands:

| Command | Purpose |
|---|---|
| `dev-ai` | Coding and repo-aware development workflow. |
| `architect-ai` | Architecture reasoning, option analysis and decision review. |
| `write-ai` | Writing, rewriting and tone refinement. |
| `research-ai` | Research, synthesis and comparison workflows. |
| `agent-ai` | Controlled agent workflows. |
| `ai-secrets` | Centralised secrets lookup helper, if needed. |

Each future command should define:

- purpose
- profile behaviour
- routing behaviour
- allowed context
- flags
- output format
- exit codes
- logging behaviour
- degraded-mode behaviour, if applicable

---

## 11. Minimum Milestone 1 CLI contract

Milestone 1 should implement the smallest useful version of:

```text id="hgoyzx"
ask-ai
ai-route
ai-status
ai-bootstrap-check
```

The minimum viable contract is:

| Command | Minimum viable behaviour |
|---|---|
| `ask-ai` | Send a local prompt through gateway or configured local fallback. |
| `ai-route` | Explain expected route for a profile/task/sensitivity. |
| `ai-status` | Show active profile, gateway health, runtime health and secrets status. |
| `ai-bootstrap-check` | Validate required profile/config/runtime/gateway basics. |

Milestone 1 does not need complete JSON output, advanced route classification, full provider automation or polished UX.

It does need clear behaviour, predictable failures and enough structure to build on.

---

## 12. Summary

The CLI contract is:

```text id="5dr4xv"
Stable command names.
Profile-aware behaviour.
Gateway-first routing.
Explicit degraded modes.
Predictable output.
Consistent exit codes.
Metadata-only logs.
No secrets or sensitive prompt content in output or logs.
```

These contracts should guide the implementation of the first workstation commands.
