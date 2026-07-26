#!/usr/bin/env bash
set -euo pipefail

log_history() {
  local event_type="$1"
  local command_name="$2"
  local mode="$3"
  local route="$4"
  local provider="$5"
  local status="$6"
  local latency_ms="$7"
  local prompt="$8"
  local decision_source="${9:-unknown}"
  local file

  file="$(history_file)"

  mkdir -p "$(dirname "$file")"

  if [[ ! -x ".venv/bin/python" ]]; then
    error "Warning: usage history was not written because .venv/bin/python was not found."
    return 0
  fi

  if ! AI_LAB_HISTORY_PROMPT="$prompt" .venv/bin/python - \
    "$file" \
    "$(active_profile)" \
    "$event_type" \
    "$command_name" \
    "$mode" \
    "$route" \
    "$provider" \
    "$status" \
    "$latency_ms" \
    "$decision_source" <<'PY'
import json
import os
import sys
from datetime import datetime, timezone

file_path = sys.argv[1]

entry = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "profile": sys.argv[2],
    "event": sys.argv[3],
    "command": sys.argv[4],
    "mode": sys.argv[5],
    "route": sys.argv[6],
    "provider": sys.argv[7],
    "status": sys.argv[8],
    "latency_ms": int(sys.argv[9]) if sys.argv[9] else None,
    "local": sys.argv[7] == "local",
    "prompt": os.environ.get("AI_LAB_HISTORY_PROMPT", ""),
    "decision_source": sys.argv[10],
}

with open(file_path, "a", encoding="utf-8") as history:
    history.write(json.dumps(entry, ensure_ascii=False) + "\n")
PY
  then
    error "Warning: failed to write usage history: ${file}"
  fi
}

last_route_summary() {
  local file

  file="$(history_file)"

  if [[ ! -s "$file" ]]; then
    echo "not recorded yet"
    return 0
  fi

  if [[ ! -x ".venv/bin/python" ]]; then
    echo "not available (.venv missing)"
    return 0
  fi

  .venv/bin/python - "$file" <<'PY'
import json
import sys

file_path = sys.argv[1]

try:
    with open(file_path, "r", encoding="utf-8") as history:
        lines = [line.strip() for line in history if line.strip()]
    if not lines:
        print("not recorded yet")
        raise SystemExit(0)

    entry = json.loads(lines[-1])
    event = entry.get("event", "unknown")
    mode = entry.get("mode", "unknown")
    route = entry.get("route", "unknown")
    status = entry.get("status", "unknown")
    latency = entry.get("latency_ms")
    decision = entry.get("decision_source")

    decision_text = f", {decision}" if decision else ""

    if latency is None:
        print(f"{mode} -> {route} ({event}, {status}{decision_text})")
    else:
        print(f"{mode} -> {route} ({event}, {status}, {latency}ms{decision_text})")
except Exception:
    print("unavailable")
PY
}

show_history() {
  local limit="10"
  local file

  case "${1:-}" in
    "")
      ;;
    --limit|-n)
      limit="${2:-}"
      ;;
    *)
      limit="${1:-}"
      ;;
  esac

  if ! [[ "$limit" =~ ^[0-9]+$ ]] || [[ "$limit" -lt 1 ]]; then
    error "Invalid history limit: ${limit}"
    error "Usage: ai history [--limit N]"
    exit 2
  fi

  file="$(history_file)"

  echo "AI Usage History"
  echo
  echo "Profile:      $(active_profile)"
  echo "History file: ${file}"
  echo

  if [[ ! -s "$file" ]]; then
    echo "No AI usage history recorded yet."
    return 0
  fi

  check_python_runtime

  .venv/bin/python - "$file" "$limit" <<'PY'
import json
import sys

file_path = sys.argv[1]
limit = int(sys.argv[2])

entries = []

with open(file_path, "r", encoding="utf-8") as history:
    for line in history:
        line = line.strip()
        if not line:
            continue
        try:
            entries.append(json.loads(line))
        except json.JSONDecodeError:
            continue

