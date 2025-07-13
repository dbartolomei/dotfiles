#!/bin/bash

# Bootstrap script for fresh Mac setup
# Usage: curl -fsSL https://raw.githubusercontent.com/dbartolomei/dotfiles/main/bootstrap.sh | bash

echo "🚀 Starting fresh Mac setup..."
echo "📦 This will install Xcode tools, Homebrew, development environment, and configure your Mac"
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the setup scripts and Brewfile
echo "📥 Downloading setup scripts..."
curl -fsSL https://raw.githubusercontent.com/dbartolomei/dotfiles/main/setup-dev.sh -o setup-dev.sh
curl -fsSL https://raw.githubusercontent.com/dbartolomei/dotfiles/main/setup-system.sh -o setup-system.sh
curl -fsSL https://raw.githubusercontent.com/dbartolomei/dotfiles/main/Brewfile -o Brewfile

# Make executable
chmod +x setup-dev.sh setup-system.sh

echo ""
echo "🎯 Running system configuration..."
./setup-system.sh

echo ""
echo "🛠️  Running development environment setup..."
bash -i setup-dev.sh

echo ""
echo "✅ Bootstrap complete!"
echo "🔄 Next steps:"
echo "   1. Add your SSH key to GitHub (already copied to clipboard)"
echo "   2. Clone your dotfiles: cd ~/Developer && git clone git@github.com:dbartolomei/dotfiles.git"
echo "   3. Run any additional setup from your dotfiles repo"

# Cleanup
rm -rf "$TEMP_DIR"