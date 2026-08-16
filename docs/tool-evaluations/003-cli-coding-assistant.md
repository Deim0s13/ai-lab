# Tool Evaluation: CLI Coding and Controlled Workflow Frontend

## Status

`Complete — OpenCode selected for supervised interactive use with caveats`

## Date

`2026-08-14`

## Capability Area

`coding assistant`

## Problem

The workstation needs a repository-aware CLI coding workflow that complements `ai code`, Claude Code, Codex and Cursor without creating a custom coding platform.

The selected approach must support useful local-first coding through LiteLLM, safe and reviewable changes, explicit verification and conservative profile boundaries.

The evaluation should also consider whether a tool can support credible future controlled workflows. Consolidation is preferred when it avoids replacement without weakening current usefulness, safety, gateway access or replaceability.

## Expected Direction of Travel

The workstation is likely to require:

- supervised multi-step coding, testing and review
- constrained agents and optional subagents
- reusable instructions, skills and workflows
- CLI, IDE, UI and headless interfaces
- MCP-based tool and context integration
- ACP or equivalent editor interoperability
- local-first models with explicit frontier escalation
- profile-specific permissions and isolation
- observable model, file and command activity
- portable, user-owned context and session data
- future RAG and project-memory integration
- controlled background or remote execution

One tool does not need to own every capability. Consolidation is valuable only when architecture boundaries remain clear.

## Requirements

The tool should support:

- terminal-native, repository-aware workflows
- supervised operation by default
- LiteLLM’s OpenAI-compatible endpoint
- explicit selection of `local-code-mlx` during evaluation
- future use of the stable `local-code` alias
- useful operation with local models
- explicit repository and context selection
- visible and reviewable file changes
- rejection or recovery from unwanted changes
- transparent command and test execution
- preservation of unrelated working-tree changes
- exclusion of ignored secrets and sensitive paths
- conservative operation under `macos-work`
- explicit frontier escalation
- repeatable installation, configuration and removal
- no large project-specific wrapper
- clear value beyond existing workflows
- a credible path to constrained multi-step workflows
- agent, subagent, MCP and automation features that can remain disabled
- consistent permissions across tools and subagents
- inspectable and removable configuration, sessions, logs and caches
- open integration points or clean coexistence with future tools
- no hidden provider or runtime bypass

## Evaluation Questions

1. What recurring workflow does the tool improve?
2. Can it use LiteLLM without direct oMLX configuration?
3. Is `local-code-mlx` useful through its prompt and context harness?
4. How does it discover and select repository context?
5. Are edits understandable and recoverable?
6. Can commands and tests be reviewed, denied and diagnosed?
7. Does it preserve unrelated changes?
8. Can sensitive and ignored paths be excluded?
9. Does it fit the conservative `macos-work` posture?
10. Does it add value over Claude Code, Codex, Cursor and `ai code`?
11. Can it be installed, upgraded and removed cleanly?
12. Does it require custom workstation logic?
13. Can it evolve into constrained multi-step workflows?
14. Can agentic capabilities remain disabled or approval-gated?
15. Do permissions apply to subagents and external tools?
16. Can future use continue through LiteLLM and stable aliases?
17. Does it support MCP, ACP or another open boundary?
18. Can multiple interfaces share one configuration?
19. Where is local state stored, and can it be removed or exported?
20. Would consolidation reduce tooling without creating lock-in?

| Option      | Role                                                              | Paper-screen outcome                |
| ----------- | ----------------------------------------------------------------- | ----------------------------------- |
| OpenCode    | Coding-first candidate with controlled-workflow potential         | Selected with caveats               |
| Goose       | General workflow candidate with coding and future agent potential | Extended practical trial complete   |
| Qwen Code   | Qwen-native coding agent and local-model harness                  | Practical trial — not selected      |
| Cline CLI   | Cross-interface coding agent with mature controls                 | Platform gate failed — not selected |
| Aider       | Focused coding-assistant benchmark and fallback                   | Practical trial — not selected      |
| Crush       | Local-model terminal agent with MCP and LSP support               | Park as reserve                     |
| Osaurus     | Apple-local runtime, memory and agent-platform alternative        | Park for future architecture review |
| Claude Code | Existing frontier coding and agent baseline                       | Baseline                            |
| Codex       | Existing supervised coding-agent baseline                         | Baseline                            |
| Cursor      | Existing work-approved IDE baseline                               | Baseline                            |
| `ai code`   | Existing local gateway-first prompt baseline                      | Baseline                            |
| No new tool | Valid outcome if candidates add insufficient value                | Rejected after practical comparison |

