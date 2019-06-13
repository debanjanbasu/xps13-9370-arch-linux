#!/bin/sh

# Author : Debanjan Basu <debanjanbasu2006@gmail.com>
# Copyright (c) Debanjan Basu
# Script follows here:

echo "Please ensure that you have wifi configured and the partitions formatted. Refer to original Arch Installation wiki please."

# Running sfdisk and creating the partitions
echo "Fomatting disk now...\n"
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2 -L ROOT
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

pacstrap /mnt base base-devel dialog ifplugd wpa_suppicant sudo intel-ucode git neovim \
xf86-input-libinput xf86-video-intel systemd-boot-pacman-hook vulkan-intel ttf-font util-linux

genfstab -L /mnt >>/mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc

# Uncomment in /etc/locale.gen --> en_US.UTF-8 UTF-8
sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

# Add in /etc/locale.conf
echo LANG=en_US.UTF-8 >/etc/locale.conf
locale-gen

# Updating and creating hostnames
echo "Updating hostname and hosts...\n"
MYHOSTNAME = "debxps13"

echo "$MYHOSTNAME" >/etc/hostname
# Add to hosts
cat <<EOT >>/etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 $MYHOSTNAME.localdomain $MYHOSTNAME
EOT

echo "Type the root user password that you want to use, followed by [ENTER] (same password for custom user):\n"
read npasswd
echo "root:$npasswd" | chpasswd
useradd -m -g users -G wheel debanjanbasu
echo "debanjanbasu:$npasswd" | chpasswd
echo "Adding custom user to sudoers...\n"
echo 'debanjanbasu ALL=(ALL) ALL' >/etc/sudoers.d/debanjanbasu

# Boot Loader install and config
echo "Installing the boot loader...\n"

bootctl install

cat <<EOT >>/boot/loader/loader.conf
default  arch
editor   no
EOT

cat <<EOT >>/boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options quiet mem_sleep_default=deep
EOT

# Section to turn on trim and reduced reserved block
echo "Optimizing disks TRIM and noatime..."
tune2fs -m 1 -o discard,noatime /dev/nvme0n1
sed 's/\<relatime,\>//g' /etc/fstab
