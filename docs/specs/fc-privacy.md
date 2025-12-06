# Feature Specification: `fc privacy`

## Overview

**Command:** `fc privacy`  
**Purpose:** View and manage app permissions for Camera, Microphone, Screen Recording, Accessibility, and more.

### Use Cases
- Check which apps have camera/mic access
- View apps with accessibility permissions
- Reset permissions for specific apps
- Audit full disk access grants

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List all privacy permission categories |
| `camera` | Show apps with Camera permission |
| `microphone` | Show apps with Microphone permission |
| `screen` | Show apps with Screen Recording permission |
| `accessibility` | Show apps with Accessibility permission |
| `disk` | Show apps with Full Disk Access |
| `reset [category]` | Reset permissions for a category |

---

## Detailed Behaviors

### `fc privacy list`

List all permission categories:

```
$ fc privacy list

Privacy Permission Categories:

  Category        Apps Granted    Location
  Camera          5              Camera usage
  Microphone      7              Microphone
  Screen Recording 3             Screen capture
  Accessibility   12             Accessibility controls
  Full Disk       4              Full disk access
  Location        8              Location services
  Contacts        2              Address book
  Calendar        3              Calendar access
```

---

### `fc privacy camera`

List apps with Camera permission:

```
$ fc privacy camera

Apps with Camera Permission:

  App                     Bundle ID                   Status
  Zoom                    us.zoom.xos                 Allowed ✓
  Google Chrome           com.google.Chrome           Allowed ✓
  Microsoft Teams         com.microsoft.teams         Allowed ✓
  Skype                   com.skype.skype             Allowed ✓
```

**Implementation:**
- Read from TCC.db (may need Full Disk Access)
- Use `tccutil` for queries where possible
- Parse `/Library/Application Support/com.apple.TCC/TCC.db`

---

### `fc privacy reset [category]`

Reset permissions (requires GUI in modern macOS):

```
$ fc privacy reset camera

⚠️  Resetting Camera permissions will:
    - Revoke access for all apps
    - Apps will prompt again when accessing camera

This may require System Settings to complete.

Opening System Settings → Privacy & Security → Camera...
```

**Implementation:**
- Use `tccutil reset Camera` for older macOS
- Modern macOS requires System Settings
- Open Settings pane with `open x-apple.systempreferences:...`

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `tccutil` | macOS | Yes |
| `sqlite3` | macOS | Optional (database query) |
| `open` | macOS | Yes |

---

## Implementation Notes

### TCC (Transparency, Consent, Control)
- Database: `~/Library/Application Support/com.apple.TCC/TCC.db`
- System DB: `/Library/Application Support/com.apple.TCC/TCC.db`
- Reading requires Full Disk Access permission

### System Integrity Protection (SIP)
- Direct TCC.db modification blocked by SIP
- Use `tccutil` for supported operations
- Open System Settings for unsupported actions

### Service Names
- `kTCCServiceCamera` - Camera
- `kTCCServiceMicrophone` - Microphone
- `kTCCServiceScreenCapture` - Screen Recording
- `kTCCServiceAccessibility` - Accessibility
- `kTCCServiceSystemPolicyAllFiles` - Full Disk

### Modern macOS Limitations
- Many `tccutil` operations no longer work
- Provide commands to open correct System Settings pane
- Document limitations clearly

---

## Examples

```bash
# List categories
fc privacy list

# Check camera permissions
fc privacy camera

# Check which apps can record screen
fc privacy screen

# Reset camera permissions
fc privacy reset camera
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc privacy --help` displays usage
- `fc privacy list` runs without error
- Unknown subcommand returns error

### Manual Verification
- Verify permission lists match System Settings
- Test reset functionality
- Check behavior with/without Full Disk Access
