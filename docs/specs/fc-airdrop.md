# Feature Specification: `fc airdrop`

## Overview

**Command:** `fc airdrop`  
**Purpose:** Manage AirDrop visibility settings from the command line.

### Use Cases
- Quickly enable/disable AirDrop for security
- Script AirDrop visibility changes
- Toggle between sharing modes

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `on` | Enable AirDrop for everyone |
| `off` | Disable AirDrop completely |
| `contacts` | Enable AirDrop for contacts only |
| `status` | Show current AirDrop visibility |

---

## Detailed Behaviors

### `fc airdrop on`

Enable for everyone:

```
$ fc airdrop on

Enabling AirDrop for everyone...
✓ AirDrop is now discoverable by everyone.
```

---

### `fc airdrop off`

Disable AirDrop:

```
$ fc airdrop off

Disabling AirDrop...
✓ AirDrop is now off.
```

---

### `fc airdrop contacts`

Contacts only:

```
$ fc airdrop contacts

Enabling AirDrop for contacts only...
✓ AirDrop is now discoverable by contacts only.
```

---

### `fc airdrop status`

Check current setting:

```
$ fc airdrop status

Checking AirDrop status...
✓ AirDrop is currently set to: Everyone
```

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `defaults` | macOS | Yes |

---

## Examples

```bash
# Enable for everyone
fc airdrop on

# Disable (recommended for public spaces)
fc airdrop off

# Allow contacts only
fc airdrop contacts

# Check current setting
fc airdrop status
```

---

## Implementation Notes

### Defaults Domain

Uses `com.apple.sharingd`:

```bash
# Set mode
defaults write com.apple.sharingd DiscoverableMode -string "Everyone"
defaults write com.apple.sharingd DiscoverableMode -string "Off"
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"

# Read mode
defaults read com.apple.sharingd DiscoverableMode
```

### Security Recommendation

For security, keep AirDrop set to "Contacts Only" or "Off" when in public spaces.

---

## Testing Strategy

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Enable all | `fc airdrop on` | AirDrop shows in Finder sidebar |
| Disable | `fc airdrop off` | AirDrop hidden |
| Contacts | `fc airdrop contacts` | Only contacts can see |
| Status | `fc airdrop status` | Shows current mode |
