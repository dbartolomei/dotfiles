#!/usr/bin/env bash
set -euo pipefail

echo "🍎 Starting macOS system configuration..."

# macOS guard
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is intended for macOS."
  exit 1
fi

# Ask for administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
keep_sudo_alive() { while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null & }
keep_sudo_alive
trap 'jobs -p | xargs -r kill 2>/dev/null || true' EXIT

# Helpers: allow best-effort writes so unknown keys don’t abort
dwrite() { defaults write "$@" || true; }
sdwrite() { sudo defaults write "$@" || true; }

###############################################################################
# DOCK SETTINGS
###############################################################################
echo "📱 Configuring Dock..."

# Remove all apps and folders from Dock
dwrite com.apple.dock persistent-apps -array
dwrite com.apple.dock persistent-others -array

# Add Launchpad to Dock
dwrite com.apple.dock persistent-apps -array-add \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Launchpad.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# Keep Downloads as the only folder in Dock (Others section)
dwrite com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${HOME}/Downloads</string><key>_CFURLStringType</key><integer>0</integer></dict><key>arrangement</key><integer>2</integer><key>displayas</key><integer>1</integer><key>showas</key><integer>1</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"

# Preferences
dwrite com.apple.dock mru-spaces -bool false
dwrite com.apple.dock tilesize -int 48
dwrite com.apple.dock show-recents -bool false
dwrite com.apple.dock mouse-over-hilite-stack -bool true
dwrite com.apple.dock autohide-delay -float 0
dwrite com.apple.dock autohide-time-modifier -float 0.5
dwrite com.apple.dock autohide -bool true

###############################################################################
# MISSION CONTROL & SPACES
###############################################################################
echo "🎯 Configuring Mission Control..."

dwrite com.apple.dock expose-animation-duration -float 0.1
dwrite com.apple.dock expose-group-by-app -bool true
dwrite com.apple.WindowManager EnableTiledWindowMargins -bool false
dwrite com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

###############################################################################
# FINDER SETTINGS
###############################################################################
echo "📁 Configuring Finder..."

dwrite com.apple.finder AppleShowAllFiles -bool false
dwrite NSGlobalDomain AppleShowAllExtensions -bool true
dwrite com.apple.finder ShowPathbar -bool true
dwrite com.apple.finder ShowStatusBar -bool true
dwrite com.apple.finder _FXShowPosixPathInTitle -bool true
dwrite com.apple.finder _FXSortFoldersFirst -bool true
dwrite com.apple.finder FXDefaultSearchScope -string "SCcf"
dwrite com.apple.finder FXEnableExtensionChangeWarning -bool false
dwrite com.apple.finder FXPreferredViewStyle -string "Nlsv"
dwrite com.apple.finder WarnOnEmptyTrash -bool false

chflags nohidden "${HOME}/Library" || true
sudo chflags nohidden /Volumes || true

###############################################################################
# TEXT INPUT & KEYBOARD SETTINGS
###############################################################################
echo "⌨️  Configuring Keyboard & Text Input..."

dwrite NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
dwrite NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
dwrite NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
dwrite NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
dwrite NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
dwrite NSGlobalDomain AppleKeyboardUIMode -int 3
dwrite NSGlobalDomain KeyRepeat -int 2
dwrite NSGlobalDomain InitialKeyRepeat -int 15
dwrite NSGlobalDomain ApplePressAndHoldEnabled -bool false

###############################################################################
# SCREEN & UI SETTINGS
###############################################################################
echo "🖥️  Configuring Screen & UI..."

dwrite com.apple.screensaver askForPassword -int 1
dwrite com.apple.screensaver askForPasswordDelay -int 0

dwrite com.apple.screencapture location -string "${HOME}/Desktop"
dwrite com.apple.screencapture type -string "png"
dwrite com.apple.screencapture disable-shadow -bool true

# No-op on Big Sur+ but harmless
dwrite NSGlobalDomain AppleFontSmoothing -int 1
dwrite NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

###############################################################################
# DISPLAY SETTINGS
###############################################################################
echo "🌟 Display settings require manual confirmation in System Settings:"
echo "   - Uncheck 'Automatically adjust brightness'"
echo "   - Uncheck 'True Tone'"
echo "Also check Battery settings:"
echo "   - Uncheck 'Slightly dim the display on battery'"

###############################################################################
# POWER MANAGEMENT SETTINGS
###############################################################################
echo "🔋 Configuring Power Management..."

# Battery
sudo pmset -b sleep 0
sudo pmset -b displaysleep 30
sudo pmset -b lessbright 0
sudo pmset -b powernap 0

# AC power (confirm that you want no sleep/no display sleep on AC)
sudo pmset -c sleep 0
sudo pmset -c displaysleep 0

