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

# ==============================================================================
# Dock Architecture
# ==============================================================================

# The Dock is managed by the `Dock.app` process and stores its configuration
# in ~/Library/Preferences/com.apple.dock.plist.
#
# DOCK STRUCTURE:
#
#   ┌────────────────────────────────────────────────────────────────────────┐
#   │  Apps (left)              │ Divider │  Stacks/Files  │  Trash │       │
#   │  Finder, Safari, etc.     │    |    │  Downloads     │   🗑   │       │
#   └────────────────────────────────────────────────────────────────────────┘
#
# The plist contains two main arrays:
#   - persistent-apps: Applications pinned to the left side
#   - persistent-others: Folders/files/stacks on the right side
#
# MODIFYING THE DOCK:
#   1. dockutil (recommended) - Safe, version-compatible manipulation
#   2. defaults write - Direct plist editing (can corrupt if wrong format)
#   3. PlistBuddy - Low-level plist editing (for advanced use)
#
# HIDDEN DOCK SETTINGS:
#   Many Dock behaviors can only be changed via `defaults write`:
#
#   # Single-app mode (hides all apps except focused one)
#   defaults write com.apple.dock single-app -bool true
#
#   # Add spacers between Dock icons
#   defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
#
#   # Highlight hidden apps (dimmed icons)
#   defaults write com.apple.dock showhidden -bool true
#
#   # Spring-loaded Dock folders (drag hover to open)
#   defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
#
#   # Scroll to Exposé for app's windows (hover + scroll)
#   defaults write com.apple.dock scroll-to-open -bool true
#
# DOCK DATABASE:
#   On modern macOS, Dock state is also tracked in:
#   ~/Library/Application Support/Dock/
#
# Source:       man defaults
# See also:     https://www.defaults-write.com/tag/dock/

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Dock preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

# ==============================================================================
# Dock Preferences
# ==============================================================================

msg_info "Configuring Dock preferences..."

# --- Dock Icon Size ---
# Key:          tilesize
# Domain:       com.apple.dock
# Description:  Controls the size of icons in the Dock, measured in pixels.
#               Smaller icons allow more apps in the Dock, while larger icons
#               are easier to click and identify.
# Default:      64 (pixels)
# Options:      Integer value from 16 to 128 pixels
#               16-32 = Very small (many icons fit)
#               48    = Small (compact but usable)
#               64    = Default (balanced)
#               96-128 = Large (easy to see)
# Set to:       48 (compact dock for more screen space)
# UI Location:  System Settings > Desktop & Dock > Size slider
# Source:       https://support.apple.com/guide/mac-help/change-dock-preferences-mchlp1119/mac
run_defaults "com.apple.dock" "tilesize" "-int" "48"

# --- Auto-Hide Dock ---
# Key:          autohide
# Domain:       com.apple.dock
# Description:  Controls whether the Dock automatically hides when not in use.
#               When enabled, the Dock slides off-screen and reappears when you
#               move the cursor to the screen edge where the Dock is located.
# Default:      false (Dock always visible)
# Options:      true  = Auto-hide Dock (more screen space)
#               false = Always show Dock
# Set to:       false (keep Dock visible for quick access)
# UI Location:  System Settings > Desktop & Dock > Automatically hide and show the Dock
# Source:       https://support.apple.com/guide/mac-help/change-dock-preferences-mchlp1119/mac
run_defaults "com.apple.dock" "autohide" "-bool" "false"

# --- Auto-Hide Delay ---
# Key:          autohide-delay
# Domain:       com.apple.dock
# Description:  Controls the delay before the Dock appears when you move the
#               cursor to the screen edge (only applies when autohide is enabled).
#               Setting to 0 makes the Dock appear instantly.
# Default:      0.2 (seconds)
# Options:      Float value in seconds:
#               0.0 = Instant (no delay)
#               0.2 = Default delay
#               0.5+ = Longer delay
# Set to:       0 (instant appearance when needed)
# UI Location:  Not available in UI (terminal only)
# Source:       https://support.apple.com/guide/mac-help/change-dock-preferences-mchlp1119/mac
run_defaults "com.apple.dock" "autohide-delay" "-float" "0"

# --- Dock Position ---
# Key:          orientation
# Domain:       com.apple.dock
# Description:  Controls which edge of the screen the Dock appears on.
#               The Dock can be placed at the bottom, left, or right edge.
# Default:      bottom
# Options:      bottom = Dock at bottom of screen (traditional)
#               left   = Dock on left edge
#               right  = Dock on right edge
# Set to:       bottom (standard position)
# UI Location:  System Settings > Desktop & Dock > Position on screen
# Source:       https://support.apple.com/guide/mac-help/change-dock-preferences-mchlp1119/mac
run_defaults "com.apple.dock" "orientation" "-string" "bottom"

# --- Show Recent Applications ---
# Key:          show-recents
# Domain:       com.apple.dock
# Description:  Controls whether the Dock shows recently used applications in
#               a separate section on the right side of the Dock (before folders).
#               Disabling this creates a cleaner, more predictable Dock.
# Default:      true (show recent apps)
# Options:      true  = Show recent applications section
#               false = Hide recent applications (cleaner Dock)
# Set to:       false (cleaner Dock without transient icons)
# UI Location:  System Settings > Desktop & Dock > Show recent applications in Dock
# Source:       https://support.apple.com/guide/mac-help/change-dock-preferences-mchlp1119/mac
run_defaults "com.apple.dock" "show-recents" "-bool" "false"

# --- Minimize Effect ---
# Key:          mineffect
# Domain:       com.apple.dock
# Description:  Controls the animation style when minimizing windows to the Dock.
#               The scale effect is faster and less visually distracting than
#               the default genie effect.
# Default:      genie (windows squeeze into Dock)
# Options:      genie = Genie effect (default, playful)
#               scale = Scale effect (faster, more professional)
#               suck  = Suck effect (hidden option, requires defaults)
# Set to:       scale (faster, less distracting)
# UI Location:  System Settings > Desktop & Dock > Minimize windows using
# Source:       https://support.apple.com/guide/mac-help/change-dock-preferences-mchlp1119/mac
run_defaults "com.apple.dock" "mineffect" "-string" "scale"

# ==============================================================================
# Dock Items (via dockutil)
# ==============================================================================

main() {
  msg_info "Configuring Dock items..."

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
