# Custom Commands (`fc`)

This document provides an overview of the custom command-line utility, `fc` (Dotfiles Flying Circus), included in this repository. This tool provides a suite of helpful commands for system inspection, management, and state synchronization.

## Usage

The `fc` command is the main entry point for all subcommands.

```bash
fc <command> [options]
```

To see a list of all available commands, simply run `fc` with no arguments.

---

## `fc bootstrap`

Orchestrate the complete setup of a new machine. Runs a series of phases to install dependencies, deploy dotfiles, configure the system, and install applications.

**Usage:**

```bash
fc fc-bootstrap [subcommand] [options]
```

**Subcommands:**
*   *(none)*: Run interactive bootstrap wizard.
*   `status`: Show bootstrap status and completed phases.
*   `resume`: Resume a previously interrupted bootstrap.
*   `reset`: Clear bootstrap state to start fresh.

**Options:**
*   `--role <role>`: Set installation role (developer, personal, work).
*   `--dry-run`: Show what would be done without executing.
*   `--skip <phase>`: Skip a specific phase (can be repeated).
*   `--only <phase>`: Run only a specific phase.
*   `--no-restore`: Skip restore phase even if backup exists.
*   `--force`: Re-run phases even if already completed.
*   `--gum`: Use Gum-based TUI (if available).

**Phases:**
| Phase | Description |
|-------|-------------|
| `preflight` | Check system requirements (macOS version, disk space, internet) |
| `homebrew` | Install/update Homebrew and core dependencies |
| `restore` | Optionally restore from `fc sync` backup |
| `dotfiles` | Deploy dotfiles and shell configuration |
| `apps` | Install applications via `fc apps` and Brewfiles |
| `configure` | Configure git identity, SSH keys, and macOS defaults |
| `health` | Run health checks and generate a bootstrap report |

**Examples:**

```bash
# Interactive bootstrap wizard
fc fc-bootstrap

# Check what's been configured
fc fc-bootstrap status

# Preview without making changes
fc fc-bootstrap --dry-run

# Resume after interruption
fc fc-bootstrap resume

# Run only the configure phase
fc fc-bootstrap --only configure --force

# Unattended setup (with bootstrap.conf configured)
AUTO_CONFIRM=true fc fc-bootstrap
```

**Configuration:**

For customized or unattended setup, create `~/.config/circus/bootstrap.conf`. See `docs/BOOTSTRAP.md` for full documentation.

---

## `fc info`

Displays a detailed report of your system's hardware, software, and network configuration.

**Usage:**

```bash
fc info
```

---

## `fc doctor`

Runs a series of diagnostic checks to ensure your system is healthy and correctly configured. This includes checking Homebrew status and verifying that critical command-line tools are installed.

**Usage:**

```bash
fc doctor
```

---

## `fc healthcheck`

Run system health checks to identify common configuration issues. Catches problems before they become bigger issues.

**Usage:**

```bash
fc healthcheck [check-name]
```

**Options:**
*   `--help`: Show help message.
*   `--list`: List available checks.

**Available Checks:**
*   `symlinks`: Check for broken symlinks in home directory.
*   `deps`: Check if Brewfile dependencies are installed.
*   `ssh`: Check SSH directory and key permissions.
*   `git`: Check git user name and email configuration.

**Examples:**

```bash
# Run all health checks
fc healthcheck

# Run a specific check
fc healthcheck ssh
fc healthcheck git

# List available checks
fc healthcheck --list
```

**Output:**

```
System Health Check
═══════════════════════════════════════════════════

  ✓ SSH Permissions        ~/.ssh properly secured
  ✓ Git Configuration      User name and email configured
  ⚠ Broken Symlinks        Found 2 broken links
  ✓ Dependencies           All Brewfile packages installed

───────────────────────────────────────────────────
Summary: 3 passed, 1 warning
```

### What Gets Checked

| Check | What It Verifies |
|-------|-----------------|
| SSH | `~/.ssh` is 700, private keys are 600 |
| Git | `user.name` and `user.email` are set globally |
| Symlinks | No broken symlinks in home (max depth 3) |
| Deps | All Brewfile packages are installed |

---

## `fc bluetooth`

Provides simple commands for managing your system's Bluetooth adapter.

**Usage:**

```bash
fc bluetooth <subcommand>
```

**Subcommands:**
*   `status`: Shows whether Bluetooth is currently on or off.
*   `on`: Turns Bluetooth on.
*   `off`: Turns Bluetooth off.

---

## `fc wifi`

Manage the system's Wi-Fi adapter from the command line. Provides simple on/off control and status checking for the primary Wi-Fi interface.

**Usage:**

```bash
fc wifi <action>
```

**Actions:**
*   `on`: Turn Wi-Fi adapter on.
*   `off`: Turn Wi-Fi adapter off (disconnects from networks).
*   `status`: Show the current Wi-Fi power state.

**Examples:**

```bash
# Enable Wi-Fi
fc wifi on

# Disable Wi-Fi
fc wifi off

# Check if Wi-Fi is on or off
fc wifi status
```

**Notes:**
- Turning Wi-Fi off disconnects from all wireless networks
- No administrator privileges required
- Uses the built-in `networksetup` command

---

## `fc vm`

Manage container virtual machines (Lima and Colima) from the command line. Provides a unified interface for starting, stopping, and managing development VMs.

**Usage:**

```bash
fc vm <action> [name]
```

**Actions:**
*   `list`: List all VMs with their status.
*   `start [name]`: Start a VM (default VM if no name).
*   `stop [name]`: Stop a VM gracefully.
*   `status [name]`: Show detailed VM status.
*   `shell [name]`: Open a shell inside the VM.
*   `delete <name>`: Delete a VM (requires confirmation).
*   `create <name>`: Create a new VM.
*   `ip [name]`: Show the IP address of a VM.
*   `provider [name]`: Show or set the active provider (lima/colima).

**Providers:**

| Provider | Description | Best For |
|----------|-------------|----------|
| Colima | Lightweight container runtime | Docker, Kubernetes development |
| Lima | General-purpose Linux VMs | Custom Linux environments |

**Examples:**

```bash
# List all VMs
fc vm list

# Start the default VM
fc vm start

# Start a named VM
fc vm start myvm

# Open shell in VM
fc vm shell

# Check status
fc vm status

# Show/change provider
fc vm provider
fc vm provider colima

# Create a new VM
fc vm create devbox
```

**Configuration:**

Edit `~/.config/circus/vm.conf`:

