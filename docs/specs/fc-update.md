# Feature Specification: `fc update`

## Overview

**Command:** `fc update`
**Purpose:** Safely update the Dotfiles Flying Circus to the latest version.

### Use Cases
- Keep dotfiles in sync with upstream
- Automatic dependency updates after pull
- Safe handling of local changes
- Version-based migrations for breaking changes

---

## Options

| Option | Description |
|--------|-------------|
| `--help` | Show help message and exit |
| `--version` | Display the current installed version |
| `--check` | Check for updates without applying them |
| `--dry-run` | Preview what the update would do |
| `--skip-migrations` | Update without running migration scripts |

---

## Examples

```bash
# Check current version
fc update --version

# Check if updates are available
fc update --check

# Preview what an update would do
fc update --dry-run

# Update to latest version
fc update

# Update without running migrations
fc update --skip-migrations
```

---

## Detailed Behavior

### Update Flow

```
$ fc update

[INFO    ] Starting update...
[INFO    ] Checking for local changes...
[WARN    ] You have uncommitted changes in your local repository.
Would you like to stash them before updating? [y/N] y
[INFO    ] Stashing local changes (including untracked files)...
[SUCCESS ] Local changes have been stashed.

[INFO    ] Pulling the latest version from the remote repository...
[SUCCESS ] Code update successful!

[INFO    ] Checking for migrations...
[INFO    ] Running migration: v1.0.0_to_v1.1.0
[SUCCESS ] Migration v1.0.0_to_v1.1.0 completed.

[WARN    ] Dependencies for role 'developer' have changed.
[INFO    ] Running 'brew bundle' to install/update dependencies...
[SUCCESS ] Dependencies are now up-to-date.

[INFO    ] Re-applying your stashed local changes...
[SUCCESS ] Your local changes have been restored.

[SUCCESS ] The Dotfiles Flying Circus has been updated!
  Updated from: v1.0.0 → v1.1.0
```

### Check Mode Flow

```
$ fc update --check

[INFO    ] Checking for updates...
[WARN    ] Updates available!

  Current version: v1.0.0
  Available version: v1.1.0
  Commits behind: 5

[INFO    ] Run 'fc update' to install updates.
```

### Dry-Run Mode Flow

```
$ fc update --dry-run

[INFO    ] [DRY-RUN] Starting update simulation...
[INFO    ] Checking for local changes...
[INFO    ] [DRY-RUN] Would run: git pull --rebase
[INFO    ] Checking for migrations...
[INFO    ] [DRY-RUN] Would run migration: v1.0.0_to_v1.1.0
[INFO    ] [DRY-RUN] Would run: brew bundle install --file=...

[SUCCESS ] [DRY-RUN] Update simulation complete.
  Would update from: v1.0.0 → v1.1.0
```

---

## What It Does

1. **Checks for local changes** - Detects uncommitted modifications
2. **Stashes changes** - Safely saves them before pull
3. **Records old version** - For migration detection
4. **Pulls latest** - Uses `git pull --rebase`
5. **Runs migrations** - Version-based scripts from `migrations/`
6. **Checks Brewfile changes** - Compares before/after
7. **Updates dependencies** - Runs `brew bundle` if needed
8. **Restores stash** - Re-applies local changes
9. **Reports version change** - Shows old → new version

---

## Migration System

Migrations run automatically when the version changes during an update.

### Migration Location

Migration scripts are stored in the `migrations/` directory.

### Naming Convention

```
v<FROM>_to_v<TO>.sh
```

Example: `v1.0.0_to_v1.1.0.sh`

### Migration Selection

When upgrading from v1.0.0 to v1.2.0, the system runs:
1. `v1.0.0_to_v1.1.0.sh` (if exists)
2. `v1.1.0_to_v1.2.0.sh` (if exists)

### Skipping Migrations

Use `--skip-migrations` to update without running migrations:

```bash
fc update --skip-migrations
```

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `git` | Xcode CLI or Homebrew | Yes |
| `brew` | Homebrew | Yes |

---

## Implementation Notes

### Safe Update Process

```bash
# Stash local changes
git stash push --include-untracked

# Rebase on latest
git pull --rebase

# Restore local changes
git stash pop
```

### Dependency Detection

Checks if role-specific Brewfile changed:

```bash
git diff --quiet "$old_head" "$new_head" -- "roles/$role/Brewfile"
```

### Role Detection

Reads current role from `~/.circus/role`.

### Version Tracking

Reads version from `.version` file at repository root.

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Merge conflict | Stops, restores stash, asks user to resolve |
| No git | Clear error message, exits |
| No brew | Clear error message, exits |
| Pull fails | Restores stash, exits with error |
| Migration fails | Reports error, continues with update |
| Network unavailable | Warning message, exits |

---

## Testing Strategy

### Automated Tests (`tests/fc_update.bats`)

| Test Case | Expected Result |
|-----------|-----------------|
| `--help` flag | Shows usage, exits 0 |
| `--version` flag | Shows version, exits 0 |
| `--check` when up-to-date | Shows "up-to-date", exits 0 |
| `--dry-run` | Shows simulation, no changes |
| Unknown option | Error message, exits 1 |

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Clean update | `fc update` (no local changes) | Pulls latest |
| With changes | Make local edit, `fc update` | Stashes, updates, restores |
| Brewfile change | Modify Brewfile upstream | Runs `brew bundle` |
| Version change | Bump `.version` upstream | Shows version change |
| Migration run | Add migration script upstream | Runs migration |
