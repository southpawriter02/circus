#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Xcode Configuration
#
# DESCRIPTION:
#   This script configures Apple Xcode preferences including build settings,
#   editor behavior, derived data location, and debugging options. Xcode is
#   Apple's integrated development environment for macOS, iOS, and other
#   Apple platforms.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Xcode installed from App Store or Apple Developer
#
# REFERENCES:
#   - Apple Developer: Xcode Overview
#     https://developer.apple.com/documentation/xcode
#   - Xcode Help: Xcode preferences
#     https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project
#
# DOMAIN:
#   com.apple.dt.Xcode
#
# NOTES:
#   - Xcode preferences stored in ~/Library/Preferences/com.apple.dt.Xcode.plist
#   - Derived data stored in ~/Library/Developer/Xcode/DerivedData/
#   - Archives stored in ~/Library/Developer/Xcode/Archives/
#   - Command line tools installed separately: xcode-select --install
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Xcode preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Xcode settings..."

# ==============================================================================
# Build Settings
# ==============================================================================

# --- Show Build Times in Activity Viewer ---
# Key:          ShowBuildOperationDuration
# Domain:       com.apple.dt.Xcode
# Description:  Displays build duration in the activity viewer at the top of
#               the Xcode window, useful for monitoring build performance.
# Default:      false
# Options:      true  = Show build duration
#               false = Hide build duration
# Set to:       true (monitor build performance)
# UI Location:  Appears in toolbar after enabling
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "ShowBuildOperationDuration" "-bool" "true"

# --- Continue Building After Errors ---
# Key:          IDEBuildingContinueBuildingAfterErrors
# Domain:       com.apple.dt.Xcode
# Description:  When enabled, Xcode continues building other targets and files
#               even after encountering build errors, showing all errors at once.
# Default:      false
# Options:      true  = Continue building after errors
#               false = Stop at first error
# Set to:       true (see all errors at once)
# UI Location:  Xcode > Settings > General > Continue building after errors
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "IDEBuildingContinueBuildingAfterErrors" "-bool" "true"

# ==============================================================================
# Editor Settings
# ==============================================================================

# --- Show Line Numbers ---
# Key:          DVTTextShowLineNumbers
# Domain:       com.apple.dt.Xcode
# Description:  Displays line numbers in the gutter of the source editor.
#               Essential for navigating code and discussing specific lines.
# Default:      true
# Options:      true  = Show line numbers
#               false = Hide line numbers
# Set to:       true (essential for development)
# UI Location:  Xcode > Settings > Text Editing > Display > Line numbers
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextShowLineNumbers" "-bool" "true"

# --- Show Code Folding Ribbon ---
# Key:          DVTTextShowFoldingSidebar
# Domain:       com.apple.dt.Xcode
# Description:  Shows the code folding ribbon in the editor gutter, allowing
#               you to collapse and expand code blocks.
# Default:      true
# Options:      true  = Show folding ribbon
#               false = Hide folding ribbon
# Set to:       true (easier code navigation)
# UI Location:  Xcode > Settings > Text Editing > Display > Code folding ribbon
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextShowFoldingSidebar" "-bool" "true"

# --- Page Guide Column ---
# Key:          DVTTextPageGuideLocation
# Domain:       com.apple.dt.Xcode
# Description:  Sets the column position for the page guide (vertical line in
#               editor). Helps maintain consistent line lengths.
# Default:      80
# Options:      Any positive integer (typically 80, 100, 120)
# Set to:       120 (modern wider displays)
# UI Location:  Xcode > Settings > Text Editing > Display > Page guide at column
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextPageGuideLocation" "-int" "120"

# --- Show Page Guide ---
# Key:          DVTTextShowPageGuide
# Domain:       com.apple.dt.Xcode
# Description:  Displays a vertical line at the page guide column to indicate
#               the recommended maximum line length.
# Default:      false
# Options:      true  = Show page guide
#               false = Hide page guide
# Set to:       true (maintain line length discipline)
# UI Location:  Xcode > Settings > Text Editing > Display > Show page guide
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextShowPageGuide" "-bool" "true"

