---
name: background-run
description: Run long-lived or slow commands in a visible Herdr tab or tmux window via Pi's background_run tool so the chat can continue. Use when the user asks to run something in the background, start a server, keep progress visible, continue execution outside the chat, or when the agent expects a command to take a long time and direct chat output is not required.
---
# Background Run

Use this skill when the user asks about running long commands in the background, offloading commands to Herdr or tmux, the `background_run` tool, or `/background-run`. The agent may also choose it for long-lived or slow commands when direct chat output is not required and keeping the conversation unblocked is more useful.

## Summary

A global Pi extension exposes `background_run`, which runs long shell commands in a visible Herdr tab or tmux window instead of blocking Pi's normal `bash` tool.

The default backend is configured as Herdr in `~/.pi/agent/background-run.json`.

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

Use it when continued execution, visible progress, or manual inspection is useful. Prefer normal `bash` for short commands where the result should come directly back into the chat.

## Command

Inside Pi:

```text
/background-run python train.py --config config.yaml
```

## Config

- Active config: `~/.pi/agent/background-run.json`
- Dotfiles config: `pi/.pi/agent/background-run.json`
- Extension docs: `~/.pi/agent/extensions/background-run.md`

Supported backends: `herdr`, `tmux`.

## Interactive and non-interactive use

This is useful in both interactive and non-interactive Pi runs. In non-interactive mode it starts the command and lets it continue in the configured backend after Pi exits.

