#!/usr/bin/bash

loadkeys la-latin1;
pacman -Syy;
pacman -S --noconfirm archlinux-keyring wget;
wget --no-check-certificate https://raw.githubusercontent.com/chirimantecman/arch-i3-basic/main/chiri-arch-i3-basic-install.sh;
chmod +x chiri-arch-i3-basic-install.sh;