# Standby delay (set both low/high where supported)
sudo pmset -a standbydelaylow 86400 || true
sudo pmset -a standbydelayhigh 86400 || true
sudo pmset -a standbydelay 86400 || true

# App termination / App Nap
dwrite NSGlobalDomain NSDisableAutomaticTermination -bool true
dwrite NSGlobalDomain NSAppSleepDisabled -bool true

###############################################################################
# ACTIVITY MONITOR
###############################################################################
echo "📊 Configuring Activity Monitor..."

dwrite com.apple.ActivityMonitor OpenMainWindow -bool true
dwrite com.apple.ActivityMonitor IconType -int 5
dwrite com.apple.ActivityMonitor ShowCategory -int 0
dwrite com.apple.ActivityMonitor SortColumn -string "CPUUsage"
dwrite com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# DEVELOPER EXPERIENCE IMPROVEMENTS
###############################################################################
echo "💻 Configuring Developer Experience..."

# Reduce Spotlight indexing in noisy dirs
touch "${HOME}/.Trash/.metadata_never_index"
touch "${HOME}/Downloads/.metadata_never_index"

# Bluetooth audio quality
dwrite com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Quick Look text selection
dwrite com.apple.finder QLEnableTextSelection -bool true

# Expand common panels
dwrite NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
dwrite NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
dwrite NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
dwrite NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Keep macOS security quarantine enabled for downloaded apps (security best practice)
# Note: LSQuarantine disabled in previous versions - now keeping security enabled

# Disable automatic emoji substitution
dwrite com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Window resize speed
dwrite NSGlobalDomain NSWindowResizeTime -float 0.001

# Resume
dwrite NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Battery percentage (current host scope)
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true || true

# Menu bar clock
dwrite com.apple.menuextra.clock ShowSeconds -bool true
dwrite com.apple.menuextra.clock ShowDayOfWeek -bool true
dwrite com.apple.menuextra.clock ShowAMPM -bool true
dwrite com.apple.menuextra.clock ShowDate -bool false
dwrite com.apple.menuextra.clock IsAnalog -bool false

# Control Center item visibility
dwrite com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true
dwrite com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
dwrite com.apple.controlcenter "NSStatusItem Visible AirDrop" -bool false
dwrite com.apple.controlcenter "NSStatusItem Visible DoNotDisturb" -int 1
dwrite com.apple.controlcenter "NSStatusItem Visible ScreenMirroring" -int 1
dwrite com.apple.controlcenter "NSStatusItem Visible Display" -bool true
dwrite com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
dwrite com.apple.controlcenter "NSStatusItem Visible NowPlaying" -int 1

# Spring loading and .DS_Store behavior
dwrite NSGlobalDomain com.apple.springing.enabled -bool true
dwrite NSGlobalDomain com.apple.springing.delay -float 0
dwrite com.apple.desktopservices DSDontWriteNetworkStores -bool true
dwrite com.apple.desktopservices DSDontWriteUSBStores -bool true

# AirDrop over Ethernet
dwrite com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Archive Utility defaults
dwrite com.apple.archiveutility ShowExpandedDialogs -bool true

# WebKit developer extras
dwrite NSGlobalDomain WebKitDeveloperExtras -bool true

# TextEdit defaults
dwrite com.apple.TextEdit RichText -int 0
dwrite com.apple.TextEdit PlainTextEncoding -int 4
dwrite com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Software updates
dwrite com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
dwrite com.apple.SoftwareUpdate ScheduleFrequency -int 1
dwrite com.apple.SoftwareUpdate AutomaticDownload -int 1
dwrite com.apple.commerce AutoUpdate -bool true

###############################################################################
# FINISHING UP
###############################################################################
echo "🔄 Applying changes..."

# Restart affected services (ignore failures)
killall "Activity Monitor" "ControlCenter" "Dock" "Finder" "SystemUIServer" 2>/dev/null || true

echo "✅ macOS system configuration complete!"
echo "📝 Changes applied:"
echo "   • Dock cleaned and tuned (autohide, size, no recents)"
echo "   • Finder: hidden files, path/status bar, list view, safe prompts off"
echo "   • Keyboard: fast repeat, full keyboard access, no smart substitutions"
echo "   • Screenshots to Desktop (PNG), no shadow"
echo "   • Activity Monitor defaults improved"
echo "🔋 Power:"
echo "   • No sleep on battery; display 30m on battery"
echo "   • No sleep on AC; display never sleeps on AC (adjust if undesired)"
echo "💻 Developer experience: Quick Look text, expanded panels, .DS_Store off on network/USB"
echo "🔔 Restart Terminal manually to see all changes take effect"