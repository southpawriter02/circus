# Feature Specification: `fc gpg-setup`

## Overview

**Command:** `fc gpg-setup`  
**Purpose:** Interactive GPG key generation and Git signing configuration.

### Use Cases
- Set up GPG for signed commits on a new machine
- Generate a new GPG key with best practices
- Configure Git to use GPG signing automatically

---

## Subcommands

This command has no subcommands. It's an interactive wizard:

```bash
fc gpg-setup
```

---

## Detailed Behavior

### Interactive Flow

```
$ fc gpg-setup

This utility will guide you through generating a GPG key and configuring Git.

First, let's generate a new GPG key.
You will be prompted for your name, email, and a passphrase.

[GPG key generation prompts appear]

✓ GPG key generated successfully.

Now, let's find the ID of the key you just created.
✓ Found GPG Key ID: ABC123DEF456

Configuring Git to use this key for signing...
✓ Git configuration updated.

Your public GPG key is below. Copy and paste it into your GitHub account.
(Settings -> SSH and GPG keys -> New GPG key)
----------------------------------------------------------------------
-----BEGIN PGP PUBLIC KEY BLOCK-----
[Key content]
-----END PGP PUBLIC KEY BLOCK-----
----------------------------------------------------------------------

✓ Success! Git is now configured to sign your commits with your new GPG key.
```

---

## What It Does

1. **Checks for GPG** - Ensures GPG is installed
2. **Generates key** - Runs `gpg --full-generate-key`
3. **Extracts key ID** - Parses output to find new key
4. **Configures Git** - Sets `user.signingkey` and `commit.gpgsign`
5. **Exports public key** - Displays for copying to GitHub/GitLab

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `gpg` | Homebrew (GPG Suite) | Yes |
| `git` | Xcode CLI or Homebrew | Yes |

---

## Examples

```bash
# Run the setup wizard
fc gpg-setup

# Verify signing works
git commit -m "Test signed commit"
git log --show-signature -1
```

---

## Implementation Notes

### Git Configuration Applied

```bash
git config --global user.signingkey "KEY_ID"
git config --global commit.gpgsign true
```

### Key ID Extraction

```bash
gpg --list-secret-keys --keyid-format LONG | grep 'sec' | tail -n 1 | awk '{print $2}' | cut -d'/' -f2
```

### Where to Add Public Key

- **GitHub**: Settings → SSH and GPG keys → New GPG key
- **GitLab**: Settings → GPG Keys → Add key

---

## Testing Strategy

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Full setup | `fc gpg-setup` | Key generated, Git configured |
| Verify Git | `git log --show-signature` | Shows "Good signature" |
| No GPG | Uninstall GPG, run command | Clear error message |
