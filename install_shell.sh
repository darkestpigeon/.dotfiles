#!/bin/bash

START_PATH=$(pwd)


install_dependencies () {
   sudo apt-get update && sudo apt-get install -y git gettext cmake unzip curl
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
   echo "Copied dotfiles."
}


install_dependencies
install_tmux
install_zsh
copy_dotfiles
