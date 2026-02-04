# Feature Proposals

This directory contains **51 feature proposals** for the Dotfiles Flying Circus project. Each proposal outlines a potential enhancement, new command, or system improvement designed to extend the project's capabilities.

---

## Implementation Status

> **Last Updated:** 2026-02-03

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Implemented | 30+ | Feature is complete and available |
| 🔄 Partial | 3 | Core functionality exists, enhancements possible |
| ⏳ Planned | 15+ | Not yet implemented |

---

## Feature Categories

### 🔄 Backup & Sync

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [01](01-remote-backup-storage.md) | Remote Backup Storage | ✅ | Upload encrypted backups to cloud providers |
| [02](02-scheduled-backups.md) | Scheduled Backups | ✅ | Automate backup execution on a schedule |
| [10](10-multiple-backup-backends.md) | Multiple Backup Backends | ✅ | Support multiple storage providers simultaneously |

### 🖥️ System Management

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [05](05-system-health-check.md) | System Health Check | ✅ | `fc healthcheck` |
| [22](22-system-update-command.md) | System Update Command | ✅ | `fc maintenance` |
| [28](28-time-machine-management-command.md) | Time Machine Management | ✅ | `fc timemachine` |
| [35](35-enhanced-fc-info.md) | Enhanced `fc info` | ✅ | `fc info` |
| [41](41-system-maintenance-command.md) | System Maintenance | ✅ | `fc maintenance` |
| [42](42-self-update-mechanism.md) | Self-Update Mechanism | ✅ | `fc self-update` |
| — | **System Snapshotting** | ✅ | `fc snapshot` |

### 🔐 Security & Privacy

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [20](20-secrets-management-integration.md) | Secrets Management | ✅ | `fc secrets` |
| [26](26-1password-cli-integration.md) | 1Password CLI Integration | ✅ | `fc secrets` |
| [29](29-granular-firewall-rule-management.md) | Granular Firewall Rules | ✅ | `fc firewall` |

### ⚙️ Automation & Workflows

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [27](27-automated-new-machine-setup.md) | Automated Machine Setup | ✅ | `fc bootstrap` |
| [38](38-launchd-agent-management.md) | LaunchAgent Management | ✅ | `fc schedule` |
| [39](39-alfred-workflow-integration.md) | Alfred Integration | ✅ | `fc alfred` |

### 🛠️ Developer Tools

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [03](03-dotfile-management-command.md) | Dotfile Management | ✅ | `fc dotfiles` |
| [06](06-plugin-system-for-fc-command.md) | Plugin System | ✅ | `lib/plugins/` architecture |
| [08](08-ssh-key-management.md) | SSH Key Management | ✅ | `fc ssh` |
| [14](14-add-a-pre-commit-hook.md) | Pre-Commit Hooks | ✅ | `.pre-commit-config.yaml` |
| [31](31-vscode-settings-sync.md) | VS Code Settings Sync | ✅ | `fc vscode-sync` |
| [48](48-project-scaffolding.md) | Project Scaffolding | ✅ | `fc scaffold` |

### 🌐 Network & Connectivity

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [33](33-network-diagnostics-tool.md) | Network Diagnostics | ✅ | `fc network` |
| [46](46-cloud-cli-config-management.md) | Cloud CLI Configuration | ⏳ | Planned |

### 📱 Interface & UX

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [07](07-theme-management.md) | Theme Management | ✅ | `fc theme` |
| [11](11-interactive-role-creation.md) | Interactive Role Creation | ⏳ | Planned |
| [23](23-interactive-fc-command.md) | Interactive `fc` Command | ⏳ | Planned |
| [24](24-web-ui-dashboard.md) | Web UI Dashboard | ⏳ | Planned |
| [43](43-macos-notification-integration.md) | Notification Integration | ✅ | `fc notify` |

### 💻 Hardware & Peripherals

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [34](34-power-management-profiles.md) | Power Management | ✅ | `fc power` |
| [45](45-vm-management.md) | VM Management | ✅ | `fc vm` |
| [49](49-audio-device-control.md) | Audio Device Control | ✅ | `fc audio` |
| [50](50-display-management.md) | Display Management | ✅ | `fc display` |

### 🧹 Utilities

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [04](04-application-cleaner.md) | Application Cleaner | ✅ | `fc uninstall` |
| [32](32-docker-cleanup-command.md) | Docker Cleanup | ✅ | `fc docker` |
| [36](36-desktop-organizer.md) | Desktop Organizer | ✅ | `fc desktop` |
| [37](37-cli-note-taking.md) | CLI Note Taking | ⏳ | Planned |
| [44](44-shell-history-search.md) | Shell History Search | ✅ | `fc history` |

### 🏗️ Infrastructure

| # | Feature | Status | Description |
|---|---------|--------|-------------|
| [09](09-externalize-fc-sync-configuration.md) | Externalize Sync Config | ✅ | Config files supported |
| [13](13-better-error-handling.md) | Better Error Handling | ✅ | `lib/helpers.sh` |
| [15](15-improve-logging.md) | Improved Logging | ✅ | `lib/helpers.sh` |
| [16](16-refactor-installer.md) | Refactor Installer | 🔄 | Ongoing |
| [17](17-configuration-management.md) | Configuration Management | ✅ | `fc config` + YAML |
| [18](18-dependency-management.md) | Dependency Management | ✅ | `lib/init.sh` |
| [19](19-adopt-a-shell-framework.md) | Shell Framework | ⏳ | Deferred |
| [25](25-cross-platform-support.md) | Cross-Platform Support | ⏳ | Planned |
| [30](30-dotfile-profiles.md) | Dotfile Profiles | ✅ | `fc profile` |
| [40](40-application-settings-management.md) | App Settings Management | ✅ | `fc app-settings` |
| [47](47-focus-mode.md) | Focus Mode | ✅ | `fc focus` |
| [51](51-versioning-and-release-strategy.md) | Versioning Strategy | ✅ | CHANGELOG.md |
| [21](21-automated-application-installation.md) | Automated App Installation | ✅ | Brewfile system |

