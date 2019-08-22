#!/usr/bin/env bash
{
	# clear any previous sudo permission
	sudo -k

	# run inside sudo
	sudo sh <<SCRIPT
	if ! command -v zsh >/dev/null 2>&1; then
		apt-get install zsh -yqq
	fi

	# chsh --shell "/usr/bin/zsh" "$USER"
SCRIPT
}
