#!/bin/bash

echo "Starting dotfiles setup..."

# Function to create a symbolic link
create_symlink() {
    local src=$1
    local dst=$2

    echo "Creating symlink for $(basename "$src")..."
    
    # Create symlink and handle existing files
    if [ -e "$dst" ]; then
        if [ -L "$dst" ]; then
            echo "Removing existing symbolic link: $dst"
            rm "$dst"
        else
            echo "Backing up existing file: $dst"
            mv "$dst" "${dst}.backup"
        fi
    fi
    ln -s "$src" "$dst"
    echo "Symlink created for $(basename "$src")."
}

# Directory containing dotfiles
DOTFILES_DIR=~/dotfiles

# Create symlinks for configuration directories/files
echo "Linking configuration files..."

# Yabai
create_symlink "${DOTFILES_DIR}/yabai" ~/.config/yabai

# SKHD
create_symlink "${DOTFILES_DIR}/skhd" ~/.config/skhd

# Neovim
# create_symlink "${DOTFILES_DIR}/neovim/init.vim" ~/.config/nvim/init.vim

# Kitty
create_symlink "${DOTFILES_DIR}/kitty" ~/.config/kitty

# Tmux (optional)
# create_symlink "${DOTFILES_DIR}/tmux/.tmux.conf" ~/.tmux.conf

# ZSH
create_symlink "${DOTFILES_DIR}/zsh/.zshrc" ~/.zshrc

# Powerlevel10k for ZSH
create_symlink "${DOTFILES_DIR}/powerlevel10k/.p10k.zsh" ~/.p10k.zsh

# Bash (optional)
# create_symlink "${DOTFILES_DIR}/bash/.bashrc" ~/.bashrc

# Check and install oh-my-zsh
echo "Checking oh-my-zsh installation..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "oh-my-zsh is already installed."
fi

# Check and install Homebrew
echo "Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install zsh-autosuggestions via Homebrew
echo "Checking zsh-autosuggestions installation..."
if ! brew list zsh-autosuggestions &> /dev/null; then
    echo "Installing zsh-autosuggestions via Homebrew..."
    brew install zsh-autosuggestions
else
    echo "zsh-autosuggestions is already installed."
fi

# Check for .zshrc_local
echo "Checking for .zshrc_local..."
if [ ! -f ~/.zshrc_local ]; then
    echo "Creating template for .zshrc_local for machine-specific configurations."
    touch ~/.zshrc_local
    echo "# Add your machine-specific aliases and settings here" >> ~/.zshrc_local
else
    echo ".zshrc_local already exists."
fi

echo "Dotfiles setup completed successfully."

