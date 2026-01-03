# ==============================================================================
# Git Aliases
#
# Common git shortcuts for developer workflow. Designed to be memorable
# and consistent with git naming conventions.
#
# USAGE:
#   These aliases are automatically loaded when the developer role is active.
#
# REFERENCES:
#   - Git documentation: https://git-scm.com/docs
#   - Oh My Zsh git plugin: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
# ==============================================================================

# --- Basic Operations ---------------------------------------------------------

alias g='git'
alias gs='git status'
alias gst='git status --short --branch'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit -v --amend'
alias gcam='git commit -a -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'

# --- Branching ----------------------------------------------------------------

alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbr='git branch -r'
alias gm='git merge'
alias gma='git merge --abort'
alias gms='git merge --squash'

# --- Stashing -----------------------------------------------------------------

alias gsta='git stash push'
alias gstaa='git stash push --include-untracked'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'
alias gstc='git stash clear'
alias gsts='git stash show --text'

# --- Remote Operations --------------------------------------------------------

alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpo='git push origin'
alias gpom='git push origin main'
alias gpu='git push -u origin HEAD'
alias gl='git pull'
alias glr='git pull --rebase'
alias glo='git pull origin'
alias glom='git pull origin main'
alias gcl='git clone'
alias gr='git remote'
alias grv='git remote -v'

# --- Rebasing -----------------------------------------------------------------

alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbs='git rebase --skip'
alias grbm='git rebase main'
alias grbom='git rebase origin/main'

# --- Logging & History --------------------------------------------------------

alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glogp='git log -p'                         # Show patches
alias glogs='git log --stat'                     # Show stats
alias glog1='git log --oneline -n 10'           # Last 10 commits
alias glast='git log -1 HEAD --stat'            # Last commit details
alias gwho='git shortlog -sne'                   # Contributor stats

# --- Diffing ------------------------------------------------------------------

alias gd='git diff'
alias gds='git diff --staged'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff'
alias gdt='git difftool'

# --- Reset & Clean ------------------------------------------------------------

alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grs='git restore'
alias grss='git restore --staged'
alias gclean='git clean -fd'
alias gpristine='git reset --hard && git clean -dfx'

# --- Cherry-pick --------------------------------------------------------------

alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# --- Worktree -----------------------------------------------------------------

alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'

# --- Tagging ------------------------------------------------------------------

alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'
alias gtl='git tag -l'

# --- Bisect -------------------------------------------------------------------

alias gbs='git bisect'
alias gbss='git bisect start'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'

# --- Submodules ---------------------------------------------------------------

alias gsm='git submodule'
alias gsmu='git submodule update --init --recursive'
alias gsms='git submodule status'

# --- Useful Compound Commands ------------------------------------------------

# Show branches sorted by last commit
alias gbage='git for-each-ref --sort=-committerdate refs/heads/ --format="%(committerdate:short) %(refname:short)"'

# Show what would be pushed
alias gwtd='git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD'

# Find commits by message
gfind() {
    git log --all --oneline --grep="$1"
}

# Find commits by author
gfinda() {
    git log --all --oneline --author="$1"
}

# Interactive fixup of last N commits
gfix() {
    git rebase -i HEAD~${1:-5}
}

# Create branch from issue number (e.g., gissue 123 "feature description")
gissue() {
    local issue="$1"
    local desc="${2:-feature}"
    local branch="feature/${issue}-$(echo "$desc" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
    git checkout -b "$branch"
}

# Show git aliases (this file's aliases that are loaded)
galias() {
    alias | grep -E "^g[a-z]+=" | sed "s/=/ = /" | sort
}
