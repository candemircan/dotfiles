#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
PKG_MGR=""

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
  brew install stow uv helix tmux zsh fzf starship btop yazi lazygit serpl node zoxide bat git-delta glow ripgrep fd jq llama.cpp

  info "Installing Homebrew casks..."
  brew install --cask firefox chromium rectangle alfred kitty obsidian

  # Nerd Fonts
  info "Installing RobotoMono Nerd Font..."
  brew install --cask font-roboto-mono-nerd-font

}

# ---------- Linux (apt-based: Debian/Ubuntu) ----------
install_linux_apt() {
  info "Using apt package manager"

  info "Updating apt and installing base packages..."
  sudo apt update
  sudo apt install -y stow tmux zsh fzf btop build-essential curl git ffmpeg gcc python3-dev kitty bat ripgrep fd-find jq sdcv rclone bubblewrap socat xournalpp

  if ! command_exists delta; then
    info "Installing git-delta..."
    sudo apt install -y git-delta || warn "git-delta install failed"
  fi

  if ! command_exists glow; then
    info "Installing Glow..."
    sudo mkdir -p /etc/apt/keyrings
    if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg; then
      printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *' | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
      sudo apt update
      sudo apt install -y glow || warn "glow install failed"
    else
      warn "Charm apt key install failed; skipping glow"
    fi
  fi

  # fd and bat have different names on Debian/Ubuntu - create symlinks
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
  fi
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    sudo ln -sf "$(which batcat)" /usr/local/bin/bat
  fi

  # Node.js via nodesource
  if ! command_exists node; then
    info "Installing Node.js via nodesource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
  fi

  # Chromium (Ubuntu's chromium-browser is a snap stub, so prefer the deb)
  if ! command_exists chromium && ! command_exists chromium-browser; then
    info "Installing Chromium..."
    sudo apt install -y chromium || sudo apt install -y chromium-browser || warn "Chromium install failed"
  fi

  # Clipboard tools for tmux
  if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    sudo apt install -y wl-clipboard
  else
    sudo apt install -y xclip
  fi
}

# ---------- Linux (dnf-based: Fedora) ----------
install_linux_dnf() {
  info "Using dnf package manager (Fedora)"

  info "Installing base packages via dnf..."
  local pkgs=(
    stow tmux zsh fzf btop kitty bat ripgrep fd-find jq rclone bubblewrap socat xournalpp
    git-delta glow helix starship zoxide yazi lazygit uv nodejs
    gcc gcc-c++ make curl git unzip python3-devel
    firefox chromium sdcv
  )
  # --skip-unavailable lets the batch succeed even if a package is missing from
  # this Fedora version's repos; the curl installers below act as fallback.
  sudo dnf install -y --skip-unavailable "${pkgs[@]}" || {
    warn "Batch install failed; trying packages one by one..."
    for pkg in "${pkgs[@]}"; do
      sudo dnf install -y "$pkg" || warn "Could not install $pkg"
    done
  }

  # Full ffmpeg is patent-encumbered and only available via RPM Fusion
  if ! command_exists ffmpeg; then
    info "Installing ffmpeg..."
    sudo dnf install -y ffmpeg \
      || sudo dnf install -y ffmpeg-free \
      || warn "ffmpeg unavailable — enable RPM Fusion for the full build"
  fi

  # Clipboard tools for tmux
  if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    sudo dnf install -y wl-clipboard
  else
    sudo dnf install -y xclip
  fi
}

# ---------- Linux dispatcher ----------
install_linux() {
  info "Detected Linux"
  if command_exists dnf; then
    PKG_MGR=dnf
    install_linux_dnf
  elif command_exists apt; then
    PKG_MGR=apt
    install_linux_apt
  else
    error "No supported package manager found (need dnf or apt)"
  fi
  install_linux_common
}

