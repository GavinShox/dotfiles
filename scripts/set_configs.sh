#!/bin/bash

# This script will simply copy config files into the user's home directory, which is all that is needed for most programs
# (tmux for example has a separate script as it isn't as simple as copying files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# dotfiles top level dir in repo
CONFIG_DIR="$SCRIPT_DIR/../configs"

# map src_conf path in repo -> target_conf path in $HOME
get_target_conf() {
    local src_conf="$1"
    local rel_path="${src_conf#"$CONFIG_DIR"/}"
    echo "$HOME/$rel_path"
}

TOP_BORDER="-------------------------------- Apply Dotfiles --------------------------------"
BOTTOM_FAILED_BORDER="--------------------------------------------------------------------------------"
BOTTOM_SUCCESSFUL_BORDER="-------------------------------- Dotfiles applied! -----------------------------"

echo "$TOP_BORDER"
read -r -p "Existing config files will be overwritten, but you will get the option to make backups. Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo "Exiting script..."
	echo "$BOTTOM_FAILED_BORDER"
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

# build array of configs
configs=()
# file/dir names to exclude
EXCLUDE=(".config" ".local")
for conf in "$CONFIG_DIR"/* "$CONFIG_DIR"/.*; do
    [ -e "$conf" ] || continue
    base=$(basename "$conf")

    # skip . and .. relative dirs
    [[ "$base" == "." || "$base" == ".." ]] && continue

    # if this directory is in EXCLUDE, recurse inside it instead of treating it as a conf dir
    skip=false
    for ex in "${EXCLUDE[@]}"; do
        if [[ "$base" == "$ex" && -d "$conf" ]]; then

            for subconf in "$conf"/* "$conf"/.*; do
                [ -e "$subconf" ] || continue
                subbase=$(basename "$subconf")

                [[ "$subbase" == "." || "$subbase" == ".." ]] && continue

                configs+=("$subconf")
            done

            skip=true
            break
        fi
    done

	# if not skipped, add to configs array
    if ! $skip; then
        configs+=("$conf")
    fi
done

# show numbered list
echo
echo "Available configs:"
echo
for i in "${!configs[@]}"; do
	# remove prefix to display to user
	name="$(basename "${configs[$i]}")"
    printf "%2d) %s\n" "$((i+1))" "$name"
done

# ask user for selection(s)
echo
read -r -p "Enter numbers separated by spaces (e.g. 1 3 5) or 'a' for all ('q' to quit): " selection

# quit option
if [[ "$selection" =~ ^[Qq]$ ]]; then
    echo "Exiting script..."
    echo "$BOTTOM_FAILED_BORDER"
    exit 0
fi

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
    echo "No configs selected. Exiting script..."
    echo "$BOTTOM_FAILED_BORDER"
    exit 1
fi

for src_conf in "${selected[@]}"; do
    target_conf="$(get_target_conf "$src_conf")"
    name="$(basename "$src_conf")"

	# handle config directory
	if [[ -d "$src_conf" ]]; then
		if [[ "$backup" == true ]]; then
	    	echo
	        echo "Backing up $name config..."
	        "$SCRIPT_DIR"/util/backup_dir.sh "$target_conf"
		fi

	    echo "Applying $name config..."
	    mkdir -p "$target_conf"
		# TODO Using rsync as is, or use --delete flag to make sure extra files in target won't break a program
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

echo "$BOTTOM_SUCCESSFUL_BORDER"
