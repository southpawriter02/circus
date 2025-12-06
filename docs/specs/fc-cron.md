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
# List jobs
fc cron list

# Add new job
fc cron add

# Run manually
fc cron run backup-daily

# View logs
fc cron logs backup-daily
```
