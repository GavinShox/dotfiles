#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "-------------------------------- Install & Setup Tmux --------------------------------"
sudo dnf install --refresh -y tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp -fb $SCRIPT_DIR/../configs/.tmux.conf $HOME/.tmux.conf
# launch tmux server to reload conf
tmux new -d
tmux source ~/.tmux.conf
tmux kill-server
echo ".tmux.conf backup made at ${HOME}/.tmux.conf~"
echo "Config complete! Launch tmux and press 'prefix (Ctrl+s) + I' to install plugins"
echo "-------------------------------- Finished Tmux Setup! --------------------------------"
