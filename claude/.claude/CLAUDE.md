# Standing instructions

These rules hold in every project. A project's own `CLAUDE.md` or `AGENTS.md` is appended after
this file and wins where the two disagree.

## Writing

- No em dashes. Use a comma, a colon, or two sentences.
- Short sentences. Active voice. Name who does what.
- Say what a thing is. Do not say why it is impressive.
- Do not restate my request back to me before answering.

## Code

- No fallbacks. No defensive `try`/`except`. No speculative generality. Fail loudly.
- A docstring says what the function does. In research code it must not name the phenomenon the
  function might represent. That framing is the result, not the documentation.
- `uv` for Python. Never conda. Never bare `pip`.
- Run commands from the repository root. Do not prefix them with `cd`.
- Do not add a comment that repeats the line below it.

## Figures

- Vector sources become SVG. Never rasterise a PDF to PNG.

## Long jobs

Anything that runs longer than about a minute goes to herdr, not the foreground. That includes a
full test suite, a training or discovery run, `quarto render`, and any `sbatch`. Print the log
path when you start it.

## Delegation

When you would spawn a subagent, start a real agent in a herdr split instead. Read the `herdr`
skill for current syntax. The shape is:

1. Write the brief to a file. Do not pass a long brief as a shell argument.
2. `herdr pane split --current --direction right --cwd "$PWD" --no-focus`
3. `herdr agent start <name> --kind claude --pane <pane-id> -- --permission-mode auto --add-dir <brief-dir>`
4. `herdr agent prompt <name> "Read <brief-path> and carry out exactly what it says. Work autonomously; do not ask me any questions."`
5. `herdr agent list` to watch status, then `herdr agent read <name> --source recent-unwrapped --lines 120`

Rules that keep an agent from hanging:

- Always start it in auto permission mode: `-- --permission-mode auto`. Without this the agent
  stops at the first permission prompt and reports `blocked`, not `working`.
- `--permission-mode bypassPermissions` is refused by my managed settings. Use `auto`.
- Pass `--add-dir` for every directory outside the agent's own cwd that the brief names. A brief in
  a scratchpad directory needs it.
- Always pass `--no-focus`, so my focus stays in the calling pane.
- Each agent starts empty, so its brief must be self-contained. Give agents file-disjoint work.
- If `herdr agent list` shows `blocked`, read the pane before sending any keys. Never guess what a
  prompt is asking.

This overrides the herdr skill's rule to act only when I ask for herdr. For delegation, treat the
request as standing.

## Working with me

- Push back when I am wrong. One sentence, then your reasoning.
- Two options at most, with a recommendation.
- Say plainly what you did not verify.
- Report in this order: what you did, the result, the next step.
