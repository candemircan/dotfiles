#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for pkg in zsh tmux helix claude copilot gemini; do
  stow -v -R -t "$HOME" "$pkg"
done

# Link skills into ~/.claude/skills/ and ~/.copilot/skills/
mkdir -p "$HOME/.claude/skills" "$HOME/.copilot/skills"
for skill_dir in "$HOME/.agent-skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$HOME/.claude/skills/$skill_name"
  ln -sfn "$skill_dir" "$HOME/.copilot/skills/$skill_name"
done

echo "All packages stowed and skills linked."
