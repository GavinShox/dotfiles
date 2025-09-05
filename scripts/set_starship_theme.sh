#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STARSHIP_CONFIG_FILE="$HOME/.config/starship.toml"
STARSHIP_THEMES_DIR="$SCRIPT_DIR/../starship_themes/"

echo "-------------------------------- Apply Starship Theme --------------------------------"

# build arrays for separating display name and full path in select
FULL_PATHS=()
DISPLAY_NAMES=()

for f in "$STARSHIP_THEMES_DIR"/*; do
	# skip non files to be safe, right now not an issue but in the future it might
	[ -f "$f" ] || continue
	FULL_PATHS+=("$f")
	PREFIX="starship_"
	EXTENSION=".toml"
    DISPLAY_NAMES+=("$(basename "$f" | sed -e "s/^$PREFIX//" -e "s/$EXTENSION$//")")
done

echo "Available themes:"
echo

PS3=$'\nSelect a theme to apply (or \'q\' to quit): '
select choice in "${DISPLAY_NAMES[@]}"; do
	# handle 'q' char entered
    if [[ "$REPLY" =~ ^[Qq]$ ]]; then
        echo "Exiting..."
        break   # exit the select loop
    fi

	# checks if $choice is valid by ensuring it's non-empty
	if [[ -n "$choice" ]]; then
		# convert menu number to array index
		index=$((REPLY - 1))
		# get the full path
	    selected="${FULL_PATHS[$index]}"

		echo "Applying $choice..."
		"$SCRIPT_DIR"/util/backup_file.sh "$STARSHIP_CONFIG_FILE"
		cp -f "$selected" "$STARSHIP_CONFIG_FILE"
		break
	else
		echo "Invalid selection - please choose a number from the list, or 'q' to quit..."
	fi
done

echo "-------------------------------- Theme Applied! --------------------------------"
