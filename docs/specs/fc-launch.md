# Feature Specification: `fc launch`

## Overview

**Command:** `fc launch`  
**Purpose:** Manage Launch Agents and Launch Daemons (background services).

### Use Cases
- List all user and system launch agents
- Enable/disable services at login
- Start/stop background services
- View service status and logs
- Create custom launch agents

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List all launch agents and daemons |
| `status [name]` | Show status of a service |
| `start [name]` | Start a service |
| `stop [name]` | Stop a service |
| `enable [name]` | Enable a service to run at login |
| `disable [name]` | Disable a service from running at login |
| `logs [name]` | View service logs |

---

## Detailed Behaviors

### `fc launch list`

List all launch agents:

```
$ fc launch list

User Launch Agents (~/Library/LaunchAgents):
  Name                              Status      Enabled
  com.docker.helper                 Running     Yes
  com.microsoft.update.agent        Running     Yes
  homebrew.mxcl.postgresql          Stopped     No

System Launch Agents (/Library/LaunchAgents):
  com.apple.cloudphotod             Running     Yes
  ...

Use --all to include system daemons (requires sudo)
```

**Implementation:**
- Scan `~/Library/LaunchAgents` for user agents
- Scan `/Library/LaunchAgents` for system agents
- Use `launchctl list` to get running status
- Accept `--all` to include `/Library/LaunchDaemons`

---

### `fc launch status [name]`

Show detailed service status:

```
$ fc launch status com.docker.helper

Service: com.docker.helper

  Status:         Running ✓
  PID:            1234
  Enabled:        Yes
  Last Exit:      0 (success)
  
  Plist:          ~/Library/LaunchAgents/com.docker.helper.plist
  Program:        /Applications/Docker.app/Contents/MacOS/Docker Helper
```

**Implementation:**
- Use `launchctl print user/$(id -u)/service` for details
- Parse plist file for program info
- Show last exit status

---

### `fc launch start [name]`

Start a service:

```
$ fc launch start homebrew.mxcl.postgresql

Starting homebrew.mxcl.postgresql...
✓ Service is now running (PID: 5678)
```

**Implementation:**
- Use `launchctl kickstart -k user/$(id -u)/service`
- Or `launchctl load <plist>` for not-yet-loaded services
- Verify service started

---

### `fc launch stop [name]`

Stop a service:

```
$ fc launch stop homebrew.mxcl.postgresql

Stopping homebrew.mxcl.postgresql...
✓ Service has been stopped
```

**Implementation:**
- Use `launchctl stop service`
- Service may restart if KeepAlive is set
- Use disable to prevent restart

---

### `fc launch enable [name]`

Enable service at login:

```
$ fc launch enable homebrew.mxcl.postgresql

Enabling homebrew.mxcl.postgresql...
✓ Service will now start at login
```

**Implementation:**
- Use `launchctl enable user/$(id -u)/service`
- Modify plist RunAtLoad if needed

---

### `fc launch disable [name]`

Disable service at login:

```
$ fc launch disable homebrew.mxcl.postgresql

Disabling homebrew.mxcl.postgresql...
✓ Service will no longer start at login
```

**Implementation:**
- Use `launchctl disable user/$(id -u)/service`
- Optionally stop if running

---

### `fc launch logs [name]`

View service logs:

```
$ fc launch logs com.docker.helper

Recent logs for com.docker.helper:

2024-01-15 10:30:45 Started Docker Helper
2024-01-15 10:30:46 Listening on socket...
...

Use --follow to stream logs
```

**Implementation:**
- Check plist for StandardOutPath/StandardErrorPath
- Use `log show --predicate` for system log entries
- Accept `--follow` for streaming

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `launchctl` | macOS | Yes |
| `plutil` | macOS | Yes |
| `log` | macOS | Yes |

---

## Implementation Notes

### Service Domains
- `user/UID/` - per-user services
- `system/` - system-wide services (needs sudo)
- `gui/UID/` - per-user GUI services

### Common Locations
- `~/Library/LaunchAgents` - User agents
- `/Library/LaunchAgents` - System-wide agents
- `/Library/LaunchDaemons` - System daemons (root)
- `/System/Library/LaunchDaemons` - Apple daemons

### Name Matching
- Support partial name matching
- Support basename without `com.` prefix
- Show multiple matches for selection

### Homebrew Services
- `brew services` creates plist files here
- Format: `homebrew.mxcl.<formula>`

---

## Examples

```bash
# List user agents
fc launch list

# List all including system daemons
sudo fc launch list --all

# Check service status
fc launch status postgresql

# Start a service
fc launch start postgresql

# Stop a service
fc launch stop postgresql

# Disable from starting at login
fc launch disable com.adobe.AdobeCreativeCloud

# View logs
fc launch logs docker --follow
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc launch --help` displays usage
- `fc launch list` runs without error
- Unknown subcommand returns error

### Manual Verification
- Test with actual Homebrew services
- Verify enable/disable affects login behavior
- Test log viewing with known services
- Check behavior with system services (sudo)
