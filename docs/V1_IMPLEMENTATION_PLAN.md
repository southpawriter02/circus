# v1.0 Implementation Plan

This document provides a detailed, actionable implementation plan for achieving a polished v1.0 release. It addresses the five technical debt areas identified in the settings roadmap.

---

## Executive Summary

| Area | Current | Target | Gap | Est. Hours |
|------|---------|--------|-----|------------|
| Environment Variables | 7 files | 20 files | +13 files | 8-12 |
| macOS Defaults | 22 scripts | 45 scripts | +23 scripts | 20-30 |
| Shell Profile Structure | Minimal | Complete | 4 new files | 4-6 |
| Role-Specific Settings | Brewfiles only | Full config | +15 files | 10-15 |
| Documentation | ~50% | 100% | ~12 scripts | 8-12 |
| **Total** | — | — | — | **50-75 hrs** |

**Timeline**: At 5-10 hours/week → **5-15 weeks** to complete.

---

## Work Packages

The work is organized into **5 work packages (WP)**, each addressing one technical debt area. Each WP is broken into **bites** of 1-3 hours.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           WORK PACKAGE FLOW                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  WP1: Shell         WP2: Environment      WP3: macOS         WP4: Roles    │
│  Profiles           Variables             Defaults           Settings      │
│  (Foundation)       (Builds on WP1)       (Independent)      (After WP1-2) │
│       │                   │                     │                 │        │
│       └───────────────────┴─────────────────────┴─────────────────┘        │
│                                     │                                       │
│                                     ▼                                       │
│                            WP5: Documentation                               │
│                            (Runs in parallel)                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## WP1: Shell Profile Structure

**Goal**: Establish proper shell startup file structure with clean PATH management.

**Dependency**: None (do this first)

**Current State**:
- `profiles/base/zsh/zshrc.symlink` → `~/.zshrc`
- Oh My Zsh plugin loads env files
- No `.zprofile`, `.zshenv`, or `.zlogout`
- PATH modifications scattered

### Bite 1.1: Create .zprofile (2 hrs)

**File**: `profiles/base/zsh/zprofile.symlink` → `~/.zprofile`

**Purpose**: Login shell initialization. Runs once per login session.

```bash
#!/usr/bin/env zsh
# ==============================================================================
# .zprofile - Login Shell Configuration
#
# This file runs for login shells (Terminal.app, SSH) before .zshrc.
# Put environment variables here that don't change during a session.
# ==============================================================================

# Homebrew PATH (must be first for ARM Macs)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Load all environment files from circus plugin
# (This sources the env/*.sh files)
if [[ -d "$ZSH_CUSTOM/circus/env" ]]; then
    for env_file in "$ZSH_CUSTOM/circus/env"/*.sh; do
        [[ -r "$env_file" ]] && source "$env_file"
    done
fi

# Load role-specific environment if set
if [[ -n "$CIRCUS_ROLE" && -d "$CIRCUS_DIR/roles/$CIRCUS_ROLE/env" ]]; then
    for env_file in "$CIRCUS_DIR/roles/$CIRCUS_ROLE/env"/*.sh; do
        [[ -r "$env_file" ]] && source "$env_file"
    done
fi

# Load local overrides (not tracked in git)
[[ -f "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
```

**Tasks**:
- [ ] Create `zprofile.symlink`
- [ ] Add to installer stage for symlinking
- [ ] Test login shell initialization
- [ ] Document in shell profile reference

### Bite 1.2: Create .zshenv (1 hr)

**File**: `profiles/base/zsh/zshenv.symlink` → `~/.zshenv`

**Purpose**: Runs for ALL shells including non-interactive scripts. Keep minimal!

```bash
#!/usr/bin/env zsh
# ==============================================================================
# .zshenv - Environment for All Shells
#
# WARNING: This runs for EVERY shell, including scripts!
# Only put critical PATH entries here. Keep it fast and minimal.
# ==============================================================================

# Ensure Homebrew is in PATH for scripts
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [[ -f "/usr/local/bin/brew" ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# Circus directory (needed for scripts that use fc)
export CIRCUS_DIR="${CIRCUS_DIR:-$HOME/.dotfiles}"
```

**Tasks**:
- [ ] Create `zshenv.symlink`
- [ ] Add to installer
- [ ] Test that scripts can find Homebrew binaries
- [ ] Verify no slowdown in shell startup

### Bite 1.3: Create .zlogout (30 min)

**File**: `profiles/base/zsh/zlogout.symlink` → `~/.zlogout`

