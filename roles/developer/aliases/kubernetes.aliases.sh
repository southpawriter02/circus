# ==============================================================================
# Kubernetes Aliases
#
# Common kubectl and Kubernetes shortcuts for developer workflow.
# Designed to be memorable and consistent with kubectl naming conventions.
#
# USAGE:
#   These aliases are automatically loaded when the developer role is active.
#
# REFERENCES:
#   - kubectl documentation: https://kubernetes.io/docs/reference/kubectl/
#   - kubectl cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
#
# NAMING CONVENTION:
#   k = kubectl
#   kg = kubectl get
#   kd = kubectl describe
#   kl = kubectl logs
#   ke = kubectl exec
#   ka = kubectl apply
#   kx = kubectl delete
# ==============================================================================

# --- Basic kubectl ------------------------------------------------------------

alias k='kubectl'
alias kv='kubectl version'
alias kapi='kubectl api-resources'

# --- Get Resources ------------------------------------------------------------

# Pods
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kubectl get pods -o wide'
alias kgpwatch='kubectl get pods -w'

# Services
alias kgs='kubectl get services'
alias kgsa='kubectl get services --all-namespaces'
alias kgsw='kubectl get services -o wide'

# Deployments
alias kgd='kubectl get deployments'
alias kgda='kubectl get deployments --all-namespaces'
alias kgdw='kubectl get deployments -o wide'

# Nodes
alias kgn='kubectl get nodes'
alias kgnw='kubectl get nodes -o wide'

# All resources
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# ConfigMaps & Secrets
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'

# Ingress
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress --all-namespaces'

# Namespaces
alias kgns='kubectl get namespaces'

# Persistent Volumes
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'

# Jobs & CronJobs
alias kgj='kubectl get jobs'
alias kgcj='kubectl get cronjobs'

# Statefulsets & Daemonsets
alias kgss='kubectl get statefulsets'
alias kgds='kubectl get daemonsets'

# ReplicaSets
alias kgrs='kubectl get replicasets'

# Events (sorted by time)
alias kge='kubectl get events --sort-by=.metadata.creationTimestamp'

# --- Describe Resources -------------------------------------------------------

alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'
alias kdcm='kubectl describe configmap'
alias kdsec='kubectl describe secret'
alias kdi='kubectl describe ingress'

# --- Logs ---------------------------------------------------------------------

alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klt='kubectl logs --tail=100'
alias klft='kubectl logs -f --tail=100'
alias klp='kubectl logs --previous'

# Logs with timestamps
alias klts='kubectl logs --timestamps'

# --- Exec into Containers -----------------------------------------------------

alias kex='kubectl exec -it'
alias ksh='kubectl exec -it -- /bin/sh'
alias kbash='kubectl exec -it -- /bin/bash'

# --- Apply & Delete -----------------------------------------------------------

alias kaf='kubectl apply -f'
alias kak='kubectl apply -k'
alias kdf='kubectl delete -f'
alias kdk='kubectl delete -k'

# Delete resources
alias kxp='kubectl delete pod'
alias kxd='kubectl delete deployment'
alias kxs='kubectl delete service'
alias kxcm='kubectl delete configmap'
alias kxsec='kubectl delete secret'

# Force delete (for stuck pods)
alias kxpf='kubectl delete pod --force --grace-period=0'

# --- Context & Namespace Management -------------------------------------------

# Context
alias kctx='kubectl config current-context'
alias kctxl='kubectl config get-contexts'
alias kctxu='kubectl config use-context'

# Namespace
alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'
alias knsset='kubectl config set-context --current --namespace'

# --- Port Forwarding ----------------------------------------------------------

alias kpf='kubectl port-forward'

# --- Resource Monitoring ------------------------------------------------------

alias ktn='kubectl top nodes'
alias ktp='kubectl top pods'
alias ktpc='kubectl top pods --containers'

# --- Rollout Management -------------------------------------------------------

alias kroll='kubectl rollout status'
alias krollh='kubectl rollout history'
alias krollr='kubectl rollout restart'
alias krollu='kubectl rollout undo'
alias krollp='kubectl rollout pause'
alias krollres='kubectl rollout resume'

# --- Scaling ------------------------------------------------------------------

alias kscale='kubectl scale'

# --- Edit Resources -----------------------------------------------------------

alias ked='kubectl edit'
alias kedp='kubectl edit pod'
alias kedd='kubectl edit deployment'
alias keds='kubectl edit service'
alias kedcm='kubectl edit configmap'

# --- Labels & Annotations -----------------------------------------------------

