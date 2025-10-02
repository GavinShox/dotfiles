#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STARSHIP_CONFIG_FILE="$HOME/.config/starship.toml"
STARSHIP_THEMES_DIR="$SCRIPT_DIR/../starship_themes/"

# colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no colour

TOP_BORDER="${PURPLE}----------------------------- Apply Starship Theme -----------------------------${NC}"
BOTTOM_FAILED_BORDER="${PURPLE}--------------------------------------------------------------------------------${NC}"
BOTTOM_SUCCESSFUL_BORDER="${PURPLE}-------------------------------- Theme Applied! --------------------------------${NC}"

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

echo -e "$TOP_BORDER"

while true; do
    echo "Available themes:"
    echo

    for i in "${!DISPLAY_NAMES[@]}"; do
        printf "%2d) %s\n" "$((i + 1))" "${DISPLAY_NAMES[$i]}"
    done

    echo
    echo -e "${YELLOW}Press number to apply a theme, or 'q' to quit.${NC}"
    read -r -p "" input
    echo

    if [[ "$input" =~ ^[Qq]$ ]]; then
        echo -e "${RED}Stopping script...${NC}"
        echo -e "$BOTTOM_FAILED_BORDER"
        exit 0
    elif [[ "$input" =~ ^[0-9]+$ ]] && ((input >= 1 && input <= ${#DISPLAY_NAMES[@]})); then
        index=$((input - 1))
        choice="${DISPLAY_NAMES[$index]}"
        selected="${FULL_PATHS[$index]}"
        echo -e "${BLUE}Applying $choice...${NC}"
        "$SCRIPT_DIR"/util/backup_file.sh "$STARSHIP_CONFIG_FILE"
        cp -f "$selected" "$STARSHIP_CONFIG_FILE"
        echo -e "${GREEN}Applied $choice!${NC}"
        break
    else
        echo -e "${RED}Invalid selection. Please enter a number from the list or 'q' to quit.${NC}"
    fi
done

echo -e "$BOTTOM_SUCCESSFUL_BORDER"
