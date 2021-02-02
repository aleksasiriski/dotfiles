#!/bin/sh
echo 'Installing packages...'

echo 'Better CLI tools'
yay -S neofetch htop bashtop micro calc autocutsel wget curl git
clear

echo 'ZSH'
yay -S zsh zsh-autosuggestions zsh-syntax-highlighting autojump
clear

echo 'Xorg, Intel and Amd GPU drivers'
yay -S xorg xorg-xinit mesa lib32-mesa xf86-video-amdgpu vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader vulkan-intel intel-media-driver lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau libva-utils
clear

echo '!!! Old intel drivers (only if necessary !!!'
yay -Rns intel-media-driver
yay -S xf86-video-intel libva-intel-driver
clear

echo 'Pulseaudio'
yay -S pulseaudio pulseaudio-alsa pulseaudio-jack pulseaudio-bluetooth bluez bluez-plugins bluez-tools bluez-utils blueberry
clear

echo 'WM'
yay -S bspwm sxhkd rofi picom polybar dunst wmrc flameshot
clear

echo 'Display manager & Polkit'
yay -S lightdm lightdm-slick-greeter polkit-gnome
sudo systemctl enable lightdm
clear

echo 'Fonts, icons & themes'
yay -S noto-fonts noto-fonts-emoji papirus-icon-theme qogir-icon-theme materia-gtk-theme lxappearance
clear

echo 'Standard GUI apps'
yay -S alacritty xterm thunar gvfs gvfs-smb gvfs-nfs gvfs-mtp ntfs-3g xarchiver firefox chromium nitrogen xfce4-clipman-plugin xfce4-power-manager sublime-text-3 code imv mpv vlc cpu-x
clear

echo 'Pulseaudio apps'
yay -S pavucontrol pnmixer mictray nm-connection-editor network-manager-applet
clear

echo 'Wine and dependencies'
yay -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader dxvk-bin libstrangle
clear

echo 'Gaming'
yay -S steam lutris heroic-games-launcher-bin parsec mangohud goverlay
clear

echo 'Social'
yay -S discord dino 
clear

echo 'Video production'
yay -S obs-studio kdenlive kdecoration handbrake gimp
clear

echo 'qBittorrent & balenaEtcher'
yay -S qbittorrent balena-etcher
clear

echo 'LibreOffice'
yay -S libreoffice-fresh
clear

echo 'Gamemoded*'
yay -S meson dbus cpupower
sudo systemctl enable cpupower
clear

echo 'Proton-GE'
cd ~
wget https://raw.githubusercontent.com/Termuellinator/ProtonUpdater/master/cproton.sh
chmod +x cproton.sh
./cproton.sh
clear

echo 'Finished installing packages!'