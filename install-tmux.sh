#!/bin/bash

sudo dnf install --refresh -y tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp ./.tmux.conf ~/.tmux.conf
# launch tmux server to reload conf
tmux new -d
tmux source ~/.tmux.conf
tmux kill-server
echo "Config complete! Launch tmux and press 'prefix (Ctrl+s) + I' to install plugins"
