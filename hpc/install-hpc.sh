#!/usr/bin/env bash
# HPC bootstrap: no sudo, no package manager. Installs user-space tools into
# ~/.local/bin and links the shared dotfiles plus the hpc/ override layer.
# Run this on a LOGIN node (compute nodes usually have no internet).
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL_BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
export PATH="$LOCAL_BIN:$PATH"

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*"; exit 1; }
command_exists() { command -v "$1" &>/dev/null; }

# ---------- preflight ----------
[ "$(uname -s)" = "Linux" ] || error "This script targets Linux HPC. Use install.sh on macOS."
command_exists curl || error "curl is required and was not found."

case "$(uname -m)" in
  x86_64)        MUSL=x86_64-unknown-linux-musl; GNU=x86_64-unknown-linux-gnu; HELIX=x86_64-linux; GO=Linux_x86_64; FZF=linux_amd64; JQ=linux-amd64 ;;
  aarch64|arm64) MUSL=aarch64-unknown-linux-musl; GNU=aarch64-unknown-linux-gnu; HELIX=aarch64-linux; GO=Linux_arm64; FZF=linux_arm64; JQ=linux-arm64 ;;
  *)             error "Unsupported architecture: $(uname -m)" ;;
esac

if ! curl -fsI https://github.com >/dev/null 2>&1; then
  warn "No route to github.com. Downloads will fail. Run this on a login node with internet."
fi

mkdir -p "$LOCAL_BIN" "$OPT"

# ---------- download helpers ----------
# Resolve the latest release tag via the web redirect (no API, no 60/hr limit).
# /releases/latest 302-redirects to /releases/tag/<TAG>; read <TAG> off the URL.
gh_latest_tag() {
  curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" 2>/dev/null \
    | sed -E 's#.*/tag/##' || true
}

# Find a release asset URL matching a regex, using the web endpoints only.
# The API is rate-limited per IP (60/hr), which HPC login nodes share and exhaust.
gh_asset_url() { # repo  asset-regex
  local tag; tag="$(gh_latest_tag "$1")"
  [ -n "$tag" ] || return 0
  curl -fsSL "https://github.com/$1/releases/expanded_assets/$tag" 2>/dev/null \
    | grep -oE "/$1/releases/download/[^\"]+" \
    | grep -E "$2" \
    | head -n1 \
    | sed 's#^#https://github.com#' || true
}

# Download an archive, extract one binary from it, install it to ~/.local/bin.
fetch_bin_from_url() {
  local url="$1" bin="$2" dest="$3" tmp found
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/pkg" || { rm -rf "$tmp"; return 1; }
  case "$url" in
    *.tar.gz|*.tgz) tar -xzf "$tmp/pkg" -C "$tmp" ;;
    *.tar.xz)       tar -xJf "$tmp/pkg" -C "$tmp" ;;
    *.zip)          command_exists unzip || { warn "unzip missing; cannot install $dest"; rm -rf "$tmp"; return 1; }
                    unzip -qo "$tmp/pkg" -d "$tmp" ;;
    *)              rm -rf "$tmp"; return 1 ;;
  esac
  found="$(find "$tmp" -type f -name "$bin" -perm -u+x 2>/dev/null | head -n1)"
  [ -n "$found" ] || found="$(find "$tmp" -type f -name "$bin" 2>/dev/null | head -n1)"
  [ -n "$found" ] || { rm -rf "$tmp"; return 1; }
  cp "$found" "$LOCAL_BIN/$dest" && chmod +x "$LOCAL_BIN/$dest"
  rm -rf "$tmp"
}

# Install a single binary that lives inside a GitHub release archive.
install_tar_tool() { # repo  asset-regex  name
  command_exists "$3" && { info "$3 already present"; return 0; }
  info "Installing $3..."
  local url; url="$(gh_asset_url "$1" "$2")"
  [ -n "$url" ] || { warn "$3: no matching release asset"; return 0; }
  fetch_bin_from_url "$url" "$3" "$3" || warn "$3 install failed"
}

# ---------- Python: uv, ruff, ty ----------
install_python() {
  if ! command_exists uv; then
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh || warn "uv install failed"
  fi
  command_exists uv || { warn "uv not on PATH; skipping ruff/ty"; return 0; }
  uv tool install ruff || warn "ruff install failed"
  uv tool install ty   || warn "ty install failed"
}

