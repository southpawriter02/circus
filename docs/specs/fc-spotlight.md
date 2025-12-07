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
# Search for files
fc spotlight search "budget 2024"

# Search with type filter
fc spotlight search "report" --type pdf

# Limit results
fc spotlight search "project" --count 5

# Check status
fc spotlight status

# Reindex home (requires sudo)
sudo fc spotlight reindex ~

# Exclude folder from indexing
fc spotlight exclude ~/Library/Caches

# Re-include a folder
fc spotlight include ~/Library/Caches
```

---

## Implementation Notes

### Spotlight Command-Line Tools

macOS provides several command-line tools for interacting with Spotlight:

| Tool | Purpose |
|------|---------|
| `mdfind` | Search the Spotlight index |
| `mdutil` | Manage Spotlight indexing |
| `mdls` | List metadata attributes of a file |
| `mdimport` | Import files into the index |

### Searching with mdfind

```bash
# Basic search
mdfind "search term"

# Search by file type (UTI)
mdfind "kMDItemContentType == 'com.adobe.pdf'"

# Search in specific directory
mdfind -onlyin ~/Documents "report"

# Limit results
mdfind "search term" | head -n 10
```

### Indexing Status

Check indexing status with `mdutil`:

```bash
# Check status of all volumes
mdutil -s /

# Output example:
#   Indexing enabled.
#   Scan base time: 2024-01-15 10:30:00 +0000
```

### Reindexing Requirements

Reindexing requires administrator privileges:

```bash
# Erase and rebuild index (requires sudo)
sudo mdutil -E /path/to/volume

# Turn indexing on
sudo mdutil -i on /

# Turn indexing off
sudo mdutil -i off /
```

> **Note:** Reindexing can take significant time depending on disk size and file count. Warn users before initiating.

### Privacy Exclusions

Spotlight exclusions are stored in System Settings:

**Location:** System Settings → Siri & Spotlight → Spotlight Privacy

Programmatic management options:

1. **AppleScript**: Open System Settings to the privacy pane
2. **Direct plist modification** (not recommended, unsupported)
3. **`.metadata_never_index` file**: Place in a directory to prevent indexing

```bash
# Create never-index marker
touch /path/to/folder/.metadata_never_index
```

### Common File Type Filters

| Filter | UTI / Query |
|--------|-------------|
| PDF files | `kMDItemContentType == 'com.adobe.pdf'` |
| Images | `kMDItemContentTypeTree == 'public.image'` |
| Documents | `kMDItemContentTypeTree == 'public.content'` |
| Source code | `kMDItemContentType == 'public.source-code'` |

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc spotlight --help         # displays usage

# Subcommand validation
fc spotlight unknown        # returns error for unknown subcommand

# Non-destructive operations
fc spotlight status         # runs without error
fc spotlight search "test"  # returns results or empty (no error)
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Search files | Run `fc spotlight search "document"` | Returns list of matching files |
| Type filter | Run `fc spotlight search "report" --type pdf` | Only PDF files returned |
| Count limit | Run `fc spotlight search "file" --count 3` | Max 3 results shown |
| Check status | Run `fc spotlight status` | Shows indexing state for volumes |
| Reindex | Run `sudo fc spotlight reindex ~/Documents` | Reindexing starts (check with `mdutil -s`) |
| Exclude path | Run `fc spotlight exclude ~/test-folder` | Path added to privacy list |
