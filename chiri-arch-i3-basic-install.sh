#!/usr/bin/bash

##
## Very naive and basic script to setup a basic Archlinux box with i3
## in Virtualbox and the fundamental apps and graphical environment.
##

## Let's follow the install guide, shall we?...


## REQUIRED PACKAGES INCLUDED IN LIVE ENVIRONMENT
## curl
## parted
## iw
## reflector
## pacstrap


## CONFIGURATION OPTIONS
KEYBOARD=la-latin1;


## KEYBOARD LAYOUT
## For now just latin-american keyboard.
loadkeys $KEYBOARD;


## INTERNET CONNECTION
## If installing in a virtualbox guest then no config is
## needed yet. Let's assume that for now.


## TIMEDATE
timedatectl set-ntp true;


## PARTITION DISK AND MAKE AND MOUNT FILESYSTEMS.
## This is for a 10GB disk, using GPT and UEFI, 3 partitions:
## boot, swap and root.
parted /dev/sda mklabel gpt;
parted /dev/sda mkpart boot fat32 1049KB 316MB set 1 esp on;
parted /dev/sda mkpart swap linux-swap 316MB 852MB set 2 swap on;
parted /dev/sda mkpart root ext4 852MB 100%;

# Make the filesystems.
mkfs.fat -F 32 /dev/sda1;
mkswap /dev/sda2;
mkfs.ext4 /dev/sda3;

# Mount the filesystems.
mount --mkdir /dev/sda3 /mnt;
mount --mkdir /dev/sda1 /mnt/boot;
swapon /dev/sda2;


## SELECT MIRRORS AND INSTALL BASE SYSTEM.
# Pacman packages.
reflector --save /etc/pacman.d/mirrorlist;
pacman -Syy archlinux-keyring;
pacstrap /mnt base linux linux-firmware parted reflector cryptsetup curl dhcpcd gnupg iw iwd kbd keyutils man-db man-pages texinfo nano perl python sudo xorg-server zsh i3-gaps emacs polybar rofi lightdm lightdm-slick-greeter rxvt-unicode libreoffice-fresh gucharmap epdfview picom feh ispell hunspell hunspell-en_us hunspell-es_cl;

# yay packages.
# waterfox
# lightdm-settings


## FSTAB.
genfstab -U /mnt >> /mnt/etc/fstab;


## CHROOT.
arch-chroot /mnt;


## TIMEZONE AND LOCALE.
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime;
hwclock --systohc;
# echo "en_US.UTF-8 UTF-8" > /etc/locale.gen;
# echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen;
# locale-gen;
# echo "LANG=es_CL.UTF-8" > /etc/locale.conf;
# echo "KEYMAP=la-latin1" > /etc/vconsole.conf;


## NETWORK.
# echo "arch-i3-basic" > /etc/hostname;
# Should enable dhcpd service on reboot.


## USER MANAGEMENT.
# passwd;
# useradd -m -s /usr/bin/zsh chiri;
# passwd chiri;


## BOOT LOADER.
# pacman -S --noconfirm grub efibootmgr;
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB;


## REBOOT.
# exit;
# umount -R /mnt;
# reboot;
