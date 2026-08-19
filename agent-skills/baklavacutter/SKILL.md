---
name: baklavacutter
description: Scaffold a new research project from the baklavacutter cookiecutter template (candemircan/baklavacutter). Use when the user asks to start, create, or scaffold a new project.
---

# Baklavacutter scaffolder

Scaffold a new project from `gh:candemircan/baklavacutter`.

## Inputs

Collect these before running. Ask for any that are missing.

- `project_name` (required): the project directory name, e.g. `my_project`.
- `project_description` (required): one short sentence.
- `user_name` (default `candemircan`): GitHub username for authorship.
- `python_version` (default `3.12.5`): target Python version.

## Steps

1. Confirm `uv` is installed: `uv --version`. If missing, install it:
   `curl -LsSf https://astral.sh/uv/install.sh | sh`.
2. Run the template non-interactively:
   ```bash
   uvx cookiecutter gh:candemircan/baklavacutter --no-input \
     project_name="<project_name>" \
     user_name="<user_name>" \
     python_version="<python_version>" \
     project_description="<project_description>"
   ```
3. The post-gen hook runs `git init`, symlinks `AGENTS.md -> CLAUDE.md`, and runs `setup.sh`.
4. Confirm the environment: run `uv sync` in the new project directory.