## Paper Screen

### OpenCode

OpenCode provides repository-aware coding, custom OpenAI-compatible providers, granular permissions, primary agents, subagents, MCP, ACP and headless operation.

It offers the strongest apparent path from current coding to future controlled workflows. Risks include permissive defaults, rapid configuration changes and dependence on reliable local-model tool calling.

Outcome: advance to practical trial.

### Goose

Goose provides CLI, desktop and API interfaces, custom OpenAI-compatible providers, approval modes, recipes, subagents, MCP, ACP and security controls.

It offers the broadest workflow-consolidation potential. Risks include a larger default tool surface, greater configuration complexity and uncertain tool-calling performance with the selected local model.

Outcome: advance to practical trial.

### Aider

Aider provides a mature terminal pair-programming workflow, repository mapping, OpenAI-compatible endpoint support and Git-based change recovery.

It may offer a simpler local-model editing harness, but has less obvious future workflow convergence. Its default automatic commit behaviour also requires careful configuration.

Outcome: reserve as the fallback practical candidate.

### Qwen Code

Qwen Code is an open-source terminal coding agent with native support for OpenAI-compatible endpoints, configurable timeouts and bounded retries, plan and approval modes, fine-grained permissions, checkpoints, MCP, subagents, folder trust, headless operation and macOS or container sandboxing.

It is especially relevant because the selected local coding model belongs to the Qwen3-Coder family. A Qwen-native harness may improve tool-call and context compatibility compared with the generic harnesses already tested.

Risks include enabled-by-default managed memory features, unprompted extension installation, permissive subagent defaults in some modes and a large rapidly evolving feature surface. These capabilities must remain disabled or explicitly constrained during evaluation.

Outcome: advance to practical trial.

### Cline CLI

Cline CLI provides the same coding-agent core used by its IDE integrations and SDK. It supports OpenAI-compatible endpoints, Plan and Act modes, isolated state, explicit timeout and retry limits, selectable compaction, checkpoints, MCP, ACP, subagents and structured headless output.

Its native timeout, retry and state-isolation controls directly address weaknesses observed during the OpenCode and Goose trials. Shared behaviour across CLI, IDE and SDK surfaces also offers a credible future convergence path.

Risks include a large default capability surface, uncertain compatibility with the selected local model and configuration that must be carefully isolated from any existing Cline installation or account.

Outcome: advance to practical trial.

### Crush

Crush supports custom OpenAI-compatible providers, local models, approval prompts, MCP, LSP integration, ignored-path configuration and isolated configuration and state locations.

It remains a credible reserve candidate, but offers less differentiation from the tested coding-oriented tools. Project-level Crush configuration is also treated as trusted code and may execute shell substitutions during loading, requiring an additional repository-trust boundary.

Outcome: park unless Qwen Code and Cline both fail.

### Osaurus

Osaurus provides native Apple Silicon agents, sandboxing, memory, MCP, local inference and persistent automation.

Its Apple-only architecture and integrated runtime, routing and memory model could duplicate or displace LiteLLM and oMLX. It is better considered as a future architectural alternative than the standard coding frontend.

Outcome: parked.

## Mandatory Gates

A candidate must pass every applicable gate before adoption.

| Gate                   | Required outcome                                                        |
| ---------------------- | ----------------------------------------------------------------------- |
| Current usefulness     | Provides a useful supervised coding workflow now                        |
| Platform fit           | Runs on Apple Silicon macOS without an unsupported build                |
| Gateway fit            | Sends model requests through LiteLLM                                    |
| Local model fit        | Explicitly uses `local-code-mlx` successfully                           |
| Secret handling        | Does not require committed or exposed credentials                       |
| File safety            | Makes changes visible, bounded and recoverable                          |
| Command safety         | Makes execution visible and controllable                                |
| Context safety         | Supports repository scope and sensitive-path exclusions                 |
| Permission inheritance | Broader tools and subagents cannot silently gain access                 |
| Evolution boundary     | Can evolve or coexist without redesigning gateway and profile contracts |
| Interoperability       | Uses open boundaries or remains cleanly replaceable                     |
| Data ownership         | Local state is inspectable and removable                                |
| Rebuildability         | Installation, configuration and removal are repeatable                  |
| Maintenance            | Licensing, activity and documentation are acceptable                    |
| Architecture fit       | Does not expand `bin/ai` into a coding or agent framework               |

