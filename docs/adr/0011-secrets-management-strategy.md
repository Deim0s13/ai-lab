# ADR-0011: Use Bitwarden as the preferred secrets management strategy, with escalation criteria

## Status

Accepted

## Date

2026-06-24

## Context

The workstation needs API keys and sensitive configuration values for local and frontier AI workflows.

Secrets may include:

- OpenAI API keys
- Anthropic API keys
- Gemini API keys
- gateway credentials
- future provider keys
- future service credentials

Secrets must not be committed to the repository or scattered through shell profiles, scripts, routing config, model config or compose files.

This project needs to work across different environments:

- `macos-work` on a MacBook Pro
- `windows-personal` on Windows / WSL2
- a future `fedora-atomic` profile

These environments do not have a consistent native credential model. macOS Keychain, Windows Credential Manager, WSL2 and future Linux key stores behave differently. Relying on OS-native credential stores as the primary cross-profile approach would make the rebuild strategy harder.

I already use Bitwarden. Introducing a heavier secrets platform such as HashiCorp Vault would add unnecessary operational complexity for a personal workstation.

The project therefore needs two things:

1. a preferred secrets approach for the workstation
2. clear criteria for when to move beyond simple `.env.local` fallback behaviour

## Decision

Bitwarden will be the preferred secrets source for the workstation.

`.env.local` may be used as an ignored local fallback only.

`.env.example` will be committed as a template showing required variable names, but never values.

The initial strategy is:

```text
Bitwarden
= preferred source for secrets

.env.example
= committed template

.env.local
= ignored local fallback only
```

A future `ai-secrets` helper should centralise secret retrieval if scripts or commands need to resolve secrets consistently.

The project will not use HashiCorp Vault, 1Password CLI, `pass`, `sops` / `age`, OS keychains, or other secret systems unless a clear trigger makes them a better fit.

---

## Options Considered

### Option 1: `.env.local` as primary source

Store local secrets in ignored `.env.local` files.

Pros:

- simple
- common pattern
- easy for early local development
- no extra tooling required

Cons:

- secrets can become scattered
- weak cross-device rebuild story
- manual secret transfer is required
- easy to accidentally make scripts depend on local-only state
- does not provide a strong long-term secret management pattern

### Option 2: Bitwarden as preferred source

Use Bitwarden CLI or Bitwarden Secrets Manager CLI where practical.

Pros:

- uses an existing trusted tool
- aligns with open-source-first posture
- works across macOS, Windows and Linux
- avoids running a separate secrets platform
- improves rebuildability
- keeps secrets outside the repo
- supports future centralisation through `ai-secrets`

Cons:

- requires CLI session handling
- may need wrapper logic
- Bitwarden CLI versus Bitwarden Secrets Manager needs evaluation
- work/personal secret separation must be handled carefully

### Option 3: HashiCorp Vault or similar

Run a dedicated secrets platform.

Pros:

- strong secrets management capability
- enterprise-style patterns
- good for teams and production systems

Cons:

- overkill for this project
- adds operational burden
- another service to bootstrap and secure
- not aligned to personal workstation scope

### Option 4: OS-native keychains

Use macOS Keychain, Windows Credential Manager or Linux secret stores.

Pros:

- native integration
- secure local storage
- avoids another third-party CLI dependency

Cons:

- inconsistent across macOS, Windows / WSL2 and Linux
- weak cross-profile rebuild story
- WSL2 integration is awkward
- harder to document one consistent approach
- may create profile-specific secret handling too early

### Option 5: `sops` / `age`, `pass`, 1Password CLI or similar

Use another developer-oriented secrets tool.

Pros:

- some options are strong for GitOps-style or CLI-heavy workflows
- may suit future automation better
- may offer better file-based encrypted secret patterns

Cons:

- not already my primary password manager
- adds another secret store
- creates migration effort
- does not currently solve a problem Bitwarden cannot solve for this project

## Rationale

Bitwarden is the best current fit because it provides secure secret storage without introducing unnecessary platform complexity.

It is already part of my workflow and is more appropriate than Vault for a personal workstation.

`.env.local` remains useful as a fallback during early development, but it should not become the long-term primary strategy.

The key design point is that secrets should be resolved consistently across profiles without becoming embedded in local machine state or scripts.

---

## Secrets escalation criteria

The project should move beyond `.env.local` fallback when any of the following are true.

| Trigger | Required response |
|---|---|
| Two or more active profiles need the same provider secret | Store the secret in Bitwarden and reference it from profile config by name. |
| Bootstrap scripts need repeatable secret resolution | Introduce or use an `ai-secrets` helper rather than reading secrets directly in many scripts. |
| A CLI command needs secrets at runtime | Resolve through Bitwarden or `ai-secrets`; do not require secrets in shell profiles. |
| Work and personal profiles need different provider credentials | Use separate Bitwarden items or naming conventions for work and personal secrets. |
| Secrets are needed inside container/service startup | Resolve at startup through a controlled local mechanism; do not commit values into compose/config files. |
| `.env.local` is being copied between machines | Move those secrets to Bitwarden. |
| `.env.local` becomes required for normal daily use | Treat this as technical debt and replace with Bitwarden retrieval. |
| Secrets need machine-to-machine or automation-style access | Evaluate Bitwarden Secrets Manager. |
| The repo becomes shared with other users | Revisit this ADR and consider Bitwarden Secrets Manager or a stronger shared secrets pattern. |
| OS-native keychain integration becomes attractive | Allow profile-specific use only if it does not weaken cross-platform rebuildability. |

