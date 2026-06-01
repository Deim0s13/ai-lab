# Troubleshooting

## Check overall status

```bash
ai-status
```

## Apply safe fixes

```bash
ai-status --fix
```

## Check GPU usage

```bash
ai-gpu-check --probe
```

## Check Ollama Service

```bash
systemctl status ollama
```

## Restart Ollama

```bash
sudo systemctl restart ollama
```

## Check Ollama Models

```bash
ollama list
ollama ps
```

## Check Open WebUI service

```bash
systemctl --user status open-webui.service
```

## View Open WebUI Logs

```bash
journalctl --user -u open-webui.service -f
```

## Check Podman container

```bash
podman ps
podman logs open-webui
```