**Purpose**: Cleanup when logging out of a login shell.

```bash
#!/usr/bin/env zsh
# ==============================================================================
# .zlogout - Logout Cleanup
#
# Runs when a login shell exits. Use for cleanup tasks.
# ==============================================================================

# Clear sensitive environment variables
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset GITHUB_TOKEN

# Clear clipboard if it contains a password (optional)
# pbcopy < /dev/null

# Custom logout message (optional)
# echo "Goodbye!"
```

**Tasks**:
- [ ] Create `zlogout.symlink`
- [ ] Add to installer
- [ ] Test logout behavior

### Bite 1.4: Create path.env.sh (1.5 hrs)

**File**: `profiles/base/zsh/oh-my-zsh-custom/circus/env/path.env.sh`

**Purpose**: Centralized PATH management. All PATH additions go here.

```bash
# ==============================================================================
# PATH Management
#
# This file consolidates all PATH additions.
# Order matters: later entries take precedence.
# ==============================================================================

# Helper function to add to PATH (avoids duplicates)
path_prepend() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

path_append() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$PATH:$1"
}

# --- User binaries (highest priority) ---
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# --- Language-specific paths ---
# Go
path_prepend "$HOME/go/bin"

# Rust
path_prepend "$HOME/.cargo/bin"

# Node (via nvm - handled by nvm.sh)
# Python (via pyenv - if installed)
[[ -d "$HOME/.pyenv/bin" ]] && path_prepend "$HOME/.pyenv/bin"

# Ruby (via rbenv - if installed)
[[ -d "$HOME/.rbenv/bin" ]] && path_prepend "$HOME/.rbenv/bin"

# --- Tool-specific paths ---
# VS Code CLI
path_append "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Rancher Desktop
path_append "$HOME/.rd/bin"

# Export the modified PATH
export PATH
```

**Tasks**:
- [ ] Create `path.env.sh`
- [ ] Audit existing env files for PATH modifications
- [ ] Consolidate all PATH additions
- [ ] Remove duplicates from other env files
- [ ] Test PATH is correct after login

### Bite 1.5: Update installer symlink stage (1 hr)

**Tasks**:
- [ ] Modify `install/06-symlink-dotfiles.sh` to handle new files
- [ ] Ensure `.zprofile`, `.zshenv`, `.zlogout` are symlinked
- [ ] Test fresh install creates all symlinks
- [ ] Test `fc update` handles new symlinks

---

## WP2: Environment Variables

**Goal**: Expand from 7 to 20 environment variable files covering all common use cases.

**Dependency**: WP1 (path.env.sh pattern established)

**Current State**:
```
env/
├── brew.env.sh     ✅
├── curl.env.sh     ✅
├── editor.env.sh   ✅
├── folders.env.sh  ✅
├── git.env.sh      ✅
├── history.env.sh  ✅
└── locale.env.sh   ✅
```

### Bite 2.1: Security & Privacy (2 hrs)

Create files for security agents and privacy opt-outs.

**File**: `security.env.sh`
```bash
# ==============================================================================
# Security Agent Configuration
# ==============================================================================

# GPG TTY for passphrase prompts
export GPG_TTY=$(tty)

# SSH agent - use macOS Keychain
# (Comment out if using 1Password SSH agent)
# export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

# GnuPG home directory
export GNUPGHOME="${GNUPGHOME:-$HOME/.gnupg}"
```

**File**: `telemetry.env.sh`
```bash
# ==============================================================================
# Telemetry Opt-Outs
#
# Disable analytics and telemetry for various CLI tools.
# ==============================================================================

# Universal opt-out signal
export DO_NOT_TRACK=1

# Homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1

# .NET
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Node.js ecosystem
export NEXT_TELEMETRY_DISABLED=1
export GATSBY_TELEMETRY_DISABLED=1
export NUXT_TELEMETRY_DISABLED=1
export ASTRO_TELEMETRY_DISABLED=1

# Cloud CLIs
export AZURE_CORE_COLLECT_TELEMETRY=0
export SAM_CLI_TELEMETRY=0

# Other tools
export CHECKPOINT_DISABLE=1          # HashiCorp
export HASURA_GRAPHQL_ENABLE_TELEMETRY=false
```

**Tasks**:
- [ ] Create `security.env.sh`
- [ ] Create `telemetry.env.sh`
- [ ] Research additional telemetry opt-outs
- [ ] Test GPG signing works

### Bite 2.2: Terminal Appearance (1.5 hrs)

