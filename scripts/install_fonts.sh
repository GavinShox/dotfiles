#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONTS_DIR="$HOME/.fontstest"

echo "-------------------------------- Install Fonts --------------------------------"

read -r -p "This script will install fonts to your ~/.fonts directory - Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo "Stopping script..."
	"-------------------------------------------------------------------------------"
	exit 1
fi

echo "Installing fonts to ${FONTS_DIR}"
# if it doesn't exist, create .fonts
mkdir -p "$FONTS_DIR"

fontlist=$(find "$SCRIPT_DIR/../fonts" -name '*.tar.gz')
for font in $fontlist; do
	name=$(basename "$font" .tar.gz)
	target="$FONTS_DIR/$name"
	if [[ ! -d "$target" ]]; then
		mkdir "$target"
		tar -xzf "$font" -C "$FONTS_DIR"
		echo "$name font installed"
	else
		echo "Failed to install $name font, directory already exists in $FONTS_DIR. Skipping..."
	fi
done

echo "-------------------------------- Fonts Installed! --------------------------------"
