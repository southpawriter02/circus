#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: JetBrains IDE Configuration
#
# DESCRIPTION:
#   Documentation of JetBrains IDE configuration. JetBrains IDEs (IntelliJ,
#   PyCharm, WebStorm, etc.) use XML configuration files rather than
#   macOS defaults.
#
# REQUIRES:
#   - Any JetBrains IDE installed
#   - Configuration directory varies by IDE and version
#
# REFERENCES:
#   - JetBrains: Directories used by the IDE
#     https://www.jetbrains.com/help/idea/directories-used-by-the-ide-to-store-settings-caches-plugins-and-logs.html
#   - JetBrains: Settings sync
#     https://www.jetbrains.com/help/idea/sharing-your-ide-settings.html
#
# DOMAIN:
#   Configuration files in ~/Library/Application Support/JetBrains/
#
# NOTES:
#   - JetBrains uses XML files for configuration
#   - Settings can sync via JetBrains Account
#   - Settings can be exported/imported as ZIP files
#
# ==============================================================================

msg_info "Setting up JetBrains IDE configuration..."

# ==============================================================================
# Configuration Directory Structure (macOS)
#
# ~/Library/Application Support/JetBrains/
# └── <Product><Version>/           # e.g., IntelliJIdea2024.1
#     ├── codestyles/               # Code style settings
#     ├── colors/                   # Color schemes
#     ├── fileTemplates/            # File templates
#     ├── inspection/               # Inspection profiles
#     ├── keymaps/                  # Keymap configurations
#     ├── options/                  # General settings (XML)
#     ├── scratches/                # Scratch files
#     └── templates/                # Live templates
#
# Cache location:
# ~/Library/Caches/JetBrains/<Product><Version>/
#
# Log location:
# ~/Library/Logs/JetBrains/<Product><Version>/
#
# ==============================================================================

# Define common JetBrains products
JETBRAINS_PRODUCTS=(
    "IntelliJIdea"
    "PyCharm"
    "WebStorm"
    "PhpStorm"
    "RubyMine"
    "GoLand"
    "Rider"
    "CLion"
    "DataGrip"
    "Fleet"
)

# ==============================================================================
# Settings Sync Options
#
# JetBrains provides multiple ways to sync settings:
#
# 1. JetBrains Account Sync (Recommended):
#    - Settings > Settings Sync
#    - Syncs across all JetBrains IDEs
#    - Requires JetBrains account
#
# 2. Settings Repository:
#    - Settings > Settings Repository
#    - Sync via Git repository
#    - Good for team sharing
#
# 3. Export/Import Settings:
#    - File > Manage IDE Settings > Export/Import
#    - Creates a ZIP file
#    - Manual transfer
#
# ==============================================================================

# ==============================================================================
# Key Configuration Files
#
# options/editor.xml:
#   - Font settings
#   - Line numbers
#   - Whitespace display
#
# options/ui.lnf.xml:
#   - Theme (Darcula, Light, etc.)
#   - UI font size
#
# options/keymap.xml:
#   - Active keymap
#   - Custom shortcuts
#
# options/git.xml:
#   - Git configuration
#   - Update method
#   - Push behavior
#
# options/project.default.xml:
#   - Default project settings
#
# codestyles/Default.xml:
#   - Code formatting rules
#   - Import organization
#
# ==============================================================================

# ==============================================================================
# Common Settings to Configure (via IDE Settings)
#
# Editor > General:
#   - Show line numbers: ✓
#   - Show whitespaces: ✓
#   - Ensure line feed at file end: ✓
#   - Strip trailing spaces on save: ✓
#   - Use soft wraps: ✗
#
# Editor > Font:
#   - Font: JetBrains Mono, Fira Code, or SF Mono
#   - Size: 14
#   - Line spacing: 1.2
#   - Enable ligatures: ✓
#
# Editor > Color Scheme:
#   - Choose theme (Darcula, One Dark, Dracula, etc.)
#
# Keymap:
#   - Choose base keymap (macOS, VS Code, etc.)
#
# Version Control > Git:
#   - Update method: Rebase
#   - Auto-update if push rejected: ✓
#
# Build, Execution, Deployment:
#   - Configure build tools
#   - Set up Docker integration
#
# Plugins:
#   - .env files support
#   - .gitignore
#   - Markdown
#   - Rainbow Brackets
#   - Key Promoter X
#
# ==============================================================================

# ==============================================================================
# Recommended Plugins
#
# Productivity:
# - Key Promoter X (learn shortcuts)
# - Presentation Assistant (show shortcuts)
# - String Manipulation
# - Rainbow Brackets
#
# Git:
# - GitToolBox
# - Conventional Commit
#
# Languages/Frameworks:
# - Prettier
# - ESLint
# - .env files support
#
# UI:
# - Atom Material Icons
# - One Dark Theme
# - Dracula Theme
#
# Install via: Settings > Plugins > Marketplace
#
# ==============================================================================

# ==============================================================================
# Command Line Tools
#
# Each JetBrains IDE can create command line launchers:
# Tools > Create Command-line Launcher
#
# This creates scripts in /usr/local/bin/:
# - idea (IntelliJ IDEA)
# - pycharm (PyCharm)
# - webstorm (WebStorm)
# - phpstorm (PhpStorm)
# - goland (GoLand)
# - rubymine (RubyMine)
# - rider (Rider)
# - clion (CLion)
# - datagrip (DataGrip)
#
# Usage: idea . (open current directory in IntelliJ)
#
# ==============================================================================

msg_success "JetBrains configuration documentation complete."
msg_info "Configure JetBrains IDEs through: Settings (Cmd + ,)"
msg_info "Settings location: ~/Library/Application Support/JetBrains/"
msg_info "Sync settings via JetBrains Account: Settings > Settings Sync"

# ==============================================================================
# Troubleshooting
#
# Reset IDE to defaults:
#   1. Help > Find Action > "Restore Default Settings"
#   OR
#   rm -rf "~/Library/Application Support/JetBrains/<Product><Version>"
#
# Clear caches:
#   rm -rf "~/Library/Caches/JetBrains/<Product><Version>"
#
# Invalidate caches from IDE:
#   File > Invalidate Caches > Invalidate and Restart
#
# View logs:
#   Help > Show Log in Finder
#   OR
#   ls "~/Library/Logs/JetBrains/"
#
# ==============================================================================
