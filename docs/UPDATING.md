# Updating the Dotfiles Flying Circus

This guide explains how to keep your Dotfiles Flying Circus installation up-to-date.

## Quick Update

To update to the latest version:

```bash
fc update
```

This command will:
1. Check for and stash any local changes
2. Pull the latest code from the remote repository
3. Run any necessary migration scripts
4. Update dependencies if the Brewfile changed
5. Restore your local changes

## Check for Updates

To see if updates are available without installing them:

```bash
fc update --check
```

This shows:
- Your current version
- The available version
- How many commits behind you are

## Command Options

| Option | Description |
|--------|-------------|
| `--help` | Show help message |
| `--version` | Display the current installed version |
| `--check` | Check for updates without applying them |
| `--dry-run` | Preview what the update would do |
| `--skip-migrations` | Update without running migration scripts |

## Examples

```bash
# Check current version
fc update --version

# See if updates are available
fc update --check

# Preview what an update would do
fc update --dry-run

# Update but skip migrations
fc update --skip-migrations

# Full update
fc update
```

## How Updates Work

### 1. Stashing Local Changes

If you have uncommitted changes, the update process will:
- Warn you about the uncommitted changes
- Ask if you want to stash them
- Stash changes including untracked files
- Restore them after the update completes

### 2. Pulling Latest Code

Updates use `git pull --rebase` to:
- Fetch the latest changes from the remote
- Rebase your local commits on top
- Avoid merge commits in your history

### 3. Running Migrations

When the version changes, the system checks for migration scripts in the `migrations/` directory. Migrations run in order based on version ranges.

Example migration path for upgrading from v1.0.0 to v1.2.0:
1. `v1.0.0_to_v1.1.0.sh` runs first
2. `v1.1.0_to_v1.2.0.sh` runs second

### 4. Updating Dependencies

If the Brewfile for your role changed, the system automatically runs:

```bash
brew bundle install --file=roles/<your-role>/Brewfile
```

## Troubleshooting

### Update Failed Due to Conflicts

If `git pull --rebase` fails:

1. The update will abort
2. Your stashed changes will be restored
3. You'll need to resolve conflicts manually

```bash
# See what's conflicting
git status

# Resolve conflicts in the files listed
# Then continue the rebase
git rebase --continue

# Or abort and try again later
git rebase --abort
```

### Network Issues

If the update can't reach the remote:

```bash
# Check your network connection
ping github.com

# Verify the remote is configured
git remote -v

# Try fetching manually
git fetch origin
```

### Skipping a Problematic Migration

If a migration is causing issues:

```bash
# Update without migrations
fc update --skip-migrations

# Then manually handle the migration issue
```

### Viewing Update History

To see what changed in recent updates:

```bash
# View recent commits
git log --oneline -10

# See the changelog
cat CHANGELOG.md
```

## Version Information

The current version is stored in the `.version` file at the repository root. This file is used for:
- Displaying version information
- Determining which migrations to run
- Tracking update progress

## Rolling Back an Update

If you need to revert to a previous version:

```bash
# See available versions/commits
git log --oneline

# Revert to a specific commit
git checkout <commit-hash>

# Or reset to a specific version tag
git checkout v1.0.0
```

**Note**: Rolling back may leave your configuration in an inconsistent state if migrations have run. Consider the implications before rolling back.
