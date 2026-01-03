# ==============================================================================
# Kubernetes Configuration
#
# Environment variables for Kubernetes and related tools.
# ==============================================================================

# --- kubectl Configuration ----------------------------------------------------

# Default kubeconfig location
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# Editor for kubectl edit
export KUBE_EDITOR="${KUBE_EDITOR:-$EDITOR}"

# Disable kubectl command headers in output
export KUBECTL_COMMAND_HEADERS=false

# --- Helm Configuration -------------------------------------------------------

# Helm data directory
export HELM_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/helm"

# Helm config directory
export HELM_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/helm"

# Helm cache directory
export HELM_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/helm"

# --- kustomize Configuration --------------------------------------------------

# kustomize plugin home
export KUSTOMIZE_PLUGIN_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/kustomize/plugin"

# --- k9s Configuration --------------------------------------------------------

# k9s config directory
export K9S_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/k9s"

# --- Lens Configuration -------------------------------------------------------

# Lens config directory (if using Lens/OpenLens)
export LENS_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/Lens"

# --- Kind Configuration -------------------------------------------------------

# Kind (Kubernetes in Docker) config
export KIND_EXPERIMENTAL_PROVIDER="docker"

# --- Minikube Configuration ---------------------------------------------------

# Minikube home directory
export MINIKUBE_HOME="${MINIKUBE_HOME:-$HOME/.minikube}"

# Default minikube driver
# export MINIKUBE_DRIVER=docker
