# Feature Specification: `fc ssh-keygen`

## Overview

**Command:** `fc ssh-keygen`  
**Purpose:** Streamlined SSH key generation with automatic agent registration and clipboard copy.

### Use Cases
- Set up SSH for GitHub/GitLab on a new machine
- Generate secure ed25519 keys
- Quick key creation with best practices

---

## Subcommands

This command has no subcommands. It's an interactive wizard:

```bash
fc ssh-keygen
```

---

## Detailed Behavior

### Interactive Flow

```
$ fc ssh-keygen

Please enter the email address to associate with your new SSH key:
> user@example.com

Generating a new ed25519 SSH key at ~/.ssh/id_ed25519...
[SSH key generation output]

✓ SSH key generated successfully.

Starting ssh-agent...
Adding SSH key to the ssh-agent and storing passphrase in Keychain...

Copying public key to clipboard...

✓ Success! Your new public SSH key has been copied to the clipboard.
You can now paste it into GitHub, GitLab, or any other service.
```

---

## What It Does

1. **Prompts for email** - Used as key comment
2. **Checks for existing key** - Asks before overwriting
3. **Generates ed25519 key** - Modern, secure algorithm
4. **Starts ssh-agent** - If not running
5. **Adds to Keychain** - `--apple-use-keychain` flag
6. **Copies public key** - Ready to paste

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `ssh-keygen` | macOS | Yes |
| `ssh-add` | macOS | Yes |
| `pbcopy` | macOS | Yes |

---

## Examples

```bash
# Generate new SSH key
fc ssh-keygen

# Verify key was created
ls -la ~/.ssh/id_ed25519*

# Test GitHub connection
ssh -T git@github.com
```

---

## Implementation Notes

### Key Generation

Uses ed25519 (modern, secure):

```bash
ssh-keygen -t ed25519 -C "email@example.com" -f ~/.ssh/id_ed25519
```

### Keychain Integration

Stores passphrase in macOS Keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Where to Add Public Key

- **GitHub**: Settings → SSH and GPG keys → New SSH key
- **GitLab**: Preferences → SSH Keys → Add key
- **Bitbucket**: Personal settings → SSH keys → Add key

---

## Testing Strategy

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Generate | `fc ssh-keygen` | Key created, copied to clipboard |
| GitHub | Paste key, `ssh -T git@github.com` | "Hi username!" message |
| Overwrite | Run twice | Prompts for confirmation |
