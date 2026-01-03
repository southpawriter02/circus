#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Contacts Configuration
#
# DESCRIPTION:
#   This script configures Apple Contacts preferences including sort order,
#   display format, address format, and vCard export settings. Contacts syncs
#   with iCloud and integrates with Mail, Messages, and other apps.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Contacts app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Contacts User Guide
#     https://support.apple.com/guide/contacts/welcome/mac
#   - Apple Support: Change Contacts preferences
#     https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
#
# DOMAIN:
#   com.apple.AddressBook
#
# NOTES:
#   - Contacts preferences are stored in ~/Library/Preferences/com.apple.AddressBook.plist
#   - Contact data is stored in ~/Library/Application Support/AddressBook/
#   - iCloud contacts sync automatically when signed in
#   - Changes take effect immediately; no restart required
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Contacts preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Contacts settings..."

# ==============================================================================
# Display Settings
# ==============================================================================

# --- Sort Order ---
# Key:          ABNameSortingFormat
# Domain:       com.apple.AddressBook
# Description:  Controls how contacts are sorted in the contact list. Choose
#               between sorting by first name or last name.
# Default:      sortingFirstName sortingLastName (sort by first name)
# Options:      "sortingFirstName sortingLastName" = Sort by first name
#               "sortingLastName sortingFirstName" = Sort by last name
# Set to:       "sortingLastName sortingFirstName" (professional/alphabetical)
# UI Location:  Contacts > Settings > General > Sort By
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABNameSortingFormat" "-string" "sortingLastName sortingFirstName"

# --- Display Order ---
# Key:          ABNameDisplay
# Domain:       com.apple.AddressBook
# Description:  Controls how contact names are displayed in the list (first name
#               first vs. last name first).
# Default:      0 (First name first: "John Smith")
# Options:      0 = First name first (John Smith)
#               1 = Last name first (Smith, John)
# Set to:       0 (natural reading order)
# UI Location:  Contacts > Settings > General > Show First Name
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABNameDisplay" "-int" "0"

# --- Show Nickname ---
# Key:          ABShowNickname
# Domain:       com.apple.AddressBook
# Description:  Controls whether nicknames are displayed alongside or instead of
#               real names when available.
# Default:      false
# Options:      true  = Show nickname when available
#               false = Always show real name
# Set to:       true (personalized display)
# UI Location:  Contacts > Settings > General > Nickname
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABShowNickname" "-bool" "true"

# --- Prefer Nickname ---
# Key:          ABPrefersNickname
# Domain:       com.apple.AddressBook
# Description:  When enabled and a nickname exists, display the nickname instead
#               of the first name throughout the system.
# Default:      false
# Options:      true  = Use nickname instead of first name
#               false = Use first name, show nickname separately
# Set to:       false (keep real names visible)
# UI Location:  Contacts > Settings > General > Prefer nicknames
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABPrefersNickname" "-bool" "false"

# ==============================================================================
# Address Format Settings
# ==============================================================================

# --- Default Country Code ---
# Key:          ABDefaultAddressCountryCode
# Domain:       com.apple.AddressBook
# Description:  Sets the default country for new addresses. Uses ISO 3166-1
#               alpha-2 country codes.
# Default:      (system locale)
# Options:      Any valid ISO country code (us, gb, de, fr, jp, etc.)
# Set to:       "us" (United States)
# UI Location:  Contacts > Settings > General > Address Format
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABDefaultAddressCountryCode" "-string" "us"

# ==============================================================================
# vCard Export Settings
# ==============================================================================

# --- vCard Format ---
# Key:          ABUse21telephones
# Domain:       com.apple.AddressBook
# Description:  Controls whether exported vCards use the older vCard 2.1 format
#               for phone number labels. Disable for better compatibility with
#               modern systems.
# Default:      false
# Options:      true  = Use vCard 2.1 phone labels (legacy compatibility)
#               false = Use modern vCard 3.0 phone labels
# Set to:       false (modern format)
# UI Location:  Contacts > Settings > vCard > vCard Format
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABUse21telephones" "-bool" "false"

# --- Include Photo in vCard ---
# Key:          ABIncludePhotosInVCards
# Domain:       com.apple.AddressBook
# Description:  Controls whether contact photos are included when exporting
#               vCards. Photos increase file size but provide visual context.
# Default:      true
# Options:      true  = Include photos in exported vCards
#               false = Export vCards without photos
# Set to:       true (complete contact info)
# UI Location:  Contacts > Settings > vCard > Export photos in vCards
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABIncludePhotosInVCards" "-bool" "true"

# --- Include Notes in vCard ---
# Key:          ABIncludeNotesInVCard
# Domain:       com.apple.AddressBook
# Description:  Controls whether notes are included when exporting vCards.
#               Disable if notes contain sensitive information.
# Default:      true
# Options:      true  = Include notes in exported vCards
#               false = Export vCards without notes
# Set to:       false (privacy - notes may contain private info)
# UI Location:  Contacts > Settings > vCard > Export notes in vCards
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABIncludeNotesInVCard" "-bool" "false"

# ==============================================================================
# My Card Settings
# ==============================================================================

# --- Show First Name Before Company ---
# Key:          ABShowCompanyAsLastName
# Domain:       com.apple.AddressBook
# Description:  For contacts marked as companies, controls whether the company
#               name appears in place of the last name.
# Default:      true
# Options:      true  = Show company name in last name position
#               false = Show person name normally, company separate
# Set to:       true (clear company identification)
# UI Location:  Contact card settings
# Source:       https://support.apple.com/guide/contacts/change-preferences-adrb7e5aaa2a/mac
run_defaults "com.apple.AddressBook" "ABShowCompanyAsLastName" "-bool" "true"

msg_success "Contacts settings applied."
