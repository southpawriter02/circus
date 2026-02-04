#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Finder Configuration
#
# DESCRIPTION:
#   This script configures settings for the macOS Finder, the primary file
#   management application. These settings optimize Finder for developer
#   workflows by showing hidden files, full paths, and file extensions.
#
# REQUIRES:
#   - macOS 10.5 (Leopard) or later
#
# REFERENCES:
#   - Finder Preferences Reference
#     https://support.apple.com/guide/mac-help/finder-mchlp2605/mac
#   - Apple Support: View and sort files in the Finder on Mac
#     https://support.apple.com/guide/mac-help/view-and-sort-files-mchlp1083/mac
#   - Mathias Bynens' dotfiles (inspiration)
#     https://github.com/mathiasbynens/dotfiles/blob/main/.macos
#   - defaults command: man defaults
#
# DOMAINS:
#   com.apple.finder     - Finder-specific settings
#   NSGlobalDomain       - System-wide settings (file extensions)
#
# NOTES:
#   - Changes require restarting Finder to take effect
#   - Some settings are user-specific, others are system-wide
#   - The Finder automatically creates ~/Desktop, ~/Documents, ~/Downloads
#
# ==============================================================================

# ==============================================================================
# Finder Architecture & Hidden Features
# ==============================================================================

# Finder is deeply integrated with macOS and manages:
# - File browsing and management
# - Desktop icons and wallpaper
# - Trash management
# - AirDrop (in recent macOS versions)
# - Quick Look previews
# - Spotlight integration
# - iCloud Drive sync
#
# FINDER PREFERENCE LOCATIONS:
#   ~/Library/Preferences/com.apple.finder.plist   - User preferences
#   ~/Library/Preferences/com.apple.desktopservices.plist - Desktop behavior
#   ~/Library/Saved Application State/com.apple.finder.savedState/ - Window state
#
# USEFUL KEYBOARD SHORTCUTS:
#   ⌘⇧.         Toggle hidden files visibility (quick toggle)
#   ⌘⌥P         Toggle path bar
#   ⌘/          Toggle status bar
#   ⌘D          Duplicate selected item
#   ⌘⇧G         Go to folder (enter path directly)
#   ⌘⇧A         Go to Applications folder
#   ⌘⇧H         Go to Home folder
#   ⌘⇧D         Go to Desktop folder
#   ⌘I          Get Info for selected item
#   Space       Quick Look preview
#
# HIDDEN FINDER FEATURES:
#   # Enable "Quit Finder" menu item
#   defaults write com.apple.finder QuitMenuItem -bool true
#
#   # Show full POSIX path in title bar
#   defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
#
#   # Disable window animations and Get Info animations
#   defaults write com.apple.finder DisableAllAnimations -bool true
#
#   # Expand save panel by default
#   defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
#
# TROUBLESHOOTING:
#   # Reset Finder to defaults
#   defaults delete com.apple.finder
#   killall Finder
#
#   # Force Finder to show all volumes on desktop
#   defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
#   defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
#
#   # Clear "Open With" duplicates
#   /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
#
# Source:       man defaults
# See also:     https://github.com/mathiasbynens/dotfiles/blob/main/.macos

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Finder preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Finder settings..."

# ==============================================================================
# Finder Window Display Options
# ==============================================================================

# --- Show Path Bar ---
# Key:          ShowPathbar
# Domain:       com.apple.finder
# Description:  Shows the full file path at the bottom of Finder windows.
#               Each component is clickable, allowing quick navigation to
#               parent directories. This provides constant awareness of your
#               location in the file system hierarchy.
# Default:      false (path bar hidden)
# Options:      true  = Show path bar at window bottom
#               false = Hide path bar
# Set to:       true (essential for navigation awareness)
# UI Location:  View menu > Show Path Bar (⌥⌘P)
# Source:       https://support.apple.com/guide/mac-help/see-the-path-to-a-file-mchlp1774/mac
# Note:         Double-click a folder in the path bar to open it in a new window.
run_defaults "com.apple.finder" "ShowPathbar" "-bool" "true"

# --- Show Status Bar ---
# Key:          ShowStatusBar
# Domain:       com.apple.finder
# Description:  Shows the item count and available disk space at the bottom
#               of Finder windows. Provides at-a-glance information about
#               folder contents and storage availability.
# Default:      false (status bar hidden in recent macOS versions)
# Options:      true  = Show status bar with item count and disk space
#               false = Hide status bar
# Set to:       true (useful for storage monitoring)
# UI Location:  View menu > Show Status Bar (⌘/)
# Source:       https://support.apple.com/guide/mac-help/change-how-folders-look-in-the-finder-mchlp2899/mac
run_defaults "com.apple.finder" "ShowStatusBar" "-bool" "true"

