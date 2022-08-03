#!/usr/bin/bash


## CONFIGURATION OPTIONS.
UNPRIV_USER='chiri';

TZ='America/Santiago';

CF_LOCALES=/etc/locale.gen;
cat <<EOT > $CF_LOCALES
es_CL.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOT

VC_KBD='la-latin1';

YAY_LIST_FILE='yay-packages';
cat <<EOT >> $YAY_LIST_FILE
waterfox-classic-bin
lightdm-settings
EOT


## TIMEZONE AND LOCALE.
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime;
hwclock --systohc;
locale-gen;
echo "LANG=`head -n 1 /etc/locale.gen`" > /etc/locale.conf;
echo "KEYMAP=$VC_KBD" > /etc/vconsole.conf;


## NETWORK.
echo "arch-i3-basic" > /etc/hostname;
ln -s /usr/lib/systemd/system/dhcpcd.service /etc/systemd/system/multi-user.target.wants/dhcpcd.service;
ln -s /usr/lib/systemd/system/systemd-resolved.service /etc/systemd/system/dbus-org.freedesktop.resolve1.service;
mkdir /etc/systemd/system/sysinit.target.wants;
ln -s /usr/lib/systemd/system/systemd-resolved.service /etc/systemd/system/sysinit.target.wants/systemd-resolved.service;


## USER MANAGEMENT.
echo "Please set the root password";
passwd;
echo "Adding user $UNPRIV_USER";
useradd -m -s /usr/bin/zsh $UNPRIV_USER;
echo "User added. Please set the user password";
passwd $UNPRIV_USER;


# YAY AND PACKAGES.
git clone https://aur.archlinux.org/yay.git /home/$UNPRIV_USER/yay;
chown -R $UNPRIV_USER:$UNPRIV_USER /home/$UNPRIV_USER/yay;
cd /home/$UNPRIV_USER/yay;
runuser -u $UNPRIV_USER -- makepkg -si;
runuser -u $UNPRIV_USER -- yay -Y --gendb;
runuser -u $UNPRIV_USER -- yay -Syu --devel;
runuser -u $UNPRIV_USER -- yay -Y --devel --save;
runuser -u $UNPRIV_USER -- yay -S - < $YAY_LIST_FILE;


## BOOT LOADER.
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB;
grub-mkconfig -o /boot/grub/grub.cfg;


## PREPARE FOR A VIRTUALBOX SHARED FOLDER.
## Currently the vboxservice systemd service will create the /media
## directory.
ln -s /usr/lib/systemd/system/vboxservice.service /etc/systemd/system/multi-user.target.wants/vboxservice.service;
usermod -a -G vboxsf root;
usermod -a -G vboxsf $UNPRIV_USER;


## COPY FILES AND SET PERMISSIONS.
cd /root;
tar -xzvf files.tar.gz;
cp -r files/config/home/.config /home/$UNPRIV_USER;
cp -r files/config/home/.emacs.d /home/$UNPRIV_USER;
cp files/config/home/.xprofile /home/$UNPRIV_USER;
cp files/config/home/.Xresources /home/$UNPRIV_USER;
chown -R $UNPRIV_USER:$UNPRIV_USER /home/$UNPRIV_USER;
cp -r files/config/etc/X11 /etc;
cp -r files/config/etc/lightdm /etc;
cp -r files/config/usr/share/applications /usr/share;
cp -r files/fonts/TTF /usr/share/fonts;
fc-cache;
mkdir /usr/share/lightdm;
cp files/images/wallpaper.jpg /usr/share/lightdm;
mkdir /home/$UNPRIV_USER/images;
mkdir /home/$UNPRIV_USER/images/wallpapers;
cp files/images/desktop-bg.jpg /home/$UNPRIV_USER/images/wallpapers/wallpaper.jpg;
chown -R $UNPRIV_USER:$UNPRIV_USER /home/$UNPRIV_USER/images;


## FINALLY ENABLE EMACS DAEMON AND LIGHTDM.
mkdir /home/$UNPRIV_USER/.config/systemd/user/default.target.wants;
ln -s /home/$UNPRIV_USER/.config/systemd/user/emacs.service /home/$UNPRIV_USER/.config/systemd/user/default.target.wants/emacs.service;
chown -R $UNPRIV_USER:$UNPRIV_USER /home/$UNPRIV_USER/.config/systemd/user;
ln -s /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service;
