#!/bin/sh
echo 'Updating system...'
paru -Syu
clear

sudo usermod -aG audio,disk,floppy,input,kvm,optical,scanner,storage,video,lp gamer
echo 'Added gamer to needed groups'

echo 'Installing packages...'

echo 'Dash, CCache & Reflector'
paru -S dash dashbinsh ccache reflector reflector-mirrorlist-update ntp openssh --noconfirm
sudo systemctl enable --now systemd-timesyncd.service reflector.service reflector.timer ntpd.service sshd.service
clear

echo 'Better CLI tools'
paru -S neofetch htop bashtop micro wget curl git --noconfirm
clear

echo 'ZSH'
paru -S zsh zsh-autosuggestions zsh-syntax-highlighting autojump --noconfirm
clear

echo 'Amd GPU drivers'
paru -S mesa lib32-mesa libva-utils --noconfirm
paru -S xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau --noconfirm
clear

echo 'Pipewire'
paru -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pavucontrol --noconfirm
systemctl --user enable --now pipewire.service pipewire-pulse.service
clear

echo 'Bluetooth'
paru -S bluez bluez-plugins bluez-utils bluetooth-autoconnect --noconfirm
sudo systemctl enable --now bluetooth.service bluetooth-autoconnect.service
clear

echo 'Fonts'
paru -S gsfonts noto-fonts noto-fonts-emoji noto-fonts-extra noto-fonts-cjk ttf-twemoji-color ttf-symbola --noconfirm
clear

echo 'Wine and dependencies'
paru -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
clear

echo 'SteamOS'
paru -S xorg xorg-xinit steamos-compositor-plus steam steam-tweaks proton-ge-custom-bin gamemode lib32-gamemode cpupower --noconfirm
sudo systemctl enable --now cpupower.service
systemctl --user enable --now gamemoded.service
clear

echo 'Finished installing packages!'