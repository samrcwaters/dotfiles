#!/bin/zsh

function cherrylog {
  # Show recent commits from a branch for cherry-picking
  # Usage: cherrylog <branch> [n]
  # Example: cherrylog feature-branch 5

  local branch="${1:?Usage: cherrylog <branch> [n]}"
  local count="${2:-10}"

  git --no-pager log "$branch" -n "$count" --reverse --pretty=format:"%h %<(50,trunc)%s %ai"
}

function conventional-commit {
  # Extract ticket number from branch name and create conventional commit
  # Usage: ccommit add something for feature X
  # Example: On branch ENG-3227-v2 or ENG-3227--do-something, creates commit "ENG-3227: add something for feature X"

  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  # Extract ticket number (PROJECT-NUMBER pattern from the start of branch name)
  local ticket=$(echo "$branch" | sed 's/^.*\/\([A-Z]*-[0-9]*\).*/\1/')

  # Check if ticket is empty
  if [[ -z "$ticket" ]]; then
    echo "Error: Could not extract ticket number from branch name"
    return 1
  fi

  # Create commit message
  local message="$ticket: $*"
  git commit -m "$message"
}
alias ccommit=conventional-commit

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

# Misc aliases
alias gc="git branch"
alias gco="git checkout"
alias gps="git push"
alias gpfwl="gps --force-with-lease"
alias gpl="git pull"
alias gcp="git cherry-pick"
alias gri="git rebase -i"

