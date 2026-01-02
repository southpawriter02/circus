#!/usr/bin/env bash

# ==============================================================================
#
# PHASE:        preflight
#
# DESCRIPTION:  Verify system requirements before bootstrap begins.
#               Checks macOS version, disk space, and internet connectivity.
#               Detects if this is a fresh install or existing setup.
#
# ==============================================================================

# --- Check macOS Version ---
check_macos_version() {
  msg_info "Checking macOS version..."

  local macos_version
  macos_version=$(sw_vers -productVersion)
  local major_version
  major_version=$(echo "$macos_version" | cut -d. -f1)

  if [ "$major_version" -lt 12 ]; then
    msg_warning "macOS $macos_version detected. Some features may not work correctly."
    msg_info "Recommended: macOS 12 (Monterey) or later."
  else
    msg_success "macOS $macos_version detected."
  fi
}

# --- Check Disk Space ---
check_disk_space() {
  msg_info "Checking available disk space..."

  local available_gb
  available_gb=$(df -g / | awk 'NR==2 {print $4}')

  if [ "$available_gb" -lt 10 ]; then
    msg_error "Only ${available_gb}GB available. At least 10GB recommended."
    die "Insufficient disk space. Free up space and try again."
  elif [ "$available_gb" -lt 20 ]; then
    msg_warning "${available_gb}GB available. Consider freeing up space."
  else
    msg_success "${available_gb}GB available."
  fi
}

# --- Check Internet Connectivity ---
check_internet() {
  msg_info "Checking internet connectivity..."

  if ping -c 1 -W 3 github.com >/dev/null 2>&1; then
    msg_success "Internet connection available."
  else
    msg_warning "Cannot reach github.com. Some phases may fail."
    msg_info "Continuing anyway - some features will work offline."
  fi
}

# --- Detect Existing Setup ---
detect_existing_setup() {
  msg_info "Detecting existing setup..."

  local is_fresh=true

  # Check for existing Homebrew
  if command -v brew >/dev/null 2>&1; then
    msg_info "  Homebrew: Installed"
    is_fresh=false
  else
    msg_info "  Homebrew: Not installed"
  fi

  # Check for existing dotfiles state
  if [ -d "$HOME/.circus" ]; then
    msg_info "  Dotfiles state: Found (~/.circus exists)"
    is_fresh=false
  else
    msg_info "  Dotfiles state: Fresh install"
  fi

  # Check for existing git config
  if [ -f "$HOME/.gitconfig" ]; then
    msg_info "  Git config: Found"
    is_fresh=false
  else
    msg_info "  Git config: Not found"
  fi

  # Check for existing SSH keys
  if [ -d "$HOME/.ssh" ] && ls "$HOME/.ssh/"*.pub >/dev/null 2>&1; then
    msg_info "  SSH keys: Found"
  else
    msg_info "  SSH keys: Not found"
  fi

  # Export mode for other phases
  if [ "$is_fresh" = true ]; then
    export BOOTSTRAP_MODE="fresh"
    msg_info "Bootstrap mode: Fresh install"
  else
    export BOOTSTRAP_MODE="existing"
    msg_info "Bootstrap mode: Existing setup detected"
  fi
}

# --- Check for Required Tools ---
check_required_tools() {
  msg_info "Checking for required tools..."

  # Check for curl (needed to install Homebrew)
  if command -v curl >/dev/null 2>&1; then
    msg_success "curl is available."
  else
    die "curl is required but not found. Please install Xcode Command Line Tools."
  fi

  # Check for git (may need to install via Xcode CLT)
  if command -v git >/dev/null 2>&1; then
    msg_success "git is available."
  else
    msg_warning "git not found. Will be installed with Xcode Command Line Tools."
  fi
}

# --- Main Preflight Checks ---
msg_info "Running preflight checks..."
echo ""

check_macos_version
check_disk_space
check_internet
check_required_tools
detect_existing_setup

echo ""
msg_success "Preflight checks complete."
