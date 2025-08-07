#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONTS_DIR=$HOME/.fonts

echo "Installing fonts to ${FONTS_DIR}"
mkdir $FONTS_DIR
find $SCRIPT_DIR/../fonts -name '*.tar.gz'  -exec tar -xvzkf {} -C $FONTS_DIR \;
