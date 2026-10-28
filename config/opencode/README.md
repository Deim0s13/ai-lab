# OpenCode Configuration

OpenCode is the preferred supervised CLI coding interface for the
`macos-work` profile. It provides repository-aware planning, editing and
verification while keeping model access behind LiteLLM.

## Configuration

- `opencode.json` defines the gateway-only provider, stable `local-code`
  model, conservative permissions and disabled integrations.
- `../secrets/.env.example` documents scoped client variables using
  placeholders only.
- `../secrets/.env.macos-work.local` is the ignored recovery fallback.
- `../../packages/macos-work/opencode.env` pins the tested OpenCode release,
  platform archive and checksum.

OpenCode receives the committed configuration through
`OPENCODE_CONFIG_CONTENT`. The launcher uses `--pure` and disables default
plugins, Claude Code integration, model fetching and LSP downloads.

## Install and Validate

```bash
just opencode-config-check
just opencode-install
just opencode-check
just opencode-models
```

`opencode-config-check` is static. `opencode-check` also requires the
workstation and LiteLLM gateway to be available.

## Supervised Use

Start the workstation, then open the current repository:

```bash
just workstation-up
just opencode
```

To select another repository:

```bash
just opencode /path/to/project
```

Review every proposed edit and command. OpenCode is not approved for
unattended or headless operation, subagents, MCP, ACP, external-directory
access or direct provider access.

## Known Limitations

Gateway connection failures may retry without terminating or clearly
reporting the failure. Interrupt the session with `Ctrl+C`, check
`just workstation-status`, recover with `just workstation-up`, and restart
OpenCode.

Local-model planning, tool use, context efficiency and completion claims may
be inconsistent. Validate all changes independently before committing.

## Removal and Rebuild

Remove only the installed binary:

```bash
rm -f "${HOME}/.opencode/bin/opencode"
```

Reinstall the pinned version with:

```bash
just opencode-install
```

OpenCode may also store local session, cache, configuration and state under
`~/.local/share/opencode`, `~/.cache/opencode`, `~/.config/opencode` and
`~/.local/state/opencode`. Removing those directories deletes local OpenCode
state and should only be done when a clean rebuild is intended.

OpenCode resolves `LITELLM_OPENCODE_KEY` from Bitwarden and can access only the
stable `local-code` model group. It never receives the LiteLLM master key.

See `../../docs/secrets-and-credentials.md` for rotation, revocation and
rebuild procedures.

## Related Documentation

- `../../docs/end-user-experience/development-workflow.md`
- `../../docs/proofs/002-opencode-supervised-development-workflow.md`
- `../../docs/adr/0018-select-opencode-for-supervised-cli-coding.md`
