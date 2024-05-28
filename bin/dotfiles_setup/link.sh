#!/usr/bin/env zsh

source ./bin/dotfiles_setup/constants.sh
source ./bin/dotfiles_setup/utils.sh

# Create symlinks
for file_name in $file_names; do
  create_symlink $file_name
done
