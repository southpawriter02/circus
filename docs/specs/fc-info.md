# Feature Specification: `fc info`

## Overview

**Command:** `fc info`  
**Purpose:** Display a summary of system hardware and software configuration.

### Use Cases
- Quick system information lookup
- Verify macOS version and hardware specs
- Documentation and support requests
- New machine inventory

---

## Subcommands

This command has no subcommands. Simply run:

```bash
fc info
```

---

## Detailed Behavior

### Sample Output

```
$ fc info

Gathering system information...

Software:
  OS Version:   macOS 14.0 (23A344)
  Hostname:     my-macbook
  Uptime:       3 days

Hardware:
  Model:        MacBookPro18,3
  CPU:          Apple M1 Pro
  Memory:       16 GB

✓ System information gathering complete.
```

---

## Information Displayed

### Software

| Field | Description |
|-------|-------------|
| OS Version | macOS version, name, and build number |
| Hostname | Computer's network name |
| Uptime | How long since last restart |

### Hardware

| Field | Description |
|-------|-------------|
| Model | Mac hardware model identifier |
| CPU | Processor name/type |
| Memory | Total RAM in GB |

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `sw_vers` | macOS | Yes |
| `sysctl` | macOS | Yes |
| `hostname` | macOS | Yes |
| `uptime` | macOS | Yes |

---

## Examples

```bash
# Display system info
fc info

# Get help
fc info --help
```

---

## Implementation Notes

### Cross-Platform Support

The plugin includes Linux fallbacks:
- Uses `/etc/os-release` for OS version
- Uses `lscpu` and `/proc/meminfo` for hardware

### Commands Used

```bash
# macOS version
sw_vers -productName
sw_vers -productVersion
sw_vers -buildVersion

# Hardware info
sysctl -n hw.model
sysctl -n machdep.cpu.brand_string
sysctl -n hw.memsize
```

---

## Testing Strategy

### Automated Tests

```bash
fc info --help    # displays usage
fc info           # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Display info | `fc info` | Shows OS, hostname, uptime, hardware |
| Correct values | Compare with System Information app | Values match |
