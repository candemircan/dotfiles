# Dotfiles

GNU Stow-based dotfiles repo for macOS and Linux.

## Structure

Each top-level directory is a stow package symlinked into `$HOME`:

- `zsh/` — `.zshrc` (Oh My Zsh, fzf, zoxide, starship, aliases) + `.local/bin/` scripts
- `tmux/` — `.tmux.conf` (prefix `C-a`, TPM, flexoki dark theme)
- `kitty/` — `.config/kitty/` (gruvbox dark theme, RobotoMono Nerd Font, boots into tmux)
- `helix/` — `.config/helix/` (gruvbox dark, REPL pipe, serpl, LSP config)
- `claude/` — `.claude/CLAUDE.md` (shared coding guidelines) + agent skills (`baklavacutter`, `docments-to-docstrings`)
- `opencode/` — `.config/opencode/` (opencode.json config, package.json plugin deps)

### `zsh/.local/bin/` scripts

| Script | Purpose |
|---|---|
| `tmux-init-default` | Creates the `default` session (window 1 shell, window 9 btop) |
| `sessionizer` | fzf over `~/Projects` + `~/Projects/cpi`; creates/attaches sessions, activates `.venv` |
| `tmux-session-switcher` | fzf over open sessions; `Enter` switches, `Ctrl-X` kills |
| `tmux-yazi` | Yazi chooser popup; text files → `hx`, others → system opener |
| `tmux-obsidian` | Opens `$vault/Inbox.md` in helix (reads `~/.zsh_secrets`) |

## Scripts

- `install.sh` — Full bootstrap: installs brew, tools, agents, plugins, then runs `stow.sh`.
- `stow.sh` — Symlinks all packages, wires agent skills, and shares instructions across agents.

## Agent integration

`claude/.claude/CLAUDE.md` is the single source of truth for coding guidelines. `stow.sh` symlinks it to each agent's expected path:

| Agent | Instructions | Skills |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills/` |
| Gemini CLI | `~/.gemini/GEMINI.md` | `~/.gemini/skills/` |
| OpenCode | `~/.config/opencode/AGENTS.md` | `~/.config/opencode/skills/` |

Skills from `~/.agent-skills/` are symlinked into all four skills directories.

## Adding a new package

1. Create a directory mirroring the target path relative to `$HOME` (e.g. `foo/.config/foo/config.toml`).
2. Add the directory name to the `stow` loop in `stow.sh`.
3. Run `./stow.sh`.
