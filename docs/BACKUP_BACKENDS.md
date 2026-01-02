# Backup Backends Guide

The `fc sync` command supports multiple backup backends, allowing you to choose the tool that best fits your needs. Each backend has different strengths and use cases.

## Available Backends

| Backend | Encryption | Deduplication | Remote Support | Best For |
|---------|------------|---------------|----------------|----------|
| **GPG** (default) | GPG encryption | No | Via rclone | Simple, portable archives |
| **Restic** | Built-in AES-256 | Yes | Native (S3, SFTP, etc.) | Incremental backups, cloud storage |
| **Borg** | Built-in AES-256 | Yes | Native (SSH) | Large backups, compression |

## Selecting a Backend

Set `BACKUP_BACKEND` in your configuration file (`~/.config/circus/sync.conf`):

```bash
# Options: "gpg" (default), "restic", "borg"
BACKUP_BACKEND="gpg"
```

## GPG Backend (Default)

The GPG backend uses `tar` to create an archive and `gpg` to encrypt it. This produces a single, portable encrypted file.

### Requirements

- `gpg` (install with: `brew install gpg-suite` or `brew install gnupg`)
- `rsync` (usually pre-installed on macOS)

### Configuration

```bash
BACKUP_BACKEND="gpg"

# Required: Your GPG key ID
# Find with: gpg --list-keys --keyid-format LONG
GPG_RECIPIENT_ID="ABCD1234EFGH5678"

# Optional: Where to save the backup (default: $HOME)
BACKUP_DEST_DIR="$HOME"

# Optional: Backup filename (default: circus_backup.tar.gz.gpg)
BACKUP_ARCHIVE_NAME="circus_backup.tar.gz.gpg"

# What to back up
BACKUP_TARGETS=(
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/Documents"
)
```

### Remote Storage

The GPG backend uses **rclone** for remote storage. Configure a remote with `rclone config`, then:

```bash
RCLONE_REMOTE="gdrive"
RCLONE_REMOTE_PATH="circus-backups"
```

Use these commands for remote operations:
- `fc fc-sync push` - Upload to remote
- `fc fc-sync pull` - Download from remote
- `fc fc-sync list-remote` - List remote backups

### Pros & Cons

**Pros:**
- Simple, single-file output
- Portable (can be decrypted on any system with GPG)
- No additional software beyond GPG

**Cons:**
- No deduplication (full backup every time)
- Can be slow for large datasets
- Requires rclone for remote storage

---

## Restic Backend

Restic provides deduplication, incremental backups, and native cloud storage support. It automatically handles encryption using AES-256.

### Requirements

```bash
brew install restic
```

### Configuration

```bash
BACKUP_BACKEND="restic"

# Required: Repository location
# Local: "/path/to/backup/repo"
# S3: "s3:s3.amazonaws.com/bucket-name"
# SFTP: "sftp:user@host:/path/to/repo"
# REST: "rest:https://user:pass@host/"
RESTIC_REPOSITORY="/path/to/backup/repo"

# Required: Password file (chmod 600)
RESTIC_PASSWORD_FILE="$HOME/.config/circus/restic-password"

# What to back up
BACKUP_TARGETS=(
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/Documents"
)
```

### Initial Setup

1. Create a password file:
   ```bash
   echo 'your-secure-password' > ~/.config/circus/restic-password
   chmod 600 ~/.config/circus/restic-password
   ```

2. Run your first backup (the repository will be initialized automatically):
   ```bash
   fc fc-sync backup
   ```

### Remote Storage

Restic has **native remote support**. Simply set `RESTIC_REPOSITORY` to a remote path:

```bash
# Amazon S3
RESTIC_REPOSITORY="s3:s3.amazonaws.com/my-bucket"
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

# SFTP
RESTIC_REPOSITORY="sftp:user@host:/path/to/repo"

# Backblaze B2
RESTIC_REPOSITORY="b2:bucket-name:path"
export B2_ACCOUNT_ID="your-account-id"
export B2_ACCOUNT_KEY="your-account-key"
```

The `push`, `pull`, and `list-remote` commands will inform you that Restic handles remotes natively.

### Useful Commands

```bash
# List snapshots
restic -r "$RESTIC_REPOSITORY" --password-file ~/.config/circus/restic-password snapshots

# Mount repository (browse backups)
restic -r "$RESTIC_REPOSITORY" --password-file ~/.config/circus/restic-password mount /mnt/backup
```

