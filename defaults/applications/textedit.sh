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
# Domain:       com.apple.TextEdit
# Description:  Controls whether new documents are created as Rich Text (RTF)
#               or plain text (.txt). Plain text is simpler, more compatible
#               with code and configuration files, and doesn't add hidden
#               formatting that can cause issues when copy-pasting.
# Default:      1 (Rich Text Format - RTF with formatting options)
# Options:      0 = Plain text (.txt files with no formatting)
#               1 = Rich Text Format (.rtf files with formatting)
# Set to:       0 (Plain text - better for developers and code)
# UI Location:  TextEdit > Settings > New Document > Format: Plain text
# Source:       https://support.apple.com/guide/textedit/work-with-plain-text-documents-txted1098/mac
# Note:         You can always convert individual documents using Format menu.
#               Plain text is ideal for code snippets, config files, shell
#               scripts, and simple notes.
run_defaults "com.apple.TextEdit" "RichText" "-int" "0"

# --- Disable Smart Quotes ---
# Key:          SmartQuotes
# Domain:       com.apple.TextEdit
# Description:  Controls whether TextEdit automatically substitutes straight
#               quotes (" and ') with curly/typographic quotes (" " and ' ').
#               While prettier for prose, smart quotes break code and scripts
#               because they are different Unicode characters.
# Default:      true (smart quotes enabled)
# Options:      true  = Convert " to " " and ' to ' ' (typographic)
#               false = Keep straight quotes (ASCII " and ')
# Set to:       false (use straight quotes - essential for code)
# UI Location:  Edit > Substitutions > Smart Quotes (toggle)
# Source:       https://support.apple.com/guide/textedit/type-special-characters-txted0d7f6/mac
# See also:     https://support.apple.com/guide/mac-help/use-substitutions-in-apps-mchlp1171/mac
# Note:         ⚠️ Smart quotes in code cause syntax errors! Always disable
#               when editing scripts, config files, or any code.
run_defaults "com.apple.TextEdit" "SmartQuotes" "-bool" "false"

# --- Disable Smart Dashes ---
# Key:          SmartDashes
# Domain:       com.apple.TextEdit
# Description:  Controls whether TextEdit automatically substitutes hyphens
#               with en-dashes (–) or em-dashes (—). Like smart quotes,
#               smart dashes break code and scripts because they are
#               different Unicode characters than the hyphen-minus (-).
# Default:      true (smart dashes enabled)
# Options:      true  = Convert -- to – and --- to — (typographic)
#               false = Keep regular hyphens (ASCII -)
# Set to:       false (use regular hyphens - essential for code)
# UI Location:  Edit > Substitutions > Smart Dashes (toggle)
# Source:       https://support.apple.com/guide/textedit/type-special-characters-txted0d7f6/mac
# Note:         ⚠️ Smart dashes in code cause syntax errors! Command-line
#               options like --help will break if dashes are substituted.
run_defaults "com.apple.TextEdit" "SmartDashes" "-bool" "false"

# ==============================================================================
# Font and Window Settings
# ==============================================================================

# --- Set Default Plain Text Font ---
# Key:          NSFixedPitchFont
#               NSFixedPitchFontSize
# Domain:       com.apple.TextEdit
# Description:  Sets the default font and size for plain text documents.
#               A monospace font with good legibility is ideal for code
#               and plain text editing. Fira Code includes programming
#               ligatures that combine characters like != into single glyphs.
# Default:      Menlo-Regular, 11pt (Apple's default monospace font)
# Options:      Any installed monospace font name and size
# Set to:       FiraCode-Retina, 13pt (modern coding font with ligatures)
# UI Location:  TextEdit > Settings > Plain text font (Change button)
# Source:       https://support.apple.com/guide/textedit/change-fonts-txted1112/mac
# Note:         Fira Code must be installed for this to work. If not
#               installed, TextEdit will fall back to the system default.
#               Install via: brew install --cask font-fira-code
run_defaults "com.apple.TextEdit" "NSFixedPitchFont" "-string" "FiraCode-Retina"
run_defaults "com.apple.TextEdit" "NSFixedPitchFontSize" "-int" "13"

# --- Set Default Window Size ---
# Key:          WinV
# Domain:       com.apple.TextEdit
# Description:  Sets the default size for new TextEdit windows. A larger
#               window provides more room for editing and reduces the need
#               to resize windows after opening.
# Default:      Varies by system (typically small)
# Options:      String tuple representing width and height
# Set to:       (900, 600) - a reasonable size for editing on most displays
# UI Location:  No direct UI - resize window and it becomes the default
# Source:       https://support.apple.com/guide/textedit/welcome/mac
# Note:         This uses a string representation of the size tuple.
#               Window position is not affected by this setting.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set TextEdit preference: 'WinV' to '(900, 600)'"
else
  defaults write com.apple.TextEdit WinV -string "(900, 600)"
fi

# ==============================================================================
# Link and Data Detection Settings
# ==============================================================================

# --- Smart Links (Data Detectors) ---
# Key:          SmartLinks
# Domain:       com.apple.TextEdit
# Description:  Controls whether TextEdit automatically detects and makes
#               URLs, email addresses, and other data clickable links. When
#               enabled, typing "http://example.com" becomes a clickable link.
# Default:      true (links are automatically detected)
# Options:      true  = Auto-detect and linkify URLs, emails, etc.
#               false = Treat all text as plain text
# Set to:       true (clickable links are convenient)
# UI Location:  Edit > Substitutions > Smart Links (toggle)
# Source:       https://support.apple.com/guide/textedit/type-special-characters-txted0d7f6/mac
# Note:         Works in both plain text and rich text mode. Links are
#               visually distinct and can be Command-clicked to open.
run_defaults "com.apple.TextEdit" "SmartLinks" "-bool" "true"

# --- Data Detectors ---
# Key:          DataDetectors
# Domain:       com.apple.TextEdit
# Description:  Controls whether TextEdit detects dates, addresses, phone
#               numbers, and other data types, allowing you to quickly add
#               them to Calendar, Contacts, or other apps. This is more
#               extensive than SmartLinks.
# Default:      true (data detection enabled)
# Options:      true  = Detect and highlight dates, addresses, phone numbers
#               false = Disable data detection
# Set to:       true (useful for quickly acting on detected data)
# UI Location:  Edit > Substitutions > Data Detectors (toggle)
# Source:       https://support.apple.com/guide/textedit/type-special-characters-txted0d7f6/mac
# Note:         Click on detected data to see action options (add to calendar,
#               create contact, etc.). Works in both plain text and rich text.
run_defaults "com.apple.TextEdit" "DataDetectors" "-bool" "true"


msg_success "TextEdit settings applied."