# ---------- CLI tools ----------
install_cli() {
  if ! command_exists starship; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$LOCAL_BIN" || warn "starship install failed"
  fi
  if ! command_exists zoxide; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh || warn "zoxide install failed"
  fi
  if ! command_exists jq; then
    info "Installing jq..."
    curl -fsSL "https://github.com/jqlang/jq/releases/latest/download/jq-$JQ" -o "$LOCAL_BIN/jq" \
      && chmod +x "$LOCAL_BIN/jq" || warn "jq install failed"
  fi

  install_tar_tool junegunn/fzf         "$FZF\\.tar\\.gz$"  fzf
  install_tar_tool BurntSushi/ripgrep   "$MUSL\\.tar\\.gz$" rg
  install_tar_tool sharkdp/fd           "$MUSL\\.tar\\.gz$" fd
  install_tar_tool sharkdp/bat          "$MUSL\\.tar\\.gz$" bat
  install_tar_tool dandavison/delta     "$MUSL\\.tar\\.gz$" delta
  install_tar_tool jesseduffield/lazygit "$GO\\.tar\\.gz$"  lazygit
  install_tar_tool sxyazi/yazi          "$GNU\\.zip$"       yazi
}

# ---------- Helix (binary + runtime) ----------
install_helix() {
  command_exists hx && { info "helix already present"; return 0; }
  info "Installing helix..."
  local url; url="$(gh_asset_url helix-editor/helix "helix-.*-$HELIX\\.tar\\.xz$")"
  [ -n "$url" ] || { warn "helix: no matching asset"; return 0; }
  local tmp; tmp="$(mktemp -d)"
  if ! curl -fsSL "$url" -o "$tmp/helix.tar.xz"; then warn "helix download failed"; rm -rf "$tmp"; return 0; fi
  mkdir -p "$OPT/helix"
  if ! tar -xJf "$tmp/helix.tar.xz" -C "$OPT/helix" --strip-components=1; then
    warn "helix extract failed (xz may be missing)"; rm -rf "$tmp"; return 0
  fi
  rm -rf "$tmp"
  ln -sfn "$OPT/helix/hx" "$LOCAL_BIN/hx"
  mkdir -p "$HOME/.config/helix"
  ln -sfn "$OPT/helix/runtime" "$HOME/.config/helix/runtime"
}

# ---------- zsh framework ----------
install_zsh_framework() {
  if ! command_exists zsh; then
    warn "zsh not found. Try 'module load zsh' or ask the cluster admins."
    warn "The HPC profile targets zsh; the exec-zsh hook stays inert until zsh exists."
  fi
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "omz install failed"
  fi
  local zc="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [ -d "$zc/plugins/zsh-autosuggestions" ]     || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$zc/plugins/zsh-autosuggestions" || warn "autosuggestions clone failed"
  [ -d "$zc/plugins/zsh-syntax-highlighting" ] || git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$zc/plugins/zsh-syntax-highlighting" || warn "syntax-highlighting clone failed"
  [ -d "$HOME/.tmux/plugins/tpm" ]             || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || warn "tpm clone failed"
}

# ---------- symlink shared configs + hpc overrides ----------
link_one() { # src  dest
  local src="$1" dest="$2"
  [ -e "$src" ] || { warn "missing source: $src"; return 0; }
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"; info "backed up $dest -> $dest.bak"
  elif [ -L "$dest" ]; then
    rm "$dest"
  fi
  ln -sfn "$src" "$dest"
}

link_configs() {
  info "Linking configs..."
  link_one "$DOTFILES_DIR/zsh/.zshrc"            "$HOME/.zshrc"
  link_one "$DOTFILES_DIR/zsh/.zshenv"           "$HOME/.zshenv"
  link_one "$DOTFILES_DIR/tmux/.tmux.conf"       "$HOME/.tmux.conf"
  link_one "$DOTFILES_DIR/git/.gitconfig"        "$HOME/.gitconfig"
  link_one "$DOTFILES_DIR/hpc/.zshenv.local"     "$HOME/.zshenv.local"
  link_one "$DOTFILES_DIR/hpc/.zshrc.local"      "$HOME/.zshrc.local"
  link_one "$DOTFILES_DIR/hpc/.tmux.conf.local"  "$HOME/.tmux.conf.local"

  mkdir -p "$HOME/.config/helix" "$HOME/.config/ruff"
  link_one "$DOTFILES_DIR/helix/.config/helix/config.toml"    "$HOME/.config/helix/config.toml"
  link_one "$DOTFILES_DIR/helix/.config/helix/languages.toml" "$HOME/.config/helix/languages.toml"
  link_one "$DOTFILES_DIR/ruff/.config/ruff/pyproject.toml"   "$HOME/.config/ruff/pyproject.toml"
  link_one "$DOTFILES_DIR/hpc/starship.toml"                  "$HOME/.config/starship.toml"
}

