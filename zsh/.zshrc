# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme configuration
ZSH_THEME="robbyrussell"
# To use a random theme from a list, uncomment the next line and define ZSH_THEME_RANDOM_CANDIDATES
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment for case-sensitive completion or hyphen-insensitive completion if desired
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"

# Plugin configuration (add any plugins you use)
plugins=(git)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Custom key bindings and aliases
set -o vi
alias vim="nvim"
export EDITOR=vi
bindkey -M vicmd v edit-command-line

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# CUDA paths (if applicable)
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Nim paths (if applicable)
export PATH=$HOME/.nimble/bin:$PATH