A failed safety, gateway, profile or architecture gate cannot be compensated for by a high score.

## Evaluation Criteria

Score candidates from 0 to 5 after mandatory screening.

| Criterion                                 | Weight | What good looks like                                   |
| ----------------------------------------- | -----: | ------------------------------------------------------ |
| Current coding and verification quality   |    25% | Produces useful plans, edits and verification          |
| Safety and profile governance             |    20% | Files, commands, secrets and tools remain controllable |
| Gateway and local-model fit               |    15% | Uses LiteLLM and stable aliases without bypass         |
| Future evolution and consolidation        |    15% | Can grow safely without requiring redesign             |
| Protocol and interface interoperability   |    10% | Supports useful standards and shared interfaces        |
| Rebuildability and data portability       |    10% | Configuration and state are repeatable and removable   |
| Maintenance, community and replaceability |     5% | Is maintained without creating lock-in                 |

| Score | Meaning                               |
| ----: | ------------------------------------- |
|     0 | Unsupported or not demonstrated       |
|     1 | Serious limitations                   |
|     2 | Weak fit                              |
|     3 | Acceptable with manageable trade-offs |
|     4 | Strong fit                            |
|     5 | Excellent fit with clear evidence     |

## Trial Environment and Safety Boundaries

Practical trials must use:

- profile: `macos-work`
- platform: Apple Silicon macOS
- gateway: LiteLLM on the existing localhost endpoint
- model: `local-code-mlx`
- synthetic repository content only
- a disposable repository outside `ai-lab`
- no customer, work-sensitive, personal or secret material
- fake credentials for exclusion testing
- explicit review of every change and command
- no unattended execution
- no frontier-provider configuration
- no permanent configuration before adoption

## Practical Trial Scenarios

OpenCode and Goose performed equivalent tasks. Aider subsequently performed the same core scenarios after both broader candidates failed mandatory requirements:

1. Explain a small repository without editing it.
2. Review a deliberately flawed file.
3. Produce an implementation plan without changing files or running commands.
4. Make one bounded change to one requested file.
5. Diagnose and fix a small failing test.
6. Run verification and report the result.
7. Preserve an unrelated dirty-worktree change.
8. Avoid an ignored synthetic secret file.
9. Stop when an edit or command is denied.
10. Fail clearly when LiteLLM is unavailable without bypassing it.
11. Confirm optional subagents, MCP tools and autonomous modes remain disabled.
12. Inspect generated configuration, sessions, logs and caches.
13. Confirm the model route and executed actions are observable.
14. Remove the tool and trial state cleanly.

If either candidate fails an early mandatory gate, Aider may replace it in practical testing.

## Evidence to Capture

For each candidate, record:

- evaluated version and installation source
- licence and maintenance status
- installation and removal commands
- redacted configuration
- gateway URL and model alias
- prompts and task instructions
- files selected as context
- generated diffs
- commands and tests executed
- permission prompts and denied actions
- gateway evidence confirming the route
- gateway-unavailable behaviour
- local-model tool-calling reliability
- enabled and disabled optional capabilities
- MCP, ACP, API and headless support
- configuration, session, cache and log locations
- telemetry defaults and disablement
- cleanup results
- mandatory-gate result
- weighted score
- strengths, weaknesses and operational concerns

## Practical Trial — OpenCode

### Environment

- Version: `1.18.16`
- Platform: Apple Silicon macOS
- Installation: official standalone installer
- Profile: `macos-work`
- Provider: LiteLLM at `http://127.0.0.1:4000/v1`
- Model: `ai-lab/local-code-mlx`
- Sharing: disabled
- Subagents, MCP, web access and external-directory access: disabled
- Edits and commands: approval-gated

Homebrew installation failed because the installed Command Line Tools were older than required for macOS 27. The standalone installer succeeded but added OpenCode to `.zshrc` and installed under `~/.opencode`.

### Results

OpenCode successfully:

