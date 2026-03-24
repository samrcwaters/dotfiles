#!/bin/zsh

function cherrylog {
  # Show recent commits from a branch for cherry-picking
  # Usage: cherrylog <branch> [n]
  # Example: cherrylog feature-branch 5

  local branch="${1:?Usage: cherrylog <branch> [n]}"
  local count="${2:-10}"

  git --no-pager log "$branch" -n "$count" --reverse --pretty=format:"%h %<(50,trunc)%s %ai"
}

function ticket {
  # Extract Jira ticket number from current branch and copy to clipboard
  # Handles branches like: feat/ENG-1234, ENG-1234--something, ENG-3227-v2

  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  local ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)

  if [[ -z "$ticket" ]]; then
    echo "Error: Could not extract ticket number from branch name"
    return 1
  fi
  
  # Remove whitespace and trailing newline
  printf '%s' "$ticket" | xargs 
}

function create-conventional-commit-for-jira-ticket {
  $ticket | pbcopy
  cz commit
}

function make-dev-branch {
  local current_branch=$(git branch --show-current)
  local new_branch="$current_branch-dev"
  git checkout -b $new_branch
  git fetch origin
  git merge origin/develop
}

function gather-tickets-from-commits {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $(basename "$0") <base-branch> <compare-branch>"
    return 1
  fi

  BASE="$1"
  COMPARE="$2"

  tickets=$(git log "$BASE".."$COMPARE" --oneline | grep -oE 'ENG-[0-9]+' | sort -u)

  if [[ -z "$tickets" ]]; then
    echo "No tickets found in commits between $BASE and $COMPARE"
    return 0
  fi

  echo "$tickets" | sed 's/^/- /'
}

# GitLab
function glab-list-commits {
  local jira_issue_id="${1:?Usage: glab-list-commits <jira_issue_id>}"

  echo "Gathering all commits from MRs targeting develop for issue $jira_issue_id"

  local develop_mrs
  develop_mrs=$(glab mr list --target-branch develop --search "$jira_issue_id" --merged -F json | jq -r '.[].iid')

  if [[ -z "$develop_mrs" ]]; then
    echo "No merged MRs found targeting develop for issue $jira_issue_id"
    return 0
  fi

  local all_commits=()
  while IFS= read -r iid; do
    local commits
    commits=$(glab api "projects/:fullpath/merge_requests/$iid/commits" | \
      jq -r '.[] | "\(.committed_date) \(.short_id) \(.title)"')
    while IFS= read -r line; do
      [[ -n "$line" ]] && all_commits+=("$line")
    done <<< "$commits"
  done <<< "$develop_mrs"

  printf '%s\n' "${all_commits[@]}" | sort
}

function create-gitlab-merge-request {
  local draft=0
  local args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d) draft=1; shift ;;
      *) args+=("$1"); shift ;;
    esac
  done
  local target_branch="${args[1]}"
  local title="${args[2]}"
  local draft_flag=()
  [[ $draft -eq 1 ]] && draft_flag=(--draft)
  glab mr create \
    --target-branch $target_branch \
    --title "$title" \
    --description '' \
    "${draft_flag[@]}"
}
alias mkmr="create-gitlab-merge-request"

# Misc aliases
alias gc="git branch"
alias gco="git checkout"
alias gps="git push"
alias gpf="gps --force-with-lease"
alias gpl="git pull"
alias gcp="git cherry-pick"
alias gri="git rebase -i"

alias czc="cz commit"
alias jczc="create-conventional-commit-for-jira-ticket"
