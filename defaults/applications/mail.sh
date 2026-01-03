#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Apple Mail Settings
#
# DESCRIPTION:
#   Configures Apple Mail.app preferences including privacy settings,
#   composition, viewing, and behavior options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Mail.app should be quit before running these commands
#
# REFERENCES:
#   - Apple Support: Use Mail on your Mac
#     https://support.apple.com/guide/mail/welcome/mac
#   - Apple Support: Mail Privacy Protection
#     https://support.apple.com/guide/mail/use-mail-privacy-protection-mlhl03be2866/mac
#
# DOMAIN:
#   com.apple.mail
#
# NOTES:
#   - Account-specific settings are stored in account preferences
#   - Some settings require Mail to be restarted
#   - iCloud Mail settings sync across devices
#
# ==============================================================================

msg_info "Configuring Apple Mail settings..."

# ==============================================================================
# Privacy Settings
# ==============================================================================

# --- Protect Mail Activity (Mail Privacy Protection) ---
# Key:          ProtectMailActivityInICloud
# Domain:       com.apple.mail
# Description:  Hide IP address and load remote content privately.
#               This prevents senders from knowing when you read emails.
# Default:      true (since macOS Monterey)
# Options:      true = Enable Mail Privacy Protection
#               false = Disable (allow tracking)
# Set to:       true (protect privacy)
# UI Location:  Mail > Settings > Privacy > Protect Mail Activity
# Source:       https://support.apple.com/guide/mail/use-mail-privacy-protection-mlhl03be2866/mac
run_defaults "com.apple.mail" "ProtectMailActivityInICloud" "-bool" "true"

# --- Block Remote Content ---
# Key:          DisableURLLoading
# Domain:       com.apple.mail
# Description:  Block loading of remote images and content in emails.
#               Prevents tracking pixels from loading automatically.
# Default:      false (load remote content)
# Options:      true = Block remote content
#               false = Allow remote content
# Set to:       true (block for privacy when Mail Privacy Protection is off)
# UI Location:  Mail > Settings > Privacy > Block All Remote Content
# Note:         If Mail Privacy Protection is on, this is less important
run_defaults "com.apple.mail" "DisableURLLoading" "-bool" "true"

# ==============================================================================
# Viewing Options
# ==============================================================================

# --- Show Conversation View ---
# Key:          ConversationViewEnabled
# Domain:       com.apple.mail
# Description:  Group related messages into conversation threads.
# Default:      true
# Options:      true = Enable conversation view
#               false = Show individual messages
# Set to:       true (group conversations)
# UI Location:  View > Organize by Conversation
run_defaults "com.apple.mail" "ConversationViewEnabled" "-bool" "true"

# --- Include Related Messages ---
# Key:          ConversationViewAllMailboxes
# Domain:       com.apple.mail
# Description:  Include related messages from all mailboxes in conversations.
# Default:      false
# Options:      true = Include from all mailboxes
#               false = Only current mailbox
# Set to:       true (see full conversation context)
# UI Location:  View > Include Related Messages
run_defaults "com.apple.mail" "ConversationViewAllMailboxes" "-bool" "true"

# --- Most Recent Message on Top ---
# Key:          ConversationViewSortDescending
# Domain:       com.apple.mail
# Description:  Show newest messages at the top of conversation threads.
# Default:      true
# Options:      true = Newest on top
#               false = Oldest on top
# Set to:       true (newest first)
# UI Location:  View > Sort By > Date (Descending)
run_defaults "com.apple.mail" "ConversationViewSortDescending" "-bool" "true"

# --- Mark All Messages as Read When Opening Conversation ---
# Key:          ConversationViewMarkAllAsRead
# Domain:       com.apple.mail
# Description:  Automatically mark all messages in a conversation as read.
# Default:      false
# Options:      true = Mark all as read
#               false = Only mark selected as read
# Set to:       false (manually mark as read)
run_defaults "com.apple.mail" "ConversationViewMarkAllAsRead" "-bool" "false"

# ==============================================================================
# Composing Messages
# ==============================================================================

