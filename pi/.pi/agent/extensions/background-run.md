# Background Run Extension

Runs long shell commands in a visible terminal backend instead of blocking Pi's normal `bash` tool.

## Tool

The model can call `background_run` with:

```json
{
  "command": "npm test",
  "label": "tests",
  "backend": "herdr",
  "focus": false
}
```

Fields:

- `command` — shell command to run.
- `label` — optional tab/window label.
- `cwd` — optional working directory; defaults to Pi's cwd.
- `backend` — `herdr` or `tmux`; defaults to config.
- `focus` — whether to focus the created tab/window; defaults to config.

## Slash command

```text
/background-run npm test
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
  "focus": false
}
```

## Backend behavior

### Herdr

- finds or creates a workspace for the current project cwd
- creates a new tab
- runs the command with `herdr pane run`
- returns workspace/tab/pane ids

### tmux

- if inside tmux, creates a new window in the current session
- if outside tmux, creates/uses a detached `pi-bg` session
- returns the tmux target and attach command when applicable

## Safety

The extension checks `~/.pi/agent/shell-guard.json` rules before starting a command. Interactive sessions ask for confirmation; non-interactive sessions block matching commands unless `--unsafe` is passed.
