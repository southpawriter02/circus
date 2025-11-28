#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: TextEdit Configuration
#
# DESCRIPTION:
#   This script configures TextEdit, macOS's built-in text editor. By default,
#   TextEdit creates Rich Text Format (RTF) documents with "smart" typography.
#   These settings convert it to a plain text editor more suitable for coding,
#   note-taking, and writing plain text files.
#
# REQUIRES:
#   - macOS 10.0 or later
#
# REFERENCES:
#   - Apple Support: TextEdit for Mac
#     https://support.apple.com/guide/textedit/welcome/mac
#   - Apple Support: Format a document in TextEdit on Mac
#     https://support.apple.com/guide/textedit/format-a-document-txted0d7f6/mac
#
# DOMAIN:
#   com.apple.TextEdit
#
# NOTES:
#   - Plain text mode is better for configuration files and code
#   - Smart quotes and dashes can break code and scripts
#   - Custom fonts can be set for better coding readability
#   - TextEdit supports syntax highlighting for some formats in RTF mode
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set TextEdit preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring TextEdit settings..."

# ==============================================================================
# Document Format and Behavior
# ==============================================================================

# --- Default to Plain Text Mode ---
# Key:          RichText
# Description:  Controls whether new documents are created as Rich Text (RTF)
#               or plain text (.txt). Plain text is simpler and more
#               compatible with code and configuration files.
# Default:      1 (Rich Text Format)
# Possible:     0 = Plain text
#               1 = Rich Text Format (RTF)
# Set to:       0 (Plain text - better for developers)
# Reference:    TextEdit > Preferences > New Document > Format: Plain text
# Use case:     Plain text is ideal for code snippets, config files,
#               shell scripts, and simple notes
run_defaults "com.apple.TextEdit" "RichText" "-int" "0"

# --- Disable Smart Quotes ---
# Key:          SmartQuotes
# Description:  Controls whether TextEdit automatically substitutes straight
#               quotes (" and ') with curly/typographic quotes (" " and ' ').
#               While prettier for prose, smart quotes break code and scripts.
# Default:      true (smart quotes enabled)
# Possible:     true, false
# Set to:       false (use straight quotes - essential for code)
# Reference:    Edit > Substitutions > Smart Quotes
# Warning:      Smart quotes in code cause syntax errors! Always disable
#               for development work.
run_defaults "com.apple.TextEdit" "SmartQuotes" "-bool" "false"

# --- Disable Smart Dashes ---
# Key:          SmartDashes
# Description:  Controls whether TextEdit automatically substitutes hyphens
#               with en-dashes (–) or em-dashes (—). Like smart quotes,
#               smart dashes break code and scripts.
# Default:      true (smart dashes enabled)
# Possible:     true, false
# Set to:       false (use regular hyphens - essential for code)
# Reference:    Edit > Substitutions > Smart Dashes
# Warning:      Smart dashes in code cause syntax errors! Always disable
#               for development work.
run_defaults "com.apple.TextEdit" "SmartDashes" "-bool" "false"

# ==============================================================================
# Font and Window Settings
# ==============================================================================

# --- Set Default Plain Text Font ---
# Keys:         NSFixedPitchFont, NSFixedPitchFontSize
# Description:  Sets the default font and size for plain text documents.
#               A monospace font with good legibility is ideal for code
#               and plain text editing.
# Default:      Menlo-Regular, 11pt
# Possible:     Any installed monospace font and size
# Set to:       FiraCode-Retina, 13pt (modern coding font with ligatures)
# Reference:    TextEdit > Preferences > Plain text font
# Note:         Fira Code must be installed for this to work. If not
#               installed, TextEdit will fall back to the default font.
#               Install via: brew install --cask font-fira-code
run_defaults "com.apple.TextEdit" "NSFixedPitchFont" "-string" "FiraCode-Retina"
run_defaults "com.apple.TextEdit" "NSFixedPitchFontSize" "-int" "13"

# --- Set Default Window Size ---
# Key:          WinV
# Description:  Sets the default size for new TextEdit windows. A larger
#               window provides more room for editing.
# Default:      Varies (typically small)
# Possible:     Array of two integers for width and height
# Set to:       (900, 600) - a reasonable size for editing
# Note:         This uses a string representation of the size tuple
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set TextEdit preference: 'WinV' to '(900, 600)'"
else
  defaults write com.apple.TextEdit WinV -string "(900, 600)"
fi


msg_success "TextEdit settings applied."
