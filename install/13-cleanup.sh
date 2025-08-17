#!/usr/bin/env bash

# ==============================================================================
#
# Stage 13: Cleanup
#
# This script performs cleanup tasks at the end of the installation process,
# such as removing temporary files and clearing caches.
#
# ==============================================================================

#
# The main logic for the cleanup stage.
#
main() {
  msg_info "Stage 13: Cleanup"

  # --- Homebrew Cleanup -------------------------------------------------------
  msg_info "Cleaning up Homebrew cache and old files..."

  # Check if Homebrew is installed before trying to clean it up.
  if ! command -v "brew" >/dev/null 2>&1; then
    msg_info "Homebrew not found. Skipping cleanup."
    return 0
  fi

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: brew cleanup --dry-run"
    # The `--dry-run` flag for brew cleanup shows what would be removed.
    brew cleanup --dry-run
  else
    # The `brew cleanup` command removes stale lock files and old downloads.
    if brew cleanup; then
      msg_success "Homebrew cleanup complete."
    else
      msg_warning "Homebrew cleanup command failed."
    fi
  fi

  msg_success "Cleanup stage complete."
}

#
# Execute the main function.
#
main