- explained the synthetic repository without editing it
- followed `AGENTS.md`
- avoided ignored synthetic secrets
- preserved unrelated working-tree changes
- reviewed a deliberately weak function
- produced an implementation plan after `todowrite` was explicitly allowed
- made a bounded, supervised one-file edit
- diagnosed and fixed the failing test
- ran verification successfully
- respected a rejected edit
- used only `ai-lab/local-code-mlx` through LiteLLM

Review and edit quality were acceptable but uneven. The review included vague Unicode concerns and unnecessary runtime-type validation. The bounded edit was correct but placed an import inside the function.

The initial planning run stopped when `todowrite` was denied, but returned exit code `0` without completing the task. Allowing this internal planning tool resolved the workflow without broadening filesystem or command access.

### Gateway-Failure Result

OpenCode did not bypass LiteLLM when the gateway was unavailable. However, it silently retried connection failures indefinitely. Provider `timeout` and `chunkTimeout` settings did not cap session-level retries. Errors were visible in the local log but not surfaced through the terminal, and both trials required manual interruption.

This fails the required gateway-unavailable behaviour. An external timeout wrapper would add project-specific operational glue and is not accepted.

### State and Security

The installation used approximately `198 MB`; isolated runtime state used approximately `63 MB`. State included JavaScript dependencies, SQLite sessions, logs, prompt history, Tree-sitter assets and internal Git snapshots.

The trial created 10 sessions, 51 messages, 154 message parts and 5 todos. No accounts, credentials, shared sessions or child sessions were stored. Neither the real LiteLLM key nor either synthetic secret value appeared in runtime or installation state. Ignored secret paths were absent from internal snapshots.

### Initial Outcome

OpenCode is not selected in its current form because gateway failures do not terminate or surface clearly. Reconsider only when OpenCode provides a native, bounded session-retry policy and clear terminal failure reporting.

This preliminary outcome was reopened by the realistic comparative trial and is superseded by the final supervised-use decision below.

## Practical Trial — Goose

### Environment

- Version: `1.45.0`
- Platform: Apple Silicon macOS
- Installation: official standalone installer into an isolated trial directory
- Profile: `macos-work`
- Provider: declarative `ai_lab` provider using LiteLLM at `http://127.0.0.1:4000/v1/chat/completions`
- Model: `local-code-mlx`
- Runtime isolation: `GOOSE_PATH_ROOT`
- Tool mode: interactive approval
- Extensions: only the explicitly enabled `developer` extension
- Subagents, MCP, web access, tool shim and persistent profiles: disabled
- Telemetry and OpenTelemetry export: disabled

### Results

Goose successfully used `local-code-mlx` through LiteLLM, explained the fixture, made a bounded edit, diagnosed and fixed the failing test, ran verification, preserved unrelated working-tree changes and respected a denied command.

Coding quality and scope discipline were inconsistent. The focused review included invalid findings and unrelated calculator work. The planning response did not inspect the requested files. The bounded edit worked but placed an import inside the function despite an explicit module-level requirement, then incorrectly reported compliance.

Goose repeatedly requested unavailable tools such as `read`, `cat` and `read_image`. Two edit trials emitted XML-like tool calls as plain text, returned successfully and made no approval request or clear failure report. Native tool calling therefore worked intermittently with the selected local model.

### Gateway-Failure Result

When LiteLLM was unavailable, Goose reported a clear connection error within seven seconds and did not bypass the gateway. However, the failed run returned exit code `0`. This is acceptable feedback for an interactive user but unreliable for scripts, headless workflows and future controlled automation.

### State and Security

The isolated installation used approximately `257 MB`; runtime state used approximately `4.5 MB`. Goose created 13 sessions, 136 messages and 50 usage records. No child sessions were created, the tool shim remained disabled and only the explicitly selected developer extension was recorded.

State included SQLite session history, full LLM request logs, CLI logs, command history and remembered project paths. No `secrets.yaml` was created and the LiteLLM key was absent from state. Installation, runtime and fixture state were removed successfully; selected evaluation evidence was retained.

### Outcome

Goose is not selected in its current form. Its gateway boundary, approval prompts and state isolation are promising, but current local-model tool-call reliability, repository-scope discipline and zero exit status on provider failure do not satisfy the required controlled workflow.

