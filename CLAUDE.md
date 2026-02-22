# Dotfiles

GNU Stow-based dotfiles repo for macOS and Linux.

## Structure

Each top-level directory is a stow package symlinked into `$HOME`:

- `zsh/` — `.zshrc` (Oh My Zsh, fzf, zoxide, starship, aliases, local AI functions) + `.local/bin/` scripts
- `tmux/` — `.tmux.conf` (prefix `C-a`, TPM, flexoki dark theme)
- `kitty/` — `.config/kitty/` (gruvbox dark theme, RobotoMono Nerd Font, boots into tmux)
- `helix/` — `.config/helix/` (gruvbox dark, REPL pipe, serpl, LSP config)
- `claude/` — `.claude/CLAUDE.md` (shared coding guidelines) + agent skills (`baklavacutter`, `docments-to-docstrings`)
- `opencode/` — `.config/opencode/` (opencode.json config, package.json plugin deps)
- `git/` — `.gitconfig` (shared settings); user name/email go in `~/.gitconfig.local` (not tracked)

### `zsh/.local/bin/` scripts

| Script | Purpose |
|---|---|
| `tmux-init-default` | Creates the `default` session (window 1 shell, window 9 btop) |
| `sessionizer` | fzf over `~/Projects` + `~/Projects/cpi`; creates/attaches sessions, activates `.venv` |
| `tmux-yazi` | Yazi chooser popup; text files → `hx`, others → system opener |
| `tmux-obsidian` | Opens `$vault/Inbox.md` in helix (reads `~/.zsh_secrets`) |

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
