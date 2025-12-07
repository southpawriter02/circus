# Feature Specification: `fc update`

## Overview

**Command:** `fc update`  
**Purpose:** Safely update the Dotfiles Flying Circus to the latest version.

### Use Cases
- Keep dotfiles in sync with upstream
- Automatic dependency updates after pull
- Safe handling of local changes

---

## Subcommands

This command has no subcommands. Simply run:

```bash
fc update
```

---

## Detailed Behavior

### Update Flow

```
$ fc update

Checking for local changes...
⚠️ You have uncommitted changes in your local repository.
Would you like to stash them before updating? [y/N] y
Stashing local changes...
✓ Local changes have been stashed.

Pulling the latest version from the remote repository...
✓ Code update successful!

Dependencies for role 'developer' have changed.
Running 'brew bundle' to install/update dependencies...
✓ Dependencies are now up-to-date.

Re-applying your stashed local changes...
✓ Your local changes have been restored.

✓ The Dotfiles Flying Circus is now up-to-date.
```

---

## What It Does

1. **Checks for local changes** - Detects uncommitted modifications
2. **Stashes changes** - Safely saves them before pull
3. **Pulls latest** - Uses `git pull --rebase`
4. **Checks Brewfile changes** - Compares before/after
5. **Updates dependencies** - Runs `brew bundle` if needed
6. **Restores stash** - Re-applies local changes

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `git` | Xcode CLI or Homebrew | Yes |
| `brew` | Homebrew | Yes |

---

## Examples

```bash
# Update to latest version
fc update

# Check what changed
git log --oneline -5
```

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

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Merge conflict | Stops, asks user to resolve |
| No git | Clear error message |
| No brew | Clear error message |
| Pull fails | Restores stash, exits |

---

## Testing Strategy

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Clean update | `fc update` (no local changes) | Pulls latest |
| With changes | Make local edit, `fc update` | Stashes, updates, restores |
| Brewfile change | Modify Brewfile upstream | Runs `brew bundle` |
| No changes | Run when up-to-date | "Already up-to-date" |
