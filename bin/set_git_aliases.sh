#!/usr/bin/env zsh

# Test to see if aliases already exist before setting them.
# This is to avoid multiple processes attempting to edit .gitconfig simultaneously.
# TODO: move this to its own script file in /lib
declare -A git_aliases
git_aliases=(
  [co]="checkout"
  [b]="branch"
  [ci]="commit"
  [st]="status"
)
# Test if alias already exists.
for cmd_alias cmd in ${(kv)git_aliases}; do;
  if [[ $(git config --get-regexp "alias.$cmd_alias" | wc -m) -eq 0 ]]; then
    echo "Creating alias ${cmd_alias}..."
    git config --global alias.${cmd_alias} ${cmd}
  fi
done
