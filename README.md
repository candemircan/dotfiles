# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start

```bash
git clone https://github.com/candemircan/dotfiles.git
cd dotfiles
./install.sh
```

`install.sh` installs all dependencies (Homebrew, CLI tools, editors, AI agents) and symlinks configs via `stow.sh`.

To only symlink without installing:

```bash
./stow.sh
```

## What's included

| Package | What it configures |
|---|---|
| `zsh` | Oh My Zsh, fzf, zoxide, starship, aliases, local scripts |
| `tmux` | Legacy tmux config kept for rollback |
| `herdr` | Primary workspace manager: prefix `C-a`, native navigator, temporary panes, default/btop spaces |
| `helix` | Gruvbox dark, REPL pipe to ipython, serpl, LSP config |
| `ruff` | Global Ruff defaults (`~/.config/ruff/pyproject.toml`) |
| `kitty` | RobotoMono Nerd Font, gruvbox theme, boots into Herdr |
| `claude` | Shared coding guidelines + agent skills |
| `opencode` | opencode.json config |
| `pi` | Pi Coding Agent defaults + OpenCode Go model provider |

## Tools installed

`stow uv helix tmux zsh fzf starship btop yazi lazygit serpl node zoxide` via Homebrew (macOS) or apt/curl (Linux), plus kitty, Firefox, Brave, Spotify, VS Code, Claude Code, OpenCode, and Pi Coding Agent.

Kitty starts Herdr through `~/.local/bin/herdr-init-default`, which ensures `default` and `btop` spaces exist before attaching.

macOS installs `llama.cpp` via Homebrew. Linux installs `llama.cpp` via `https://llama.app/install.sh`. No local GGUF models are downloaded by default.

## One-time setup after install

```bash
# Set your Obsidian vault path (gitignored, device-specific)
echo 'export vault="/path/to/your/ObsidianVault"' >> ~/.zsh_secrets
```

See [CHEATSHEET.md](CHEATSHEET.md) for all keybindings.
