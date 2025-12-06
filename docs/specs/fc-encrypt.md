# Feature Specification: `fc encrypt`

## Overview

**Command:** `fc encrypt`  
**Purpose:** Quick file/folder encryption using GPG or built-in macOS tools.

### Use Cases
- Encrypt sensitive files before sharing
- Decrypt received encrypted files
- Create encrypted archives
- Encrypt text directly from command line

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `file [path]` | Encrypt a file with password |
| `decrypt [path]` | Decrypt an encrypted file |
| `folder [path]` | Encrypt a folder as archive |
| `text` | Encrypt text from stdin |

---

## Detailed Behaviors

### `fc encrypt file [path]`

Encrypt a file:

```
$ fc encrypt file secrets.txt

Encrypting secrets.txt...

Enter password: ********
Confirm password: ********

✓ Created: secrets.txt.gpg

Original file: secrets.txt
Delete original? [y/N] y

✓ Original deleted
```

**Implementation:**
- Use `gpg --symmetric` for password-based
- Default to AES-256 cipher
- Accept `--keep` to preserve original

---

### `fc encrypt decrypt [path]`

Decrypt a file:

```
$ fc encrypt decrypt secrets.txt.gpg

Decrypting secrets.txt.gpg...

Enter password: ********

✓ Created: secrets.txt
```

**Implementation:**
- Use `gpg --decrypt` 
- Auto-detect file type (.gpg, .asc)
- Handle both symmetric and key-based

---

### `fc encrypt folder [path]`

Encrypt entire folder:

```
$ fc encrypt folder ~/Documents/secrets/

Creating encrypted archive...

Enter password: ********
Confirm password: ********

✓ Created: secrets.tar.gz.gpg (15.2 MB)

Delete original folder? [y/N] n
Original folder preserved.
```

**Implementation:**
- Create tar.gz first, then encrypt
- Use `tar czf - folder | gpg -c > archive.tar.gz.gpg`

---

### `fc encrypt text`

Encrypt text from stdin or prompt:

```
$ fc encrypt text

Enter text to encrypt (Ctrl+D when done):
API_KEY=sk_live_xxxxxxxxxxxxx
^D

Enter password: ********

Encrypted output (base64):
-----BEGIN PGP MESSAGE-----
jA0ECQMCxxxxxxxxx...
-----END PGP MESSAGE-----

Copied to clipboard ✓
```

**Implementation:**
- Accept piped input or interactive
- Output as armored (ASCII) by default
- Copy to clipboard

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `gpg` | Homebrew | Yes |
| `tar` | macOS | Yes |
| `pbcopy` | macOS | Yes |

---

## Implementation Notes

### Cipher Selection
- Default: AES-256 (very secure)
- Use `--cipher-algo AES256` explicitly

### File Naming
- Encrypted: `original.ext.gpg`
- Decrypted: Strip `.gpg` suffix

### Key-Based Encryption
- Support `--recipient` for GPG key encryption
- Falls back to symmetric if no key

### OpenSSL Alternative
- Offer `openssl enc` as fallback if GPG unavailable
- Command: `openssl enc -aes-256-cbc -salt -in file -out file.enc`

---

## Examples

```bash
# Encrypt a file
fc encrypt file passwords.txt

# Decrypt
fc encrypt decrypt passwords.txt.gpg

# Encrypt and delete original
fc encrypt file secrets.json --delete

# Encrypt folder
fc encrypt folder ~/private/

# Encrypt from pipe
echo "secret data" | fc encrypt text

# Interactive text encryption
fc encrypt text
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc encrypt --help` displays usage
- Command requires gpg presence
- Unknown subcommand returns error

### Manual Verification
- Test encrypt/decrypt cycle
- Verify password requirement
- Test folder encryption
