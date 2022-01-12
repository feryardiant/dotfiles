#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
add-apt-repository ppa:pi-rho/dev -y > /dev/null 2>&1

if ! command -v tmux >/dev/null 2>&1; then
	apt-get install tmux -yqq
else
	apt-get upgrade tmux -yqq
fi
SCRIPT
}
