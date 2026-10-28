# Secrets and Gateway Credentials

## Purpose

Bitwarden is the preferred secret source for the workstation. Committed
`.env.example` files contain names and placeholders only. Ignored
`.env.<profile>.local` files are recovery fallbacks, not the normal daily
source.

`tools/ai/secrets.sh` provides the thin, profile-aware resolution layer. It
checks the environment first, then Bitwarden, then the ignored fallback file.
It never prints resolved values. Keep Bitwarden unlocked and export
`BW_SESSION` only for the active terminal session; never store it in a shell
profile or repository file.

## macos-work Credentials

| Bitwarden item | Purpose | Access |
| --- | --- | --- |
| `ai-lab/macos-work/LITELLM_MASTER_KEY` | LiteLLM administration | Gateway lifecycle, health and key administration only |
| `ai-lab/macos-work/LITELLM_SALT_KEY` | Persistent virtual-key hashing | Gateway startup only |
| `ai-lab/macos-work/LITELLM_DATABASE_PASSWORD` | PostgreSQL authentication | Gateway startup only |
| `ai-lab/macos-work/LITELLM_CLI_KEY` | `bin/ai` | Stable local model groups |
| `ai-lab/macos-work/LITELLM_LIBRECHAT_KEY` | LibreChat | Stable local model groups |
| `ai-lab/macos-work/LITELLM_OPENCODE_KEY` | OpenCode | `local-code` only |
| `ai-lab/macos-work/LITELLM_EVAL_KEY` | Model fitness | Configured stable, diagnostic and candidate groups |

All client keys are LiteLLM virtual keys restricted to OpenAI-compatible
inference routes. They must not access key-management or other administrative
routes. The master key must not be copied into client configuration.

## Runtime Handling

Gateway and LibreChat lifecycle recipes create mode-`600` temporary environment
files and remove them on exit. `bin/ai`, OpenCode and model evaluation resolve
their scoped keys only when needed. Client keys are passed to child processes
through purpose-specific environment variables and are not written to tracked
files.

LibreChat's ignored profile file continues to hold its application JWT and
encryption secrets. Its LiteLLM entry remains the `replace-me` placeholder;
the actual gateway credential comes from Bitwarden.

## Availability Checks

With Bitwarden unlocked, run:

```bash
just workstation-status
AI_LAB_PROFILE=macos-work bin/ai routes
just ui-check
just opencode-check
just eval-gateway-models
```

These checks report availability and permitted model groups without printing
secret values. Use `just gateway-health` only for the bounded administrative
provider-health diagnostic.

## Rotation

Rotate one credential at a time and retain a rollback path until validation
passes.

### Master key

1. Generate a new high-entropy `sk-`-prefixed value and update only the
   matching Bitwarden item.
2. Keep `LITELLM_SALT_KEY` unchanged so persisted virtual-key hashes remain
   valid.
3. Recreate the gateway with `just gateway-stop` and `just gateway-start`.
4. Confirm the new master credential can perform an administrative check and
   the old credential is rejected.
5. Run every client availability check above. Existing scoped keys should
   remain valid because PostgreSQL state and the salt key are retained.

### Client key

1. Generate a replacement LiteLLM virtual key with the same model and route
   restrictions as the client entry in the table above.
2. Update the stable Bitwarden item with the replacement value.
3. Recreate only the affected client and run its focused validation.
4. Block or delete the old virtual key through LiteLLM after the replacement
   is proven.

Never place old or new values on a command line that will be logged, echo them,
or save them in validation evidence.

## Revocation and Recovery

If a client credential may be exposed, block it immediately through LiteLLM,
create a replacement with the minimum required scope, update Bitwarden, and
rerun the client check. Compromise of the master or salt key requires gateway
administrative rotation; treat loss of the database password as a gateway
service credential incident.

If Bitwarden is temporarily unavailable, populate only the corresponding
ignored `config/secrets/.env.<profile>.local` fallback. Administrative gateway
fallbacks belong in `containers/litellm/.env.<profile>.local`; LibreChat
application secrets remain in `containers/librechat/.env.<profile>.local`.
Remove fallback values after Bitwarden access is restored.

## Rebuild

On a rebuilt machine:

1. Install and unlock Bitwarden CLI.
2. Restore the profile's local application secrets where they are not held in
   Bitwarden.
3. Run `just workstation-up`.
4. If the persistent LiteLLM PostgreSQL volume was restored, validate the
   existing scoped keys. If it was not restored, recreate the virtual keys and
   update their stable Bitwarden items.
5. Run the availability checks above and confirm LibreChat conversation
   persistence separately.

Do not treat a copied `.env.local` file as a successful rebuild.
