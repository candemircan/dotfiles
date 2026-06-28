# Shell Guard Extension

Global Pi extension that guards dangerous shell commands before they run.

## What it protects

The extension checks both:

- model-initiated `bash` tool calls
- user `!command` / `!!command` shell commands

Matching commands require approval in interactive Pi sessions. In non-interactive modes, matching commands are blocked by default.

## Commands

Inside Pi:

```text
/shell-guard status
/shell-guard rules
/shell-guard edit
/shell-guard reload
/shell-guard clear
/shell-guard off
/shell-guard on
```

- `edit` opens the JSON config in Pi's editor, validates it, saves it, and reloads rules.
- `off` disables the guard for the current session only.
- `clear` forgets commands approved for the current session.

## Non-interactive override

Use `--unsafe` to disable the guard for one Pi process:

```bash
pi -p --unsafe "run the requested task"
```

Without `--unsafe`, dangerous commands are blocked in non-interactive modes because there is no approval UI.

## Config

Rules live at:

```text
~/.pi/agent/shell-guard.json
```

In this dotfiles repo:

```text
pi/.pi/agent/shell-guard.json
```

Each rule has:

```json
{
  "id": "rm-recursive",
  "description": "Recursive deletion",
  "pattern": "...JavaScript regex source..."
}
```

Patterns are JavaScript regular expressions compiled case-insensitively.
