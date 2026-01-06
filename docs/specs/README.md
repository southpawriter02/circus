# Command Specifications

This directory contains **39 detailed specifications** for `fc` commands — the plugin-based command-line interface that powers the Dotfiles Flying Circus project.

---

## Overview

Each specification documents a single `fc` command and includes:

- **Overview** — Command purpose and use cases
- **Subcommands** — Available actions and options
- **Detailed Behaviors** — Expected output and examples
- **Dependencies** — Required tools and packages
- **Implementation Notes** — Technical details and `defaults` domains
- **Testing Strategy** — Manual verification steps

---

## Command Categories

### 🖥️ System & Hardware

Monitor and manage system resources.

| Command | Description |
|---------|-------------|
| [fc-battery](fc-battery.md) | Battery status, health, and power information |
| [fc-cpu](fc-cpu.md) | CPU usage, temperature, and process monitoring |
| [fc-disk](fc-disk.md) | Disk usage analysis and cleanup utilities |
| [fc-memory](fc-memory.md) | Memory usage and pressure monitoring |

---

### 🌐 Network & Connectivity

Control network interfaces and connections.

| Command | Description |
|---------|-------------|
| [fc-airdrop](fc-airdrop.md) | AirDrop visibility settings |
| [fc-bluetooth](fc-bluetooth.md) | Bluetooth adapter control |
| [fc-dns](fc-dns.md) | DNS server configuration |
| [fc-firewall](fc-firewall.md) | Application firewall management |
| [fc-network](fc-network.md) | Network diagnostics and information |
| [fc-vpn](fc-vpn.md) | VPN connection management |
| [fc-wifi](fc-wifi.md) | Wi-Fi adapter control |

---

### 🔐 Security & Privacy

Protect your system and data.

| Command | Description |
|---------|-------------|
| [fc-audit](fc-audit.md) | Security configuration auditing |
| [fc-encrypt](fc-encrypt.md) | File and folder encryption |
| [fc-gpg-setup](fc-gpg-setup.md) | GPG key generation and configuration |
| [fc-keychain](fc-keychain.md) | macOS Keychain access and management |
| [fc-lock](fc-lock.md) | Screen lock and security controls |
| [fc-privacy](fc-privacy.md) | Privacy permissions management |
| [fc-ssh-keygen](fc-ssh-keygen.md) | SSH key generation |

---

### ⚡ Productivity

Boost your workflow efficiency.

| Command | Description |
|---------|-------------|
| [fc-caffeine](fc-caffeine.md) | Prevent system sleep |
| [fc-clipboard](fc-clipboard.md) | Clipboard utilities and history |
| [fc-notify](fc-notify.md) | macOS notification management |
| [fc-qr](fc-qr.md) | QR code generation and scanning |
| [fc-screenshot](fc-screenshot.md) | Screenshot settings and capture |

---

### 🎨 macOS Customization

Configure your macOS experience.

| Command | Description |
|---------|-------------|
| [fc-defaults](fc-defaults.md) | System defaults and preferences |
| [fc-dock](fc-dock.md) | Dock appearance and behavior |
| [fc-finder](fc-finder.md) | Finder settings and preferences |
| [fc-quicklook](fc-quicklook.md) | Quick Look plugin management |
| [fc-spotlight](fc-spotlight.md) | Spotlight search configuration |
| [fc-trash](fc-trash.md) | Trash management and secure delete |

---

### 📦 Apps & Processes

Manage applications and system processes.

| Command | Description |
|---------|-------------|
| [fc-apps](fc-apps.md) | Application installation and management |
| [fc-cron](fc-cron.md) | Scheduled task management |
| [fc-kill](fc-kill.md) | Process termination utilities |
| [fc-launch](fc-launch.md) | Application launching shortcuts |
| [fc-redis](fc-redis.md) | Redis server management |

---

### 🔄 Sync & Backup

Keep your configuration synchronized.

| Command | Description |
|---------|-------------|
| [fc-backup](fc-backup.md) | Backup creation and restoration |
| [fc-sync](fc-sync.md) | Configuration synchronization |
| [fc-update](fc-update.md) | System and package updates |

