#!/usr/bin/env zsh
# ... (header and constants remain the same) ...

# Global state variables
DRY_RUN_MODE=false
INTERACTIVE_MODE=false
INSTALL_ROLE=""
FORCE_MODE=false
PARANOID_MODE=false

# ... (library sourcing remains the same) ...

# Update usage function to include the new flag
usage() {
  echo "Usage: ./install.sh [options]"
  echo ""
  echo "Options:"
  echo "  --role <name>      Specify the role to install (e.g., developer)."
  echo "  --dry-run          Run the installer without making any changes."
  echo "  --force            Force re-running of already completed stages."
  echo "  --non-interactive  Run the installer without prompting for confirmation."
  echo "  --silent           Run the installer with minimal output to protect privacy."
  echo "  --help             Display this help message."
  exit 1
}

main() {
  # Argument parsing
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role)
        INSTALL_ROLE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN_MODE=true
        shift
        ;;
      --force)
        FORCE_MODE=true
        shift
        ;;
      --non-interactive)
        INTERACTIVE_MODE=false
        shift
        ;;
      --silent)
        PARANOID_MODE=true
        shift
        ;;
      --help)
        usage
        ;;
      *)
        usage
        ;;
    esac
  done

  # Export the PARANOID_MODE so it's available to all sourced scripts
  export PARANOID_MODE

  # --- Installation Stages ---
  msg_info "Starting Dotfiles Flying Circus setup..."
  prompt_for_confirmation "Ready to begin the installation."

  local INSTALL_STAGES=(
    "01-introduction-and-user-interaction.sh"
    "02-logging-setup.sh"
    "03-homebrew-installation.sh"
    "04-macos-system-settings.sh"
    "09-dotfiles-deployment.sh"
    "10-git-configuration.sh"
    "11-defaults-and-additional-configuration.sh"
    "12-aliases-configuration.sh"
    "13-env-configuration.sh"
    "16-jetbrains-configuration.sh"
    "17-secrets-management.sh"
    "14-cleanup.sh"
    "15-finalization-and-reporting.sh"
  )

  # ... (rest of the script remains the same) ...
}

main "$@"
