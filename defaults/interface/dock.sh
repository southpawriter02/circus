#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Dock Configuration
#
# DESCRIPTION:
#   This script uses the `dockutil` tool to create a clean, organized Dock
#   with a curated list of applications. The Dock provides quick access to
#   frequently used apps and can show active applications and minimized windows.
#
# REQUIRES:
#   - dockutil command-line tool (install via Homebrew: brew install dockutil)
#   - macOS 10.10 (Yosemite) or later
#
# REFERENCES:
#   - dockutil GitHub Repository
#     https://github.com/kcrawford/dockutil
#   - Apple Support: Use the Dock on Mac
#     https://support.apple.com/guide/mac-help/open-apps-using-the-dock-mh35859/mac
#   - Apple Human Interface Guidelines: The Dock
#     https://developer.apple.com/design/human-interface-guidelines/the-dock
#
# NOTES:
#   - The Dock is automatically restarted after all changes are made
#   - Apps must be installed for their icons to appear in the Dock
#   - The --no-restart flag is used to batch changes for efficiency
#   - Removing all items first ensures a clean, predictable Dock layout
#
# ==============================================================================

main() {
  msg_info "Configuring the Dock..."

  # --- Prerequisite Check ---
  # dockutil is required to manage Dock items. It's not included with macOS
  # and must be installed separately (typically via Homebrew).
  if ! command -v dockutil >/dev/null 2>&1; then
    msg_warning "\`dockutil\` command not found. Skipping Dock configuration."
    msg_info "Please ensure \`dockutil\` is installed, for example by adding it to the Brewfile."
    return 1
  fi

  # ==============================================================================
  # Configuration
  # ==============================================================================

  # A list of applications to add to the Dock, in order from left to right.
  # Note: The path must be to the actual .app bundle.
  #
  # Customize this list to include your most frequently used applications.
  # Common developer apps to consider:
  # - /Applications/Xcode.app
  # - /Applications/Slack.app
  # - /Applications/1Password.app
  # - /Applications/Docker.app
  local apps_to_add=(
    "/System/Applications/Finder.app"
    "/System/Applications/System Settings.app"
    "/Applications/iTerm.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Google Chrome.app"
  )

  # ==============================================================================
  # Dock Management
  # ==============================================================================

  # --- Step 1: Clear the Dock ---
  # Remove all existing items for a clean slate. This ensures the Dock
  # contains only the apps we explicitly add below.
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would clear all items from the Dock."
  else
    dockutil --remove all --no-restart
    msg_info "Cleared the Dock."
  fi

  # --- Step 2: Add Applications ---
  # Add each app in the list to the Dock. The --no-restart flag prevents
  # the Dock from restarting after each addition (we'll do one restart at the end).
  msg_info "Adding applications to the Dock..."
  for app_path in "${apps_to_add[@]}"; do
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would add '$app_path' to the Dock."
    else
      if [ -d "$app_path" ]; then
        if dockutil --add "$app_path" --no-restart; then
          msg_success "Added $(basename "$app_path") to the Dock."
        else
          msg_error "Failed to add $(basename "$app_path") to the Dock."
        fi
      else
        msg_warning "Application not found at $app_path. Skipping."
      fi
    fi
  done

  # --- Step 3: Add Downloads Folder ---
  # Add the Downloads folder to the right side of the Dock (in the "Stacks" area).
  # Configuration options:
  #   --view grid     : Display as a grid when clicked
  #   --display folder: Show as a folder icon
  #   --sort dateadded: Sort contents by when they were added
  msg_info "Adding Downloads folder to the Dock..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would add the Downloads folder to the Dock."
  else
    if dockutil --add "$HOME/Downloads" --view grid --display folder --sort dateadded --no-restart; then
      msg_success "Added Downloads folder to the Dock."
    else
      msg_error "Failed to add Downloads folder to the Dock."
    fi
  fi

  # --- Step 4: Restart the Dock ---
  # Apply all changes at once by restarting the Dock process.
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would restart the Dock."
  else
    msg_info "Restarting the Dock to apply changes..."
    killall Dock
  fi

  msg_success "Dock configuration complete."
}

main
