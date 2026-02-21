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
| `tmux` | Prefix `C-a`, TPM, sessionizer, popups, flexoki dark |
| `helix` | Gruvbox dark, REPL pipe to ipython, serpl, LSP config |
| `kitty` | RobotoMono Nerd Font, gruvbox theme, boots into tmux |
| `claude` | Shared coding guidelines + agent skills (all 4 agents) |
| `opencode` | opencode.json config + plugin deps |

## Tools installed

`stow uv helix tmux zsh fzf starship btop yazi lazygit serpl node zoxide` via Homebrew (macOS) or apt/curl (Linux), plus kitty, Firefox, Brave, VS Code, Claude Code, GitHub Copilot, Gemini CLI, OpenCode.

## One-time setup after install

```bash
# Set your Obsidian vault path (gitignored, device-specific)
echo 'export vault="/path/to/your/ObsidianVault"' >> ~/.zsh_secrets
```

See [CHEATSHEET.md](CHEATSHEET.md) for all keybindings.

To Do
- [] glow md
- [] ripgrep fd fzf

