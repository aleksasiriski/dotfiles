#!/bin/sh
yay -Syu
yay -Rns $(yay -Qtdq)
yay -Sc
