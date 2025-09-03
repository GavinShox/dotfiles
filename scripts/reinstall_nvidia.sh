#! /bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "-------------------------------- Reinstall Nvidia Drivers --------------------------------"
echo "Removing all nvidia drivers, excluding nvidia-gpu-firmware"
dnf remove -y \*nvidia\* --exclude nvidia-gpu-firmware
echo "Reinstalling nvidia drivers and nvidia-smi"
dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

echo "Wait for kernel module to compile before restarting - 'modinfo -f version nvidia' should return the module version after it is compiled"
echo "-------------------------------- Nvidia Drivers Reinstalled! --------------------------------"
