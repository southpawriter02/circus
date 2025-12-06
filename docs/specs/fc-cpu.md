# Feature Specification: `fc cpu`

## Overview

**Command:** `fc cpu`  
**Purpose:** Monitor CPU usage, view per-core statistics, and track thermal/power state.

### Use Cases
- Quick check of current CPU load
- Identify CPU-intensive processes
- Monitor thermal throttling status
- Check performance vs efficiency core usage (Apple Silicon)

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show overall CPU usage and load average |
| `top` | List top 10 CPU-consuming processes |
| `cores` | Display per-core usage breakdown |
| `temp` | Show CPU temperature (if available) |
| `info` | Display CPU model and specifications |

---

## Detailed Behaviors

### `fc cpu status`

Display CPU summary:

```
$ fc cpu status

CPU Usage:
  Current:     45%
  User:        32%
  System:      13%
  Idle:        55%

Load Average: 2.45 3.12 2.89 (1m, 5m, 15m)
```

**Implementation:**
- Use `top -l 1 -n 0` to get current CPU percentages
- Use `sysctl -n vm.loadavg` for load averages

---

### `fc cpu top`

List top CPU consumers:

```
$ fc cpu top

Top CPU Consumers:
  PID     CPU%    Process
  1234    45.2%   Xcode
  5678    23.1%   Google Chrome Helper
  9012    12.8%   node
  ...
```

**Implementation:**
- Use `ps aux --sort=-%cpu | head -11`
- Parse and format output
- Accept `--count N` for different limits

---

### `fc cpu cores`

Show per-core usage (Apple Silicon aware):

```
$ fc cpu cores

Core Usage:
  P-Core 0:  78%   ████████░░
  P-Core 1:  65%   ███████░░░
  P-Core 2:  45%   █████░░░░░
  P-Core 3:  82%   ████████░░
  E-Core 0:  12%   █░░░░░░░░░
  E-Core 1:  8%    █░░░░░░░░░
  ...
```

**Implementation:**
- Use `powermetrics` (requires sudo) for detailed per-core stats
- Fall back to `top -l 1` aggregate if powermetrics unavailable
- Distinguish P-cores and E-cores on Apple Silicon

---

### `fc cpu temp`

Show CPU temperature:

```
$ fc cpu temp

CPU Temperature: 62°C (143°F)
Status: Normal ✓

Thermal State: Nominal
```

**Implementation:**
- Use `powermetrics --samplers thermal` (requires sudo)
- Or use `osx-cpu-temp` if installed (Homebrew)
- Handle gracefully if temperature unavailable

---

### `fc cpu info`

Display CPU specifications:

```
$ fc cpu info

CPU Information:
  Model:           Apple M1 Pro
  Cores:           10 (8 Performance + 2 Efficiency)
  Architecture:    arm64
  Max Frequency:   3.2 GHz
```

**Implementation:**
- Use `sysctl machdep.cpu.brand_string`
- Use `sysctl hw.ncpu` for core count
- Use `uname -m` for architecture

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `top` | macOS | Yes |
| `ps` | macOS | Yes |
| `sysctl` | macOS | Yes |
| `powermetrics` | macOS | Optional (sudo) |
| `osx-cpu-temp` | Homebrew | Optional |

---

## Implementation Notes

### Apple Silicon Considerations
- Distinguish between Performance (P) and Efficiency (E) cores
- Power metrics differ from Intel architecture
- Some temperature readings may not be available

### Sudo Requirements
- `powermetrics` requires root privileges
- Offer graceful degradation when sudo not available

### Edge Cases
- Handle Intel vs Apple Silicon differences
- VMs may not have temperature sensors
- Load average interpretation differs by core count

---

## Examples

```bash
# Quick CPU check
fc cpu status

# Find CPU hogs
fc cpu top --count 15

# View per-core usage (needs sudo for accuracy)
sudo fc cpu cores

# Check temperature
sudo fc cpu temp

# CPU specifications
fc cpu info
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc cpu --help` displays usage
- `fc cpu status` runs without error
- `fc cpu info` returns valid CPU info
- Unknown subcommand returns error

### Manual Verification
- Verify usage percentages match Activity Monitor
- Test on both Intel and Apple Silicon Macs
- Confirm temperature readings when available
