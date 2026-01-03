# Raycast Script Commands Integration

The Flying Circus Raycast script commands provide quick access to common `fc` commands directly from Raycast's launcher.

## Requirements

- **Raycast** - [Download Raycast](https://www.raycast.com/)
- **Dotfiles Flying Circus** installed and configured

## Installation

```bash
fc raycast install
```

This command:
1. Detects your Raycast installation
2. Creates the `~/.raycast-script-commands/flying-circus/` directory
3. Copies all script commands
4. Configures the environment with your dotfiles location
5. Makes all scripts executable

Raycast automatically discovers script commands in this directory.

## Uninstallation

```bash
fc raycast uninstall
```

## Check Status

```bash
fc raycast status
```

## Available Commands

After installation, search for these commands in Raycast:

### System Control

| Command | Description | Mode |
|---------|-------------|------|
| Wi-Fi On | Turn on the Wi-Fi adapter | Silent |
| Wi-Fi Off | Turn off the Wi-Fi adapter | Silent |
| Wi-Fi Status | Show Wi-Fi adapter status | Compact |
| Bluetooth On | Turn on Bluetooth | Silent |
| Bluetooth Off | Turn off Bluetooth | Silent |
| Bluetooth Status | Show Bluetooth status | Compact |
| Lock Screen | Lock screen immediately | Silent |
| Caffeine On | Prevent sleep indefinitely | Silent |
| Caffeine Off | Allow sleep | Silent |
| Caffeine 30 Minutes | Prevent sleep for 30 min | Silent |
| Caffeine 1 Hour | Prevent sleep for 1 hour | Silent |
| Caffeine Status | Show caffeine status | Compact |

### Network

| Command | Description | Mode |
|---------|-------------|------|
| DNS Status | Show current DNS servers | Compact |
| DNS: Cloudflare | Set DNS to Cloudflare (1.1.1.1) | Silent |
| DNS: Google | Set DNS to Google (8.8.8.8) | Silent |
| DNS: Quad9 | Set DNS to Quad9 (9.9.9.9) | Silent |
| DNS: Clear | Clear custom DNS (use DHCP) | Silent |
| AirDrop: Everyone | Set AirDrop to everyone | Silent |
| AirDrop: Contacts Only | Set AirDrop to contacts only | Silent |
| AirDrop: Off | Turn off AirDrop | Silent |
| AirDrop Status | Show AirDrop status | Compact |

### Information & Diagnostics

| Command | Description | Mode |
|---------|-------------|------|
| System Info | Show system information | Full Output |
| System Healthcheck | Run system diagnostics | Full Output |
| Disk Status | Show disk status summary | Compact |
| Disk Usage | Show detailed disk usage | Full Output |

### SSH & Utilities

| Command | Description | Mode |
|---------|-------------|------|
| SSH: List Keys | List SSH keys | Compact |
| SSH: Copy Public Key | Copy default public key to clipboard | Silent |
| Clipboard: Clear | Clear the clipboard | Silent |

## Usage Examples

### Quick Wi-Fi Toggle

1. Press `Cmd + Space` to open Raycast
2. Type "Wi-Fi"
3. Select "Wi-Fi On" or "Wi-Fi Off"

### Lock Screen

1. Press `Cmd + Space`
2. Type "Lock"
3. Press Enter - screen locks immediately

### Prevent Sleep

1. Type "Caffeine"
2. Select duration (30 min, 1 hour, or indefinitely)

### Switch DNS

1. Type "DNS"
2. Select a provider (Cloudflare, Google, Quad9) or "Clear"

### Copy SSH Key

1. Type "SSH"
2. Select "SSH: Copy Public Key"
3. Key is copied to clipboard

## Raycast Modes

Script commands use different output modes:

- **Silent** - Command runs and shows a notification (for toggle commands)
- **Compact** - Shows single-line output in Raycast (for status commands)
- **Full Output** - Shows full output in Raycast window (for detailed info)

## Troubleshooting

### Commands not appearing in Raycast

1. Check installation status:
   ```bash
   fc raycast status
   ```

2. Try reinstalling:
   ```bash
   fc raycast uninstall
   fc raycast install
   ```

3. Refresh Raycast's script command index:
   - Open Raycast preferences
   - Go to Extensions > Script Commands
   - Click "Reload"

### Commands failing

1. Ensure fc commands work from Terminal first:
   ```bash
   fc wifi status
   ```

2. Check that the environment script has your dotfiles location:
   ```bash
   cat ~/.raycast-script-commands/flying-circus/fc-env.sh | grep DOTFILES_ROOT
   ```

3. Verify scripts are executable:
   ```bash
   ls -la ~/.raycast-script-commands/flying-circus/
   ```

### Script not finding fc command

The `fc-env.sh` script sets up the PATH. If commands aren't found:

1. Check the DOTFILES_ROOT path is correct:
   ```bash
   cat ~/.raycast-script-commands/flying-circus/fc-env.sh
   ```

2. Reinstall to update the path:
   ```bash
   fc raycast install
   ```

## Script Command Architecture

Each script command is a standalone bash script with Raycast metadata:

```bash
#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Wi-Fi On
# @raycast.mode silent
# @raycast.icon 📶
# @raycast.packageName Flying Circus
# @raycast.description Turn on the Wi-Fi adapter

source "$(dirname "$0")/fc-env.sh"
fc wifi on
```

The `fc-env.sh` script sets up the environment:
- Configures PATH for Homebrew (Apple Silicon and Intel)
- Sets DOTFILES_ROOT to your dotfiles location
- Adds the fc bin directory to PATH

## Source Files

The script command source files are located at:
```
$DOTFILES_ROOT/etc/raycast/scripts/
├── fc-env.sh              # Shared environment setup
├── wifi-on.sh             # Wi-Fi: Turn on
├── wifi-off.sh            # Wi-Fi: Turn off
├── wifi-status.sh         # Wi-Fi: Show status
├── bluetooth-on.sh        # Bluetooth: Turn on
├── bluetooth-off.sh       # Bluetooth: Turn off
├── bluetooth-status.sh    # Bluetooth: Show status
├── lock-screen.sh         # Lock screen
├── caffeine-on.sh         # Caffeine: On indefinitely
├── caffeine-off.sh        # Caffeine: Off
├── caffeine-30min.sh      # Caffeine: 30 minutes
├── caffeine-60min.sh      # Caffeine: 1 hour
├── caffeine-status.sh     # Caffeine: Status
├── dns-status.sh          # DNS: Status
├── dns-cloudflare.sh      # DNS: Cloudflare
├── dns-google.sh          # DNS: Google
├── dns-quad9.sh           # DNS: Quad9
├── dns-clear.sh           # DNS: Clear
├── airdrop-everyone.sh    # AirDrop: Everyone
├── airdrop-contacts.sh    # AirDrop: Contacts
├── airdrop-off.sh         # AirDrop: Off
├── airdrop-status.sh      # AirDrop: Status
├── system-info.sh         # System info
├── system-healthcheck.sh  # System healthcheck
├── disk-status.sh         # Disk status
├── disk-usage.sh          # Disk usage
├── ssh-list.sh            # SSH: List keys
├── ssh-copy-default.sh    # SSH: Copy public key
└── clipboard-clear.sh     # Clipboard: Clear
```

## Comparison with Alfred Workflow

| Feature | Alfred | Raycast |
|---------|--------|---------|
| Installation | `fc alfred install` | `fc raycast install` |
| Structure | Single workflow with keywords | Individual script commands |
| Selection | Type keyword, choose from list | Type command name directly |
| Output | Notifications | Notifications or inline output |
| Requirements | Alfred Powerpack | Free Raycast |

## Related Documentation

- [Commands Reference](../COMMANDS.md) - Full fc command documentation
- [Alfred Workflow](./ALFRED.md) - Alfred integration
- [Raycast Script Commands](https://manual.raycast.com/script-commands) - Official Raycast documentation
