[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

#  Performance: Skip slow security checks
export ZSH_DISABLE_COMPFIX="true"

# Performance: Smarter Path Management (Avoid duplicates)
typeset -U path  # Keep path unique
path=(
    ~/.local/bin
    ~/.config/helix
    ~/.juliaup/bin
    ~/.antigravity/antigravity/bin
    ~/.opencode/bin
    $path
)

# Completion Cache Logic (DO THIS ONCE)
autoload -Uz compinit
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Oh My Zsh Setup
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode disabled
ZSH_THEME="" # Using Starship instead
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

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
