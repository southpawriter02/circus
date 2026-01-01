# Migration Scripts

This directory contains migration scripts that run automatically during updates when the version changes.

## How Migrations Work

When you run `fc update`, the system:

1. Records the current version before updating
2. Pulls the latest code
3. Reads the new version
4. Runs any migration scripts that apply to the version range

## Naming Convention

Migration scripts must follow this naming pattern:

```
v<FROM_VERSION>_to_v<TO_VERSION>.sh
```

Examples:
- `v1.0.0_to_v1.1.0.sh` - Runs when upgrading from 1.0.0 to 1.1.0
- `v1.1.0_to_v2.0.0.sh` - Runs when upgrading from 1.1.0 to 2.0.0

## Writing a Migration Script

```bash
#!/usr/bin/env bash

# Migration: v1.0.0 → v1.1.0
# Description: Brief description of what this migration does

# Source init.sh for helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../lib/init.sh"

# Perform migration
msg_info "Migrating configuration..."

# Example: Rename a config file
if [ -f "$HOME/.old-config" ]; then
  mv "$HOME/.old-config" "$HOME/.new-config"
  msg_success "Renamed .old-config to .new-config"
fi

# Example: Remove deprecated file
if [ -f "$HOME/.deprecated-file" ]; then
  rm "$HOME/.deprecated-file"
  msg_success "Removed deprecated file"
fi

# Return 0 for success, non-zero for failure
exit 0
```

## Best Practices

1. **Idempotent**: Migrations should be safe to run multiple times
2. **Check before acting**: Always verify a file/setting exists before modifying
3. **Log actions**: Use `msg_info`, `msg_success`, `msg_warning` for visibility
4. **Handle errors gracefully**: Don't fail silently; report issues clearly
5. **Keep it simple**: One migration, one purpose

## Skipping Migrations

Users can skip migrations during update:

```bash
fc update --skip-migrations
```

## Testing Migrations

Test your migration script locally before committing:

```bash
# Source the migration directly
source migrations/v1.0.0_to_v1.1.0.sh
```