---

## Complete Index

| # | Feature | Status |
|---|---------|--------|
| [01](01-remote-backup-storage.md) | Remote Backup Storage | ✅ |
| [02](02-scheduled-backups.md) | Scheduled Backups | ✅ |
| [03](03-dotfile-management-command.md) | Dotfile Management Command | ✅ |
| [04](04-application-cleaner.md) | Application Cleaner | ✅ |
| [05](05-system-health-check.md) | System Health Check | ✅ |
| [06](06-plugin-system-for-fc-command.md) | Plugin System for FC Command | ✅ |
| [07](07-theme-management.md) | Theme Management | ✅ |
| [08](08-ssh-key-management.md) | SSH Key Management | ✅ |
| [09](09-externalize-fc-sync-configuration.md) | Externalize FC Sync Configuration | ✅ |
| [10](10-multiple-backup-backends.md) | Multiple Backup Backends | ✅ |
| [11](11-interactive-role-creation.md) | Interactive Role Creation | ⏳ |
| [12](12-more-fc-commands.md) | More FC Commands | ✅ |
| [13](13-better-error-handling.md) | Better Error Handling | ✅ |
| [14](14-add-a-pre-commit-hook.md) | Pre-Commit Hook | ✅ |
| [15](15-improve-logging.md) | Improve Logging | ✅ |
| [16](16-refactor-installer.md) | Refactor Installer | 🔄 |
| [17](17-configuration-management.md) | Configuration Management | ✅ |
| [18](18-dependency-management.md) | Dependency Management | ✅ |
| [19](19-adopt-a-shell-framework.md) | Adopt a Shell Framework | ⏳ |
| [20](20-secrets-management-integration.md) | Secrets Management Integration | ✅ |
| [21](21-automated-application-installation.md) | Automated Application Installation | ✅ |
| [22](22-system-update-command.md) | System Update Command | ✅ |
| [23](23-interactive-fc-command.md) | Interactive FC Command | ⏳ |
| [24](24-web-ui-dashboard.md) | Web UI Dashboard | ⏳ |
| [25](25-cross-platform-support.md) | Cross-Platform Support | ⏳ |
| [26](26-1password-cli-integration.md) | 1Password CLI Integration | ✅ |
| [27](27-automated-new-machine-setup.md) | Automated New Machine Setup | ✅ |
| [28](28-time-machine-management-command.md) | Time Machine Management Command | ⏳ |
| [29](29-granular-firewall-rule-management.md) | Granular Firewall Rule Management | ✅ |
| [30](30-dotfile-profiles.md) | Dotfile Profiles | ✅ |
| [31](31-vscode-settings-sync.md) | VS Code Settings Sync | ✅ |
| [32](32-docker-cleanup-command.md) | Docker Cleanup Command | ✅ |
| [33](33-network-diagnostics-tool.md) | Network Diagnostics Tool | ✅ |
| [34](34-power-management-profiles.md) | Power Management Profiles | ✅ |
| [35](35-enhanced-fc-info.md) | Enhanced FC Info | ✅ |
| [36](36-desktop-organizer.md) | Desktop Organizer | ✅ |
| [37](37-cli-note-taking.md) | CLI Note Taking | ⏳ |
| [38](38-launchd-agent-management.md) | LaunchD Agent Management | ✅ |
| [39](39-alfred-workflow-integration.md) | Alfred Workflow Integration | ✅ |
| [40](40-application-settings-management.md) | Application Settings Management | ⏳ |
| [41](41-system-maintenance-command.md) | System Maintenance Command | ✅ |
| [42](42-self-update-mechanism.md) | Self-Update Mechanism | ⏳ |
| [43](43-macos-notification-integration.md) | macOS Notification Integration | 🔄 |
| [44](44-shell-history-search.md) | Shell History Search | ✅ |
| [45](45-vm-management.md) | VM Management | ✅ |
| [46](46-cloud-cli-config-management.md) | Cloud CLI Config Management | ⏳ |
| [47](47-focus-mode.md) | Focus Mode | ✅ |
| [48](48-project-scaffolding.md) | Project Scaffolding | ✅ |
| [49](49-audio-device-control.md) | Audio Device Control | ✅ |
| [50](50-display-management.md) | Display Management | ✅ |
| [51](51-versioning-and-release-strategy.md) | Versioning and Release Strategy | ✅ |

---

## Summary

- **✅ Implemented:** 39 features
- **🔄 Partial:** 3 features
- **⏳ Planned:** 9 features

---

## Contributing

Have an idea for a new feature? Create a new proposal following the existing format and submit a pull request. Each proposal should include:

1. Clear problem statement and user benefit
2. Technical design considerations
3. Security implications
4. Documentation requirements
5. Implementation steps

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for general contribution guidelines.
