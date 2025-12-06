# Feature Specification: `fc disk`

## Overview

**Command:** `fc disk`  
**Purpose:** Analyze disk usage, identify space hogs, and provide cleanup utilities.

### Use Cases
- Quick check of available disk space across all volumes
- Identify large files and directories consuming space
- Clean up common space wasters (caches, logs, Xcode data)
- Monitor disk health via S.M.A.R.T. status

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show disk usage summary for all mounted volumes |
| `usage [path]` | Analyze disk usage for a specific directory (default: home) |
| `large [path]` | Find the 10 largest files in a directory |
| `cleanup` | Interactive cleanup of common space wasters |
| `health` | Display S.M.A.R.T. disk health status |

---

## Detailed Behaviors

### `fc disk status`

Display a summary table of all mounted volumes:

```
Volume              Size      Used      Free      Use%
/                   500GB     350GB     150GB     70%
/Volumes/Backup     2TB       1.5TB     500GB     75%
```

**Implementation:**
- Use `df -h` to get volume information
- Parse and format output as a table
- Highlight volumes with >90% usage in yellow/red

---

### `fc disk usage [path]`

Analyze disk usage by subdirectory (like `du` but prettier):

```
$ fc disk usage ~/Documents
Analyzing /Users/turtle1/Documents...

  4.5 GB  Projects/
  2.1 GB  Archives/
  1.2 GB  Reports/
  ---
  7.8 GB  Total
```

**Implementation:**
- Use `du -sh` on subdirectories
- Sort by size descending
- Show top 10 directories by default
- Accept optional `--all` flag to show all

---

### `fc disk large [path]`

Find the 10 largest files:

```
$ fc disk large ~/Downloads
Finding largest files in /Users/turtle1/Downloads...

  2.5 GB  macOS_Sonoma.dmg
  1.8 GB  Xcode_15.zip
  850 MB  movie_backup.mp4
  ...
```

**Implementation:**
- Use `find . -type f -exec du -h` or GNU `du --files0-from`
- Sort by size, show top 10
- Accept `--count N` flag for different limits

---

### `fc disk cleanup`

Interactive cleanup wizard:

```
$ fc disk cleanup

🧹 Disk Cleanup Wizard

Scanning for cleanable items...

  [1] System Caches         2.3 GB
  [2] User Caches           1.8 GB  
  [3] Homebrew Cache        4.1 GB
  [4] Xcode DerivedData     12.5 GB
  [5] npm Cache             890 MB
  [6] pip Cache             450 MB
  [7] Log Files             1.2 GB
  [8] Trash                 3.4 GB

Enter items to clean (e.g., "1,3,4" or "all"):
```

**Implementation:**
- Check existence and size of each location:
  - `~/Library/Caches/`
  - `/Library/Caches/` (sudo)
  - `$(brew --cache)`
  - `~/Library/Developer/Xcode/DerivedData/`
  - `~/.npm/_cacache/`
  - `~/Library/Caches/pip/`
  - `~/Library/Logs/`
  - `~/.Trash/`
- Only show items that exist and have content
- Require confirmation before deletion
- Use `sudo` only when necessary

---

### `fc disk health`

Show S.M.A.R.T. status for internal drives:

```
$ fc disk health

Disk: disk0 (APPLE SSD AP0512M)
S.M.A.R.T. Status: Verified ✓
Temperature: 35°C
```

**Implementation:**
- Use `diskutil info disk0 | grep SMART`
- Use `smartctl` if available (Homebrew: `smartmontools`)
- Gracefully handle systems without S.M.A.R.T. support

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `df` | macOS | Yes |
| `du` | macOS | Yes |
| `find` | macOS | Yes |
| `diskutil` | macOS | Yes |
| `smartctl` | Homebrew (`smartmontools`) | Optional |

---

## Implementation Notes

### Sudo Requirements
- `cleanup` may require `sudo` for `/Library/Caches/`
- Check permissions before attempting cleanup

### Edge Cases
- Handle external/network volumes gracefully
- Handle permission-denied errors without crashing
- APFS volumes may report space differently (purgeable space)

### macOS APIs Used
- `df` — disk free
- `du` — disk usage  
- `diskutil` — disk info and S.M.A.R.T. status
- `find` — file search
- `osascript` — empty Trash via Finder (optional)

---

## Examples

```bash
# Quick disk space check
fc disk status

# Analyze Documents folder
fc disk usage ~/Documents

# Find biggest files in Downloads
fc disk large ~/Downloads --count 20

# Run cleanup wizard
fc disk cleanup

# Check disk health
fc disk health
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc disk --help` displays usage
- `fc disk status` runs without error
- `fc disk usage` with valid path succeeds
- `fc disk large` with valid path succeeds
- Unknown subcommand returns error

### Manual Verification
- Verify cleanup correctly identifies cache locations
- Confirm S.M.A.R.T. status on supported machines
- Test on systems with multiple volumes
