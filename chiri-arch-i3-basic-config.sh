#!/usr/bin/env bash

##
## Post install script for configuring the GUI system and the various
## apps used.
##

## VARIABLES.
GITHUB_URL='https://raw.githubusercontent.com/chirimantecman/arch-i3-basic/main';
GREETER_BG='wallpaper.jpg';


## SET LOCALE FOR X!!.
localectl set-x11-keymap latam;


## DOWNLOAD FILES.
##
## Greeter background, desktop background, xorg config, lightdm
## config, slick greeter config, i3 config, polybar config, rofi
## config, emacs config, zsh config, .xprofile, .Xresources, picom
## config, systemd user scripts, fonts, desktop files
wget --no-check-certificate "$GITHUB_URL/$GREETER_BG";


## XORG.



## LIGHTDM AND GREETER.
## We use slick greeter for now.
## /etc/lightdm/lightdm.conf
echo '[LightDM]' > /etc/lightdm/lightdm.conf;
echo 'run-directory=/run/lightdm' >> /etc/lightdm/lightdm.conf;
echo '' >> /etc/lightdm/lightdm.conf;
echo '[Seat:*]' >> /etc/lightdm/lightdm.conf;
echo 'greeter-session=lightdm-slick-greeter' >> /etc/lightdm/lightdm.conf;
echo 'session-wrapper=/etc/lightdm/Xsession' >> /etc/lightdm/lightdm.conf;
echo '' >> /etc/lightdm/lightdm.conf;
echo '[XDMCPServer]' >> /etc/lightdm/lightdm.conf
echo '' >> /etc/lightdm/lightdm.conf;
echo '[VNCServer]' >> /etc/lightdm/lightdm.conf;

## /etc/lightdm/slick-greeter.conf
## Here we need the background image file, it has been downloaded at
## the first step.
mkdir /usr/share/lightdm;
cp wallpaper.jpg /usr/share/lightdm/wallpaper.jpg;
echo '[Greeter]' > /etc/lightdm/slick-greeter.conf;
echo 'background=/usr/share/lightdm/wallpaper.jpg' >> /etc/lightdm/slick-greeter.conf;
echo 'draw-user-backgrounds=true' >> /etc/lightdm/slick-greeter.conf;
echo 'icon-theme-name=Adwaita' >> /etc/lightdm/slick-greeter.conf;
