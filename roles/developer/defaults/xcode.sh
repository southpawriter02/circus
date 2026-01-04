#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Xcode Settings
#
# DESCRIPTION:
#   Configures Xcode and command-line developer tools settings for
#   iOS/macOS development.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Xcode installed (optional for some settings)
#   - Xcode Command Line Tools installed
#
# REFERENCES:
#   - Apple Developer: Xcode
#     https://developer.apple.com/xcode/
#   - Xcode defaults reference
#     https://nshipster.com/xcode-build-settings/
#
# DOMAIN:
#   com.apple.dt.Xcode
#
# NOTES:
#   - Some settings require Xcode to be quit before applying
#   - Xcode settings can also be modified via xcconfig files
#   - DerivedData can be safely deleted to free disk space
#
# ==============================================================================

msg_info "Configuring Xcode developer settings..."

# ==============================================================================
# Build Settings
# ==============================================================================

# --- Show Build Times ---
# Key:          ShowBuildOperationDuration
# Domain:       com.apple.dt.Xcode
# Description:  Display how long each build takes in the activity viewer.
# Default:      false
# Options:      true = Show build duration
#               false = Hide build duration
# Set to:       true (useful for optimizing build times)
run_defaults "com.apple.dt.Xcode" "ShowBuildOperationDuration" "-bool" "true"

# --- Parallel Build Threads ---
# Key:          IDEBuildOperationMaxNumberOfConcurrentCompileTasks
# Domain:       com.apple.dt.Xcode
# Description:  Maximum number of parallel compile tasks.
#               Higher values can speed up builds on multi-core systems.
# Default:      $(sysctl -n hw.ncpu) (number of CPU cores)
# Set to:       Use all available cores
run_defaults "com.apple.dt.Xcode" "IDEBuildOperationMaxNumberOfConcurrentCompileTasks" "-int" "$(sysctl -n hw.ncpu)"

# ==============================================================================
# Editor Settings
# ==============================================================================

# --- Show Line Numbers ---
# Key:          DVTTextShowLineNumbers
# Domain:       com.apple.dt.Xcode
# Description:  Display line numbers in the code editor.
# Default:      true (in recent Xcode versions)
# Options:      true = Show line numbers
#               false = Hide line numbers
# Set to:       true (essential for debugging)
run_defaults "com.apple.dt.Xcode" "DVTTextShowLineNumbers" "-bool" "true"

# --- Show Code Folding Ribbon ---
# Key:          DVTTextShowFoldingSidebar
# Domain:       com.apple.dt.Xcode
# Description:  Display the code folding ribbon on the left side.
# Default:      true
# Options:      true = Show folding ribbon
#               false = Hide folding ribbon
# Set to:       true (useful for navigating large files)
run_defaults "com.apple.dt.Xcode" "DVTTextShowFoldingSidebar" "-bool" "true"

# --- Trim Trailing Whitespace ---
# Key:          DVTTextEditorTrimTrailingWhitespace
# Domain:       com.apple.dt.Xcode
# Description:  Automatically remove trailing whitespace when saving.
# Default:      false
# Options:      true = Trim whitespace
#               false = Keep whitespace
# Set to:       true (cleaner code)
run_defaults "com.apple.dt.Xcode" "DVTTextEditorTrimTrailingWhitespace" "-bool" "true"

# --- Trim Whitespace Only Lines ---
# Key:          DVTTextEditorTrimWhitespaceOnlyLines
# Domain:       com.apple.dt.Xcode
# Description:  Trim lines that contain only whitespace.
# Default:      false
# Options:      true = Trim whitespace-only lines
#               false = Keep whitespace-only lines
# Set to:       true (cleaner code)
run_defaults "com.apple.dt.Xcode" "DVTTextEditorTrimWhitespaceOnlyLines" "-bool" "true"

# --- Show Invisible Characters ---
# Key:          DVTTextShowInvisibles
# Domain:       com.apple.dt.Xcode
# Description:  Show invisible characters (spaces, tabs, newlines).
# Default:      false
# Options:      true = Show invisibles
#               false = Hide invisibles
# Set to:       false (less visual clutter; enable when needed)
run_defaults "com.apple.dt.Xcode" "DVTTextShowInvisibles" "-bool" "false"

# --- Indent on Paste ---
# Key:          DVTTextIndentOnPaste
# Domain:       com.apple.dt.Xcode
# Description:  Automatically re-indent code when pasting.
# Default:      true
# Options:      true = Re-indent on paste
#               false = Preserve original indentation
# Set to:       true (maintain consistent formatting)
run_defaults "com.apple.dt.Xcode" "DVTTextIndentOnPaste" "-bool" "true"

# ==============================================================================
# Behavior Settings
# ==============================================================================

