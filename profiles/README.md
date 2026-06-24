# profiles

This directory will contain profile-specific workstation configuration.

Profiles define how the same architecture behaves on different machines and for different usage contexts.

---

## Active profiles

| Profile | Status | Purpose |
|---|---|---|
| `macos-work` | Active | Work AI workstation on MacBook Pro. |
| `windows-personal` | Active | Personal AI development lab on Windows / WSL2. |
| `fedora-atomic` | Future / reference | Future rebuildable Linux workstation pattern. |

---

## Expected structure

Possible future structure:

```text
profiles/
├── macos-work/
│   └── profile.yaml
├── windows-personal/
│   └── profile.yaml
└── fedora-atomic/
    └── profile.yaml
```

---

## Profile responsibilities

A profile may define:

- local runtime preferences
- runtime access rules
- provider priority
- routing posture
- secret requirements
- context access rules
- enabled capabilities
- validation expectations
- risk posture

---

## Rules

Profiles should not contain secrets.

Profile config should reference secret names, not secret values.

---

## Related docs

```text
docs/06-profiles.md
docs/07-routing-strategy.md
docs/adr/0007-profile-based-work-personal-separation.md
docs/adr/0012-work-personal-context-boundaries.md
```
