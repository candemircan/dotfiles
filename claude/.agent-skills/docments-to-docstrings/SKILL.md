---
name: docments-to-docstrings
description: Convert docments-style inline comments on function parameters to Google-style docstrings across a Python package.
---
# Skill: docments-to-docstrings

Convert docments-style inline `#` comments on function parameters to Google-style docstrings across a Python package.

## Instructions

Fully automatic — find all files, convert everything, write changes, and show a summary.

### Find target files

1. Glob for `**/__init__.py` to identify packages.
2. Glob for `**/*.py` within each package directory.
3. Exclude: `.venv`, `venv`, `.env`, `env`, `node_modules`, `__pycache__`, `.tox`, `.nox`, `.eggs`, `build`, `dist`, `.git`, `.hg`, `site-packages`, `egg-info`.
4. Skip standalone scripts (files not inside a directory with `__init__.py`).

### What to convert

Functions/methods with trailing `# comments` on parameter or return annotation lines:

```python
def foo(x: int,  # the x value
        y: str,  # the y value
        ) -> bool:  # whether it worked
```

### Conversion rules

- Remove inline `# comments` from the signature. Collapse to one line if it fits in ~88 chars; otherwise one param per line, no comments.
- Build a Google-style docstring with `Args:` and `Returns:` sections from the extracted comments.
- Capitalize first letter and ensure a trailing period on each comment and on any existing summary line.
- Do NOT include types in `Args:` (they're in the signature).
- Skip `self`/`cls` in `Args:` (but still remove their inline comments).
- Only add params that had comments — don't add bare params to `Args:`.
- Return annotation comments become a `Returns:` section.
- If a docstring already exists, merge: keep the summary, insert `Args:` after description text but before `Returns:`/`Raises:`/etc. Don't duplicate existing entries.

### Output

- Write changes with the Edit tool.
- Print a summary: number of files modified, and for each file the functions/methods converted.
