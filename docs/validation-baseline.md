# Workstation Validation Baseline

## Status

Completed — issue #62

## Purpose

This document defines the supported validation baseline for the AI Dev Workstation. It separates static policy checks, live readiness checks and synthetic behaviour checks so failures can be reproduced, classified and owned.

This baseline composes existing tools and `just` recipes. It is not a new validation framework.

## Supported Scope

| Profile            | Static validation | Live validation | Behaviour validation |
| ------------------ | ----------------- | --------------- | -------------------- |
| `macos-work`       | Supported         | Supported       | Supported            |
| `windows-personal` | Supported         | Deferred        | Deferred             |
| `fedora-atomic`    | Supported         | Deferred        | Deferred             |

Live validation is currently limited to `macos-work` because the unified workstation lifecycle is implemented only for that profile.

## Validation Rules

- Use synthetic prompts and data only.
- Never print credential values.
- Run static checks before live checks.
- Run lifecycle recovery only when explicitly intended.
- Do not classify a single unreproduced transient as a defect.
- Every persistent failure must have an expected-behaviour classification, workaround, upstream reference or focused issue.
- “Pre-existing” describes scope; it is not a final disposition.

## Tier 1 — Static Validation

These checks must not start services or require live model access:

```bash
bash -n bin/ai tools/ai/*.sh
just --fmt --check
just check-yaml
just opencode-config-check
git diff --check
```

Expected result: every command exits `0`.

For repeat use, run:

    just validation-static

## Tier 2 — Live Readiness

Start or recover the supported workstation before running the live baseline:

```bash
just workstation-up
```

Then run:

```bash
just workstation-preflight
just workstation-status
just ollama-check
just omlx-check
just local-exposure-check
just ui-check
just opencode-check
```

Expected result: every command exits `0` and reports the required `macos-work` components ready.

Local workstation services must listen only on loopback interfaces. MongoDB
must remain available only inside the LibreChat Compose network.

For repeat use, run:

    just validation-live

Lifecycle commands such as `workstation-down`, `ui-down` and `omlx-down` are not part of the default baseline because they intentionally change workstation state.

## Tier 3 — Synthetic Behaviour

Load the local gateway key without printing it:

```bash
key="$(
  awk '$0 ~ /^LITELLM_MASTER_KEY=/ {
    sub(/^LITELLM_MASTER_KEY=/, "")
    sub(/\r$/, "")
    print
    exit
  }' config/opencode/.env.macos-work.local
)"
```

Confirm explicit route selection:

```bash
AI_LAB_PROFILE=macos-work \
LITELLM_MASTER_KEY="${key}" \
  bin/ai routes test --mode fast \
  "Return only: VALIDATION_FAST_ROUTE"

AI_LAB_PROFILE=macos-work \
LITELLM_MASTER_KEY="${key}" \
  bin/ai routes test --mode capable \
  "Return only: VALIDATION_CAPABLE_ROUTE"

AI_LAB_PROFILE=macos-work \
LITELLM_MASTER_KEY="${key}" \
  bin/ai routes test --mode code \
  "Return only: VALIDATION_CODE_ROUTE"
```

Expected routes:

| Mode      | Expected route      |
| --------- | ------------------- |
| `fast`    | `local-fast`        |
| `capable` | `local-capable-mlx` |
| `code`    | `local-code`        |

Confirm the two stable daily-use completion paths:

```bash
LITELLM_MASTER_KEY="${key}" \
  just ask-model local-fast \
  "Return only: VALIDATION_FAST_OK"

LITELLM_MASTER_KEY="${key}" \
  just ask-model local-code \
  "Return only: VALIDATION_CODE_OK"

unset key
```

Expected responses are `VALIDATION_FAST_OK` and `VALIDATION_CODE_OK`.

Frontier acknowledgement remains explicit. With no acknowledgement, routing exits `7`. With acknowledgement but no configured frontier provider, routing exits `6`. Neither result sends a provider request.

## Exit Behaviour

| Check type                         | Success                                | Expected failure                                                  |
| ---------------------------------- | -------------------------------------- | ----------------------------------------------------------------- |
| Static `just` or tool-native check | `0`                                    | Any nonzero value; record the native result                       |
| Readiness or validation recipe     | `0`                                    | Normally `8` with an actionable message                           |
| `workstation-status`               | `0` when required components are ready | `8` when a required component is unavailable                      |
| Route dry run                      | `0`                                    | `2`, `3`, `7` or `8`, depending on cause                          |
| Frontier route policy              | Provider result when configured        | `7` without acknowledgement; `6` when the provider is unavailable |

Do not rewrite tool-native exit codes solely to make every command return the same value.

## Failure Classification

| Classification          | Meaning                                                | Required disposition                             |
| ----------------------- | ------------------------------------------------------ | ------------------------------------------------ |
| Expected behaviour      | Intentional fixture or policy result                   | Document why it is expected                      |
| Upstream limitation     | Behaviour owned by an external project                 | Link upstream evidence and document a workaround |
| Environment-specific    | Caused by host state, versions or installation         | Record reproduction and operator recovery        |
| Repository-owned defect | Incorrect project configuration, code or documentation | Fix if bounded or create a focused issue         |

## Classified Findings

| Finding                                                                                                                                                                    | Classification                                                                    | Disposition                                                                                                                         |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| LiteLLM aggregate `/health` timed out in two of three 15-second attempts; the successful attempt took 14.28 seconds and reported nine healthy and zero unhealthy endpoints | Upstream/integration characteristic exposed by a repository-owned unbounded check | Use bounded readiness and stable-model discovery for routine validation; retain aggregate health as a bounded, on-demand diagnostic |
| OpenCode may retry indefinitely after gateway interruption                                                                                                                 | Upstream limitation                                                               | Accepted for supervised use; interrupt with `Ctrl+C` and restart                                                                    |
| Podman APIs may become stale after sleep                                                                                                                                   | Environment-specific, with repository recovery                                    | Use `just workstation-up`; unified recovery has been validated                                                                      |
| Homebrew oMLX launcher previously referenced a removed Python runtime                                                                                                      | Environment-specific installation failure                                         | Current user-space oMLX installation is the working path                                                                            |
| `ai status` checked retired MLX ports and returned success despite reporting local models unavailable                                                                      | Repository-owned defect                                                           | Fixed by delegating status and recovery to the unified workstation recipes                                                          |
| OpenCode example configuration could contain a non-placeholder gateway key without failing static validation                                                               | Repository-owned defect                                                           | Fixed by requiring `replace-me` in the committed `.env.example`                                                                     |

## Evidence Record

The completed baseline is recorded in:

```text
docs/proofs/003-workstation-validation-baseline.md
```

The proof contains the workstation state, commands, exit results, classified failures, bounded fixes, remaining limitations and the final known-good result.
