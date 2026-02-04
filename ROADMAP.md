# Feature Roadmap

This roadmap organizes the proposed features from the `docs/features/` directory into a logical sequence of four phases. Each phase builds on the last, ensuring that foundational work is completed before more complex features are attempted.

---

## Phase 1: Building the Foundation

**Goal:** To establish a robust, extensible, and maintainable architecture for the entire system. This phase is critical for the long-term health of the project.

*   **Key Features:**
    *   **Architecture:**
        *   ~~`06-plugin-system-for-fc-command`~~: **DONE** - Plugin-based dispatcher implemented in `bin/fc` with 22 plugins in `lib/plugins/`. Documentation in `docs/CREATING_PLUGINS.md` and `ARCHITECTURE.md`.
        *   `19-adopt-a-shell-framework`: Standardize shell scripting practices (e.g., using a framework like `bash-it` or `oh-my-zsh` helpers) to ensure consistency.
    *   **Developer Experience & Stability:**
        *   ~~`13-better-error-handling`~~: **DONE** - Error handler with `die()` function and ERR trap implemented in `lib/helpers.sh`.
        *   ~~`15-improve-logging`~~: **DONE** - 6 log levels (DEBUG, INFO, SUCCESS, WARN, ERROR, CRITICAL), file logging with `--log-file`, console filtering with `--log-level`, `--silent` flag, and automatic log rotation. Documentation in `docs/TROUBLESHOOTING.md`.
        *   `14-add-a-pre-commit-hook`: Enforce code quality standards automatically.
    *   **Installation and Updates:**
        *   `18-dependency-management`: Create a clear and reliable way to manage third-party dependencies (e.g., Homebrew packages).
        *   ~~`16-refactor-installer`~~: **DONE** - Stage-based installer with 15 modular stages, 21 preflight checks, role system, privacy profiles, dry-run mode. Comprehensive bats tests for stages and preflight checks. Documentation in `ARCHITECTURE.md`.
        *   ~~`42-self-update-mechanism`~~: **DONE** - Enhanced `fc update` with `--check`, `--version`, `--dry-run`, `--skip-migrations` flags, migration system in `migrations/`, version tracking via `.version` file, `CHANGELOG.md`, and `docs/UPDATING.md`.
    *   **Configuration:**
        *   ~~`09-externalize-fc-sync-configuration`~~: **DONE** - External config file at `~/.config/circus/sync.conf`, template in `lib/templates/sync.conf.template`, `setup` subcommand for easy configuration, security checks for file permissions.
        *   ~~`17-configuration-management`~~: **DONE** - `fc config` command for declarative YAML-based configuration. Supports role-based configs (`roles/personal/config.yaml`), validation, and conversion from legacy shell scripts. Engine in `lib/yaml_config.sh`. Documentation in `docs/YAML_CONFIGURATION.md`.

---

## Phase 2: Delivering Core User Value

**Goal:** To implement the most critical, user-facing features that solve the primary problems the tool is designed to address.

