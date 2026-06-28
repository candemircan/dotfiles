# Pi Global Notes

## Shell guard

A global shell guard extension is installed. It prompts before dangerous shell commands in interactive mode and blocks matching commands by default in non-interactive mode.

Useful commands:

- `/shell-guard status`
- `/shell-guard rules`
- `/shell-guard edit`
- `/shell-guard off` — disable for the current session only
- `/shell-guard on`

For one non-interactive run, `pi --unsafe ...` disables the shell guard.
