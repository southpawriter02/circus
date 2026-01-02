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







