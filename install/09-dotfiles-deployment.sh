#!/usr/bin/env bash

# ==============================================================================
#
# Stage 09: Dotfiles & Plugin Deployment
#
# This script handles the deployment of the core shell configuration, including
# the .zshrc file and the custom Oh My Zsh plugin.
#
# ==============================================================================

#
# @description
#   A helper function to safely create a symlink, backing up any existing file
#   at the destination. Supports dry-run mode.
#
# @param $1 The source file/directory for the symlink.
# @param $2 The destination path for the symlink.
#
symlink_with_backup() {
  local source="$1"
  local dest="$2"

  if [ "$DRY_RUN_MODE" = true ]; then
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      msg_info "[Dry Run] Would backup existing file at $dest"
    fi
    msg_info "[Dry Run] Would create symlink: $source -> $dest"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup_path
    backup_path="${dest}.backup-$(date +%Y%m%d%H%M%S)"
    msg_info "Backing up existing file at $dest to $backup_path"
    mv "$dest" "$backup_path"
  fi

  msg_info "Creating symlink: $source -> $dest"
  # The -s flag creates a symbolic link.
  # The -n flag is important for symlinking directories; it prevents `ln` from
  # creating the link inside the directory if the destination already exists.
  ln -sn "$source" "$dest"
}

main() {
  msg_info "Stage 09: Dotfiles & Plugin Deployment"

  # --- Symlink Core Configuration Files ---
  msg_info "Deploying core shell configuration..."

  # 1. Deploy core configuration files by finding all *.symlink files.
  #    This searches profiles/base and profiles/$INSTALL_ROLE (if set).
  local dotfiles_dirs=("$DOTFILES_ROOT/profiles/base")
  if [ -n "$INSTALL_ROLE" ] && [ -d "$DOTFILES_ROOT/profiles/$INSTALL_ROLE" ]; then
    dotfiles_dirs+=("$DOTFILES_ROOT/profiles/$INSTALL_ROLE")
  fi

  for dir in "${dotfiles_dirs[@]}"; do
    msg_info "Searching for dotfiles in: $dir"
    while IFS= read -r source_file; do
      local filename=$(basename "$source_file")
      # Strip .symlink extension and prepend a dot
      local target_name=".${filename%.symlink}"
      local target_file="$HOME/$target_name"

      symlink_with_backup "$source_file" "$target_file"
    done < <(find "$dir" -name "*.symlink")
  done

  # 2. Deploy the custom Oh My Zsh plugin.
  #    This requires the ~/.oh-my-zsh/custom/plugins directory to exist.
  local custom_plugin_dir="$HOME/.oh-my-zsh/custom/plugins"
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would create directory: $custom_plugin_dir"
  else
    mkdir -p "$custom_plugin_dir"
  fi
  symlink_with_backup "$DOTFILES_ROOT/profiles/base/zsh/oh-my-zsh-custom/circus" "$custom_plugin_dir/circus"

  # --- Make CLI Plugins Executable ---
  msg_info "Making fc command plugins executable..."
  local plugins_dir="$DOTFILES_ROOT/lib/plugins"
  for plugin in "$plugins_dir"/*; do
    if [ -f "$plugin" ]; then
      if [ "$DRY_RUN_MODE" = true ]; then
        msg_info "[Dry Run] Would make executable: $(basename "$plugin")"
      else
        if chmod +x "$plugin"; then
          msg_success "  -> Made executable: $(basename "$plugin")"
        else
          msg_error "  -> Failed to make executable: $(basename "$plugin")"
        fi
      fi
    fi
  done

  msg_success "Dotfiles and plugin deployment complete."
}

main