# --- Trim Trailing Whitespace ---
# Key:          DVTTextEditorTrimTrailingWhitespace
# Domain:       com.apple.dt.Xcode
# Description:  Automatically removes trailing whitespace from lines when
#               saving files. Keeps code clean and reduces diff noise.
# Default:      true
# Options:      true  = Trim trailing whitespace on save
#               false = Preserve trailing whitespace
# Set to:       true (clean code)
# UI Location:  Xcode > Settings > Text Editing > Editing > Trim trailing whitespace
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextEditorTrimTrailingWhitespace" "-bool" "true"

# --- Trim Whitespace Only Lines ---
# Key:          DVTTextEditorTrimWhitespaceOnlyLines
# Domain:       com.apple.dt.Xcode
# Description:  Also removes whitespace from lines that contain only whitespace
#               (in addition to trailing whitespace from other lines).
# Default:      true
# Options:      true  = Trim whitespace-only lines
#               false = Only trim from lines with content
# Set to:       true (completely clean whitespace)
# UI Location:  Xcode > Settings > Text Editing > Editing
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextEditorTrimWhitespaceOnlyLines" "-bool" "true"

# ==============================================================================
# Indentation Settings
# ==============================================================================

# --- Tab Width ---
# Key:          DVTTextIndentTabWidth
# Domain:       com.apple.dt.Xcode
# Description:  The number of spaces displayed for each tab character.
# Default:      4
# Options:      2, 4, 8 (common values)
# Set to:       4 (Swift/Obj-C standard)
# UI Location:  Xcode > Settings > Text Editing > Indentation > Tab width
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextIndentTabWidth" "-int" "4"

# --- Indent Width ---
# Key:          DVTTextIndentWidth
# Domain:       com.apple.dt.Xcode
# Description:  The number of spaces used for each indentation level when using
#               spaces instead of tabs.
# Default:      4
# Options:      2, 4, 8 (common values)
# Set to:       4 (Swift/Obj-C standard)
# UI Location:  Xcode > Settings > Text Editing > Indentation > Indent width
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "DVTTextIndentWidth" "-int" "4"

# ==============================================================================
# Simulator Settings
# ==============================================================================

# --- Show Device Bezels ---
# Key:          ShowDeviceBezels
# Domain:       com.apple.dt.Xcode
# Description:  Shows device bezels (frame) around the simulator window to
#               make it look like an actual device.
# Default:      true
# Options:      true  = Show device bezels
#               false = Show screen only
# Set to:       false (more screen space)
# UI Location:  Simulator > Window > Show Device Bezels
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "ShowDeviceBezels" "-bool" "false"

# ==============================================================================
# Debugging Settings
# ==============================================================================

# --- Show Runtime Issues ---
# Key:          IDEShowRuntimeIssues
# Domain:       com.apple.dt.Xcode
# Description:  Shows runtime issues (like layout warnings, memory issues) in
#               the Issue Navigator during debugging.
# Default:      true
# Options:      true  = Show runtime issues
#               false = Hide runtime issues
# Set to:       true (catch issues early)
# UI Location:  Xcode > Settings > General > Show runtime issues
# Source:       https://developer.apple.com/documentation/xcode
run_defaults "com.apple.dt.Xcode" "IDEShowRuntimeIssues" "-bool" "true"

# ==============================================================================
# Derived Data
# ==============================================================================

# Note: Derived data location is configured via:
# Xcode > Settings > Locations > Derived Data
#
# Default location: ~/Library/Developer/Xcode/DerivedData
# Custom location can be set per-project or workspace.
#
# To clean derived data:
# rm -rf ~/Library/Developer/Xcode/DerivedData

msg_success "Xcode settings applied."
msg_info "Restart Xcode for all settings to take effect."
echo ""
msg_info "Additional setup:"
echo "  Command Line Tools: xcode-select --install"
echo "  Accept License: sudo xcodebuild -license accept"
