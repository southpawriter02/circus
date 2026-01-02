# fc bootstrap - Automated New Machine Setup

`fc bootstrap` is a meta-command that orchestrates the complete setup of a new machine. It runs a series of phases to install dependencies, deploy dotfiles, configure the system, and install applications.

## Quick Start

```bash
# Interactive mode (recommended for first-time setup)
fc fc-bootstrap

# Check what's been configured
fc fc-bootstrap status

# Preview what would be done without making changes
fc fc-bootstrap --dry-run
```

## Features

- **Phase-based execution**: 7 distinct phases that can be skipped, run individually, or resumed
- **Resumable**: If interrupted, resume from where you left off
- **Dual wizard modes**: Interactive prompts or rich Gum-based TUI
- **Unattended mode**: Configure once, run anywhere with `AUTO_CONFIRM=true`
- **Dry-run support**: Preview all changes before executing
- **Backup restoration**: Optionally restore from `fc sync` backup

## Phases

| Phase | Name | Description |
|-------|------|-------------|
| 1 | Preflight | Check system requirements (macOS version, disk space, internet) |
| 2 | Homebrew | Install/update Homebrew and core dependencies |
| 3 | Restore | Optionally restore from `fc sync` backup |
| 4 | Dotfiles | Deploy dotfiles and shell configuration |
| 5 | Apps | Install applications via `fc apps` and Brewfiles |
| 6 | Configure | Configure git identity, SSH keys, and macOS defaults |
| 7 | Health | Run health checks and generate a bootstrap report |

## Usage

```bash
fc fc-bootstrap [subcommand] [options]
```

### Subcommands

| Subcommand | Description |
|------------|-------------|
| *(none)* | Run interactive bootstrap wizard |
| `status` | Show bootstrap status and completed phases |
| `resume` | Resume a previously interrupted bootstrap |
| `reset` | Clear bootstrap state to start fresh |

### Options

| Option | Description |
|--------|-------------|
| `--role <role>` | Set installation role (developer, personal, work) |
| `--dry-run` | Show what would be done without executing |
| `--skip <phase>` | Skip a specific phase (can be repeated) |
| `--only <phase>` | Run only a specific phase |
| `--no-restore` | Skip restore phase even if backup exists |
| `--force` | Re-run phases even if already completed |
| `--gum` | Use Gum-based TUI (if available) |
| `--help` | Show help message |

## Configuration

Create a configuration file at `~/.config/circus/bootstrap.conf` for customized or unattended setup.

### Creating the Configuration File

```bash
# Copy the template
cp ~/.config/circus/bootstrap.conf.template ~/.config/circus/bootstrap.conf

# Or create from scratch
mkdir -p ~/.config/circus
nano ~/.config/circus/bootstrap.conf
```

### Configuration Options

```bash
# ==============================================================================
# Role Selection
# ==============================================================================

# Installation role: developer, personal, work
BOOTSTRAP_ROLE="developer"

# Privacy profile: standard, privacy, lockdown
BOOTSTRAP_PRIVACY_PROFILE="standard"

# ==============================================================================
# Phase Control
# ==============================================================================

# Skip specific phases (set to true to skip)
SKIP_PHASE_PREFLIGHT=false
SKIP_PHASE_HOMEBREW=false
SKIP_PHASE_RESTORE=false
SKIP_PHASE_DOTFILES=false
SKIP_PHASE_APPS=false
SKIP_PHASE_CONFIGURE=false
SKIP_PHASE_HEALTH=false

# ==============================================================================
# Restore Settings
# ==============================================================================

# Automatically restore from backup if available
AUTO_RESTORE=false

# Remote backup location (for fc sync pull)
RESTORE_REMOTE=""

# ==============================================================================
# Git Configuration
# ==============================================================================

# Pre-configure git identity to skip prompts
GIT_USER_NAME=""
GIT_USER_EMAIL=""

# ==============================================================================
# SSH Configuration
# ==============================================================================

# Automatically generate SSH key if none exists
AUTO_GENERATE_SSH_KEY=true

# Email for SSH key comment
SSH_KEY_EMAIL=""

# ==============================================================================
# Unattended Mode
# ==============================================================================

# Skip all prompts (requires all settings above to be configured)
AUTO_CONFIRM=false

# ==============================================================================
# UI Preferences
# ==============================================================================

# Use Gum-based TUI for richer interactive experience
USE_GUM=false
```

