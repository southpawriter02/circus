# macOS Defaults Configuration

This directory contains scripts that configure macOS system and application preferences using the `defaults` command and other system utilities. The scripts are organized logically by category for easy navigation and maintenance.

## Overview

The `defaults` command is a macOS utility that reads and writes application and system preferences stored in property list (plist) files. These scripts automate the configuration of a new Mac with sensible defaults for developers and power users.

## Directory Structure

```
defaults/
├── README.md                    # This file
├── system/                      # System-level settings
│   ├── auto_updates.sh          # Automated maintenance agent
│   ├── core.sh                  # Core system settings (systemsetup)
│   ├── firewall.sh              # Application firewall
│   ├── screensaver.sh           # Screen saver and lock
│   ├── software_update.sh       # Software Update & App Store
│   └── time_machine.sh          # Time Machine backup
├── interface/                   # User interface settings
│   ├── activity_monitor.sh      # Activity Monitor app
│   ├── dock.sh                  # Dock configuration
│   ├── finder.sh                # Finder preferences
│   ├── mission_control.sh       # Mission Control, Spaces, Hot Corners
│   └── ui_ux.sh                 # Global UI/UX settings
├── input/                       # Input device settings
│   ├── keyboard.sh              # Keyboard preferences
│   └── trackpad_mouse.sh        # Trackpad and mouse
└── applications/                # Application-specific settings
    ├── alfred.sh                # Alfred launcher
    ├── docker.sh                # Docker Desktop
    ├── iterm2.sh                # iTerm2 terminal
    ├── mariadb.sh               # MariaDB database
    ├── nvm.sh                   # Node Version Manager
    ├── safari.sh                # Safari browser
    ├── textedit.sh              # TextEdit editor
    └── vscode.sh                # Visual Studio Code
```

## Categories

### System (`defaults/system/`)

Core system-level settings that affect security, stability, and system behavior.

| Script | Description |
|--------|-------------|
| `auto_updates.sh` | Installs a launchd agent for automated dotfiles and Homebrew updates |
| `core.sh` | Network time, timezone, remote login, and restart-on-freeze settings |
| `firewall.sh` | Configures the macOS Application Firewall with stealth mode |
| `screensaver.sh` | Screen saver activation and password-on-wake settings |
| `software_update.sh` | Automatic software and security update settings |
| `time_machine.sh` | Time Machine exclusions for developer directories |

### Interface (`defaults/interface/`)

User interface and window management settings.

| Script | Description |
|--------|-------------|
| `activity_monitor.sh` | Activity Monitor default view and sorting |
| `dock.sh` | Dock apps, folders, and layout (requires `dockutil`) |
| `finder.sh` | Finder views, hidden files, extensions, and navigation |
| `mission_control.sh` | Spaces behavior and Hot Corners configuration |
| `ui_ux.sh` | Scrollbars, dialog boxes, and quarantine settings |

### Input (`defaults/input/`)

Keyboard, trackpad, and mouse settings.

| Script | Description |
|--------|-------------|
| `keyboard.sh` | Key repeat rate, delay, and full keyboard access |
| `trackpad_mouse.sh` | Tap to click, tracking speed, and scroll direction |

### Applications (`defaults/applications/`)

Settings for third-party and system applications.

| Script | Description |
|--------|-------------|
| `alfred.sh` | Alfred preferences sync folder |
| `docker.sh` | Docker Desktop resource allocation |
| `iterm2.sh` | iTerm2 preferences sync folder |
| `mariadb.sh` | MariaDB service startup and security instructions |
| `nvm.sh` | Node Version Manager setup and LTS installation |
| `safari.sh` | Safari developer tools, privacy, and security |
| `textedit.sh` | TextEdit plain text mode and font settings |
| `vscode.sh` | VS Code extensions and settings symlink |

## Documentation Format

Each script follows a consistent documentation format with two levels: a **header block** for script-level information and **inline documentation** for each setting.

### Header Block Format

```bash
#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: [Script Name]
#
# DESCRIPTION:
#   Brief description of what the script configures.
#
# REQUIRES:
#   - Prerequisites and dependencies
#
# REFERENCES:
#   - Apple Support/Documentation links
#   - Third-party documentation
#   - man page references
#
# DOMAIN:
#   The preference domain(s) being modified
#
# NOTES:
#   - Additional information and tips
#
# ==============================================================================
```

### Inline Setting Documentation (Enhanced Format)

Each individual setting should be documented with the following fields:

```bash
# --- Setting Name ---
# Key:          preference_key_name
# Description:  What this setting does. Include context about why a user
#               might want to change it and how it affects system behavior.
# Default:      value (description of Apple's default)
# Options:      value1 = Description of what this value does
#               value2 = Description of what this value does
#               value3 = Description of what this value does
# Set to:       value (rationale for why we chose this value)
# UI Location:  System Settings > Category > Subcategory > Setting name
# Source:       https://support.apple.com/... (official Apple documentation URL)
# See also:     https://... (optional additional references)
# Note:         Optional additional context, warnings, or tips
```

#### Field Descriptions

| Field | Required | Description |
|-------|----------|-------------|
| `Key` | Yes | The exact preference key name used in the `defaults write` command |
| `Description` | Yes | Clear explanation of what the setting controls and its impact |
| `Default` | Yes | Apple's default value with a brief description |
| `Options` | Yes | All valid values with explanations (use `=` to separate value from description) |
| `Set to` | Yes | The value this script configures, with rationale |
| `UI Location` | Yes | Path in System Settings/Preferences to find this setting |
| `Source` | Yes | URL to official Apple documentation for this setting |
| `See also` | No | Additional reference URLs (other Apple docs, man pages, etc.) |
| `Note` | No | Warnings, tips, or additional context |
| `Security` | No | Security implications (for security-related settings) |

