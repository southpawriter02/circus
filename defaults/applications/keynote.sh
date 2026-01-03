#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Keynote Configuration
#
# DESCRIPTION:
#   This script configures Apple Keynote preferences including presentation
#   display options, auto-save behavior, and authoring settings. Keynote is
#   Apple's presentation software, part of the iWork suite.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Keynote app installed (free from App Store)
#
# REFERENCES:
#   - Apple Support: Keynote User Guide
#     https://support.apple.com/guide/keynote/welcome/mac
#   - Apple Support: Change Keynote settings
#     https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
#
# DOMAIN:
#   com.apple.iWork.Keynote
#
# NOTES:
#   - Keynote preferences stored in ~/Library/Preferences/com.apple.iWork.Keynote.plist
#   - Presentations can sync via iCloud Drive
#   - Supports export to PowerPoint, PDF, and other formats
#   - Presenter display options configured per presentation
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Keynote preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Keynote settings..."

# ==============================================================================
# General Settings
# ==============================================================================

# --- Default Template ---
# Key:          TSADefaultTemplate
# Domain:       com.apple.iWork.Keynote
# Description:  Controls whether new presentations start from a template chooser
#               or use a default template directly.
# Default:      (uses template chooser)
# Options:      Template name or empty for chooser
# Note:         Template selection is better done in-app
# UI Location:  Keynote > Settings > General > For New Documents
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac

# --- Show Presenter Notes ---
# Key:          ShowPresenterNotes
# Domain:       com.apple.iWork.Keynote
# Description:  Shows presenter notes panel in the editing view for easy
#               reference while building presentations.
# Default:      false
# Options:      true  = Show presenter notes
#               false = Hide presenter notes
# Set to:       true (visible notes while editing)
# UI Location:  View > Show Presenter Notes
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "ShowPresenterNotes" "-bool" "true"

# ==============================================================================
# Editing Settings
# ==============================================================================

# --- Show Guides at Object Center ---
# Key:          KNShowsObjectCenterGuides
# Domain:       com.apple.iWork.Keynote
# Description:  Shows alignment guides when dragging objects near the center
#               of other objects, helping with precise positioning.
# Default:      true
# Options:      true  = Show center alignment guides
#               false = Hide center guides
# Set to:       true (precise alignment)
# UI Location:  Keynote > Settings > Rulers
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "KNShowsObjectCenterGuides" "-bool" "true"

# --- Show Guides at Object Edges ---
# Key:          KNShowsObjectEdgeGuides
# Domain:       com.apple.iWork.Keynote
# Description:  Shows alignment guides when dragging objects near the edges
#               of other objects for precise edge alignment.
# Default:      true
# Options:      true  = Show edge alignment guides
#               false = Hide edge guides
# Set to:       true (precise alignment)
# UI Location:  Keynote > Settings > Rulers
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "KNShowsObjectEdgeGuides" "-bool" "true"

# --- Show Size and Position When Moving Objects ---
# Key:          KNShowSizeAndPositionWhenMoving
# Domain:       com.apple.iWork.Keynote
# Description:  Displays a tooltip showing object size and position while
#               dragging objects on the canvas.
# Default:      true
# Options:      true  = Show size/position info
#               false = Hide info during drag
# Set to:       true (precise positioning)
# UI Location:  Keynote > Settings > Rulers
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "KNShowSizeAndPositionWhenMoving" "-bool" "true"

# ==============================================================================
# Slideshow Settings
# ==============================================================================

# --- Exit Presentation After Last Slide ---
# Key:          KNExitAfterLastSlide
# Domain:       com.apple.iWork.Keynote
# Description:  Controls whether the presentation automatically exits after the
#               last slide or shows a black screen.
# Default:      false (shows black screen)
# Options:      true  = Exit after last slide
#               false = Show black screen, wait for manual exit
# Set to:       false (controlled ending)
# UI Location:  Document Settings during presentation
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "KNExitAfterLastSlide" "-bool" "false"

# --- Show Pointer When Using Mouse ---
# Key:          KNShowPointerOnSlide
# Domain:       com.apple.iWork.Keynote
# Description:  Controls whether the mouse pointer is visible on slides during
#               presentation mode when the mouse is moved.
# Default:      true
# Options:      true  = Show pointer during presentation
#               false = Hide pointer
# Set to:       true (useful for pointing at content)
# UI Location:  Play > Customize Presenter Display
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "KNShowPointerOnSlide" "-bool" "true"

# ==============================================================================
# Auto-Save and Versions
# ==============================================================================

# --- Auto-Save ---
# Key:          NSDocumentSavesInPlace
# Domain:       com.apple.iWork.Keynote
# Description:  Enables automatic saving of documents. With auto-save, your
#               work is continuously saved as you edit.
# Default:      true
# Options:      true  = Auto-save enabled
#               false = Manual save only
# Set to:       true (never lose work)
# UI Location:  System-wide preference, respects macOS settings
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "NSDocumentSavesInPlace" "-bool" "true"

# ==============================================================================
# Remote Control
# ==============================================================================

# --- Enable Remote Control ---
# Key:          KNRemoteEnabled
# Domain:       com.apple.iWork.Keynote
# Description:  Allows controlling Keynote presentations using the Keynote
#               Remote app on iPhone or iPad.
# Default:      true
# Options:      true  = Allow remote control
#               false = Disable remote control
# Set to:       true (convenient for presenting)
# UI Location:  Keynote > Settings > Remotes
# Source:       https://support.apple.com/guide/keynote/change-settings-tanc3a3dd7c/mac
run_defaults "com.apple.iWork.Keynote" "KNRemoteEnabled" "-bool" "true"

msg_success "Keynote settings applied."
msg_info "Presenter display settings are configured per presentation."
