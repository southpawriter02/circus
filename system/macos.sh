#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
# It is best practice to use `#!/usr/bin/env zsh` instead of a hardcoded
# path like `#!/bin/zsh`. This makes the script more portable, as it
# allows the system's `env` command to find the `zsh` interpreter in the
# user's PATH.
# ------------------------------------------------------------------------------

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ FILE:        system/macos.sh                                               ║
# ║ PROJECT:     Dotfiles Flying Circus                                        ║
# ║ REPOSITORY:  https://github.com/southpawriter02/dotfiles                   ║
# ║ AUTHOR:      southpawriter02 <southpawriter@pm.me>                         ║
# ║                                                                            ║
# ║ DESCRIPTION: This script configures macOS system settings using the        ║
# ║              `defaults` command. It is intended to be run by the main      ║
# ║              `install.sh` script.                                          ║
# ║                                                                            ║
# ║ LICENSE:     MIT                                                           ║
# ║ COPYRIGHT:   Copyright (c) $(date +'%Y') southpawriter02                   ║
# ║ STATUS:      DRAFT                                                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# ------------------------------------------------------------------------------
# SECTION: OPTIONS
# ------------------------------------------------------------------------------

set -e
set -u
set -o pipefail

# ------------------------------------------------------------------------------
# SECTION: VARIABLES & CONSTANTS
# ------------------------------------------------------------------------------

# Dynamically determine the root directory of the dotfiles repository.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly HELPERS_LIB="$DOTFILES_DIR/lib/helpers.sh"

# ------------------------------------------------------------------------------
# SECTION: FUNCTIONS
# ------------------------------------------------------------------------------

###
# @description
#   Main function to execute all macOS configuration settings.
###
main() {
  # Source the helper library
  if [[ -f "$HELPERS_LIB" ]]; then
    # shellcheck source=/dev/null
    source "$HELPERS_LIB"
  else
    echo "Error: Helper library not found at $HELPERS_LIB" >&2
    exit 1
  fi

  msg_info "Configuring macOS defaults..."

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Finder
  # ----------------------------------------------------------------------------
  msg_info "Configuring Finder settings..."

  # Show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Dock
  # ----------------------------------------------------------------------------
  msg_info "Configuring Dock settings..."

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Remove the auto-hiding Dock delay
  defaults write com.apple.dock autohide-delay -float 0

  # Set the icon size of Dock items to 36 pixels
  defaults write com.apple.dock tilesize -int 36

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Screenshots
  # ----------------------------------------------------------------------------
  msg_info "Configuring screenshot settings..."

  # Save screenshots to the desktop
  defaults write com.apple.screencapture location -string "${HOME}/Desktop"

  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Kill affected applications
  # ----------------------------------------------------------------------------
  msg_info "Restarting affected applications to apply changes..."

  for app in "Dock" "Finder"; do
    killall "${app}" &> /dev/null || true
  done

  msg_success "macOS defaults have been configured."
  msg_warning "Note that some changes may require a logout/restart to take effect."
}

# ------------------------------------------------------------------------------
# SECTION: SCRIPT EXECUTION
# ------------------------------------------------------------------------------

main "$@"
