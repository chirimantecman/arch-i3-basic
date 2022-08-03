#!/usr/bin/bash

##
## Very naive and basic script to setup a basic Archlinux box with i3
## in Virtualbox and the fundamental apps and graphical environment.
##

## Let's follow the install guide, shall we?...


## CONFIGURATION OPTIONS
KEYBOARD='la-latin1';
PACSTRAP_LIST_FILE='pacstrap-packages';
cat <<EOT >> $PACSTRAP_LIST_FILE
base
base-devel
linux
linux-firmware
parted
reflector
cryptsetup
curl
dhcpcd
gnupg
iw
iwd
kbd
keyutils
man-db
man-pages
texinfo
nano
perl
python
sudo
xorg-server
zsh
i3-gaps
emacs
polybar
rofi
lightdm
lightdm-slick-greeter
rxvt-unicode
libreoffice-fresh
gucharmap
epdfview
picom
feh
ispell
hunspell
hunspell-en_us
hunspell-es_cl
virtualbox-guest-utils
xorg-server-xephyr
wget
xorg-xrdb
xterm
grub
efibootmgr
EOT

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
pacstrap /mnt - < $PACSTRAP_LIST_FILE;


## FSTAB.
genfstab -U /mnt >> /mnt/etc/fstab;


## CHROOT.
cp files.tar.gz /mnt/root;
cp chiri-arch-i3-basic-install-chroot.sh /mnt/root;
chmod +x /mnt/root/chiri-arch-i3-basic-install-chroot.sh;
arch-chroot /mnt /root/chiri-arch-i3-basic-install-chroot.sh;
#umount -R /mnt;
#reboot;