# --- Show All File Extensions ---
# Key:          AppleShowAllExtensions
# Domain:       NSGlobalDomain (system-wide setting)
# Description:  Controls whether Finder displays all file extensions
#               (e.g., .txt, .jpg, .sh). By default, macOS hides extensions
#               for "known" file types. Showing all extensions is essential
#               for developers to distinguish between files with similar names.
# Default:      false (extensions hidden for known file types)
# Options:      true  = Show all file extensions
#               false = Hide extensions for known file types
# Set to:       true (essential for developers)
# UI Location:  Finder > Settings > Advanced > Show all filename extensions
# Source:       https://support.apple.com/guide/mac-help/show-or-hide-filename-extensions-mchlp2304/mac
# Security:     Showing extensions helps identify malicious files disguised
#               with fake extensions (e.g., "document.pdf.exe").
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set global preference: AppleShowAllExtensions to true"
else
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
fi

# --- Default View Style ---
# Key:          FXPreferredViewStyle
# Domain:       com.apple.finder
# Description:  Sets the default view style for new Finder windows.
#               Column view is preferred by many developers for navigating
#               deep directory structures, as it shows the hierarchy and
#               allows quick traversal without opening multiple windows.
# Default:      icnv (Icon View)
# Options:      icnv = Icon View (grid of large icons)
#               clmv = Column View (hierarchical columns)
#               Nlsv = List View (detailed file list with columns)
#               glyv = Gallery View (large preview with thumbnails)
# Set to:       clmv (Column View for easy navigation)
# UI Location:  View menu > as Columns (⌘3)
# Source:       https://support.apple.com/guide/mac-help/view-and-sort-files-mchlp1083/mac
# Note:         Column view shows file info in the rightmost column when
#               a file is selected.
run_defaults "com.apple.finder" "FXPreferredViewStyle" "-string" "clmv"

# ==============================================================================
# Advanced Finder Behavior
# ==============================================================================

# --- Show Hidden Files ---
# Key:          AppleShowAllFiles
# Domain:       com.apple.finder
# Description:  Controls whether Finder shows hidden files (those starting
#               with a dot, like .gitignore, .bashrc, .env). These files are
#               hidden by default to reduce clutter for casual users, but
#               developers need to see them regularly.
# Default:      false (hidden files are hidden)
# Options:      true  = Show hidden files (dimmed in Finder)
#               false = Hide files starting with dot
# Set to:       true (essential for developers working with dotfiles)
# UI Location:  No direct UI - toggle with ⌘⇧. keyboard shortcut
# Source:       https://support.apple.com/guide/mac-help/view-hidden-files-and-folders-mchlp1791/mac
# Note:         You can temporarily toggle hidden files with the keyboard
#               shortcut Command+Shift+Period (⌘⇧.).
run_defaults "com.apple.finder" "AppleShowAllFiles" "-bool" "true"

# --- Default Search Scope ---
# Key:          FXDefaultSearchScope
# Domain:       com.apple.finder
# Description:  Determines the default search scope when using Finder's
#               search field. Searching the current folder is usually more
#               intuitive than searching the entire Mac, especially when
#               working within a specific project directory.
# Default:      SCev (Search This Mac - entire computer)
# Options:      SCev = Search This Mac (entire computer)
#               SCcf = Search the Current Folder only
#               SCsp = Use the Previous Search Scope
# Set to:       SCcf (Current Folder for focused project-based searching)
# UI Location:  Finder > Settings > Advanced > When performing a search
# Source:       https://support.apple.com/guide/mac-help/narrow-search-results-mchlp1067/mac
run_defaults "com.apple.finder" "FXDefaultSearchScope" "-string" "SCcf"

# --- Keep Folders on Top ---
# Key:          _FXSortFoldersFirst
# Domain:       com.apple.finder
# Description:  When sorting by name, keeps folders grouped together at
#               the top of the list, separate from files. This organizational
#               approach makes it easier to navigate directory structures
#               and matches the behavior of many file managers.
# Default:      false (folders mixed with files alphabetically)
# Options:      true  = Folders appear first, then files
#               false = Folders and files sorted together
# Set to:       true (cleaner organization for directory navigation)
# UI Location:  Finder > Settings > Advanced > Keep folders on top
# Source:       https://support.apple.com/guide/mac-help/finder-settings-mchlp2899/mac
run_defaults "com.apple.finder" "_FXSortFoldersFirst" "-bool" "true"

# --- Disable Extension Change Warning ---
# Key:          FXEnableExtensionChangeWarning
# Domain:       com.apple.finder
# Description:  Controls whether Finder shows a warning dialog when
#               changing a file's extension. Disabling this removes an
#               unnecessary interruption for power users who frequently
#               rename files and understand the implications.
# Default:      true (warning dialog shown)
# Options:      true  = Show warning when changing extensions
#               false = Allow extension changes without warning
# Set to:       false (suppress warning for power users)
# UI Location:  Alert appears when renaming a file with new extension
# Source:       https://support.apple.com/guide/mac-help/rename-files-folders-and-disks-mchlp1144/mac
# Note:         Even with this disabled, Finder will still prevent you from
#               removing an extension entirely without the dialog.
run_defaults "com.apple.finder" "FXEnableExtensionChangeWarning" "-bool" "false"

