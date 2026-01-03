# ==============================================================================
# Cloud CLI Configuration
#
# Environment variables for cloud provider CLIs (AWS, GCP, Azure).
#
# NOTE: Credentials should NOT be stored here.
# Use `fc fc-secrets` or cloud CLI login commands.
# ==============================================================================

# --- AWS CLI ------------------------------------------------------------------

# Disable paging in AWS CLI (output goes directly to terminal)
export AWS_PAGER=""

# Default output format (json, text, table, yaml)
export AWS_DEFAULT_OUTPUT="json"

# Default region (uncomment and set to your preferred region)
# export AWS_DEFAULT_REGION="us-east-1"

# Use aws-vault for credential management (if installed)
# export AWS_VAULT_BACKEND="keychain"

# --- Google Cloud SDK (gcloud) ------------------------------------------------

# Use Python 3 for gcloud
export CLOUDSDK_PYTHON="python3"

# Disable gcloud update prompts
export CLOUDSDK_CORE_DISABLE_PROMPTS=1

# Application default credentials location
# export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"

# --- Microsoft Azure CLI ------------------------------------------------------

# Default output format (json, table, tsv, yaml, jsonc)
export AZURE_CORE_OUTPUT="table"

# Disable telemetry (also set in telemetry.env.sh)
export AZURE_CORE_COLLECT_TELEMETRY=0

# --- DigitalOcean CLI (doctl) -------------------------------------------------

# Access token from environment (uncomment if needed)
# export DIGITALOCEAN_ACCESS_TOKEN=""

# --- Terraform ----------------------------------------------------------------

# Disable Terraform update checks
export CHECKPOINT_DISABLE=1

# Enable Terraform plugin caching
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

# Create plugin cache directory if it doesn't exist
[[ -d "$TF_PLUGIN_CACHE_DIR" ]] || mkdir -p "$TF_PLUGIN_CACHE_DIR"
