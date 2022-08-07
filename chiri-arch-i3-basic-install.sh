#!/usr/bin/bash

##
## Very naive and basic script to setup a basic Archlinux box with i3
## in Virtualbox and the fundamental apps and graphical environment.
##

## Let's follow the install guide, shall we?...


## CONFIGURATION OPTIONS
KEYBOARD='la-latin1';

# Partition configuration.  Follows the sfdisk script file format.
BOOT_PARTITION_FILE="./boot-partition";
SWAP_PARTITION_FILE="./swap-partition";
LINUX_PARTITION_FILE="./linux-partition";
echo "size=300MiB, bootable, type=uefi" > $BOOT_PARTITION_FILE;
echo "size=512MiB, type=swap" > $SWAP_PARTITION_FILE;
echo "type=linux" > $LINUX_PARTITION_FILE;

# Packages.
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
git
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


## PARTITION DISK, MAKE AND MOUNT FILESYSTEMS.
# This piece of code checks whether there are existing partitions,
# their type, label type, etc.  And creates the new ones based on
# missing ones.  It does not currently alter the existing ones but
# leaves them as is.
if [[ -a /proc/partitions ]]; then
    # See whether machine was booted in UEFI mode.
    UEFI_BOOT=0;
    if [[ -a /sys/firmware/efi/fw_platform_size ]]; then UEFI_BOOT=1; fi;
    
    # Detect first disk's name.
    echo "Detecting first disk device..."
    DISK=`sed -n '3l' /proc/partitions | tr -s " " | cut -d " " -f 5 | cut -c 1-3`;
    if [[ -z $DISK ]]; then
        echo "No devices or partitions listed in /proc/partitions. Exiting.";
        exit 1;
    else
        echo "First disk device is: $DISK";

        # Check if disk has label type and detect.
        echo "Inspecting existing partitions and disk label..."
        HAS_LABEL=`fdisk -l /dev/$DISK | grep -E 'gpt|dos'`;
        if [[ ! -z $HAS_LABEL ]]; then
            IS_GPT=`echo $HAS_LABEL | grep -c 'gpt'`;

            # Check partitions.
            if [[ $IS_GPT -gt 0 ]]; then
                echo "Disk label type is: GPT";

                BOOT_PARTITION=`fdisk -l /dev/$DISK | grep -E "$DISK[0-9].*EFI" | cut -d " " -f 1`;
                if [[ -z $BOOT_PARTITION ]]; then
                    echo "No EFI partition detected, creating...";
                    cat $BOOT_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;
                    BOOT_PARTITION_STRLEN=`echo $BOOT_PARTITION | wc -m`;
                    BOOT_PARTITION_NUM=`echo $BOOT_PARTITION | cut -c $(( $BOOT_PARTITION_STRLEN - 1 ))`;
                    set $BOOT_PARTITION_NUM esp on;
                    echo "Making filesystem for EFI partition...";
                    mkfs.fat -F 32 /dev/$DISK$BOOT_PARTITION_NUM;
                    echo "DONE";
                else
                    echo "Existing EFI partition detected.";
                    BOOT_PARTITION_STRLEN=`echo $BOOT_PARTITION | wc -m`;
                    BOOT_PARTITION_NUM=`echo $BOOT_PARTITION | cut -c $(( $BOOT_PARTITION_STRLEN - 1 ))`;
                fi;
            else
                echo "Disk label type is: DOS";
            fi;

            SWAP_PARTITION=`fdisk -l /dev/$DISK | grep -E "$DISK[0-9].*swap" | cut -d " " -f 1`;
            if [[ -z $SWAP_PARTITION ]]; then
                echo "No SWAP partition detected, creating...";
                cat $SWAP_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;
                SWAP_PARTITION_STRLEN=`echo $SWAP_PARTITION | wc -m`;
                SWAP_PARTITION_NUM=`echo $SWAP_PARTITION | cut -c $(( $SWAP_PARTITION_STRLEN - 1 ))`;
                echo "Making filesystem for SWAP partition...";
                mkswap /dev/$DISK$SWAP_PARTITION_NUM;
                echo "DONE";
            else
                echo "Existing SWAP partition detected.";
                SWAP_PARTITION_STRLEN=`echo $SWAP_PARTITION | wc -m`;
                SWAP_PARTITION_NUM=`echo $SWAP_PARTITION | cut -c $(( $SWAP_PARTITION_STRLEN - 1 ))`;
            fi;

            LINUX_PARTITION=`fdisk -l /dev/$DISK | grep -E "$DISK[0-9].*Linux" | grep -v 'swap' | cut -d " " -f 1 | head -n 1`;
            if [[ -z $LINUX_PARTITION ]]; then
                echo "No LINUX partition detected, creating...";
                cat $LINUX_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;
                LINUX_PARTITION_STRLEN=`echo $LINUX_PARTITION | wc -m`;
                LINUX_PARTITION_NUM=`echo $LINUX_PARTITION | cut -c $(( $LINUX_PARTITION_STRLEN - 1 ))`;
                echo "Making filesystem for LINUX partition...";
                mkfs.ext4 /dev/$DISK$LINUX_PARTITION_NUM;
                echo "DONE";
            else
                echo "Existing LINUX partition detected.";
                LINUX_PARTITION_STRLEN=`echo $LINUX_PARTITION | wc -m`;
                LINUX_PARTITION_NUM=`echo $LINUX_PARTITION | cut -c $(( $LINUX_PARTITION_STRLEN - 1 ))`;
            fi;

            # Mount the filesystems.
            echo "Mounting filesystems...";
            if ! cat /proc/mounts | grep -q "/dev/$DISK$LINUX_PARTITION_NUM"; then
                mount --mkdir /dev/$DISK$LINUX_PARTITION_NUM /mnt;
            fi;
            if ! cat /proc/mounts | grep -q "/dev/$DISK$BOOT_PARTITION_NUM"; then
                mount --mkdir /dev/$DISK$BOOT_PARTITION_NUM /mnt/boot;
            fi;
            if ! swapon -s | grep -q "/dev/$DISK$SWAP_PARTITION_NUM"; then
                swapon /dev/$DISK$SWAP_PARTITION_NUM;
            fi;
            echo "DONE";
        else
            
            # No prior label or partitions.
            echo "No partitions or type label detected, creating...";
            if [[ UEFI_BOOT -gt 0 ]]; then
                parted /dev/sda mklabel gpt;
                cat $BOOT_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;
                cat $SWAP_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;
                cat $LINUX_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;

                # Make the filesystems.
                echo "Making filesystem for partitions...";
                mkfs.fat -F 32 /dev/$DISK\1;
                mkswap /dev/$DISK\2;
                mkfs.ext4 /dev/$DISK\3;
                echo "DONE";

                # Mount the filesystems.
                echo "Mounting filesystems...";
                if ! cat /proc/mounts | grep -q "/dev/$DISK[3]"; then
                    mount --mkdir /dev/$DISK\3 /mnt;
                fi;
                if ! cat /proc/mounts | grep -q "/dev/$DISK[1]"; then
                    mount --mkdir /dev/$DISK\1 /mnt/boot;
                fi;
                if ! swapon -s | grep -q "/dev/$DISK\2"; then
                    swapon /dev/$DISK\2;
                fi;
                echo "DONE";
            else
                parted /dev/sda mklabel msdos;
                cat $SWAP_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;
                cat $LINUX_PARTITION_FILE | sfdisk --append --lock /dev/$DISK;

                # Make the filesystems.
                echo "Making filesystem for partitions...";
                mkswap /dev/$DISK\1;
                mkfs.ext4 /dev/$DISK\2;
                echo "DONE";

                # Mount the filesystems.
                echo "Mounting filesystems...";
                if ! cat /proc/mounts | grep -q "/dev/$DISK[2]"; then
                    mount --mkdir /dev/$DISK\2 /mnt;
                fi;
                if ! swapon -s | grep -q "/dev/$DISK[1]"; then
                    swapon /dev/$DISK\1;
                fi;
                echo "DONE";
            fi;
        fi;
    fi;
else
    echo "/proc/partitions not found. Exiting.";
    exit 1;
fi;


## SELECT MIRRORS AND INSTALL BASE SYSTEM.
# Pacman packages.
reflector --latest 15 --country "United States",Chile --protocol https,http --sort rate --save /etc/pacman.d/mirrorlist;
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
