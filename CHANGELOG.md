# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.2] - 2026-01-02

### Added

- **VM Management**: New `fc vm` command for managing container VMs with:
  - Support for Lima (`limactl`) and Colima providers
  - Provider abstraction in `lib/vm_backends/` for extensibility
  - Subcommands: `list`, `start`, `stop`, `status`, `shell`, `delete`, `create`, `ip`, `provider`
  - Auto-detection of available provider (prefers Colima)
  - Configuration via `~/.config/circus/vm.conf`

### Documentation

- New `docs/VIRTUAL_MACHINES.md` - Complete VM management guide
- Updated `COMMANDS.md` with `fc vm` command documentation
- Updated `ROADMAP.md` to mark feature #45 as complete

## [1.1.1] - 2026-01-02

### Added

- **Raycast Script Commands Integration**: New `fc raycast` command with:
  - `install` subcommand to install Flying Circus script commands to Raycast
  - `uninstall` subcommand to remove the script commands
  - `status` subcommand to check installation status
  - 27 individual script commands for quick-access to fc functionality
  - Script commands source files in `etc/raycast/scripts/`

- **Raycast Commands**: Quick access to fc commands via Raycast:
  - Wi-Fi On/Off/Status - Control Wi-Fi adapter
  - Bluetooth On/Off/Status - Control Bluetooth
  - Lock Screen - Lock screen immediately
  - Caffeine On/Off/30min/1hr/Status - Prevent sleep
  - DNS Status/Cloudflare/Google/Quad9/Clear - Manage DNS servers
  - AirDrop Everyone/Contacts/Off/Status - Control AirDrop visibility
  - System Info - Display system information (full output)
  - System Healthcheck - Run diagnostics (full output)
  - Disk Status/Usage - Disk utilities
  - SSH List/Copy - SSH key management
  - Clipboard Clear - Clear clipboard

### Documentation

- Added `docs/RAYCAST.md` - Complete Raycast integration documentation
- Updated `COMMANDS.md` with `fc raycast` command documentation
- Updated `ROADMAP.md` to mark feature #40 as complete

## [1.1.0] - 2026-01-02

### Added

- **Alfred Workflow Integration**: New `fc alfred` command with:
  - `install` subcommand to install the Flying Circus workflow to Alfred
  - `uninstall` subcommand to remove the workflow
  - `status` subcommand to check installation status
  - Single "Flying Circus" workflow with 12 keyword triggers
  - Script filters returning JSON for dynamic Alfred results
  - Workflow source files in `etc/alfred/workflows/Flying Circus/`

- **Alfred Keywords**: Quick access to fc commands via Alfred:
  - `wifi` - Control Wi-Fi (on/off/status)
  - `bluetooth` - Control Bluetooth (on/off/status)
  - `lock` - Lock screen immediately
  - `caffeine` - Prevent sleep (on/off/for/status)
  - `dns` - Manage DNS servers (Cloudflare, Google, Quad9, clear)
  - `airdrop` - Control AirDrop visibility
  - `fcinfo` - Display system information
  - `healthcheck` - Run system diagnostics
  - `disk` - Disk utilities (status/usage/large/cleanup)
  - `sshkey` - SSH key management (list/copy/generate/add)
  - `keychain` - Keychain access (list/wifi/search)
  - `clip` - Clipboard utilities (show/clear/plain/count)
  - `fc` - Browse all available commands

### Documentation

- Added `docs/ALFRED.md` - Complete Alfred workflow documentation
- Updated `COMMANDS.md` with `fc alfred` command documentation
- Updated `ROADMAP.md` to mark feature #39 as complete

## [1.0.0] - 2026-01-01

### Added

- **Self-Update Mechanism**: Enhanced `fc update` command with:
  - `--check` flag to check for updates without applying them
  - `--version` flag to display the current installed version
  - `--dry-run` flag to preview what an update would do
  - `--skip-migrations` flag to update without running migrations
  - Automatic migration system for version upgrades

- **Migration System**: Framework for running migration scripts during updates
  - Migrations stored in `migrations/` directory
  - Version-based migration selection
  - Documentation for writing migration scripts

- **Version Tracking**: `.version` file for semantic versioning

- **Installer Refactor**: Stage-based modular installer with:
  - 15 independent installation stages
  - 21 preflight system checks
  - Role-based configuration (developer, personal, work)
  - Privacy profiles (standard, privacy, lockdown)
  - Dry-run mode support
  - Comprehensive test coverage

- **Logging System**: 6-level logging with:
  - DEBUG, INFO, SUCCESS, WARN, ERROR, CRITICAL levels
  - File logging with `--log-file` flag
  - Console filtering with `--log-level` flag
  - `--silent` flag for quiet operation
  - Automatic log rotation

- **Plugin System**: Extensible command architecture
  - 22+ plugins in `lib/plugins/`
  - Dynamic plugin discovery
  - Per-plugin help messages

- **Error Handling**: Robust error management with:
  - `die()` function for fatal errors
  - ERR trap for unexpected failures
  - Contextual error messages

### Documentation

- Architecture documentation in `ARCHITECTURE.md`
- Plugin creation guide in `docs/CREATING_PLUGINS.md`
- Troubleshooting guide in `docs/TROUBLESHOOTING.md`
- Update guide in `docs/UPDATING.md`
- Command specifications in `docs/specs/`
