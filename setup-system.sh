#!/bin/bash

# macOS System Settings Configuration
# Part 1: Configure macOS system preferences and UI settings

echo "🍎 Starting macOS system configuration..."

# Ask for administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# DOCK SETTINGS
###############################################################################

echo "📱 Configuring Dock..."

# Remove all apps from Dock
defaults write com.apple.dock persistent-apps -array

# Add Launchpad to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Launchpad.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# Remove all folders from Dock
defaults write com.apple.dock persistent-others -array

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 48

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Set the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

###############################################################################
# MISSION CONTROL & SPACES
###############################################################################

echo "🎯 Configuring Mission Control..."

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Group windows by application in Mission Control
defaults write com.apple.dock expose-group-by-app -bool true

# Remove margins between tiled windows (macOS Sequoia)
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Disable "click desktop to show desktop" feature (macOS Sonoma+)
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

###############################################################################
# FINDER SETTINGS
###############################################################################

echo "📁 Configuring Finder..."

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes

###############################################################################
# TEXT INPUT & KEYBOARD SETTINGS
###############################################################################

echo "⌨️  Configuring Keyboard & Text Input..."

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Enable key repeat (important for vim users and holding keys)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

###############################################################################
# SCREEN & UI SETTINGS
###############################################################################

echo "🖥️  Configuring Screen & UI..."

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the Desktop in PNG format
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Show scrollbars when scrolling
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

###############################################################################
# DISPLAY SETTINGS
###############################################################################

echo "🌟 Configuring Display Settings..."

# Note: True Tone and automatic brightness settings require modifying system plists
# that are protected and may require restart. These settings are better configured
# manually in System Settings > Displays for reliability.

echo "⚠️  Please manually configure in System Settings > Displays:"
echo "   - Uncheck 'Automatically adjust brightness'"
echo "   - Uncheck 'True Tone'"
echo ""
echo "   Also check System Settings > Battery:"
echo "   - Uncheck 'Slightly dim the display on battery'"

###############################################################################
# POWER MANAGEMENT SETTINGS
###############################################################################

echo "🔋 Configuring Power Management..."

# Prevent system from sleeping on battery power (set to 0 to disable sleep)
sudo pmset -b sleep 0

# Prevent display from sleeping on battery power (30 minutes)
sudo pmset -b displaysleep 30

# Prevent display from sleeping on AC power (never)
sudo pmset -c displaysleep 0

# Prevent system from sleeping on AC power
sudo pmset -c sleep 0

# Disable display dimming on battery power
sudo pmset -b lessbright 0

# Disable Power Nap on battery
sudo pmset -b powernap 0

# Set standby delay to 24 hours (86400 seconds)
sudo pmset -a standbydelay 86400

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable App Nap system-wide
defaults write NSGlobalDomain NSAppSleepDisabled -bool true


###############################################################################
# ACTIVITY MONITOR
###############################################################################

echo "📊 Configuring Activity Monitor..."

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TERMINAL
###############################################################################

echo "💻 Configuring Terminal..."

###############################################################################
# DEVELOPER EXPERIENCE IMPROVEMENTS
###############################################################################

echo "💻 Configuring Developer Experience..."



# Enable debug menu in Mac App Store
defaults write com.apple.appstore ShowDebugMenu -bool true

# Disable Spotlight indexing for commonly excluded dev directories
# This speeds up file operations in large projects
touch ~/.Trash/.metadata_never_index
touch ~/Downloads/.metadata_never_index

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable text selection in Quick Look windows
defaults write com.apple.finder QLEnableTextSelection -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable automatic emoji substitution
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Speed up window resize animations
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Show battery percentage in menu bar (modern macOS)
defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true

# Configure menu bar clock to show seconds
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -bool false
defaults write com.apple.menuextra.clock IsAnalog -bool false

# Configure menu bar items visibility
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible BentoBox" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Display" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true

# Configure Control Center module visibility in Menu Bar
# Wi-Fi: Show in Menu Bar
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true

# Bluetooth: Show in Menu Bar  
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true

# AirDrop: Don't Show in Menu Bar
defaults write com.apple.controlcenter "NSStatusItem Visible AirDrop" -bool false

# Focus: Show When Active
defaults write com.apple.controlcenter "NSStatusItem Visible DoNotDisturb" -int 1

# Stage Manager: Don't Show in Menu Bar
defaults write com.apple.controlcenter "NSStatusItem Visible StageManager" -bool false

# Screen Mirroring: Show When Active  
defaults write com.apple.controlcenter "NSStatusItem Visible ScreenMirroring" -int 1

# Display: Always Show in Menu Bar (already configured above)
defaults write com.apple.controlcenter "NSStatusItem Visible Display" -bool true

# Sound: Always Show in Menu Bar (already configured above)  
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

# Now Playing: Show When Active
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -int 1

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Enable AirDrop over Ethernet and on unsupported Macs
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Show the main window when launching Archive Utility
defaults write com.apple.archiveutility ShowExpandedDialogs -bool true

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Enable developer extras in all web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# FINISHING UP
###############################################################################

echo "🔄 Applying changes..."

# Kill affected applications (except Terminal to avoid breaking the script)
for app in "Activity Monitor" \
    "ControlCenter" \
    "Dock" \
    "Finder" \
    "SystemUIServer"; do
    killall "${app}" &> /dev/null
done

# Note: Terminal is not restarted to avoid interrupting the running script
print_warning "Restart Terminal manually to see all changes take effect"

echo "✅ macOS system configuration complete!"
echo "📝 Changes applied:"
echo "   • Cleared Dock and disabled auto-rearranging"
echo "   • Disabled auto-correct, capitalization, and smart quotes"
echo "   • Enabled hidden files and path bar in Finder"
echo "   • Configured keyboard repeat rates"
echo "   • Optimized screen capture settings"
echo "   • Improved Activity Monitor defaults"
echo ""
echo "🌟 Display Settings:"
echo "   • Manual configuration required for True Tone & auto brightness"
echo "   • See System Settings > Displays to complete setup"
echo ""
echo "🔋 Power Management:"
echo "   • Disabled sleep on battery power"
echo "   • Display sleeps after 30 min on battery (never on AC)"
echo "   • Disabled display dimming on battery"
echo "   • Disabled App Nap and Power Nap"
echo ""
echo "💻 Developer Experience:"
echo "   • Browser settings commented out for user preference"
echo "   • Disabled Gatekeeper for unsigned apps"
echo "   • Disabled click desktop to show desktop"
echo "   • Disabled .DS_Store on network/USB drives"
echo "   • Enabled text selection in Quick Look"
echo "   • Expanded save/print panels by default"
echo "   • Show battery percentage in menu bar"
echo "   • Clock shows seconds and day of week"
echo "   • Configured menu bar items (WiFi, Bluetooth, Sound, etc.)"
echo "   • Daily software update checks"
echo ""
echo "🔄 Some changes may require a logout/restart to take full effect."
echo ""
echo "🛠️  Next: Run the development environment setup script to install:"
echo "   • Homebrew, iTerm2, Oh My Zsh"
echo "   • SSH keys and Git configuration"
echo "   • Development tools and apps"