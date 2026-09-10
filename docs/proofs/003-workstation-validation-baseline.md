# Proof: Workstation Validation Baseline

## Status

Completed

## Date

2026-09-10

## Purpose

Establish a repeatable, classified validation baseline for the AI Dev Workstation without introducing a custom validation framework.

## Supported Scope

Static validation covers all committed profiles. Live readiness and synthetic behaviour were validated for `macos-work`; live validation for `windows-personal` and `fedora-atomic` remains deferred until their lifecycle implementations exist.

## Result

Successful, with LiteLLM aggregate provider health retained as a bounded diagnostic rather than a routine readiness gate.

The final known-good workstation reported the Podman machine and APIs, Ollama fallback, preferred oMLX runtime, LiteLLM and LibreChat ready. OpenCode selected `ai-lab/local-code` through LiteLLM.

## Validation Performed

Static validation passed:

    bash -n bin/ai tools/ai/*.sh
    just --fmt --check
    just check-yaml
    just opencode-config-check
    git diff --check
    just validation-static

Live validation passed:

    just workstation-preflight
    just workstation-status
    just ollama-check
    just omlx-check
    just ui-check
    just opencode-check
    just validation-live

Synthetic route tests selected `local-fast`, `local-capable-mlx` and `local-code` as expected. Stable `local-fast` and `local-code` completions returned their exact synthetic responses. Frontier routing exited `7` without acknowledgement and `6` when acknowledged but unavailable; neither path sent a provider request.

`ai status` returned `0` and reported oMLX as the preferred ready runtime, Ollama as fallback, and all required workstation services ready.

## Aggregate Health Investigation

LiteLLM readiness and model discovery each returned HTTP 200 in approximately six milliseconds. Three 15-second aggregate `/health` samples produced two timeouts and one HTTP 200 response after 14.28 seconds; the successful response reported nine healthy and zero unhealthy endpoints.

After bounding `just gateway-health` at 20 seconds, the diagnostic failed with exit `8` and an actionable timeout message. This is expected diagnostic behaviour and does not fail routine bootstrap or live validation.

## Bounded Fixes

- Added `validation-static` and `validation-live` orchestration using existing checks.
- Changed bootstrap validation to use bounded readiness and required stable-model discovery.
- Bounded gateway metadata and aggregate-health requests.
- Added committed OpenCode example-key placeholder validation.
- Corrected `ai status`, readiness and shutdown to delegate to unified workstation recipes rather than retired MLX-port checks.
- Updated gateway and CLI documentation to match the implemented lifecycle and health semantics.

## Classified Conditions

| Condition | Classification | Disposition |
| --- | --- | --- |
| Slow or intermittent LiteLLM aggregate health | Upstream/integration characteristic exposed by repository validation | Bounded, on-demand diagnostic; not a routine readiness gate |
| OpenCode may retry indefinitely after gateway interruption | Upstream limitation | Interrupt with `Ctrl+C`, recover the workstation and restart the supervised session |
| Podman APIs may become stale after sleep | Environment-specific | `just workstation-up` performs the validated recovery path |
| Homebrew oMLX launcher referenced a removed Python runtime | Environment-specific | Use the working user-space oMLX installation |
| CLI checked retired MLX ports | Repository-owned defect | Fixed by delegating to unified workstation recipes |
| Committed OpenCode example key was not enforced as a placeholder | Repository-owned defect | Fixed by static configuration validation |

## Architecture Assessment

The baseline remains a thin composition of tool-native checks and `just` recipes. It adds no generic health framework, routing engine or new dependency. LiteLLM remains the gateway, oMLX remains preferred on Apple Silicon, Ollama remains fallback, and the CLI delegates lifecycle responsibility rather than duplicating it.

## Conclusion

The `macos-work` workstation has a repeatable static, live and behavioural validation baseline. Routine checks are bounded and produce actionable failures. Known external and environment-specific conditions have explicit dispositions rather than being dismissed as pre-existing.

## Related Documents

- `docs/validation-baseline.md`
- `docs/11-cli-interface-contracts.md`
- `docs/12-cli-habit-layer.md`
- `docs/end-user-experience/ai-command.md`
- `docs/proofs/002-opencode-supervised-development-workflow.md`
- GitHub issue #62
