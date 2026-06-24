#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Fix: Dynamically set DOTFILES_DIR so the script knows where it is running from
DOTFILES_DIR="$(pwd)"

# Back up existing configs if they're real files (not symlinks from a previous stow)
for f in .zshrc .gitconfig; do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$HOME/$f.bak"
    echo "Backed up existing $f to $f.bak"
  elif [ -L "$HOME/$f" ]; then
    rm "$HOME/$f"
  fi
done

# Fix: Clean up old symlinks inside the opencode package before running Stow
# This prevents GNU Stow from throwing absolute symlink conflict errors.
OPENCODE_SKILL_DIR="$DOTFILES_DIR/opencode/.config/opencode/skills"
if [ -d "$OPENCODE_SKILL_DIR" ]; then
  find "$OPENCODE_SKILL_DIR" -type l -delete
fi

# Run GNU Stow
for pkg in zsh tmux helix kitty claude opencode git ruff; do
  stow -v -R -t "$HOME" "$pkg"
done

# Link skills into each agent's skills directory
SKILL_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.gemini/skills"
)

# Re-create directory and link skills for opencode package
mkdir -p "$OPENCODE_SKILL_DIR"
for skill_dir in "$HOME/.agent-skills"/*/; do
  [ -d "$skill_dir" ] || continue
  ln -sfn "$skill_dir" "$OPENCODE_SKILL_DIR/$(basename "$skill_dir")"
done

# Link skills for other AI agents
mkdir -p "${SKILL_DIRS[@]}"
for skill_dir in "$HOME/.agent-skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  for dest in "${SKILL_DIRS[@]}"; do
    ln -sfn "$skill_dir" "$dest/$skill_name"
  done
done


# Claude Code managed settings (machine-level safety policies)
MANAGED_SRC="$DOTFILES_DIR/claude/managed-settings.json"
if [ -f "$MANAGED_SRC" ]; then
  case "$(uname -s)" in
    Darwin) MANAGED_DEST="/Library/Application Support/ClaudeCode/managed-settings.json" ;;
    Linux)  MANAGED_DEST="/etc/claude-code/managed-settings.json" ;;
    *)      MANAGED_DEST="" ;;
  esac
  if [ -n "$MANAGED_DEST" ]; then
    printf 'Install Claude Code managed settings to %s? [y/N] ' "$MANAGED_DEST"
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      sudo mkdir -p "$(dirname "$MANAGED_DEST")"
      sudo cp "$MANAGED_SRC" "$MANAGED_DEST"
      echo "Installed managed settings to $MANAGED_DEST"
    else
      echo "Skipped managed settings installation."
    fi
  fi
fi

echo "All packages stowed, skills linked, and agent instructions symlinked."
