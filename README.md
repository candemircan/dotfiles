# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start

```bash
git clone https://github.com/candemircan/dotfiles.git
cd dotfiles
./install.sh
```

`install.sh` installs all dependencies (Homebrew, CLI tools, editors, AI agents, plugins) and symlinks configs via `stow.sh`.

To only symlink without installing anything:

```bash
./stow.sh
```

## What's included

| Package  | What it configures                                    |
|----------|-------------------------------------------------------|
| `zsh`    | Oh My Zsh, fzf, starship prompt, aliases              |
| `tmux`   | TPM, vi-mode copy, flexoki dark theme                 |
| `helix`  | Gruvbox dark, lazygit/yazi/serpl keybinds, LSP config |
| `claude` | Global CLAUDE.md, agent skills                        |
| `copilot`| MCP server config                                     |
| `gemini` | MCP server config                                     |

## Tools installed

Homebrew, stow, uv, helix, tmux, zsh, fzf, starship, btop, yazi, lazygit, serpl, node, kitty, Firefox, Brave, VS Code, Claude Code, GitHub Copilot, Google Gemini CLI.
