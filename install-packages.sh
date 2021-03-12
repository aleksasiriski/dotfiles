#!/bin/sh

echo 'User: '
read username
sudo usermod -aG audio,disk,floppy,input,kvm,optical,scanner,storage,video,lp $username
echo 'Added '$username' to needed groups'

echo 'Installing packages...'

echo 'CCache, Reflector & Pacman Hook'
paru -S ccache reflector reflector-mirrorlist-update
sudo systemctl enable --now reflector.service
sudo systemctl enable --now reflector.timer
clear

echo 'Better CLI tools'
paru -S neofetch htop bashtop micro calc autocutsel wget curl git github-cli ranger cava
clear

echo 'ZSH'
paru -S zsh zsh-autosuggestions zsh-syntax-highlighting autojump
clear

echo 'Xorg, Intel and Amd GPU drivers'
paru -S xorg xorg-xinit mesa lib32-mesa xf86-video-amdgpu vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader vulkan-intel intel-media-driver libva-intel-driver lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau libva-utils
clear

echo 'Pipewire'
paru -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-jack-dropin catia
clear

echo 'Bluetooth'
paru -S bluez bluez-plugins bluez-utils blueberry
sudo systemctl enable bluetooth.service
sudo systemctl enable bluetooth-autoconnect.service
systemctl --user enable pulseaudio-bluetooth-autoconnect
clear

echo 'XOrg Window Manager - bspwm'
paru -S bspwm sxhkd rofi rofi-calc picom polybar dunst wmrc flameshot
clear

echo 'Wayland Window Manager - Sway'
paru -S sway waybar wofi mako i3status xorg-xwayland qt5-wayland glfw-wayland
clear

echo 'Fonts, icons & themes'
paru -S noto-fonts noto-fonts-emoji noto-fonts-extra noto-fonts-cjk ttf-twemoji-color ttf-symbola papirus-icon-theme qogir-icon-theme materia-gtk-theme lxappearance
clear

echo 'Standard GUI apps'
paru -S polkit-gnome alacritty devour xterm thunar gvfs gvfs-smb gvfs-nfs gvfs-mtp ntfs-3g xarchiver firefox nitrogen xfce4-clipman-plugin xfce4-power-manager sublime-text-3 code imv mpv vlc cpu-x
clear

echo 'Systray apps'
paru -S pavucontrol pnmixer mictray nm-connection-editor network-manager-applet
clear

echo 'Wine and dependencies'
paru -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader dxvk-bin libstrangle
clear

echo 'Gaming'
paru -S steam steam-native-runtime lutris heroic-games-launcher-bin parsec-bin mangohud goverlay
clear

echo 'Social'
paru -S dino discord
clear

echo 'Video & Audio production'
paru -S obs-studio gimp audacity kdenlive breeze handbrake
clear

echo 'qBittorrent & balenaEtcher'
paru -S qbittorrent etcher-bin
clear

echo 'LibreOffice'
paru -S libreoffice-fresh
clear

echo 'Gamemoded*'
paru -S meson dbus cpupower
sudo systemctl enable cpupower
clear

echo 'Proton-GE'
cd ~
rm cproton.sh
wget https://raw.githubusercontent.com/Termuellinator/ProtonUpdater/master/cproton.sh
chmod +x cproton.sh
./cproton.sh
clear

echo 'Finished installing packages!'