# --- Default Message Format ---
# Key:          SendFormat
# Domain:       com.apple.mail
# Description:  Default format for composing new messages.
# Default:      MIME (Rich Text)
# Options:      Plain = Plain text only
#               MIME = Rich text with formatting
# Set to:       MIME (rich text for formatting)
# UI Location:  Mail > Settings > Composing > Message Format
run_defaults "com.apple.mail" "SendFormat" "-string" "MIME"

# --- Quote Original Message on Reply ---
# Key:          ReplyQuotesOriginal
# Domain:       com.apple.mail
# Description:  Include original message text when replying.
# Default:      true
# Options:      true = Include quoted text
#               false = No quoted text
# Set to:       true (include context)
# UI Location:  Mail > Settings > Composing > Include original message text
run_defaults "com.apple.mail" "ReplyQuotesOriginal" "-bool" "true"

# --- Increase Quote Level ---
# Key:          IncreaseQuoteLevel
# Domain:       com.apple.mail
# Description:  Add quote level indicators (>) for nested replies.
# Default:      true
# Options:      true = Show quote levels
#               false = No quote level indicators
# Set to:       true (show quote levels)
run_defaults "com.apple.mail" "IncreaseQuoteLevel" "-bool" "true"

# ==============================================================================
# Behavior Settings
# ==============================================================================

# --- Add Invitations to Calendar Automatically ---
# Key:          AddInvitationsToCalendar
# Domain:       com.apple.mail
# Description:  Automatically add meeting invitations to Calendar.
# Default:      true
# Options:      true = Add automatically
#               false = Ask or ignore
# Set to:       true (add invitations)
# UI Location:  Mail > Settings > General > Add invitations to Calendar
run_defaults "com.apple.mail" "AddInvitationsToCalendar" "-bool" "true"

# --- Check for New Messages Automatically ---
# Key:          PollTime
# Domain:       com.apple.mail
# Description:  How often to check for new mail (in minutes).
#               Use -1 for manual checking only.
# Default:      -1 (automatic based on push)
# Options:      -1 = Automatic
#               1, 5, 15, 30, 60 = Minutes
# Set to:       -1 (automatic/push)
# UI Location:  Mail > Settings > General > Check for new messages
run_defaults "com.apple.mail" "PollTime" "-int" "-1"

# --- Enable Notification Sound ---
# Key:          PlayMailSounds
# Domain:       com.apple.mail
# Description:  Play sound when new mail arrives.
# Default:      true
# Options:      true = Play sounds, false = Silent
# Set to:       true (audio notification)
# UI Location:  Mail > Settings > General > New message notifications
run_defaults "com.apple.mail" "PlayMailSounds" "-bool" "true"

# --- Show Unread Count in Dock ---
# Key:          ShouldShowUnreadMessagesInDockIcon
# Domain:       com.apple.mail
# Description:  Display unread message count on Dock icon badge.
# Default:      true
# Options:      true = Show badge, false = No badge
# Set to:       true (show unread count)
# UI Location:  Not directly in Mail settings (Dock preferences)
run_defaults "com.apple.mail" "ShouldShowUnreadMessagesInDockIcon" "-bool" "true"

# ==============================================================================
# Junk Mail
# ==============================================================================

# --- Enable Junk Mail Filter ---
# Key:          JunkMailBehavior
# Domain:       com.apple.mail
# Description:  Controls how junk mail is handled.
# Default:      0 (enabled, mark as junk)
# Options:      0 = Disabled
#               1 = Enabled, mark as junk
#               2 = Enabled, move to Junk mailbox
# Set to:       2 (move to Junk folder)
# UI Location:  Mail > Settings > Junk Mail
run_defaults "com.apple.mail" "JunkMailBehavior" "-int" "2"

# --- Trust Junk Mail Headers in Messages ---
# Key:          TrustSpamHeaders
# Domain:       com.apple.mail
# Description:  Trust spam headers from mail server.
# Default:      true
# Options:      true = Trust server headers
#               false = Use local filtering only
# Set to:       true (trust server classification)
run_defaults "com.apple.mail" "TrustSpamHeaders" "-bool" "true"

msg_success "Apple Mail settings configured."

# ==============================================================================
# Restart Mail
#
# Mail settings require restarting the app:
#   killall Mail
#
# Or quit and reopen Mail.app manually.
#
# ==============================================================================
