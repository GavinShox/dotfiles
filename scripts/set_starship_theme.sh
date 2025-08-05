#!/bin/bash

STARSHIP_PATH=$HOME/.config/starship.toml
STARSHIP_THEMES=../starship_themes/*

PS3="Select a theme to apply: "
select file in $STARSHIP_THEMES; do
	echo "Applying ${file}..."
	./backup_file.sh $STARSHIP_PATH
	cp $file $STARSHIP_PATH
	echo "Theme applied!" 
	break
done
