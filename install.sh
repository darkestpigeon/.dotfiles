#!/bin/bash
# Improved workstation setup script with interactive prompts and uninstall option.

START_PATH=$(pwd)

# Helper: check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Helper: prompt for yes/no, defaulting to yes unless specified
prompt_yes_no() {
    local prompt_message="$1"
    local default_answer="${2:-Y}"
    local answer
    read -p "$prompt_message [$default_answer/n]: " answer
    answer=${answer:-$default_answer}
    case "$answer" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

# Default mode is installation; pass "uninstall" as first argument to remove components
MODE="install"
if [[ "$1" == "uninstall" ]]; then
    MODE="uninstall"
fi

# Arrays to store the selected components for summary
declare -a install_list
declare -a uninstall_list

# Install system dependencies (common for both modes)
install_dependencies() {
    if [ "$MODE" == "install" ]; then
        echo "Installing system dependencies..."
        sudo apt-get update && sudo apt-get install -y \
            git ninja-build gettext cmake unzip curl build-essential \
            libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
            libffi-dev liblzma-dev ripgrep ca-certificates gnupg xclip
    fi
}

# --- tmux ---
install_tmux() {
    if ! command_exists tmux; then
        echo "Installing tmux..."
        sudo apt-get install tmux -y
    else
        echo "tmux is already installed."
    fi
}

uninstall_tmux() {
    if command_exists tmux; then
        echo "Uninstalling tmux..."
        sudo apt-get remove --purge tmux -y
    else
        echo "tmux is not installed."
    fi
}

# --- pyenv and pyenv-virtualenv ---
install_pyenv() {
    if [ ! -d "$HOME/.pyenv" ]; then
        echo "Installing pyenv..."
        git clone https://github.com/pyenv/pyenv.git "$HOME/.pyenv"
    else
        echo "pyenv is already installed."
    fi
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

uninstall_pyenv() {
    if [ -d "$HOME/.pyenv" ]; then
        echo "Removing pyenv..."
        rm -rf "$HOME/.pyenv"
    else
        echo "pyenv is not installed."
    fi
}

install_virtualenv() {
    if [ ! -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
        echo "Installing pyenv-virtualenv..."
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
    else
        echo "pyenv-virtualenv is already installed."
    fi
}

uninstall_virtualenv() {
    if [ -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
        echo "Removing pyenv-virtualenv..."
        rm -rf "$(pyenv root)/plugins/pyenv-virtualenv"
    else
        echo "pyenv-virtualenv is not installed."
    fi
}

# --- Neovim ---
install_nvim() {
    if ! command_exists nvim; then
        echo "Installing Neovim..."
        git clone https://github.com/neovim/neovim.git ~/neovim
        cd ~/neovim
        git checkout stable
        make CMAKE_BUILD_TYPE=Release
        sudo make install
        cd "$START_PATH"
    else
        echo "Neovim is already installed."
    fi
}

uninstall_nvim() {
    if command_exists nvim; then
        echo "Removing Neovim installation..."
        sudo apt-get remove --purge neovim -y || echo "Manual removal may be required if installed from source."
    else
        echo "Neovim is not installed."
    fi
}

# --- zsh and oh-my-zsh ---
install_zsh() {
    if ! command_exists zsh; then
        echo "Installing zsh..."
        sudo apt-get install -y zsh
    else
        echo "zsh is already installed."
    fi
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    else
        echo "oh-my-zsh is already installed."
    fi
    echo "Setting zsh as the default shell."
    chsh -s "$(which zsh)"
}

uninstall_zsh() {
    # Removing zsh (or oh‑my‑zsh) may require manual steps since zsh might be set as default.
    echo "To uninstall zsh/oh-my-zsh, please change your default shell first and remove ~/.oh-my-zsh manually."
}

# --- Dotfiles ---
copy_dotfiles() {
    echo "Copying configuration files..."
    cp "$START_PATH/zsh/.zshrc" "$HOME/.zshrc"
    cp "$START_PATH/tmux/.tmux.conf" "$HOME/.tmux.conf"
    mkdir -p "$HOME/.config/nvim" && cp "$START_PATH/nvim/"* "$HOME/.config/nvim/"
}

remove_dotfiles() {
    echo "Removing configuration files..."
    rm -f "$HOME/.zshrc" "$HOME/.tmux.conf"
    rm -rf "$HOME/.config/nvim"
}

# --- Node.js ---
install_node() {
    if ! command_exists node; then
        echo "Installing Node.js..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
        NODE_MAJOR=20
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
        sudo apt-get update
        sudo apt-get install nodejs -y
    else
        echo "Node.js is already installed."
    fi
}

uninstall_node() {
    if command_exists node; then
        echo "Uninstalling Node.js..."
        sudo apt-get remove --purge nodejs -y
    else
        echo "Node.js is not installed."
    fi
}

# --- Main interactive loop ---
echo "Select components to ${MODE}:"
if [ "$MODE" == "install" ]; then
    prompt_yes_no "Install tmux?"          && install_list+=("tmux")
    prompt_yes_no "Install pyenv?"          && install_list+=("pyenv")
    prompt_yes_no "Install pyenv-virtualenv?" && install_list+=("virtualenv")
    prompt_yes_no "Install Neovim?"         && install_list+=("nvim")
    prompt_yes_no "Install zsh and oh-my-zsh?" && install_list+=("zsh")
    prompt_yes_no "Copy dotfiles?"          && install_list+=("dotfiles")
    prompt_yes_no "Install Node.js?"        && install_list+=("node")
else
    prompt_yes_no "Uninstall tmux?"          && uninstall_list+=("tmux")
    prompt_yes_no "Uninstall pyenv?"          && uninstall_list+=("pyenv")
    prompt_yes_no "Uninstall pyenv-virtualenv?" && uninstall_list+=("virtualenv")
    prompt_yes_no "Uninstall Neovim?"         && uninstall_list+=("nvim")
    prompt_yes_no "Uninstall oh-my-zsh and remove zsh config?" && uninstall_list+=("zsh")
    prompt_yes_no "Remove dotfiles?"          && uninstall_list+=("dotfiles")
    prompt_yes_no "Uninstall Node.js?"        && uninstall_list+=("node")
fi

# Display summary and confirm
if [ "$MODE" == "install" ]; then
    echo "Components to be installed: ${install_list[*]}"
else
    echo "Components to be uninstalled: ${uninstall_list[*]}"
fi

if ! prompt_yes_no "Proceed with ${MODE}?" "Y"; then
    echo "Operation cancelled."
    exit 0
fi

# Install dependencies (if installing)
install_dependencies

# Process the selected components
if [ "$MODE" == "install" ]; then
    for comp in "${install_list[@]}"; do
        case "$comp" in
            tmux)        install_tmux ;;
            pyenv)       install_pyenv ;;
            virtualenv)  install_virtualenv ;;
            nvim)        install_nvim ;;
            zsh)         install_zsh ;;
            dotfiles)    copy_dotfiles ;;
            node)        install_node ;;
            *)           echo "Unknown component: $comp" ;;
        esac
    done
else
    for comp in "${uninstall_list[@]}"; do
        case "$comp" in
            tmux)        uninstall_tmux ;;
            pyenv)       uninstall_pyenv ;;
            virtualenv)  uninstall_virtualenv ;;
            nvim)        uninstall_nvim ;;
            zsh)         uninstall_zsh ;;
            dotfiles)    remove_dotfiles ;;
            node)        uninstall_node ;;
            *)           echo "Unknown component: $comp" ;;
        esac
    done
fi

echo "Operation ${MODE} completed."
