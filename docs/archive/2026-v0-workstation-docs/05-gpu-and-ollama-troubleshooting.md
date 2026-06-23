# GPU and Ollama Troubleshooting

## Purpose

This document captures the practical troubleshooting steps for GPU-backed Ollama inference in the AI Lab workstation.

The goal is not to become a CUDA tuning expert. The goal is to understand and validate the runtime path that allows local models to use the NVIDIA GPU from inside WSL2.

The expected runtime path is:

```text
Windows NVIDIA driver
        ↓
WSL2 GPU passthrough
        ↓
CUDA visibility inside Ubuntu
        ↓
Ollama service
        ↓
local model
        ↓
GPU-backed inference
```

---

## Known Good State

A healthy setup should show:

* WSL2 can see the NVIDIA GPU
* Ollama service is running
* Ollama API is reachable
* models are available through `ollama list`
* active models show GPU usage through `ollama ps`
* `ai-gpu-check --probe` reports GPU usage
* `ai-status --fix --probe` completes successfully

Quick validation:

```bash
ai-status --fix --probe
```

Focused GPU validation:

```bash
ai-gpu-check --probe
```

---

## Key Commands

| Command                                | Purpose                                 |
| -------------------------------------- | --------------------------------------- |
| `nvidia-smi`                           | Confirms WSL2 can see the NVIDIA GPU    |
| `ollama list`                          | Lists available local models            |
| `ollama ps`                            | Shows active models and processor usage |
| `systemctl status ollama`              | Checks Ollama service status            |
| `sudo systemctl restart ollama`        | Restarts Ollama service                 |
| `curl http://127.0.0.1:11434/api/tags` | Tests Ollama API                        |
| `ai-gpu-check --probe`                 | Validates GPU path                      |
| `ai-status --fix --probe`              | Full health check and safe remediation  |

---

## Confirm WSL2 Can See the GPU

Run:

```bash
nvidia-smi
```

Expected result:

* NVIDIA GPU is listed
* driver version is shown
* CUDA version is shown
* GPU memory is shown

Example expected GPU:

```text
NVIDIA GeForce RTX 4090
```

If `nvidia-smi` is not found or does not show the GPU, the issue is below Ollama. It is likely related to:

* Windows NVIDIA driver
* WSL2 integration
* Windows needing a restart
* WSL needing to be shut down and restarted

From Windows PowerShell:

```powershell
wsl --shutdown
```

Then reopen Ubuntu and test again:

```bash
nvidia-smi
```

---

## Confirm CUDA Library Visibility

In WSL2, CUDA libraries are normally exposed under:

```text
/usr/lib/wsl/lib
```

Check:

```bash
ls -l /usr/lib/wsl/lib/libcuda.so.1
```

If this file exists, Linux processes should be able to see the CUDA library provided through WSL2.

If it does not exist, Ollama may not be able to use the GPU even if other parts of the setup appear correct.

Optional check:

```bash
echo $LD_LIBRARY_PATH
```

If needed, `/usr/lib/wsl/lib` can be added to the shell environment:

```bash
echo 'export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH' >> ~/.zshrc
source ~/.zshrc
```

This is not always required, but it can help some tools find CUDA libraries.

---

## Confirm Ollama is Running

Check the service:

```bash
systemctl status ollama
```

Expected:

```text
active (running)
```

If the service is stopped:

```bash
sudo systemctl start ollama
```

If the service is running but not behaving correctly:

```bash
sudo systemctl restart ollama
```

---

## Confirm Ollama API is Reachable

Run:

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

Expected result:

* JSON response
* list of available models

If this fails, check:

```bash
systemctl status ollama
```

Restart if required:

```bash
sudo systemctl restart ollama
```

---

## Confirm Ollama Host Binding

The workstation expects Ollama to be reachable locally at:

```text
http://127.0.0.1:11434
```

Ollama is configured through a systemd override.

Check the override:

```bash
systemctl cat ollama
```

Expected environment entry:

```ini
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

If this is missing, edit the service override:

```bash
sudo systemctl edit ollama
```

Add:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

Then reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

Validate:

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

---

## Confirm Models are Available

List models:

```bash
ollama list
```

Current expected models:

```text
qwen3:14b
deepseek-r1:14b
llama3.1:8b
```

If a model is missing, pull it again:

```bash
ollama pull qwen3:14b
ollama pull deepseek-r1:14b
ollama pull llama3.1:8b
```

---

## Confirm Ollama is Using the GPU

Run a prompt:

```bash
ollama run qwen3:14b "Reply with exactly: ok"
```

Then run:

```bash
ollama ps
```

Expected:

```text
PROCESSOR
100% GPU
```

or at least a processor value showing GPU usage.

If it shows:

```text
100% CPU
```

then Ollama is not using the GPU for the active model.

---

## Use `ai-gpu-check`

The project includes a focused GPU validation tool:

```bash
ai-gpu-check
```

For a full probe:

```bash
ai-gpu-check --probe
```

This checks:

* NVIDIA GPU visibility
* CUDA library visibility
* Ollama service/process status
* active model processor usage
* NVIDIA process snapshot

The desired result is:

```text
Ollama reports 100% GPU usage
```

---

## Use `ai-status`

The project also includes a broader health check:

```bash
ai-status
```

Run with safe remediation and inference probe:

```bash
ai-status --fix --probe
```

This can safely:

* start Ollama if stopped
* restart Ollama if the API is unreachable
* check available models
* run a small model probe
* check Open WebUI
* restart Open WebUI if needed

It does not:

* change GPU drivers
* rewrite GPU configuration
* download models
* recreate containers
* delete runtime data

---

## Problem: Ollama Shows 100% CPU

Symptom:

```bash
ollama ps
```

shows:

```text
PROCESSOR
100% CPU
```

This means the model is running, but not using the GPU.

### Check 1 — Can WSL see the GPU?

```bash
nvidia-smi
```

If this fails, fix the Windows/WSL/NVIDIA path first.

### Check 2 — Is CUDA visible?

```bash
ls -l /usr/lib/wsl/lib/libcuda.so.1
```

If missing, WSL GPU support is not correctly exposed.

### Check 3 — Restart Ollama

```bash
sudo systemctl restart ollama
```

Then:

```bash
ollama run qwen3:14b "Reply with exactly: ok"
ollama ps
```

### Check 4 — Run Ollama manually in debug mode

Stop the service first:

```bash
sudo systemctl stop ollama
```

Start manually with debug enabled:

```bash
OLLAMA_DEBUG=1 OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

