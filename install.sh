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
  brew install stow uv helix tmux zsh fzf starship btop yazi lazygit serpl node zoxide bat ripgrep fd llama-cpp

  info "Installing Homebrew casks..."
  brew install --cask firefox brave-browser visual-studio-code rectangle alfred kitty spotify

  # Nerd Fonts
  info "Installing RobotoMono Nerd Font..."
  brew install --cask font-roboto-mono-nerd-font

  # HuggingFace models for llama-cpp
  info "Installing HuggingFace CLI..."
  uv tool install 'huggingface_hub[cli]'

  export HF_HUB_CACHE="$HOME/.cache/huggingface/hub"
  info "Downloading gpt-oss-20b model..."
  hf download unsloth/gpt-oss-20b-GGUF gpt-oss-20b-UD-Q4_K_XL.gguf
  info "Downloading Devstral-Small-2 model..."
  hf download unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF Devstral-Small-2-24B-Instruct-2512-UD-Q4_K_XL.gguf
  info "Downloading Gemma-3-27b model..."
  hf download unsloth/gemma-3-27b-it-GGUF gemma-3-27b-it-UD-Q4_K_XL.gguf
}

# ---------- Linux (deb-based) ----------
install_linux() {
  info "Detected Linux"

  info "Updating apt and installing base packages..."
  sudo apt update
  sudo apt install -y stow tmux zsh fzf btop build-essential curl git ffmpeg gcc python3-dev kitty bat ripgrep fd-find

  # fd and bat have different names on Ubuntu - create symlinks
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    sudo ln -sf $(which fdfind) /usr/local/bin/fd
  fi
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    sudo ln -sf $(which batcat) /usr/local/bin/bat
  fi

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
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Helix (GitHub binary release)
  if ! command_exists hx; then
    info "Installing Helix..."
    HELIX_VERSION=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep -Po '"tag_name": "\K[^"]*')
    curl -fsSL "https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-x86_64-linux.tar.xz" -o /tmp/helix.tar.xz
    sudo mkdir -p /opt/helix
    sudo tar xf /tmp/helix.tar.xz -C /opt/helix --strip-components=1
    rm /tmp/helix.tar.xz
    sudo ln -sf /opt/helix/hx /usr/local/bin/hx
    mkdir -p "$HOME/.config/helix"
    ln -sf /opt/helix/runtime "$HOME/.config/helix/runtime"
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

  # Zoxide
  if ! command_exists zoxide; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
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

  # Spotify
  if ! command_exists spotify; then
    info "Installing Spotify..."
    curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y spotify-client
  fi

  # VS Code
  if ! command_exists code; then
    info "Installing VS Code..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code
  fi

  # Nerd Fonts
  if ! fc-list | grep -qi "RobotoMono Nerd Font"; then
    info "Installing RobotoMono Nerd Font..."
    NERD_FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
    mkdir -p "$NERD_FONT_DIR"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/RobotoMono.zip -o /tmp/RobotoMono.zip
    unzip -o /tmp/RobotoMono.zip -d "$NERD_FONT_DIR"
    rm /tmp/RobotoMono.zip
    fc-cache -fv
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
  if ! command_exists claude; then
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  if ! command_exists opencode; then
    info "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
  fi
  if ! command_exists gemini; then
    info "Installing Gemini CLI..."
    yes | npm install -g @google/gemini-cli 2>/dev/null || warn "gemini-cli install failed (check package name)"
  fi

  # python stuff
  uv tool install ruff
  uv tool install python-lsp-server

}

# ---------- Post-install ----------
post_install() {
  # Git identity (machine-local, not tracked)
  if [ ! -f "$HOME/.gitconfig.local" ]; then
    info "Setting up git identity (~/.gitconfig.local)..."
    printf 'Git user name: '  && read -r git_name
    printf 'Git email: '      && read -r git_email
    git config -f "$HOME/.gitconfig.local" user.name  "$git_name"
    git config -f "$HOME/.gitconfig.local" user.email "$git_email"
  fi

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
