# Feature Specification: `fc backup`

## Overview

**Command:** `fc backup`  
**Purpose:** Create timestamped backups of essential dotfiles to iCloud or a local directory.

### Use Cases
- Quick backup before making configuration changes
- Sync dotfiles across machines via iCloud
- Disaster recovery for shell configuration

---

## Subcommands

This command has no subcommands. Simply run:

```bash
fc backup
```

---

## Detailed Behavior

### Sample Output

```
$ fc backup

Starting dotfiles backup...
Backup destination: ~/Library/Mobile Documents/com~apple~CloudDocs/Backups/dotfiles-backup-2024-01-15-143052

  -> Backing up '.zshrc'...
  -> Backing up '.gitconfig'...
  -> Backing up '.gnupg'...
  -> Skipping '.zpreztorc' (does not exist).

Backup complete!
Items backed up: 3
Items skipped: 1
```

---

## What Gets Backed Up

| Item | Description |
|------|-------------|
| `.zshrc` | Zsh configuration |
| `.zpreztorc` | Prezto configuration (if exists) |
| `.gitconfig` | Git configuration |
| `.gnupg` | GPG keys directory |

---

## Configuration

Edit the plugin to customize:

```bash
# Backup location
BACKUP_LOCATION_BASE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups"

# Files to back up
DOTFILES_TO_BACKUP=(
  ".zshrc"
  ".zpreztorc"
  ".gitconfig"
  ".gnupg"
)
```

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `rsync` | macOS | Yes |

---

## Implementation Notes

- Creates timestamped directory: `dotfiles-backup-YYYY-MM-DD-HHMMSS`
- Uses `rsync -a` for reliable copying
- Skips missing files gracefully
- Default location: iCloud Drive Backups folder

---

## Testing Strategy

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Backup | `fc backup` | Creates timestamped backup |
| iCloud sync | Check iCloud folder | Backup appears |
| Missing file | Remove a dotfile temporarily | Shows "Skipping" message |