*   **Key Features:**
    *   **Dotfile Management:**
        *   ~~`03-dotfile-management-command`~~: **DONE** - `fc fc-dotfiles` command with `add`, `list`, and `edit` subcommands. Interactive subdirectory selection, symlink management, and `$EDITOR` integration. Documentation in `COMMANDS.md`.
        *   ~~`30-dotfile-profiles`~~: **DONE** - Profile system with `profiles/base/` for shared dotfiles and named profiles (e.g., `work/`, `personal/`) for overrides. `fc fc-profile` command with `list`, `current`, and `switch` subcommands. Documentation in `docs/PROFILES.md` and `COMMANDS.md`.
    *   **Backup and Restore:**
        *   ~~`02-scheduled-backups`~~: **DONE** - `fc fc-schedule` command with `install`, `uninstall`, `status`, and `run` subcommands. Uses macOS launchd for reliable scheduling. Supports daily/weekly frequencies. Added `--no-confirm` flag to `fc-sync` for automated execution. Documentation in `COMMANDS.md`.
    *   **System & Application Management:**
        *   ~~`40-application-settings-management`~~: **DONE** - `fc app-settings` command for managing macOS defaults via category-based scripts. Supports applying, listing, and previewing settings for system, apps, interface, and accessibility. Documentation in `COMMANDS.md`.
        *   ~~`21-automated-application-installation`~~: **DONE** - `fc fc-apps` command with `setup`, `list`, `install`, and `add` subcommands. Brewfile-compatible config at `~/.config/circus/apps.conf`. Supports Homebrew formulae, casks, and Mac App Store apps. Added `mas` to base Brewfile. Documentation in `COMMANDS.md`.
        *   ~~`22-system-update-command`~~: **DONE** - Extended `fc update` with `--os`, `--packages`, `--self`, `--all` flags. Updates Homebrew (formulae, casks), Mac App Store apps, macOS, and dotfiles repository. Dry-run mode for previewing. Documentation in `COMMANDS.md`.
        *   ~~`41-system-maintenance-command`~~: **DONE** - `fc fc-maintenance` command with `setup`, `list`, and `run` subcommands. 11 maintenance tasks including brew cleanup, cache clearing, log rotation, DNS flush, and more. Configurable via `~/.config/circus/maintenance.conf`. Dry-run mode and safe defaults. Documentation in `COMMANDS.md`.
        *   ~~`04-application-cleaner`~~: **DONE** - `fc fc-clean` command with `brew`, `casks`, and `list` subcommands. Detects orphaned Homebrew packages not defined in any Brewfile. Interactive removal with `--remove` flag, dependency filtering with `--skip-deps`. Documentation in `COMMANDS.md`.
    *   **Utilities:**
        *   ~~`12-more-fc-commands`~~: **DONE** - `fc wifi`, `fc dns`, and `fc firewall` commands for managing Wi-Fi adapter, DNS settings, and the application firewall. Simple on/off/status controls with proper sudo handling. Documentation in `COMMANDS.md`.
        *   ~~`08-ssh-key-management`~~: **DONE** - `fc ssh` command with `generate`, `add`, `copy`, and `list` subcommands. Ed25519 key generation, Keychain integration, clipboard support. Replaces the simpler `fc-ssh-keygen` wizard. Documentation in `COMMANDS.md`.
        *   ~~`05-system-health-check`~~: **DONE** - `fc healthcheck` command with 4 checks: broken symlinks, missing Brewfile dependencies, SSH permissions, and git configuration. Run all checks or specific ones by name. Documentation in `COMMANDS.md`.

---

## Phase 3: Advanced Functionality and Integrations

**Goal:** To build upon the core features with more advanced capabilities and integrations with other tools and services.

