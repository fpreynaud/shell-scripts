#!/bin/bash

mkdir -p $HOME/github_repos $HOME/.local/bin &&

# Swap caps lock and escape
sudo echo "[Unit]
Description=Swap Caps Lock and Escape keys

[Service]
ExecStart=/home/me/.local/bin/swap_escape_capslock

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/swap_escape_capslock.service

echo "setkeycodes 3a 1
setkeycodes 01 58" > $HOME/.local/bin/swap_escape_capslock

sudo systemctl enable swap_escape_capslock
sudo systemctl start swap_escape_capslock

# Install i3, fish, kitty and docker
sudo apt update &&
sudo apt install -y --allow-unauthenticated \
	i3-wm \
	fish \
	kitty \
	docker.io &&

# Use fish as login shell
chsh --shell /usr/bin/fish &&
sudo chsh --shell /usr/bin/fish &&

orig_dir=$(pwd)
cd $HOME/github_repos &&

# Fetch and apply config files
git clone https://github.com/fpreynaud/config_files &&
$HOME/github_repos/config_files/configure &&

# Fetch contx and build image (repo is private so password will be needed)
git clone https://fpreynaud@github.com/fpreynaud/contx &&
cd $HOME/github_repos/contx &&
sudo $HOME/github_repos/contx/build &&
cp $HOME/github_repos/contx/setup.fish $HOME/.local/bin/audit
cd $orig_dir &&


# Dynamic touchpad device search (by partial name)
device_name=$(xinput list --name-only | grep -i 'touchpad')  
device_id=$(xinput list --id-only "$device_name")

# Activate natural scrolling on touchpad
xinput set-prop "$device_id" "libinput Natural Scrolling Enabled" 1

exec fish