**File**: `colors.env.sh`
```bash
# ==============================================================================
# Terminal Colors
# ==============================================================================

# Enable colors in terminal
export CLICOLOR=1
export CLICOLOR_FORCE=1

# BSD ls colors (macOS)
export LSCOLORS="exfxcxdxbxegedabagacad"

# GNU ls colors (for GNU coreutils if installed)
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# GCC colors for compiler warnings/errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Grep colors
export GREP_COLORS='ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'
```

**File**: `pager.env.sh`
```bash
# ==============================================================================
# Pager Configuration
# ==============================================================================

# Less options:
#   -R : Output raw control characters (colors)
#   -F : Quit if content fits on one screen
#   -X : Don't clear screen on exit
#   -S : Chop long lines (don't wrap)
#   -i : Ignore case in searches (unless uppercase used)
export LESS="-RFXSi"

# Less input preprocessor (for viewing compressed files, etc.)
# Requires lesspipe: brew install lesspipe
[[ -x /opt/homebrew/bin/lesspipe.sh ]] && export LESSOPEN="|/opt/homebrew/bin/lesspipe.sh %s"

# Man pages pager
export MANPAGER="less -X"

# Bat (cat replacement) configuration
export BAT_THEME="TwoDark"
export BAT_STYLE="numbers,changes,header"
```

**Tasks**:
- [ ] Create `colors.env.sh`
- [ ] Create `pager.env.sh`
- [ ] Test colors work in Terminal.app and iTerm2
- [ ] Test `man` pages look good

### Bite 2.3: Development Languages (3 hrs)

Create env files for Python, Node, Go, Rust, Java.

**File**: `python.env.sh`
```bash
# ==============================================================================
# Python Configuration
# ==============================================================================

# Don't write .pyc bytecode files
export PYTHONDONTWRITEBYTECODE=1

# Force unbuffered stdout/stderr (useful for Docker, logging)
export PYTHONUNBUFFERED=1

# Require virtual environment for pip install
# Prevents accidental global installs
export PIP_REQUIRE_VIRTUALENV=true

# Let the shell prompt handle virtualenv display
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Pipenv: create virtualenv in project directory
export PIPENV_VENV_IN_PROJECT=1

# Poetry: create virtualenv in project directory
export POETRY_VIRTUALENVS_IN_PROJECT=true

# Python history file
export PYTHONSTARTUP="${PYTHONSTARTUP:-$HOME/.pythonrc}"
```

**File**: `node.env.sh`
```bash
# ==============================================================================
# Node.js Configuration
# ==============================================================================

# Increase Node.js memory limit (default 512MB is often too low)
export NODE_OPTIONS="--max-old-space-size=4096"

# npm global prefix (avoid system directories)
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
path_append "$NPM_CONFIG_PREFIX/bin"

# Node REPL history file
export NODE_REPL_HISTORY="$HOME/.node_repl_history"

# Disable npm update notifier (annoying in scripts)
export NO_UPDATE_NOTIFIER=1

# pnpm home
export PNPM_HOME="$HOME/.local/share/pnpm"
path_append "$PNPM_HOME"
```

**File**: `go.env.sh`
```bash
# ==============================================================================
# Go Configuration
# ==============================================================================

# Go workspace
export GOPATH="${GOPATH:-$HOME/go}"

# Go binaries
export GOBIN="$GOPATH/bin"

# Go module proxy (faster downloads)
export GOPROXY="https://proxy.golang.org,direct"

# Enable Go modules
export GO111MODULE=on

# Add Go bin to PATH (handled in path.env.sh)
```

**File**: `rust.env.sh`
```bash
# ==============================================================================
# Rust Configuration
# ==============================================================================

# Cargo home directory
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

# Rustup home directory
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"

# Add cargo bin to PATH (handled in path.env.sh)
```

**File**: `java.env.sh`
```bash
# ==============================================================================
# Java Configuration
# ==============================================================================

# Auto-detect JAVA_HOME using macOS java_home utility
if [[ -x /usr/libexec/java_home ]] && /usr/libexec/java_home &>/dev/null; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Maven settings
export MAVEN_OPTS="-Xmx2048m"

# Gradle settings
export GRADLE_OPTS="-Xmx2048m -Dorg.gradle.daemon=true"
```

**Tasks**:
- [ ] Create `python.env.sh`
- [ ] Create `node.env.sh`
- [ ] Create `go.env.sh`
- [ ] Create `rust.env.sh`
- [ ] Create `java.env.sh`
- [ ] Test each language environment
- [ ] Ensure PATH additions don't duplicate

