# Dotfiles

GNU Stow-based dotfiles repo for macOS and Linux.

## Structure

Each top-level directory is a stow package symlinked into `$HOME`:

- `zsh/` — `.zshrc` (Oh My Zsh, fzf, starship, aliases)
- `tmux/` — `.tmux.conf` (TPM, vi-mode, flexoki dark theme)
- `kitty/` — `.config/kitty/` (gruvbox dark theme, RobotoMono Nerd Font)
- `helix/` — `.config/helix/` (gruvbox dark, custom keybinds, LSP config)
- `claude/` — `.claude/CLAUDE.md` (shared coding guidelines) + agent skills (`baklavacutter`, `docments-to-docstrings`)
- `opencode/` — `.config/opencode/` (opencode.json config, package.json plugin deps)

## Scripts

- `install.sh` — Full bootstrap: installs brew, tools, agents, plugins, then runs `stow.sh`.
- `stow.sh` — Symlinks all packages, wires agent skills, and shares instructions across agents.

## Agent integration

`claude/.claude/CLAUDE.md` is the single source of truth for coding guidelines. `stow.sh` symlinks it to each agent's expected path:

| Agent | Instructions | Skills |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills/` |
| Copilot CLI | `~/.copilot/copilot-instructions.md` | `~/.copilot/skills/` |
| Gemini CLI | `~/.gemini/GEMINI.md` | `~/.gemini/skills/` |
| OpenCode | `~/.config/opencode/AGENTS.md` | `~/.config/opencode/skills/` |

Skills from `~/.agent-skills/` are symlinked into all four skills directories.

## Adding a new package

1. Create a directory mirroring the target path relative to `$HOME` (e.g. `foo/.config/foo/config.toml`).
2. Add the directory name to the `stow` loop in `stow.sh`.
3. Run `./stow.sh`.
