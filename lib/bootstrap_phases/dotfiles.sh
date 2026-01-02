#!/usr/bin/env bash

# ==============================================================================
#
# PHASE:        dotfiles
#
# DESCRIPTION:  Deploy dotfiles and shell configuration.
#               Sets up symbolic links and configures the shell environment.
#
# ==============================================================================

# --- Check if dotfiles repo exists ---
if [ ! -d "$DOTFILES_ROOT" ]; then
  msg_error "Dotfiles root not found: $DOTFILES_ROOT"
  msg_info "This phase requires the dotfiles repository to be present."
  return 1
fi

# --- Deploy Shell Configuration ---
deploy_shell_config() {
  msg_info "Deploying shell configuration..."

  # Create .config directory if it doesn't exist
  mkdir -p "$HOME/.config"

  # Link shell configuration files
  local shell_files=(
    ".zshrc"
    ".zshenv"
    ".zprofile"
    ".bashrc"
    ".bash_profile"
  )

  for file in "${shell_files[@]}"; do
    local source_file="$DOTFILES_ROOT/shell/$file"
    local target_file="$HOME/$file"

    if [ -f "$source_file" ]; then
      # Backup existing file if it's not a symlink
      if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
        msg_info "Backing up existing $file"
        mv "$target_file" "${target_file}.backup.$(date +%Y%m%d%H%M%S)"
      fi

      # Create symlink
      ln -sf "$source_file" "$target_file"
      msg_success "Linked $file"
    fi
  done
}

# --- Deploy Config Directory ---
deploy_config_dir() {
  msg_info "Deploying configuration files..."

  local config_source="$DOTFILES_ROOT/config"

  if [ -d "$config_source" ]; then
    # Link each config directory/file
    for item in "$config_source"/*; do
      local name=$(basename "$item")
      local target="$HOME/.config/$name"

      # Skip if already a symlink to the right place
      if [ -L "$target" ] && [ "$(readlink "$target")" = "$item" ]; then
        msg_info "Already linked: $name"
        continue
      fi

      # Backup existing if not a symlink
      if [ -e "$target" ] && [ ! -L "$target" ]; then
        msg_info "Backing up existing .config/$name"
        mv "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
      fi

      # Create symlink
      ln -sf "$item" "$target"
      msg_success "Linked .config/$name"
    done
  fi
}

# --- Deploy Git Configuration ---
deploy_git_config() {
  msg_info "Deploying git configuration..."

  local git_source="$DOTFILES_ROOT/git"

  if [ -d "$git_source" ]; then
    # Link gitconfig if it exists
    if [ -f "$git_source/.gitconfig" ]; then
      local target="$HOME/.gitconfig"

      if [ -f "$target" ] && [ ! -L "$target" ]; then
        msg_info "Backing up existing .gitconfig"
        mv "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
      fi

      ln -sf "$git_source/.gitconfig" "$target"
      msg_success "Linked .gitconfig"
    fi

    # Link gitignore_global if it exists
    if [ -f "$git_source/.gitignore_global" ]; then
      local target="$HOME/.gitignore_global"

      if [ -f "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
      fi

      ln -sf "$git_source/.gitignore_global" "$target"
      msg_success "Linked .gitignore_global"
    fi
  fi
}

# --- Apply Profile if Configured ---
apply_profile() {
  if [ -n "$BOOTSTRAP_ROLE" ]; then
    msg_info "Checking for role-specific profile: $BOOTSTRAP_ROLE"

    # Check if fc profile command exists
    if [ -x "$DOTFILES_ROOT/bin/fc" ]; then
      # Check if profile exists
      local profile_dir="$DOTFILES_ROOT/profiles/$BOOTSTRAP_ROLE"
      if [ -d "$profile_dir" ]; then
        msg_info "Applying profile: $BOOTSTRAP_ROLE"
        "$DOTFILES_ROOT/bin/fc" profile switch "$BOOTSTRAP_ROLE" --no-confirm 2>/dev/null || true
      else
        msg_info "No profile directory found for role: $BOOTSTRAP_ROLE"
      fi
    fi
  fi
}

# --- Main Dotfiles Phase ---
msg_info "Deploying dotfiles from $DOTFILES_ROOT"
echo ""

# Deploy in order
deploy_shell_config
echo ""

deploy_config_dir
echo ""

deploy_git_config
echo ""

apply_profile
echo ""

# Remind user to reload shell
msg_info "Dotfiles deployed. Open a new terminal to load the new configuration."

msg_success "Dotfiles phase complete."
