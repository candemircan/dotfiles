#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# back up existing .zshrc if it's a real file (not a symlink from a previous stow)
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  echo "Backed up existing .zshrc to .zshrc.bak"
elif [ -L "$HOME/.zshrc" ]; then
  rm "$HOME/.zshrc"
fi
for pkg in zsh tmux helix kitty claude opencode; do
  stow -v -R -t "$HOME" "$pkg"
done

# Link skills into each agent's skills directory
SKILL_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.copilot/skills"
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
ln -sfn "$HOME/.claude/CLAUDE.md" "$HOME/.copilot/copilot-instructions.md"
ln -sfn "$HOME/.claude/CLAUDE.md" "$HOME/.gemini/GEMINI.md"
ln -sfn "$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md"

echo "All packages stowed, skills linked, and agent instructions symlinked."
