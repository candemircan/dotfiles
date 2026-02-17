# Dotfiles

GNU Stow-based dotfiles repo for macOS and Linux.

## Structure

Each top-level directory is a stow package symlinked into `$HOME`:

- `zsh/` — `.zshrc` (Oh My Zsh, fzf, starship, aliases)
- `tmux/` — `.tmux.conf` (TPM, vi-mode, flexoki dark theme)
- `kitty/` — `.config/kitty/` (gruvbox dark theme, RobotoMono Nerd Font)
- `helix/` — `.config/helix/` (gruvbox dark, custom keybinds, LSP config)
- `claude/` — `.claude/CLAUDE.md` + agent skills (`baklavacutter`, `docments-to-docstrings`)
- `copilot/` — `.copilot/mcp-config.json`
- `gemini/` — `.gemini/antigravity/mcp_config.json`

## Scripts

- `install.sh` — Full bootstrap: installs brew, tools, agents, plugins, then runs `stow.sh`.
- `stow.sh` — Symlinks all packages and wires agent skills into `~/.claude/skills` and `~/.copilot/skills`.

## Adding a new package

1. Create a directory mirroring the target path relative to `$HOME` (e.g. `foo/.config/foo/config.toml`).
2. Add the directory name to the `stow` loop in `stow.sh`.
3. Run `./stow.sh`.