`.env.local` remains acceptable when:

| Situation | Allowed use |
|---|---|
| Early development before Bitwarden wiring exists | Temporary fallback. |
| Local-only testing with dummy or low-risk values | Acceptable if ignored by git. |
| Provider key not yet ready to move into Bitwarden | Temporary fallback with documented follow-up. |
| Debugging Bitwarden CLI or Secrets Manager issues | Temporary fallback. |

`.env.local` should not be used as the normal long-term secret source.

---

## Bitwarden implementation choices

There are two likely Bitwarden paths.

| Option | Best fit |
|---|---|
| Bitwarden CLI | Local interactive workstation use, early implementation, simple secret lookup. |
| Bitwarden Secrets Manager CLI | More repeatable developer/DevOps-style secret injection, automation, service startup or future shared use. |

Initial implementation should start with the simplest practical Bitwarden approach.

The project should not decide between Bitwarden CLI and Bitwarden Secrets Manager abstractly. It should trial the simplest option during Milestone 1 and move to Secrets Manager only if there is a concrete need.

### Decision criteria for Bitwarden CLI vs Secrets Manager

| Criterion | Bitwarden CLI | Bitwarden Secrets Manager |
|---|---|---|
| Simple local use | Strong fit | Possible, but may be more setup |
| Interactive workstation | Strong fit | Good if already configured |
| Bootstrap repeatability | Good with wrapper | Stronger fit |
| Service/container startup | Possible with wrapper | Stronger fit |
| Multiple profiles | Good with naming discipline | Stronger with explicit project/secrets structure |
| Future shared use | Limited | Stronger fit |
| Operational simplicity | Stronger initially | Stronger later if automation grows |

Initial preference:

```text
Start with Bitwarden CLI or manual Bitwarden-backed setup.
Add ai-secrets when scripts need consistent retrieval.
Evaluate Bitwarden Secrets Manager when automation or service startup makes it worthwhile.
```

---

## Naming and separation

Secrets should be named so profile intent is clear.

Example naming convention:

```text
ai-lab/macos-work/GEMINI_API_KEY
ai-lab/macos-work/ANTHROPIC_API_KEY
ai-lab/windows-personal/OPENAI_API_KEY
ai-lab/windows-personal/ANTHROPIC_API_KEY
ai-lab/shared/GEMINI_API_KEY
```

The exact Bitwarden item structure can be refined during implementation.

The principle is:

```text
Work and personal secrets should not be mixed accidentally.
```

Profile config should reference secret names, not secret values.

Example:

```yaml
secrets:
  source: bitwarden
  fallback: env_local
  required:
    - name: GEMINI_API_KEY
      ref: ai-lab/macos-work/GEMINI_API_KEY
  optional:
    - name: ANTHROPIC_API_KEY
      ref: ai-lab/macos-work/ANTHROPIC_API_KEY
    - name: OPENAI_API_KEY
      ref: ai-lab/macos-work/OPENAI_API_KEY
```

---

## Consequences

### Benefits

- Keeps secrets out of the repo.
- Supports cross-device rebuilds.
- Avoids heavy secrets infrastructure.
- Aligns with the project’s open-source-first principle.
- Provides a clear migration path away from `.env.local`.
- Allows work and personal provider secrets to remain separated.
- Creates a future path for `ai-secrets`.

### Trade-offs

- Requires Bitwarden CLI or Secrets Manager setup.
- Bootstrap needs to handle unauthenticated or locked vault states.
- Profile-specific secret requirements must be clear.
- Some early implementation may still use `.env.local`.

### Risks or Follow-ups

- Avoid exposing secrets in logs.
- Ensure validation checks only report presence or absence.
- Keep `.env.local` ignored.
- Add `.env.local` to `.gitignore`.
- Do not store secrets in shell profiles.
- Do not store secrets in container compose files.
- Decide whether `ai-secrets` is needed during Milestone 1.
- Trial Bitwarden CLI before deciding whether Secrets Manager is necessary.

## Implementation Impact

Milestone 1 should include:

- `.env.example`
- `.gitignore` entry for `.env.local`
- Bitwarden-oriented setup notes
- profile-level secret requirements
- validation that checks for secret availability without printing values
- decision on whether `ai-secrets` is needed immediately or can remain planned
- clear fallback behaviour when Bitwarden is unavailable

Example validation output:

```text
Secrets:
- source: Bitwarden
- vault status: unlocked
- GEMINI_API_KEY: available
- ANTHROPIC_API_KEY: optional, not configured
- OPENAI_API_KEY: optional, not configured

Status: OK
```

Example fallback output:

```text
Secrets:
- source: .env.local fallback
- Bitwarden: unavailable
- OPENAI_API_KEY: available
- ANTHROPIC_API_KEY: missing

Status: WARN
Next action:
- move required secrets into Bitwarden before this profile is considered fully rebuilt
```

## Review Trigger

Review this decision if:

- Bitwarden CLI workflow is too awkward
- Bitwarden Secrets Manager is clearly better than the standard CLI
- work/personal separation needs stronger secret isolation
- `.env.local` starts becoming the normal daily-use pattern
- the project becomes shared with other users
- OS-native keychain integration becomes simpler and useful without weakening cross-platform rebuildability
- a new active profile introduces different secret requirements

## Related Documents

- `README.md`
- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/08-rebuild-strategy.md`
- `docs/09-tool-selection.md`
- `docs/11-cli-interface-contracts.md`
