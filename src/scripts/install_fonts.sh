#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONTS_DIR="$HOME/.fonts"

# colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no colour

TOP_BORDER="${PURPLE}-------------------------------- Install Fonts ---------------------------------${NC}"
BOTTOM_FAILED_BORDER="${PURPLE}--------------------------------------------------------------------------------${NC}"
BOTTOM_SUCCESSFUL_BORDER="${PURPLE}------------------------------- Fonts Installed! -------------------------------${NC}"

echo -e "$TOP_BORDER"

read -r -p "This script will install fonts to your ~/.fonts directory - Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo -e "${RED}Stopping script...${NC}"
	echo -e "$BOTTOM_FAILED_BORDER"
	exit 1
fi

echo -e "${BLUE}Installing fonts to ${FONTS_DIR}${NC}"
# if it doesn't exist, create .fonts
mkdir -p "$FONTS_DIR"

fontlist=$(find "$SCRIPT_DIR/../fonts" -name '*.tar.gz')
for font in $fontlist; do
	name=$(basename "$font" .tar.gz)
	target="$FONTS_DIR/$name"
	if [[ ! -d "$target" ]]; then
		mkdir "$target"
		tar -xzf "$font" -C "$FONTS_DIR"
		echo -e "${GREEN}$name font installed${NC}"
	else
		echo -e "${YELLOW}Failed to install $name font, directory already exists in $FONTS_DIR. Skipping...${NC}"
	fi
done

echo -e "$BOTTOM_SUCCESSFUL_BORDER"
