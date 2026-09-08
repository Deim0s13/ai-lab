# Supervised Development Workflow

OpenCode is the preferred repository-aware coding interface for routine work that the local coding model can handle. It uses LiteLLM as its only provider and requires operator review throughout.

## Start a Session

From the workstation repository, start or recover the complete stack:

```bash
just workstation-up
just workstation-status
```

Open the current repository or an explicit project directory:

```bash
just opencode
just opencode /path/to/project
```

The launcher validates the pinned installation, conservative configuration, gateway and `ai-lab/local-code` model before starting OpenCode.

## Work Safely

1. Start in the default Plan agent and ask for analysis or a bounded plan.
2. Review the proposed files, commands, assumptions and excluded work.
3. Use `Tab` to switch to Build only when ready to make changes.
4. Approve or reject each edit and command individually.
5. Reject access to secrets, external directories, destructive Git operations or unrelated files.
6. Treat the final summary as a claim to verify, not proof of completion.

OpenCode must not read secret-bearing `.env` or `.env.*` files, `.secrets/`, private keys or other restricted project data. A committed `.env.example` containing placeholders only may be inspected when relevant. Preserve unrelated working-tree changes and make commits outside OpenCode after review.

## Verify Before Committing

In a separate terminal, inspect the actual outcome:

```bash
git status --short
git diff --check
git diff
```

Run the repository's documented tests and the smallest relevant `just` checks. Confirm that only intended files changed before committing manually.

## Escalate Deliberately

Use OpenCode and `local-code` for routine supervised repository work. Use `ai code` for direct coding questions that do not need repository-aware editing.

Escalate deliberately to Claude Code, Codex, Cursor or another approved frontier tool when local output is insufficient for complex debugging, broad changes or architecture-heavy work. OpenCode does not automatically escalate or bypass LiteLLM.

## Recover from Failure

If OpenCode stalls after a gateway interruption, press `Ctrl+C`, then run:

```bash
just workstation-status
just workstation-up
just opencode /path/to/project
```

The launcher fails before opening OpenCode when LiteLLM is unavailable. Do not reconfigure a direct provider as a workaround.

## Inspect and Remove Local State

Inspect OpenCode's local paths and, from the target repository, its project sessions with:

```bash
OPENCODE_DISABLE_AUTOUPDATE=true ~/.opencode/bin/opencode --pure debug paths
OPENCODE_DISABLE_AUTOUPDATE=true ~/.opencode/bin/opencode --pure session list
```

Delete an unneeded session explicitly:

```bash
OPENCODE_DISABLE_AUTOUPDATE=true \
  ~/.opencode/bin/opencode --pure session delete SESSION_ID
```

Session history may contain prompts and responses. Operational logs must not contain prompt or secret content. See `config/opencode/README.md` for full removal and rebuild guidance.

## Boundaries

This workflow approves supervised interactive coding only. It does not approve autonomous execution, headless operation, subagents, MCP, ACP, web access, external-directory access or automatic frontier escalation.
