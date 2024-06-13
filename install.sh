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

# Aerospace
create_symlink "${DOTFILES_DIR}/aerospace" ~/.config/aerospace

# Sketchybar
create_symlink "${DOTFILES_DIR}/sketchybar" ~/.config/sketchybar

# Neovim
# create_symlink "${DOTFILES_DIR}/neovim/init.vim" ~/.config/nvim/init.vim

# Kitty
create_symlink "${DOTFILES_DIR}/kitty" ~/.config/kitty

# Tmux
create_symlink "${DOTFILES_DIR}/tmux/tmux.conf" ~/.config/tmux/tmux.conf

# Custom tmux scripts
TMUX_CUSTOM_DIR=~/.config/tmux/plugins/tmux/custom
mkdir -p "$TMUX_CUSTOM_DIR"
for script in "${DOTFILES_DIR}/tmux/custom/"*; do
    create_symlink "$script" "${TMUX_CUSTOM_DIR}/$(basename "$script")"
done

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

# Install alias-tips plugin
echo "Installing alias-tips plugin..."
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins
if [ ! -d "${ZSH_CUSTOM}/alias-tips" ]; then
    git clone https://github.com/djui/alias-tips.git "${ZSH_CUSTOM}/alias-tips"
else
    echo "alias-tips plugin is already installed."
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

echo "Checking for IPython installation..."
if command -v ipython &> /dev/null; then
    echo "IPython is installed, proceeding with setup..."
    
    # IPYTHON_PROFILE="terminal"
    IPYTHON_PROFILE="default"
    echo "Checking for IPython profile '${IPYTHON_PROFILE}'..."
    if ipython profile list | grep -q "${IPYTHON_PROFILE}"; then
        echo "IPython profile '${IPYTHON_PROFILE}' already exists."
    else
        echo "Creating IPython profile '${IPYTHON_PROFILE}'..."
        ipython profile create "${IPYTHON_PROFILE}"
    fi

    # Determine the IPython startup directory for the profile
    IPYTHON_STARTUP_DIR="${HOME}/.ipython/profile_${IPYTHON_PROFILE}/startup"
    # Ensure the directory exists (it should, but just in case)
    mkdir -p "${IPYTHON_STARTUP_DIR}"

    # Symlink all files in the dotfiles/ipython directory
    echo "Linking IPython startup scripts..."
    for src in "${DOTFILES_DIR}/ipython"/*; do
        dst="${IPYTHON_STARTUP_DIR}/$(basename "$src")"
        create_symlink "$src" "$dst"
    done

    echo "IPython setup completed successfully."
else
    echo "IPython is not installed, skipping IPython setup."
fi

# Install bat themes if they do not exist
BAT_THEME_DIR="$(bat --config-dir)/themes"
BAT_THEME_URLS=(
    "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme"
    "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme"
    "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"
    "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
)

echo "Checking bat themes installation..."
mkdir -p "$BAT_THEME_DIR"
for url in "${BAT_THEME_URLS[@]}"; do
    theme_file="$BAT_THEME_DIR/$(basename "$url")"
    if [ ! -f "$theme_file" ]; then
        echo "Downloading $(basename "$url")..."
        wget -P "$BAT_THEME_DIR" "$url"
    else
        echo "$(basename "$url") already installed."
    fi
done

# Rebuild bat's cache
bat cache --build


echo "Copying fabric patterns"

cp -a ./custom-fabric-patterns/* ~/.config/fabric/patterns/

echo "Dotfiles setup completed successfully."
