# Secrets Management

The `fc secrets` command provides unified secrets management across multiple backends: 1Password CLI, macOS Keychain, and HashiCorp Vault.

## Quick Start

```bash
# Initial setup - creates config file and checks prerequisites
fc fc-secrets setup

# Edit the configuration file
$EDITOR ~/.config/circus/secrets.conf

# Sync all configured secrets to their destinations
fc fc-secrets sync

# Fetch a single secret (prints to stdout)
fc fc-secrets get op://Personal/github/token
```

## Backends

### 1Password CLI (`op://`)

Uses the official 1Password CLI (`op`) to fetch secrets.

**Prerequisites:**
- Install 1Password CLI: `brew install 1password-cli`
- Sign in: `op signin`

**URI Format:**
```
op://vault/item/field
op://vault/item/section/field
```

**Examples:**
```bash
fc fc-secrets get op://Personal/github.com/token
fc fc-secrets get op://Work/AWS/access_key_id
```

### macOS Keychain (`keychain://`)

Uses the built-in macOS Keychain via the `security` command.

**Prerequisites:**
- macOS (built-in)
- No authentication required (per-item prompts may appear)

**URI Format:**
```
keychain://service/account
```

**Examples:**
```bash
fc fc-secrets get keychain://api-service/production
fc fc-secrets get keychain://database/myapp
```

### HashiCorp Vault (`vault://`)

Uses the HashiCorp Vault CLI to fetch secrets.

**Prerequisites:**
- Install Vault CLI: `brew install vault`
- Set VAULT_ADDR in config or environment
- Authenticate with `vault login`

**URI Format:**
```
vault://path/to/secret#field
```

**Examples:**
```bash
fc fc-secrets get vault://secret/data/myapp#api_key
fc fc-secrets get vault://secret/data/database#password
```

## Configuration

Configuration file: `~/.config/circus/secrets.conf`

### Format

Each line defines a secret to sync:
```bash
"<backend-uri>" "<destination>" [permissions]
```

**Destination types:**
- `env:VAR_NAME` - Write to environment file (`~/.zshenv.local`)
- `/path/to/file` - Write to file with optional permissions

### Example Configuration

```bash
# Secrets Configuration for fc-secrets
# Format: "<backend>://<path>" "<destination>" [permissions]

# --- 1Password Secrets ---
"op://Personal/github.com/token"           "env:GITHUB_TOKEN"
"op://Work/aws/access_key_id"              "env:AWS_ACCESS_KEY_ID"
"op://Work/aws/secret_access_key"          "env:AWS_SECRET_ACCESS_KEY"
"op://Work/database/connection_string"     "~/.config/myapp/db.conf" "600"

# --- macOS Keychain ---
"keychain://api-service/production"        "env:API_KEY"
"keychain://signing-cert/developer"        "~/.config/certs/dev.pem" "600"

# --- HashiCorp Vault ---
# Set VAULT_ADDR if not using default
VAULT_ADDR="https://vault.example.com:8200"

"vault://secret/data/myapp#api_key"        "env:MYAPP_API_KEY"
"vault://secret/data/certs#tls_cert"       "~/.config/app/tls.crt" "644"
"vault://secret/data/certs#tls_key"        "~/.config/app/tls.key" "600"
```

## Subcommands

### `setup`

Creates the configuration file and checks backend prerequisites.

```bash
fc fc-secrets setup
```

### `sync`

Syncs all configured secrets to their destinations.

```bash
fc fc-secrets sync
```

Environment variables are written to `~/.zshenv.local` in a managed section:
```bash
# User's existing content...

# --- fc-secrets managed (DO NOT EDIT BELOW) ---
export GITHUB_TOKEN="ghp_xxxxx"
export AWS_ACCESS_KEY_ID="AKIA..."
# --- fc-secrets end ---
```

### `get <uri>`

Fetches a single secret and prints to stdout.

```bash
fc fc-secrets get op://Personal/github/token
fc fc-secrets get keychain://api-service/key
fc fc-secrets get vault://secret/data/app#field
```

Use this for scripting or piping:
```bash
# Use in a script
API_KEY=$(fc fc-secrets get op://Work/api/key)

# Pipe to clipboard
fc fc-secrets get op://Personal/password | pbcopy
```

### `list`

Lists all configured secrets and their destinations.

```bash
fc fc-secrets list
```

### `status`

Shows authentication status for each backend.

```bash
fc fc-secrets status
```

### `verify`

Verifies all configured secrets are accessible (dry-run).

```bash
fc fc-secrets verify
```

## Environment File Management

When using `env:` destinations, secrets are written to `~/.zshenv.local` with managed section markers. This allows `fc fc-secrets sync` to update secrets without affecting your other environment variables.

To load the secrets in your shell, add to your `.zshrc`:
```bash
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
```

## Security Considerations

1. **Config file permissions**: The configuration file is created with `600` permissions (owner read/write only).

2. **Secret files**: Files are created with `600` permissions by default. Specify different permissions if needed:
   ```bash
   "op://certs/tls" "~/.config/tls.crt" "644"
   ```

3. **Never log secrets**: The command never prints secret values (except `get` which outputs to stdout for piping).

4. **Environment variables**: When using `env:` destinations, the environment file is also set to `600` permissions.

## Troubleshooting

### 1Password

**"op is not installed"**
```bash
brew install 1password-cli
```

**"Not authenticated"**
```bash
op signin
```

### macOS Keychain

**"Item not found"**
- Verify the service and account names match what's stored in Keychain Access
- Check both login and system keychains

### HashiCorp Vault

**"vault is not installed"**
```bash
brew install vault
```

**"Not authenticated"**
```bash
export VAULT_ADDR=https://vault.example.com:8200
vault login
```

**"Permission denied"**
- Verify your Vault token has read access to the path
- Check the Vault ACL policies

## Integration with Other Commands

### Bootstrap

During `fc bootstrap`, you can configure automatic secret sync:
```bash
# In bootstrap.conf
AUTO_SYNC_SECRETS=true
```

### Scheduled Sync

Combine with `fc schedule` to periodically refresh secrets:
```bash
# Create a custom launchd job for secret sync
```

## Backend Help

Get backend-specific help:
```bash
fc fc-secrets get --help op
fc fc-secrets get --help keychain
fc fc-secrets get --help vault
```