# ---------- machine-local values (untracked) ----------
write_hpc_local() {
  [ -f "$HOME/.hpc.local" ] && { info "~/.hpc.local exists; leaving it"; return 0; }
  local default_base="${SCRATCH:-}" base
  printf 'Large scratch/work path for caches (uv, pip, HF). Empty = use $HOME [%s]: ' "$default_base"
  read -r base || base=""
  base="${base:-$default_base}"
  {
    echo "# Machine-local HPC values (untracked). Sourced first by ~/.zshenv.local."
    [ -n "$base" ] && echo "export DOTFILES_CACHE_BASE=\"$base\""
    echo "# Cluster module loads (guarded so scripts and batch jobs do not break):"
    echo "# command -v module >/dev/null 2>&1 && module load git tmux"
  } > "$HOME/.hpc.local"
  info "Wrote ~/.hpc.local"
}

# ---------- launch zsh from bash on login ----------
setup_bash_profile() {
  local marker="# >>> dotfiles hpc exec-zsh >>>"
  if grep -qF "$marker" "$HOME/.bash_profile" 2>/dev/null; then
    info "bash_profile exec-zsh hook already present"; return 0
  fi
  info "Adding exec-zsh hook to ~/.bash_profile..."
  cat >> "$HOME/.bash_profile" <<'EOF'

# >>> dotfiles hpc exec-zsh >>>
# Launch zsh for interactive shells (chsh is often disabled on HPC).
# Guarded so batch jobs (non-interactive) and shells already in zsh are untouched.
if [ -z "${ZSH_VERSION:-}" ]; then
  case $- in
    *i*)
      if command -v zsh >/dev/null 2>&1; then
        export SHELL="$(command -v zsh)"
        exec zsh -l
      fi
      ;;
  esac
fi
# <<< dotfiles hpc exec-zsh <<<
EOF
}

# ---------- git identity (machine-local) ----------
setup_git_identity() {
  [ -f "$HOME/.gitconfig.local" ] && return 0
  info "Setting up git identity (~/.gitconfig.local)..."
  printf 'Git user name: ' && read -r git_name
  printf 'Git email: '     && read -r git_email
  git config -f "$HOME/.gitconfig.local" user.name  "$git_name"
  git config -f "$HOME/.gitconfig.local" user.email "$git_email"
}

# ---------- coding agents (optional) ----------
install_agents() {
  printf 'Install Claude Code + Pi agents and link shared instructions/skills? [y/N] '
  local ans; read -r ans || ans=""
  case "$ans" in y|Y) ;; *) info "Skipping agents"; return 0 ;; esac

  command_exists claude || { info "Installing Claude Code..."; curl -fsSL https://claude.ai/install.sh | bash || warn "claude install failed"; }
  command_exists pi     || { info "Installing Pi...";         curl -fsSL https://pi.dev/install.sh   | sh   || warn "pi install failed"; }

  mkdir -p "$HOME/.claude/skills" "$HOME/.pi/agent/skills"
  # One shared instruction file for both agents (mirrors stow.sh).
  ln -sfn "$DOTFILES_DIR/claude/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  ln -sfn "$DOTFILES_DIR/claude/.claude/CLAUDE.md" "$HOME/.pi/agent/AGENTS.md"
  # Link tracked skills into both agents.
  for dest in "$HOME/.claude/skills" "$HOME/.pi/agent/skills"; do
    for skill_dir in "$DOTFILES_DIR/agent-skills"/*/; do
      [ -d "$skill_dir" ] || continue
      ln -sfn "$skill_dir" "$dest/$(basename "$skill_dir")"
    done
  done
  info "Agent settings.json is NOT linked on HPC (it holds macOS-specific hook paths)."
}

# ---------- notes ----------
final_notes() {
  cat <<'EOF'

[INFO]  Done. Next steps:
  1. Start a fresh login shell (or run: exec zsh -l).
  2. tmux and git are best provided by the cluster: run 'module avail tmux git',
     then add the matching 'module load ...' lines to ~/.hpc.local (guarded).
  3. On HPC, tmux uses prefix C-b (so it does not clash with a local C-a tmux).
  4. Caches (uv, pip, HuggingFace) go under $DOTFILES_CACHE_BASE. Check ~/.hpc.local.
  5. Do installs on a login node. Compute nodes usually have no internet.
EOF
}

# ---------- main ----------
info "Dotfiles HPC profile bootstrap"
install_python
install_cli
install_helix
install_zsh_framework
link_configs
write_hpc_local
setup_git_identity
setup_bash_profile
install_agents
final_notes
