[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

#  Performance: Skip slow security checks
export ZSH_DISABLE_COMPFIX="true"

# Performance: Smarter Path Management (Avoid duplicates)
typeset -U path  # Keep path unique
path=(
    ~/.local/bin
    ~/.config/helix
    ~/.juliaup/bin
    ~/.opencode/bin
    $path
)


# Oh My Zsh Setup
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode disabled
ZSH_THEME="" # Using Starship instead
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

autoload -Uz compinit

if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif [ -d /usr/share/doc/fzf/examples ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


export GEMINI_SANDBOX=true
export claudemd=~/.claude/CLAUDE.md
export EDITOR=hx
alias py='python -m pdb -c c'
alias p='bat --style=plain --paging=never'

# fzf with ripgrep and fd for better performance
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

zstyle ':completion:*' menu select

count() {
    if [ "$1" == "-h" ]; then
        echo "Usage: count <<directory>>"
    else
        find $1 -maxdepth 1 -type f -not -path '*/.*' | wc -l
    fi
}

# AI assistant function
ai() {
    opencode run "$*"
}

eval "$(starship init zsh)"

# Zoxide (jump with z)
eval "$(zoxide init zsh)"

# SSH: auto-attach to tmux on remote hosts
ssh() {
    if [[ $# -eq 1 ]]; then
        command ssh -t "$1" -- 'tmux attach 2>/dev/null || tmux new-session 2>/dev/null || $SHELL'
    else
        command ssh "$@"
    fi
}

# Obsidian note search — $vault must be exported in ~/.zsh_secrets
sn() {
    note=$(cd "$vault" && find . -name "*.md" 2>/dev/null | sed 's|^\./||' | fzf --prompt="Note: ")
    [ -z "$note" ] && return
    hx "$vault/$note"
}

setopt GLOB_DOTS