# --- Show Debug Area on Run ---
# Key:          IDEShowDebugAreaOnRun
# Domain:       com.apple.dt.Xcode
# Description:  Automatically show the debug area when running.
# Default:      true
# Options:      true = Show debug area
#               false = Keep hidden
# Set to:       true (essential for debugging)
run_defaults "com.apple.dt.Xcode" "IDEShowDebugAreaOnRun" "-bool" "true"

# --- Show Issue Navigator on Build Failure ---
# Key:          IDEShowNavigatorOnBuildFailure
# Domain:       com.apple.dt.Xcode
# Description:  Show the issue navigator when a build fails.
# Default:      true
# Options:      true = Show on failure
#               false = Don't show
# Set to:       true (quickly see errors)
run_defaults "com.apple.dt.Xcode" "IDEShowNavigatorOnBuildFailure" "-bool" "true"

# ==============================================================================
# Documentation Settings
# ==============================================================================

# --- Load Documentation on Launch ---
# Key:          IDEIndexerDisableDocIndex
# Domain:       com.apple.dt.Xcode
# Description:  Disable documentation indexing (can improve performance).
# Default:      false (indexing enabled)
# Options:      true = Disable doc indexing
#               false = Enable doc indexing
# Set to:       false (keep documentation available)
run_defaults "com.apple.dt.Xcode" "IDEIndexerDisableDocIndex" "-bool" "false"

# ==============================================================================
# Additional Editor Settings
# ==============================================================================

# --- Indent Width ---
# Key:          DVTTextIndentWidth
# Domain:       com.apple.dt.Xcode
# Description:  Number of spaces for each indentation level.
# Default:      4
# Set to:       4 (standard for Swift)
run_defaults "com.apple.dt.Xcode" "DVTTextIndentWidth" "-int" "4"

# --- Tab Width ---
# Key:          DVTTextTabWidth
# Domain:       com.apple.dt.Xcode
# Description:  Width of tab characters in spaces.
# Default:      4
# Set to:       4 (consistent with indent width)
run_defaults "com.apple.dt.Xcode" "DVTTextTabWidth" "-int" "4"

# --- Use Syntax-Aware Indenting ---
# Key:          DVTTextUsesSyntaxAwareIndenting
# Domain:       com.apple.dt.Xcode
# Description:  Indent based on code structure and syntax.
# Default:      true
# Set to:       true (smart indentation)
run_defaults "com.apple.dt.Xcode" "DVTTextUsesSyntaxAwareIndenting" "-bool" "true"

# --- Indent Case Labels ---
# Key:          DVTTextIndentCase
# Domain:       com.apple.dt.Xcode
# Description:  Indent case labels in switch statements.
# Default:      true
# Set to:       true (standard Swift style)
run_defaults "com.apple.dt.Xcode" "DVTTextIndentCase" "-bool" "true"

# --- Page Guide Column ---
# Key:          DVTTextPageGuideLocation
# Domain:       com.apple.dt.Xcode
# Description:  Column position for the page guide line.
# Default:      80
# Set to:       120 (modern wider displays)
run_defaults "com.apple.dt.Xcode" "DVTTextPageGuideLocation" "-int" "120"

# --- Show Page Guide ---
# Key:          DVTTextShowPageGuide
# Domain:       com.apple.dt.Xcode
# Description:  Display a vertical line at the page guide column.
# Default:      false
# Set to:       true (visual line length indicator)
run_defaults "com.apple.dt.Xcode" "DVTTextShowPageGuide" "-bool" "true"

# ==============================================================================
# Source Control Settings
# ==============================================================================

# --- Enable Source Control ---
# Key:          IDESourceControlEnableSourceControl
# Domain:       com.apple.dt.Xcode
# Description:  Enable Xcode's built-in source control features.
# Default:      true
# Set to:       true (integrated Git support)
run_defaults "com.apple.dt.Xcode" "IDESourceControlEnableSourceControl" "-bool" "true"

# --- Refresh Server Status Automatically ---
# Key:          IDESourceControlRefreshServerStatusAutomatically
# Domain:       com.apple.dt.Xcode
# Description:  Auto-refresh remote repository status.
# Default:      true
# Set to:       true (stay in sync with remote)
run_defaults "com.apple.dt.Xcode" "IDESourceControlRefreshServerStatusAutomatically" "-bool" "true"

# --- Add and Remove Files Automatically ---
# Key:          IDESourceControlAddRemoveFilesAutomatically
# Domain:       com.apple.dt.Xcode
# Description:  Automatically stage new files and remove deleted files.
# Default:      true
# Set to:       true (streamlined Git workflow)
run_defaults "com.apple.dt.Xcode" "IDESourceControlAddRemoveFilesAutomatically" "-bool" "true"

