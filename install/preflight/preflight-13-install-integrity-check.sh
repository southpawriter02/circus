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


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

#
# Echo a formatted message to the console.
#
# @param string $1 The message to echo.
#
function e_msg() {
  printf " [37;1m%s[0m\n" "$1"
}

#
# Echo a success message to the console.
#
# @param string $1 The message to echo.
#
function e_success() {
  printf " [32;1m✔[0m %s\n" "$1"
}

#
# Echo an error message to the console and exit.
#
# @param string $1 The message to echo.
#
function e_error() {
  printf " [31;1m✖[0m %s\n" "$1"
}


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

e_msg "Performing install integrity check..."

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
integrity_issue=false

# Get the directory of the current script.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Iterate through the checksums.
for script in "${!CHECKSUMS[@]}"; do
  script_path="$script_dir/$script"

  if [ -f "$script_path" ]; then
    # Calculate the checksum of the script.
    checksum=$(shasum -a 256 "$script_path" | awk '{print $1}')

    # Compare the calculated checksum with the expected checksum.
    if [ "$checksum" == "${CHECKSUMS[$script]}" ]; then
      e_success "$script: OK"
    else
      e_error "$script: FAILED (checksum mismatch)"
      integrity_issue=true
    fi
  else
    e_error "$script: FAILED (file not found)"
    integrity_issue=true
  fi
done

# If any integrity issues were found, exit with an error status.
if [ "$integrity_issue" = true ]; then
  e_error "Install integrity check failed. Please re-download the installation files."
  exit 1
fi

e_success "Install integrity check passed."
exit 0