# ---------- Linux (shared, distro-agnostic installers) ----------
install_linux_common() {
  # uv
  if ! command_exists uv; then
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # llama.cpp
  if ! command_exists llama-cli; then
    info "Installing llama.cpp..."
    curl -LsSf https://llama.app/install.sh | sh
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

  # Obsidian (AppImage — universal across distros)
  if ! command_exists obsidian; then
    info "Installing Obsidian via AppImage..."
    OBSIDIAN_VERSION="$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -Po '"tag_name": "v\K[^"]*')"
    if [ -z "$OBSIDIAN_VERSION" ]; then
      warn "Could not determine latest Obsidian version; skipping"
    else
      ARCH="$(uname -m)"
      case "$ARCH" in
        x86_64)        SUFFIX="" ;;
        aarch64|arm64) SUFFIX="-arm64" ;;
        *)             SUFFIX=""; warn "Unsupported arch '$ARCH' for Obsidian; trying x86_64 build" ;;
      esac
      URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}${SUFFIX}.AppImage"
      if curl -fsSL "$URL" -o /tmp/Obsidian.AppImage; then
        sudo install -Dm755 /tmp/Obsidian.AppImage /opt/obsidian/obsidian.AppImage
        sudo ln -sf /opt/obsidian/obsidian.AppImage /usr/local/bin/obsidian
        rm -f /tmp/Obsidian.AppImage

        # AppImages require FUSE to mount themselves at launch
        case "$PKG_MGR" in
          apt) sudo apt install -y libfuse2 2>/dev/null || sudo apt install -y libfuse2t64 2>/dev/null || warn "libfuse2 install failed; AppImages may not launch" ;;
          dnf) sudo dnf install -y fuse 2>/dev/null || true ;;
        esac

        # Desktop launcher integration (best-effort: extracts icon + writes .desktop)
        rm -rf /tmp/squashfs-root
        ( cd /tmp && /opt/obsidian/obsidian.AppImage --appimage-extract &>/dev/null ) || true
        ICON_SRC="$(readlink -f /tmp/squashfs-root/.DirIcon 2>/dev/null)"
        if [ -n "$ICON_SRC" ] && [ -f "$ICON_SRC" ]; then
          sudo install -Dm644 "$ICON_SRC" /usr/share/icons/hicolor/512x512/apps/obsidian.png
          sudo tee /usr/share/applications/obsidian.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Obsidian
Comment=A knowledge base that works on local Markdown files
Exec=/usr/local/bin/obsidian %U
Icon=obsidian
Terminal=false
Type=Application
Categories=Office;Utility;TextEditor;
StartupWMClass=Obsidian
MimeType=x-scheme-handler/obsidian;
EOF
          ( command -v gtk-update-icon-cache >/dev/null && sudo gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null ) || true
          ( command -v update-desktop-database >/dev/null && sudo update-desktop-database /usr/share/applications 2>/dev/null ) || true
        else
          warn "Could not extract Obsidian icon; launch with 'obsidian' from terminal"
        fi
        rm -rf /tmp/squashfs-root
      else
        warn "Obsidian AppImage download failed: $URL"
      fi
    fi
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

  if ! command_exists herdr; then
    info "Installing herdr"
    curl -fsSL https://herdr.dev/install.sh | sh
  fi

  # herdr stores plugins in its own dir outside the stowed tree, so the pinned
  # install is scripted here rather than tracked as a file. .zshrc sources its
  # shell hook by glob, which no-ops until this runs.
  if ! herdr plugin list --json 2>/dev/null | jq -e '.result.plugins[]? | select(.plugin_id=="herdr-automatic-rename")' >/dev/null 2>&1; then
    info "Installing herdr-automatic-rename plugin (pinned v0.5.0)..."
    herdr plugin install qu8n/herdr-automatic-rename --ref v0.5.0 --yes || warn "herdr-automatic-rename install failed"
  fi

  # cli agents
  if ! command_exists claude; then
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  if ! command_exists pi; then
    info "Installing Pi Coding Agent..."
    curl -fsSL https://pi.dev/install.sh | sh
  fi

  # srt (sandbox-runtime) backs the `sclaude`/`spi` wrappers; the policy file
  # is stowed from srt/. Linux additionally needs the bubblewrap and socat
  # distro packages (installed above); srt resolves them from PATH.
  if ! command_exists srt; then
    info "Installing sandbox-runtime (srt)..."
    npm install -g @anthropic-ai/sandbox-runtime@0.0.71 || warn "srt install failed"
  fi

  info "Installing Pi packages..."
  pi install npm:pi-web-access --no-approve || warn "pi-web-access install failed"
  pi install npm:@tmustier/pi-files-widget --no-approve || warn "pi-files-widget install failed"
  pi install git:github.com/huggingface/pi-llama --no-approve || warn "pi-llama install failed"

  # Agent skills, scoped per agent. `--agent` takes space-separated agent ids
  # (commas are rejected). Runs after the agents are installed so the skills CLI
  # can find their skills directories.
  #
  # Always pass --agent. A bare `-g` installs into every agent it detects, which
  # sprays skills into config dirs for agents that are not installed here.
  info "Installing agent skills..."
  npx --yes skills add ogulcancelik/herdr --skill herdr -g -y --agent claude-code pi || warn "herdr skill install failed"
  npx --yes skills add vercel-labs/skills --skill find-skills -g -y --agent claude-code pi || warn "find-skills skill install failed"
  npx --yes skills add ogulcancelik/agent-skills --skill web-search -g -y --agent pi || warn "web-search skill install failed"
  npx --yes skills add ogulcancelik/agent-skills --skill preflight -g -y --agent claude-code pi || warn "preflight skill install failed"

  # python stuff
  uv tool install ruff
  uv tool install ty

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

  # Set kitty as default terminal (apt-based Linux only; no equivalent on Fedora)
  if [ "$PKG_MGR" = "apt" ] && command_exists kitty; then
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
