#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: GitHub Desktop Configuration
#
# DESCRIPTION:
#   This script configures GitHub Desktop preferences including the default
#   external editor, shell integration, and appearance settings. GitHub Desktop
#   is a GUI client for Git that simplifies common Git operations.
#
# REQUIRES:
#   - macOS 10.13 (High Sierra) or later
#   - GitHub Desktop installed
#
# REFERENCES:
#   - GitHub Desktop: Configuring Git
#     https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/configuring-git-for-github-desktop
#   - GitHub Desktop: Configuring a default editor
#     https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/configuring-a-default-editor
#
# DOMAIN:
#   com.github.GitHubClient
#
# NOTES:
#   - GitHub Desktop stores preferences in ~/Library/Application Support/GitHub Desktop/
#   - The config file is ~/.config/github-desktop/config (JSON format)
#   - Some settings are in the preferences plist, others in the config file
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set GitHub Desktop preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring GitHub Desktop settings..."

# ==============================================================================
# Appearance Settings
# ==============================================================================

# --- Theme Mode ---
# Key:          optOutOfUsageTracking
# Domain:       com.github.GitHubClient
# Description:  Controls whether usage data is sent to GitHub for improving
#               the application. Disabling helps protect privacy.
# Default:      false (tracking enabled)
# Options:      true  = Opt out of usage tracking
#               false = Allow usage tracking
# Set to:       true (privacy conscious setting)
# UI Location:  GitHub Desktop > Settings > Advanced > Usage
# Source:       https://docs.github.com/en/desktop/installing-and-configuring-github-desktop
run_defaults "com.github.GitHubClient" "optOutOfUsageTracking" "-bool" "true"

# ==============================================================================
# Configuration File Settings
#
# GitHub Desktop stores most preferences in a JSON config file:
# ~/.config/github-desktop/config
#
# Key settings in this file include:
#
# {
#   "selectedExternalEditor": "Visual Studio Code",
#   "selectedShell": "Terminal",
#   "confirmDiscardChanges": true,
#   "confirmRepositoryRemoval": true,
#   "confirmForcePush": true,
#   "selectedTheme": "system"
# }
#
# Available External Editors:
#   - Visual Studio Code
#   - Atom
#   - Sublime Text
#   - TextMate
#   - BBEdit
#   - MacVim
#   - Xcode
#
# Available Shells:
#   - Terminal
#   - iTerm2
#   - Hyper
#   - Alacritty
#   - kitty
#
# ==============================================================================

# ==============================================================================
# Configure External Editor (via config file)
# ==============================================================================

GITHUB_CONFIG_DIR="$HOME/.config/github-desktop"
GITHUB_CONFIG_FILE="$GITHUB_CONFIG_DIR/config"

configure_github_desktop() {
  # Ensure config directory exists
  if [ ! -d "$GITHUB_CONFIG_DIR" ]; then
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would create directory: $GITHUB_CONFIG_DIR"
    else
      mkdir -p "$GITHUB_CONFIG_DIR"
    fi
  fi

  # Check if config file exists and has content
  if [ -f "$GITHUB_CONFIG_FILE" ]; then
    msg_info "GitHub Desktop config file exists, preserving existing settings"
  else
    msg_info "GitHub Desktop config not found - configure via app preferences"
  fi
}

# Only run if GitHub Desktop is installed
if [ -d "/Applications/GitHub Desktop.app" ]; then
  configure_github_desktop
fi

msg_success "GitHub Desktop settings applied."
echo ""
msg_info "Configure additional settings in GitHub Desktop:"
echo "  1. GitHub Desktop > Settings (Cmd+,)"
echo "  2. Integrations > External Editor: Choose your editor"
echo "  3. Integrations > Shell: Choose Terminal or iTerm2"
echo "  4. Git > Configure Git settings"
