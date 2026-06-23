# Model Notes

## Current Models

| Model | Intended Use |
|---|---|
| `qwen3:14b` | General architecture explanation and strong everyday reasoning |
| `deepseek-r1:14b` | Deeper reasoning, trade-offs, complex analysis |
| `llama3.1:8b` | Lightweight tasks, quick responses, simple rewrites |

## Future Direction

Introduce model routing:

```text
Prompt
  ↓
Classify intent
  ↓
Select model
  ↓
Generate response
```

Initial routing ideas:

| Task Type                       | Model             |
| ------------------------------- | ----------------- |
| Explain / summarise             | `qwen3:14b`       |
| Compare / reason / analyse      | `deepseek-r1:14b` |
| Quick rewrite / simple response | `llama3.1:8b`     |
