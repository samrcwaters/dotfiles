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

# zsh-autocomplete
zstyle ':autocomplete:*' min-input 6

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

# ts-node configuration
export TS_NODE_COMPILER_OPTIONS='{"module":"commonjs","moduleResolution":"node"}'

# Python
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Utilities
for file in $HOME/dotfiles/lib/*.sh; do
  source "$file"
done

# Other
## Needed for claude
export PATH="$HOME/.local/bin:$PATH"

os=$(uname -s)
if [[ $os == "Linux" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

source $ZSH_SH
