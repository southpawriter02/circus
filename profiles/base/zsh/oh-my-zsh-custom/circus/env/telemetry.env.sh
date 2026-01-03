# ==============================================================================
# Telemetry Opt-Outs
#
# Disable analytics and telemetry for various CLI tools.
# These settings respect privacy by preventing data collection.
#
# REFERENCES:
#   - https://consoledonottrack.com/
#   - https://github.com/beatcracker/toptout
# ==============================================================================

# --- Universal Opt-Out Signal -------------------------------------------------

# Console Do Not Track - respected by some tools
export DO_NOT_TRACK=1

# --- Package Managers ---------------------------------------------------------

# Homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1

# npm (disable update notifier)
export NO_UPDATE_NOTIFIER=1

# --- .NET Ecosystem -----------------------------------------------------------

export DOTNET_CLI_TELEMETRY_OPTOUT=1

# --- JavaScript Frameworks ----------------------------------------------------

# Next.js
export NEXT_TELEMETRY_DISABLED=1

# Gatsby
export GATSBY_TELEMETRY_DISABLED=1

# Nuxt
export NUXT_TELEMETRY_DISABLED=1

# Astro
export ASTRO_TELEMETRY_DISABLED=1

# Angular CLI
export NG_CLI_ANALYTICS=false

# --- Cloud CLIs ---------------------------------------------------------------

# Microsoft Azure
export AZURE_CORE_COLLECT_TELEMETRY=0

# AWS SAM CLI
export SAM_CLI_TELEMETRY=0

# Google Cloud SDK (gcloud)
# Note: Use `gcloud config set disable_usage_reporting true` for full opt-out

# --- HashiCorp Tools ----------------------------------------------------------

# Terraform, Packer, Consul, Vault, etc.
export CHECKPOINT_DISABLE=1

# --- Other Tools --------------------------------------------------------------

# Hasura
export HASURA_GRAPHQL_ENABLE_TELEMETRY=false

# Netlify
export NETLIFY_TELEMETRY_DISABLED=1

# Stripe CLI
export STRIPE_CLI_TELEMETRY_OPTOUT=1

# Homebrew Cask analytics
export HOMEBREW_NO_ANALYTICS=1

# Kubernetes/kubectl (no telemetry by default, but set anyway)
export KUBECTL_COMMAND_HEADERS=false

# Pulumi
export PULUMI_SKIP_UPDATE_CHECK=true