```bash
# Provider: lima or colima
VM_PROVIDER="colima"

# Default VM name
VM_DEFAULT_NAME="default"
```

**Prerequisites:**
- Install Colima: `brew install colima docker`
- Or install Lima: `brew install lima`

**Full Documentation:** See `docs/VIRTUAL_MACHINES.md` for complete setup and usage guide.

---

## `fc dns`

Manage the DNS settings for the active network service. Allows viewing, setting, and clearing custom DNS servers.

**Usage:**

```bash
fc dns <action> [dns_servers...]
```

**Actions:**
*   `get` / `status`: Show the current DNS servers.
*   `set <ip>...`: Set one or more custom DNS servers.
*   `clear`: Clear custom DNS servers, reverting to DHCP-provided servers.

**Examples:**

```bash
# View current DNS servers
fc dns get

# Use Google DNS
fc dns set 8.8.8.8 8.8.4.4

# Use Cloudflare DNS
fc dns set 1.1.1.1 1.0.0.1

# Revert to DHCP-provided DNS
fc dns clear
```

**Popular DNS Providers:**
| Provider | Primary | Secondary |
|----------|---------|-----------|
| Google | 8.8.8.8 | 8.8.4.4 |
| Cloudflare | 1.1.1.1 | 1.0.0.1 |
| OpenDNS | 208.67.222.222 | 208.67.220.220 |
| Quad9 | 9.9.9.9 | 149.112.112.112 |

**Notes:**
- Setting or clearing DNS requires administrator (sudo) password
- The active network service is automatically detected
- Multiple DNS servers provide redundancy
- To flush the DNS cache, use `fc fc-maintenance run dns-flush`

---

## `fc firewall`

Manage the macOS application firewall from the command line. Provides granular per-app rule management through `socketfilterfw`.

**Usage:**

```bash
fc firewall <action> [options]
```

**Basic Actions:**

| Action | Description |
|--------|-------------|
| `on` | Turn the firewall on |
| `off` | Turn the firewall off |
| `status` | Show firewall state, stealth mode, and app count |

**App Rule Management:**

| Action | Description |
|--------|-------------|
| `list-apps` | List all applications with firewall rules |
| `add <app>` | Add an application (blocks incoming by default) |
| `remove <app>` | Remove an application from the firewall |
| `allow <app>` | Allow incoming connections for an app |
| `block <app>` | Block incoming connections for an app |

**Configuration:**

| Action | Description |
|--------|-------------|
| `apply-rules` | Apply rules from `~/.config/circus/firewall.conf` |
| `export` | Export current rules to stdout |
| `setup` | Create configuration file template |

**Advanced Options:**

