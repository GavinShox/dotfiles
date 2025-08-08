#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
DOTFILE_CONFIG_DIR="$SCRIPT_DIR/../.config"

read -r -p "⚠️  This will overwrite existing config files. Backups will be made. Continue? (y/n): " input
if [[ $input == "Y" || $input == "y" ]]; then
	for dir in "$DOTFILE_CONFIG_DIR"/*; do
		# only process on directories
		[ -d "$dir" ] || continue
		dirname=$(basename "$dir")
		target_dir="$CONFIG_DIR/$dirname"

		# ask after each config is applied
		read -r -p "Apply $dirname config? (y/n): " folder_input
		if [[ $folder_input == "Y" || $folder_input == "y" ]]; then
			echo "Backing up $dirname config file..."
			"$SCRIPT_DIR"/backup_dir.sh "$target_dir"

			echo "Applying $dirname config files..."
			# make sure the dir exists before copying
			mkdir -p "$target_dir"
			cp -rf "$dir"/* "$target_dir"
		else
			echo "Skipping ${dirname}..."
		fi
	done
	echo "All configs applied!"
else
	echo "Stopping script"
fi