#### Example: Complete Setting Documentation

```bash
# --- Require Password After Sleep or Screen Saver ---
# Key:          askForPassword
# Description:  Controls whether a password is required to exit the screensaver
#               or wake the display from sleep. This is a critical security
#               setting that prevents unauthorized access to an unattended Mac.
#               When enabled, the login password (or Touch ID/Apple Watch) is
#               required to unlock.
# Default:      0 (disabled - no password required to wake)
# Options:      0 = Disabled (no authentication required to unlock)
#               1 = Enabled (password/Touch ID required to unlock)
# Set to:       1 (require password for security)
# UI Location:  System Settings > Lock Screen > Require password after screen
#               saver begins or display is turned off
# Source:       https://support.apple.com/guide/mac-help/require-a-password-after-waking-your-mac-mchlp2270/mac
# Security:     Essential for protecting data on shared or portable Macs.
#               Combine with a short password delay for maximum security.
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"
```

### Documentation Progress

The following scripts have been updated with enhanced inline documentation including source citations:

| Script | Status | Last Updated |
|--------|--------|--------------|
| `input/trackpad_mouse.sh` | ✅ Complete | 2025-12-04 |
| `input/keyboard.sh` | ✅ Complete | 2025-12-04 |
| `system/screensaver.sh` | ✅ Complete | 2025-12-04 |
| `system/firewall.sh` | ✅ Complete | 2025-12-04 |
| `system/software_update.sh` | ✅ Complete | 2025-12-04 |
| `interface/activity_monitor.sh` | ✅ Complete | 2025-12-04 |
| `interface/finder.sh` | ✅ Complete | 2025-12-04 |
| `interface/mission_control.sh` | ✅ Complete | 2025-12-04 |
| `interface/ui_ux.sh` | ✅ Complete | 2025-12-04 |
| `applications/safari.sh` | ✅ Complete | 2025-12-04 |
| `applications/textedit.sh` | ✅ Complete | 2025-12-04 |
| `interface/dock.sh` | ⚠️ Partial | Uses dockutil, different format |
| `system/time_machine.sh` | 📋 Pending | Needs documentation update |
| `system/core.sh` | 📋 Pending | Needs documentation update |
| `system/auto_updates.sh` | 📋 Pending | Needs documentation update |
| `applications/alfred.sh` | 📋 Pending | Needs documentation update |
| `applications/docker.sh` | 📋 Pending | Needs documentation update |
| `applications/iterm2.sh` | 📋 Pending | Needs documentation update |
| `applications/mariadb.sh` | 📋 Pending | Needs documentation update |
| `applications/nvm.sh` | 📋 Pending | Needs documentation update |
| `applications/vscode.sh` | 📋 Pending | Needs documentation update |

**Legend:**
- ✅ Complete: Full enhanced documentation with source citations
- ⚠️ Partial: Has documentation structure but missing source URLs
- 📋 Pending: Needs documentation update

### Finding Apple Documentation Sources

When adding source citations, use these Apple Support resources:

1. **Mac Help Guides**: `https://support.apple.com/guide/mac-help/`
2. **Activity Monitor Guide**: `https://support.apple.com/guide/activity-monitor/`
3. **Safari Guide**: `https://support.apple.com/guide/safari/`
4. **General Support Articles**: `https://support.apple.com/en-us/HT...`

Search tips:
- Use `site:support.apple.com` in Google for targeted searches
- Look for guides specific to the app domain (e.g., `/guide/activity-monitor/`)
- Prefer permanent guide URLs over knowledge base articles when possible

## Usage

### Running Individual Scripts

Scripts can be run individually:

```bash
# Source the helpers first
source lib/helpers.sh

# Run a specific defaults script
./defaults/interface/finder.sh
```

### Dry Run Mode

All scripts support dry run mode to preview changes without applying them:

```bash
export DRY_RUN_MODE=true
./defaults/interface/finder.sh
```

### Running All Defaults

During installation, Stage 11 sources all defaults scripts:

```bash
./install.sh
# Or with dry run:
./install.sh --dry-run
```

## References

### Apple Documentation

- [defaults man page](x-man-page://defaults)
- [systemsetup man page](x-man-page://systemsetup)
- [launchctl man page](x-man-page://launchctl)
- [Apple Support](https://support.apple.com)

### Inspiration

These scripts draw inspiration from:

- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles) - The canonical macOS defaults reference
- [Kevin Suttle's macOS Defaults](https://github.com/kevinSuttle/macOS-Defaults) - Comprehensive defaults documentation
- [Pawel Grzybek's macOS setup](https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/) - Clear explanations

## Notes

### Applying Changes

Some changes require specific actions to take effect:

- **Finder changes**: Finder is restarted automatically
- **Dock changes**: Dock is restarted automatically
- **Keyboard changes**: Require logout/restart
- **Firewall changes**: Firewall service is restarted
- **System settings**: Some require restart

### Security Considerations

Several scripts modify security-related settings:

- `firewall.sh` enables the application firewall with stealth mode
- `screensaver.sh` requires password on wake (no grace period)
- `software_update.sh` enables automatic security updates
- `ui_ux.sh` disables quarantine warnings (power-user setting)

Review these settings and adjust according to your security requirements.
