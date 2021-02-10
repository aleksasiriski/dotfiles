#!/bin/sh
cd dotfiles
git add *
git add .*
read commit
git commit $commit
git push
