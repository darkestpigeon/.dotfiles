#!/bin/bash

START_PATH=$(pwd)


install_dependencies () {
   sudo apt-get update && sudo apt-get install -y git ninja-build gettext cmake unzip curl \
   build-essential libssl-dev zlib1g-dev \
   libbz2-dev libreadline-dev libsqlite3-dev \
   libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
   ripgrep
}

install_tmux () {
   if ! which tmux > /dev/null; then
      echo "tmux is not installed. Installing..."
      sudo apt-get update
      sudo apt-get install tmux -y
   else
      echo "tmux is already installed."
   fi
}

install_pyenv () {
   if [ ! -d ~/.pyenv ]; then
      echo "pyenv is not installed. Installing..."
      git clone https://github.com/pyenv/pyenv.git ~/.pyenv
   else
      echo "pyenv is already installed."
   fi
   export PYENV_ROOT="$HOME/.pyenv"
   command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
   eval "$(pyenv init -)"
}

install_virtualenv () {
   if [ ! -d ~/.pyenv/plugins/pyenv-virtualenv ]; then
      echo "pyenv-virtualenv is not installed. Installing..."
      git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
   else
      echo "pyenv-virtualenv is already installed."
   fi
}

install_nvim () {
   if ! which nvim > /dev/null; then
      echo "nvim is not installed. Installing..."
      git clone https://github.com/neovim/neovim.git ~/neovim
      cd ~/neovim
      git checkout stable
      make CMAKE_BUILD_TYPE=Release
      sudo make install
   else
      echo "nvim is already installed."
   fi
}

install_zsh () {
   if ! which zsh > /dev/null; then
      echo "zsh is not installed. Installing..."
      sudo apt-get update && sudo apt-get install -y zsh
      git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
   else
      echo "zsh is already installed."
   fi	
   echo "Setting zsh as the default shell."
   chsh -s $(which zsh)
}

copy_dotfiles () {
   cd ${START_PATH}
   cp zsh/.zshrc ~/.zshrc
   cp tmux/.tmux.conf ~/.tmux.conf
   mkdir --parents ~/.config/nvim; cp nvim/* ~/.config/nvim/
   echo "Copied dotfiles."
}

install_npm () {
   if ! which npm > /dev/null; then
      echo "npm is not installed. Installing..."
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
      NODE_MAJOR=20
      echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
      sudo apt-get update
      sudo apt-get install nodejs -y
   else
      echo "npm is already installed."
   fi
}



install_dependencies
install_tmux
install_pyenv && install_virtualenv
install_nvim
install_zsh
copy_dotfiles
install_npm
