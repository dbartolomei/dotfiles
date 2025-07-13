#!/bin/bash

# Development Environment Setup Script
# Install and configure development tools, shell, and authentication

echo "🛠️  Starting development environment setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only."
    exit 1
fi

###############################################################################
# XCODE COMMAND LINE TOOLS
###############################################################################

echo "🔧 Installing Xcode Command Line Tools..."

# Check if Xcode command line tools are installed
if ! xcode-select -p &> /dev/null; then
    print_status "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    # Wait for installation to complete
    print_warning "Please complete the Xcode Command Line Tools installation in the popup window."
    print_warning "Press Enter when installation is complete..."
    read -r
else
    print_status "Xcode Command Line Tools already installed!"
fi

###############################################################################
# HOMEBREW INSTALLATION
###############################################################################

echo "🍺 Installing Homebrew..."

if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session (Apple Silicon)
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_status "Homebrew already installed, updating..."
    brew update
fi

###############################################################################
# INSTALL APPS & TOOLS FROM BREWFILE
###############################################################################

echo "📦 Installing applications from Brewfile..."

# Check if Brewfile exists in the current directory or dotfiles directory
if [ -f "Brewfile" ]; then
    print_status "Found Brewfile in current directory"
    BREWFILE_PATH="Brewfile"
elif [ -f "$HOME/Developer/dotfiles/Brewfile" ]; then
    print_status "Found Brewfile in ~/Developer/dotfiles"
    BREWFILE_PATH="$HOME/Developer/dotfiles/Brewfile"
else
    print_error "No Brewfile found! Please ensure Brewfile exists in the current directory or ~/Developer/dotfiles/"
    exit 1
fi

# Install everything from Brewfile
print_status "Running brew bundle to install all packages..."
brew bundle --file="$BREWFILE_PATH"

print_status "All applications and tools installed from Brewfile!"

# Configure iTerm2 to use Nerd Font
if [ -d "/Applications/iTerm.app" ]; then
    print_status "Configuring iTerm2 to use MesloLGS NF font..."
    # Set the font in iTerm2 preferences
    /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Normal Font' 'MesloLGS-NF-Regular 12'" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Non Ascii Font' 'MesloLGS-NF-Regular 12'" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true
fi

###############################################################################
# OH MY ZSH INSTALLATION & CONFIGURATION
###############################################################################

echo "🐚 Setting up Oh My Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_status "Oh My Zsh already installed!"
fi

# Install useful zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_status "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_status "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    print_status "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
fi

# Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    print_status "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Create/update .zshrc
print_status "Configuring .zshrc..."
cat > ~/.zshrc << 'EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    brew
    macos
    node
    npm
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='code'

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Modern replacements
alias cat='bat'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

###############################################################################
# SSH KEY GENERATION
###############################################################################

echo "🔑 Setting up SSH keys..."

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_KEY_PATH" ]; then
    # Keep prompting until we get an email
    while true; do
        read -p "Enter your email for SSH key (required): " email
        if [ -n "$email" ]; then
            break
        fi
        print_warning "Email is required for SSH key generation. Please try again."
    done
    
    print_status "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N ""
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_PATH"
    
    # Add to keychain
    ssh-add --apple-use-keychain "$SSH_KEY_PATH"
    
    # Create SSH config
    cat > ~/.ssh/config << EOF
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    
    print_status "SSH key generated!"
    print_warning "Public key (copy this to GitHub):"
    echo ""
    cat "$SSH_KEY_PATH.pub"
    echo ""
    print_warning "The public key has been copied to clipboard!"
    print_warning "Add it to GitHub: https://github.com/settings/ssh/new"
    pbcopy < "$SSH_KEY_PATH.pub"
else
    print_status "SSH key already exists!"
fi

###############################################################################
# PYTHON ENVIRONMENT SETUP
###############################################################################

echo "🐍 Setting up Python environment with pyenv..."

# Reload shell to get pyenv in PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install latest stable Python version
print_status "Installing Python versions..."
PYTHON_LATEST=$(pyenv install --list | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | grep -v "[a-z]" | tail -1 | tr -d ' ')

if [ -n "$PYTHON_LATEST" ]; then
    print_status "Installing Python $PYTHON_LATEST as global default..."
    pyenv install "$PYTHON_LATEST" --skip-existing
    pyenv global "$PYTHON_LATEST"
    print_status "Set Python $PYTHON_LATEST as global default"
fi

# Install essential Python packages globally
print_status "Installing essential Python packages..."
pip install --upgrade pip
pip install virtualenv

# Setup pipx PATH (pipx is installed via Homebrew)
pipx ensurepath

# Source the updated PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Install useful Python tools globally via pipx
print_status "Installing Python development tools via pipx..."
pipx install ruff
pipx install poetry