### Bite 2.4: DevOps & Cloud (2 hrs)

**File**: `docker.env.sh`
```bash
# ==============================================================================
# Docker Configuration
# ==============================================================================

# Enable BuildKit (much faster builds)
export DOCKER_BUILDKIT=1

# Use BuildKit for docker-compose
export COMPOSE_DOCKER_CLI_BUILD=1

# Disable Docker scan suggestions
export DOCKER_SCAN_SUGGEST=false

# Docker config directory
export DOCKER_CONFIG="${DOCKER_CONFIG:-$HOME/.docker}"
```

**File**: `cloud.env.sh`
```bash
# ==============================================================================
# Cloud CLI Configuration
#
# Note: Credentials should NOT be stored here.
# Use `fc fc-secrets` or cloud CLI login commands.
# ==============================================================================

# AWS
export AWS_PAGER=""  # Disable paging in AWS CLI

# GCP
export CLOUDSDK_PYTHON="python3"

# Azure
export AZURE_CORE_OUTPUT="table"  # Default output format
```

**File**: `kubernetes.env.sh`
```bash
# ==============================================================================
# Kubernetes Configuration
# ==============================================================================

# Default kubeconfig location
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# kubectl editor
export KUBE_EDITOR="${KUBE_EDITOR:-$EDITOR}"

# Helm
export HELM_HOME="${HELM_HOME:-$HOME/.helm}"
```

**Tasks**:
- [ ] Create `docker.env.sh`
- [ ] Create `cloud.env.sh`
- [ ] Create `kubernetes.env.sh`
- [ ] Test Docker builds use BuildKit
- [ ] Verify AWS CLI doesn't page

### Bite 2.5: XDG Base Directories (1 hr)

**File**: `xdg.env.sh`
```bash
# ==============================================================================
# XDG Base Directory Specification
#
# See: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
#
# Many modern tools respect these variables. Setting them helps keep your
# home directory clean by moving config/data/cache to standard locations.
# ==============================================================================

# Configuration files (like settings, preferences)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Data files (like databases, persistent state)
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Cache files (safe to delete)
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# State files (logs, history - persists between restarts)
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Runtime files (sockets, named pipes - cleared on reboot)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"

# Create directories if they don't exist
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"
```

**Tasks**:
- [ ] Create `xdg.env.sh`
- [ ] Document which tools respect XDG
- [ ] Consider making this opt-in

---

## WP3: macOS Defaults

**Goal**: Expand from 22 to 45+ defaults scripts with complete documentation.

**Dependency**: None (can run in parallel with WP1/WP2)

**Current State**:
```
defaults/
├── applications/     9 scripts (5 need docs)
├── input/            2 scripts (complete)
├── interface/        5 scripts (1 needs docs)
├── profiles/         4 scripts
└── system/           6 scripts (4 need docs)
```

### Bite 3.1: Privacy & Security Defaults (3 hrs)

High-priority security defaults.

**File**: `system/privacy.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: Privacy & Analytics
#
# DESCRIPTION:
#   Configures privacy settings to limit data collection and sharing.
#
# DOMAIN:
#   com.apple.assistant.support (Siri)
#   com.apple.CrashReporter
#   com.apple.AdLib
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

# --- Disable Analytics Sharing ---
# Key:          AutoSubmit
# Description:  Share crash and usage data with Apple
# Default:      1 (enabled)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       0 (don't share)
# UI Location:  System Settings > Privacy & Security > Analytics & Improvements
run_defaults "com.apple.CrashReporter" "DialogType" "-string" "none"

# --- Disable Personalized Ads ---
# Key:          allowApplePersonalizedAdvertising
# Description:  Allow Apple to use your data for personalized ads
# Default:      1 (enabled)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       0 (no personalized ads)
# UI Location:  System Settings > Privacy & Security > Apple Advertising
run_defaults "com.apple.AdLib" "allowApplePersonalizedAdvertising" "-bool" "false"

# --- Disable Siri Analytics ---
# Key:          Siri Data Sharing Opt-In Status
# Description:  Share Siri recordings with Apple for improvement
# Default:      varies
# Set to:       2 (opted out)
run_defaults "com.apple.assistant.support" "Siri Data Sharing Opt-In Status" "-int" "2"
```

