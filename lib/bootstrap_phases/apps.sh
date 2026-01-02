#!/usr/bin/env bash

# ==============================================================================
#
# PHASE:        apps
#
# DESCRIPTION:  Install applications via fc-apps.
#               Handles both CLI tools and GUI applications.
#
# ==============================================================================

# --- Check for fc command ---
if [ ! -x "$DOTFILES_ROOT/bin/fc" ]; then
  msg_error "fc command not available."
  msg_info "The apps phase requires the fc command to be installed."
  return 1
fi

# --- Check for Apps Configuration ---
check_apps_config() {
  local apps_config="$HOME/.config/circus/apps.conf"
  local apps_template="$DOTFILES_ROOT/lib/templates/apps.conf.template"

  if [ ! -f "$apps_config" ]; then
    msg_info "Apps configuration not found."

    if [ -f "$apps_template" ]; then
      msg_info "Creating default apps configuration..."
      mkdir -p "$(dirname "$apps_config")"
      cp "$apps_template" "$apps_config"
      msg_success "Created $apps_config"
      msg_info "You can customize this file to control which apps are installed."
    else
      msg_warning "No apps configuration template found."
      msg_info "Running fc apps setup to create configuration..."
      "$DOTFILES_ROOT/bin/fc" apps setup 2>/dev/null || true
    fi
  else
    msg_info "Using existing apps configuration: $apps_config"
  fi
}

# --- Install Apps Based on Role ---
install_apps_for_role() {
  local role="${BOOTSTRAP_ROLE:-developer}"
  msg_info "Installing applications for role: $role"
  echo ""

  # Check if role-specific Brewfile exists
  local role_brewfile="$DOTFILES_ROOT/Brewfiles/Brewfile.$role"
  local main_brewfile="$DOTFILES_ROOT/Brewfile"

  if [ -f "$role_brewfile" ]; then
    msg_info "Found role-specific Brewfile: $role_brewfile"
    HOMEBREW_BUNDLE_FILE="$role_brewfile" brew bundle --no-lock 2>/dev/null || {
      msg_warning "Some apps from role Brewfile may have failed to install."
    }
  elif [ -f "$main_brewfile" ]; then
    msg_info "Using main Brewfile: $main_brewfile"
    brew bundle --file="$main_brewfile" --no-lock 2>/dev/null || {
      msg_warning "Some apps from Brewfile may have failed to install."
    }
  fi
}

# --- Install Apps via fc-apps ---
install_fc_apps() {
  msg_info "Running fc apps install..."
  echo ""

  # Run fc apps install
  if "$DOTFILES_ROOT/bin/fc" apps install 2>/dev/null; then
    msg_success "Applications installed successfully."
  else
    msg_warning "Some applications may have failed to install."
    msg_info "You can retry later with: fc apps install"
  fi
}

# --- Install Mac App Store Apps ---
install_mas_apps() {
  # Check if mas is installed
  if ! command -v mas >/dev/null 2>&1; then
    msg_info "mas (Mac App Store CLI) not installed. Skipping MAS apps."
    return 0
  fi

  # Check if user is signed in to App Store
  if ! mas account >/dev/null 2>&1; then
    msg_warning "Not signed in to Mac App Store."
    msg_info "Sign in to App Store to install MAS apps, then run: fc apps install"
    return 0
  fi

  # Check for MAS Brewfile
  local mas_brewfile="$DOTFILES_ROOT/Brewfiles/Brewfile.mas"
  if [ -f "$mas_brewfile" ]; then
    msg_info "Installing Mac App Store apps..."
    brew bundle --file="$mas_brewfile" --no-lock 2>/dev/null || {
      msg_warning "Some MAS apps may have failed to install."
    }
  fi
}

# --- Main Apps Phase ---
msg_info "Starting application installation..."
echo ""

# Ensure apps config exists
check_apps_config
echo ""

# Install role-based apps first (from Brewfiles)
install_apps_for_role
echo ""

# Install apps via fc-apps
install_fc_apps
echo ""

# Try MAS apps if available
install_mas_apps
echo ""

msg_success "Apps phase complete."
