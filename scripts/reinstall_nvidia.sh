#! /bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Re-installing Nvidia drivers"
dnf remove -y \*nvidia\* --exclude nvidia-gpu-firmware
dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

echo "Wait for kernel module to compile before restarting - 'modinfo -f version nvidia' should return the module version after it is compiled"
