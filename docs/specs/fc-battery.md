# Feature Specification: `fc battery`

## Overview

**Command:** `fc battery`  
**Purpose:** Monitor battery health, charge status, cycle count, and power source information.

### Use Cases
- Quick check of battery percentage and time remaining
- Monitor battery health and degradation
- View cycle count for warranty/replacement planning
- Check power adapter status and wattage

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show current charge level and time remaining |
| `health` | Display battery health, capacity, and cycle count |
| `history` | Show recent battery level history |
| `adapter` | Display power adapter information |

---

## Detailed Behaviors

### `fc battery status`

Display current battery state:

```
$ fc battery status

Battery Status:
  Level:         78%
  State:         Discharging
  Time Left:     4:32

Power Source: Battery
```

**Implementation:**
- Use `pmset -g batt` for battery percentage and state
- Parse time remaining from output
- Show "Calculating..." if time not yet determined

---

### `fc battery health`

Display battery health details:

```
$ fc battery health

Battery Health:
  Condition:       Normal ✓
  Maximum Capacity: 94%
  Cycle Count:     287

Design Capacity:  5100 mAh
Current Capacity: 4794 mAh
```

**Implementation:**
- Use `system_profiler SPPowerDataType` for detailed info
- Or use `ioreg -l | grep -i capacity`
- Calculate percentage from design vs current capacity

---

### `fc battery history`

Show recent battery drain/charge history:

```
$ fc battery history

Battery History (last 24h):
  Time        Level   State
  16:30       78%     Discharging
  14:00       95%     Charging
  12:45       40%     Discharging
  09:00       100%    Fully Charged
```

**Implementation:**
- Use `pmset -g log | grep -i battery` for recent events
- Parse and format last 10-20 entries
- Group by charge/discharge cycles if possible

---

### `fc battery adapter`

Display power adapter information:

```
$ fc battery adapter

Power Adapter:
  Connected:      Yes ✓
  Wattage:        96W
  Manufacturer:   Apple Inc.
  Charging:       Yes (78% → full in ~1:15)
```

**Implementation:**
- Use `system_profiler SPPowerDataType` for adapter info
- Use `ioreg -l | grep -i adapter` as fallback
- Show "Not Connected" if on battery only

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `pmset` | macOS | Yes |
| `system_profiler` | macOS | Yes |
| `ioreg` | macOS | Yes |

---

## Implementation Notes

### Desktop Macs
- Gracefully handle systems without batteries (iMac, Mac Mini, Mac Pro)
- Show "No battery detected" instead of error

### Battery Condition Values
- **Normal**: Battery is functioning normally
- **Service Recommended**: Consider replacement
- **Service Battery**: Battery needs immediate attention

### Edge Cases
- Handle new batteries with "Calibrating..." status
- Show "Not Charging" state (when plugged in but battery full)
- Handle optimized battery charging feature

---

## Examples

```bash
# Quick battery check
fc battery status

# Detailed health info
fc battery health

# View charge/discharge history
fc battery history

# Power adapter info
fc battery adapter
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc battery --help` displays usage
- `fc battery status` runs without error
- Gracefully handles desktop Macs (no battery)
- Unknown subcommand returns error

### Manual Verification
- Verify percentage matches menu bar
- Compare cycle count with System Information
- Test on both plugged-in and battery states
- Test on desktop Mac for graceful degredation
