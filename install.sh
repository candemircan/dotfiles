#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*"; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

# ---------- macOS ----------
install_macos() {
  info "Detected macOS"

  # Homebrew
  if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
  fi

  info "Installing Homebrew formulae..."
  brew install stow uv helix tmux zsh fzf starship btop yazi lazygit serpl node

  info "Installing Homebrew casks..."
  brew install --cask firefox brave-browser visual-studio-code rectangle alfred
}

# ---------- Linux (deb-based) ----------
install_linux() {
  info "Detected Linux"

  info "Updating apt and installing base packages..."
  sudo apt update
  sudo apt install -y stow tmux zsh fzf btop build-essential curl git

  # Node.js via nodesource
  if ! command_exists node; then
    info "Installing Node.js via nodesource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
  fi

  # uv
  if ! command_exists uv; then
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi

  # Helix
  if ! command_exists hx; then
    info "Installing Helix..."
    sudo add-apt-repository -y ppa:maveonair/helix-editor
    sudo apt update
    sudo apt install -y helix
  fi

  # Starship
  if ! command_exists starship; then
    info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # Yazi
  if ! command_exists yazi; then
    info "Installing Yazi..."
    curl -fsSL https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip -o /tmp/yazi.zip
    unzip -o /tmp/yazi.zip -d /tmp/yazi
    sudo mv /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
    rm -rf /tmp/yazi /tmp/yazi.zip
  fi

  # Lazygit
  if ! command_exists lazygit; then
    info "Installing Lazygit..."
    LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -o /tmp/lazygit.tar.gz
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo mv /tmp/lazygit /usr/local/bin/
    rm /tmp/lazygit.tar.gz
  fi

  # serpl (via cargo)
  if ! command_exists serpl; then
    info "Installing serpl via cargo..."
    if ! command_exists cargo; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source "$HOME/.cargo/env"
    fi
    cargo install serpl
  fi

  # Firefox (already via apt above)

  # Brave browser
  if ! command_exists brave-browser; then
    info "Installing Brave browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser
  fi

  # VS Code
  if ! command_exists code; then
    info "Installing VS Code..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code
  fi

  # Clipboard tools for tmux
  if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    sudo apt install -y wl-clipboard
  else
    sudo apt install -y xclip
  fi
}

# ---------- Common (both OS) ----------
install_common() {
  # Oh My Zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # Zsh plugins
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi

  # TPM (Tmux Plugin Manager)
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  # cli agents
  curl -fsSL https://claude.ai/install.sh | bash
  curl -fsSL https://gh.io/copilot-install | bash
  npm install -g @google/gemini-cli 2>/dev/null || warn "gemini-cli install failed (check package name)"

  # VoiceMode
  info "Installing VoiceMode..."
  uvx voice-mode-install --yes 2>/dev/null || warn "VoiceMode install failed"

  # kitty
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
}

# ---------- Post-install ----------
post_install() {
  info "Running stow.sh to symlink dotfiles..."
  "$DOTFILES_DIR/stow.sh"

  # Set zsh as default shell
  if [ "$(basename "$SHELL")" != "zsh" ]; then
    info "Setting zsh as default shell..."
    ZSH_PATH="$(command -v zsh)"
    if ! grep -qF "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
  fi

  # Set kitty as default terminal (Linux)
  if [ "$OS" = "Linux" ] && command_exists kitty; then
    info "Setting kitty as default terminal..."
    sudo update-alternatives --set x-terminal-emulator "$(command -v kitty)" 2>/dev/null || warn "Could not set kitty as default terminal"
  fi

  # Install VoiceMode plugin for Claude Code
  info "Installing VoiceMode plugin for Claude Code..."
  claude mcp add voicemode -- uvx --refresh voice-mode 2>/dev/null || warn "Claude VoiceMode MCP setup failed"

  # TPM plugin install
  if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    info "Installing tmux plugins via TPM..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || warn "TPM plugin install failed"
  fi
}

# ---------- Main ----------
case "$OS" in
  Darwin) install_macos ;;
  Linux)  install_linux ;;
  *)      error "Unsupported OS: $OS" ;;
esac

install_common
post_install

info "Done! Open a new terminal to start using your dotfiles."
