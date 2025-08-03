#!/bin/bash

sudo dnf install --refresh -y tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp ./.tmux.conf ~/.tmux.conf
tmux source ~/.tmux.conf
