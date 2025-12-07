# Documentation Index

Welcome to the Dotfiles Flying Circus documentation. This guide helps you navigate the project documentation.

> **Note:** Core documentation (README, COMMANDS, ARCHITECTURE, TESTING) lives at the repository root. This `docs/` folder contains supplementary guides, feature proposals, and specs.

## Quick Start

| Document | Description |
|----------|-------------|
| [README](../README.md) | Project overview and getting started |
| [Commands Guide](../COMMANDS.md) | Complete `fc` command reference |
| [Contributing](../CONTRIBUTING.md) | How to contribute |

---

## Architecture & Design

| Document | Description |
|----------|-------------|
| [Architecture](../ARCHITECTURE.md) | System design philosophy and structure |
| [Roles Guide](../ROLES.md) | Role-based installation system |
| [Privacy Profiles](../defaults/profiles/README.md) | Standard, privacy, and lockdown profiles |

---

## Developer Guides

| Document | Description |
|----------|-------------|
| [Creating Plugins](CREATING_PLUGINS.md) | How to create `fc` command plugins |
| [macOS Commands Reference](MACOS_COMMANDS.md) | Terminal commands used in this project |
| [Customization Guide](CUSTOMIZATION.md) | Adapting the project for your needs |
| [Testing Quick Start](../TESTING.md) | Running and setting up tests |
| [Writing Tests](WRITING_TESTS.md) | Tutorial: How to write Bats tests |

---

## Feature Proposals

The [features/](features/) folder contains 51 feature proposals for future development.

Browse by category:
- **Backup & Sync**: [01](features/01-remote-backup-storage.md), [02](features/02-scheduled-backups.md), [10](features/10-multiple-backup-backends.md)
- **System Management**: [05](features/05-system-health-check.md), [22](features/22-system-update-command.md), [41](features/41-system-maintenance-command.md)
- **Security**: [20](features/20-secrets-management-integration.md), [29](features/29-granular-firewall-rule-management.md)
- **Automation**: [27](features/27-automated-new-machine-setup.md), [38](features/38-launchd-agent-management.md)

---

## Command Specifications

The [specs/](specs/) folder contains detailed specifications for each `fc` command.

### System & Hardware
| Spec | Description |
|------|-------------|
| [fc-battery](specs/fc-battery.md) | Battery status and management |
| [fc-cpu](specs/fc-cpu.md) | CPU monitoring |
| [fc-disk](specs/fc-disk.md) | Disk usage and cleanup |
| [fc-memory](specs/fc-memory.md) | Memory monitoring |

### Network
| Spec | Description |
|------|-------------|
| [fc-wifi](specs/fc-wifi.md) | Wi-Fi adapter control |
| [fc-bluetooth](specs/fc-bluetooth.md) | Bluetooth control |
| [fc-dns](specs/fc-dns.md) | DNS server management |
| [fc-firewall](specs/fc-firewall.md) | Application firewall |
| [fc-network](specs/fc-network.md) | Network diagnostics |
| [fc-vpn](specs/fc-vpn.md) | VPN management |

### Security & Privacy
| Spec | Description |
|------|-------------|
| [fc-audit](specs/fc-audit.md) | Security auditing |
| [fc-encrypt](specs/fc-encrypt.md) | File encryption |
| [fc-keychain](specs/fc-keychain.md) | Keychain access |
| [fc-lock](specs/fc-lock.md) | Screen lock control |
| [fc-privacy](specs/fc-privacy.md) | Privacy permissions |

### Productivity
| Spec | Description |
|------|-------------|
| [fc-caffeine](specs/fc-caffeine.md) | Prevent sleep |
| [fc-clipboard](specs/fc-clipboard.md) | Clipboard utilities |
| [fc-notify](specs/fc-notify.md) | Notifications |
| [fc-qr](specs/fc-qr.md) | QR code generation |
| [fc-screenshot](specs/fc-screenshot.md) | Screenshot settings |

### macOS Customization
| Spec | Description |
|------|-------------|
| [fc-defaults](specs/fc-defaults.md) | System defaults |
| [fc-dock](specs/fc-dock.md) | Dock customization |
| [fc-finder](specs/fc-finder.md) | Finder settings |
| [fc-quicklook](specs/fc-quicklook.md) | Quick Look plugins |
| [fc-spotlight](specs/fc-spotlight.md) | Spotlight search |
| [fc-trash](specs/fc-trash.md) | Trash management |

### Apps & Processes
| Spec | Description |
|------|-------------|
| [fc-apps](specs/fc-apps.md) | Application management |
| [fc-cron](specs/fc-cron.md) | Scheduled tasks |
| [fc-kill](specs/fc-kill.md) | Process management |
| [fc-launch](specs/fc-launch.md) | App launching |

---

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.
