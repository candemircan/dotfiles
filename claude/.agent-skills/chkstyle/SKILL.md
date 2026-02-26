---
name: chkstyle
description: Enforce the fast.ai coding style in Python projects using the `chkstyle` tool. Use this when you need to ensure code follows density-focused patterns, minimizes vertical space, or uses idiomatic fast.ai naming and formatting.
---

## Usage

No need to use `uv`. It's already installed system-wide.

```bash
chkstyle
chkstyle src/ tests/
```

## Opting Out
- `# chkstyle: ignore` — Ignore a single line.
- `# chkstyle: off` / `# chkstyle: on` — Disable for a block.
- `# chkstyle: skip` — Skip the entire file (must be in first 5 lines).