**File**: `system/gatekeeper.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: Gatekeeper & Security
#
# DESCRIPTION:
#   Configures Gatekeeper settings for app security.
#   Requires sudo for some settings.
#
# DOMAIN:
#   com.apple.LaunchServices
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

# --- Disable Quarantine Warning for Downloaded Apps ---
# Key:          LSQuarantine
# Description:  Show warning dialog when opening downloaded files
# Default:      true
# Options:      true = Show warning, false = Don't show
# Set to:       false (power user setting - understand the risk!)
# UI Location:  No direct UI equivalent
# Note:         This removes the "Are you sure you want to open this?"
run_defaults "com.apple.LaunchServices" "LSQuarantine" "-bool" "false"
```

**Tasks**:
- [ ] Create `system/privacy.sh`
- [ ] Create `system/gatekeeper.sh`
- [ ] Add settings to lockdown profile
- [ ] Test all privacy settings apply

### Bite 3.2: Energy & Power (2 hrs)

**File**: `system/energy.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: Energy & Power Management
#
# DESCRIPTION:
#   Configures power management settings. Uses pmset for most settings.
#   Requires sudo.
#
# REQUIRES:
#   - sudo access for pmset commands
#
# REFERENCES:
#   - man pmset
#   - https://support.apple.com/guide/mac-help/mchl55185cb2/mac
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

# Note: These use pmset, not defaults

# --- Display Sleep (Battery) ---
# Set display to sleep after 5 minutes on battery
# Options: 0 = never, 1-180 = minutes
sudo pmset -b displaysleep 5

# --- Display Sleep (Power Adapter) ---
# Set display to sleep after 15 minutes on power
sudo pmset -c displaysleep 15

# --- Computer Sleep (Battery) ---
# Set computer to sleep after 10 minutes on battery
sudo pmset -b sleep 10

# --- Computer Sleep (Power Adapter) ---
# Set computer to sleep after 30 minutes on power
sudo pmset -c sleep 30

# --- Disable Power Nap (Battery) ---
# Power Nap wakes computer periodically for updates
# Set to 0 to save battery
sudo pmset -b powernap 0

# --- Enable Power Nap (Power Adapter) ---
sudo pmset -c powernap 1

# --- Wake on LAN (Power Adapter only) ---
# Wake computer for network access
sudo pmset -c womp 1

# --- Disable Wake on LAN (Battery) ---
sudo pmset -b womp 0
```

**Tasks**:
- [ ] Create `system/energy.sh`
- [ ] Handle sudo requirement gracefully
- [ ] Test on both laptop and desktop
- [ ] Document battery vs AC differences

### Bite 3.3: Interface Defaults - Menu Bar (2 hrs)

**File**: `interface/menu_bar.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: Menu Bar
#
# DESCRIPTION:
#   Configures menu bar appearance and clock settings.
#
# DOMAIN:
#   com.apple.menuextra.clock
#   com.apple.menuextra.battery
#   com.apple.controlcenter
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

# --- Clock Format ---
# Key:          DateFormat
# Description:  Format string for menu bar clock
# Default:      "EEE MMM d  h:mm a"
# Set to:       24-hour format with seconds
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "DateFormat" "-string" "EEE d MMM HH:mm:ss"

# --- Show Date in Menu Bar ---
# Key:          ShowDate
# Description:  Show the date in the menu bar clock
# Default:      1 (when space allows)
# Options:      0 = Never, 1 = When space allows, 2 = Always
# Set to:       2 (always show date)
run_defaults "com.apple.menuextra.clock" "ShowDate" "-int" "2"

# --- Show Day of Week ---
# Key:          ShowDayOfWeek
# Description:  Show day of week in clock
# Default:      true
# Set to:       true
run_defaults "com.apple.menuextra.clock" "ShowDayOfWeek" "-bool" "true"

# --- Show Battery Percentage ---
# Key:          ShowPercent
# Description:  Show battery percentage in menu bar
# Default:      false
# Set to:       true
run_defaults "com.apple.menuextra.battery" "ShowPercent" "-bool" "true"

# --- Flash Time Separators ---
# Key:          FlashDateSeparators
# Description:  Blink the colon every second
# Default:      false
# Set to:       false (annoying!)
run_defaults "com.apple.menuextra.clock" "FlashDateSeparators" "-bool" "false"
```

**Tasks**:
- [ ] Create `interface/menu_bar.sh`
- [ ] Test on macOS Sonoma/Sequoia
- [ ] Verify Control Center integration

### Bite 3.4: User-Requested Applications (5 hrs)

Create defaults for user-requested applications.

