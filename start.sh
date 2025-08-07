#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

# filenames to exclude - these are util scripts not for users
EXCLUDE=("backup_dir.sh" "backup_file.sh")

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

# display menu using basenames
PS3="Run a script: "
select choice in "${DISPLAY_NAMES[@]}"; do
    if [[ -n "$choice" ]]; then
        index=$((REPLY - 1))
        selected="${FULL_PATHS[$index]}"

        echo "Running: $choice"
        /bin/bash "$selected"
        echo "Script complete!"
        break
    else
        echo "Invalid selection."
    fi
done
