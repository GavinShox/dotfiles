#! /bin/bash

echo "-------------------------------- Reinstall Nvidia Drivers --------------------------------"

read -r -p "This script will reinstall your Nvidia drivers. It requires sudo privileges - Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo "Stopping script..."
	exit 1
fi

echo "Removing all nvidia drivers, excluding nvidia-gpu-firmware"
echo "Trying to execute: 'sudo dnf remove -y \*nvidia\* --exclude nvidia-gpu-firmware'"

sudo dnf remove -y \*nvidia\* --exclude nvidia-gpu-firmware || {
	echo "Error: Couldn't execute command with sudo. Exiting...";
	echo "---------------------------------------------------------------------------------------------";
	exit 1;
}

echo "Reinstalling nvidia drivers and nvidia-smi"
echo "Trying to execute: 'sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda'"
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda || {
	echo "Error: Couldn't execute command with sudo. Please run the given reinstall command to get the nvidia drivers. Exiting...";
	echo "---------------------------------------------------------------------------------------------";
	exit 1;
}

echo "Done!"
echo "Wait for kernel module to compile before restarting - 'modinfo -f version nvidia' should return the module version after it is compiled, or watch for an 'akmods' process to complete"
echo "-------------------------------- Nvidia Drivers Reinstalled! --------------------------------"

