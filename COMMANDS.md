# Custom Commands (`fc`)

This document provides an overview of the custom command-line utility, `fc` (Dotfiles Flying Circus), included in this repository. This tool provides a suite of helpful commands for system inspection, management, and state synchronization.

## Usage

The `fc` command is the main entry point for all subcommands.

```bash
fc <command> [options]
```

To see a list of all available commands, simply run `fc` with no arguments.

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

Manage the macOS application firewall from the command line. Controls incoming connections to applications on your Mac.

**Usage:**

```bash
fc firewall <action>
```

**Actions:**
*   `on`: Turn the application firewall on.
*   `off`: Turn the application firewall off.
*   `status`: Show the current firewall state.

**Examples:**

```bash
# Enable the firewall
fc firewall on

# Disable the firewall
fc firewall off

# Check current state
fc firewall status
```

**Notes:**
- All actions require administrator (sudo) privileges
- The macOS firewall is an application-level firewall, not a packet filter
- It controls incoming connections to applications
- It does NOT filter outgoing connections
- Can also be configured in System Settings > Network > Firewall

---

## `fc sync`

This is a powerful command for managing the full lifecycle of your machine's state. It allows you to create a complete, end-to-end encrypted backup of your applications and data and then restore that state to a new machine.

### The Migration Workflow

Here is the recommended workflow for using `fc sync` to migrate to a new machine:

**1. On Your OLD Machine:**

Run the `backup` command. This will create an encrypted `circus_backup.tar.gz.gpg` file in your home directory.

```bash
fc sync backup
```

Once complete, copy this encrypted archive to an external drive or cloud storage service.

**2. On Your NEW Machine:**

First, run the main `./install.sh` script to lay down the foundational scaffolding for your chosen role. Then, copy your encrypted backup archive to your new machine's home folder.

Finally, run the `restore` command. This will prompt for your GPG passphrase, decrypt the archive, and then restore your applications and data.

```bash
fc sync restore
```

The result is a new machine that is a near-perfect mirror of your old environment.

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

