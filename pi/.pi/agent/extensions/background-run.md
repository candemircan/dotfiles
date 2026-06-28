# Background Run Extension

Runs long shell commands in a visible terminal backend instead of blocking Pi's normal `bash` tool.

## Tool

The model can call `background_run` with:

```json
{
  "command": "python train.py --config config.yaml",
  "label": "training",
  "backend": "herdr",
  "focus": false,
  "closeOnExit": false,
  "closeDelaySeconds": 5
}
```

Fields:

- `command` — shell command to run.
- `label` — optional tab/window label.
- `cwd` — optional working directory; defaults to Pi's cwd.
- `backend` — `herdr` or `tmux`; defaults to config.
- `focus` — whether to focus the created tab/window; defaults to config.
- `closeOnExit` — close the tab/window after the command exits; defaults to config.
- `closeDelaySeconds` — delay before closing when `closeOnExit` is true; defaults to config.

## Slash command

```text
/background-run python train.py --config config.yaml
```

## Config

Rules live at:

```text
~/.pi/agent/background-run.json
```

In this dotfiles repo:

```text
pi/.pi/agent/background-run.json
```

Current config:

```json
{
  "backend": "herdr",
  "focus": false,
  "closeOnExit": false,
  "closeDelaySeconds": 5
}
```

## When to use

Use `background_run` for commands where continued execution, visible progress, or manual inspection is useful. Prefer normal `bash` for short commands where the result should come directly back into the chat.

This can be useful in interactive and non-interactive Pi runs. In non-interactive mode it starts the command and lets it continue in the configured backend after Pi exits.

## Backend behavior

### Herdr

- finds or creates a workspace for the current project cwd
- creates a new tab
- runs the command with `herdr pane run`
- returns workspace/tab/pane ids
- keeps the tab open by default for inspection

### tmux

- if inside tmux, creates a new window in the current session
- if outside tmux, creates/uses a detached `pi-bg` session
- keeps the window open by default for inspection
- returns the tmux target and attach command when applicable

