# Feature Specification: `fc memory`

## Overview

**Command:** `fc memory`  
**Purpose:** Monitor system memory usage, identify memory-hungry processes, and provide memory pressure insights.

### Use Cases
- Quick check of current RAM usage
- Find applications using the most memory
- Monitor memory pressure status
- Identify potential memory leaks

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show overall memory usage summary |
| `top` | List top 10 memory-consuming processes |
| `pressure` | Display memory pressure level and swap usage |
| `purge` | Purge disk caches to free memory (requires sudo) |

---

## Detailed Behaviors

### `fc memory status`

Display memory summary:

```
$ fc memory status

Memory Usage:
  Total:      32 GB
  Used:       24.5 GB (77%)
  Free:       2.1 GB
  Cached:     5.4 GB
  Swap Used:  512 MB
```

**Implementation:**
- Parse `vm_stat` output for page statistics
- Calculate percentages and convert pages to GB
- Use `sysctl hw.memsize` for total RAM

---

### `fc memory top`

List top memory consumers:

```
$ fc memory top

Top Memory Consumers:
  PID     Memory    Process
  1234    4.2 GB    Google Chrome
  5678    2.8 GB    Xcode
  9012    1.5 GB    Docker Desktop
  ...
```

**Implementation:**
- Use `ps aux --sort=-%mem | head -11`
- Parse and format output
- Accept `--count N` for different limits

---

### `fc memory pressure`

Show macOS memory pressure indicator:

```
$ fc memory pressure

Memory Pressure: NORMAL ✓

  Level:          Normal (Green)
  Compressed:     1.2 GB
  Swap Used:      0 MB
  Page Outs:      142 (low)
```

**Implementation:**
- Use `memory_pressure` command if available
- Parse `vm_stat` for page out statistics
- Color-code: Green (normal), Yellow (warn), Red (critical)

---

### `fc memory purge`

Purge disk caches:

```
$ fc memory purge

Purging memory caches...
This requires administrator privileges.

Memory before: 24.5 GB used
Memory after:  18.2 GB used

Freed: 6.3 GB
```

**Implementation:**
- Run `sudo purge`
- Capture before/after state
- Note: Only affects file caches, not application memory

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `vm_stat` | macOS | Yes |
| `ps` | macOS | Yes |
| `sysctl` | macOS | Yes |
| `purge` | macOS | Yes |
| `memory_pressure` | macOS | Optional |

---

## Implementation Notes

### Page Size Conversion
- macOS reports memory in pages (typically 4096 bytes)
- Conversion: `bytes = pages * 4096`
- Example: `vm_stat | grep "Pages free" | awk '{print $3 * 4096}'`

### Memory Pressure Levels
- **Normal**: System has plenty of free memory
- **Warn**: Memory is getting low, may start compressing
- **Critical**: Heavy swap usage, system may be sluggish

### Edge Cases
- Handle systems with different page sizes
- Gracefully handle when `memory_pressure` is unavailable
- Warn that `purge` only affects cached memory

---

## Examples

```bash
# Quick memory check
fc memory status

# Find memory hogs
fc memory top --count 20

# Check memory pressure
fc memory pressure

# Free cached memory (requires sudo)
fc memory purge
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc memory --help` displays usage
- `fc memory status` runs without error
- `fc memory top` outputs valid process list
- Unknown subcommand returns error

### Manual Verification
- Verify memory calculations match Activity Monitor
- Test `purge` command actually frees memory
- Confirm pressure level matches Activity Monitor indicator
