# Proof: OpenCode Supervised Development Workflow

## Status

Completed

## Date

2026-09-09

## Purpose

Validate the adopted OpenCode configuration as a safe, local-first workflow for supervised repository development on `macos-work`.

## Path Proven

Operator -> `just opencode` -> OpenCode -> LiteLLM `local-code` -> oMLX coding model

## Result

Successful, with the documented gateway-health limitation.

OpenCode analysed a disposable Python repository, identified an expected failing test, proposed the smallest repair, applied only the approved production-code edit and ran the approved test command. Independent verification passed.

## Behaviour Verified

- The supported launcher selected `ai-lab/local-code` through LiteLLM.
- Plan mode performed read-only analysis and did not change tracked files.
- Build mode requested approval before editing or running commands.
- A rejected edit left the repository unchanged.
- An approved repair changed only `src/trial_app/calculator.py`.
- Existing operator work and ignored synthetic secret files were preserved byte-for-byte.
- OpenCode created no commit.
- Independent tests passed after the repair.
- With LiteLLM unavailable, the launcher failed before opening OpenCode and did not bypass the gateway.
- `local-code` and `local-code-mlx` were both exposed by LiteLLM and mapped to the same oMLX coding model.
- A direct `local-code` completion returned the expected synthetic response.

## Privacy and Local State

The sanitised OpenCode session export was valid JSON. It and the operational logs contained neither synthetic secret value. The tested synthetic prompt was also absent from both locations. The disposable OpenCode session was deleted after inspection.

OpenCode session history is local application state and may normally contain prompts and responses. Operational logs must remain metadata-only. Use synthetic or appropriately classified content and clean up sessions when a disposable test ends.

## Commands Used

The workflow was launched with:

```bash
just workstation-up
just opencode /path/to/disposable/repository
```

Independent repository verification used:

```bash
git status --short
git diff
PYTHONPATH=src python3 -m unittest discover -s tests -v
```

Runtime and route verification used:

```bash
just opencode-check
just opencode-models
just omlx-check
just gateway-routes
just ask-model local-code "Return only: ISSUE_61_LOCAL_CODE_OK"
```

## Known Limitation

LiteLLM's aggregate `/health` request exceeded 15 seconds during final validation even though `local-code` model discovery and completion succeeded. This is an operational health-check concern, not evidence of gateway bypass or failure of the selected coding path. It should be investigated separately.

OpenCode may also retry an interrupted gateway connection without a useful terminal deadline. Interrupt it with `Ctrl+C`, recover the workstation and restart the supervised session.

## Conclusion

OpenCode is suitable as the preferred supervised, local-first repository coding interface. Operator approval and independent verification remain mandatory. This proof does not approve autonomous operation, subagents, MCP, ACP, external-directory access or unattended execution.

## Related Documents

- `docs/end-user-experience/development-workflow.md`
- `docs/tool-evaluations/003-cli-coding-assistant.md`
- `docs/adr/0018-select-opencode-for-supervised-cli-coding.md`
- `config/opencode/README.md`
- GitHub issue #61