In another terminal:

```bash
ollama run qwen3:14b "Reply with exactly: ok"
ollama ps
```

If GPU works manually but not as a service, the issue is likely with the service environment.

Restart the service afterwards:

```bash
sudo systemctl start ollama
```

---

## Problem: Cannot Start Ollama Manually Because Port is in Use

Symptom:

```bash
OLLAMA_DEBUG=1 OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

returns:

```text
Error: listen tcp 0.0.0.0:11434: bind: address already in use
```

This means Ollama is already running.

Check:

```bash
ps aux | grep ollama
```

If Ollama is running as a systemd service, stop it properly:

```bash
sudo systemctl stop ollama
```

Then start the debug session again:

```bash
OLLAMA_DEBUG=1 OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

---

## Problem: `pkill ollama` Does Not Stop Ollama

Symptom:

```bash
sudo pkill ollama
ps aux | grep ollama
```

still shows:

```text
/usr/local/bin/ollama serve
```

This usually means systemd is restarting the service automatically.

Stop the service instead:

```bash
sudo systemctl stop ollama
```

Then confirm:

```bash
ps aux | grep ollama
```

You should only see the `grep` process.

---

## Problem: Models Disappear After Switching Between Manual and Service Mode

Ollama can use different model stores depending on which user is running the process.

The systemd service usually runs as the `ollama` user.

Service model store:

```text
/usr/share/ollama/.ollama/models
```

Interactive user model store:

```text
~/.ollama/models
```

Check both:

```bash
sudo ls -lah /usr/share/ollama/.ollama/models
ls -lah ~/.ollama/models
```

If models were pulled under the wrong user context, they may not appear when the service is running.

Recommended approach:

* use the Ollama service as the source of truth
* re-pull the required models once
* avoid switching between manual user-run Ollama and systemd service mode unless troubleshooting

Pull models:

```bash
ollama pull qwen3:14b
ollama pull deepseek-r1:14b
ollama pull llama3.1:8b
```

---

## Problem: Ollama Service Restart Interrupts Active Sessions

Restarting Ollama will interrupt active model sessions used by:

* Open WebUI
* Continue.dev
* CLI tools
* running prompts

Use restart only when needed:

```bash
sudo systemctl restart ollama
```

For normal validation, prefer:

```bash
ollama ps
ai-gpu-check --probe
ai-status
```

---

## Problem: Open WebUI Cannot See Models

Open WebUI depends on Ollama.

Check Ollama API:

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

Check Open WebUI service:

```bash
systemctl --user status open-webui.service
```

Restart Open WebUI:

```bash
systemctl --user restart open-webui.service
```

If Ollama was restarted, refresh Open WebUI in the browser.

---

## Useful Debug Commands

### Ollama service status

```bash
systemctl status ollama
```

### Ollama service logs

```bash
journalctl -u ollama -n 100 --no-pager
```

### Follow Ollama logs

```bash
journalctl -u ollama -f
```

### Ollama active models

```bash
ollama ps
```

### Ollama available models

```bash
ollama list
```

### NVIDIA status

```bash
nvidia-smi
```

### Listening ports

```bash
ss -tulnp | grep 11434
```

### API check

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

---

## Known Good Validation Sequence

Use this sequence when something feels wrong:

```bash
nvidia-smi
```

```bash
systemctl status ollama
```

```bash
curl http://127.0.0.1:11434/api/tags | jq
```

```bash
ollama run qwen3:14b "Reply with exactly: ok"
```

```bash
ollama ps
```

```bash
ai-gpu-check --probe
```

```bash
ai-status --fix --probe
```

---

## What Not To Auto-Fix

The project deliberately avoids automatically fixing some issues.

Do not automatically change:

* NVIDIA drivers
* WSL GPU configuration
* systemd service overrides
* model storage locations
* container images
* network configuration

These should be diagnosed and changed deliberately.

Safe automated fixes are limited to:

* starting known services
* restarting known services
* starting known containers
* restarting known containers
* reloading user systemd where safe

---

## Troubleshooting Principle

Use this mental model:

```text
If nvidia-smi fails:
    Windows / WSL / NVIDIA path issue

If nvidia-smi works but ollama ps shows CPU:
    Ollama GPU runtime issue

If ollama ps shows GPU but Open WebUI is slow:
    Model size, prompt length, or UI/runtime issue

If Ollama API fails:
    Ollama service or host binding issue

If Open WebUI fails:
    Podman / Quadlet / Open WebUI service issue
```

This keeps troubleshooting structured rather than random.

---

## Notes

Local GPU-backed inference will not always feel instant, especially with larger or reasoning-oriented models.

A 14B model running locally may feel similar in latency to a smaller CPU-bound model in some simple prompts, but the GPU advantage becomes more obvious with:

* larger prompts
* longer context
* multiple tools
* larger models
* reasoning tasks
* future routing workflows
* future RAG workflows

The goal is not raw speed alone. The goal is local control, hands-on learning, and practical understanding of AI runtime architecture.