*   **Key Features:**
    *   **Advanced Backups:**
        *   ~~`01-remote-backup-storage`~~: **DONE** - Extended `fc sync` with `push`, `pull`, and `list-remote` subcommands for remote backup storage using rclone. Supports 40+ cloud providers (S3, Google Drive, Dropbox, Backblaze B2, etc.). Configuration via `RCLONE_REMOTE` and `RCLONE_REMOTE_PATH` in sync.conf. Documentation in `COMMANDS.md`.
        *   ~~`10-multiple-backup-backends`~~: **DONE** - Refactored `fc sync` with dispatcher pattern supporting multiple backup backends. Three backends available: GPG (default, tar+gpg), Restic (deduplication, native S3/SFTP), and Borg (deduplication, compression, native SSH). Configuration via `BACKUP_BACKEND` in sync.conf. Backend files in `lib/backup_backends/`. Documentation in `docs/BACKUP_BACKENDS.md`.
    *   **Automation:**
        *   ~~`27-automated-new-machine-setup`~~: **DONE** - `fc fc-bootstrap` command that orchestrates complete machine setup through 7 phases: preflight checks, Homebrew setup, backup restore, dotfiles deployment, app installation, system configuration, and health checks. Supports interactive wizard (shell prompts or Gum-based TUI), dry-run mode, phase skipping/selection, and unattended mode via config file. State tracking for resumable bootstraps. Documentation in `docs/BOOTSTRAP.md` and `COMMANDS.md`.
    *   **Integrations:**
        *   ~~`20-secrets-management-integration`~~: **DONE** - `fc fc-secrets` command with unified secrets management for 1Password CLI, macOS Keychain, and HashiCorp Vault. URI-based secret references (`op://`, `keychain://`, `vault://`), environment variable sync to `~/.zshenv.local`, file destination support with permissions. 6 subcommands: setup, sync, get, list, status, verify. Backend plugins in `lib/secrets_backends/`. Documentation in `docs/SECRETS.md` and `COMMANDS.md`.
        *   ~~`26-1password-cli-integration`~~: **DONE** - Included as the `op://` backend in `fc fc-secrets`. Supports `op://vault/item/field` URI format, automatic authentication prompts, and full `op read` integration. See `lib/secrets_backends/op.sh`.
        *   ~~`31-vscode-settings-sync`~~: **DONE** - `fc vscode-sync` command with `setup`, `up`, `down`, and `status` subcommands. Two backends: GitHub Gist (default) and Git repository. Syncs settings.json, keybindings.json, snippets, extensions, and optionally tasks.json and launch.json. Configurable sync flags. Authentication via macOS Keychain, gh CLI, or GITHUB_TOKEN. Documentation in `COMMANDS.md`.
        *   ~~`39-alfred-workflow-integration`~~: **DONE** - `fc alfred` command with `install`, `uninstall`, and `status` subcommands. Single "Flying Circus" workflow with 12 keyword triggers for quick-access commands (wifi, bluetooth, lock, caffeine, dns, airdrop, fcinfo, healthcheck, disk, sshkey, keychain, clip). Script filters return JSON for Alfred. Workflow source in `etc/alfred/workflows/Flying Circus/`. Documentation in `docs/ALFRED.md` and `COMMANDS.md`.
        *   ~~`40-raycast-script-commands`~~: **DONE** - `fc raycast` command with `install`, `uninstall`, and `status` subcommands. 27 individual script commands for quick-access to fc functionality. Matches Alfred workflow feature parity. Script commands source in `etc/raycast/scripts/`. Documentation in `docs/RAYCAST.md` and `COMMANDS.md`.
    *   **Power-User Features:**
        *   ~~`45-vm-management`~~: **DONE** - `fc vm` command for managing Lima and Colima VMs. Provider abstraction in `lib/vm_backends/`. Subcommands: list, start, stop, status, shell, delete, create, ip, provider. Documentation in `docs/VIRTUAL_MACHINES.md`.
    *   **Hardware & Peripherals:**
        *   ~~`34-power-management-profiles`~~: **DONE** - `fc power` command for switching between performance and battery profiles. Uses `pmset`.
        *   ~~`49-audio-device-control`~~: **DONE** - `fc audio` command for volume control and device switching. Supports `switchaudio-osx` and fuzzy matching.
        *   ~~`50-display-management`~~: **DONE** - `fc display` command for managing resolutions, mirroring, and saving/restoring layouts with `displayplacer`.

---

## Phase 4: The "Big Picture" and Polishing the User Experience

**Goal:** To focus on ambitious, long-term projects and on refining the user experience to make the tool more accessible and pleasant to use.

*   **Key Features:**
    *   **Major New Interfaces:**
        *   `24-web-ui-dashboard`: A major undertaking to create a graphical interface for the tool.
        *   ~~`25-cross-platform-support`~~: **DONE** (v1.1.3-1.1.6) - Complete Linux support with OS abstraction layer. All core plugins work on Linux (Ubuntu, Fedora, Arch). See `docs/CROSS_PLATFORM.md`.
    *   **Enhanced Interactivity:**
        *   ~~`23-interactive-fc-command`~~: **DONE** (v1.1.7) - `fc -i` launches fzf-powered interactive menu with command previews
        *   ~~`11-interactive-role-creation`~~: **DONE** (v1.1.8) - `fc profile create` launches 4-step wizard with fzf component selection
    *   **Quality-of-Life Improvements:**
    *   **Quality-of-Life Improvements:**
        *   ~~`43-macos-notification-integration`~~: **DONE** - `fc notify` command. Supports `terminal-notifier` and `osascript` with success/error/warning presets and click actions. Configurable via `~/.config/circus/notify.conf`.
        *   ~~`35-enhanced-fc-info`~~: **DONE** (v1.1.8) - Visual banner, health indicators, tool status, `--json` output
        *   And many of the other smaller utilities and enhancements (`theme-management`, `focus-mode`, etc.).

---

## Roadmap Management Strategy

A great roadmap is only useful if it's visible and actionable. Here are the recommended approaches for managing this feature roadmap:

1.  **GitHub Projects (Most Recommended):** This is the ideal solution. It allows you to create a Kanban-style board directly within your repository. You can turn each feature proposal into a GitHub Issue and place it on the board. This tightly integrates the roadmap with your development workflow, providing excellent visibility and automation opportunities.

2.  **A `ROADMAP.md` File (This File!):** A simple and transparent solution. The roadmap lives as a version-controlled Markdown file in the repository. It's easy to access and update via pull requests, giving you a version-controlled history of the roadmap.

3.  **Third-Party Project Management Tool (e.g., Trello, Linear, Jira):** These tools offer powerful features for tracking complex projects, but come at the cost of being disconnected from the code and potentially introducing subscription fees.

---

## Feature Candidates for Future Phases

This section lists proposed features that are not yet part of the official phased roadmap. They are candidates for future development, prioritized based on their potential impact and alignment with the project's goals.

### 🛡️ Safety & Reliability (Priority 1)
| Feature | Functionality / User Story | Difficulty | Status |
| :--- | :--- | :--- | :--- |
| **System Snapshotting** | As a user, I want `circus` to automatically take an APFS snapshot before applying major changes so that I can easily revert my system if something goes wrong. | Medium | ✅ Done |
| **Disaster Recovery Mode** | As a user, I want an `fc recover --from <source>` command to perform a full system restore from a `circus` backup. | Hard | ⏳ Planned |
| **Time Machine Mgmt** | As a user, I want to manage Time Machine backups (start/stop/status/exclude) from the CLI (Feature #28). | Medium | ⏳ Planned |
| **Configuration Auditing** | As a user, I want to run `fc audit` to check my live system state against my configuration files and report any drift. | Medium | ⏳ Planned |
| **Undo Last Action**| As a user, I want an `fc undo` command that reverts the last major operation, potentially by restoring an APFS snapshot. | Hard | ⏳ Planned |

### 🛠️ Core Management Enhancements (Priority 2)
| Feature | Functionality / User Story | Difficulty | Status |
| :--- | :--- | :--- | :--- |
| **Cloud CLI Managers** | As a user, I want to manage authentication and configuration for AWS, GCP, and Azure CLIs consistently (Feature #46). | Medium | ⏳ Planned |
| **Network Profiles** | As a user, I want to switch network sets (DNS, Proxy, WiFi) with `fc network switch home/work`. | Medium | ⏳ Planned |
| **App Data Cleanup** | As a user, I want to run `fc clean --app-data <app>` to deeply remove all associated cache and configuration files (beyond what `fc uninstall` does). | Medium | ⏳ Planned |
| **Secrets Rotation** | As a user, I want `fc secrets rotate` to integrate with services like Vault to rotate secrets automatically. | Hard | ⏳ Planned |

### 🚀 User Experience & Integrations (Priority 3)
| Feature | Functionality / User Story | Difficulty | Status |
| :--- | :--- | :--- | :--- |
| **Web UI Dashboard** | As a user, I want to view system status, health, and configuration from a local web dashboard (Feature #24). | Hard | ⏳ Planned |
| **CLI Note Taking** | As a user, I want a quick way to capture notes/snippets from the terminal `fc note "fix this later"` (Feature #37). | Easy | ⏳ Planned |
| **Unified Theme Mgmt** | As a user, I want `fc theme set <theme>` to apply the theme consistently across macOS, iTerm2, VSCode, and Alfred. | Medium | ⏳ Planned |
| **Natural Language CLI** | As a user, I want to type commands like `fc install chrome` and have the tool translate it. | Hard | ⏳ Planned |
| **Plugin Marketplace** | As a user, I want to browse and install community plugins. | Hard | ⏳ Planned |

### 💻 Developer Experience (Priority 4)
| Feature | Functionality / User Story | Difficulty | Status |
| :--- | :--- | :--- | :--- |
| **Windows (WSL2)** | As a user, I want `circus` to provide experimental support for WSL2 (Feature #25 extension). | Hard | ⏳ Planned |
| **Test Coverage** | As a developer, I want `bats` test runs to generate coverage reports. | Medium | ⏳ Planned |
| **Auto-Docs** | As a developer, I want documentation to be generated from source comments. | Medium | ⏳ Planned |