entries = entries[-limit:]

if not entries:
    print("No readable AI usage history entries found.")
    raise SystemExit(0)

print(f"Showing last {len(entries)} entr{'y' if len(entries) == 1 else 'ies'}")
print()

for entry in entries:
    timestamp = entry.get("timestamp", "unknown")
    if timestamp.endswith("+00:00"):
        timestamp = timestamp.replace("+00:00", "Z")

    event = entry.get("event", "unknown")
    command = entry.get("command", "unknown")
    mode = entry.get("mode", "unknown")
    route = entry.get("route", "unknown")
    provider = entry.get("provider", "unknown")
    status = entry.get("status", "unknown")
    latency = entry.get("latency_ms")
    prompt = entry.get("prompt", "")
    decision_source = entry.get("decision_source")
    feedback = entry.get("feedback")
    feedback_note = entry.get("feedback_note", "")

    latency_text = "n/a" if latency is None else f"{latency}ms"

    print(
        f"{timestamp} | {event} | {command} | "
        f"{mode} -> {route} | {provider} | {status} | {latency_text}"
    )

    if prompt:
        prompt_preview = " ".join(prompt.split())
        if len(prompt_preview) > 140:
            prompt_preview = prompt_preview[:137] + "..."
        print(f"  Prompt: {prompt_preview}")

    if decision_source:
        print(f"  Decision: {decision_source}")

    if feedback:
        print(f"  Feedback: {feedback}")
        if feedback_note:
            note_preview = " ".join(feedback_note.split())
            if len(note_preview) > 140:
                note_preview = note_preview[:137] + "..."
            print(f"  Note: {note_preview}")

    print()
PY
}

record_feedback() {
  local rating="${1:-}"
  local note="${*:2}"
  local file

  case "$rating" in
    good|bad)
      ;;
    "")
      error "No feedback rating provided."
      error "Usage: ai feedback good|bad [note]"
      error "Examples:"
      error "  ai feedback good"
      error "  ai feedback bad Missed the context"
      exit 2
      ;;
    *)
      error "Unknown feedback rating: ${rating}"
      error "Supported ratings: good, bad"
      exit 2
      ;;
  esac

  file="$(history_file)"

  if [[ ! -s "$file" ]]; then
    error "No AI prompt history found for profile: $(active_profile)"
    error "Run a prompt first, then retry:"
    error "  ai ask --mode capable Summarise this"
    exit 2
  fi

  check_python_runtime

  if AI_LAB_FEEDBACK_NOTE="$note" .venv/bin/python - "$file" "$rating" <<'PY'
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

file_path = Path(sys.argv[1])
rating = sys.argv[2]
note = os.environ.get("AI_LAB_FEEDBACK_NOTE", "")

raw_lines = file_path.read_text(encoding="utf-8").splitlines()
entries = []
changed = False

for line in raw_lines:
    if not line.strip():
        continue
    try:
        entries.append(json.loads(line))
    except json.JSONDecodeError:
        entries.append({"event": "unreadable", "raw": line})

for entry in reversed(entries):
    if entry.get("event") == "prompt":
        entry["feedback"] = rating
        entry["feedback_timestamp"] = datetime.now(timezone.utc).isoformat()
        if note:
            entry["feedback_note"] = note
        elif "feedback_note" in entry:
            entry.pop("feedback_note", None)
        changed = True
        break

if not changed:
    print("No prompt history entry found to update.", file=sys.stderr)
    raise SystemExit(3)

with file_path.open("w", encoding="utf-8") as history:
    for entry in entries:
        history.write(json.dumps(entry, ensure_ascii=False) + "\n")
PY
  then
    echo "Recorded feedback: ${rating}"
    if [[ -n "$note" ]]; then
      echo "Note: ${note}"
    fi
  else
    error "Failed to record feedback."
    exit 8
  fi
}
