# ==============================================================================
#
# FILE:         circus.plugin.zsh
#
# DESCRIPTION:  This is the main plugin file for the Dotfiles Flying Circus.
#               It sources all the custom aliases, environment variables, and
#               functions that make up your shell environment.
#
# ==============================================================================

# Get the directory of the current script.
# This allows us to source other files relative to this one.
local circus_plugin_dir="${0:A:h}"

# Source all alias files.
for alias_file in "$circus_plugin_dir"/aliases/*.sh; do
  source "$alias_file"
done

# Source all environment files.
for env_file in "$circus_plugin_dir"/env/*.sh; do
  source "$env_file"
done

# Source all function files.
for func_file in "$circus_plugin_dir"/functions/*.sh; do
  source "$func_file"
done

# --- Load Role-Specific Configurations --------------------------------------
# Check if a role is defined and load its specific configurations.
local circus_state_dir="$HOME/.circus"
local circus_root_file="$circus_state_dir/root"
local circus_role_file="$circus_state_dir/role"

if [ -f "$circus_root_file" ]; then
  local dotfiles_root
  dotfiles_root=$(cat "$circus_root_file")

  if [ -f "$circus_role_file" ]; then
    local current_role
    current_role=$(cat "$circus_role_file")

    if [ -n "$current_role" ] && [ -d "$dotfiles_root/roles/$current_role" ]; then
      # Source role-specific alias files.
      local role_aliases_dir="$dotfiles_root/roles/$current_role/aliases"
      if [ -d "$role_aliases_dir" ]; then
        for alias_file in "$role_aliases_dir"/*.sh; do
          [ -f "$alias_file" ] && source "$alias_file"
        done
      fi

      # Source role-specific environment files.
      local role_env_dir="$dotfiles_root/roles/$current_role/env"
      if [ -d "$role_env_dir" ]; then
        for env_file in "$role_env_dir"/*.sh; do
          [ -f "$env_file" ] && source "$env_file"
        done
      fi
    fi
  fi
fi
