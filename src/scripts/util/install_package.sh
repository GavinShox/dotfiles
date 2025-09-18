#!/bin/bash

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
	echo "Error: Couldn't find package manager. Stopping script..."
	exit 1
fi

sudo $PACKAGE_MANAGER "$1"
