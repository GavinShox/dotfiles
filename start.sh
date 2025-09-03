#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

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

echo "================================ Utility Scripts ================================"

# allow for multiple scripts to be run in succession without re-launching the script
while true; do
	echo "Available scripts:"
	echo

	for i in "${!DISPLAY_NAMES[@]}"; do
	    printf "%2d) %s\n" $((i+1)) "${DISPLAY_NAMES[$i]}"
	done

	echo
	echo "Press number to run a script, or 'q' to quit."

	# read a single key without requiring Enter
    read -r -n1 -s input
    echo

	if [[ "$input" =~ [Qq] ]]; then
		echo "Exiting..."
		break
	elif [[ "$input" =~ ^[0-9]$ ]] && (( input >= 1 && input <= ${#DISPLAY_NAMES[@]} )); then
		index=$((input-1))
        selected="${FULL_PATHS[$index]}"

        echo "Running: ${DISPLAY_NAMES[$index]}"
        /bin/bash "$selected"
	else
		echo "Invalid input: $input"
	fi
done

echo "================================================================================="
