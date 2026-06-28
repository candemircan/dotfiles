---
name: shell-guard
description: Manage Pi shell guard safety rules and dangerous command approval. Use when the user asks about shell guard status, rules, approvals, the --unsafe flag, or editing shell guard configuration.
---
# Shell Guard

Use this skill when the user asks about Pi shell guard, dangerous command approval, the `--unsafe` flag, or editing shell guard rules.

## Summary

A global Pi shell guard extension is installed at `~/.pi/agent/extensions/shell-guard.ts`.
It checks model `bash` tool calls, model `background_run` tool calls when that extension is installed, and user `!` / `!!` shell commands before execution.

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

## Non-interactive override

Use `--unsafe` to disable the guard for one Pi process:

```bash
pi -p --unsafe "run the requested task"
```

## Config

Rules live at `~/.pi/agent/shell-guard.json`.
In the dotfiles repo, edit `pi/.pi/agent/shell-guard.json`.

The extension docs are in `~/.pi/agent/extensions/shell-guard.md`.
