# Feature Specification: `fc sync`

## Overview

**Command:** `fc sync`  
**Purpose:** Create encrypted backups and restore system state for machine migration.

### Use Cases
- Migrate to a new Mac with all settings and data
- Create secure, encrypted backups of critical files
- Disaster recovery
- Maintain consistent environment across machines

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `backup` | Create encrypted backup archive |
| `restore` | Decrypt and restore from backup |

---

## Detailed Behaviors

### `fc sync backup`

Create an encrypted backup:

```
$ fc sync backup

⚠️  Ready to begin the encrypted backup process.
Continue? [y/N] y

Created temporary backup directory: /tmp/xxx
Creating application inventory...
Backing up critical files...
Creating and encrypting backup archive...
Cleaning up temporary files...
✓ Encrypted backup created at: ~/circus_backup.tar.gz.gpg
```

**What's backed up:**
- `~/.ssh` - SSH keys
- `~/.gnupg` - GPG keys
- `~/Documents` - Documents folder
- `Brewfile.dump` - Installed Homebrew packages

---

### `fc sync restore`

Restore from encrypted backup:

```
$ fc sync restore

⚠️  Ready to restore. This may overwrite existing files.
Continue? [y/N] y

Decrypting backup... (GPG passphrase prompt)
✓ Decryption successful.
Restoring applications from inventory...
Restoring critical files...
✓ System restoration complete.
```

---

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `GPG_RECIPIENT_ID` | Must be set | Your GPG key ID |
| `BACKUP_DEST_DIR` | `$HOME` | Where to save backup |
| `BACKUP_ARCHIVE_NAME` | `circus_backup.tar.gz.gpg` | Archive filename |

### Setting GPG Key ID

Edit `lib/plugins/fc-sync` and set:
```bash
GPG_RECIPIENT_ID="your-gpg-key-id-here"
```

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `gpg` | Homebrew (`gpg-suite`) | Yes |
| `rsync` | macOS | Yes |
| `tar` | macOS | Yes |
| `brew` | Homebrew | Optional (for app inventory) |

---

## Migration Workflow

### On Your OLD Machine

```bash
# 1. Create encrypted backup
fc sync backup

# 2. Copy backup to external drive or cloud
cp ~/circus_backup.tar.gz.gpg /Volumes/ExternalDrive/
```

### On Your NEW Machine

```bash
# 1. Run installer first
./install.sh --role developer

# 2. Copy backup to home folder
cp /Volumes/ExternalDrive/circus_backup.tar.gz.gpg ~/

# 3. Restore everything
fc sync restore
```

---

## Implementation Notes

### GPG Encryption

The backup is encrypted using GPG public-key encryption:
```bash
tar -czf - files | gpg -e -r "$GPG_RECIPIENT_ID" -o backup.tar.gz.gpg
```

### Decryption

```bash
gpg -d backup.tar.gz.gpg | tar -xzf - -C /tmp/restore
```

### Customizing Backup Targets

Edit `BACKUP_TARGETS` array in the plugin:
```bash
readonly BACKUP_TARGETS=(
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/Documents"
  # Add more paths here
)
```

---

## Testing Strategy

### Automated Tests

Difficult to test without GPG keys configured. Focus on:
- Dependency checks (gpg, rsync)
- Error handling for missing backup file

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Backup | `fc sync backup` | Creates encrypted archive |
| Restore | `fc sync restore` | Restores files from archive |
| Missing GPG | Unset GPG_RECIPIENT_ID | Clear error message |
| Missing archive | Delete archive, run restore | "not found" error |
