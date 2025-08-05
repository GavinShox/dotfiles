#!/bin/bash

FISH_DIR="${HOME}/.config/fish"

echo "Files will be overwritten after a backup is made, are you sure? (y/n) "
read input
if [[ $input == "Y" || $input == "y" ]]; then
	./backup_dir.sh $FISH_DIR
	cp -rf ../.config/fish/* $FISH_DIR
else
	echo "Stopping script"
fi
