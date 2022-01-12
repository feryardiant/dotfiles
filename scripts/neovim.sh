#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
add-apt-repository ppa:neovim-ppa/stable -y > /dev/null 2>&1

if ! command -v nvim >/dev/null 2>&1; then
	apt-get install neovim -yqq
fi

# update-alternatives --install `which vim` vim `which nvim` 60 > /dev/null
SCRIPT
}