**File**: `applications/mail.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: Apple Mail
#
# DESCRIPTION:
#   Configures Apple Mail settings for privacy and efficiency.
#
# DOMAIN:
#   com.apple.mail
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

# --- Disable Remote Content Loading ---
# Key:          DisableURLLoading
# Description:  Block remote images (tracking pixels) in emails
# Default:      false (loads remote content)
# Set to:       true (privacy protection)
# UI Location:  Mail > Settings > Privacy > Protect Mail Activity
run_defaults "com.apple.mail" "DisableURLLoading" "-bool" "true"

# --- Copy Addresses as Full Name + Email ---
# Key:          AddressesIncludeNameOnPasteboard
# Description:  When copying email address, include full name
# Default:      false
# Set to:       true
run_defaults "com.apple.mail" "AddressesIncludeNameOnPasteboard" "-bool" "true"

# --- Display Emails in Threaded Mode ---
# Key:          ConversationViewEnabled
# Description:  Group related emails into conversations
# Default:      true
# Set to:       true
run_defaults "com.apple.mail" "ConversationViewEnabled" "-bool" "true"

# --- Disable Inline Attachments ---
# Key:          DisableInlineAttachmentViewing
# Description:  Show attachments as icons instead of inline
# Default:      false
# Set to:       true (cleaner view)
run_defaults "com.apple.mail" "DisableInlineAttachmentViewing" "-bool" "true"
```

**File**: `applications/messages.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: Messages
#
# DESCRIPTION:
#   Configures Messages app settings.
#
# DOMAIN:
#   com.apple.MobileSMS
#   com.apple.iChat
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

# Note: Many Messages settings require iCloud and are synced, 
# not stored in local defaults.

# Messages doesn't have many configurable defaults via command line.
# Most settings are UI-only or iCloud-synced.

log_info "Messages settings are primarily configured via the app UI"
log_info "Key privacy settings to configure manually:"
log_info "  - Read Receipts: Messages > Settings > iMessage"
log_info "  - Share Name and Photo: Messages > Settings > Shared with You"
```

**File**: `applications/warp.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: Warp Terminal
#
# DESCRIPTION:
#   Configures Warp terminal settings.
#   Warp stores settings in YAML files, not defaults.
#
# CONFIG LOCATION:
#   ~/.warp/
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

log_info "Warp uses YAML configuration, not macOS defaults"
log_info "Configuration location: ~/.warp/"
log_info ""
log_info "Key files:"
log_info "  - ~/.warp/themes/     Custom themes"
log_info "  - ~/.warp/keybindings.yaml"
log_info ""
log_info "Consider adding Warp config to your dotfiles symlinks"
```

**File**: `applications/jetbrains.sh`
```bash
#!/usr/bin/env bash
# ==============================================================================
# macOS Defaults: JetBrains IDEs
#
# DESCRIPTION:
#   JetBrains IDEs store settings in their own XML format.
#   This script documents the configuration approach.
#
# CONFIG LOCATIONS:
#   ~/Library/Application Support/JetBrains/<IDE><version>/
#   ~/.ideavimrc (for IdeaVim plugin)
#
# SYNC OPTIONS:
#   1. JetBrains Settings Sync (built-in)
#   2. Settings Repository plugin (git-based)
#   3. Manual symlink of config directories
# ==============================================================================

source "${CIRCUS_DIR:-$HOME/.dotfiles}/lib/helpers.sh"

log_info "JetBrains IDEs use XML configuration, not macOS defaults"
log_info ""
log_info "Configuration sync options:"
log_info "  1. Settings Sync: File > Manage IDE Settings > Settings Sync"
log_info "  2. Settings Repository: Install plugin, point to git repo"
log_info "  3. Manual: Symlink ~/Library/Application Support/JetBrains/"
log_info ""
log_info "Memory settings: Edit ~/Library/Application Support/JetBrains/<IDE>/idea.vmoptions"
log_info "  -Xms1024m"
log_info "  -Xmx4096m"
```

**Tasks**:
- [ ] Create `applications/mail.sh`
- [ ] Create `applications/messages.sh` (mostly documentation)
- [ ] Create `applications/warp.sh` (config file approach)
- [ ] Create `applications/jetbrains.sh` (documentation)
- [ ] Create `applications/dropbox.sh`
- [ ] Create `applications/notion.sh`
- [ ] Create `applications/github_desktop.sh`

### Bite 3.5: Remaining System Defaults (4 hrs)

**Files to create**:
- `system/sound.sh` - Alert sounds, UI sounds
- `system/bluetooth.sh` - Discoverable mode, menu bar
- `system/spotlight.sh` - Index categories, exclusions
- `system/airdrop.sh` - Discoverability
- `system/siri.sh` - Enable/disable, suggestions
- `system/login.sh` - Login window settings

