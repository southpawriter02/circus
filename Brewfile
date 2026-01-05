# ==============================================================================
#
# FILE:         Brewfile
#
# DESCRIPTION:  This is the base Brewfile. It lists all the Homebrew packages
#               that should be installed for ALL roles.
#
# ==============================================================================

# --- Cask Arguments ---------------------------------------------------------
# Configure where cask applications and components are installed.

cask_args language: "en"
cask_args appdir: "/Applications"
cask_args input_methoddir: "~/Library/Input Methods"
cask_args keyboard_layoutdir: "~/Library/Keyboard Layouts"
cask_args colorpickerdir: "~/Library/ColorPickers"
cask_args prefpanedir: "~/Library/PreferencePanes"
cask_args qlplugindir: "~/Library/QuickLook"
cask_args mdimporterdir: "~/Library/Spotlight"
cask_args dictionarydir: "~/Library/Dictionaries"
cask_args fontdir: "~/Library/Fonts"
cask_args servicedir: "~/Library/Services"
cask_args internet_plugindir: "~/Library/Internet Plug-Ins"
cask_args audio_unit_plugindir: "~/Library/Audio/Plug-Ins/Components"
cask_args vst_plugindir: "~/Library/Audio/Plug-Ins/VST"
cask_args vst3_plugindir: "~/Library/Audio/Plug-Ins/VST3"
cask_args screen_saverdir: "~/Library/Screen Savers"

# --- Taps -------------------------------------------------------------------
# Add external repositories here if needed.

tap "homebrew/bundle"
tap "homebrew/cask-fonts"
tap "homebrew/services"

# --- Core Formulae ----------------------------------------------------------

# -- Shell & Core Utilities --

# Core Unix utilities (gls, gcat, etc.)
brew "coreutils"

# Additional GNU find utilities
brew "findutils"

# The Zsh shell
brew "zsh"

# Zsh completions
brew "zsh-completions"

# The Bash shell
brew "bash"

# Bash completion
brew "bash-completion@2"

# Static analysis for shell scripts
brew "shellcheck"

# Directory tree viewer
brew "tree"

# macOS command line tools (Swiss Army knife for macOS)
brew "m-cli"

# TLDR pages - simplified man pages
brew "tlrc"

# Move files to trash from CLI
brew "macos-trash"

# -- Version Control --

# Distributed version control
brew "git"

# GitHub CLI
brew "gh"

# -- Package Management --

# Mac App Store CLI (for fc-apps command)
brew "mas"

# Keep application settings in sync
brew "mackup"

# -- File & Text Processing --

# Modern cat with syntax highlighting
brew "bat"

# Modern ls replacement
brew "eza"

# Fast file finder
brew "fd"

# Fast grep replacement
brew "ripgrep"

# JSON processor
brew "jq"

# Fuzzy finder
brew "fzf"

# -- Networking --

# Download utility
brew "wget"

# HTTP client
brew "curl"

# -- Compression --

# Modern compression
brew "zstd"

# 7-zip support
brew "p7zip"

# --- MAS Apps (Mac App Store) -----------------------------------------------
# MAS apps are listed before casks so they take precedence if available in both.

# -- Security --

# Password manager (primary)
mas "1Password", id: 443987910

# Password manager (alternative)
mas "Bitwarden", id: 1352778147

# -- Productivity --

# Keep Mac awake
mas "Amphetamine", id: 937984704

# Calendar app
mas "Fantastical", id: 975937182

# --- Casks (GUI Applications) -----------------------------------------------
# Only apps that should be installed for ALL roles belong here.
# Role-specific apps go in roles/*/Brewfile.

# -- Security & Privacy --

# GPG Suite for signing commits
cask "gpg-suite"

# Network monitor and firewall
cask "little-snitch"

# Password manager (standalone, for non-MAS)
cask "keepassxc"

# Malware scanner - shows persistent items
cask "knockknock"

# YubiKey authentication
cask "yubico-authenticator"

# -- Browsers --

# A modern web browser
cask "google-chrome"

# -- Productivity --

# Launcher and productivity tool
cask "raycast"

# -- Cloud & Sync --

# Backup utility
cask "carbon-copy-cloner"

# Cloud storage and sync
cask "dropbox"

# -- System Utilities --

# System diagnostic tool
cask "etrecheckpro"

# macOS preferences editor
cask "prefs-editor"

# --- Fonts (Casks) ---------------------------------------------------------
# Essential fonts for all roles. Role-specific fonts in roles/*/Brewfile.

# Monospace coding font with ligatures
cask "font-fira-code"

# JetBrains monospace font
cask "font-jetbrains-mono"

# Apple-style monospace font
cask "font-sf-mono"

# Clean sans-serif for UI
cask "font-inter"
