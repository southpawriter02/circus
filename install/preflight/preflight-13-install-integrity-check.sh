#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Install Integrity
#
# This script performs an integrity check of the installation files. It does
# this by calculating the SHA-256 checksum of each preflight script and
# comparing it to a list of known checksums.
#
# This helps to ensure that the installation files have not been corrupted or
# tampered with.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Performing install integrity check..."

  #
  # CUSTOMIZATION:
  # If you modify any of the preflight scripts, you will need to update their
  # checksums in this associative array. You can generate a new checksum using
  # the following command from within the 'install/preflight' directory:
  #
  # shasum -a 256 <script_name>
  #

  # TODO: Generate and update the checksums for all preflight scripts.
  # The current values are placeholders and will cause the integrity check to fail.
  declare -A CHECKSUMS
  CHECKSUMS["preflight-01-macos-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-02-root-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-03-admin-rights-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-04-file-permissions-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-05-unset-vars-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-06-shell-type-version-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-07-locale-encoding-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-08-battery-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-09-wifi-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-10-xcode-cli-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-11-homebrew-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-12-dependency-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-14-update-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-15-existing-install-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-16-backed-up-dotfiles-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-17-existing-dotfiles-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-18-icloud-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-19-terminal-type-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-20-conflicting-processes-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  CHECKSUMS["preflight-21-install-sanity-check.sh"]="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  # A flag to track if any integrity issues are found.
  local integrity_issue=false

  # Get the directory of the current script.
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Iterate through the checksums.
  for script in "${!CHECKSUMS[@]}"; do
    local script_path="$script_dir/$script"

    if [ -f "$script_path" ]; then
      # Calculate the checksum of the script.
      local checksum
      checksum=$(shasum -a 256 "$script_path" | awk '{print $1}')

      # Compare the calculated checksum with the expected checksum.
      if [ "$checksum" == "${CHECKSUMS[$script]}" ]; then
        msg_success "$script: OK"
      else
        msg_error "$script: FAILED (checksum mismatch)"
        integrity_issue=true
      fi
    else
      msg_error "$script: FAILED (file not found)"
      integrity_issue=true
    fi
  done

  # If any integrity issues were found, return an error status.
  if [ "$integrity_issue" = true ]; then
    msg_error "Install integrity check failed. Please re-download the installation files."
    return 1
  fi

  msg_success "Install integrity check passed."
  return 0
}

#
# Execute the main function.
#
main
