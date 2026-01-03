#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Preview Configuration
#
# DESCRIPTION:
#   This script configures Apple Preview preferences including sidebar display,
#   image scaling, PDF viewing options, and window behavior. Preview is the
#   default viewer for images and PDFs on macOS.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Preview app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Preview User Guide
#     https://support.apple.com/guide/preview/welcome/mac
#   - Apple Support: Change Preview preferences
#     https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
#
# DOMAIN:
#   com.apple.Preview
#
# NOTES:
#   - Preview is bundled with macOS and cannot be removed
#   - Preferences stored in ~/Library/Preferences/com.apple.Preview.plist
#   - Preview supports PDF, images, and some document formats
#   - Annotations are saved directly in PDF files
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Preview preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Preview settings..."

# ==============================================================================
# Window Settings
# ==============================================================================

# --- Open Documents in Same Window ---
# Key:          PVImageOpenMode
# Domain:       com.apple.Preview
# Description:  Controls whether opening a new document creates a new window
#               or opens in a tab/same window.
# Default:      2 (open in tabs)
# Options:      1 = Open in new window
#               2 = Open in tabs
# Set to:       2 (reduce window clutter)
# UI Location:  Preview > Settings > General > When opening files
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVImageOpenMode" "-int" "2"

# --- Window Size ---
# Key:          PVWindowSize
# Domain:       com.apple.Preview
# Description:  Controls the initial window size behavior when opening documents.
# Default:      3 (fit to screen)
# Options:      1 = Actual size
#               2 = Fit width
#               3 = Fit to window
# Set to:       3 (see full document)
# UI Location:  View menu options
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVWindowSize" "-int" "3"

# ==============================================================================
# Sidebar Settings
# ==============================================================================

# --- Show Sidebar ---
# Key:          PVSidebarViewModeForNewDocuments
# Domain:       com.apple.Preview
# Description:  Controls whether the sidebar (thumbnails/table of contents)
#               is shown by default when opening documents.
# Default:      0 (hidden)
# Options:      0 = Hidden
#               1 = Thumbnails
#               2 = Table of Contents
#               3 = Annotations
#               4 = Bookmarks
# Set to:       1 (thumbnails for easy navigation)
# UI Location:  View > Thumbnails (Cmd+Option+2)
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVSidebarViewModeForNewDocuments" "-int" "1"

# ==============================================================================
# Image Display Settings
# ==============================================================================

# --- Anti-Aliasing ---
# Key:          PVAntiAliasImages
# Domain:       com.apple.Preview
# Description:  Enables anti-aliasing for smoother image display, especially
#               when zoomed out. May slightly soften pixel art.
# Default:      true
# Options:      true  = Smooth edges (anti-aliased)
#               false = Sharp pixels (no smoothing)
# Set to:       true (smoother appearance)
# UI Location:  Not directly accessible in UI
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVAntiAliasImages" "-bool" "true"

# --- Background Color ---
# Key:          PVBackgroundColor
# Domain:       com.apple.Preview
# Description:  Sets the background color for the image viewing area when the
#               document doesn't fill the window.
# Default:      0 (default gray)
# Options:      0 = Default (matches window)
#               1 = White
#               2 = Black
# Set to:       0 (neutral background)
# UI Location:  View > Customize Toolbar
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVBackgroundColor" "-int" "0"

# ==============================================================================
# PDF Settings
# ==============================================================================

# --- Scale Documents to Fit ---
# Key:          PVScaleDocumentsToFit
# Domain:       com.apple.Preview
# Description:  When enabled, automatically scales documents to fit the window
#               when opened rather than showing at actual size.
# Default:      true
# Options:      true  = Scale to fit window
#               false = Show at actual size
# Set to:       true (see full page)
# UI Location:  Preview > Settings > PDF
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVScaleDocumentsToFit" "-bool" "true"

# --- Open PDF to Last Viewed Page ---
# Key:          PVPDFRememberCurrentPage
# Domain:       com.apple.Preview
# Description:  When opening a PDF that was previously viewed, automatically
#               jump to the last page you were reading.
# Default:      true
# Options:      true  = Remember and restore page position
#               false = Always open to first page
# Set to:       true (continue reading)
# UI Location:  Preview > Settings > PDF
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVPDFRememberCurrentPage" "-bool" "true"

# --- Single Page Display ---
# Key:          PVPDFDisplayMode
# Domain:       com.apple.Preview
# Description:  Controls the default PDF page display mode.
# Default:      0 (single page)
# Options:      0 = Single page
#               1 = Single page continuous
#               2 = Two pages
#               3 = Two pages continuous
# Set to:       1 (single page continuous for scrolling)
# UI Location:  View > Single Page / Two Pages / Continuous
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVPDFDisplayMode" "-int" "1"

# ==============================================================================
# Editing Settings
# ==============================================================================

# --- Show Markup Toolbar ---
# Key:          PVShowMarkupToolbarForNewDocuments
# Domain:       com.apple.Preview
# Description:  Automatically shows the Markup toolbar when opening documents,
#               providing quick access to annotation tools.
# Default:      false
# Options:      true  = Show Markup toolbar
#               false = Hide Markup toolbar
# Set to:       false (show only when needed)
# UI Location:  View > Show Markup Toolbar
# Source:       https://support.apple.com/guide/preview/change-preferences-prvw11793/mac
run_defaults "com.apple.Preview" "PVShowMarkupToolbarForNewDocuments" "-bool" "false"

msg_success "Preview settings applied."
