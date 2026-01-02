#!/usr/bin/env bash

# ==============================================================================
#
# PHASE:        homebrew
#
# DESCRIPTION:  Install or update Homebrew and core dependencies.
#               This phase ensures the package manager is available for
#               subsequent phases.
#
# ==============================================================================

# --- Install Xcode Command Line Tools ---
install_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    msg_success "Xcode Command Line Tools already installed."
    return 0
  fi

  msg_info "Installing Xcode Command Line Tools..."
  msg_info "This may take a few minutes and require user interaction."

  # Trigger the installation dialog
  xcode-select --install 2>/dev/null || true

  # Wait for installation to complete
  msg_info "Waiting for Xcode Command Line Tools installation..."
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done

  msg_success "Xcode Command Line Tools installed."
}

# --- Install Homebrew ---
install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    msg_success "Homebrew already installed."
    return 0
  fi

  msg_info "Installing Homebrew..."
  msg_info "This may require your password."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for Apple Silicon
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    msg_info "Homebrew installed to /opt/homebrew (Apple Silicon)"
  elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    msg_info "Homebrew installed to /usr/local (Intel)"
  fi

  if command -v brew >/dev/null 2>&1; then
    msg_success "Homebrew installed successfully."
  else
    die "Homebrew installation failed."
  fi
}

# --- Update Homebrew ---
update_homebrew() {
  msg_info "Updating Homebrew..."

  brew update

  msg_success "Homebrew updated."
}

# --- Install Core Dependencies ---
install_core_dependencies() {
  msg_info "Installing core dependencies..."

  # Essential tools that other phases depend on
  local core_packages=(
    "git"
    "coreutils"
  )

  for pkg in "${core_packages[@]}"; do
    if brew list "$pkg" >/dev/null 2>&1; then
      msg_info "  $pkg: Already installed"
    else
      msg_info "  Installing $pkg..."
      brew install "$pkg"
    fi
  done

  # Install gum if user requested rich TUI
  if [ "$USE_GUM" = true ]; then
    if brew list gum >/dev/null 2>&1; then
      msg_info "  gum: Already installed"
    else
      msg_info "  Installing gum for rich TUI..."
      brew install gum
    fi
  fi

  msg_success "Core dependencies installed."
}

# --- Install Role-Specific Brewfile ---
install_role_brewfile() {
  local role_brewfile="$DOTFILES_ROOT/roles/${BOOTSTRAP_ROLE}/Brewfile"

  if [ -n "$BOOTSTRAP_ROLE" ] && [ -f "$role_brewfile" ]; then
    msg_info "Installing packages from role Brewfile: $BOOTSTRAP_ROLE"
    brew bundle install --file="$role_brewfile" || true
    msg_success "Role packages installed."
  else
    msg_info "No role-specific Brewfile found. Skipping."
  fi
}

# --- Main Homebrew Phase ---
msg_info "Setting up Homebrew and core dependencies..."
echo ""

install_xcode_clt
install_homebrew
update_homebrew
install_core_dependencies

# Only install role Brewfile if we're not restoring from backup
# (restore phase will handle application installation)
if [ "$AUTO_RESTORE" != true ]; then
  install_role_brewfile
fi

echo ""
msg_success "Homebrew phase complete."
