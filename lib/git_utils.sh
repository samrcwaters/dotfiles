#!/bin/zsh

function cherrylog {
  # Show recent commits from a branch for cherry-picking
  # Usage: cherrylog <branch> [n]
  # Example: cherrylog feature-branch 5

  local branch="${1:?Usage: cherrylog <branch> [n]}"
  local count="${2:-10}"

  git --no-pager log "$branch" -n "$count" --pretty=format:"%h %s"
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
  local ticket=$(echo "$branch" | sed 's/^\([A-Z]*-[0-9]*\).*/\1/')

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
