# dotfiles

My fresh macOS developer setup.

## Quick Start

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dbartolomei/dotfiles/main/bootstrap.sh)"
```

## What's Included

### Development Environment
- **Shell**: Zsh + Oh My Zsh + Powerlevel10k theme
- **Terminal**: Ghostty
- **Editors**: Cursor, Zed, Neovim
- **Python**: pyenv + latest Python + ruff/poetry via pipx
- **Node**: nvm + latest LTS Node.js
- **Containers**: OrbStack (Docker replacement)

### AI CLI Tools
Installed via npm for latest versions:
- **Claude Code** - `claude` (Anthropic)
- **Codex** - `codex` (OpenAI)
- **Gemini** - `gemini` (Google)

### CLI Tools
Modern replacements and essentials:
- `zoxide` - smarter cd
- `eza` - modern ls
- `bat` - cat with syntax highlighting
- `ripgrep` - fast grep
- `fd` - fast find
- `fzf` - fuzzy finder
- `lazygit` - git TUI
- `git-delta` - better diffs

### Apps
Browsers, communication, productivity - see [Brewfile](Brewfile) for full list.

## Scripts

| File | Description |
|------|-------------|
| `bootstrap.sh` | Downloads and runs everything |
| `setup-system.sh` | macOS system settings (Dock, Finder, keyboard) |
| `setup-dev.sh` | Development environment setup |
| `Brewfile` | Homebrew packages and apps |
| `Brewfile.lock.json` | Frozen package versions |

## Reset Homebrew

To completely reset and reinstall:

```bash
# Uninstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove leftovers
sudo rm -rf /opt/homebrew
rm -rf ~/Library/Caches/Homebrew

# Reinstall via bootstrap
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dbartolomei/dotfiles/main/bootstrap.sh)"
```

## Cleanup

Remove packages not in Brewfile:

```bash
brew bundle cleanup --force
brew cleanup --prune=all
brew autoremove
```

## Post-Install

1. Open terminal and run `p10k configure` to set up prompt
2. Add SSH key to GitHub: `cat ~/.ssh/id_ed25519.pub | pbcopy`
3. Authenticate AI tools:
   - `claude` - Claude Code
   - `codex` - OpenAI Codex
   - `gemini auth login` - Gemini
