#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

declare -A osInfo;
osInfo[/etc/redhat-release]="dnf -y install"
osInfo[/etc/arch-release]="pacman --noconfirm -S"
osInfo[/etc/gentoo-release]="emerge -q --ask=n"
osInfo[/etc/SuSE-release]="zypper -n install"
osInfo[/etc/debian_version]="apt-get -y install"
osInfo[/etc/alpine-release]="apk add --no-confirm"

for f in "${!osInfo[@]}"
do
    if [[ -f $f ]]; then
        PACKAGE_MANAGER=${osInfo[$f]}
    fi
done

if [[ -z "$PACKAGE_MANAGER" ]]; then
	echo -e "${RED}Error: Couldn't find package manager. Stopping script...${NC}"
	exit 1
fi

sudo $PACKAGE_MANAGER "$1"
