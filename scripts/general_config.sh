#!/bin/bash

# This script will simply copy config files into the user's home directory, which is all that is needed for most programs
# (tmux for example has a separate script as it isn't as simple as copying files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
DOTFILE_CONFIG_DIR="$SCRIPT_DIR/../.config"

echo "-------------------------------- dotfile script --------------------------------"
read -r -p "Existing config files will be overwritten, but you will get the option to make backups. Continue? (y/n): " input
if [[ $input == "Y" || $input == 'y' ]]; then
	echo "Stopping script"
	exit 1
fi

read -r -p "Do you want to make backups of your existing files? (y/n): " backup_input
if [[ $backup_input == "Y" || $backup_input == "y" ]]; then
	backup=true
else
	backup=false
fi

for dir in "$DOTFILE_CONFIG_DIR"/*; do
	# only process on directories
	[ -d "$dir" ] || continue
	dirname=$(basename "$dir")
	target_dir="$CONFIG_DIR/$dirname"

	# ask after each config is applied
	read -r -p "Apply $dirname config? (y/n): " folder_input
	if [[ $folder_input == "Y" || $folder_input == "y" ]]; then
		if [[ "$backup" == true ]]; then
			echo "Backing up $dirname config file..."
			"$SCRIPT_DIR"/backup_dir.sh "$target_dir"
		fi

		echo "Applying $dirname config files..."
		# make sure the dir exists before copying
		mkdir -p "$target_dir"
		cp -rf "$dir"/* "$target_dir"
	else
		echo "Skipping ${dirname}..."
	fi
done
echo "All configs applied!"