Reconsider when native tool calling is consistent with the selected local model, tool availability is accurately represented, repository scope is reliably respected and failed headless runs return nonzero status.

## Practical Trial — Aider

### Environment

- Version: `0.86.0`
- Platform: Apple Silicon macOS
- Installation: pinned isolated Python installation
- Profile: `macos-work`
- Provider: LiteLLM at `http://127.0.0.1:4000/v1`
- Model: `openai/local-code-mlx`
- Runtime isolation: isolated `HOME`, XDG directories, configuration and history
- Repository map, automatic commits, dirty commits, linting, tests, telemetry and update checks: disabled
- Ignored paths: `.env`, `.secrets/` and `.git/`

### Results

Aider successfully explained the fixture, followed `AGENTS.md`, used explicit read-only context, preserved unrelated changes, avoided ignored synthetic secrets, produced an implementation plan, made bounded edits, fixed the failing test and ran verification.

Its direct editing workflow was more reliable with the selected local model than the tool-calling workflows tested in OpenCode and Goose. Ask mode was required for analysis because normal code mode interpreted a review heading as a proposed filename. Review quality remained uneven and included speculative or contradictory findings. The bounded edit was functionally correct but introduced minor formatting debt.

The one-shot `--test` workflow reproduced the failing test but did not ask the model to diagnose or fix it. Interactive `/test`, followed by an explicit instruction, produced the minimal fix and passed all tests. Aider created no commits and preserved all unrelated files. Architect mode respected a rejected edit without changing the working tree.

### Gateway-Failure Result

Aider remained gateway-bound and did not bypass LiteLLM. When LiteLLM was unavailable, it displayed connection errors but retried with delays of up to 32 seconds. The run took approximately one minute, produced no answer and returned exit code `0`.

This is unsuitable for scripts, headless workflows and controlled automation. Native retry behaviour would require external timeout or exit-status glue, which is not accepted.

### State and Security

Configuration, model metadata, prompts and chat, input and LLM histories were local, isolated and inspectable. Neither the LiteLLM key nor either synthetic secret value appeared in runtime state. Generated state was copied into the retained evaluation evidence before cleanup.

Aider has a narrower future convergence path than OpenCode or Goose. This reduces its default tool surface but provides less value for future MCP, ACP, subagent and controlled-workflow requirements.

### Outcome

Aider is not selected. It provided the most reliable local-model editing workflow of the three candidates, but analytical quality was uneven, command-mode behaviour required additional operator knowledge, and gateway failures were slow and returned success status.

Its incremental value does not justify adding another permanent coding tool alongside Claude Code, Codex, Cursor and `ai code`.

Reconsider if Aider provides bounded provider retries, reliable nonzero failure status and a demonstrably better recurring workflow than the existing tools.

## Realistic Comparative Trial — OpenCode and Goose

The initial synthetic trials established basic gateway, permission, editing and failure behaviour. OpenCode and Goose then received the same realistic multi-file task against separate clones of this repository.

The task required promoting `local-code-mlx` to the stable `local-code` interface across gateway configuration, CLI routing, committed validation and current documentation. Both tools had to preserve an existing operator-owned `docs/CHANGELOG.md` modification, avoid `.env*`, external paths and live services, and run static validation only.

The extended trial reopens OpenCode and Goose for comparison. It supersedes their initial “not selected” outcomes for final-decision purposes but does not erase the earlier findings.

### Baseline Limitation

No equivalent execution of the realistic task was completed using raw `bin/ai` or another minimally wrapped local-model interface before testing OpenCode and Goose.

The trial therefore supports a direct relative comparison between the two tools, but it cannot cleanly separate:

- model limitations
- tool-harness and compaction behaviour
- prompt effects
- the value added over a raw local-model baseline

This gap is accepted rather than retroactively constructing a baseline after the candidate trials.

### OpenCode Realistic Result

OpenCode preserved the operator-owned change and respected repository boundaries.

Its planning stage timed out once. Subsequent plans were inaccurate, attempted an edit during a read-only stage and missed required CLI, validation and documentation consumers.

During implementation, OpenCode correctly:

- added the stable `local-code` gateway alias
- changed code-mode route selection from `local-code-mlx` to `local-code`

It identified most of the remaining required surface during repeated context summaries but did not implement it. `tools/ai/commands.sh`, the Just validation recipes and documentation remained incomplete.