| Action | Description |
|--------|-------------|
| `stealth-on` | Enable stealth mode (don't respond to ICMP probes) |
| `stealth-off` | Disable stealth mode |
| `block-all` | Block all incoming connections |
| `unblock-all` | Allow signed apps to receive connections |

**Examples:**

```bash
# Basic on/off control
fc firewall on
fc firewall status

# Per-app rules
fc firewall add /Applications/Firefox.app
fc firewall allow /Applications/Slack.app
fc firewall block /Applications/Suspicious.app
fc firewall list-apps

# Configuration-based management
fc firewall setup          # Create config file
fc firewall apply-rules    # Apply rules from config
fc firewall export > my-rules.conf  # Backup rules

# Security hardening
fc firewall stealth-on     # Hide from port scans
```

**Configuration File Format:**

```bash
# ~/.config/circus/firewall.conf
# Format: <action> <path_to_app>

allow /Applications/Slack.app
allow /Applications/Visual Studio Code.app
block /Applications/Firefox.app
```

**Notes:**
- All actions require administrator (sudo) privileges
- The macOS firewall is an application-level firewall (incoming connections only)
- Apps added with `add` are blocked by default; use `allow` to permit connections
- Can also be configured in System Settings > Network > Firewall

---

## `fc ssh`

Manage SSH keys for authentication with remote services. Generate new keys, add them to the ssh-agent, copy public keys to clipboard, and list available keys.

**Usage:**

```bash
fc ssh <subcommand> [options]
```

**Subcommands:**
*   `generate [name]`: Generate a new ed25519 SSH key.
*   `add <name>`: Add an existing key to ssh-agent and Keychain.
*   `copy [name]`: Copy public key to clipboard.
*   `list`: List all SSH key pairs in ~/.ssh.

### fc ssh generate

Generate a new ed25519 SSH key pair with automatic agent registration.

```bash
fc ssh generate [key-name] [options]
```

**Options:**
*   `--email <email>`: Email address for key comment (prompts if not provided).
*   `--no-passphrase`: Generate key without passphrase (less secure).

**Examples:**

```bash
# Generate default key (~/.ssh/id_ed25519)
fc ssh generate

# Generate named key for work
fc ssh generate work --email user@company.com

# Generate without passphrase (for automation)
fc ssh generate deploy --no-passphrase
```

**What it does:**
1. Creates ed25519 key pair (modern, secure algorithm)
2. Prompts for passphrase (unless `--no-passphrase`)
3. Adds key to ssh-agent with Keychain integration
4. Copies public key to clipboard
5. Displays the public key for easy copying

### fc ssh add

Add an existing SSH key to the ssh-agent and macOS Keychain.

```bash
fc ssh add <key-name>
```

**Examples:**

```bash
fc ssh add id_ed25519
fc ssh add work
```

### fc ssh copy

Copy a public key to the clipboard for pasting into GitHub, GitLab, etc.

```bash
fc ssh copy [key-name]
```

Defaults to `id_ed25519` if no key name is specified.

**Examples:**

```bash
fc ssh copy              # Copy id_ed25519.pub
fc ssh copy work         # Copy work.pub
```

### fc ssh list

List all SSH key pairs in ~/.ssh with their type and comment.

```bash
fc ssh list
```

**Output:**

```
SSH Keys in /Users/you/.ssh:

  id_ed25519           ED25519    user@example.com
  work                 ED25519    user@company.com
  github               RSA        old-key@example.com
```

---

## `fc secrets`

Unified secrets management command that integrates with multiple secrets managers (1Password CLI, macOS Keychain, HashiCorp Vault) to fetch secrets and sync them to environment variables or files.

**Usage:**

```bash
fc fc-secrets <subcommand> [options]
```

**Subcommands:**
*   `setup`: Create configuration file and check prerequisites.
*   `sync`: Sync all secrets from config to their destinations.
*   `get <uri>`: Fetch a single secret and print to stdout.
*   `list`: List configured secrets and their destinations.
*   `status`: Show backend authentication status.
*   `verify`: Verify all secrets are accessible (dry-run).

**Backends:**

| Backend | URI Prefix | Requirements |
|---------|------------|--------------|
| 1Password | `op://` | `op` CLI installed, signed in |
| macOS Keychain | `keychain://` | Built-in on macOS |
| HashiCorp Vault | `vault://` | `vault` CLI installed, authenticated |

**URI Formats:**

```bash
# 1Password
op://vault/item/field
op://Personal/github.com/token

# macOS Keychain
keychain://service/account
keychain://api-service/production

# HashiCorp Vault
vault://path/to/secret#field
vault://secret/data/myapp#api_key
```

**Configuration:**

Secrets are configured in `~/.config/circus/secrets.conf`:

```bash
# Format: "<uri>" "<destination>" [permissions]

# Environment variables (written to ~/.zshenv.local)
"op://Personal/github/token"           "env:GITHUB_TOKEN"
"keychain://api-service/key"           "env:API_KEY"
"vault://secret/data/app#api_key"      "env:APP_API_KEY"

# Files with optional permissions
"op://Work/certs/tls"                  "~/.config/app/tls.crt" "644"
"vault://secret/data/db#password"      "~/.config/db/password" "600"
```

**Examples:**

```bash
# Initial setup
fc fc-secrets setup

# Sync all configured secrets
fc fc-secrets sync

# Get a single secret (for scripting)
API_KEY=$(fc fc-secrets get op://Work/api/key)

# Check backend status
fc fc-secrets status

# Verify all secrets are accessible
fc fc-secrets verify

# List configured secrets
fc fc-secrets list
```

**Full Documentation:** See `docs/SECRETS.md` for complete backend setup and configuration details.

---

## `fc sync`

This is a powerful command for managing the full lifecycle of your machine's state. It allows you to create a complete, end-to-end encrypted backup of your applications and data and then restore that state to a new machine.

**Usage:**

```bash
fc sync <subcommand> [options]
```

**Subcommands:**
*   `setup`: Create configuration file from template.
*   `backup`: Back up and encrypt critical data.
*   `restore`: Decrypt and restore data from backup.
*   `push`: Upload local backup to remote storage (GPG backend only).
*   `pull`: Download backup from remote storage (GPG backend only).
*   `list-remote`: List available backups on remote storage (GPG backend only).

**Options:**
*   `--no-confirm`: Skip confirmation prompts (for automation).

### Backup Backends

The sync command supports multiple backup backends, each with different strengths:

| Backend | Description | Remote Support |
|---------|-------------|----------------|
| `gpg` (default) | tar + GPG encryption | Via rclone (push/pull) |
| `restic` | Deduplication, incremental | Native (S3, SFTP, etc.) |
| `borg` | Deduplication, compression | Native (SSH) |

Set your preferred backend in `~/.config/circus/sync.conf`:

```bash
# Options: "gpg", "restic", "borg"
BACKUP_BACKEND="gpg"
```

For detailed backend configuration, see [docs/BACKUP_BACKENDS.md](docs/BACKUP_BACKENDS.md).

### The Migration Workflow

Here is the recommended workflow for using `fc sync` to migrate to a new machine:

**1. On Your OLD Machine:**

Run the `backup` command. This will create an encrypted `circus_backup.tar.gz.gpg` file in your home directory.

```bash
fc sync backup
```

Optionally, push to remote storage:

```bash
fc sync push
```

**2. On Your NEW Machine:**

First, run the main `./install.sh` script to lay down the foundational scaffolding for your chosen role. Then, either copy your encrypted backup archive manually or pull from remote storage:

```bash
fc sync pull
```

Finally, run the `restore` command. This will prompt for your GPG passphrase, decrypt the archive, and then restore your applications and data.

```bash
fc sync restore
```

The result is a new machine that is a near-perfect mirror of your old environment.

### Remote Storage (GPG Backend)

The GPG backend uses [rclone](https://rclone.org/) to upload backups to cloud storage providers. This enables off-site backup protection against local data loss.

**Note:** The Restic and Borg backends have native remote support. Configure their repository settings to point directly to remote storage instead of using the push/pull commands.

**Setup:**

1. Install rclone: `brew install rclone`
2. Configure a remote: `rclone config`
3. Edit sync.conf: `$EDITOR ~/.config/circus/sync.conf`
4. Set `RCLONE_REMOTE` to your remote name (e.g., "gdrive", "s3-backup")

**Configuration Variables:**

```bash
# Remote name as configured in rclone (run: rclone listremotes)
RCLONE_REMOTE="gdrive"

# Path within the remote for backups
RCLONE_REMOTE_PATH="circus-backups"
```

**Examples:**

```bash
# Upload backup to remote
fc sync push

# Download backup from remote
fc sync pull

# List backups on remote
fc sync list-remote
```

**Supported Providers:**

rclone supports 40+ backends including:
- Amazon S3, Google Drive, Dropbox
- Backblaze B2, Microsoft OneDrive
- SFTP, WebDAV, and many more

See [rclone.org](https://rclone.org/) for the full list.

---

## `fc vscode-sync`

Sync VS Code settings, extensions, keybindings, and snippets to GitHub Gist or a Git repository. Enables consistent VS Code configuration across multiple machines.

**Usage:**

```bash
fc vscode-sync <subcommand> [options]
```

**Subcommands:**
*   `setup`: Create configuration file and check prerequisites.
*   `up`: Push local VS Code settings to remote.
*   `down`: Pull remote settings and apply locally.
*   `status`: Show differences between local and remote.

### Storage Backends

| Backend | Description | Best For |
|---------|-------------|----------|
| `gist` (default) | Private GitHub Gist | Simple, quick setup |
| `repo` | Dedicated Git repository | Full version control |

### Configuration

Edit `~/.config/circus/vscode-sync.conf`:

```bash
# Backend: "gist" or "repo"
VSCODE_SYNC_BACKEND="gist"

# Gist backend settings
VSCODE_GIST_ID=""  # Auto-created on first push

# Files to sync (true/false)
SYNC_SETTINGS=true
SYNC_KEYBINDINGS=true
SYNC_SNIPPETS=true
SYNC_EXTENSIONS=true
SYNC_TASKS=false
SYNC_LAUNCH=false
```

### Authentication

Token retrieval priority:
1. macOS Keychain (service: github.com, account: vscode-sync)
2. `gh` CLI authentication (`gh auth login`)
3. `GITHUB_TOKEN` environment variable

To store token in Keychain:

```bash
security add-generic-password -s "github.com" -a "vscode-sync" -w "YOUR_TOKEN"
```

### What Gets Synced

| File | Config Flag | Description |
|------|-------------|-------------|
| settings.json | SYNC_SETTINGS | Editor preferences |
| keybindings.json | SYNC_KEYBINDINGS | Keyboard shortcuts |
| snippets/ | SYNC_SNIPPETS | Code snippets |
| extensions list | SYNC_EXTENSIONS | Installed extensions |
| tasks.json | SYNC_TASKS | Build tasks (opt-in) |
| launch.json | SYNC_LAUNCH | Debug configs (opt-in) |

**Examples:**

```bash
# Initial setup
fc vscode-sync setup

# Push current settings to remote
fc vscode-sync up

# Pull and apply settings from remote (new machine)
fc vscode-sync down

# Check what's different between local and remote
fc vscode-sync status
```

---

## `fc schedule`

Manage scheduled automatic backups using macOS's native launchd service. This provides a "set it and forget it" approach to keeping your backups current.

**Usage:**

```bash
fc fc-schedule <subcommand> [options]
```

**Subcommands:**
*   `install`: Install and enable scheduled backups.
*   `uninstall`: Disable and remove scheduled backups.
*   `status`: Show backup schedule status and last run time.
*   `run`: Manually trigger a backup now.

**Options for install:**
*   `--frequency <daily|weekly>`: Backup frequency (default: daily).

**Examples:**

```bash
# Install daily scheduled backups
fc fc-schedule install

# Install weekly backups instead
fc fc-schedule install --frequency weekly

# Check the schedule status
fc fc-schedule status

# Manually run a backup
fc fc-schedule run

# Remove scheduled backups
fc fc-schedule uninstall
```

### How It Works

The `fc schedule` command uses macOS's launchd to run `fc sync backup` automatically. When you install the schedule:

1. A launchd agent is installed to `~/Library/LaunchAgents/`
2. Backups run in the background at the specified frequency
3. Output is logged to `~/.circus/logs/backup.log`

**Prerequisites:**
- You must configure `fc sync` first (run `fc fc-sync setup`)
- GPG must be configured with your key ID

---

## `fc apps`

Manage application installations via Homebrew and Mac App Store. Define your apps in a configuration file and install them with a single command.

**Usage:**

```bash
fc fc-apps <subcommand> [options]
```

**Subcommands:**
*   `setup`: Create configuration file from template.
*   `list`: Show configured apps and their installation status.
*   `install`: Install all apps from configuration.
*   `add --brew <name>`: Add and install a Homebrew formula.
*   `add --cask <name>`: Add and install a Homebrew cask.
*   `add --mas <name> <id>`: Add and install a Mac App Store app.

**Options:**
*   `--no-confirm`: Skip confirmation prompts.

**Examples:**

```bash
# Create configuration file
fc fc-apps setup

# Add apps to configuration and install them
fc fc-apps add --cask visual-studio-code
fc fc-apps add --cask slack
fc fc-apps add --brew ripgrep
fc fc-apps add --mas "Xcode" 497799835

# Check what's configured and installed
fc fc-apps list

# Install all configured apps
fc fc-apps install
```

### Configuration File

The configuration file (`~/.config/circus/apps.conf`) uses Brewfile syntax:

```bash
# Homebrew formulae (CLI tools)
brew "ripgrep"
brew "fzf"

# Homebrew casks (GUI applications)
cask "visual-studio-code"
cask "slack"

# Mac App Store apps (requires mas-cli)
mas "Xcode", id: 497799835
mas "1Password 7", id: 1333542190
```

To find Mac App Store app IDs, use: `mas search <name>`

---

## `fc disk`

Analyze disk usage, find space hogs, and clean up common cache locations.

**Usage:**

```bash
fc disk <subcommand> [options]
```

**Subcommands:**
*   `status`: Show disk usage summary for all mounted volumes.
*   `usage [path]`: Analyze disk usage for a directory (defaults to home).
*   `large [path]`: Find the largest files in a directory.
*   `cleanup`: Interactive cleanup wizard for caches, logs, and trash.
*   `health`: Display S.M.A.R.T. disk health status.

**Options:**
*   `--count N`: Number of items to show (for `large` action).
*   `--all`: Show all items (for `usage` action).

**Examples:**

```bash
# Check disk space across volumes
fc disk status

# Analyze what's using space in Documents
fc disk usage ~/Documents

# Find 20 largest files in Downloads
fc disk large ~/Downloads --count 20

# Clean up caches and free space
fc disk cleanup

# Check disk health
fc disk health
```

---

## `fc clipboard`

Clipboard utilities for viewing, copying, and transforming clipboard contents.

**Usage:**

```bash
fc clipboard <subcommand> [text]
```

**Subcommands:**
*   `show`: Show current clipboard contents.
*   `clear`: Clear the clipboard.
*   `copy <text>`: Copy text to clipboard.
*   `plain`: Convert clipboard to plain text (remove rich formatting).
*   `count`: Count characters, words, and lines in clipboard.

**Examples:**

```bash
# View what's on clipboard
fc clipboard show

# Copy text to clipboard
fc clipboard copy "Hello World"

# Pipe output to clipboard
echo "piped text" | fc clipboard copy

# Clear clipboard (for security)
fc clipboard clear

# Get word count
fc clipboard count
```

---

## `fc privacy`

View and manage macOS privacy permissions (Camera, Microphone, Screen Recording, etc.)

**Usage:**

```bash
fc privacy <action> [category]
```

**Actions:**
*   `list`: List all privacy permission categories.
*   `status`: Show overview of granted permissions.
*   `camera`, `microphone`, `screen`, `accessibility`, `disk`: View apps with that permission.
*   `open [category]`: Open System Settings for a category.
*   `reset <category>`: Reset permissions for a category.

**Note:** Reading the TCC database requires Full Disk Access. If unavailable, the command will open System Settings as a fallback.

**Examples:**

```bash
# List all categories
fc privacy list

# See which apps have camera access
fc privacy camera

# Open Screen Recording settings
fc privacy open screen

# Reset microphone permissions
fc privacy reset microphone
```

---

## `fc keychain`

Interact with macOS Keychain—list, search, add, and retrieve passwords and secrets.

**Usage:**

```bash
fc keychain <action> [options]
```

**Actions:**
*   `list`: List keychain items (no passwords shown).
*   `search <query>`: Search for keychain items.
*   `get <name>`: Get a password (copies to clipboard).
*   `wifi [ssid]`: Get WiFi network password.
*   `add`: Add a new keychain entry (interactive).
*   `delete <name>`: Delete a keychain entry.

**Options:**
*   `--show`: Show password instead of copying to clipboard.
*   `--account <acct>`: Specify account name for lookup.

**Examples:**

```bash
# List all keychain items
fc keychain list

# Search for GitHub-related entries
fc keychain search github

# Get a password (will prompt for Keychain access)
fc keychain get api-token

# Get current WiFi password
fc keychain wifi

# Get specific WiFi password
fc keychain wifi "Coffee Shop"

# Add new password
fc keychain add
```

---

## `fc encrypt`

Encrypt and decrypt files using GPG (with OpenSSL fallback).

**Usage:**

```bash
fc encrypt <action> [path] [options]
```

**Actions:**
*   `file <path>`: Encrypt a file with password.
*   `decrypt <path>`: Decrypt an encrypted file.
*   `folder <path>`: Encrypt a folder as a tar.gz archive.
*   `text`: Encrypt text from stdin (copies to clipboard).

**Options:**
*   `--delete`: Delete original after encryption.
*   `--output <path>`: Specify output file path.

**Examples:**

```bash
# Encrypt a file
fc encrypt file secrets.txt

# Decrypt a file
fc encrypt decrypt secrets.txt.gpg

# Encrypt a folder
fc encrypt folder ~/Documents/private/

# Encrypt and delete original
fc encrypt file passwords.json --delete

# Encrypt text from pipe
echo "API_KEY=secret" | fc encrypt text
```

---

## `fc lock`

Control screen lock, display sleep, and password requirements.

**Usage:**

```bash
fc lock <action> [value]
```

**Actions:**
*   `now`: Lock the screen immediately.
*   `status`: Show current lock settings.
*   `require <on/off>`: Require password after sleep.
*   `timeout <seconds>`: Set display sleep timeout (0 = never).
*   `screensaver`: Start screen saver now.

**Examples:**

```bash
# Lock screen immediately
fc lock now

# Check current settings
fc lock status

# Require password after sleep
fc lock require on

# Set display to sleep after 10 minutes
fc lock timeout 600

# Never sleep display
fc lock timeout 0
```

---

## `fc dotfiles`

Manage dotfiles tracked by the Dotfiles Flying Circus. Add new files to the repository, list managed dotfiles and their status, or edit existing dotfiles.

**Usage:**

```bash
fc fc-dotfiles <subcommand> [options]
```

**Subcommands:**
*   `add <file>`: Add a file to the dotfiles repository and create a symlink in its place.
*   `list`: List all managed dotfiles and their symlink status.
*   `edit <name>`: Open a managed dotfile in `$EDITOR`.

**Examples:**

```bash
# Add your vim config to the repository
fc fc-dotfiles add ~/.vimrc

# List all tracked dotfiles and their status
fc fc-dotfiles list

# Edit your git config
fc fc-dotfiles edit .gitconfig
```

### Adding a Dotfile

When you run `fc fc-dotfiles add`, the command will:

1. Prompt you to select a target subdirectory (bash, git, zsh, etc.)
2. Move the file to `profiles/base/<subdir>/`
3. Create a symlink from the original location to the new location

This keeps your dotfiles organized and tracked in the repository while maintaining their expected location in your home directory.

---

## `fc profile`

Manage dotfile profiles for switching between different configurations (e.g., work vs personal). Profiles allow you to maintain environment-specific overrides while sharing a common base configuration.

**Usage:**

```bash
fc fc-profile <subcommand>
```

**Subcommands:**
*   `list`: List all available profiles and show which one is active.
*   `current`: Display the currently active profile and its overrides.
*   `switch <profile>`: Switch to a different profile.

**Examples:**

```bash
# List available profiles
fc fc-profile list

# See current profile
fc fc-profile current

# Switch to work profile
fc fc-profile switch work

# Switch to personal profile
fc fc-profile switch personal
```

### How Profiles Work

Profiles use a layering system:

1. **Base Configuration** (`profiles/base/`): Common dotfiles shared across all environments
2. **Profile Overrides** (`profiles/<name>/`): Environment-specific files that replace base files

When you switch profiles:
1. All dotfiles from `profiles/base/` are symlinked to your home directory
2. Files from the selected profile override the base symlinks
3. The current profile is saved to `~/.config/circus/current_profile`

### Creating a New Profile

```bash
# Create a new profile directory
mkdir -p profiles/myprofile

# Add override files (e.g., a different .gitconfig)
cat > profiles/myprofile/.gitconfig << 'EOF'
[user]
    name = Your Name
    email = specific@email.com
EOF

# Switch to your new profile
fc fc-profile switch myprofile
```

See `docs/PROFILES.md` for detailed documentation on the profile system.

---

## `fc context`

Manage development contexts for project-specific environments. Contexts store environment variables, runtime versions, Git identities, and custom activation scripts to quickly switch between different project configurations.

**Usage:**

```bash
fc context <subcommand> [options]
```

**Subcommands:**
*   `list`: List all defined contexts.
*   `current`: Show the active context and its settings.
*   `switch <name>`: Switch to a context (loads env vars, runs version managers).
*   `create [name]`: Create a new context with interactive wizard.
*   `edit <name>`: Open context file in your editor.
*   `delete <name>`: Delete a context.
*   `export <name>`: Export context as shareable file.
*   `import <file>`: Import context from file.
*   `shell`: Open subshell with context loaded.
*   `off`: Deactivate the current context.

**Examples:**

```bash
# List available contexts
fc context list

# Create a new context interactively
fc context create project-alpha

# Switch to a context
fc context switch project-alpha

# See current context and settings
fc context current

# Deactivate context
fc context off

# Open subshell with context
fc context shell project-alpha

# Export for sharing
fc context export project-alpha
fc context import project-alpha.context
```

### How Contexts Work

Contexts are project-specific configurations that complement profiles:
- **Profiles** (`fc profile`): Machine-wide settings (developer, work, personal)
- **Contexts** (`fc context`): Project-specific settings

When you switch to a context:
1. Environment variables are loaded from `~/.config/circus/contexts/<name>.conf`
2. Version managers are called (nvm, pyenv, goenv, rbenv)
3. Git identity is set via environment variables
4. Custom activation commands run
5. Context state is saved to `~/.config/circus/current_context`

### Context Configuration File

Contexts are stored in `~/.config/circus/contexts/<name>.conf`:

```bash
# --- Environment Variables ---
export AWS_PROFILE="project-alpha-dev"
export DATABASE_URL="postgres://localhost/alpha_dev"
export API_KEY="from-secrets:op://Personal/alpha/api-key"

# --- Version Managers ---
NODE_VERSION="18"
PYTHON_VERSION="3.11"
GO_VERSION="1.21"

# --- Git Identity ---
GIT_USER_NAME="Ryan Developer"
GIT_USER_EMAIL="ryan@alpha-project.com"

# --- Custom Commands ---
ON_ACTIVATE="docker-compose up -d"
ON_DEACTIVATE="docker-compose down"
```

### Secrets Integration

Use `from-secrets:` prefix to load values from 1Password:

```bash
export API_KEY="from-secrets:op://Personal/myproject/api-key"
```

This integrates with `fc secrets` to resolve secrets at context activation time.

### Shell Integration

Contexts are automatically loaded in new shells when the circus plugin sources `~/.circus/context_env.sh`. The `FC_ACTIVE_CONTEXT` environment variable indicates the current context.

---

## `fc audit`

Run security audits to check system protection settings.

**Usage:**

```bash
fc audit <action>
```

**Actions:**
*   `run`: Run full security audit (8 checks with scoring).
*   `quick`: Quick check of critical settings.
*   `sip`: Check System Integrity Protection.
*   `filevault`: Check FileVault encryption status.
*   `gatekeeper`: Check Gatekeeper status.
*   `firewall`: Check firewall status.

**Checks Include:**
- SIP, FileVault, Gatekeeper, Firewall
- Password after sleep, Auto login
- Stealth mode, Remote login (SSH)

**Examples:**

```bash
# Full security audit
fc audit run

# Quick check (4 critical items)
fc audit quick

# Check specific features
fc audit sip
fc audit filevault
```

---

## `fc update`

Unified system update command. Updates macOS, Homebrew packages, Mac App Store apps, and the dotfiles repository.

**Usage:**

```bash
fc update [options]
```

**Update Targets:**
*   `--all`: Update everything (default behavior).
*   `--os`: Update macOS only.
*   `--packages`: Update Homebrew formulae, casks, and Mac App Store apps.
*   `--self`: Update the dotfiles repository only.

**Options:**
*   `--check`: Check for dotfiles updates without applying them.
*   `--dry-run`: Show what would be done without making changes.
*   `--skip-migrations`: Skip running migration scripts (for --self).
*   `--version`: Show the current installed version.
*   `--help`: Show help message.

**Examples:**

```bash
# Update everything (macOS, packages, and dotfiles)
fc update

# Update only Homebrew and Mac App Store packages
fc update --packages

# Update only macOS
fc update --os

# Update only the dotfiles repository
fc update --self

# Preview what would be updated
fc update --dry-run

# Check for dotfiles updates
fc update --check

# Combine targets
fc update --packages --self
```

### How It Works

The `fc update` command runs updates in the following order:

1. **Packages** (`--packages`): Updates Homebrew (`brew update && brew upgrade`), Homebrew casks, and Mac App Store apps (if `mas` is installed).

2. **macOS** (`--os`): Checks for system updates using `softwareupdate`. Prompts for confirmation before installing as updates may require a restart.

3. **Dotfiles** (`--self`): Pulls the latest dotfiles from the remote repository, runs any applicable migrations, and updates role dependencies.

The order ensures that package managers are up-to-date before system updates, and dotfiles are updated last to get any new configuration.

---

## `fc maintenance`

Run routine system maintenance and cleanup tasks. This provides automated batch execution of common maintenance operations, complementing `fc disk cleanup` (interactive) with a "set it and forget it" approach.

**Usage:**

```bash
fc fc-maintenance [subcommand] [options]
```

**Subcommands:**
*   `(none)`: Run configured maintenance tasks.
*   `setup`: Create configuration file from template.
*   `list`: List all available maintenance tasks.
*   `run <task>`: Run a specific maintenance task.

**Options:**
*   `--all`: Run all tasks (including disabled ones).
*   `--include-trash`: Include trash emptying in this run.
*   `--dry-run`: Show what would be done without executing.
*   `--help`: Show help message.

**Examples:**

```bash
# Run default maintenance tasks
fc fc-maintenance

# Preview what would be done
fc fc-maintenance --dry-run

# Run all tasks including disabled ones
fc fc-maintenance --all

# List available tasks
fc fc-maintenance list

# Run a specific task
fc fc-maintenance run dns-flush

# Include trash emptying
fc fc-maintenance --include-trash
```

### Available Tasks

| Task | Description | Default | Sudo |
|------|-------------|---------|------|
| `brew-cleanup` | Run `brew cleanup` to remove old versions | Yes | No |
| `brew-cache` | Clear Homebrew download cache | Yes | No |
| `npm-cache` | Clear npm cache | Yes | No |
| `pip-cache` | Clear pip cache | Yes | No |
| `xcode-derived` | Clear Xcode DerivedData | Yes | No |
| `user-logs` | Clear old user log files | Yes | No |
| `system-logs` | Clear system log files | No | Yes |
| `dns-flush` | Flush DNS cache | No | Yes |
| `spotlight-rebuild` | Rebuild Spotlight index | No | Yes |
| `disk-verify` | Verify disk health | No | No |
| `trash` | Empty the Trash | No | No |

### Configuration

The configuration file (`~/.config/circus/maintenance.conf`) allows you to customize which tasks run by default:

```bash
# Enable/disable specific tasks
TASK_BREW_CLEANUP=true
TASK_NPM_CACHE=true
TASK_TRASH=false

# Configure retention periods
LOG_RETENTION_DAYS=7
BREW_PRUNE_DAYS=30
```

Run `fc fc-maintenance setup` to create the configuration file from the template.

---

## `fc clean`

Find and remove orphaned Homebrew packages—packages that are installed but not defined in any Brewfile. This helps keep your system in sync with your Brewfile definitions.

**Usage:**

```bash
fc fc-clean <subcommand> [options]
```

**Subcommands:**
*   `brew`: Find orphaned Homebrew formulae.
*   `casks`: Find orphaned Homebrew casks.
*   `list`: List all orphaned packages (for scripting).

**Options:**
*   `--remove`: Interactively select packages to remove.
*   `--remove-all`: Remove all orphaned packages (with confirmation).
*   `--skip-deps`: Exclude packages that are dependencies of others.

**Examples:**

```bash
# Show orphaned formulae
fc fc-clean brew

# Interactively remove orphaned formulae
fc fc-clean brew --remove

# Show orphaned casks
fc fc-clean casks

# List all orphaned packages (for scripting)
fc fc-clean list

# List only orphaned formulae
fc fc-clean list --formula

# Exclude dependencies from results
fc fc-clean brew --skip-deps
```

### How It Works

The `fc clean` command compares installed Homebrew packages against packages defined in your Brewfiles:

1. **Scans installed packages**: Gets the list of formulae/casks from `brew list`
2. **Parses Brewfiles**: Reads expected packages from:
   - `$DOTFILES_ROOT/Brewfile`
   - `$DOTFILES_ROOT/roles/*/Brewfile`
   - `$DOTFILES_ROOT/etc/Brewfile`
   - `~/.config/circus/apps.conf`
3. **Identifies orphans**: Finds packages that are installed but not defined anywhere

Orphaned packages may be:
- Experiments you tried and forgot about
- Dependencies installed manually
- Packages from a removed Brewfile

### Adopting vs Removing

When you find orphaned packages, you have two choices:

**Adopt the package** (add to your Brewfile):
```bash
fc fc-apps add --brew <package-name>
fc fc-apps add --cask <package-name>
```

**Remove the package**:
```bash
# Individual removal
brew uninstall <package-name>

# Interactive removal of multiple packages
fc fc-clean brew --remove
```

---

## `fc alfred`

Manage the Flying Circus Alfred workflow installation. The workflow provides quick access to common `fc` commands directly from Alfred's search bar.

**Usage:**

```bash
fc alfred <action>
```

**Actions:**
*   `install`: Install the workflow to Alfred.
*   `uninstall`: Remove the workflow from Alfred.
*   `status`: Check if the workflow is installed.

**Examples:**

```bash
# Install the Alfred workflow
fc alfred install

# Check installation status
fc alfred status

# Remove the workflow
fc alfred uninstall
```

### Available Alfred Keywords

After installation, these keywords are available in Alfred:

| Keyword | Command | Description |
|---------|---------|-------------|
| `fc` | (browse) | Browse all available commands |
| `wifi` | `fc wifi` | Control Wi-Fi (on/off/status) |
| `bluetooth` | `fc bluetooth` | Control Bluetooth (on/off/status) |
| `lock` | `fc lock now` | Lock screen immediately |
| `caffeine` | `fc caffeine` | Prevent sleep (on/off/for/status) |
| `dns` | `fc dns` | Manage DNS servers |
| `airdrop` | `fc airdrop` | Control AirDrop visibility |
| `fcinfo` | `fc info` | Display system information |
| `healthcheck` | `fc healthcheck` | Run system diagnostics |
| `disk` | `fc disk` | Disk utilities |
| `sshkey` | `fc ssh` | SSH key management |
| `keychain` | `fc keychain` | Keychain access |
| `clip` | `fc clipboard` | Clipboard utilities |

### Requirements

- **Alfred 4 or 5** with Powerpack (recommended)
- Dotfiles Flying Circus installed

See `docs/ALFRED.md` for full documentation.

---

## `fc raycast`

Manage the Flying Circus Raycast script commands installation. Script commands provide quick access to common `fc` commands directly from Raycast's launcher.

**Usage:**

```bash
fc raycast <action>
```

**Actions:**
*   `install`: Install the script commands to Raycast.
*   `uninstall`: Remove the script commands from Raycast.
*   `status`: Check if the script commands are installed.

**Examples:**

```bash
# Install the Raycast script commands
fc raycast install

# Check installation status
fc raycast status

# Remove the script commands
fc raycast uninstall
```

### Available Raycast Commands

After installation, these commands are available in Raycast:

| Command | Description | Mode |
|---------|-------------|------|
| Wi-Fi On/Off/Status | Control Wi-Fi adapter | Silent/Compact |
| Bluetooth On/Off/Status | Control Bluetooth | Silent/Compact |
| Lock Screen | Lock screen immediately | Silent |
| Caffeine On/Off/30min/1hr/Status | Prevent sleep | Silent/Compact |
| DNS Status/Cloudflare/Google/Quad9/Clear | Manage DNS servers | Silent/Compact |
| AirDrop Everyone/Contacts/Off/Status | Control AirDrop visibility | Silent/Compact |
| System Info | Display system information | Full Output |
| System Healthcheck | Run system diagnostics | Full Output |
| Disk Status/Usage | Disk utilities | Compact/Full Output |
| SSH: List Keys / Copy Public Key | SSH key management | Compact/Silent |
| Clipboard: Clear | Clear clipboard | Silent |

### Requirements

- **Raycast** installed
- Dotfiles Flying Circus installed

See `docs/RAYCAST.md` for full documentation.

---

## `fc uninstall`

Completely uninstall macOS applications including the app bundle, preferences, caches, containers, and support files.

**Usage:**

```bash
fc uninstall <action> [options]
```

**Actions:**
*   `<app-name>`: Uninstall the specified application (requires `--force`).
*   `list <app>`: Preview files that would be removed (dry run).
*   `scan`: Find installed applications and their disk usage.

**Options:**
*   `--force`: Actually delete files (required for uninstall).
*   `--keep-prefs`: Keep preference files when uninstalling.

**Cleanup Locations:**
- `/Applications/<App>.app` (Application bundle)
- `~/Library/Preferences/<bundle-id>.*` (Preference files)
- `~/Library/Caches/<bundle-id>/` (Cache files)
- `~/Library/Application Support/<App>/` (Support files)
- `~/Library/Containers/<bundle-id>/` (Sandbox containers)
- `~/Library/Saved Application State/` (Window state)

**Examples:**

```bash
# Preview what would be removed
fc uninstall list Slack

# Actually uninstall the app
fc uninstall Slack --force

# List installed apps with sizes
fc uninstall scan
```

> **Note:** Dry-run by default. System apps in `/System/Applications` are protected.

---

## `fc theme`

Manage and switch between shell/terminal themes. Change colors, prompts, and shell appearance with a single command.

**Usage:**

```bash
fc theme <action> [theme-name]
```

**Actions:**
*   `list`: Show available themes.
*   `current`: Show the currently active theme.
*   `apply <name>`: Apply a theme.
*   `preview <name>`: Preview theme colors without applying.
*   `create <name>`: Create a new theme from template.

**Built-in Themes:**
*   `dark`: Dark color scheme with minimal prompt.
*   `light`: Light color scheme for bright environments.

**Examples:**

```bash
# List available themes
fc theme list

# Apply dark theme
fc theme apply dark

# Show current theme
fc theme current

# Create a custom theme
fc theme create my-custom
```

**Theme Structure:**

Themes are stored in `$DOTFILES_ROOT/themes/<name>/` with:
- `theme.conf` - Theme metadata (name, description, author)
- `colors.sh` - Color variable exports
- `prompt.zsh` - Zsh prompt configuration

---

## `fc network`

Network diagnostics and troubleshooting tool. Run comprehensive connectivity tests, check latency, verify DNS, and display local network configuration.

**Usage:**

```bash
fc network <action> [options]
```

**Actions:**
*   `status`: Quick connectivity overview (default).
*   `diag`: Full diagnostic suite (6 tests).
*   `info`: Show local network configuration.
*   `latency [host]`: Ping test with statistics.
*   `dns [domain]`: DNS resolution test.
*   `trace [host]`: Traceroute to a host.
*   `port <host> <port>`: Check if a port is open.
*   `speed`: Run speed test (requires speedtest-cli).

**Diagnostic Suite (`fc network diag`):**
1. Local Info - IP address, gateway, DNS servers
2. Gateway Ping - Local network health
3. Internet Ping - 1.1.1.1, 8.8.8.8
4. DNS Resolution - apple.com, google.com
5. HTTPS Check - Verifies full HTTP connectivity
6. Latency Summary

**Examples:**

```bash
# Quick status check
fc network

# Full diagnostic suite
fc network diag

# Local network configuration
fc network info

# Check if GitHub HTTPS is reachable
fc network port github.com 443

# Trace route to Google DNS
fc network trace 8.8.8.8
```

---

## `fc docker`

Docker cleanup utility for reclaiming disk space. Removes unused images, stopped containers, dangling volumes, and build cache.

**Usage:**

```bash
fc docker <action> [options]
```

**Actions:**
*   `status`: Show Docker disk usage summary.
*   `clean`: Safe cleanup (dangling images/containers).
*   `clean --all`: Aggressive cleanup (all unused).
*   `clean --hard`: Nuclear option (everything including volumes).
*   `images`: List and prune unused images.
*   `containers`: List and prune stopped containers.
*   `volumes`: List and prune unused volumes.
*   `cache`: Clear build cache.

**Options:**
*   `--force`: Skip confirmation prompts.
*   `--dry-run`: Show what would be removed.

**Cleanup Levels:**

| Level | What it removes |
|-------|-----------------|
| `clean` | Dangling images, stopped containers (safe) |
| `clean --all` | ALL unused images, containers, networks |
| `clean --hard` | Everything including volumes (DESTRUCTIVE) |

**Examples:**

```bash
# Check Docker disk usage
fc docker status

# Safe cleanup
fc docker clean

# Preview aggressive cleanup
fc docker clean --all --dry-run

# Clear build cache
fc docker cache
```

> **Warning:** The `--hard` option is destructive and will delete all Docker data including volumes.

---

## `fc desktop`

Desktop organization utility. Move files from the desktop into date-stamped archive folders or organize by file type.

**Usage:**

```bash
fc desktop <action> [options]
```

**Actions:**
*   `status`: Show desktop statistics (file count, size).
*   `clean`: Move files to dated archive folder.
*   `organize`: Organize files by type (Images, Documents, etc.).
*   `undo`: Restore last archived files.
*   `config`: Show/edit configuration.

**Options:**
*   `--dry-run`: Preview what would be moved.
*   `--force`: Skip confirmation prompts.
*   `--keep-dirs`: Don't move directories, only files.

**Organization Categories:**
- `Images/` - jpg, png, gif, heic, webp, svg
- `Documents/` - pdf, doc, docx, xls, txt, md
- `Screenshots/` - Files starting with "Screenshot"
- `Videos/` - mp4, mov, avi, mkv
- `Audio/` - mp3, wav, m4a, flac
- `Archives/` - zip, tar, gz, rar, 7z
- `Code/` - js, ts, py, rb, sh, json
- `Other/` - Everything else

**Examples:**

```bash
# See what's on desktop
fc desktop status

# Archive to dated folder
fc desktop clean

# Preview archive
fc desktop clean --dry-run

# Organize by file type
fc desktop organize

# Restore last cleanup
fc desktop undo
```

---

## `fc history`

Enhanced shell history search using fzf for interactive fuzzy finding.

**Usage:**

```bash
fc history [action] [options]
```

**Actions:**
*   `search`: Interactive fuzzy search (default).
*   `stats`: Show history statistics.
*   `top`: Show most used commands.
*   `clean`: Remove duplicates from history.
*   `setup`: Configure shell integration (Ctrl+R binding).

**Options:**
*   `--count N`: Number of results to show (for `top`).

**Dependencies:** Requires `fzf` (`brew install fzf`).

**Examples:**

```bash
# Interactive search (default)
fc history

# Show history statistics
fc history stats

# Top 20 most used commands
fc history top --count 20

# Remove duplicate entries
fc history clean

# Set up Ctrl+R integration
fc history setup
```

---

## `fc scaffold`

Project scaffolding tool for quickly creating new projects from templates with variable substitution.

**Usage:**

```bash
fc scaffold <action> [options]
```

**Actions:**
*   `new <template> <name>`: Create new project from template.
*   `list`: List available templates.
*   `show <template>`: Show template details.
*   `create-template <name>`: Create new template from current directory.

**Options:**
*   `--author <name>`: Set author name (default: git user.name).
*   `--dir <path>`: Output directory (default: current).
*   `--force`: Overwrite if exists.

**Template Variables:**

| Variable | Description |
|----------|-------------|
| `{{PROJECT_NAME}}` | Name of the project |
| `{{PROJECT_NAME_UPPER}}` | Name in UPPER_SNAKE_CASE |
| `{{PROJECT_NAME_LOWER}}` | Name in lowercase |
| `{{AUTHOR}}` | Author name |
| `{{YEAR}}` | Current year |
| `{{DATE}}` | Current date (YYYY-MM-DD) |

**Template Locations:**
- Built-in: `$DOTFILES_ROOT/templates/projects/`
- Custom: `~/.config/circus/templates/`

**Examples:**

```bash
# List available templates
fc scaffold list

# Create Python CLI project
fc scaffold new python-cli myapp

# View template details
fc scaffold show python-cli

# Save current directory as template
fc scaffold create-template my-template
```

