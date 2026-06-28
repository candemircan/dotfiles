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

for f in \
  .pi/agent/settings.json \
  .pi/agent/models.json \
  .pi/agent/background-run.json \
  .pi/agent/shell-guard.json \
  .pi/agent/extensions/background-run.md \
  .pi/agent/extensions/background-run.ts \
  .pi/agent/extensions/shell-guard.md \
  .pi/agent/extensions/shell-guard.ts \
  .pi/agent/skills/background-run \
  .pi/agent/skills/shell-guard
do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$HOME/$f.bak"
    echo "Backed up existing $f to $f.bak"
  elif [ -L "$HOME/$f" ]; then
    rm "$HOME/$f"
  fi
done

# Clean up old generated skill symlinks inside packages before running Stow.
# These are runtime links and should not become part of stowed source trees.
for repo_skill_dir in \
  "$DOTFILES_DIR/claude/.claude/skills" \
  "$DOTFILES_DIR/opencode/.config/opencode/skills" \
  "$DOTFILES_DIR/pi/.pi/agent/skills"
do
  if [ -d "$repo_skill_dir" ]; then
    find "$repo_skill_dir" -type l -delete
  fi
done

# Run GNU Stow. --no-folding keeps parent config directories real so runtime
# skill symlinks are created in $HOME instead of inside this repository.
for pkg in zsh tmux herdr helix kitty claude opencode pi git ruff; do
  stow --no-folding -v -R -t "$HOME" "$pkg"
done

# Link skills into each agent's runtime skills directory.
SKILL_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.config/opencode/skills"
  "$HOME/.pi/agent/skills"
)

remove_generated_skill_links() {
  local dest="$1"
  local link target

  [ -d "$dest" ] || return 0
  for link in "$dest"/*; do
    [ -L "$link" ] || continue
    target=$(readlink "$link")
    case "$target" in
      *"/.agent-skills/"*) rm "$link" ;;
    esac
  done
}

mkdir -p "${SKILL_DIRS[@]}"
for dest in "${SKILL_DIRS[@]}"; do
  remove_generated_skill_links "$dest"
  for skill_dir in "$HOME/.agent-skills"/*/; do
    [ -d "$skill_dir" ] || continue
    ln -sfn "$skill_dir" "$dest/$(basename "$skill_dir")"
  done
done


# Claude Code managed settings (machine-level safety policies)
MANAGED_SRC="$DOTFILES_DIR/claude/.claude/managed-settings.json"
if [ -f "$MANAGED_SRC" ]; then
  case "$(uname -s)" in
    Darwin) MANAGED_DEST="/Library/Application Support/ClaudeCode/managed-settings.json" ;;
    Linux)  MANAGED_DEST="/etc/claude-code/managed-settings.json" ;;
    *)      MANAGED_DEST="" ;;
  esac
  if [ -n "$MANAGED_DEST" ]; then
    printf 'Install Claude Code managed settings to %s? [y/N] ' "$MANAGED_DEST"
    read -r answer || answer=""
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
