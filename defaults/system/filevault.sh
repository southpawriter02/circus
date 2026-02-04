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

# --- FileVault Full Disk Encryption ---
# Description:  FileVault 2 provides XTS-AES-128 encryption with a 256-bit key
#               for the entire startup disk. When enabled, all data on the disk
#               is encrypted automatically and transparently. The encryption is
#               hardware-accelerated on Macs with Apple Silicon or Intel Macs
#               with a T2 security chip, resulting in no noticeable performance
#               impact for typical workloads.
#
# How It Works:
#   1. When you enable FileVault, macOS creates a recovery key
#   2. Your login password becomes the encryption passphrase
#   3. Pre-boot authentication is required before macOS loads
#   4. All data is encrypted/decrypted on-the-fly as you work
#   5. If the disk is removed, data is unreadable without the key
#
# Default:      Off (requires user opt-in during or after setup)
# UI Location:  System Settings > Privacy & Security > FileVault
# Source:       https://support.apple.com/guide/mac-help/mh11785/mac
# See also:     https://support.apple.com/guide/security/volume-encryption-with-filevault-sec4c6dc1b6e/web
#               https://support.apple.com/en-us/102384
#
# Security:     FileVault protects data at rest. Without it, anyone with physical
#               access to your Mac can boot into recovery mode or target disk mode
#               and access all files. FileVault is ESSENTIAL for:
#               - Laptops (risk of theft)
#               - Shared workspaces
#               - Compliance requirements (HIPAA, PCI-DSS, GDPR, SOC 2)
#               - Any Mac containing sensitive personal or business data
#
# Performance:  On Apple Silicon and T2 Macs, encryption is hardware-accelerated
#               in the Secure Enclave. Benchmarks show <1% performance difference.
#               Older Intel Macs without T2 may see 1-3% performance impact.

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
# FileVault Best Practices
# ==============================================================================

# --- Recovery Key Management ---
# Description:  When FileVault is enabled, you choose between two recovery options:
#
#               1. iCloud Recovery (recommended for personal use):
#                  - Apple stores an encrypted copy of your recovery key
#                  - You can unlock your Mac by authenticating with Apple ID
#                  - Convenient but requires trusting Apple with your key
#
#               2. Personal Recovery Key (recommended for enterprise/high security):
#                  - A 24-character alphanumeric key is generated
#                  - YOU are responsible for storing it securely
#                  - If lost and you forget your password, DATA IS UNRECOVERABLE
#
# Source:       https://support.apple.com/guide/mac-help/mh11785/mac
# See also:     https://support.apple.com/en-us/102650

msg_info ""
msg_info "FileVault Best Practices:"
msg_info "  ✓ Always enable on portable Macs (laptops are high theft risk)"
msg_info "  ✓ Store recovery key in password manager (1Password, Bitwarden)"
msg_info "  ✓ Keep iCloud recovery enabled as backup"
msg_info "  ✓ Initial encryption takes 1-4 hours (runs in background)"
msg_info "  ✓ All users who should unlock the disk must be added during setup"
msg_info "  ✓ For enterprise: consider escrowing keys to MDM (Jamf, Mosyle)"

# ==============================================================================
# Command Line Reference
# ==============================================================================

# --- fdesetup Commands ---
# Source:       man fdesetup
#
# Status and Information:
#   fdesetup status                    # Check if FileVault is on/off
#   fdesetup status -extended          # Detailed status including progress
#   fdesetup list                      # List users authorized to unlock
#   fdesetup isactive                  # Returns 0 if active, 1 if not
#
# Enable/Disable (requires restart):
#   sudo fdesetup enable               # Interactive enable with prompts
#   sudo fdesetup enable -user <name>  # Enable for specific user
#   sudo fdesetup disable              # Disable FileVault (decrypts disk)
#
# Recovery Key Management:
#   sudo fdesetup changerecovery       # Generate new recovery key
#   sudo fdesetup validaterecovery     # Verify recovery key is correct
#   sudo fdesetup haspersonalrecoverykey  # Check if PRK exists
#
# User Management:
#   sudo fdesetup add -usertoadd <name>   # Add user to unlock list
#   sudo fdesetup remove -user <name>     # Remove user from unlock list
#
# See also:     man fdesetup, man diskutil

# ==============================================================================
# Managed Settings (MDM/Enterprise)
# ==============================================================================

# --- Enterprise Deployment ---
# Description:  In managed environments, FileVault can be enforced and recovery
#               keys escrowed via MDM (Mobile Device Management) profiles.
#               The following keys are used in configuration profiles:
#
# Key:          dontAllowFDEDisable
# Domain:       com.apple.MCX
# Description:  When set via MDM profile, prevents users from disabling FileVault.
#               This ensures compliance with security policies.
#
# Key:          fdeEnabled  
# Domain:       com.apple.MCX (or via fdesetup defer)
# Description:  Defers FileVault enablement to next login. Used with MDM to
#               enable FileVault without needing the user's password in advance.
#               Recovery key is escrowed to the MDM server.
#
# Source:       https://developer.apple.com/documentation/devicemanagement/fdefilevault
# See also:     https://support.apple.com/guide/deployment/dep82a4aa5a/web

msg_success "FileVault check complete."
