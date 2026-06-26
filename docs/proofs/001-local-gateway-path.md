# Proof: Local Model Path Through LiteLLM Gateway

## Status

Completed

## Date

2026-06-26

## Purpose

Prove one local model path through the gateway for Milestone 1.

## Path Proven

Client request -> LiteLLM gateway -> Ollama -> local model response

## Result

Successful.

A request sent to the LiteLLM OpenAI-compatible chat completions endpoint returned a response from the local-fast model group backed by Ollama.

## Model Group

local-fast

## Local Runtime

Ollama

## Local Model

llama3.2:3b

## Gateway

LiteLLM proxy running locally through Podman.

## Container Image

docker.io/litellm/litellm:1.90.0-rc.1

## Platform

linux/arm64

## Config Used

config/gateway/litellm/config.local.yaml

## Host Runtime Access

Because LiteLLM ran in a Podman container and Ollama ran on the host, the gateway config used:

http://host.containers.internal:11434

## Commands Used

Confirm Ollama models:

ollama list

Run LiteLLM gateway:

export LITELLM_MASTER_KEY=sk-local-dev

podman run --rm \
  --name ai-lab-litellm \
  --platform linux/arm64 \
  -p 4000:4000 \
  -e LITELLM_MASTER_KEY="$LITELLM_MASTER_KEY" \
  -v "$PWD/config/gateway/litellm/config.local.yaml:/app/config.yaml:ro" \
  docker.io/litellm/litellm:1.90.0-rc.1 \
  --config /app/config.yaml \
  --host 0.0.0.0 \
  --port 4000

Check gateway health:

curl http://localhost:4000/health \
  -H "Authorization: Bearer sk-local-dev"

Health result summary:

healthy_count: 1
unhealthy_count: 0
model: ollama/llama3.2:3b
api_base: http://host.containers.internal:11434

Check gateway models:

curl http://localhost:4000/v1/models \
  -H "Authorization: Bearer sk-local-dev"

Model result summary:

local-fast was listed as an available model.

Send test prompt:

curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-local-dev" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "local-fast",
    "messages": [
      {
        "role": "user",
        "content": "Say hello from the local gateway in one short sentence."
      }
    ]
  }'

Response summary:

The request returned a chat completion with model local-fast.

## Security Notes

No frontier provider was used.

No work-approved provider was used.

No external API key was required.

The LiteLLM master key was set locally and not committed.

The test used the Podman container path rather than installing LiteLLM into the repo Python environment.

## Follow-up

Use this proof to support the gateway-aware bootstrap check.

Consider adding a small Podman run helper or just recipe later.

Reassess whether config.local.yaml should be expanded to local-capable and local-code after the initial gateway path remains stable.

The proof used llama3.2:3b as the backend for local-fast. This proves the gateway path only. It does not make llama3.2:3b the permanent local-fast model.
