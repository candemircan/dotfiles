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
export LLAMA_CACHE=~/.cache/huggingface/hub
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

# Shared model lookup for local AI functions
_local_ai_path() {
    local -A models=(
        gpt-oss  "gpt-oss-20b-UD-Q4_K_XL.gguf"
        devstral "Devstral-Small-2-UD-Q4_K_XL.gguf"
    )
    [[ -z "${models[$1]}" ]] && { echo "Unknown model '$1'. Available: ${(k)models}"; return 1 }
    local path=("${LLAMA_CACHE}"/**/"${models[$1]}"(N))
    [[ ${#path} -eq 0 ]] && { echo "Model file not found in $LLAMA_CACHE"; return 1 }
    echo "$path[1]"
}

# Launch llama-server for opencode. Usage: serve_ai [--model MODEL]
serve_ai() {
    local model=devstral
    zparseopts -D -E -- -model:=model_opt && model="${model_opt[-1]:-$model}"
    local path=$(_local_ai_path "$model") || return 1
    llama-server -m "$path" -ngl 99 --flash-attn -c 32768 --port 8080 "$@"
}

# One-shot or interactive local inference (offline).
# Usage: local_ai [--model MODEL] ["question"]
# No question → interactive chat (default: devstral)
# With question → one-shot answer (default: gpt-oss)
local_ai() {
    local model=""
    zparseopts -D -E -- -model:=model_opt
    [[ -n "${model_opt[-1]}" ]] && model="${model_opt[-1]}"
    local prompt="$*"
    [[ -z "$model" ]] && { [[ -z "$prompt" ]] && model=devstral || model=gpt-oss }
    local path=$(_local_ai_path "$model") || return 1
    local flags=(-m "$path" -ngl 99 --flash-attn -c 32768 --no-display-prompt)
    [[ -z "$prompt" ]] && llama-cli "${flags[@]}" -cnv || llama-cli "${flags[@]}" -p "$prompt"
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
