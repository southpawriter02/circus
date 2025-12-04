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
  # checksums in this associative array. You can generate new checksums using:
  #
  #   cd install/preflight && for f in preflight-*.sh; do
  #     echo "CHECKSUMS[\"$f\"]=\"$(sha256sum "$f" | cut -d' ' -f1)\"";
  #   done
  #
  # Note: This script (preflight-13) is not included since it cannot verify itself.

  declare -A CHECKSUMS
  CHECKSUMS["preflight-01-macos-check.sh"]="62ecb63735e4bb6ebc15353457a8ef39882f6e1180dbe5fed845db2fef378660"
  CHECKSUMS["preflight-02-root-check.sh"]="ea2334cc8dc3b77756f4891d0b18cef3af0e1467a41badb899521b5c9c9331c7"
  CHECKSUMS["preflight-03-admin-rights-check.sh"]="8ecb3aad185eb54b1d0b9b2146981e828be17b03f315bef388d0687576a3a17f"
  CHECKSUMS["preflight-04-file-permissions-check.sh"]="099bfc4ce2b192df21b7950e772b509d9811a38ac9cdedbeec31624efacc5103"
  CHECKSUMS["preflight-05-unset-vars-check.sh"]="fb37e0db88eb7850fd74e2a5f4b0e474df1452ca2c4ba2fdd1ce29809c74d325"
  CHECKSUMS["preflight-06-shell-type-version-check.sh"]="8d4e9051310f43269797b6a3a6cd6a39a3891140aa3f1796aa8ed3bb27d8f90a"
  CHECKSUMS["preflight-07-locale-encoding-check.sh"]="bbe81d5303a3c3c4588ad35282d332d80ce39677c85aea2cf38cfccf9e619c90"
  CHECKSUMS["preflight-08-battery-check.sh"]="ab6020aeb825ae880cecd86f0fab24b56b225e0764e2a777de56bba9e5149e12"
  CHECKSUMS["preflight-09-wifi-check.sh"]="1643ba5b56821b423eae9f7bdc467505399ab425c87ef900fbc4d2630376abc6"
  CHECKSUMS["preflight-10-xcode-cli-check.sh"]="5a2fa97fe401f8935a1a33781ecb08f4130416a1ca9681189166636b365bba68"
  CHECKSUMS["preflight-11-homebrew-check.sh"]="422af179d72cdcc85fd7b9323b4842fc17b6bb2c12816ac49ba408a3e80e6ef4"
  CHECKSUMS["preflight-12-dependency-check.sh"]="176d38376ac3cabcdbcf44b951be0bcbb5360e11fb8b6fbd7396d53427560ef9"
  CHECKSUMS["preflight-14-update-check.sh"]="75cc7bf52d03749b37920f2e8d3fcfeb2d6d7f8f8628f3986bd9a61e0b31dc13"
  CHECKSUMS["preflight-15-existing-install-check.sh"]="6ea7c8d9db9473105d82e97f32f7db8e7a910773bc97e695091390f7638c0186"
  CHECKSUMS["preflight-16-backed-up-dotfiles-check.sh"]="6179731a5969f87b9b39f1c5c5eced1c9937e9e583bad5b3350f31421c9c059b"
  CHECKSUMS["preflight-17-existing-dotfiles-check.sh"]="4bddbb1d57bd3604ee3f3aec13dd6e049b127a9742670ca1c54fa48cfab27073"
  CHECKSUMS["preflight-18-icloud-check.sh"]="b2379ee7b8bfa2a4dee230c5d7feae98d509c4dd23432cd8e7713a3095e3f8a8"
  CHECKSUMS["preflight-19-terminal-type-check.sh"]="01d6aaf8afdfb990147daa5339a089abfe1f42b77d2c83fa9fe521bffc5aa346"
  CHECKSUMS["preflight-20-conflicting-processes-check.sh"]="a654b882d7731f9e25e5786c77ef8bc6c991dd019f8cb0522aa31e292ca23904"
  CHECKSUMS["preflight-21-install-sanity-check.sh"]="ec0f107ad1df237eef6703bc38bf3337e5fedfba77581575fd1d9ecd7b823425"

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
      # Use sha256sum (Linux) or shasum (macOS) depending on availability.
      local checksum
      if command -v sha256sum >/dev/null 2>&1; then
        checksum=$(sha256sum "$script_path" | awk '{print $1}')
      else
        checksum=$(shasum -a 256 "$script_path" | awk '{print $1}')
      fi

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
