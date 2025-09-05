#!/bin/bash

# This script will simply copy config files into the user's home directory, which is all that is needed for most programs
# (tmux for example has a separate script as it isn't as simple as copying files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
# dotfiles meant to go in ~
DOTFILE_TOP_LEVEL_DIR="$SCRIPT_DIR/../configs"
# dotfiles meant to go in ~/.config
DOTFILE_CONFIG_DIR="$DOTFILE_TOP_LEVEL_DIR/.config"

echo "-------------------------------- Apply Dotfiles --------------------------------"
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
        *) echo "Please answer yes (y) or no (n)." ;;
    esac
done

# build array of configs to go in ~/.config
configs=()
for conf in "$DOTFILE_CONFIG_DIR"/* "$DOTFILE_CONFIG_DIR"/.*; do
    [ -e "$conf" ] || continue
    base=$(basename "$conf")

    # skip . and .. relative dirs
    [[ "$base" == "." || "$base" == ".." ]] && continue

	# prefix with config
	configs+=("config:$base")
done

# and configs that will go directly into the home directory
for hconf in "$DOTFILE_TOP_LEVEL_DIR"/* "$DOTFILE_TOP_LEVEL_DIR"/.*; do
	[ -e "$hconf" ] || continue
	base=$(basename "$hconf")

	# skip . and .. relative dirs, and the .config dir
	[[ "$base" == "." || "$base" == ".." || "$base" == ".config" ]] && continue

	# prefix with hconfig
	configs+=("hconfig:$base")
done

# show numbered list
echo
echo "Available configs:"
for i in "${!configs[@]}"; do
	# remove prefix to display to user
    sel="${configs[$i]}"
    name="${sel#*:}"
    printf "%2d) %s\n" "$((i+1))" "$name"
done

# ask user for selection(s)
echo
read -r -p "Enter numbers separated by spaces (e.g. 1 3 5) or 'a' for all ('q' to quit): " selection

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
    echo "No configs selected. Exiting..."
    echo "-----------------------------------------------------------------------------------"
    exit 1
fi

for sel in "${selected[@]}"; do
	# separate prefix that was applied above from the config name
	kind="${sel%%:*}"
	name="${sel#*:}"

	# configs to go into ~/.config
	if [[ "$kind" == "config" ]]; then
		src_conf="$DOTFILE_CONFIG_DIR/$name"
	    target_conf="$CONFIG_DIR/$name"
	# configs to go into ~
	elif [[ "$kind" == "hconfig" ]]; then
		src_conf="$DOTFILE_TOP_LEVEL_DIR/$name"
		target_conf="$HOME/$name"
	else
		echo "Error: Unkown kind of config ($kind). Exiting..."
		echo "-----------------------------------------------------------------------------------"
		exit 1
	fi

	# handle config directory
	if [[ -d "$src_conf" ]]; then
		if [[ "$backup" == true ]]; then
	    	echo
	        echo "Backing up $name config..."
	        "$SCRIPT_DIR"/util/backup_dir.sh "$target_conf"
		fi
		
	    echo "Applying $name config..."
	    mkdir -p "$target_conf"
		# TODO Using rsync as is, or use --delete flag to make sure extra files in target won't break a program e.g. two incompatible addons
	    #cp -rf "$src_conf"/* "$target_conf"
	    rsync -a "$src_conf"/ "$target_conf"/
	# handle config file
	elif [[ -f "$src_conf" ]]; then
		if [[ "$backup" == true ]]; then
	    	echo
	        echo "Backing up $name config..."
	        "$SCRIPT_DIR"/util/backup_file.sh "$target_conf"
		fi

		echo "Applying $name config..."
		cp -f "$src_conf" "$target_conf"
	fi
done

echo "-------------------------------- Dotfiles applied! --------------------------------"