# Add useful shell aliases
print_status "Adding shell aliases..."
cat >> ~/.zshrc << 'EOF'

# Python virtual environment helpers
alias mkenv='python -m venv'
alias activate='source ./venv/bin/activate'
alias deactivate='deactivate'

# Pyenv shortcuts
alias py='python'
alias py3='python3'
alias pip='pip'
alias piplist='pip list'
alias pipfreeze='pip freeze'

# Docker/Orbstack aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
EOF

###############################################################################
# GIT CONFIGURATION
###############################################################################

echo "⚙️  Configuring Git..."

# Check if git is already configured
if [ -z "$(git config --global user.name)" ]; then
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    
    if [ -n "$git_username" ] && [ -n "$git_email" ]; then
        git config --global user.name "$git_username"
        git config --global user.email "$git_email"
        print_status "Git configured with user: $git_username <$git_email>"
    fi
else
    print_status "Git already configured for: $(git config --global user.name) <$(git config --global user.email)>"
fi

# Set useful git defaults
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global core.excludesfile "$HOME/.gitignore_global"
git config --global pull.rebase false
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global merge.conflictstyle diff3
git config --global color.ui auto

# Set useful git aliases
git config --global alias.s 'status -sb'
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.cob 'checkout -b'
git config --global alias.c commit
git config --global alias.cm 'commit -m'
git config --global alias.ca 'commit -a'
git config --global alias.cam 'commit -am'
git config --global alias.amend 'commit --amend'
git config --global alias.b 'branch -vv'
git config --global alias.d diff
git config --global alias.dc 'diff --cached'
git config --global alias.l 'log --oneline --graph --decorate'
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.pl pull
git config --global alias.ps push
git config --global alias.psu 'push -u origin HEAD'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.undo 'reset --soft HEAD~1'

# Create global gitignore
print_status "Creating global gitignore..."
cat > ~/.gitignore_global << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.Spotlight-V100
.Trashes

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
*~
.directory

# IDEs
.idea/
.vscode/
*.swp
*.swo
*~
.project
.settings/

# Python
__pycache__/
*.py[cod]
*$py.class
.Python
venv/
ENV/
.env

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# General
*.log
.env.local
.env.*.local
EOF

# Note: Brewfile should already exist in the dotfiles directory
# The script uses brew bundle to install everything from the Brewfile

###############################################################################
# NODE VERSION MANAGER (NVM)
###############################################################################

echo "🟢 Installing Node Version Manager (nvm)..."

if [ ! -d "$HOME/.nvm" ]; then
    print_status "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Add nvm to current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    
    # Install latest LTS Node
    print_status "Installing latest LTS Node.js..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
    
    print_status "Node.js $(node --version) installed"
else
    print_status "nvm already installed"
fi

###############################################################################
# CLAUDE CODE INSTALLATION
###############################################################################

echo "🤖 Installing Claude Code..."

# Ensure nvm is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Install Claude Code via npm
if command -v npm &> /dev/null; then
    print_status "Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code
    
    if command -v claude-code &> /dev/null; then
        print_status "Claude Code installed successfully!"
        print_warning "Remember to authenticate: claude-code auth"
    else
        print_warning "Claude Code installation may have failed. Try running: npm install -g @anthropic-ai/claude-code"
    fi
else
    print_error "npm not found! Please ensure Node.js is installed from Brewfile first."
fi

###############################################################################
# FINISHING UP
###############################################################################

print_status "Development environment setup complete!"
echo ""
echo "📋 Summary of what was installed/configured:"
echo "   🍺 Homebrew package manager"
echo "   📦 All tools and apps from Brewfile"
echo "   🐚 Oh My Zsh with plugins and Powerlevel10k theme"
echo "   🐍 Python with pyenv + tools (ruff, poetry)"
echo "   🟢 Node.js with nvm (latest LTS)"
echo "   🔑 SSH key generated (if email provided)"
echo "   ⚙️  Git configuration with global gitignore"
echo "   🐳 Orbstack for Docker containers"
echo "   🤖 Claude Code CLI installed"
echo ""
echo "🔄 Next steps:"
echo "   1. Run 'p10k configure' in a new terminal to set up your prompt"
echo "   2. Review the Brewfile and run 'brew bundle' if needed"
echo "   3. Add your SSH public key to GitHub/GitLab/etc."
echo "   4. Authenticate Claude Code: claude-code auth"
echo ""
echo "🐍 Python environment commands:"
echo "   'pyenv versions'        - List installed Python versions"
echo "   'pyenv install 3.12.0'  - Install a specific Python version"
echo "   'pyenv global 3.12.0'   - Set global Python version"
echo "   'pyenv local 3.11.5'    - Set local Python version for project"
echo "   'mkenv'                 - Create virtual environment in current dir"
echo "   'activate'              - Activate venv in current dir"
echo ""
echo "🚀 Happy coding!"