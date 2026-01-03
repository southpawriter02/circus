# Cross-Platform Support

Circus supports both macOS and Linux (including WSL). This guide explains platform compatibility and how to use Circus on different systems.

## Supported Platforms

| Platform | Support Level | Notes |
|----------|---------------|-------|
| **macOS 12+** | Full | All features available |
| **Ubuntu 22.04+** | Core | Most commands work |
| **Fedora 38+** | Core | Most commands work |
| **Arch Linux** | Core | Most commands work |
| **WSL 2** | Partial | Networking limited |

## Command Compatibility Matrix

### ✅ Full Cross-Platform Support

These commands work identically on macOS and Linux:

| Command | Description |
|---------|-------------|
| `fc vm` | Virtual machine management (Lima/Colima) |
| `fc sync` | Backup and sync (gpg/restic/borg) |
| `fc ssh` | SSH key management |
| `fc encrypt` | File encryption (GPG) |
| `fc update` | Self-update |
| `fc dotfiles` | Dotfile deployment |
| `fc profile` | Profile switching |
| `fc healthcheck` | System health checks |
| `fc disk` | Disk utilities |
| `fc info` | System information |
| `fc doctor` | Diagnostic checks |
| `fc wifi` | Wi-Fi control (v1.1.4) |
| `fc dns` | DNS management (v1.1.4) |
| `fc firewall` | Firewall control (v1.1.4) |
| `fc lock` | Screen lock (v1.1.5) |
| `fc caffeine` | Sleep prevention (v1.1.5) |
| `fc clipboard` | Clipboard utils (v1.1.6) |
| `fc apps` | Package management (v1.1.6) |
| `fc maintenance` | System cleanup (v1.1.6) |

### ❌ macOS-Only Commands

These commands are only available on macOS:

| Command | Reason |
|---------|--------|
| `fc bluetooth` | Uses blueutil (macOS) |
| `fc lock` | Uses macOS-specific APIs |
| `fc caffeine` | Uses caffeinate (macOS) |
| `fc keychain` | Uses macOS Keychain |
| `fc airdrop` | Apple-only feature |
| `fc alfred` | macOS-only application |
| `fc raycast` | macOS-only application |
| `fc defaults` | macOS defaults system |

Running a macOS-only command on Linux will display:

```
[ERROR] fc bluetooth is only available on macOS
```

## Linux Prerequisites

### Ubuntu/Debian

```bash
# Clipboard support
sudo apt install xclip

# Network management
sudo apt install network-manager

# Firewall
sudo apt install ufw
```

### Fedora

```bash
# Clipboard support
sudo dnf install xclip

# Firewall (usually pre-installed)
sudo dnf install firewalld
```

### Arch Linux

```bash
# Clipboard support
sudo pacman -S xclip

# Network and firewall
sudo pacman -S networkmanager ufw
```

## Architecture

The cross-platform support is built on an OS abstraction layer:

```
lib/os/
├── detect.sh    # Platform detection
├── macos.sh     # macOS implementations
└── linux.sh     # Linux implementations
```

### Detection Functions

```bash
# Check current OS
detect_os          # Returns: macos, linux, wsl, or unknown
detect_distro      # Returns: ubuntu, fedora, arch, etc.

# Boolean checks
is_macos           # true on macOS
is_linux           # true on Linux (including WSL)
is_wsl             # true only on WSL

# Distro checks (Linux only)
is_debian_based    # ubuntu, debian, pop, mint
is_rhel_based      # fedora, rhel, centos, rocky
is_arch_based      # arch, manjaro, endeavouros
```

### Requirement Functions

```bash
# Guard for macOS-only features
require_macos "fc bluetooth"

# Guard for Linux-only features
require_linux "some-feature"
```

## WSL Considerations

WSL (Windows Subsystem for Linux) is detected as a separate platform. Some limitations:

- **Networking**: Wi-Fi/DNS management may not work (WSL uses Windows networking)
- **Clipboard**: Works if WSL clipboard integration is enabled
- **Display**: Requires WSLg or X server for GUI-dependent features

## Adding Linux Support to Plugins

To make a plugin cross-platform:

1. Use OS abstraction functions instead of direct commands:

```bash
# Instead of:
pbcopy < file.txt

# Use:
os_clipboard_copy < file.txt
```

2. For macOS-only plugins, add a guard:

```bash
main() {
    require_macos "fc your-command"
    # ... rest of plugin
}
```

## Future Roadmap

| Version | Focus |
|---------|-------|
| v1.1.3 | Foundation + Tier 1 (current) |
| v1.2.0 | Networking (wifi, dns, firewall) |
| v1.3.0 | Desktop (lock, caffeine) |
| v1.4.0 | Package management (apps) |

## Troubleshooting

### "No clipboard tool found"

Install a clipboard tool:
```bash
# Ubuntu/Debian
sudo apt install xclip

# Or for Wayland
sudo apt install wl-clipboard
```

### "NetworkManager not found"

Install NetworkManager:
```bash
sudo apt install network-manager
sudo systemctl enable NetworkManager
```

### "This feature is only available on macOS"

The command you're trying to use doesn't have a Linux implementation. Check the compatibility matrix above for alternatives.
