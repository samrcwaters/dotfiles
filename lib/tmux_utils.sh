#!/bin/zsh

# Create a new tmux session with windows for each directory in TMUX_DEFAULT_DIRS
function txinit {
  local first_entry="${TMUX_DEFAULT_DIRS[1]}"
  # Read this as "trim whatever matches `:*` from the **right** side of $first_entry".
  # So "/some/dir:somedir_alias" becomes "/some/dir"
  local first_dir="${first_entry%%:*}"
  # Read this as "trim whatever matches `*:` from the left side of $first_entry".
  local first_window_name="${first_entry##*:}"
  local session_name=$(basename "$first_dir")
  # Create the first window
  tmux new-session -s "$session_name" -c "$first_dir" -d -n $first_window_name

  # Create windows for remaining directories
  for entry in "${TMUX_DEFAULT_DIRS[@]:1}"; do
    local dir="${entry%%:*}"
    local window_name="${entry##*:}"
    tmux new-window -t "$session_name:" -c "$dir" -n "$window_name"
  done

  # Select the first window and attach
  tmux select-window -t "$session_name:0"
  tmux attach-session -t "$session_name"
}

# Open a new tmux window in the current session with name based on target directory.
# Unlike txinit, this does not currently support custom window names.
function txopen {
  local target_dir="${1:-$PWD}"
  target_dir="${target_dir/#\~/$HOME}"
  local window_name=$(basename "$target_dir")
  tmux new-window -c "$target_dir" -n "$window_name"
}
