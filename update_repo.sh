#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/src/configs"

TOP_BORDER="============================== Update Current Configs =============================="
BOTTOM_FAILED_BORDER="===================================================================================="
BOTTOM_SUCCESSFUL_BORDER="============================= Current Configs Updated! ============================="

# function to map target path in repo -> src path in $HOME
get_src_conf() {
    local repo_conf="$1"
    local rel_path="${repo_conf#"$CONFIG_DIR"/}"
    echo "$HOME/$rel_path"
}

echo "$TOP_BORDER"
read -r -p "Existing config files in this repo will be overwritten. Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo "Exiting script..."
	echo "$BOTTOM_FAILED_BORDER"
	exit 1
fi

# build array of configs
configs=()
# file/dir names to exclude
EXCLUDE=(".config" ".local")
for conf in "$CONFIG_DIR"/* "$CONFIG_DIR"/.*; do
    [ -e "$conf" ] || continue
    base=$(basename "$conf")
    
    # skip . and .. relative dirs
    [[ "$base" == "." || "$base" == ".." ]] && continue

    # check if src_conf actually exists in users current configs
    src_conf="$(get_src_conf "$conf")"
	if [[ ! -f "$src_conf" && ! -d "$src_conf" ]]; then
	    continue   # not a file or directory
	fi

    # if this directory is in EXCLUDE, recurse inside it instead of treating it as a conf dir
    skip=false
    for ex in "${EXCLUDE[@]}"; do
        if [[ "$base" == "$ex" && -d "$conf" ]]; then

            for subconf in "$conf"/* "$conf"/.*; do
                [ -e "$subconf" ] || continue
                subbase=$(basename "$subconf")

                [[ "$subbase" == "." || "$subbase" == ".." ]] && continue

                # check if src_conf actually exists in users current configs
			    sub_src_conf="$(get_src_conf "$subconf")"
				if [[ ! -f "$sub_src_conf" && ! -d "$sub_src_conf" ]]; then
				    continue   # not a file or directory
				fi

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
echo "Available configs that can be updated:"
echo
for i in "${!configs[@]}"; do
	# remove prefix to display to user
	name="$(basename "${configs[$i]}")"
    printf "%2d) %s\n" "$((i+1))" "$name"
done

# ask user for selection(s)
echo
read -r -p "Enter numbers separated by spaces (e.g. 1 3 5) or 'a' for all ('q' to quit): " selection
echo

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

# function to check for differences and prompt user, 0: save, 1: skip, 2: answered no, skip
check_diff() {
    local src="$1"
    local target="$2"
    local name="$3"

    # determine if directory or file
    local diff_cmd
    if [[ -d "$target" ]]; then
        diff_cmd=(diff -r "$target" "$src")
    else
        diff_cmd=(diff "$target" "$src")
    fi

    # return 1 if no diff
    if "${diff_cmd[@]}" >/dev/null 2>&1; then
        # No differences found, skip
        return 1
    fi

    # differences found, show them and prompt
    "${diff_cmd[@]}"
    while true; do
        read -r -p "Difference found between the repo's $name config and your current config. Continue? (y/n): " input
        case "$input" in
            [Yy]) return 0 ;;   # apply
            [Nn]) return 2 ;;   # answered no, skip
            *) echo "Please answer y or n." ;;
        esac
    done
}

for target_conf in "${selected[@]}"; do
    src_conf="$(get_src_conf "$target_conf")"
    name="$(basename "$target_conf")"

    # check diff
	echo "Checking differences in $name config..."
	check_diff "$src_conf" "$target_conf" "$name"
	case $? in
		0)
			# apply config
			;;
		1)
			echo "Skipping $name config, no differences found between $target_conf and $src_conf..."
			echo
			continue
			;;
		2)
			echo "Skipping $name config..."
			echo
			continue
			;;
	esac

    # reach here on a 0 return of check_diff
    if [[ -d "$src_conf" ]]; then
        echo "Updating $name config..."
        mkdir -p "$target_conf"
        rsync -a "$src_conf"/ "$target_conf"/
    elif [[ -f "$src_conf" ]]; then
        echo "Updating $name config..."
        cp -f "$src_conf" "$target_conf"
    fi
done

echo "$BOTTOM_SUCCESSFUL_BORDER"