---

### 🩺 Diagnostics

System health and troubleshooting.

| Command | Description |
|---------|-------------|
| [fc-doctor](fc-doctor.md) | System health diagnostics |
| [fc-info](fc-info.md) | System information display |

---

## Quick Reference

All commands in alphabetical order:

| Command | Category | Description |
|---------|----------|-------------|
| [fc-airdrop](fc-airdrop.md) | Network | AirDrop visibility |
| [fc-apps](fc-apps.md) | Apps | Application management |
| [fc-audit](fc-audit.md) | Security | Security auditing |
| [fc-backup](fc-backup.md) | Sync | Backup management |
| [fc-battery](fc-battery.md) | System | Battery status |
| [fc-bluetooth](fc-bluetooth.md) | Network | Bluetooth control |
| [fc-caffeine](fc-caffeine.md) | Productivity | Prevent sleep |
| [fc-clipboard](fc-clipboard.md) | Productivity | Clipboard utilities |
| [fc-cpu](fc-cpu.md) | System | CPU monitoring |
| [fc-cron](fc-cron.md) | Apps | Scheduled tasks |
| [fc-defaults](fc-defaults.md) | Customization | System defaults |
| [fc-disk](fc-disk.md) | System | Disk management |
| [fc-dns](fc-dns.md) | Network | DNS configuration |
| [fc-dock](fc-dock.md) | Customization | Dock settings |
| [fc-doctor](fc-doctor.md) | Diagnostics | System health |
| [fc-encrypt](fc-encrypt.md) | Security | File encryption |
| [fc-finder](fc-finder.md) | Customization | Finder settings |
| [fc-firewall](fc-firewall.md) | Network | Firewall control |
| [fc-gpg-setup](fc-gpg-setup.md) | Security | GPG configuration |
| [fc-info](fc-info.md) | Diagnostics | System information |
| [fc-keychain](fc-keychain.md) | Security | Keychain access |
| [fc-kill](fc-kill.md) | Apps | Process management |
| [fc-launch](fc-launch.md) | Apps | App launching |
| [fc-lock](fc-lock.md) | Security | Screen lock |
| [fc-memory](fc-memory.md) | System | Memory monitoring |
| [fc-network](fc-network.md) | Network | Network diagnostics |
| [fc-notify](fc-notify.md) | Productivity | Notifications |
| [fc-privacy](fc-privacy.md) | Security | Privacy permissions |
| [fc-qr](fc-qr.md) | Productivity | QR codes |
| [fc-quicklook](fc-quicklook.md) | Customization | Quick Look |
| [fc-redis](fc-redis.md) | Apps | Redis management |
| [fc-screenshot](fc-screenshot.md) | Productivity | Screenshots |
| [fc-spotlight](fc-spotlight.md) | Customization | Spotlight search |
| [fc-ssh-keygen](fc-ssh-keygen.md) | Security | SSH keys |
| [fc-sync](fc-sync.md) | Sync | Config sync |
| [fc-trash](fc-trash.md) | Customization | Trash management |
| [fc-update](fc-update.md) | Sync | System updates |
| [fc-vpn](fc-vpn.md) | Network | VPN management |
| [fc-wifi](fc-wifi.md) | Network | Wi-Fi control |

---

## Specification Format

Each specification follows a consistent structure:

```markdown
# Feature Specification: `fc <command>`

## Overview
**Command:** `fc <command>`
**Purpose:** What the command does

### Use Cases
- Primary use case
- Secondary use case

## Subcommands
| Subcommand | Description |
|------------|-------------|
| `action` | What it does |

## Detailed Behaviors
### `fc <command> action`
Expected output and examples

## Dependencies
| Tool | Source | Required |
|------|--------|----------|
| `tool` | Source | Yes/No |

## Implementation Notes
Technical details

## Testing Strategy
Manual verification steps
```

---

## Related Documentation

- [Commands Guide](../../COMMANDS.md) — Complete `fc` command reference
- [Creating Plugins](../CREATING_PLUGINS.md) — How to build new `fc` commands
- [Architecture](../../ARCHITECTURE.md) — System design overview