## Examples

### First-Time Setup

```bash
# Start the interactive wizard
fc fc-bootstrap

# Follow the prompts to:
# 1. Select your role (developer, personal, work)
# 2. Choose whether to restore from backup
# 3. Select privacy profile
# 4. Confirm settings and begin
```

### Check Status

```bash
fc fc-bootstrap status
```

Output:
```
╭───────────────────────────── Bootstrap Status ─────────────────────────────╮

  ✓ Preflight Checks       2024-01-15 10:30:00
  ✓ Homebrew Setup         2024-01-15 10:32:15
  ○ Backup Restore         Not completed
  ○ Dotfiles Deployment    Not completed
  ...

╰────────────────────────────────────────────────────────────────────────────╯
```

### Resume After Interruption

```bash
fc fc-bootstrap resume
```

### Skip Specific Phases

```bash
# Skip the restore phase
fc fc-bootstrap --skip restore

# Skip multiple phases
fc fc-bootstrap --skip restore --skip apps
```

### Run Only One Phase

```bash
# Re-run only the configure phase
fc fc-bootstrap --only configure --force
```

### Dry Run

```bash
# See what would happen without making changes
fc fc-bootstrap --dry-run
```

### Unattended Setup

```bash
# Configure bootstrap.conf first, then:
fc fc-bootstrap

# Or for fully automated setup in a script:
AUTO_CONFIRM=true fc fc-bootstrap
```

## Roles

Roles determine which packages and configurations are installed:

| Role | Description |
|------|-------------|
| `developer` | Full development environment with IDEs, SDKs, and dev tools |
| `personal` | Personal productivity setup with media, communication apps |
| `work` | Work/corporate environment with business tools |

## Privacy Profiles

Privacy profiles control security and system settings:

| Profile | Description |
|---------|-------------|
| `standard` | Default macOS settings |
| `privacy` | Enhanced privacy (disable Siri, personalized ads) |
| `lockdown` | Maximum security (firewall, stealth mode) |

## State Management

Bootstrap state is stored in `~/.circus/bootstrap/`:

```
~/.circus/bootstrap/
├── preflight.done    # Timestamp when phase completed
├── homebrew.done
├── restore.done
├── dotfiles.done
├── apps.done
├── configure.done
├── health.done
└── report.txt        # Final bootstrap report
```

### Clearing State

```bash
# Start fresh
fc fc-bootstrap reset
```

## Integration with fc sync

If you have a backup created with `fc sync backup`, the bootstrap process can restore it:

1. Place the backup file at `~/circus_backup.tar.gz.gpg`
2. Or configure `RESTORE_REMOTE` to pull from cloud storage
3. Run bootstrap and select "Yes" when asked about restore

```bash
# Pull backup from remote before bootstrapping
fc fc-sync pull

# Then run bootstrap
fc fc-bootstrap
```

## Troubleshooting

### Phase fails to complete

1. Check the error message
2. Run the phase again with `--force`:
   ```bash
   fc fc-bootstrap --only <phase> --force
   ```

### Homebrew installation fails

Ensure you have:
- Xcode Command Line Tools: `xcode-select --install`
- Internet connectivity

### Restore phase can't find backup

1. Check backup location: `ls ~/circus_backup.tar.gz.gpg`
2. If using remote: verify rclone configuration
3. Or skip: `fc fc-bootstrap --no-restore`

### SSH key generation prompts for passphrase

The configure phase generates SSH keys without a passphrase by default. To add one:
1. Skip auto-generation: Set `AUTO_GENERATE_SSH_KEY=false` in config
2. Generate manually: `fc ssh-keygen`

## Files

| File | Description |
|------|-------------|
| `lib/plugins/fc-bootstrap` | Main orchestration script |
| `lib/bootstrap_phases/*.sh` | Individual phase scripts |
| `lib/templates/bootstrap.conf.template` | Configuration template |
| `~/.config/circus/bootstrap.conf` | User configuration |
| `~/.circus/bootstrap/` | State directory |
