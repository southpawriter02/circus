# Feature Specification: `fc redis`

## Overview

**Command:** `fc redis`  
**Purpose:** Manage the Redis server using Homebrew services.

### Use Cases
- Start/stop Redis for development
- Quick status checks
- Update Redis to latest version

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `start` | Start Redis in background |
| `stop` | Stop Redis server |
| `restart` | Restart Redis server |
| `status` | Show current Redis status |
| `update` | Update Redis via Homebrew |

---

## Detailed Behaviors

### `fc redis start`

```
$ fc redis start

Starting Redis server...
✓ Redis server started.
```

---

### `fc redis stop`

```
$ fc redis stop

Stopping Redis server...
✓ Redis server stopped.
```

---

### `fc redis status`

```
$ fc redis status

Checking Redis service status...
redis started turtle ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
```

---

### `fc redis update`

```
$ fc redis update

Updating Redis formula...
[Homebrew output]
✓ Redis formula updated.
```

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `brew` | Homebrew | Yes |
| `redis` | Homebrew formula | Yes |

---

## Examples

```bash
# Start Redis for development
fc redis start

# Check if running
fc redis status

# Stop when done
fc redis stop

# Update to latest version
fc redis update
```

---

## Implementation Notes

### Homebrew Services

Uses `brew services` for management:

```bash
brew services start redis
brew services stop redis
brew services restart redis
brew services list | grep redis
```

### Installation

If Redis isn't installed:

```bash
brew install redis
```

---

## Testing Strategy

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Start | `fc redis start` | Redis running |
| Status | `fc redis status` | Shows "started" |
| Stop | `fc redis stop` | Redis stopped |
| Connect | `redis-cli ping` | Returns "PONG" |
