## Code

- No fallbacks. No defensive `try`/`except`. No speculative generality. Fail loudly.
- Do not wrap code into functions unnecessarily.
- Make the smallest change that solves the problem. No unrequested extras.
- Do not "improve" adjacent code, comments, or formatting.
- Prefer the simplest implementation. If 200 lines could be 50, rewrite it.
- A docstring says what the function does. In research code it must not name the phenomenon the
  function might represent. That framing is the result, not the documentation.
- Document tensor shapes in the docstring, e.g. `X (torch.Tensor): input batch (batch,
  observation, feature)`.
- Use `einops` to reshape tensors whenever it is sensible.
- Comment only the "why", not the "how". Do not add a comment that repeats the line below it.
- `uv` for Python. Never conda. Never bare `pip`. Run scripts with `uv run`.
- Run commands from the repository root. Do not prefix them with `cd`.
- Do not add a heavyweight dependency without asking.

## Algorithms and data

- Must run in 16 GB RAM on large datasets. Use generators and lazy loading.
- Vectorise with broadcasting and advanced indexing, not loops.
- Cite sources in comments: paper links and equation numbers.
- Never overwrite raw data. Do not silently change metrics, data splits, likelihoods, seeds, or
  analyses.

## Figures

- Vector sources become SVG. Never rasterise a PDF to PNG.

## Working with me

- Optimize for correctness, reproducibility, minimal diffs, and traceability.
- Be extremely concise.
- Ask, do not assume. State assumptions explicitly. If several interpretations exist, present
  them. If unclear, stop and ask.
- Propose a short plan before non-trivial edits.
- Push back when I am wrong. One sentence, then your reasoning.
- Two options at most, with a recommendation.
- Say plainly what you did not verify.
- Report in this order: what you did, the result, the next step.
