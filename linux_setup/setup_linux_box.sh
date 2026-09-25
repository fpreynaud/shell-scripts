#!/bin/bash

# Swap caps lock and escape
sudo setkeycodes 3a 1 &&
sudo setkeycodes 01 58 &&

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
mkdir -p $HOME/github_repos &&
cd $HOME/github_repos &&

# Fetch and apply config files
git clone https://github.com/fpreynaud/config_files &&
$HOME/github_repos/config_files/configure &&

# Fetch contx and build image (repo is private so password will be needed)
git clone https://fpreynaud@github.com/fpreynaud/contx &&
cd $HOME/github_repos/contx &&
sudo $HOME/github_repos/contx/build &&

cd $orig_dir &&

exec fish
