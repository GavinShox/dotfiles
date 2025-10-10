#!/bin/bash

# This script will simply copy config files into the user's home directory, which is all that is needed for most programs
# (tmux for example has a separate script as it isn't as simple as copying files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# dotfiles top level dir in repo
CONFIG_DIR="$SCRIPT_DIR/../configs"
POST_INSTALL_DIR="$SCRIPT_DIR/../post_install"
POST_INSTALL_SCRIPT_SUFFIX="_post_install.sh"
EXCLUDE_DIR="$SCRIPT_DIR/../exclude"
EXCLUDE_FILE_SUFFIX=".exclude"

# Mapping between config name and package name (if they differ)
# (allows multiple as different package managers could have different names)
declare -A CONFIG_BIN_MAP=(
    [.tmux.conf]="tmux"
    [pip]="python3-pip pip3"
)

# colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no colour

TOP_BORDER="${PURPLE}-------------------------------- Apply Dotfiles --------------------------------${NC}"
BOTTOM_FAILED_BORDER="${PURPLE}--------------------------------------------------------------------------------${NC}"
BOTTOM_SUCCESSFUL_BORDER="${PURPLE}-------------------------------- Dotfiles applied! -----------------------------${NC}"

# map src_conf path in repo -> target_conf path in $HOME
get_target_conf() {
    local src_conf="$1"
    local rel_path="${src_conf#"$CONFIG_DIR"/}"
    echo "$HOME/$rel_path"
}

echo -e "$TOP_BORDER"
read -r -p "Existing config files will be overwritten, but you will get the option to make backups. Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
    echo -e "${RED}Stopping script...${NC}"
    echo -e "$BOTTOM_FAILED_BORDER"
    exit 1
fi

while true; do
    read -r -p "Do you want to make backups of your existing files? (y/n): " backup_input
    case "$backup_input" in
    [Yy])
        backup=true
        break
        ;;
    [Nn])
        backup=false
        break
        ;;
    *) echo -e "${YELLOW}Please answer yes (y) or no (n).${NC}" ;;
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
    printf "%2d) %s\n" "$((i + 1))" "$name"
done

# ask user for selection(s)
echo
echo -e "${YELLOW}Enter numbers separated by spaces (e.g. 1 3 5) or 'a' for all ('q' to quit):${NC}"
read -r -p "" selection
echo

# quit option
if [[ "$selection" =~ ^[Qq]$ ]]; then
    echo -e "${RED}Stopping script...${NC}"
    echo -e "$BOTTOM_FAILED_BORDER"
    exit 0
fi

# convert selection into array
selected=()
if [[ "$selection" =~ ^[Aa]$ ]]; then
    selected=("${configs[@]}")
else
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && ((num >= 1 && num <= ${#configs[@]})); then
            selected+=("${configs[$((num - 1))]}")
        else
            echo -e "${RED}Invalid selection: $num${NC}"
        fi
    done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
    echo -e "${RED}No configs selected. Stopping script...${NC}"
    echo -e "$BOTTOM_FAILED_BORDER"
    exit 1
fi

for src_conf in "${selected[@]}"; do
    echo
    target_conf="$(get_target_conf "$src_conf")"
    name="$(basename "$src_conf")"
    post_install_script_name="$name$POST_INSTALL_SCRIPT_SUFFIX"
    post_install_script="$POST_INSTALL_DIR/$post_install_script_name"

    # check if program is installed
    # use $name as package name, unless there is an override in $CONFIG_BIN_MAP
    echo -e "${BLUE}Checking if program for '$name' config is installed...${NC}"
    required_bins="${CONFIG_BIN_MAP[$name]:-$name}"

    installed=false
    for bin in $required_bins; do
        # check all the possible bin variations to see if one is installed
        if command -v "$bin" >/dev/null 2>&1; then
            installed=true
            break
        fi
    done
    # if it isn't installed, offer to install
    if [[ "$installed" == false ]]; then
        read -r -p "This config ($name) is for a program that isn't installed. Do you want to install it? (y/n): " install_input
        if [[ ! $install_input =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Skipping install...${NC}"
        else
            install_successful=false
            # try all possible bin names
            for bin in $required_bins; do
                echo -e "${BLUE}Trying to install package $bin...${NC}"
                "$SCRIPT_DIR"/util/install_package.sh "$bin" || {
                    echo -e "${YELLOW}Couldn't install package with name: $bin - checking if alternate package names exist${NC}"
                    continue
                }
                # gets here if error handling above doesn't trigger, meaning the package installed
                echo -e "${GREEN}Package $bin installed!${NC}"
                install_successful=true
                break
            done

            if [[ "$install_successful" == false ]]; then
                echo -e "${YELLOW}Warning: Couldn't install package for '$name' config - setting config anyway...${NC}"
            fi
        fi
    else
        echo -e "${GREEN}Program for '$name' config is already installed.${NC}"
    fi

    # handle config directory
    if [[ -d "$src_conf" ]]; then
        if [[ "$backup" == true ]]; then
            echo -e "${PURPLE}Backing up $name config...${NC}"
            "$SCRIPT_DIR"/util/backup_dir.sh "$target_conf"
        fi

        echo -e "${BLUE}Applying $name config...${NC}"
        mkdir -p "$target_conf"

        # check for an exclude file
        exclude_file="$EXCLUDE_DIR/$name$EXCLUDE_FILE_SUFFIX"
        if [[ -f "$exclude_file" ]]; then
            rsync -a --delete --exclude-from="$exclude_file" "$src_conf"/ "$target_conf"/
        else
            rsync -a --delete "$src_conf"/ "$target_conf"/
        fi
        echo -e "${GREEN}Applied $name config!${NC}"

    # handle config file
    elif [[ -f "$src_conf" ]]; then
        if [[ "$backup" == true ]]; then
            echo -e "${CYAN}Backing up $name config...${NC}"
            "$SCRIPT_DIR"/util/backup_file.sh "$target_conf"
        fi

        echo -e "${BLUE}Applying $name config...${NC}"
        cp -f "$src_conf" "$target_conf"
        echo -e "${GREEN}Applied $name config!${NC}"
    fi

    # run post install script if it exists
    if [[ -f "$post_install_script" ]]; then
        echo -e "${CYAN}Post-install script for $name config found. Running...${NC}"
        bash "$post_install_script"
        echo -e "${GREEN}Post-install script complete!${NC}"
    fi
done

echo -e "$BOTTOM_SUCCESSFUL_BORDER"
