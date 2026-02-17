[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

# 1. Performance: Skip slow security checks
export ZSH_DISABLE_COMPFIX="true"

# 2. Performance: Smarter Path Management (Avoid duplicates)
typeset -U path  # Keep path unique
path=(
    ~/.local/bin
    ~/.config/helix
    ~/.juliaup/bin
    ~/.antigravity/antigravity/bin
    ~/.opencode/bin
    $path
)

# 3. Completion Cache Logic (DO THIS ONCE)
autoload -Uz compinit
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 4. Oh My Zsh Setup
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode disabled
ZSH_THEME="" # Using Starship instead
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# 5. External Tool Loading
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


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

# 7. Prompt (Must be at the very bottom)
eval "$(starship init zsh)"


# AI assistant function
aido() {
    copilot -p "$*" --allow-all-tools
}
ai() {
    copilot -p "$*"
}
