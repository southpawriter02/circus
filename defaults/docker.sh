#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Docker Configuration
#
# This script configures Docker Desktop with sensible defaults for developers,
# particularly for resource allocation.
#
# ==============================================================================

main() {
  msg_info "Configuring Docker Desktop settings..."

  # --- Configuration ---
  # Note: Docker settings are stored in a group container.
  local docker_settings_dir="$HOME/Library/Group Containers/group.com.docker"
  local docker_settings_file="$docker_settings_dir/settings.json"

  # --- Prerequisite Check ---
  # Don't run if Docker hasn't created its settings directory yet.
  if [ ! -d "$docker_settings_dir" ]; then
    msg_warning "Docker settings directory not found. Skipping configuration."
    msg_info "Please run Docker Desktop at least once to create its settings."
    return 1
  fi

  # --- Settings Configuration ---
  # To avoid overwriting user preferences, we only create a default config
  # if one doesn't already exist.
  if [ -f "$docker_settings_file" ]; then
    msg_info "Docker settings file already exists. Skipping creation of default config."
  else
    msg_info "Docker settings file not found. Creating a default configuration..."
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would create default Docker settings file at $docker_settings_file"
    else
      # Create the settings file with some sensible defaults.
      cat << EOF > "$docker_settings_file"
{
  "cpus": 4,
  "memoryMiB": 4096,
  "diskSizeMiB": 65536,
  "checkForUpdatesOnStartup": true,
  "analyticsEnabled": false,
  "integratedWslDistros": []
}
EOF
      msg_success "Created default Docker settings file."
    fi
  fi

  msg_success "Docker configuration complete."
}

main
