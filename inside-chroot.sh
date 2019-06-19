    
#!/bin/sh

# Author : Debanjan Basu <debanjanbasu2006@gmail.com>
# Copyright (c) Debanjan Basu
# Script follows here:

ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc

# Uncomment in /etc/locale.gen --> en_US.UTF-8 UTF-8
sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

# Add in /etc/locale.conf
echo LANG=en_US.UTF-8 >/etc/locale.conf
locale-gen

# Updating and creating hostnames
echo "Updating hostname and hosts..."

MYHOSTNAME=debxps13

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
options root=LABEL=ROOT quiet mem_sleep_default=deep
EOT

