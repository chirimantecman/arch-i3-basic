#!/usr/bin/env bash

##
## Post install script for configuring the GUI system and the various
## apps used.
##

## DOWNLOAD FILES.


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
echo '[Greeter]' > /etc/lightdm/slick-greeter.conf;
echo 'background=/usr/share/lightdm/wallpaper.jpg' >> /etc/lightdm/slick-greeter.conf;
echo 'draw-user-backgrounds=true' >> /etc/lightdm/slick-greeter.conf;
echo 'icon-theme-name=Adwaita' >> /etc/lightdm/slick-greeter.conf;
