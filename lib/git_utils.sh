#!/bin/zsh

function ccommit {
  # Extract ticket number from branch name and create conventional commit
  # Usage: ccommit add something for feature X
  # Example: On branch ENG-3227--do-something, creates commit "ENG-3227: add something for feature X"

  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  # Extract ticket number (everything before the first -- if it exists, otherwise use the whole branch name)
  local ticket=$(echo "$branch" | sed 's/--.*$//')

  # Check if ticket is empty
  if [[ -z "$ticket" ]]; then
    echo "Error: Could not extract ticket number from branch name"
    return 1
  fi

  # Create commit message
  local message="$ticket: $*"
  git commit -m "$message"
}
