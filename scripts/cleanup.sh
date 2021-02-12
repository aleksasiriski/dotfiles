#!/bin/sh
paru -Syu
paru -Rns $(paru -Qtdq)
paru -Sc