# ==============================================================================
# Window & Navigation Behavior
# ==============================================================================

# --- New Finder Window Target ---
# Key:          NewWindowTarget
# Domain:       com.apple.finder
# Description:  Controls what location opens when you create a new Finder window
#               (Cmd+N) or click the Finder dock icon. Setting this to your home
#               folder provides quick access to your personal files.
# Default:      PfHm (Home folder)
# Options:      PfCm = Computer (shows all volumes)
#               PfVo = Volume (root of current volume)
#               PfHm = Home folder (~/)
#               PfDe = Desktop (~/Desktop)
#               PfDo = Documents (~/Documents)
#               PfLo = All My Files (spotlight-based view)
#               PfAF = iCloud Drive
# Set to:       PfHm (home folder for quick access)
# UI Location:  Finder > Settings > General > New Finder windows show
# Source:       https://support.apple.com/guide/mac-help/finder-settings-mchlp2899/mac
run_defaults "com.apple.finder" "NewWindowTarget" "-string" "PfHm"

# --- New Window Target Path ---
# Key:          NewWindowTargetPath
# Domain:       com.apple.finder
# Description:  Specifies the exact path for new Finder windows. This works in
#               conjunction with NewWindowTarget to define the starting location.
#               Must be a file:// URL format.
# Default:      file://${HOME}/ (user's home directory)
# Set to:       file://${HOME}/ (matches NewWindowTarget setting)
# UI Location:  Finder > Settings > General > New Finder windows show
# Source:       https://support.apple.com/guide/mac-help/finder-settings-mchlp2899/mac
# Note:         The path must use file:// URL scheme and be properly escaped.
run_defaults "com.apple.finder" "NewWindowTargetPath" "-string" "file://${HOME}/"

# --- Quick Look Text Selection ---
# Key:          QLEnableTextSelection
# Domain:       com.apple.finder
# Description:  Enables selecting and copying text from Quick Look previews
#               (spacebar preview). By default, Quick Look only displays text
#               but doesn't allow selection. Enabling this lets you copy text
#               without fully opening the document.
# Default:      false (text selection disabled in Quick Look)
# Options:      true  = Enable text selection in Quick Look
#               false = View-only mode (no selection)
# Set to:       true (copy text directly from previews)
# UI Location:  Not available in UI (terminal only)
# Source:       https://support.apple.com/guide/mac-help/view-and-edit-files-quick-look-mh14119/mac
# Note:         Press spacebar to preview a file, then select text directly.
run_defaults "com.apple.finder" "QLEnableTextSelection" "-bool" "true"

# --- Spring-Loaded Folders Delay ---
# Key:          com.apple.springing.delay
# Domain:       NSGlobalDomain
# Description:  Controls the delay before spring-loaded folders open when
#               dragging a file over them. Spring loading automatically opens
#               a folder when you hover over it during a drag operation.
# Default:      0.5 (half second delay)
# Options:      Float value in seconds:
#               0.0 = Instant (no delay)
#               0.3 = Short delay (recommended)
#               0.5 = Default
#               1.0 = Long delay
# Set to:       0.3 (faster response for efficient file management)
# UI Location:  System Settings > Accessibility > Pointer Control > Spring-loading delay
# Source:       https://support.apple.com/guide/mac-help/accessibility-pointer-control-settings-mchl5bb87cce/mac
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set global preference: com.apple.springing.delay to 0.3"
else
  defaults write NSGlobalDomain com.apple.springing.delay -float 0.3
fi

# --- Disable Window Animations ---
# Key:          NSAutomaticWindowAnimationsEnabled
# Domain:       NSGlobalDomain
# Description:  Controls whether windows animate when opening documents from
#               Finder (the zoom effect from file icon to window). Disabling
#               this makes Finder feel snappier by removing the animation delay.
# Default:      true (animations enabled)
# Options:      true  = Enable window opening animations
#               false = Disable animations (instant window appearance)
# Set to:       false (faster, no animation delay)
# UI Location:  Not directly available in UI (terminal only)
# Source:       https://support.apple.com/guide/mac-help/change-general-preferences-mchlp1225/mac
# Note:         This affects all apps that use standard window opening behavior,
#               not just Finder.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set global preference: NSAutomaticWindowAnimationsEnabled to false"
else
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
fi

# ==============================================================================
# Apply Changes
# ==============================================================================

# Changes to Finder require restarting the Finder process to take effect.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would restart Finder to apply changes."
else
  msg_info "Restarting Finder to apply changes..."
  killall Finder
fi

msg_success "Finder settings applied."
