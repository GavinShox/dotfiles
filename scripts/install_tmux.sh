#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "-------------------------------- Install & Setup Tmux --------------------------------"

read -r -p "This script will install tmux and plugin manager from repo: <https://github.com/tmux-plugins/tpm> - Continue? (y/n): " input
if [[ ! $input =~ ^[Yy]$ ]]; then
	echo "Stopping script..."
	"--------------------------------------------------------------------------------------"
	exit 1
fi

sudo dnf install --refresh -y tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp -fb "$SCRIPT_DIR"/../configs/.tmux.conf "$HOME"/.tmux.conf
# launch tmux server to reload conf
tmux new -d
tmux source "$HOME"/.tmux.conf
tmux kill-server
echo ".tmux.conf backup made at ${HOME}/.tmux.conf~"
echo "Config complete! Launch tmux and press 'prefix (Ctrl+s) + I' to install plugins"
echo "-------------------------------- Finished Tmux Setup! --------------------------------"
