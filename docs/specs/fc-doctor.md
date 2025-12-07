# Feature Specification: `fc doctor`

## Overview

**Command:** `fc doctor`  
**Purpose:** Run diagnostic checks to ensure system health and proper configuration.

### Use Cases
- Verify installation completed successfully
- Troubleshoot issues with the dotfiles setup
- Check for missing dependencies
- Validate Homebrew health

---

## Subcommands

This command has no subcommands. Simply run:

```bash
fc doctor
```

---

## Detailed Behavior

### Running Diagnostics

```
$ fc doctor

Starting system health check...

Checking Homebrew status...
✓ Homebrew is healthy.

Checking for critical tools...
  [✓] Found 'git'
  [✓] Found 'zsh'
  [✓] Found 'op'
  [✓] Found 'shellcheck'
  [✓] Found 'gpg'
✓ All critical tools are installed.

✓ System health check complete.
```

---

## Checks Performed

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| Homebrew health | Runs `brew doctor` | No errors from brew |
| git | Version control | Command available |
| zsh | Shell | Command available |
| op | 1Password CLI | Command available |
| shellcheck | Shell linter | Command available |
| gpg | Encryption | Command available |

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `brew` | Homebrew | Yes |

---

## Examples

```bash
# Run full diagnostics
fc doctor

# Get help
fc doctor --help
```

---

## Implementation Notes

### Graceful Handling of brew doctor

The `brew doctor` command often returns non-zero for warnings. The plugin handles this gracefully:

```bash
set +e  # Temporarily disable exit-on-error
brew_output=$(brew doctor 2>&1)
brew_status=$?
set -e  # Re-enable
```

### Extending Checks

To add new tools to check, edit `tools_to_check` array:

```bash
local tools_to_check=("git" "zsh" "op" "shellcheck" "gpg" "my-tool")
```

---

## Testing Strategy

### Automated Tests

```bash
fc doctor --help    # displays usage
fc doctor           # runs without error (if tools installed)
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| All tools present | Run `fc doctor` | All checks pass |
| Missing tool | Uninstall one tool | Shows [✗] for missing |
| Homebrew issues | Break brew config | Shows warning with details |
