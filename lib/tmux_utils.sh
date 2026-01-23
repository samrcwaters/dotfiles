#!/bin/zsh

function txinit {
  # Create a new tmux session with windows for each directory in TMUX_DEFAULT_DIRS
  local first_dir="${TMUX_DEFAULT_DIRS[1]}"
  local session_name=$(basename "$first_dir")

  # Create the first window
  tmux new-session -s "$session_name" -c "$first_dir" -d -n "$(basename "$first_dir")"

  # Create windows for remaining directories
  for dir in "${TMUX_DEFAULT_DIRS[@]:1}"; do
    local window_name=$(basename "$dir")
    tmux new-window -t "$session_name:" -c "$dir" -n "$window_name"
  done

  # Select the first window and attach
  tmux select-window -t "$session_name:0"
  tmux attach-session -t "$session_name"
}

function txopen {
  # Open a new tmux window in the current session with name based on target directory
  local target_dir="${1:-$PWD}"
  target_dir="${target_dir/#\~/$HOME}"
  local window_name=$(basename "$target_dir")
  tmux new-window -c "$target_dir" -n "$window_name"
}
