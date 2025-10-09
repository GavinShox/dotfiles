#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/util/install_package.sh"

# colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no colour

TOP_BORDER="${PURPLE}----------------------------- Install & Setup Tmux -----------------------------${NC}"
BOTTOM_FAILED_BORDER="${PURPLE}--------------------------------------------------------------------------------${NC}"
BOTTOM_SUCCESSFUL_BORDER="${PURPLE}----------------------------- Finished Tmux Setup! -----------------------------${NC}"

echo -e "$TOP_BORDER"

read -r -p "This script will install tmux and plugin manager from repo: <https://github.com/tmux-plugins/tpm> - Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo -e "${RED}Stopping script...${NC}"
	echo -e "$BOTTOM_FAILED_BORDER"
	exit 1
fi

# install dependencies (for loop to keep consistent with other scripts in the future)
for cmd in git; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}Dependency ($cmd) already installed...${NC}"
    else
        echo -e "${BLUE}Missing dependency ($cmd). Attempting to install...${NC}"
        if sudo "$INSTALL_SCRIPT" "$cmd" >/dev/null 2>&1; then
            echo -e "${GREEN}Dependency ($cmd) installed!${NC}"
        else
            echo -e "${RED}Error: Failed to install $cmd. Exiting...${NC}"
            echo -e "$BOTTOM_FAILED_BORDER"
            exit 1
        fi
    fi
done

# tmux install
if command -v tmux >/dev/null 2>&1; then
    echo -e "${GREEN}tmux already installed...${NC}"
else
    echo -e "${BLUE}Installing tmux...${NC}"
    if sudo "$INSTALL_SCRIPT" tmux >/dev/null 2>&1; then
        echo -e "${GREEN}tmux installed!${NC}"
    else
        echo -e "${RED}Error: Failed to install tmux. Exiting..."
        echo -e "$BOTTOM_FAILED_BORDER"
        exit 1
    fi
fi

# install plugin manager
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    echo -e "${YELLOW}tmux plugin manager already exists at $TPM_DIR. Skipping clone...${NC}"
else
    echo -e "${BLUE}Cloning tmux plugin manager...${NC}"
    if ! git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
        echo -e "${RED}Error: Failed to clone tmux plugin manager. Exiting...${NC}"
        echo -e "$BOTTOM_FAILED_BORDER"
        exit 1
    fi
fi

# copy .tmux.conf
echo -e "${BLUE}Copying tmux configuration...${NC}"
if ! cp -fb "$SCRIPT_DIR"/../configs/.tmux.conf "$HOME"/.tmux.conf; then
    echo -e "${RED}Error: Failed to copy tmux config file. Exiting...${NC}"
    echo -e "$BOTTOM_FAILED_BORDER"
    exit 1
fi

# start tmux server and reload config
echo -e "${BLUE}Setting up tmux server...${NC}"
if tmux new -d; then
    tmux source "$HOME"/.tmux.conf || echo -e "${YELLOW}Warning: Could not source .tmux.conf.${NC}"
    tmux kill-server || true
fi

echo -e "${GREEN}.tmux.conf backup made at ${HOME}/.tmux.conf~${NC}"
echo -e "${GREEN}Config complete! Launch tmux and press 'prefix (Ctrl+s) + I' to install required plugins.${NC}"
echo -e "$BOTTOM_SUCCESSFUL_BORDER"
