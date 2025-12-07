# Feature Specification: `fc cron`

## Overview

**Command:** `fc cron`  
**Purpose:** Simplified cron/launchd job management for scheduled tasks.

### Use Cases
- Schedule recurring scripts
- List scheduled jobs
- Enable/disable jobs
- View job logs

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List scheduled jobs |
| `add` | Create a new scheduled job |
| `remove [name]` | Remove a scheduled job |
| `run [name]` | Run a job manually |
| `logs [name]` | View job output logs |

---

## Detailed Behaviors

### `fc cron list`

List jobs:

```
$ fc cron list

Scheduled Jobs (fc-managed):

  Name           Schedule              Next Run       Status
  backup-daily   Every day at 2:00am   Tomorrow       Active
  sync-logs      Every hour            12:00          Active
```

---

### `fc cron add`

Create job interactively:

```
$ fc cron add

Create Scheduled Job:

  Name: backup-daily
  Command: /path/to/backup.sh
  
  Schedule:
    [1] Every hour
    [2] Daily at specific time
    [3] Weekly
    [4] Custom (cron expression)
  Select: 2
  
  Time (HH:MM): 02:00

✓ Job created: ~/Library/LaunchAgents/com.circus.backup-daily.plist
```

**Implementation:**
- Generate launchd plist
- Use `launchctl load` to enable

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `launchctl` | macOS | Yes |
| `plutil` | macOS | Yes |

---

## Examples

```bash
# List all fc-managed jobs
fc cron list

# Add new job interactively
fc cron add

# Add job with arguments
fc cron add --name "cleanup" --command "/path/to/cleanup.sh" --daily "03:00"

# Run a job immediately
fc cron run backup-daily

# View job output
fc cron logs backup-daily

# Remove a job
fc cron remove backup-daily
```

---

## Implementation Notes

### launchd vs cron

macOS uses `launchd` as the preferred job scheduler, not traditional Unix `cron`. While `cron` is available, `launchd` provides:

- Better integration with macOS power management
- Run-on-wake behavior for missed schedules
- Structured logging
- Resource controls

### Job Location

fc-managed jobs are stored as user LaunchAgents:

```
~/Library/LaunchAgents/com.circus.<job-name>.plist
```

### Plist Structure

Each job is a property list (plist) file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.circus.backup-daily</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/path/to/backup.sh</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>StandardOutPath</key>
    <string>/tmp/com.circus.backup-daily.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/com.circus.backup-daily.error.log</string>
</dict>
</plist>
```

### Schedule Formats

| Schedule Type | Plist Key | Example |
|---------------|-----------|---------|
| Hourly | `StartCalendarInterval` | `<key>Minute</key><integer>0</integer>` |
| Daily | `StartCalendarInterval` | Hour + Minute |
| Weekly | `StartCalendarInterval` | Weekday + Hour + Minute |
| Interval | `StartInterval` | Seconds between runs |

### launchctl Commands

```bash
# Load a job (enable)
launchctl load ~/Library/LaunchAgents/com.circus.job-name.plist

# Unload a job (disable)
launchctl unload ~/Library/LaunchAgents/com.circus.job-name.plist

# Start immediately
launchctl start com.circus.job-name

# List loaded jobs
launchctl list | grep circus
```

### Log Locations

Job output is captured to:

- **stdout**: `/tmp/com.circus.<job-name>.log`
- **stderr**: `/tmp/com.circus.<job-name>.error.log`

### Naming Conventions

- Job names should be lowercase, alphanumeric with hyphens
- Labels use reverse-DNS: `com.circus.<job-name>`
- Avoid special characters in job names

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc cron --help              # displays usage

# Subcommand validation
fc cron unknown             # returns error for unknown subcommand

# Non-destructive operations
fc cron list                # runs without error (may show empty)
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| List jobs | Run `fc cron list` | Shows fc-managed jobs or empty message |
| Add job | Run `fc cron add`, provide name/command/schedule | Plist created in LaunchAgents, job loaded |
| Run job | Create test job, run `fc cron run <name>` | Job executes immediately |
| View logs | After job runs, `fc cron logs <name>` | Shows stdout/stderr output |
| Remove job | Run `fc cron remove <name>` | Job unloaded, plist deleted |

### Edge Cases

- Job with same name already exists
- Invalid schedule format
- Non-existent job for run/remove/logs
- Script path doesn't exist
- Special characters in job name
