# Dotfiles

GNU Stow-based dotfiles repo for macOS and Linux.

## Structure

Each top-level directory is a stow package symlinked into `$HOME`:

- `zsh/` — `.zshrc` (Oh My Zsh, fzf, zoxide, starship, aliases, local AI functions) + `.local/bin/` scripts
- `tmux/` — `.tmux.conf` (prefix `C-a`, TPM, flexoki dark theme)
- `herdr/` — `.config/herdr/config.toml` (experimental tmux-like Herdr bindings)
- `kitty/` — `.config/kitty/` (gruvbox dark theme, RobotoMono Nerd Font, boots into tmux)
- `helix/` — `.config/helix/` (gruvbox dark, REPL pipe, serpl, LSP config)
- `ruff/` — `.config/ruff/pyproject.toml` (global Ruff lint defaults)
- `claude/` —  agent skills (`baklavacutter`, `docments-to-docstrings`) + `managed-settings.json` (machine-level safety policies)
- `opencode/` — `.config/opencode/` (opencode.json config, package.json plugin deps)
- `git/` — `.gitconfig` (shared settings); user name/email go in `~/.gitconfig.local` (not tracked)

### `zsh/.local/bin/` scripts

| Script | Purpose |
|---|---|
| `tmux-init-default` | Creates the `default` session (window 1 shell, window 9 btop) |
| `sessionizer` | fzf over `~/Projects` + `~/Projects/cpi`; creates/attaches sessions, activates `.venv` |
| `tmux-yazi` | Yazi chooser popup; text files → `hx`, others → system opener |
| `tmux-obsidian` | Opens `$vault/Inbox.md` in helix (reads `~/.zsh_secrets`) |
| `herdr-sessionizer` | fzf project picker; creates/focuses Herdr workspaces and tabs |
| `herdr-space-switcher` | fzf over Herdr spaces only; focuses selected space |
| `herdr-yazi` | Yazi chooser temporary pane; text files open in the previously active Herdr pane |
| `herdr-init-default` | Starts/attaches Herdr, ensures `default` and `btop` spaces |

### `.zshrc` functions

| Function | Purpose |
|---|---|
| `ai <prompt>` | Run opencode with a prompt |
| `local_ai [--model MODEL] [prompt]` | One-shot answer (default: gpt-oss) or interactive chat (default: devstral) via llama-cli — offline |
| `serve_ai [--model MODEL]` | Start llama-server for opencode local model use (default: devstral) |
| `sn` | Fuzzy Obsidian note search |
| `count <dir>` | Count files in a directory |

## Scripts

- `install.sh` — Full bootstrap: installs brew, tools, agents, plugins, then runs `stow.sh`.
- `stow.sh` — Symlinks all packages, wires agent skills, and shares instructions across agents.



Skills from `~/.agent-skills/` are symlinked into all four skills directories.

`claude/managed-settings.json` contains machine-level Claude Code safety policies. `stow.sh` prompts to install it to:
- macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
- Linux: `/etc/claude-code/managed-settings.json`

## Adding a new package

1. Create a directory mirroring the target path relative to `$HOME` (e.g. `foo/.config/foo/config.toml`).
2. Add the directory name to the `stow` loop in `stow.sh`.
3. Run `./stow.sh`.
