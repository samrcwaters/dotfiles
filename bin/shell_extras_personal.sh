#!/usr/bin/env zsh

alias python=python3
alias pip=pip3
alias tf="terraform"

# Python
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Scala
export PATH="$PATH:$HOME/.local/share/coursier/bin"
alias scli="scala-cli -S 2.13.11 --jvm adopt:11"

# Java
[ -s "$HOME/.jabba/jabba.sh" ] && source "$HOME/.jabba/jabba.sh"

# Go
export PATH="$HOME/.gobrew/current/bin:$HOME/.gobrew/bin:$PATH"
export GOROOT="$HOME/.gobrew/current/go"
if [[ $OS = "debian" ]]; then
	export CPATH="/mnt/c/Users/$WIN_USER_ID"
	export NOTESPATH="$CPATH/Documents/notes"

	alias nvim="nvim.appimage"
	alias pbcopy="xclip -selection clipboard"
	alias pbpaste="xclip -o"
fi
if [[ $ENABLE_RUST = true ]]; then
	. "$HOME/.cargo/env"
fi
