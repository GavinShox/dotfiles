#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STARSHIP_PATH=$HOME/.config/starship.toml
STARSHIP_THEMES=$SCRIPT_DIR/../starship_themes/*

PS3="Select a theme to apply: "
select file in $STARSHIP_THEMES; do
	echo "Applying ${file}..."
	$SCRIPT_DIR/backup_file.sh $STARSHIP_PATH
	cp $file $STARSHIP_PATH
	echo "Theme applied!" 
	break
done
