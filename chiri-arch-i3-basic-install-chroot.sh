#!/usr/bin/bash

## TIMEZONE AND LOCALE.
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime;
hwclock --systohc;
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen;
echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen;
locale-gen;
echo "LANG=es_CL.UTF-8" > /etc/locale.conf;
echo "KEYMAP=la-latin1" > /etc/vconsole.conf;
echo "localectl set-x11-keymap latam" > /etc/xprofile;


## NETWORK.
echo "arch-i3-basic" > /etc/hostname;
ln -s /usr/lib/systemd/system/dhcpcd.service /etc/systemd/system/multi-user.target.wants/dhcpcd.service;
ln -s /usr/lib/systemd/system/systemd-resolved.service /etc/systemd/system/dbus-org.freedesktop.resolve1.service;
mkdir /etc/systemd/system/sysinit.target.wants;
ln -s /usr/lib/systemd/system/systemd-resolved.service /etc/systemd/system/sysinit.target.wants/systemd-resolved.service;

## USER MANAGEMENT.
passwd;
useradd -m -s /usr/bin/zsh chiri;
passwd chiri;


## BOOT LOADER.
pacman -S --noconfirm grub efibootmgr;
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB;
grub-mkconfig -o /boot/grub/grub.cfg;


## PREPARE FOR A VIRTUALBOX SHARED FOLDER.
## Currently the vboxservice systemd service will create the /media
## directory.
ln -s /usr/lib/systemd/system/vboxservice.service /etc/systemd/system/multi-user.target.wants/vboxservice.service;
usermod -a -G vboxsf root;
usermod -a -G vboxsf chiri;


## COPY FILES AND SET PERMISSIONS.
tar -xzvf files.tar.gz;
cp -r files/config/home/.config /home/chiri;
cp -r files/config/home/.emacs.d /home/chiri;
cp files/config/home/.xprofile /home/chiri;
cp files/config/home/.Xresources /home/chiri;
chown -R chiri:chiri /home/chiri;
cp -r files/config/etc/X11 /etc;
cp -r files/config/etc/lightdm /etc;
cp -r files/config/usr/share/applications /usr/share;
cp -r files/fonts/TTF /usr/share/fonts;
fc-cache;
mkdir /usr/share/lightdm;
cp files/images/wallpaper.jpg /usr/share/lightdm;
mkdir /home/chiri/images;
mkdir /home/chiri/images/wallpapers;
cp files/images/desktop-bg.jpg /home/chiri/images/wallpapers/wallpaper.jpg;
chown -R chiri:chiri /home/chiri/images;


## FINALLY ENABLE EMACS DAEMON AND LIGHTDM.
mkdir /home/chiri/.config/systemd/user/default.target.wants;
ln -s /home/chiri/.config/systemd/user/emacs.service /home/chiri/.config/systemd/user/default.target.wants/emacs.service;
chown -R chiri:chiri /home/chiri/.config/systemd/user;
ln -s /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service;


## REBOOT - MUST BE DONE MANUALLY, ONLY FOR INFO.
# exit;
# umount -R /mnt; ## optional
# reboot;
