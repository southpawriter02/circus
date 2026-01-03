#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Warp Terminal Configuration
#
# DESCRIPTION:
#   Documentation of Warp terminal configuration. Warp uses YAML files for
#   configuration rather than macOS defaults, stored in ~/.warp/.
#
# REQUIRES:
#   - Warp installed (https://www.warp.dev/)
#   - Configuration directory: ~/.warp/
#
# REFERENCES:
#   - Warp Documentation: https://docs.warp.dev/
#   - Warp Themes: https://docs.warp.dev/appearance/themes
#   - Warp Keybindings: https://docs.warp.dev/features/keybindings
#
# DOMAIN:
#   Configuration files in ~/.warp/
#
# NOTES:
#   - Warp does not use macOS defaults system
#   - Configuration is YAML-based
#   - Some settings sync via Warp account
#
# ==============================================================================

msg_info "Setting up Warp terminal configuration..."

# ==============================================================================
# Configuration Directory Structure
#
# ~/.warp/
# ├── themes/           # Custom theme files (.yaml)
# ├── keybindings.yaml  # Custom keybindings
# ├── launch_configurations.yaml
# └── workflows/        # Workflow definitions
#
# ==============================================================================

# Create Warp config directories if they don't exist
WARP_DIR="$HOME/.warp"
[[ -d "$WARP_DIR" ]] || mkdir -p "$WARP_DIR"
[[ -d "$WARP_DIR/themes" ]] || mkdir -p "$WARP_DIR/themes"
[[ -d "$WARP_DIR/workflows" ]] || mkdir -p "$WARP_DIR/workflows"

# ==============================================================================
# Theme Configuration
#
# Themes are stored in ~/.warp/themes/ as YAML files.
# Warp includes many built-in themes accessible via Settings > Appearance.
#
# Custom theme example (~/.warp/themes/custom.yaml):
#
# accent: '#61afef'
# background: '#282c34'
# details: darker
# foreground: '#abb2bf'
# terminal_colors:
#   normal:
#     black: '#1e2127'
#     red: '#e06c75'
#     green: '#98c379'
#     yellow: '#d19a66'
#     blue: '#61afef'
#     magenta: '#c678dd'
#     cyan: '#56b6c2'
#     white: '#abb2bf'
#   bright:
#     black: '#5c6370'
#     red: '#e06c75'
#     green: '#98c379'
#     yellow: '#d19a66'
#     blue: '#61afef'
#     magenta: '#c678dd'
#     cyan: '#56b6c2'
#     white: '#ffffff'
#
# ==============================================================================

# ==============================================================================
# Keybindings Configuration
#
# Custom keybindings in ~/.warp/keybindings.yaml:
#
# Example:
# ---
# keybindings:
#   - command: "workspace:new_tab"
#     keys: "cmd-t"
#   - command: "workspace:close_tab"
#     keys: "cmd-w"
#   - command: "workspace:split_vertically"
#     keys: "cmd-shift-d"
#   - command: "workspace:split_horizontally"
#     keys: "cmd-d"
#   - command: "terminal:clear"
#     keys: "cmd-k"
#
# See: https://docs.warp.dev/features/keybindings
#
# ==============================================================================

# ==============================================================================
# Launch Configurations
#
# Customize new session behavior in ~/.warp/launch_configurations.yaml:
#
# Example:
# ---
# name: "Default"
# shell: "/opt/homebrew/bin/zsh"
# working_directory: "~"
# environment:
#   EDITOR: "nvim"
#
# ==============================================================================

# ==============================================================================
# Workflow Configuration
#
# Warp workflows are stored in ~/.warp/workflows/ as YAML files.
# Workflows allow you to save and share command sequences.
#
# Example workflow (~/.warp/workflows/git_sync.yaml):
#
# ---
# name: "Git Sync"
# description: "Pull latest changes, update submodules"
# command: "git pull && git submodule update --init --recursive"
# tags:
#   - git
#   - sync
#
# ==============================================================================

# ==============================================================================
# Settings Overview (GUI Configuration)
#
# The following settings are configured via Warp Settings (Cmd + ,):
#
# Appearance:
# - Theme selection
# - Font family and size
# - Window opacity
# - Compact mode
# - Tab bar position
#
# Features:
# - Warp AI settings
# - Blocks (command output grouping)
# - Session restore
# - Right prompt
#
# Input:
# - Cursor style (block, underline, bar)
# - Cursor blink
# - Option key behavior
# - Mouse features
#
# SSH:
# - SSH key management
# - Connection presets
#
# Terminal:
# - Default shell
# - Working directory
# - Scrollback lines
# - Bell behavior
#
# Privacy:
# - Telemetry settings (can be disabled)
# - AI training data opt-out
#
# ==============================================================================

# ==============================================================================
# Disabling Telemetry
#
# Warp collects telemetry by default. To disable:
# 1. Open Warp Settings (Cmd + ,)
# 2. Navigate to Privacy
# 3. Disable telemetry options
#
# Note: This respects the DO_NOT_TRACK environment variable if set.
#
# ==============================================================================

# ==============================================================================
# Migration from Other Terminals
#
# Warp automatically imports settings from:
# - iTerm2 color schemes
# - Terminal.app profiles
#
# Shell configuration (.zshrc, .bashrc) works unchanged.
#
# ==============================================================================

msg_success "Warp configuration directories created."
msg_info "Configure Warp settings through the app: Cmd + ,"
msg_info "Custom themes go in: ~/.warp/themes/"
msg_info "Custom keybindings: ~/.warp/keybindings.yaml"

# ==============================================================================
# Troubleshooting
#
# Reset Warp to defaults:
#   rm -rf ~/.warp
#   (Restart Warp)
#
# Clear Warp caches:
#   rm -rf ~/Library/Caches/dev.warp.Warp-Stable
#
# View Warp logs:
#   ls ~/Library/Logs/warp/
#
# ==============================================================================
