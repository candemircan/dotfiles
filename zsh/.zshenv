# Sourced by every zsh invocation: interactive shells, the #!/bin/zsh scripts in
# ~/.local/bin, and the agent shell snapshot. Put env vars that all three need here.

# uv
export PATH="$HOME/.local/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Single source of truth for presentation paths.
export PRESENTATIONS_DIR="$HOME/Projects/cpi/presentations"
export BIB_MASTER="$HOME/Zotero/library.bib"

# Machine-local env layer (HPC caches, etc). Absent on the laptop, so this no-ops.
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