**Tasks**:
- [ ] Create each file with proper documentation
- [ ] Test on clean macOS install
- [ ] Add to appropriate privacy profiles

### Bite 3.6: Interface & Desktop (3 hrs)

**Files to create**:
- `interface/notifications.sh` - Preview, grouping
- `interface/desktop.sh` - Icons, stacks
- `interface/window_management.sh` - Double-click, minimize
- `interface/control_center.sh` - Visible modules

### Bite 3.7: Accessibility (2 hrs)

**Create new directory**: `defaults/accessibility/`

**Files to create**:
- `accessibility/display.sh` - Reduce motion, transparency
- `accessibility/pointer.sh` - Cursor size, shake to locate
- `accessibility/zoom.sh` - Scroll gesture zoom
- `accessibility/audio.sh` - Flash screen, mono audio

---

## WP4: Role-Specific Settings

**Goal**: Expand roles from Brewfiles-only to full environment/defaults.

**Dependency**: WP1, WP2 (env file patterns established)

### Bite 4.1: Developer Role - Environment (2 hrs)

**Structure**:
```
roles/developer/
├── Brewfile              ✅ Exists
├── aliases/
│   ├── git.aliases.sh    🆕 New
│   └── docker.aliases.sh 🆕 New
├── defaults/
│   └── xcode.sh          🆕 New
└── env/
    ├── development.env.sh 🆕 New
    └── debugging.env.sh   🆕 New
```

**File**: `roles/developer/aliases/git.aliases.sh`
```bash
# ==============================================================================
# Git Aliases (Developer Role)
# ==============================================================================

alias g='git'
alias gst='git status'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gm='git merge'
alias gr='git rebase'
alias gri='git rebase -i'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline -20'
alias gla='git log --oneline --all --graph'
alias gclean='git clean -fd'
alias greset='git reset --hard HEAD'
```

**File**: `roles/developer/env/development.env.sh`
```bash
# ==============================================================================
# Development Environment (Developer Role)
# ==============================================================================

# Preferred editors
export EDITOR="${EDITOR:-code --wait}"
export VISUAL="${VISUAL:-code --wait}"
export GIT_EDITOR="${GIT_EDITOR:-code --wait}"

# Pager for git
export GIT_PAGER="less -FRX"

# Projects directory
export PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
```

**Tasks**:
- [ ] Create `roles/developer/aliases/git.aliases.sh`
- [ ] Create `roles/developer/aliases/docker.aliases.sh`
- [ ] Create `roles/developer/env/development.env.sh`
- [ ] Create `roles/developer/env/debugging.env.sh`
- [ ] Create `roles/developer/defaults/xcode.sh`
- [ ] Test role switching loads aliases

### Bite 4.2: Work Role - Environment (2 hrs)

**Structure**:
```
roles/work/
├── Brewfile              ✅ Exists
├── defaults/
│   ├── security.sh       🆕 New (stricter)
│   └── calendar.sh       🆕 New
└── env/
    ├── corporate.env.sh  🆕 New
    └── vpn.env.sh        🆕 New
```

**File**: `roles/work/env/corporate.env.sh`
```bash
# ==============================================================================
# Corporate Environment (Work Role)
#
# Proxy and enterprise-specific settings.
# Uncomment and configure as needed for your organization.
# ==============================================================================

# HTTP Proxy (uncomment if needed)
# export HTTP_PROXY="http://proxy.company.com:8080"
# export HTTPS_PROXY="http://proxy.company.com:8080"
# export NO_PROXY="localhost,127.0.0.1,.company.com"

# npm enterprise registry
# export NPM_CONFIG_REGISTRY="https://npm.company.com/"

# pip enterprise index
# export PIP_INDEX_URL="https://pypi.company.com/simple/"
```

**Tasks**:
- [ ] Create work role env files with templates
- [ ] Create stricter security defaults for work
- [ ] Document customization points

### Bite 4.3: Personal Role - Environment (1 hr)

**Structure**:
```
roles/personal/
├── Brewfile              ✅ Exists
├── aliases/
│   └── personal.aliases.sh 🆕 New
└── defaults/
    └── casual.sh         🆕 New (more relaxed settings)
```

**Tasks**:
- [ ] Create personal role env/aliases files
- [ ] More relaxed security defaults

### Bite 4.4: Role Loading Integration (2 hrs)

Update the shell profile to load role-specific settings.

