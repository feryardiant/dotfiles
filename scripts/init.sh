#!/usr/bin/env bash
{
	# clear any previous sudo permission
	sudo -k

	# run inside sudo
	sudo sh <<SCRIPT
	locale-gen $LANG
	update-locale LC_ALL="$LANG" LANG="$LANG"
	dpkg-reconfigure --frontend noninteractive locales

	# Latest GIT
	add-apt-repository ppa:git-core/ppa -y

	# Latest TMUX & VIM
	add-apt-repository ppa:pi-rho/dev -y

	# Latest NeoVIM
	add-apt-repository ppa:neovim-ppa/stable -y

	# Apply changes
	apt-key update && apt-get update

	# Update
	apt-get install python-pip python3-pip -y
SCRIPT
}
