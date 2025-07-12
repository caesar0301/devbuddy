#!/bin/bash

# Setup script for dotfiles installation
# This script runs after the devcontainer is created

set -e

echo "🚀 Setting up dotfiles for AI development environment..."

# Switch to vscode user
USER_HOME="/home/vscode"
DOTFILES_DIR="$USER_HOME/.dotfiles"

# Function to run commands as vscode user
run_as_vscode() {
    sudo -u vscode bash -c "$1"
}

# Create basic directories
run_as_vscode "mkdir -p $USER_HOME/.config"
run_as_vscode "mkdir -p $USER_HOME/.local/bin"

# Check if dotfiles repository exists in common locations
DOTFILES_REPO=""
if [ -d "/workspace/.dotfiles" ]; then
    DOTFILES_REPO="/workspace/.dotfiles"
elif [ -d "/workspace/dotfiles" ]; then
    DOTFILES_REPO="/workspace/dotfiles"
fi

# If dotfiles repo found, create symlink and run install script
if [ -n "$DOTFILES_REPO" ]; then
    echo "📦 Found dotfiles repository at: $DOTFILES_REPO"
    run_as_vscode "ln -sf $DOTFILES_REPO $DOTFILES_DIR"
    
    # Look for common install scripts
    if [ -f "$DOTFILES_REPO/install.sh" ]; then
        echo "🔧 Running dotfiles install script..."
        run_as_vscode "cd $DOTFILES_DIR && bash install.sh"
    elif [ -f "$DOTFILES_REPO/setup.sh" ]; then
        echo "🔧 Running dotfiles setup script..."
        run_as_vscode "cd $DOTFILES_DIR && bash setup.sh"
    elif [ -f "$DOTFILES_REPO/Makefile" ]; then
        echo "🔧 Running dotfiles Makefile..."
        run_as_vscode "cd $DOTFILES_DIR && make install"
    else
        echo "⚠️  No install script found, manually symlinking common files..."
        
        # Manually symlink common dotfiles
        for file in .vimrc .zshrc .bashrc .gitconfig .tmux.conf; do
            if [ -f "$DOTFILES_REPO/$file" ]; then
                run_as_vscode "ln -sf $DOTFILES_REPO/$file $USER_HOME/$file"
                echo "   ✅ Linked $file"
            fi
        done
    fi
else
    echo "⚠️  No dotfiles repository found, creating basic configuration..."
    
    # Create basic .zshrc configuration
    run_as_vscode "cat > $USER_HOME/.zshrc << 'EOF'
# AI Development Environment ZSH Configuration
export ZSH=\"$USER_HOME/.oh-my-zsh\"

# ZSH Theme
ZSH_THEME=\"robbyrussell\"

# Plugins
plugins=(git python pip docker kubectl)

source \$ZSH/oh-my-zsh.sh

# Environment variables
export CUDA_HOME=/usr/local/cuda
export PATH=\$CUDA_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH
export PYTHONPATH=/workspace:\$PYTHONPATH

# Aliases
alias python=python3.12
alias pip=python3.12 -m pip
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gpu='nvidia-smi'
alias jlab='jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root'
alias jnb='jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root'

# Custom functions
function mkcd() { mkdir -p "\$1" && cd "\$1"; }
function gpu-test() { python3.12 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA devices: {torch.cuda.device_count()}')"; }

# Welcome message
echo \"🤖 AI Development Environment Ready!\"
echo \"🐍 Python: \$(python --version)\"
echo \"🚀 CUDA: \$CUDA_HOME\"
if command -v nvidia-smi > /dev/null; then
    echo \"🎮 GPU: \$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)\"
fi
EOF"

    # Create basic .gitconfig
    run_as_vscode "cat > $USER_HOME/.gitconfig << 'EOF'
[user]
    name = AI Developer
    email = ai-dev@example.com
[init]
    defaultBranch = main
[core]
    editor = vim
    autocrlf = input
[push]
    default = simple
[pull]
    rebase = false
EOF"

    # Create basic .vimrc
    run_as_vscode "cat > $USER_HOME/.vimrc << 'EOF'
\" AI Development Vim Configuration
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
set ruler
set showcmd
set wildmenu
set background=dark
syntax on
filetype plugin indent on

\" Python-specific settings
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
EOF"
fi

# Install additional Python packages for development
echo "📦 Installing additional Python development packages..."
sudo -u vscode python3.12 -m pip install --user --no-cache-dir \
    ipython \
    rich \
    typer \
    httpx \
    pydantic \
    sqlalchemy \
    alembic \
    redis \
    celery

# Set up Jupyter configuration
echo "🔧 Setting up Jupyter configuration..."
run_as_vscode "mkdir -p $USER_HOME/.jupyter"
run_as_vscode "cat > $USER_HOME/.jupyter/jupyter_lab_config.py << 'EOF'
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.token = ''
c.ServerApp.password = ''
EOF"

# Fix ownership
chown -R vscode:vscode $USER_HOME

echo "✅ Dotfiles setup complete!"
echo "🔄 Please reload your shell or restart the terminal to apply changes."