#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Docker Desktop Configuration
#
# DESCRIPTION:
#   This script configures Docker Desktop with sensible defaults for developers.
#   It sets up resource allocation (CPU, memory, disk) and general preferences.
#   Docker Desktop provides containerization capabilities for macOS.
#
# REQUIRES:
#   - Docker Desktop installed (brew install --cask docker)
#   - Docker Desktop must have been run at least once to create settings
#
# REFERENCES:
#   - Docker Desktop for Mac Documentation
#     https://docs.docker.com/desktop/install/mac-install/
#   - Docker Desktop Settings
#     https://docs.docker.com/desktop/settings/mac/
#   - Docker Resource Management
#     https://docs.docker.com/desktop/mac/space/
#
# PATHS:
#   Settings directory: ~/Library/Group Containers/group.com.docker
#   Settings file:      ~/Library/Group Containers/group.com.docker/settings.json
#
# DEFAULT RESOURCES:
#   - CPUs: Half of host's CPUs (minimum 2)
#   - Memory: 2 GB (minimum), up to 50% of host RAM
#   - Disk: 64 GB virtual disk image
#
# NOTES:
#   - Docker Desktop uses a Linux VM under the hood (HyperKit or QEMU)
#   - Resource limits apply to the Docker VM, not individual containers
#   - Analytics can be disabled for privacy
#   - Changes may require Docker Desktop restart
#
# ==============================================================================

main() {
  msg_info "Configuring Docker Desktop settings..."

  # --- Configuration ---
  # Docker Desktop stores its settings in a Group Container directory.
  # This location is used for sandboxed macOS apps.
  local docker_settings_dir="$HOME/Library/Group Containers/group.com.docker"
  local docker_settings_file="$docker_settings_dir/settings.json"

  # --- Prerequisite Check ---
  # Docker Desktop creates its settings directory on first launch.
  # If it doesn't exist, Docker hasn't been run yet.
  if [ ! -d "$docker_settings_dir" ]; then
    msg_warning "Docker settings directory not found. Skipping configuration."
    msg_info "Please run Docker Desktop at least once to create its settings."
    return 1
  fi

  # ==============================================================================
  # Settings Configuration
  # ==============================================================================
  #
  # Docker Desktop settings are stored as JSON. Rather than overwriting user
  # preferences, we only create a default configuration if one doesn't exist.
  #
  # Key settings explained:
  #   - cpus: Number of CPU cores allocated to Docker VM
  #   - memoryMiB: Memory in MiB allocated to Docker VM
  #   - diskSizeMiB: Maximum size of Docker's disk image in MiB
  #   - checkForUpdatesOnStartup: Check for Docker Desktop updates
  #   - analyticsEnabled: Send usage statistics to Docker

  if [ -f "$docker_settings_file" ]; then
    msg_info "Docker settings file already exists. Skipping creation of default config."
    msg_info "Existing settings will be preserved."
  else
    msg_info "Docker settings file not found. Creating a default configuration..."
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would create default Docker settings file at $docker_settings_file"
    else
      # Create the settings file with sensible developer defaults
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
      # Explanation of settings:
      #   - cpus: 4        = Allocate 4 CPU cores (adjust based on your machine)
      #   - memoryMiB: 4096 = 4 GB RAM (adjust based on your workload)
      #   - diskSizeMiB: 65536 = 64 GB disk image
      #   - checkForUpdatesOnStartup: true = Keep Docker up to date
      #   - analyticsEnabled: false = Disable telemetry for privacy
      #   - integratedWslDistros: [] = WSL integration (Windows only, ignored on Mac)
      msg_success "Created default Docker settings file."
    fi
  fi

  msg_success "Docker configuration complete."
}

main
