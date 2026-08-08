#!/usr/bin/env bash

echo "› Desktop & Dock"
# Automatically hide the Dock
defaults write com.apple.dock autohide -bool true
# Hide recent applications in the Dock
defaults write com.apple.dock show-recents -bool false
# Wipe all pinned app icons from the Dock
defaults write com.apple.dock persistent-apps -array

echo "› Mission Control"
# Keep Spaces arrangement fixed (don't auto-rearrange by recent use)
defaults write com.apple.dock mru-spaces -bool false
# Group windows by application
defaults write com.apple.dock expose-group-apps -bool true
# Disable all Hot Corners
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 0

echo "› Control Center"
# Hide the Spotlight search field from the menu bar
defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true

echo "› Lock Screen"
# Require a password immediately after the screen saver begins or display turns off
sysadminctl -screenLock immediate -password -

echo "› Siri & Spotlight"
# Don't share Spotlight search queries with Apple
defaults write com.apple.assistant.support "Search Queries Data Sharing Status" -int 2
# Disable the Spotlight search keyboard shortcut (⌘ Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
    '<dict><key>enabled</key><false/></dict>'
# Disable the Spotlight Finder search keyboard shortcut (⌥ ⌘ Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 \
    '<dict><key>enabled</key><false/></dict>'

echo "› Finder"
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "› Keyboard"
# Set key repeat rate to Fast
defaults write NSGlobalDomain KeyRepeat -int 2
# Set delay until repeat to Short
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Disable the press-and-hold accent picker
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Enable keyboard navigation (Tab moves focus between controls)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
# Use Caps Lock to switch to and from the ABC input source
defaults write NSGlobalDomain TISRomanSwitchState -bool true

echo "› Trackpad"
# Enable Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -bool true
# Enable the App Exposé gesture
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# Local overrides
if [ -f ~/.macos-defaults.local.sh ]; then
    echo "› Local overrides"
    # shellcheck source=/dev/null
    . ~/.macos-defaults.local.sh
fi

gum log --level warn "Apply: some changes require a logout/restart to fully take effect"
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

gum style --border rounded --border-foreground 214 --padding "1 2" --foreground 255 \
    "$(gum style --bold --foreground 214 "⚠  Manual setup required")" \
    "" \
    "Disable password autofill:" \
    "  System Settings ▸ General ▸ AutoFill & Passwords" \
    "Modifier key remap (Caps Lock ⇄ Control):" \
    "  System Settings ▸ Keyboard ▸ Keyboard Shortcuts ▸ Modifier Keys" \
    "Review privacy settings:" \
    "  System Settings ▸ Privacy & Security ▸ Analytics & Improvements" \
    "                                       ▸ Apple Advertising"
