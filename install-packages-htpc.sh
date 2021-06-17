#!/bin/sh
echo 'Updating system...'
paru -Syu
clear

sudo usermod -aG audio,disk,floppy,input,kvm,optical,scanner,storage,video,lp gamer
echo 'Added gamer to needed groups'

echo 'Installing packages...'

echo 'Dash, CCache & Reflector'
paru -S dash dashbinsh ccache reflector reflector-mirrorlist-update ntp --noconfirm
sudo systemctl enable --now systemd-timesyncd.service
sudo systemctl enable --now reflector.service
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now ntpd.service
clear

echo 'Better CLI tools'
paru -S neofetch htop bashtop micro wget curl git --noconfirm
clear

echo 'ZSH'
paru -S zsh zsh-autosuggestions zsh-syntax-highlighting autojump --noconfirm
clear

echo 'Intel and Amd GPU drivers'
paru -S mesa lib32-mesa libva-utils --noconfirm
paru -S vulkan-intel intel-media-driver libva-intel-driver --noconfirm
paru -S xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau --noconfirm
clear

echo 'Wayland Window Manager - Sway'
paru -S sway xorg-xwayland wofi qt5-wayland glfw-wayland wl-clipboard clipman --noconfirm
clear

echo 'Pipewire'
paru -S pipewire libpipewire02 pipewire-media-session pipewire-alsa pipewire-pulse pipewire-jack --noconfirm
systemctl --user enable pipewire pipewire-pulse pipewire-media-session
clear

echo 'Bluetooth'
paru -S bluez bluez-plugins bluez-utils bluetooth-autoconnect blueberry --noconfirm
sudo systemctl enable bluetooth.service
sudo systemctl enable bluetooth-autoconnect.service
clear

echo 'Fonts, icons & themes'
paru -S gsfonts noto-fonts noto-fonts-emoji noto-fonts-extra noto-fonts-cjk ttf-twemoji-color ttf-symbola papirus-icon-theme qogir-icon-theme materia-gtk-theme lxappearance --noconfirm
clear

echo 'Standard GUI apps'
paru -S alacritty firefox pcmanfm-gtk3 gvfs gvfs-mtp xarchiver gedit imv mpv --noconfirm
clear

echo 'Systray apps'
paru -S pavucontrol --noconfirm
clear

echo 'Wine and dependencies'
paru -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
clear

echo 'Gaming'
paru -S steam steam-tweaks proton-ge-custom-bin gamemode lib32-gamemode --noconfirm
systemctl --user enable gamemoded
clear

echo 'Finished installing packages!'
