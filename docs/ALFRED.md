# Alfred Workflow Integration

The Flying Circus Alfred workflow provides quick access to common `fc` commands directly from Alfred's search bar.

## Requirements

- **Alfred 4 or 5** - [Download Alfred](https://www.alfredapp.com/)
- **Alfred Powerpack** (recommended) - Required for workflow features
- **Dotfiles Flying Circus** installed and configured

## Installation

```bash
fc alfred install
```

This command:
1. Detects your Alfred installation
2. Copies the workflow to Alfred's workflow directory
3. Configures the workflow with your dotfiles location
4. Makes all scripts executable

## Uninstallation

```bash
fc alfred uninstall
```

## Check Status

```bash
fc alfred status
```

## Available Commands

After installation, you can use these keywords in Alfred:

### System Control

| Keyword | Description | Actions |
|---------|-------------|---------|
| `wifi` | Control Wi-Fi adapter | on, off, status |
| `bluetooth` | Control Bluetooth | on, off, status |
| `lock` | Lock screen | (immediate) |
| `caffeine` | Prevent sleep | on, off, for 30/60/120 min, status |

### Network

| Keyword | Description | Actions |
|---------|-------------|---------|
| `dns` | Manage DNS servers | status, Cloudflare, Google, Quad9, clear |
| `airdrop` | Control AirDrop | everyone, contacts, off, status |

### Information

| Keyword | Description | Actions |
|---------|-------------|---------|
| `fcinfo` | System information | (immediate) |
| `healthcheck` | System diagnostics | (immediate) |
| `disk` | Disk utilities | status, usage, large files, cleanup |

### SSH & Secrets

| Keyword | Description | Actions |
|---------|-------------|---------|
| `sshkey` | SSH key management | list, copy, generate, add |
| `keychain` | Keychain access | list, wifi passwords, search |
| `clip` | Clipboard utilities | show, count, clear, plain text |

### Browse All

| Keyword | Description |
|---------|-------------|
| `fc` | Browse all available commands |

## Usage Examples

### Quick Wi-Fi Toggle

1. Press `Cmd + Space` to open Alfred
2. Type `wifi`
3. Select "Wi-Fi On" or "Wi-Fi Off"

### Lock Screen

1. Press `Cmd + Space`
2. Type `lock`
3. Press Enter - screen locks immediately

### Prevent Sleep

1. Type `caffeine`
2. Select duration (30 min, 1 hour, 2 hours, or indefinitely)

### Switch DNS

1. Type `dns`
2. Select a provider (Cloudflare, Google, Quad9) or "Clear" for DHCP

### Copy SSH Key

1. Type `sshkey`
2. Select "SSH: Copy Public Key"
3. Key is copied to clipboard

## Workflow Architecture

The workflow uses Alfred's Script Filter feature to provide dynamic options:

```
[Keyword Trigger] → [Script Filter] → [Run Script] → [Notification]
```

- **Script Filters** return JSON with available options
- **Run Script** executes the actual `fc` command
- **Notification** displays the result

## Troubleshooting

### Workflow not appearing in Alfred

1. Check installation status:
   ```bash
   fc alfred status
   ```

2. Try reinstalling:
   ```bash
   fc alfred uninstall
   fc alfred install
   ```

3. Restart Alfred:
   - Click Alfred icon in menu bar
   - Choose "Quit Alfred"
   - Reopen Alfred

### Commands failing

1. Ensure fc commands work from Terminal first:
   ```bash
   fc wifi status
   ```

2. Check that the workflow has the correct dotfiles path:
   ```bash
   fc alfred status
   ```

3. Verify the wrapper script has your dotfiles location:
   ```bash
   cat ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences/workflows/Flying\ Circus/scripts/fc-wrapper.sh | grep DOTFILES_ROOT
   ```

### Alfred Powerpack required

Some workflow features require Alfred Powerpack (paid upgrade). Without Powerpack:
- Workflows may not be available
- Script Filters may not work

## Customization

### Adding New Commands

To add a new command to the workflow:

1. Create a script filter in `etc/alfred/workflows/Flying Circus/scripts/`
2. Add keyword and filter objects to `info.plist`
3. Connect them to the shared `FC-RUN-SCRIPT` action
4. Reinstall: `fc alfred install`

### Modifying Keywords

Edit `etc/alfred/workflows/Flying Circus/info.plist` to change:
- Keyword triggers (e.g., change `wifi` to `wf`)
- Descriptions and subtitles
- Icon assignments

## Source Files

The workflow source files are located at:
```
$DOTFILES_ROOT/etc/alfred/workflows/Flying Circus/
├── info.plist          # Workflow definition
├── icon.png            # Workflow icon
└── scripts/
    ├── fc-wrapper.sh   # Environment setup wrapper
    ├── wifi.sh         # Wi-Fi script filter
    ├── bluetooth.sh    # Bluetooth script filter
    ├── caffeine.sh     # Caffeine script filter
    ├── dns.sh          # DNS script filter
    ├── airdrop.sh      # AirDrop script filter
    ├── disk.sh         # Disk script filter
    ├── ssh.sh          # SSH script filter
    ├── keychain.sh     # Keychain script filter
    ├── clipboard.sh    # Clipboard script filter
    └── fc-commands.sh  # Main fc command browser
```

## Related Documentation

- [Commands Reference](../COMMANDS.md) - Full fc command documentation
- [Alfred Help](https://www.alfredapp.com/help/) - Official Alfred documentation
- [Alfred Workflow Development](https://www.alfredapp.com/help/workflows/) - Creating workflows
