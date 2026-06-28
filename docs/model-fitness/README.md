# Model Fitness

This section defines how local models are assessed for use in the AI Dev Workstation.

The goal is not to create a formal benchmark suite. The goal is to decide whether a local model is good enough for the real tasks this workstation needs to support.

Model fitness is used to decide which local models should back gateway model groups such as:

- local-fast
- local-capable
- local-code

The stable project interface is the gateway model group, not the specific local model behind it.

## Documents

- `criteria.md` defines how local model fitness is judged.
- `test-prompts.md` defines the lightweight prompt set used to compare local models.

- `candidates.md` records candidate local model/runtime combinations before downloading and testing additional models.
