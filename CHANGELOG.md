# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
