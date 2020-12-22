#!/bin/sh
sudo pacman -Syu
sudo pacman -Rns $(pacman -Qtdq)
sudo pacman -Sc

yay -Syu
yay -Rns $(yay -Qtdq)
yay -Sc
