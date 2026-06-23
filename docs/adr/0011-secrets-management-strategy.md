# ADR-0011: Use Bitwarden as the preferred secrets management strategy

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

Secrets must not be committed to the repository or scattered through shell profiles, scripts, routing config or compose files.

I already use Bitwarden. Introducing a heavier secrets platform such as HashiCorp Vault would add unnecessary operational complexity for a personal workstation.

## Decision

Bitwarden will be the preferred secrets source.

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

A future `ai-secrets` helper may centralise secret retrieval so Bitwarden-specific logic is not scattered across scripts.

## Options Considered

### Option 1: `.env.local` as primary source

Store local secrets in ignored `.env.local` files.

Pros:

- simple
- common pattern
- easy for local development
- no extra tooling required

Cons:

- secrets can become scattered
- weaker cross-device rebuild story
- manual secret transfer needed
- easy to leak accidentally if mishandled
- poor long-term secret hygiene

### Option 2: Bitwarden as preferred source

Use Bitwarden CLI or Bitwarden Secrets Manager CLI where practical.

Pros:

- uses an existing trusted tool
- aligns with open-source-first posture
- works across macOS, Windows and Linux
- avoids running a separate secrets platform
- improves rebuildability
- keeps secrets outside the repo

Cons:

- requires CLI session handling
- may need wrapper logic
- Secrets Manager vs standard CLI needs evaluation
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
- avoids third-party CLI dependency

Cons:

- inconsistent across macOS, Windows/WSL2 and Linux
- more complex rebuild story
- WSL2 integration is awkward
- harder to create one profile-aware strategy

## Rationale

Bitwarden is the best fit because it provides secure secret storage without introducing unnecessary platform complexity.

It is already part of my workflow and is more appropriate than Vault for a personal workstation. `.env.local` remains useful as a fallback during early development, but it should not be the long-term primary strategy.

## Consequences

### Benefits

- Keeps secrets out of the repo.
- Supports cross-device rebuilds.
- Avoids heavy secrets infrastructure.
- Aligns with the project’s open-source-first principle.
- Can be centralised behind `ai-secrets`.

### Trade-offs

- Requires Bitwarden CLI or Secrets Manager CLI setup.
- Bootstrap needs to handle unauthenticated or locked vault states.
- Profile-specific secret requirements must be clear.

### Risks or Follow-ups

- Decide whether to use Bitwarden CLI or Bitwarden Secrets Manager CLI.
- Avoid exposing secrets in logs.
- Ensure validation checks only report presence/absence.
- Keep `.env.local` ignored.
- Separate work and personal provider keys where needed.

## Implementation Impact

Milestone 1 should include:

- `.env.example`
- `.gitignore` entry for `.env.local`
- Bitwarden-oriented setup notes
- profile-level secret requirements
- validation that checks for secret availability without printing values
- optional `ai-secrets` design placeholder

Example profile secret config:

```yaml
secrets:
  source: bitwarden
  fallback: env_local
  required:
    - GEMINI_API_KEY
  optional:
    - ANTHROPIC_API_KEY
    - OPENAI_API_KEY
```

## Review Trigger

Review this decision if:

- Bitwarden CLI workflow is too awkward
- Bitwarden Secrets Manager is clearly better than the standard CLI
- work/personal separation needs stronger secret isolation
- the project becomes shared with other users
- OS-native keychain integration becomes simpler and more useful

## Related Documents

- `README.md`
- `docs/02-principles.md`
- `docs/03-architecture.md`
- `docs/06-profiles.md`
- `docs/08-rebuild-strategy.md`
- `docs/09-tool-selection.md`
-
