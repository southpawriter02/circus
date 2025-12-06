# Feature Specification: `fc keychain`

## Overview

**Command:** `fc keychain`  
**Purpose:** Interact with macOS Keychain—list, search, add, and delete passwords/secrets.

### Use Cases
- Find WiFi passwords
- Search for stored credentials
- Add new password entries
- Delete old/unused entries
- Export/import keychain items

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List all keychain items |
| `search [query]` | Search for keychain items |
| `get [name]` | Retrieve a password (with auth) |
| `add` | Add a new password entry |
| `delete [name]` | Delete a keychain item |
| `wifi [ssid]` | Get WiFi network password |

---

## Detailed Behaviors

### `fc keychain list`

List keychain items:

```
$ fc keychain list

Keychain Items (login.keychain-db):

  Kind             Name                    Account
  Internet         github.com              username
  Internet         gitlab.com              token
  Application      Slack                   team-id
  Generic          AWS Credentials         default
  ...

Found 142 items. Use 'fc keychain search' to filter.
```

**Implementation:**
- Use `security dump-keychain` to list (no passwords)
- Parse and format output
- Accept `--kind` to filter by type

---

### `fc keychain search [query]`

Search keychains:

```
$ fc keychain search github

Search results for "github":

  Kind       Name              Account      Keychain
  Internet   github.com        johnsmith    login
  Generic    github-token      personal     login
```

**Implementation:**
- Use `security find-generic-password -l query`
- Search across name, account, and label

---

### `fc keychain get [name]`

Retrieve a password:

```
$ fc keychain get github.com

🔐 Keychain Access Required

Retrieving password for: github.com
Account: johnsmith

[System will prompt for Keychain access]

Password: ghp_xxxxxxxxxxxx (copied to clipboard)
```

**Implementation:**
- Use `security find-generic-password -w` for password
- Triggers macOS Keychain access dialog
- Copy to clipboard with `pbcopy`
- Accept `--show` to display instead of copy

---

### `fc keychain add`

Add new entry (interactive):

```
$ fc keychain add

Add Keychain Entry:

  Name/Label: AWS API Key
  Account: production
  Password: [hidden input]
  
  Kind: [1] Generic  [2] Internet
  Select: 1

✓ Added to login.keychain-db
```

**Implementation:**
- Use `security add-generic-password`
- Or `security add-internet-password` for web
- Prompt for all fields interactively

---

### `fc keychain delete [name]`

Delete an entry:

```
$ fc keychain delete "AWS API Key"

Found keychain entry:
  Name: AWS API Key
  Account: production
  
Delete this entry? [y/N] y

✓ Entry deleted from login.keychain-db
```

**Implementation:**
- Use `security delete-generic-password`
- Require confirmation
- Show entry details before delete

---

### `fc keychain wifi [ssid]`

Get WiFi password:

```
$ fc keychain wifi "Home Network"

🔐 Keychain Access Required

WiFi Network: Home Network

[System will prompt for Keychain access]

Password: MyWiFiPassword123 (copied to clipboard)
```

**Implementation:**
- Use `security find-generic-password -D "AirPort network password" -a SSID -w`
- This is a common use case deserving shortcut

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `security` | macOS | Yes |
| `pbcopy` | macOS | Yes |

---

## Implementation Notes

### Keychain Locations
- `~/Library/Keychains/login.keychain-db` - User keychain
- `/Library/Keychains/System.keychain` - System keychain
- Use `-A` flag for all keychains

### Authentication
- Reading passwords triggers macOS Keychain prompt
- Cannot bypass without user interaction
- "Always Allow" option grants permanent access

### Security Note
- Never log or store retrieved passwords
- Clear clipboard after reasonable time
- Warn about password visibility if using `--show`

---

## Examples

```bash
# List all items
fc keychain list

# Search for an entry
fc keychain search aws

# Get a password (will prompt)
fc keychain get api-token

# Get WiFi password
fc keychain wifi "My Network"

# Add new entry
fc keychain add

# Delete entry
fc keychain delete old-token
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc keychain --help` displays usage
- `fc keychain list` runs without error
- Unknown subcommand returns error

### Manual Verification
- Test password retrieval (requires auth)
- Verify WiFi password retrieval
- Test add/delete operations
