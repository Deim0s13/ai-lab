# ADR-0019: Adopt Risk-Based Workstation Control Levels

## Status

Accepted

## Date

2026-09-28

## Context

The workstation now supports gateway-backed chat, CLI prompts and supervised repository editing through OpenCode. Future milestones include work personas, private context and controlled agents.

Existing decisions require conservative permissions, profile boundaries, gateway-first access and human approval. However, they do not define when ordinary supervision is sufficient and when a workflow requires operating-system containment.

Applying maximum isolation to every prompt would add enough friction to undermine daily use. Treating approval prompts as a sandbox would leave valuable files, secrets and external actions exposed to operator error, prompt injection or unexpected tool behaviour.

## Decision

Adopt three risk-based control levels:

1. **Advisory** for chat, review and planning without approved file or command changes.
2. **Supervised editing** for daily repository work with explicit scope, application permissions, operator approvals, diff review and independent validation.
3. **Isolated execution** for unattended, destructive, untrusted or materially higher-risk workflows, using a disposable workspace and process, credential, network and lifecycle controls.

Choose the level using both data sensitivity and action consequence. Sensitive content does not automatically require a sandbox when the route and workflow are genuinely read-only and approved. A non-sensitive task may require isolation when it can make broad or destructive changes.

OpenCode permission rules are supervision controls, not an operating-system security boundary. Level 2 remains the default for normal supervised coding. Level 3 is required before unattended agents and whenever Level 2 cannot reasonably contain the likely harm.

Controls must remain proportionate. Repeated low-value approvals, unnecessary startup steps and controls that do not reduce a credible risk should be redesigned or removed.

## Options Considered

### Option 1: Use the same lightweight controls for every workflow

Pros:

- lowest operating friction;
- simplest configuration;
- supports rapid experimentation.

Cons:

- approval prompts can be mistaken for containment;
- inadequate for unattended or destructive work;
- does not bound access to host files, credentials or services.

### Option 2: Require maximum isolation for all AI use

Pros:

- smallest default blast radius;
- simpler claim about where tools execute;
- strong separation from host files and credentials.

Cons:

- disproportionate for ordinary chat and planning;
- creates startup and integration friction;
- risks making the workstation too inconvenient for daily use;
- may encourage bypassing controls entirely.

### Option 3: Use risk-based control levels

Pros:

- aligns control strength with likely consequence;
- preserves low-friction daily use;
- establishes a clear gate before unattended agents;
- supports incremental implementation with existing tools.

Cons:

- requires operator judgement;
- boundaries must be documented and reviewed;
- Level 2 retains residual host-access risk.

## Rationale

Risk-based levels best support secure-by-default, daily-use, profile-aware and adopt-before-build principles.

They preserve the proven supervised OpenCode workflow while making its limitations explicit. They also prevent future agent work from inheriting weak assumptions merely because application approvals exist.

## Consequences

### Benefits

- Security expectations are consistent across interfaces and future tools.
- Ordinary advisory and supervised workflows remain usable.
- Strong containment has explicit triggers and acceptance criteria.
- Application guardrails are not overstated as sandboxing.
- Follow-up security work can target clear invariants.

### Trade-offs

- The operator must classify some workflows before execution.
- Level 2 cannot guarantee protection from an approved destructive action.
- Level 3 will take longer to start and may support fewer integrations.
- Some workflows must be reduced or deferred until stronger isolation exists.

### Risks or Follow-ups

- Control levels could become documentation-only unless regression checks are added.
- Too many prompts could cause approval fatigue.
- Isolation tooling may not fit interactive macOS use cleanly.
- Profile configuration must not imply controls that are not technically enforced.

## Implementation Impact

- `docs/security-and-controls.md` is the practical source of truth.
- Issues #71, #64, #72, #65 and #73 implement the security-hardening baseline.
- Issue #63 and future controlled-agent decisions must satisfy Level 3.
- `macos-work` continues to allow approved advisory and supervised workflows while blocking unattended agents.
- No new policy engine, agent framework or mandatory sandbox is introduced by this decision.

## Review Trigger

Review this decision when:

- unattended or scheduled agents are proposed;
- remote gateway access is required;
- private RAG or broad work context is introduced;
- a selected tool weakens its permission model;
- the controls repeatedly obstruct normal daily work;
- a security incident shows that a control level is insufficient.

## Related Documents

- `docs/security-and-controls.md`
- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/09-tool-selection.md`
- `docs/adr/0011-secrets-management-strategy.md`
- `docs/adr/0014-controlled-agent-guardrails.md`
- `docs/adr/0018-select-opencode-for-supervised-cli-coding.md`
- GitHub issue #70
- GitHub milestone `Security and Control Hardening`

