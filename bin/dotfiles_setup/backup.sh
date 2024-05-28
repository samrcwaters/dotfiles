#!/usr/bin/env zsh

source ./bin/dotfiles_setup/utils.sh

if [[ ! -d $backups_dir ]]; then
	mkdir $backups_dir
fi

# Back up files
timestamp=$(date +%Y%m%d_%H%M%S)
timestamped_backup_dir=$backups_dir/$timestamp
mkdir $timestamped_backup_dir
for file_name in $file_names; do
	if [[ -d $file_name ]]; then
		mkdir -p $timestamped_backup_dir/$file_name
		cp -a ~/$file_name/. $timestamped_backup_dir/$file_name
	else
		cp ~/$file_name $timestamped_backup_dir
	fi
	# Verify that file was successfully copied
	if [[ -e $timestamped_backup_dir/$file_name ]]; then
		echo-success "~/$file_name was successfully backed up to $timestamped_backup_dir/$file_name"
	else
		echo-failure "Failed to back up $file_name"
	fi
done
