#!/usr/bin/env bash
set -euo pipefail

# Development Environment Setup Script
# Install and configure development tools, shell, and authentication

echo "🛠️  Starting development environment setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  print_error "This script is designed for macOS only."
  exit 1
fi

###############################################################################
# XCODE COMMAND LINE TOOLS
###############################################################################

echo "🔧 Installing Xcode Command Line Tools..."

if ! xcode-select -p &>/dev/null; then
  print_status "Requesting Xcode Command Line Tools installation..."
  xcode-select --install || true
  print_warning "Waiting for Xcode Command Line Tools to complete. This can take several minutes..."
  # Wait until tools become available
  until xcode-select -p &>/dev/null || pkgutil --pkg-info=com.apple.pkg.CLTools_Executables &>/dev/null; do
    sleep 20
  done
  print_status "Xcode Command Line Tools installed."
else
  print_status "Xcode Command Line Tools already installed!"
fi

###############################################################################
# HOMEBREW INSTALLATION
###############################################################################

echo "🍺 Installing Homebrew..."

if ! command -v brew &>/dev/null; then
  print_status "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for current session and persist for future shells
  if [[ -x /opt/homebrew/bin/brew ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  print_status "Homebrew already installed, updating..."
  brew update
fi

###############################################################################
# INSTALL APPS & TOOLS FROM BREWFILE
###############################################################################

echo "📦 Installing applications from Brewfile..."

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

print_status "Running brew bundle to install all packages..."
brew bundle --file="$BREWFILE_PATH"
print_status "All applications and tools installed from Brewfile!"

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
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  print_status "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
fi

# Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  print_status "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
fi

# Backup existing .zshrc if present (non-destructive)
if [ -f "$HOME/.zshrc" ]; then
  ts="$(date +%Y%m%d%H%M%S)"
  cp "$HOME/.zshrc" "$HOME/.zshrc.backup-$ts"
  print_warning "Backed up existing .zshrc to ~/.zshrc.backup-$ts"
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

# Enable zoxide and direnv if available
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Homebrew (Apple Silicon or Intel)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza -T --icons'
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
  # Check if running interactively
  if [ -t 0 ]; then
    # Keep prompting until we get an email
    while true; do
      echo -n "Enter your email for SSH key (required): "
      read -r email
      if [ -n "${email:-}" ]; then
        break
      fi
      print_warning "Email is required for SSH key generation. Please try again."
    done
  else
    print_error "Script is not running interactively. Please run with:"
    print_error "bash -i setup-dev.sh"
    print_error "Or set EMAIL environment variable:"
    print_error "EMAIL=your@email.com ./setup-dev.sh"

    if [ -n "${EMAIL:-}" ]; then
      email="$EMAIL"
      print_status "Using EMAIL from environment: $email"
    else
      exit 1
    fi
  fi

  print_status "Generating SSH key..."
  ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N ""

  # Start ssh-agent and add key
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY_PATH"

  # Add to keychain
  ssh-add --apple-use-keychain "$SSH_KEY_PATH"

  # Create SSH config (best-effort)
  mkdir -p ~/.ssh
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
  pbcopy < "$SSH_KEY_PATH.pub"
  print_warning "The public key has been copied to clipboard!"
  print_warning "Add it to GitHub: https://github.com/settings/ssh/new"
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

# Install latest stable Python 3.x via pyenv
print_status "Installing Python versions..."
PYTHON_LATEST="$(pyenv install --list | grep -E '^\s*3\.[0-9]+\.[0-9]+$' | grep -v '[a-z]' | tail -1 | tr -d ' ' || true)"

if [ -n "${PYTHON_LATEST:-}" ]; then
  print_status "Installing Python $PYTHON_LATEST as global default..."
  pyenv install "$PYTHON_LATEST" --skip-existing
  pyenv global "$PYTHON_LATEST"
  print_status "Set Python $PYTHON_LATEST as global default"
fi

# Install essential Python packages globally
print_status "Installing essential Python packages..."
python -m pip install --upgrade pip
python -m pip install virtualenv

# Setup pipx PATH (pipx is installed via Homebrew)
if command -v pipx &>/dev/null; then
  pipx ensurepath || true
  # Source the updated PATH for current session
  export PATH="$HOME/.local/bin:$PATH"
  # Install useful Python tools globally via pipx
  print_status "Installing Python development tools via pipx..."
  pipx install ruff || true
  pipx install poetry || true
else
  print_warning "pipx not found. Ensure pipx is installed via Brewfile if you want isolated CLI installs."
fi

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

if [ -z "$(git config --global user.name || true)" ]; then
  read -p "Enter your Git username: " git_username
  read -p "Enter your Git email: " git_email

  if [ -n "${git_username:-}" ] && [ -n "${git_email:-}" ]; then
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

# Use git-delta for rich diffs
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side false

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

###############################################################################
# NODE VERSION MANAGER (NVM)
###############################################################################

echo "🟢 Installing Node Version Manager (nvm)..."

if [ ! -d "$HOME/.nvm" ]; then
  print_status "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

  # Add nvm to current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  # Install latest LTS Node
  print_status "Installing latest LTS Node.js..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'

  print_status "Node.js $(node --version) installed"
else
  print_status "nvm already installed"
  # Ensure nvm is loaded to allow subsequent npm installs
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

###############################################################################
# CLAUDE CODE INSTALLATION
###############################################################################

echo "🤖 Installing Claude Code..."

# Ensure nvm is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Install Claude Code via npm
if command -v npm &>/dev/null; then
  print_status "Installing Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code || true

  if command -v claude &>/dev/null || command -v claude-code &>/dev/null; then
    print_status "Claude Code installed successfully!"
    print_warning "Authenticate by running: claude (or: claude-code auth)"
  else
    print_warning "Claude Code installation may have failed. Try running: npm install -g @anthropic-ai/claude-code"
  fi
else
  print_error "npm not found! Please ensure Node.js is installed from Brewfile or via nvm first."
fi

###############################################################################
# GEMINI CLI INSTALLATION
###############################################################################

echo "🔷 Installing Gemini CLI..."

# Ensure nvm is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if command -v npm &>/dev/null; then
  print_status "Installing Gemini CLI..."
  npm install -g @google/gemini-cli || true

  if command -v gemini &>/dev/null; then
    print_status "Gemini CLI installed successfully!"
    print_warning "Authenticate by running: gemini auth login (or just 'gemini' to start)"
  else
    print_warning "Gemini CLI installation may have failed. Try: npm install -g @google/gemini-cli"
  fi
else
  print_error "npm not found! Please ensure Node.js is installed from Brewfile or via nvm first."
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
echo "   🐍 Python with pyenv + tools (ruff, poetry via pipx)"
echo "   🟢 Node.js with nvm (latest LTS)"
echo "   🔑 SSH key generated (if email provided)"
echo "   ⚙️  Git configuration with global gitignore"
echo "   🐳 Orbstack for Docker containers"
echo "   🤖 Claude Code CLI installed"
echo "   🔷 Gemini CLI installed"
echo ""
echo "🔄 Next steps:"
echo "   1. Open a new terminal or 'source ~/.zshrc' to load shell updates"
echo "   2. Run 'p10k configure' to set up your prompt"
echo "   3. Add your SSH public key to GitHub/GitLab/etc."
echo "   4. Authenticate Claude Code: run 'claude' (or 'claude-code auth')"
echo "   5. Authenticate Gemini CLI: 'gemini auth login'"
echo ""
echo "🐍 Python environment commands:"
echo "   'pyenv versions'        - List installed Python versions"
echo "   'pyenv install 3.12.x'  - Install a specific Python version"
echo "   'pyenv global 3.12.x'   - Set global Python version"
echo "   'pyenv local 3.11.x'    - Set local Python version for project"
echo "   'mkenv'                 - Create virtual environment in current dir"
echo "   'activate'              - Activate venv in current dir"
echo ""
echo "🚀 Happy coding!"