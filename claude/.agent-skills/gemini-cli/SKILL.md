---
name: gemini-cli
description: Use the Gemini CLI to analyse large codebases or files that would overflow the current context window.
---
# Skill: gemini-cli

Use `gemini -p` to offload large-context analysis to Gemini when the files involved are too big to read directly.

## When to use

- Summarising or exploring an entire project or directory
- Comparing many files at once
- Verifying whether a feature/pattern exists anywhere in the codebase
- Total file size exceeds ~100 KB

## Syntax

Include files or directories with `@`. Paths are relative to the current working directory.

```bash
# Single file
gemini -p "@src/train.py Explain what this script does"

# Whole directory
gemini -p "@src/ Summarise the architecture"

# Multiple targets
gemini -p "@src/ @tests/ What is the test coverage for the training pipeline?"

# Entire project
gemini --all_files -p "Give me an overview of this project"
```

## Example prompts for Python projects

```bash
# Understand a package
gemini -p "@mypackage/ Explain the public API and how the modules relate to each other"

# Find a pattern
gemini -p "@src/ Is early stopping implemented anywhere? Show the relevant functions"

# Check a shell script
gemini -p "@install.sh Summarise what this script installs and in what order"

# Cross-file data flow
gemini -p "@src/ @config/ Trace how a config value flows from file to model training"
```

## Notes

- No `--yolo` flag needed for read-only analysis
- Be specific in your prompt — Gemini's answers are only as precise as the question