### Pros & Cons

**Pros:**
- Fast incremental backups with deduplication
- Native support for 20+ cloud providers
- Browseable snapshots
- Automatic pruning and cleanup

**Cons:**
- Slightly more complex setup
- Repository format is restic-specific (not a standard tar)
- Requires restic to be installed for restore

---

## Borg Backend

Borg (BorgBackup) offers excellent deduplication, compression, and SSH-based remote support. It's ideal for large backups where compression matters.

### Requirements

```bash
brew install borgbackup
```

### Configuration

```bash
BACKUP_BACKEND="borg"

# Required: Repository location
# Local: "/path/to/backup/repo"
# SSH: "ssh://user@host/path/to/repo"
# SSH: "user@host:/path/to/repo"
BORG_REPOSITORY="/path/to/backup/repo"

# Required: Passphrase file (chmod 600)
BORG_PASSPHRASE_FILE="$HOME/.config/circus/borg-passphrase"

# Optional: Compression algorithm (default: zstd)
# Options: none, lz4, zstd, zlib, lzma
BORG_COMPRESSION="zstd"

# What to back up
BACKUP_TARGETS=(
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/Documents"
)
```

### Initial Setup

1. Create a passphrase file:
   ```bash
   echo 'your-secure-passphrase' > ~/.config/circus/borg-passphrase
   chmod 600 ~/.config/circus/borg-passphrase
   ```

2. Run your first backup (the repository will be initialized automatically):
   ```bash
   fc fc-sync backup
   ```

3. **Important**: Export your repository key for disaster recovery:
   ```bash
   borg key export $BORG_REPOSITORY ~/.config/circus/borg-key-backup
   ```

### Remote Storage

Borg has **native SSH support**. Set `BORG_REPOSITORY` to an SSH path:

```bash
# SSH format
BORG_REPOSITORY="ssh://user@backup-server.com/path/to/repo"

# Or traditional format
BORG_REPOSITORY="user@backup-server.com:/path/to/repo"
```

Ensure SSH key authentication is set up for the remote server.

### Useful Commands

```bash
# List archives
borg list "$BORG_REPOSITORY"

# Show archive contents
borg list "$BORG_REPOSITORY::archive-name"

# Mount repository (browse backups)
borg mount "$BORG_REPOSITORY" /mnt/backup

# Check repository integrity
borg check "$BORG_REPOSITORY"
```

### Compression Options

| Algorithm | Speed | Ratio | Best For |
|-----------|-------|-------|----------|
| `none` | Fastest | 1:1 | Already compressed data |
| `lz4` | Very fast | Low | Speed priority |
| `zstd` | Fast | Good | General use (default) |
| `zlib` | Medium | Better | Balance |
| `lzma` | Slow | Best | Maximum compression |

### Pros & Cons

**Pros:**
- Excellent compression options
- Fast deduplication
- Native SSH support (no extra setup)
- Automatic archive pruning
- Mountable repository for browsing

**Cons:**
- SSH-only remote support (no native S3, etc.)
- Requires borg to be installed for restore
- Repository key management is critical

---

## Comparison: Which Backend Should I Use?

### Use GPG if:
- You want simple, portable encrypted archives
- You need to restore on systems without specialized software
- Your backups are relatively small
- You're already using rclone for cloud storage

### Use Restic if:
- You have large datasets that benefit from deduplication
- You want native cloud storage support (S3, B2, SFTP, etc.)
- You need fast incremental backups
- You want to browse/mount backup snapshots

### Use Borg if:
- You have large datasets that benefit from compression
- Your remote storage is SSH-accessible
- You want fine-grained compression control
- You prefer a mature, battle-tested solution

---

## Migrating Between Backends

Changing backends means starting a new backup set. Your existing backups remain accessible with the original tool.

1. Update `BACKUP_BACKEND` in your config
2. Configure the new backend's settings
3. Run `fc fc-sync backup` to create your first backup with the new backend

**Tip**: Keep your old backend's configuration commented out in case you need to restore from old backups:

```bash
BACKUP_BACKEND="restic"

# Old GPG settings (kept for reference)
# GPG_RECIPIENT_ID="ABCD1234EFGH5678"

# New Restic settings
RESTIC_REPOSITORY="/path/to/new/repo"
RESTIC_PASSWORD_FILE="$HOME/.config/circus/restic-password"
```
