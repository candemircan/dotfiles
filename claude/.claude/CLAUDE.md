# CLAUDE.md

## Behavioral Guidelines

These bias toward caution over speed. For trivial tasks, use judgment.

- **Ask, don't assume.** State assumptions explicitly. If multiple interpretations exist, present them. If unclear, stop and ask.
- **Simplicity first.** No features, abstractions, or error handling beyond what was asked. If 200 lines could be 50, rewrite it.
- **Surgical changes.** Don't "improve" adjacent code, comments, or formatting. Match existing style. Every changed line should trace to the user's request. Remove only orphans YOUR changes created.
- **Goal-driven.** Transform tasks into verifiable goals (e.g. "fix bug" -> "write reproducing test, then make it pass"). For multi-step tasks, state a brief plan with verification steps.

## Code Style & Conventions

The project follows the coding conventions below, most of which come from fastai:

### Core Principles
- **Minimalism**: Do not wrap things into functions unnecessarily. No aggressively defensive programming.
- **No Boilerplate**: Do not write exceptions or verbose debugging/info prints (e.g., no "model loaded").
- **Manual Layout**: Do not use auto-formatters (ruff/black/yapf). Do not reformat existing code when editing it. Manual layout for domain clarity is intentional.
- **Comments**: Only for "why", not "how". No comments for each line.
- **Fastcore**: Use `docments` only for `@call_parse` CLI functions. For all other functions, use Google-style docstrings. Never mix both in one function.
- **Tensor Documentation**: Always include shape notation in the docstring, e.g., `X (torch.Tensor): Input batch (batch, observation, feature)`.
- **einops**: Use the `einops` package whenever possible and sensible to reshape tensors/arrays.

### Symbol Naming
- **Aggressive Abbreviations**: Used for short-lived symbols (list comps, lambdas, local helpers).
- **Common Abbreviations**: Used for function arguments and variables.
- **Full Names**: Only for modules and classes (long-lived).
- **Common Abbrs**: `sz` (size), `img` (image), `bs` (batch size), `sl` (seq len), `lr` (learning rate), `opt` (optimizer), `ds` (dataset), `dl` (dataloader), `idx` (index), `x`/`y` (input/target).

### Layout
- **Width**: ~160 characters.
- **One Idea per Line**: One semantic idea per line.
- **Single-line constructs**: `if x: y`, ternary operators `x = a if b else c`, and short `def` bodies on the same line are encouraged.
- **Signature Layout**: Only break to multiple lines if the signature exceeds ~100 characters.
- **Vertical Space**: Minimize vertical space. No empty lines between similar short functions.
- **Alignment**: Align conceptually similar statement parts to highlight differences.

### Algorithms & Data
- **Scalability**: Must work in 16GB RAM on large datasets (use generators/lazy loading).
- **Vectorization**: Use broadcasting and advanced indexing, not loops.
- **Citations**: Include paper links and equation numbers in comments.
