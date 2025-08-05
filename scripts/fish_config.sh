#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FISH_DIR="${HOME}/.config/fish"

echo "Files will be overwritten after a backup is made, are you sure? (y/n) "
read input
if [[ $input == "Y" || $input == "y" ]]; then
	$SCRIPT_DIR/backup_dir.sh $FISH_DIR
	cp -rf $SCRIPT_DIR/../.config/fish/* $FISH_DIR
else
	echo "Stopping script"
fi
