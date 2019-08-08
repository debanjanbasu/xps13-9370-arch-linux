#!/bin/sh

# Author : Debanjan Basu <debanjanbasu2006@gmail.com>
# Copyright (c) Debanjan Basu
# Script follows here:

echo "Please ensure that you have wifi configured and the partitions formatted. Refer to original Arch Installation wiki please."

# Running sfdisk and creating the partitions
echo "Fomatting disk now...\n"
mkfs.fat -F32 /dev/nvme0n1p1
yes | mkfs.ext4 /dev/nvme0n1p2 -L ROOT
mkswap /dev/nvme0n1p3 -L SWAP
swapon --discard /dev/nvme0n1p3

# Enabling Wifi Auto Connect
echo "Enabling Wifi Auto Connect...\n"
systemctl enable netctl-auto@wlp2s0

# Configure for further installation
echo "Configuring final before arch installation...\n"

timedatectl set-ntp true

mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# pacstrapping Arch Linux
echo "Strapping on base and base-devel arch installation (some additional packages too)...\n"

pacstrap /mnt base base-devel dialog ifplugd wpa_supplicant sudo intel-ucode git neovim \
xf86-input-libinput xf86-video-intel vulkan-intel ttf-font util-linux

genfstab -L /mnt >>/mnt/etc/fstab
arch-chroot /mnt
