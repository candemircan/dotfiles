[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Performance: Smarter Path Management (Avoid duplicates)
typeset -U path  # Keep path unique
path=(
    ~/.local/bin
    ~/.config/helix
    ~/.juliaup/bin
    $path
)


# Lightweight shell setup. Loading all of Oh My Zsh runs compinit on every new
# shell, which dominates pane startup time in tmux/herdr.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh}"
export CLAUDE_TRANSCRIPT_CAPTURE_SYSTEM_PROMPT=1 # my claude transcript capture
mkdir -p "$ZSH_CACHE_DIR/completions" 2>/dev/null
fpath=(
    "$ZSH_CACHE_DIR/completions"
    "$ZSH/functions"
    "$ZSH/completions"
    "$ZSH_CUSTOM/functions"
    "$ZSH_CUSTOM/completions"
    "$ZSH/plugins/git"
    $fpath
)

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gcb='git checkout -b'
alias gco='git checkout'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gcmsg='git commit --message'
alias gd='git diff'
alias gdca='git diff --cached'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'

if [[ -o interactive && -t 0 && -t 1 && -r "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

autoload -Uz compinit
zstyle ':completion:*' menu select

_lazy_compinit() {
    (( ${+_ZSH_COMPINIT_LOADED} )) && return
    typeset -g _ZSH_COMPINIT_LOADED=1
    compinit -C -d "${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump-${HOST%%.*}-${ZSH_VERSION}}"
}

_lazy_expand_or_complete() {
    _lazy_compinit
    zle .expand-or-complete
}

_lazy_reverse_menu_complete() {
    _lazy_compinit
    zle .reverse-menu-complete
}

if [[ -o interactive && -t 0 && -t 1 ]]; then
  zle -N expand-or-complete _lazy_expand_or_complete
  zle -N reverse-menu-complete _lazy_reverse_menu_complete
  bindkey '^I' expand-or-complete
  bindkey '^[[Z' reverse-menu-complete

  if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
  else
    # fzf >= 0.48 bundles key-bindings + completion in `--zsh` output.
    # (Fedora's fzf package no longer ships completion.zsh in
    # /usr/share/fzf/shell, so sourcing the files directly breaks.)
    _fzf_integration="$(command fzf --zsh 2>/dev/null)"
    if [ -n "$_fzf_integration" ]; then
      eval "$_fzf_integration"
    elif [ -d /usr/share/doc/fzf/examples ]; then
      # Debian/Ubuntu
      for _f in key-bindings.zsh completion.zsh; do
        [ -f "/usr/share/doc/fzf/examples/$_f" ] && source "/usr/share/doc/fzf/examples/$_f"
      done
    elif [ -d /usr/share/fzf/shell ]; then
      # Fedora (older fzf packaging)
      for _f in key-bindings.zsh completion.zsh; do
        [ -f "/usr/share/fzf/shell/$_f" ] && source "/usr/share/fzf/shell/$_f"
      done
    fi
    unset _fzf_integration _f
  fi
fi
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


export EDITOR=hx
alias py='python -m pdb -c c'
alias p='bat --style=plain --paging=never'

# fzf with ripgrep and fd for better performance
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# --- Sandboxed coding agents ------------------------------------------------
# `sclaude` and `spi` wrap Claude Code and Pi in srt (Anthropic sandbox-runtime):
# Seatbelt on macOS, bubblewrap + socat on Linux (distro packages, installed by
# install.sh; srt does not bundle them). Policy: ~/.srt-settings.json, stowed
# from srt/. Writes are limited to $PWD, /tmp and the agents' own state dirs;
# common secret files are unreadable; outbound traffic goes through srt's
# proxy and is limited to the allowlisted domains. `--` keeps the agents' own
# flags (e.g. `pi -c`) away from srt's option parser.
# Plain `claude` / `pi` (host binaries) remain untouched and unsandboxed.
sclaude() { srt -- claude "$@"; }
spi() { srt -- pi "$@"; }

count() {
    if [ "$1" == "-h" ]; then
        echo "Usage: count <<directory>>"
    else
        find $1 -maxdepth 1 -type f -not -path '*/.*' | wc -l
    fi
}



eval "$(starship init zsh)"

# Zoxide (jump with z)
eval "$(zoxide init zsh)"

# Obsidian note search — $vault must be exported in ~/.zsh_secrets
sn() {
    note=$(cd "$vault" && find . -name "*.md" 2>/dev/null | sed 's|^\./||' | fzf --prompt="Note: ")
    [ -z "$note" ] && return
    hx "$vault/$note"
}

setopt GLOB_DOTS

if [[ -o interactive && -t 0 && -t 1 && -r "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# herdr-automatic-rename: live per-command tab names (no-op outside a herdr pane)
for _f in ${HOME}/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
  source $_f; break
done

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Machine-local interactive layer (HPC aliases, etc). Absent on the laptop.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
