# dotfiles

My fresh macOS developer setup.

## Quick Start

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dbartolomei/dotfiles/main/bootstrap.sh)"
```

## What it does

- **System**: Optimizes macOS settings for development (power, keyboard, Finder)
- **Shell**: Oh My Zsh with Powerlevel10k theme and useful plugins
- **Python**: pyenv + latest Python + ruff/poetry via pipx
- **Node**: nvm + latest LTS Node.js
- **Tools**: Homebrew + essential CLI tools and apps via Brewfile
- **Git**: Global config with aliases and gitignore
- **Auth**: SSH key generation and Claude Code CLI

## Scripts

- `bootstrap.sh` - Downloads and runs everything
- `setup-system.sh` - macOS system settings
- `setup-dev.sh` - Development environment
- `Brewfile` - Homebrew packages and apps
