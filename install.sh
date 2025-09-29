#!/usr/bin/env bash


# --- dependencies ---
sudo apt-get update && sudo apt-get install -y \
    git ninja-build gettext cmake unzip curl build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev ripgrep ca-certificates gnupg xclip || \
    { echo "failed to install dependencies"; exit 1; }


command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- tmux ---
if ! command_exists tmux; then
    echo "Installing tmux"
    sudo apt-get install -y tmux || { echo "failed to install tmux"; exit 1; }
fi

# --- pyenv ---
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [ ! -d "$PYENV_ROOT" ]; then
    echo "Installing pyenv"
    git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT" || \
        { echo "failed to install pyenv"; exit 1; }
fi

# --- pyenv-virtualenv ---
if [ ! -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
    echo "Installing pyenv-virtualenv"
    git clone https://github.com/pyenv/pyenv-virtualenv.git \
        "$(pyenv root)/plugins/pyenv-virtualenv" || \
        { echo "failed to install pyenv-virtualenv"; exit 1; }
fi

# --- neovim ---
if ! command_exists nvim; then
    echo "Installing neovim"
    (
        git clone https://github.com/neovim/neovim.git "$HOME/neovim" &&
        cd "$HOME/neovim" &&
        git checkout stable &&
        make CMAKE_BUILD_TYPE=Release &&
        sudo make install ||
        { echo "failed to install neovim"; exit 1; }
    )
fi

# --- zsh ---
if ! command_exists zsh; then
    echo "Installing zsh"
    sudo apt-get install -y zsh || { echo "failed to install zsh"; exit 1; }
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh"
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || \
        { echo "failed to install oh-my-zsh"; exit 1; }
fi
if [[ $SHELL != *zsh ]]; then
    echo "Setting zsh as a login shell"
    sudo chsh -s "$(which zsh)" "$(id -un)" || \
        { echo "failed to set zsh as a login shell"; exit 1; }
fi

# --- dotfiles ---
if [ ! -f "$HOME/.zshrc" ]; then
    echo "copying .zshrc"
    cp zsh/.zshrc "$HOME/.zshrc" || exit 1;
fi
if [ ! -f "$HOME/.tmux.conf" ]; then
    echo "copying .tmux.conf"
    cp tmux/.tmux.conf "$HOME/.tmux.conf" || exit 1;
fi
if [ ! -d "$HOME/.config/nvim" ]; then
    echo "copying nvim/"
    mkdir -p "$HOME/.config/nvim" && cp nvim/* "$HOME/.config/nvim/" || exit 1;
fi

# --- nodejs ---
FNM_PATH="$HOME/.local/share/fnm"
export PATH="$FNM_PATH:$PATH"
if [ ! -d "$FNM_PATH" ]; then
    curl -o- https://fnm.vercel.app/install | bash || \
        { echo "failed to install fnm (node version manager)"; exit 1; }
fi
eval "`fnm env`"
if ! command_exists node; then
    fnm install 24 || { echo "failed to install nodejs"; exit 1; }
fi

# --- nim ---
export PATH="$HOME/.nimble/bin:$PATH"
if ! command_exists choosenim || ! command_exists nim; then
    echo "Installing nim (choosenim)"
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y
fi