# ==============================================================================
# Code Completion & Assistance
# ==============================================================================

# --- Show Completions Inline ---
# Key:          DVTTextShowCompletionsInline
# Domain:       com.apple.dt.Xcode
# Description:  Show code completions inline as you type.
# Default:      true
# Set to:       true (faster coding with suggestions)
run_defaults "com.apple.dt.Xcode" "DVTTextShowCompletionsInline" "-bool" "true"

# --- Include Matching Braces ---
# Key:          DVTTextAutoInsertClosingBraces
# Domain:       com.apple.dt.Xcode
# Description:  Automatically insert closing braces, parentheses, etc.
# Default:      true
# Set to:       true (auto-pair brackets)
run_defaults "com.apple.dt.Xcode" "DVTTextAutoInsertClosingBraces" "-bool" "true"

# ==============================================================================
# Appearance Settings
# ==============================================================================

# --- File Extension Display ---
# Key:          IDEFileExtensionDisplayMode
# Domain:       com.apple.dt.Xcode
# Description:  How to display file extensions in the navigator.
# Options:      0 = Show all, 1 = Hide known, 2 = Hide all
# Default:      1
# Set to:       0 (show all extensions)
run_defaults "com.apple.dt.Xcode" "IDEFileExtensionDisplayMode" "-int" "0"

# --- Show Quick Look for Pasteboard ---
# Key:          IDEShowPasteboardDocumentsForQuickLook
# Domain:       com.apple.dt.Xcode
# Description:  Show Quick Look previews for clipboard content.
# Default:      true
# Set to:       true (useful for debugging)
run_defaults "com.apple.dt.Xcode" "IDEShowPasteboardDocumentsForQuickLook" "-bool" "true"

# --- Single Click to Open Files ---
# Key:          IDEEditorCoordinatorTarget_Click
# Domain:       com.apple.dt.Xcode
# Description:  Single-click behavior in the navigator.
# Options:      0 = Preview, 1 = Open in new tab
# Default:      0
# Set to:       0 (single-click previews, double-click opens)
run_defaults "com.apple.dt.Xcode" "IDEEditorCoordinatorTarget_Click" "-int" "0"

# ==============================================================================
# Debugging Settings
# ==============================================================================

# --- Enable GPU Frame Capture ---
# Key:          IDEDebuggerEnableGPUFrameCapture
# Domain:       com.apple.dt.Xcode
# Description:  Enable GPU frame capture for Metal debugging.
# Default:      true
# Set to:       true (useful for graphics development)
run_defaults "com.apple.dt.Xcode" "IDEDebuggerEnableGPUFrameCapture" "-bool" "true"

# --- Enable View Debugging ---
# Key:          IDEDebuggerEnableViewDebugging
# Domain:       com.apple.dt.Xcode
# Description:  Enable view hierarchy debugging.
# Default:      true
# Set to:       true (essential for UI debugging)
run_defaults "com.apple.dt.Xcode" "IDEDebuggerEnableViewDebugging" "-bool" "true"

# ==============================================================================
# DerivedData Location
#
# DerivedData is where Xcode stores build products and indexes.
# By default: ~/Library/Developer/Xcode/DerivedData
#
# To change location (useful for faster SSD or RAM disk):
# Xcode > Settings > Locations > DerivedData
#
# To clean DerivedData:
# rm -rf ~/Library/Developer/Xcode/DerivedData
#
# ==============================================================================

# ==============================================================================
# Command Line Tools
# ==============================================================================

# Verify command line tools are installed
if ! xcode-select -p &>/dev/null; then
    msg_info "Xcode Command Line Tools not found. Install with: xcode-select --install"
fi

# ==============================================================================
# Simulator Settings
#
# iOS Simulator settings are primarily configured through:
# - Simulator app preferences
# - simctl command line tool
#
# Common simctl commands:
#   xcrun simctl list                    # List all simulators
#   xcrun simctl boot "iPhone 15"        # Boot a simulator
#   xcrun simctl shutdown all            # Shutdown all simulators
#   xcrun simctl erase all               # Reset all simulators
#
# ==============================================================================

msg_success "Xcode developer settings configured."

# ==============================================================================
# Troubleshooting
#
# Reset Xcode settings:
#   defaults delete com.apple.dt.Xcode
#
# Clean build folder:
#   Xcode: Product > Clean Build Folder (Cmd+Shift+K)
#
# Delete DerivedData:
#   rm -rf ~/Library/Developer/Xcode/DerivedData
#
# Delete Xcode caches:
#   rm -rf ~/Library/Caches/com.apple.dt.Xcode
#
# Reset simulators:
#   xcrun simctl erase all
#
# ==============================================================================
