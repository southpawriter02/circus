#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: FileVault
#
# DESCRIPTION:
#   Displays FileVault disk encryption status and provides information
#   about enabling full-disk encryption. FileVault cannot be enabled
#   via defaults - it requires interactive user authentication.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Administrator privileges
#   - Restart required for enabling/disabling
#
# REFERENCES:
#   - Apple Support: Use FileVault to encrypt the startup disk
#     https://support.apple.com/guide/mac-help/mh11785/mac
#
# DOMAIN:
#   com.apple.MCX (managed preferences)
#
# NOTES:
#   - FileVault MUST be enabled via System Settings or `fdesetup`
#   - Recovery key should be stored securely
#   - Enabling requires logout and re-authentication
#
# ==============================================================================

msg_info "Checking FileVault status..."

# ==============================================================================
# FileVault Status Check
# ==============================================================================

# Check current FileVault status
if command -v fdesetup &>/dev/null; then
  local fv_status
  fv_status=$(fdesetup status 2>/dev/null)
  
  if echo "$fv_status" | grep -q "FileVault is On"; then
    msg_success "FileVault is ENABLED ✓"
    msg_info "Your disk is encrypted."
  elif echo "$fv_status" | grep -q "FileVault is Off"; then
    msg_warning "FileVault is DISABLED"
    msg_info ""
    msg_info "To enable FileVault:"
    msg_info "  1. System Settings > Privacy & Security > FileVault"
    msg_info "  2. Click 'Turn On FileVault'"
    msg_info "  3. Choose recovery key option"
    msg_info "  4. Restart to begin encryption"
    msg_info ""
    msg_info "Or via command line:"
    msg_info "  sudo fdesetup enable"
  else
    msg_info "FileVault status: $fv_status"
  fi
else
  msg_warning "fdesetup command not available"
fi

# ==============================================================================
# FileVault Recommendations
# ==============================================================================

msg_info ""
msg_info "FileVault Best Practices:"
msg_info "  ✓ Always enable on portable Macs"
msg_info "  ✓ Store recovery key in password manager"
msg_info "  ✓ Keep iCloud recovery option enabled"
msg_info "  ✓ Initial encryption may take several hours"

# ==============================================================================
# Managed Settings (for MDM/Enterprise)
# ==============================================================================

# Note: The following settings are typically used with MDM profiles:
#
# --- Defer FileVault Enable at Login ---
# Key:          dontAllowFDEDisable
# Domain:       com.apple.MCX
# Description:  Prevent users from disabling FileVault (MDM policy)
#
# --- Force FileVault Enable ---
# Key:          fdeEnabled
# Domain:       com.apple.MCX
# Description:  Require FileVault (MDM policy)

msg_success "FileVault check complete."
