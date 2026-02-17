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
for pkg in zsh tmux helix kitty claude copilot gemini; do
  stow -v -R -t "$HOME" "$pkg"
done

# Link skills into ~/.claude/skills/, ~/.copilot/skills/, and ~/.opencode/skills/
mkdir -p "$HOME/.claude/skills" "$HOME/.copilot/skills" "$HOME/.opencode/skills"
for skill_dir in "$HOME/.agent-skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$HOME/.claude/skills/$skill_name"
  ln -sfn "$skill_dir" "$HOME/.copilot/skills/$skill_name"
  ln -sfn "$skill_dir" "$HOME/.opencode/skills/$skill_name"
done

echo "All packages stowed and skills linked."
