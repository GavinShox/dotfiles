#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/src/scripts"

# colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no colour

TOP_BORDER="${PURPLE}================================ Utility Scripts ================================${NC}"
BOTTOM_BORDER="${PURPLE}=================================================================================${NC}"

# file/dir names to exclude - these are util scripts not for users
EXCLUDE=("util")

# one for full paths (for execution), one for basenames (for display)
FULL_PATHS=()
DISPLAY_NAMES=()

# loop through scripts and filter out excluded ones
for f in "$SCRIPTS_DIR"/*; do
    filename=$(basename "$f")

    # skip if in exclude list
    skip=false
    for ex in "${EXCLUDE[@]}"; do
        if [[ "$filename" == "$ex" ]]; then
            skip=true
            break
        fi
    done

    # if not skipped, add to both arrays
    if ! $skip; then
        FULL_PATHS+=("$f")
        DISPLAY_NAMES+=("$filename")
    fi
done

echo -e "$TOP_BORDER"

# allow for multiple scripts to be run in succession without re-launching the script
while true; do
    echo "Available scripts:"
    echo

    for i in "${!DISPLAY_NAMES[@]}"; do
        printf "%2d) %s\n" $((i + 1)) "${DISPLAY_NAMES[$i]}"
    done

    echo
    echo -e "${YELLOW}Press number to run a script, or 'q' to quit.${NC}"

    # read a single key without requiring Enter
    read -r -n1 -s input
    echo

    if [[ "$input" =~ [Qq] ]]; then
        echo -e "${RED}Exiting...${NC}"
        break
    elif [[ "$input" =~ ^[0-9]$ ]] && ((input >= 1 && input <= ${#DISPLAY_NAMES[@]})); then
        index=$((input - 1))
        selected="${FULL_PATHS[$index]}"

        echo -e "${BLUE}Running: ${DISPLAY_NAMES[$index]}${NC}"
        /bin/bash "$selected"
    else
        echo -e "${RED}Invalid input: $input${NC}"
    fi
done

echo -e "$BOTTOM_BORDER"
