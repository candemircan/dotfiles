---
name: baklavacutter
description: Scaffolds a new project using the baklavacutter template.
arguments:
  project_name:
    type: string
    description: "The name of the project to create (e.g., 'my_project')"
    required: true
  user_name:
    type: string
    description: "GitHub username for the author"
    default: "candemircan"
  python_version:
    type: string
    description: "Target Python version"
    default: "3.12.5"
  project_description:
    type: string
    description: "A short summary of the project"
    required: true
---
# Baklavacutter Scaffolder

When this skill is invoked:

1. **Validation Phase:** - Ensure all `arguments` are provided. If any required fields are missing, ask the user specifically for them.
   - Confirm `uv` is installed (`uv --version`). If missing, install via `curl -LsSf https://astral.sh/uv/install.sh | sh`.
2. **Execution Phase:**
   - Use `uvx` to run the template.
   - Pass the arguments directly to avoid interactive prompts if possible:
     `uvx cookiecutter gh:candemircan/baklavacutter --no-input project_name="{{project_name}}" user_name="{{user_name}}" python_version="{{python_version}}" project_description="{{project_description}}"`

3. **Post-Scaffold:**
   - `cd` into the new directory and run `uv sync` to initialize the environment.
