#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/src/configs"
EXCLUDE_DIR="$SCRIPT_DIR/src/exclude"
EXCLUDE_FILE_SUFFIX=".exclude"

# colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no colour

TOP_BORDER="${PURPLE}============================== Update Current Configs ===============================${NC}"
BOTTOM_FAILED_BORDER="${PURPLE}=====================================================================================${NC}"
BOTTOM_SUCCESSFUL_BORDER="${PURPLE}============================= Current Configs Updated! ==============================${NC}"

# function to map target path in repo -> src path in $HOME
get_src_conf() {
    local repo_conf="$1"
    local rel_path="${repo_conf#"$CONFIG_DIR"/}"
    echo "$HOME/$rel_path"
}

echo -e "$TOP_BORDER"
read -r -p "Existing config files in this repo will be overwritten. Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
    echo -e "${RED}Exiting script...${NC}"
    echo -e "$BOTTOM_FAILED_BORDER"
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
        continue # not a file or directory
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
                    continue # not a file or directory
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
echo -e "${CYAN}Available configs that can be updated:${NC}"
echo
for i in "${!configs[@]}"; do
    # remove prefix to display to user
    name="$(basename "${configs[$i]}")"
    printf "%2d) %s\n" "$((i + 1))" "$name"
done

# ask user for selection(s)
echo
read -r -p "Enter numbers separated by spaces (e.g. 1 3 5) or 'a' for all ('q' to quit): " selection
echo

# quit option
if [[ "$selection" =~ ^[Qq]$ ]]; then
    echo -e "${RED}Exiting script...${NC}"
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
    echo -e "${RED}No configs selected. Exiting script...${NC}"
    echo -e "$BOTTOM_FAILED_BORDER"
    exit 1
fi

# function to check for differences and prompt user, 0: save, 1: skip, 2: answered no, skip
check_diff() {
    local src="$1"
    local target="$2"
    local name="$3"

    local exclude_file="$EXCLUDE_DIR/$name$EXCLUDE_FILE_SUFFIX"
    local exclude_args=()

    # find exclude args if an exclude file exists, as those files/dirs won't be copied in the rsync
    if [[ -f "$exclude_file" ]]; then
        while IFS= read -r pattern; do
            [[ -n "$pattern" ]] || continue
            exclude_args+=(-not -path "$src/$pattern" -not -path "$target/$pattern")
        done < "$exclude_file"
    fi

    local has_diff=false

    # walk all files in $src and compare with $target
    while IFS= read -r file; do
        rel="${file#$src/}"  # relative path
        src_file="$src/$rel"
        target_file="$target/$rel"

        if [[ -f "$target_file" ]]; then
            if ! diff "$target_file" "$src_file" >/dev/null 2>&1; then
                has_diff=true
                echo "Diff for $rel:"
                # pick diff based on support for --color flag
                if diff --help 2>&1 | grep -q -- '--color'; then
                    diff --color=auto "$target_file" "$src_file"
                else
                    diff "$target_file" "$src_file"
                fi
                echo
            fi
        fi
    done < <(find "$src" -type f "${exclude_args[@]}")

    if [[ "$has_diff" == false ]]; then
         # no differences found, skip
        return 1
    fi
    # differences found (echoed in above while loop above) so prompt
    while true; do
        read -r -p "Differences found in $name config. Update repo? (y/n): " input
        case "$input" in
            [Yy]) return 0 ;;
            [Nn]) return 2 ;;
            *) echo -e "${YELLOW}Please answer y or n.${NC}" ;;
        esac
    done
}

for target_conf in "${selected[@]}"; do
    src_conf="$(get_src_conf "$target_conf")"
    name="$(basename "$target_conf")"

    # check diff
    echo -e "${BLUE}Checking differences in $name config...${NC}"
    check_diff "$src_conf" "$target_conf" "$name"
    case $? in
    0)
        # apply config
        ;;
    1)
        echo -e "${YELLOW}Skipping $name config, no differences found between $target_conf and $src_conf...${NC}"
        echo
        continue
        ;;
    2)
        echo -e "${YELLOW}Skipping $name config...${NC}"
        echo
        continue
        ;;
    esac

    # reach here on a 0 return of check_diff
    if [[ -d "$src_conf" ]]; then
        echo -e "${BLUE}Updating $name config...${NC}"
        # mkdir not really needed as the dir has to exist to get here, but just in case...
        mkdir -p "$target_conf"

        # check for exclude file
        exclude_file="$EXCLUDE_DIR/$name$EXCLUDE_FILE_SUFFIX"
        if [[ -f "$exclude_file" ]]; then
            rsync -a --delete --exclude-from="$exclude_file" "$src_conf"/ "$target_conf"/
        else
            rsync -a --delete "$src_conf"/ "$target_conf"/
        fi
        echo -e "${GREEN}Updated $name config!${NC}"

    elif [[ -f "$src_conf" ]]; then
        echo -e "${BLUE}Updating $name config...${NC}"
        cp -f "$src_conf" "$target_conf"
        echo -e "${GREEN}Updated $name config!${NC}"
    fi
done

echo -e "$BOTTOM_SUCCESSFUL_BORDER"
