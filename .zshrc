# Shared constants
export DATE_FORMAT_DEFAULT="+%Y-%m-%d %H:%M:%S"

# OMZ
export ZSH="$HOME/.oh-my-zsh"
export ZSH_SH="$ZSH/oh-my-zsh.sh"
export ZSH_THEME="bira"
plugins=(
  git
  command-not-found
  aws
  zsh-autocomplete # for things like real-time AWS CLI completions
  zsh-autosuggestions # for recall of commonly-typed commands 
)

source $ZSH_SH

# Aliases
alias tf="terraform"
alias nr="npm run"
alias d="docker"
alias d-c="docker-compose"
alias tks="tmux kill-session"

# Git aliases (adding here to be able to leave .gitconfig uncommitted)
$HOME/dotfiles/bin/set_git_aliases.sh

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Python
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Tmux utilities

function txinit {
  # Create a new tmux session with windows for each directory in TMUX_DEFAULT_DIRS
  local dirs=("${(@s/ /)TMUX_DEFAULT_DIRS}")
  local first_dir="${dirs[1]}"
  local session_name=$(basename "$first_dir")

  # Create the first window
  tmux new-session -s "$session_name" -c "$first_dir" -d -n "$session_name"

  # Create windows for remaining directories
  for dir in "${dirs[@]:1}"; do
    local window_name=$(basename "$dir")
    tmux new-window -t "$session_name" -c "$dir" -n "$window_name"
  done

  # Select the first window and attach
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

function txopen {
  # Open a new tmux window in the current session with name based on current directory
  local window_name=$(basename "$PWD")
  tmux new-window -c "$PWD" -n "$window_name"
}

# Other
## Needed for claude
export PATH="$HOME/.local/bin:$PATH"

os=$(uname -s)
if [[ $os == "Linux" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
