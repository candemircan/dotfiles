#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# back up existing configs if they're real files (not symlinks from a previous stow)
for f in .zshrc .gitconfig; do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$HOME/$f.bak"
    echo "Backed up existing $f to $f.bak"
  elif [ -L "$HOME/$f" ]; then
    rm "$HOME/$f"
  fi
done
for pkg in zsh tmux helix kitty claude opencode git; do
  stow -v -R -t "$HOME" "$pkg"
done

# Link skills into each agent's skills directory
SKILL_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.gemini/skills"
  "$HOME/.config/opencode/skills"
)
mkdir -p "${SKILL_DIRS[@]}"
for skill_dir in "$HOME/.agent-skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  for dest in "${SKILL_DIRS[@]}"; do
    ln -sfn "$skill_dir" "$dest/$skill_name"
  done
done

# Symlink shared instructions to each agent's expected path
ln -sfn "$HOME/.claude/CLAUDE.md" "$HOME/.gemini/GEMINI.md"
ln -sfn "$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md"

echo "All packages stowed, skills linked, and agent instructions symlinked."
