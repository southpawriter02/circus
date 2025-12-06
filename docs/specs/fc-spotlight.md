# Feature Specification: `fc spotlight`

## Overview

**Command:** `fc spotlight`  
**Purpose:** Control Spotlight indexing and search.

### Use Cases
- Search files via Spotlight from terminal
- Reindex Spotlight database
- Add/remove paths from indexing
- Check indexing status

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `search [query]` | Search using Spotlight |
| `status` | Show indexing status |
| `reindex [path]` | Reindex a path |
| `exclude [path]` | Exclude path from indexing |
| `include [path]` | Include previously excluded path |

---

## Detailed Behaviors

### `fc spotlight search [query]`

Search files:

```
$ fc spotlight search "project report"

Spotlight Results:

  1. ~/Documents/project_report_2024.pdf
  2. ~/Projects/report-generator/README.md
  3. ~/Downloads/project-report.docx
```

**Implementation:**
- Use `mdfind <query>`
- Accept `--type` for file type filtering
- Accept `--count` for limit

---

### `fc spotlight reindex [path]`

Reindex:

```
$ fc spotlight reindex ~/Documents

Reindexing ~/Documents...
This may take a while.

✓ Reindexing started
```

**Implementation:**
- Use `sudo mdutil -E <path>` to erase and rebuild

---

### `fc spotlight exclude [path]`

Exclude from indexing:

```
$ fc spotlight exclude ~/node_modules

Adding ~/node_modules to Spotlight exclusions...
✓ Path will no longer be indexed
```

**Implementation:**
- Add to Privacy list in System Settings
- Requires `defaults` or GUI opening

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `mdfind` | macOS | Yes |
| `mdutil` | macOS | Yes |
| `mdls` | macOS | Yes |

---

## Examples

```bash
# Search
fc spotlight search "budget 2024"

# Check status
fc spotlight status

# Reindex home
sudo fc spotlight reindex ~

# Exclude folder
fc spotlight exclude ~/Library/Caches
```