alias klabel='kubectl label'
alias kanno='kubectl annotate'

# --- Dry Run & Diff -----------------------------------------------------------

alias kdry='kubectl apply --dry-run=client -o yaml'
alias kdiff='kubectl diff -f'

# --- Output Formats -----------------------------------------------------------

# Get resource as YAML
alias kgy='kubectl get -o yaml'
alias kgpy='kubectl get pod -o yaml'
alias kgdy='kubectl get deployment -o yaml'
alias kgsy='kubectl get service -o yaml'

# Get resource as JSON
alias kgj='kubectl get -o json'

# Get with custom columns
alias kgpn='kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName'

# --- Cluster Info -------------------------------------------------------------

alias kci='kubectl cluster-info'
alias kcid='kubectl cluster-info dump'

# --- Debugging ----------------------------------------------------------------

alias krun='kubectl run'
alias kdebug='kubectl debug'

# Debug with busybox
alias krunbb='kubectl run debug-pod --image=busybox --rm -it --restart=Never -- /bin/sh'

# Debug with curl
alias kruncurl='kubectl run curl-pod --image=curlimages/curl --rm -it --restart=Never -- /bin/sh'

# --- Useful Functions ---------------------------------------------------------

# Execute command in pod (pod name as first arg, command as rest)
kexec() {
    local pod="$1"
    shift
    kubectl exec -it "$pod" -- "$@"
}

# Follow logs with optional tail count
klogs() {
    local pod="$1"
    local lines="${2:-100}"
    kubectl logs -f --tail="$lines" "$pod"
}

# Watch pods in a namespace
kwatch() {
    local ns="${1:-default}"
    kubectl get pods -n "$ns" -w
}

# Get all resources in a namespace
kgetall() {
    local ns="${1:-default}"
    kubectl get all -n "$ns"
}

# Restart a deployment
krestart() {
    kubectl rollout restart deployment "$1"
}

# Scale a deployment
kscaledep() {
    local deploy="$1"
    local replicas="$2"
    kubectl scale deployment "$deploy" --replicas="$replicas"
}

# Get pod by partial name
kgpod() {
    kubectl get pods | grep "$1"
}

# Describe pod by partial name
kdpod() {
    local pod
    pod=$(kubectl get pods -o name | grep "$1" | head -1)
    [ -n "$pod" ] && kubectl describe "$pod"
}

# Logs by partial pod name
klpod() {
    local pod
    pod=$(kubectl get pods -o name | grep "$1" | head -1)
    [ -n "$pod" ] && kubectl logs -f "$pod"
}

# Quick shell into first matching pod
kshpod() {
    local pod
    pod=$(kubectl get pods -o name | grep "$1" | head -1)
    [ -n "$pod" ] && kubectl exec -it "$pod" -- /bin/sh
}

# Copy files to/from pod
# Usage: kcopy my-pod:/path/in/pod ./local/path
alias kcopy='kubectl cp'

# Get events for a specific pod
kpevents() {
    kubectl get events --field-selector involvedObject.name="$1"
}

# Show resource usage for pods in current namespace
kusage() {
    echo "=== Pod Resource Usage ==="
    kubectl top pods
    echo ""
    echo "=== Node Resource Usage ==="
    kubectl top nodes
}

# Quick namespace switch
ns() {
    if [ -z "$1" ]; then
        kubectl config view --minify --output 'jsonpath={..namespace}' && echo
    else
        kubectl config set-context --current --namespace="$1"
        echo "Switched to namespace: $1"
    fi
}

# Show all available aliases for reference
kalias() {
    echo "=== Kubernetes Aliases ==="
    alias | grep -E "^k[a-z]+=" | sed "s/=/ = /" | sort
    echo ""
    echo "=== Functions ==="
    echo "kexec <pod> <cmd>  - Execute command in pod"
    echo "klogs <pod> [n]    - Follow logs (last n lines)"
    echo "kwatch [ns]        - Watch pods in namespace"
    echo "kgetall [ns]       - Get all resources in namespace"
    echo "krestart <deploy>  - Restart deployment"
    echo "kscaledep <d> <n>  - Scale deployment to n replicas"
    echo "kgpod <pattern>    - Get pods matching pattern"
    echo "kdpod <pattern>    - Describe first matching pod"
    echo "klpod <pattern>    - Logs from first matching pod"
    echo "kshpod <pattern>   - Shell into first matching pod"
    echo "kpevents <pod>     - Get events for pod"
    echo "kusage             - Show resource usage"
    echo "ns [namespace]     - Get/set current namespace"
}
