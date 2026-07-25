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
  elif [ -d /usr/share/doc/fzf/examples ]; then
    # Debian/Ubuntu
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
  elif [ -d /usr/share/fzf/shell ]; then
    # Fedora
    source /usr/share/fzf/shell/key-bindings.zsh
    source /usr/share/fzf/shell/completion.zsh
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


# Added by Antigravity CLI installer
export PATH="/Users/candemircan/.local/bin:$PATH"
