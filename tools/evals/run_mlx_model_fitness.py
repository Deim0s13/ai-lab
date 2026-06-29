import json
import subprocess
import sys
import time
from pathlib import Path

MODELS = [
    {
        "label": "mlx-llama32-3b",
        "model": "mlx-community/Llama-3.2-3B-Instruct-4bit",
        "role": "local-fast",
        "max_tokens": "400",
        "timeout": 900,
    },
    {
        "label": "mlx-qwen35-9b-reasoning",
        "model": "Jackrong/MLX-Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit",
        "role": "local-capable",
        "max_tokens": "500",
        "timeout": 900,
    },
    {
        "label": "mlx-qwen3-coder-30b",
        "model": "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-5bit",
        "role": "local-code",
        "max_tokens": "500",
        "timeout": 1200,
    },
]

PROMPTS = [
    {
        "id": "quick-general-assistance",
        "text": "In three bullets, explain what this AI workstation is trying to achieve: local-first, gateway-first, CLI-native.",
    },
    {
        "id": "short-summary",
        "text": "Summarise this in four bullets: LiteLLM is being used as the local AI gateway. The daily CLI workflow uses just recipes. The local-fast model group currently routes to Ollama. The project avoids custom wrappers unless there is a clear need.",
    },
    {
        "id": "command-line-help",
        "text": "Explain what this command does, including any risks: podman rm -f ai-lab-litellm >/dev/null 2>&1 || true",
    },
    {
        "id": "troubleshooting",
        "text": 'LiteLLM starts in a Podman container, but curl to localhost:4000 immediately returns "connection reset by peer". The container is still starting. What is the likely cause and what small change should I make to the justfile?',
    },
    {
        "id": "code-config-review",
        "text": 'Review this just recipe line and explain what might go wrong: curl -fsS "$gateway_url/v1/chat/completions" -d "{model: local-fast, messages: [{role: user, content: $prompt}]}"',
    },
    {
        "id": "unsuitable-model-signal",
        "text": "A local model gives fast responses but often ignores requested structure, invents project files, and produces broken shell commands. Which gateway model group should it be used for, if any?",
    },
]


def clean_output(text: str) -> str:
    marker = "=========="
    if marker in text:
        text = text.split(marker, 1)[1]
    return text.strip()


def run_model(model: dict, prompt: dict) -> dict:
    start = time.time()

    cmd = [
        sys.executable,
        "-m",
        "mlx_lm",
        "generate",
        "--model",
        model["model"],
        "--prompt",
        prompt["text"],
        "--max-tokens",
        model["max_tokens"],
    ]

    try:
        result = subprocess.run(
            cmd,
            check=False,
            capture_output=True,
            text=True,
            timeout=model["timeout"],
        )
    except subprocess.TimeoutExpired:
        return {
            "model": model["label"],
            "model_id": model["model"],
            "role": model["role"],
            "prompt": prompt["id"],
            "status": "error",
            "error": "timeout",
            "duration_seconds": round(time.time() - start, 2),
        }

    output = clean_output(result.stdout)
    stderr = result.stderr.strip()

    record = {
        "model": model["label"],
        "model_id": model["model"],
        "role": model["role"],
        "prompt": prompt["id"],
        "status": "pass" if result.returncode == 0 else "error",
        "duration_seconds": round(time.time() - start, 2),
        "output": output,
    }

    if result.returncode != 0:
        record["error"] = stderr or "mlx-lm returned non-zero exit code"

    return record


def main() -> int:
    out_dir = Path("tmp")
    out_dir.mkdir(parents=True, exist_ok=True)

    results = []

    for model in MODELS:
        print(f"\n== {model['label']} ==")
        for prompt in PROMPTS:
            print(f"- {prompt['id']}")
            record = run_model(model, prompt)
            results.append(record)
            print(f"  {record['status']} in {record['duration_seconds']}s")

    json_path = out_dir / "model-fitness-mlx-results.json"
    md_path = out_dir / "model-fitness-mlx-results.md"

    json_path.write_text(json.dumps(results, indent=2), encoding="utf-8")

    lines = ["# MLX Model Fitness Results", ""]
    for record in results:
        lines.append(f"## {record['model']} / {record['prompt']}")
        lines.append("")
        lines.append(f"- Role: {record['role']}")
        lines.append(f"- Status: {record['status']}")
        lines.append(f"- Duration: {record['duration_seconds']}s")
        if record.get("error"):
            lines.append(f"- Error: {record['error']}")
        lines.append("")
        lines.append("Output:")
        lines.append("")
        lines.append(record.get("output", ""))
        lines.append("")

    md_path.write_text("\n".join(lines), encoding="utf-8")

    error_count = sum(1 for r in results if r["status"] == "error")

    print(f"\nWrote {json_path}")
    print(f"Wrote {md_path}")

    if error_count:
        print(f"\nCompleted with {error_count} error(s)")
        return 1

    print("\nCompleted successfully")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
