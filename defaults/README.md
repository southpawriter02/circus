# macOS Defaults Configuration

This directory contains scripts that configure macOS system and application preferences using the `defaults` command and other system utilities. The scripts are organized logically by category for easy navigation and maintenance.

## Overview

The `defaults` command is a macOS utility that reads and writes application and system preferences stored in property list (plist) files. These scripts automate the configuration of a new Mac with sensible defaults for developers and power users.

## Privacy & Security Profiles

In addition to the base defaults, you can choose a privacy/security profile that applies additional settings based on your security requirements:

| Profile | Description |
|---------|-------------|
| `standard` | Balanced security and convenience (default) |
| `privacy` | Enhanced privacy - disables telemetry, limits tracking |
| `lockdown` | Maximum security for high-risk environments |

To apply a profile during installation:

```bash
./install.sh --privacy-profile privacy
```

See [profiles/README.md](profiles/README.md) for detailed documentation on each profile.

## Directory Structure

```
defaults/
├── README.md                    # This file
├── profiles/                    # Privacy and security profiles
│   ├── README.md                # Profile documentation
│   ├── standard.sh              # Standard profile (default)
│   ├── privacy.sh               # Enhanced privacy profile
│   └── lockdown.sh              # Maximum security profile
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

Each script follows a consistent documentation format:

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

Each individual setting is documented with:

- **Key**: The preference key being set
- **Description**: What the setting does
- **Default**: The macOS default value
- **Possible**: All possible values with explanations
- **Set to**: The value this script sets and why
- **Reference**: Where to find this setting in System Preferences (if applicable)

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