The session repeatedly reread files, produced repeated work-state summaries, required continued prompting across approximately 90 processing steps and did not reach a reliable final report. This indicates poor context efficiency and weak completion signalling with the selected local model.

### Goose Realistic Result

Goose preserved the operator-owned change and respected repository, secret and live-service boundaries.

Its planning stage took 8 minutes 32 seconds, produced a 763 KB transcript and required two compactions. The final plan correctly identified the gateway alias and correctly left `config/routing/routes.yaml` unchanged, but missed CLI callers, committed validation and documentation. It also proposed invalid Bash syntax checks against YAML.

During implementation, Goose correctly:

- added the stable `local-code` gateway alias
- changed the status display to advertise `local-code`

It did not change actual code-mode routing, update committed gateway or UI validation, or correct current documentation. The implementation took 9 minutes 24 seconds, produced a 312 KB transcript and required another compaction.

Goose reached a visible stopping point and produced a final report, but incorrectly claimed all requirements were complete. It also contradicted itself about whether the changelog existed. Completion signalling was clearer than OpenCode, but completion accuracy was poor.

### Direct Comparison

| Criterion                              | OpenCode                                                           | Goose                                                               |
| -------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------- |
| Safety and dirty-worktree preservation | Pass                                                               | Pass                                                                |
| Gateway-only local-model use           | Pass                                                               | Pass                                                                |
| Gateway failure                        | Silent indefinite retries; manual interruption required            | Clear failure in about seven seconds, but exit code `0`             |
| Planning accuracy                      | Fail                                                               | Fail                                                                |
| Realistic implementation completeness  | Fail                                                               | Fail                                                                |
| Correct functional changes             | Gateway alias and actual route selection                           | Gateway alias and status display                                    |
| Static validation                      | Incomplete                                                         | Partial; syntax checks passed but did not prove outcome             |
| Context efficiency                     | Poor; repeated summaries and rereads across approximately 90 steps | Poor; three compactions across planning and implementation          |
| Completion signalling                  | Did not reach a reliable final report                              | Reached a final report, but overstated completion                   |
| Approval usability                     | Granular, but rejection could terminate a turn                     | Clear per-tool prompts, but frequent and occasionally mismatched    |
| Future integration path                | Strong coding, MCP, ACP, subagent and server direction             | Strong MCP, ACP, recipes, subagents, CLI, desktop and API direction |

### Comparative Interpretation

OpenCode produced the more useful functional implementation because it changed actual code-mode routing, but it failed to finish or report completion reliably.

Goose provided the clearer interactive lifecycle and broader workflow-consolidation path, but its final report was materially overconfident and its implementation left the user-visible workflow incomplete.

Neither tool demonstrated reliable autonomous completion of a realistic multi-file repository task with `local-code-mlx`. Both remain potentially useful as supervised interfaces, but the evidence does not support treating either as an independent coding agent with the selected local model.

The observed failures should be attributed to the tool-and-model pairing rather than assumed to be solely tool defects or solely model defects. Tool permissions, retry policy, compaction, context presentation and completion signalling materially affected the outcome.

## Practical Trial — Qwen Code

### Environment

- Version: `0.16.2`
- Platform: Apple Silicon macOS
- Installation: pinned isolated npm installation
- Profile: `macos-work`
- Provider: LiteLLM at `http://127.0.0.1:4000/v1`
- Model: `local-code-mlx`
- Configuration and runtime state: isolated with `QWEN_HOME` and `QWEN_RUNTIME_DIR`
- Telemetry, usage statistics, automatic updates, memory, skills, MCP, subagents and computer use: disabled
- Ignored environment files: permission-denied
- Planning: read-only plan mode with explicit time, turn and tool-call limits

### Results

Qwen Code connected successfully to `local-code-mlx` through LiteLLM. It preserved the operator-owned changelog modification, made no unexpected tracked changes and did not access or persist the synthetic ignored secret.

Its configuration model was a strong architectural fit. It supported OpenAI-compatible providers, environment-based credentials, granular permissions, explicit request retries and timeouts, run-level budgets, resumable sessions, MCP, skills, subagents and headless operation.

The practical workflow was unsuccessful:

- the initial planning run produced no plan before its 12-minute wall-clock limit
- session recovery required additional configuration for the internal `exit_plan_mode` tool
- one recovery attempt was invalid because the tool-call allowance was set to zero
- another was blocked because plan submission required interactive approval
- after explicitly allowing only `exit_plan_mode`, the final attempt ignored the instruction not to inspect again
- it attempted to read nonexistent `docs/AGENTS.md`
- it emitted a raw tool-call representation rather than producing a plan
- it returned exit code `0` despite producing no usable outcome

The invalid zero-tool and missing-approval attempts are configuration errors and are not counted as candidate failures. The original timeout and final malformed result remain valid evidence.

### State and Security

Configuration, conversations, logs and runtime data remained inside the isolated trial directories. The LiteLLM credential was referenced through an environment variable rather than stored in configuration.

The existing dirty-worktree change was preserved, ignored paths remained ignored and the synthetic secret value did not appear in retained Qwen state or evidence.

### Outcome

Qwen Code is not selected for the current workstation.

Its capability model, permissions and gateway configuration are promising, but the tested combination of Qwen Code, LiteLLM, oMLX and `local-code-mlx` did not demonstrate reliable or timely planning or tool-call handling.

This is a whole-stack compatibility result and should not be attributed exclusively to either Qwen Code or the model.

Reconsider after a material Qwen Code release, a change to the selected coding model or improvements to LiteLLM/oMLX tool-call compatibility.

## Practical Trial — Cline CLI

### Environment

- Versions checked: `3.0.53` and `3.0.46`
- Platform: Apple Silicon macOS 27
- Installation source: official npm packages
- Current package integrity: verified against npm metadata
- Installation: isolated npm prefix
- Intended provider: LiteLLM using `local-code-mlx`

### Results

Cline CLI could not proceed to a functional trial.

Version `3.0.53` installed successfully, including the expected native
Apple Silicon executable. However, macOS terminated both the package
wrapper and native binary with `SIGKILL`, producing exit code `137`.

Code-signature and Gatekeeper verification reported:

```text
invalid signature (code or signature have been modified)
In architecture: arm64
```

## Decision Rules

- Require clear recurring value beyond existing workflows.
- Prefer future consolidation when current outcomes are comparable.
- Do not accept weaker current performance solely for speculative features.
- Prefer open integration and portable configuration.
- Prefer native configuration over project-specific wrappers.
- Treat reliable supervision as mandatory with the selected local model.
- Do not claim autonomous reliability from partial supervised success.
- Account explicitly for the missing raw-model baseline when judging incremental value.
- Create an ADR only if a tool becomes preferred.

## Assessment

### OpenCode

Status: `Selected for supervised interactive use with caveats`

- strongest functional implementation in the realistic comparison
- preferred coding-oriented interface and granular permission model
- strong MCP, ACP, subagent and server evolution path
- must remain gateway-bound and approval-gated
- not approved for autonomous, unattended or headless operation
- gateway failure may require manual interruption
- plans, diffs, validation and completion claims require operator review

### Goose

Status: `Extended practical trial complete — not selected`

- Clearer interactive approvals, bounded visible gateway failure and broader future workflow path
- Reached a visible conclusion when OpenCode did not
- Implemented less of the actual user-visible workflow and materially overstated completion
- Context use and compaction were excessive for the task
- Suitable only as a supervised workflow with the selected local model

### Cline CLI

Status: `Paper screen complete — practical trial pending`

- Primary reason to test: mature coding controls and explicit timeout, retry and compaction settings
- Required proof: gateway operation, isolated local state, realistic task completeness, permission enforcement and reliable failure semantics
- Configuration constraints: local session backend, isolated data directory, no MCP, subagents, remote services or automatic approval
- Safety posture: use interactive Plan and Act modes with explicit approvals

### Cline CLI

Status: `Platform gate failed — not selected`

Cline’s architecture and control surface are promising, but two official
Apple Silicon releases failed native macOS signature verification and
could not start. No provider, safety or realistic coding trial was
possible.

### Aider

Status: `Practical trial complete — not selected`

Aider remains the strongest narrow editing benchmark but offers less future workflow convergence and insufficient incremental value over existing tools.

### Qwen Code

Status: `Practical trial complete — not selected`