**Tasks**:
- [ ] Update `.zprofile` to load role env files
- [ ] Update `.zshrc` to load role aliases
- [ ] Create `fc fc-profile` hook for defaults
- [ ] Test `fc fc-profile switch developer` works
- [ ] Test `fc fc-profile switch work` works
- [ ] Document role customization

---

## WP5: Documentation

**Goal**: Achieve 100% documentation coverage for all defaults scripts.

**Dependency**: None (runs in parallel)

### Bite 5.1: System Scripts (3 hrs)

Scripts needing documentation:
- [ ] `system/core.sh`
- [ ] `system/time_machine.sh`
- [ ] `system/auto_updates.sh`

**For each script**:
1. Read existing code
2. Research each setting on Apple Support
3. Add full inline documentation
4. Add source URLs
5. Update `defaults/README.md` status

### Bite 5.2: Application Scripts (3 hrs)

Scripts needing documentation:
- [ ] `applications/alfred.sh`
- [ ] `applications/docker.sh`
- [ ] `applications/iterm2.sh`
- [ ] `applications/mariadb.sh`
- [ ] `applications/nvm.sh`
- [ ] `applications/vscode.sh`

### Bite 5.3: Interface Scripts (1 hr)

Scripts needing documentation:
- [ ] `interface/dock.sh` (partial - needs source URLs)

### Bite 5.4: Documentation Polish (2 hrs)

- [ ] Update `defaults/README.md` with 100% status
- [ ] Create quick reference card
- [ ] Add troubleshooting section
- [ ] Document how to contribute new defaults
- [ ] Link from main README.md

---

## Execution Schedule

### Suggested Order

```
Week 1-2: WP1 (Shell Profiles) + WP5 Bite 5.1 (Doc: System)
Week 3-4: WP2 (Environment Variables) + WP5 Bite 5.2 (Doc: Apps)
Week 5-7: WP3 Bites 3.1-3.3 (Defaults: Security, Energy, Menu)
Week 8-9: WP3 Bites 3.4-3.7 (Defaults: Apps, Desktop, Accessibility)
Week 10-11: WP4 (Role Settings)
Week 12: WP5 Bites 5.3-5.4 (Final documentation)
```

### Per-Session Approach

If working in 1-2 hour sessions:

1. **Session 1**: Bite 1.1 (.zprofile)
2. **Session 2**: Bite 1.2 + 1.3 (.zshenv, .zlogout)
3. **Session 3**: Bite 1.4 (path.env.sh)
4. **Session 4**: Bite 1.5 (installer update)
5. **Session 5**: Bite 2.1 (security/telemetry)
6. **Session 6**: Bite 2.2 (colors/pager)
7. **Session 7**: Bite 2.3 (python, node)
8. **Session 8**: Bite 2.3 continued (go, rust, java)
9. **Session 9**: Bite 2.4 + 2.5 (docker, cloud, xdg)
10. **Session 10**: Bite 3.1 (privacy defaults)
... and so on

---

## Validation Checklist

Before declaring v1.0 complete:

### Shell Profiles
- [ ] Fresh install creates all symlinks
- [ ] Login shell loads all env files
- [ ] Non-login interactive shell works
- [ ] Scripts can find Homebrew binaries
- [ ] No significant shell startup slowdown (< 500ms)

### Environment Variables
- [ ] All 20 env files created and loading
- [ ] Telemetry disabled for all tracked CLIs
- [ ] GPG/SSH agents work without manual config
- [ ] PATH is correct and has no duplicates
- [ ] Colors work in Terminal.app and iTerm2

### macOS Defaults
- [ ] All 45+ defaults scripts exist
- [ ] All scripts have inline documentation
- [ ] All scripts work on macOS 14+ (Sonoma)
- [ ] Privacy profile applies 20+ settings
- [ ] Lockdown profile applies max security

### Role Settings
- [ ] Developer role has git aliases loading
- [ ] Work role has proxy template
- [ ] Personal role has relaxed settings
- [ ] `fc fc-profile switch` works correctly

### Documentation
- [ ] defaults/README.md shows 100% complete
- [ ] All scripts have Apple Support source URLs
- [ ] Contributing guide exists
- [ ] Troubleshooting section exists

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| macOS update breaks defaults | Medium | Medium | Test on beta releases |
| Scope creep (more settings) | High | Low | Stick to defined list |
| Time underestimated | Medium | Medium | Track actual hours |
| Shell startup slowdown | Low | High | Profile with `zprof` |
| Symlink conflicts | Low | Medium | Backup strategy |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-02 | Initial plan created |
