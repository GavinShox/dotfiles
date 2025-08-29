#!/bin/bash

# This script will simply copy config files into the user's home directory, which is all that is needed for most programs
# (tmux for example has a separate script as it isn't as simple as copying files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
DOTFILE_CONFIG_DIR="$SCRIPT_DIR/../.config"

echo "-------------------------------- My dotfile script --------------------------------"
read -r -p "Existing config files will be overwritten, but you will get the option to make backups. Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo "Stopping script"
	exit 1
fi

while true; do
    read -r -p "Do you want to make backups of your existing files? (y/n): " backup_input
    case "$backup_input" in
        [Yy]) backup=true; break ;;
        [Nn]) backup=false; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# build array of configs
configs=()
for dir in "$DOTFILE_CONFIG_DIR"/*; do
    [ -d "$dir" ] || continue
    configs+=("$(basename "$dir")")
done

# show numbered list
echo "Available configs:"
for i in "${!configs[@]}"; do
    printf "%2d) %s\n" "$((i+1))" "${configs[$i]}"
done

# ask user for selection(s)
echo
read -r -p "Enter numbers separated by spaces (e.g. 1 3 5) or 'a' for all: " selection

# convert selection into array
selected=()
if [[ "$selection" =~ ^[Aa]$ ]]; then
    selected=("${configs[@]}")
else
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#configs[@]} )); then
            selected+=("${configs[$((num-1))]}")
        else
            echo "Invalid selection: $num"
        fi
    done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
    echo "No configs selected, exiting."
    exit 1
fi

for dirname in "${selected[@]}"; do
    dir="$DOTFILE_CONFIG_DIR/$dirname"
    target_dir="$CONFIG_DIR/$dirname"

    if [[ "$backup" == true ]]; then
    	echo
        echo "Backing up $dirname config..."
        "$SCRIPT_DIR"/backup_dir.sh "$target_dir"
    fi

    echo "Applying $dirname config..."
    mkdir -p "$target_dir"
    # this overlays files
    cp -rf "$dir"/* "$target_dir"
    # this replaces whole directory
    #rsync -a --delete "$dir"/ "$target_dir"/
done

echo "-------------------------------- Configs applied! --------------------------------"
