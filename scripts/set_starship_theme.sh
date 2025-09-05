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
for i in "${!DISPLAY_NAMES[@]}"; do
    printf "%2d) %s\n" "$((i+1))" "${DISPLAY_NAMES[$i]}"
done

while true; do
    read -r -p $'\nSelect a theme to apply (or \'q\' to quit): ' REPLY
    if [[ "$REPLY" =~ ^[Qq]$ ]]; then
        echo "Exiting..."
        echo  "--------------------------------------------------------------------------------"
        exit 0
    elif [[ "$REPLY" =~ ^[0-9]+$ ]] && (( REPLY >= 1 && REPLY <= ${#DISPLAY_NAMES[@]} )); then
        index=$((REPLY - 1))
        choice="${DISPLAY_NAMES[$index]}"
        selected="${FULL_PATHS[$index]}"
        echo "Applying $choice..."
        "$SCRIPT_DIR"/util/backup_file.sh "$STARSHIP_CONFIG_FILE"
        cp -f "$selected" "$STARSHIP_CONFIG_FILE"
        break
    else
        echo "Invalid selection. Please enter a number from the list or 'q' to quit."
    fi
done

echo "-------------------------------- Theme Applied! --------------------------------"
