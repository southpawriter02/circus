# Feature Specification: `fc lock`

## Overview

**Command:** `fc lock`  
**Purpose:** Control screen lock, sleep settings, and display timeout.

### Use Cases
- Lock screen immediately
- Set screen saver timeout
- Enable/disable password requirement
- Configure display sleep settings

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `now` | Lock the screen immediately |
| `status` | Show current lock settings |
| `require [on/off]` | Require password after sleep |
| `timeout [seconds]` | Set display sleep timeout |

---

## Detailed Behaviors

### `fc lock now`

Lock screen immediately:

```
$ fc lock now

Locking screen...
```

**Implementation:**
- Use `pmset displaysleepnow`
- Or `osascript -e 'tell app "System Events" to keystroke "q" using {control down, command down}'`
- Requires password on wake if enabled

---

### `fc lock status`

Show lock settings:

```
$ fc lock status

Screen Lock Settings:

  Require Password:      Yes ✓
  Delay After Sleep:     Immediately
  Display Sleep:         10 minutes
  Screen Saver:          5 minutes
```

**Implementation:**
- Read various defaults domains
- Check `com.apple.screensaver`
- Check system power settings

---

### `fc lock require [on/off]`

Configure password requirement:

```
$ fc lock require on

Setting password requirement...

Password will be required immediately after sleep.
✓ Setting applied
```

**Implementation:**
- Use `sysadminctl` or system preferences
- May require admin password

---

### `fc lock timeout [seconds]`

Set display sleep:

```
$ fc lock timeout 300

Setting display sleep to 5 minutes...

✓ Display will sleep after 5 minutes of inactivity
```

**Implementation:**
- Use `pmset -c displaysleep X` (plugged in)
- Use `pmset -b displaysleep X` (battery)
- 0 = never sleep

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `pmset` | macOS | Yes |
| `osascript` | macOS | Yes |
| `defaults` | macOS | Yes |

---

## Examples

```bash
# Lock now
fc lock now

# Check settings
fc lock status

# Require password
fc lock require on

# Set 10 minute timeout
fc lock timeout 600

# Never sleep display
fc lock timeout 0
```

---

## Testing Strategy

### Automated Tests
- `fc lock --help` displays usage
- `fc lock status` runs without error

### Manual Verification
- Test immediate lock
- Verify timeout settings apply
