#!/usr/bin/env zsh

source ./bin/dotfiles_setup/constants.sh

# Logging

echo-failure() {
	echo "❌ $1"
}

echo-success() {
	echo "✅ $1"
}

echo-warning() {
	echo "⚠️ $1"
}

# Files

create_symlink() {
	file_name=$1
	dest_path=$(pwd)/$file_name
	link_path=~/$file_name
	if [[ -e $link_path ]]; then
		if [[ ! -L $link_path ]]; then
			echo-warning "$link_path exists and is not a symlink. Back up and delete this file/directory before retrying."
			return 1
		else
			echo-success "Symlink for $link_path already exists. Skipping..."
			return 0
		fi
	fi
	ln -s $dest_path $link_path
	if [[ $? -eq 0 ]]; then
		echo-success "Created symlink $link_path -> $dest_path"
	else
		echo-failure "Failed to create symlink $link_path -> $dest_path"
		return 1
	fi
}
