# Feature Specification: `fc trash`

## Overview

**Command:** `fc trash`  
**Purpose:** Manage the macOS Trash—view contents, empty, restore, or securely delete.

### Use Cases
- Check Trash size before emptying
- Empty Trash from terminal
- Securely delete Trash contents
- List files in Trash
- Restore recently deleted files

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show Trash size and item count |
| `list` | List files in Trash |
| `empty` | Empty the Trash |
| `secure` | Securely empty Trash (overwrite data) |
| `restore [name]` | Restore a file from Trash |
| `put [path]` | Move a file to Trash |

---

## Detailed Behaviors

### `fc trash status`

Show Trash overview:

```
$ fc trash status

Trash Status:
  Items:     47 files, 12 folders
  Size:      3.2 GB
  Oldest:    15 days ago
  
Location: ~/.Trash
```

**Implementation:**
- Use `du -sh ~/.Trash` for size
- Count items with `ls ~/.Trash | wc -l`
- Find oldest file for age

---

### `fc trash list`

List Trash contents:

```
$ fc trash list

Trash Contents:

  Name                         Size      Deleted
  old_project/                 1.2 GB    3 days ago
  photo_backup.zip             850 MB    5 days ago
  document.pdf                 2.1 MB    1 week ago
  ...

47 files, 12 folders (3.2 GB total)
```

**Implementation:**
- List `~/.Trash` contents
- Show modification time as "deleted" date
- Sort by date or size with flags

---

### `fc trash empty`

Empty the Trash:

```
$ fc trash empty

Trash contains 47 items (3.2 GB)

Are you sure you want to permanently delete these files? [y/N] y

Emptying Trash...
✓ Trash has been emptied
```

**Implementation:**
- Use `osascript -e 'tell app "Finder" to empty trash'`
- Or `rm -rf ~/.Trash/*` as fallback
- Require confirmation (bypass with `--yes`)

---

### `fc trash secure`

Securely empty Trash:

```
$ fc trash secure

⚠️  Secure delete will overwrite files before deletion.
    This may take longer and cannot be undone.

Trash contains 47 items (3.2 GB)

Proceed with secure deletion? [y/N] y

Securely deleting...
✓ Trash has been securely emptied
```

**Implementation:**
- Use `srm -rfz ~/.Trash/*` on older macOS
- Note: On APFS/SSD, secure delete less effective
- Warn user about SSD limitations
- Consider using `diskutil secureErase`

---

### `fc trash restore [name]`

Restore a file:

```
$ fc trash restore document.pdf

Restoring document.pdf...

Original location: ~/Documents/document.pdf
Restored successfully ✓
```

**Implementation:**
- Use AppleScript to restore via Finder
- Or move from ~/.Trash back to original path
- Need to track original path (stored in .DS_Store or xattr)

---

### `fc trash put [path]`

Move file to Trash (instead of `rm`):

```
$ fc trash put old_file.txt

Moving old_file.txt to Trash...
✓ File moved to Trash (can be restored)
```

**Implementation:**
- Use `osascript -e 'tell app "Finder" to delete POSIX file "/path"'`
- Or use `trash` CLI if installed (Homebrew)
- Accept multiple files

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `osascript` | macOS | Yes |
| `du` | macOS | Yes |
| `ls` | macOS | Yes |
| `rm` | macOS | Yes |
| `srm` | macOS (older) | Optional |
| `trash` | Homebrew | Optional |

---

## Implementation Notes

### Trash Locations
- User Trash: `~/.Trash`
- Volume Trash: `/Volumes/DriveName/.Trashes/UID`
- Handle external volumes with `--all-volumes`

### Original Path Tracking
- macOS stores original path in extended attributes
- Use `xattr` or `.DS_Store` to retrieve
- May not be available for all files

### Security Considerations
- APFS and SSD wear leveling makes secure erase less reliable
- Document this limitation to users
- Standard empty is usually sufficient

---

## Examples

```bash
# Check trash size
fc trash status

# List trash contents
fc trash list

# Empty trash
fc trash empty

# Empty without confirmation
fc trash empty --yes

# Secure delete
fc trash secure

# Restore a file
fc trash restore important.doc

# Move to trash instead of rm
fc trash put ~/Desktop/old_file.txt

# Move multiple files
fc trash put *.log
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc trash --help` displays usage
- `fc trash status` runs without error
- Unknown subcommand returns error

### Manual Verification
- Test empty with actual files
- Verify restore works
- Test with external volumes
- Check secure delete warnings on APFS
