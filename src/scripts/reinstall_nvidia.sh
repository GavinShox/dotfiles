#! /bin/bash

# colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no colour

TOP_BORDER="${PURPLE}--------------------------- Reinstall Nvidia Drivers ---------------------------${NC}"
BOTTOM_FAILED_BORDER="${PURPLE}--------------------------------------------------------------------------------${NC}"
BOTTOM_SUCCESSFUL_BORDER="${PURPLE}------------------------- Nvidia Drivers Reinstalled! --------------------------${NC}"

echo -e "$TOP_BORDER"

read -r -p "This script will reinstall your Nvidia drivers. It requires sudo privileges - Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo -e "${RED}Stopping script...${NC}"
	echo -e "$BOTTOM_FAILED_BORDER"
	exit 1
fi

echo -e "${BLUE}Removing all nvidia drivers, excluding nvidia-gpu-firmware${NC}"
echo -e "${BLUE}Trying to execute: 'sudo dnf remove -y \\*nvidia\\* --exclude nvidia-gpu-firmware'${NC}"

sudo dnf remove -y \*nvidia\* --exclude nvidia-gpu-firmware || {
	echo -e "${RED}Error: Couldn't execute command with sudo. Exiting...${NC}"
	echo -e "$BOTTOM_FAILED_BORDER"
	exit 1
}

echo -e "${BLUE}Reinstalling nvidia drivers and nvidia-smi${NC}"
echo -e "${BLUE}Trying to execute: 'sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda'${NC}"
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda || {
	echo -e "${RED}Error: Couldn't execute command with sudo. Please run the given reinstall command to get the nvidia drivers. Exiting...${NC}"
	echo -e "$BOTTOM_FAILED_BORDER"
	exit 1
}

echo -e "${GREEN}Done!${NC}"
echo -e "${YELLOW}Wait for kernel module to compile before restarting - 'modinfo -f version nvidia' should return the module version after it is compiled, or watch for an 'akmods' process to complete${NC}"
echo -e "$BOTTOM_SUCCESSFUL_BORDER"
