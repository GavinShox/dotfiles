#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

echo -e "${BLUE}Installing tmux...${NC}"
sudo dnf install --refresh -y tmux
echo -e "${BLUE}Cloning tmux plugin manager...${NC}"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo -e "${BLUE}Copying tmux configuration...${NC}"
cp -fb "$SCRIPT_DIR"/../configs/.tmux.conf "$HOME"/.tmux.conf
echo -e "${BLUE}Setting up tmux server...${NC}"
# launch tmux server to reload conf
tmux new -d
tmux source "$HOME"/.tmux.conf
tmux kill-server
echo -e "${GREEN}.tmux.conf backup made at ${HOME}/.tmux.conf~${NC}"
echo -e "${GREEN}Config complete! Launch tmux and press 'prefix (Ctrl+s) + I' to install plugins${NC}"
echo -e "$BOTTOM_SUCCESSFUL_BORDER"