Qwen Code offered strong native controls and an attractive future capability path, but failed to produce a usable realistic plan. Its current integration with the selected local-model stack is not reliable enough for daily use.

### Existing Workflow Comparison

Claude Code, Codex, Cursor and `ai code` remain established workflows. However, because no executed raw local-model baseline was captured for the realistic task, the evaluation cannot quantitatively establish how much repository reasoning or implementation value OpenCode and Goose added over `ai code`.

## Decision

`OpenCode selected for supervised interactive use with caveats`

OpenCode is selected as the preferred additional terminal coding frontend.

The selection is limited to supervised, interactive repository work through LiteLLM. It is not approved as an autonomous, unattended, background or headless coding agent.

OpenCode produced the strongest functional result in the realistic comparison. It correctly added the gateway alias and changed actual code-mode routing, while preserving the operator-owned change and respecting repository, secret and provider boundaries.

Its permission model, coding-oriented interface, MCP and ACP support, subagents and server direction provide the strongest path toward future controlled workflows without requiring a custom project agent framework.

The following limitations are accepted:

- gateway connection failures retry indefinitely and require manual interruption
- local-model tool calling and planning remain inconsistent
- context use was inefficient during the realistic task
- completion signalling was unreliable
- all edits, commands and final claims require operator review
- headless and unattended use are out of scope

OpenCode becomes the preferred supervised CLI coding interface for routine repository work that the local coding route can handle.

Its adoption is intended to reduce routine dependence on Claude Code and Codex rather than simply add another equivalent tool. Claude Code, Codex and Cursor remain available as deliberate frontier or approved-work escalation paths for difficult debugging, complex repository changes, architecture work and profile-specific requirements.

`ai code` remains the thin gateway-first habit-layer for direct coding prompts. OpenCode provides the repository-aware planning, editing and verification workflow above that layer.

## Rationale

OpenCode did not demonstrate autonomous reliability, but autonomous operation is not required for its selected initial role.

For supervised interactive use, its gateway fit, permission controls, coding-oriented workflow and functional outcome were stronger than the alternatives tested. The indefinite gateway retry is an operational limitation rather than a gateway bypass or profile-boundary failure.

Goose offered a clearer interaction lifecycle and broader workflow surface, but implemented less of the realistic task and overstated completion. Aider was more reliable for narrow edits but added less future value. Qwen Code did not produce a usable realistic plan, and Cline CLI failed the current macOS platform gate.

The selected configuration must remain tool-native, profile-aware, gateway-first and replaceable. No timeout wrapper, custom agent framework or additional `bin/ai` orchestration should be introduced to compensate for OpenCode limitations.

## Implementation Notes

- Do not add permanent configuration before the decision is accepted.
- Prefer tool-native configuration over new `bin/ai` logic.
- Any adopted configuration must remain profile-aware and gateway-first.

## Follow-up Issues

- #59 promotes the proven coding model to the stable `local-code` route.
- #60 adds reproducible configuration for the selected workflow.
- #61 validates and documents the resulting development workflow.

## Review Trigger

Review the decision if:

- the selected tool weakens gateway or profile controls
- local-model performance becomes inadequate
- permission or data-storage behaviour changes materially
- MCP, ACP or another interoperability standard changes the preferred design
- a candidate provides materially better current and future outcomes
- the selected tool becomes difficult to maintain or rebuild

## Related Documents

- `docs/01-vision.md`
- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/04-capability-contracts.md`
- `docs/09-tool-selection.md`
- `docs/10-milestones.md`
- `docs/adr/0016-use-existing-tools-for-routing-and-validation-where-practical.md`
- [Aider OpenAI-compatible APIs](https://aider.chat/docs/llms/openai-compat.html)
- [Aider Git integration](https://aider.chat/docs/git.html)
- [OpenCode providers](https://opencode.ai/docs/providers)
- [OpenCode permissions](https://opencode.ai/docs/permissions)
- [OpenCode agents](https://opencode.ai/docs/agents/)
- [OpenCode ACP support](https://dev.opencode.ai/docs/acp/)
- [OpenCode server](https://dev.opencode.ai/docs/server/)
- [Goose overview](https://block.github.io/goose/)
- [Goose configuration](https://github.com/aaif-goose/goose/blob/main/documentation/docs/guides/config-files.md)
- [Osaurus overview](https://docs.osaurus.ai/)
