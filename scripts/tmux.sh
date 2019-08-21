#!/usr/bin/env bash
{
	# clear any previous sudo permission
	sudo -k

	# run inside sudo
	sudo sh <<SCRIPT
	if ! command -v tmux >/dev/null 2>&1; then
		apt-get install tmux -yqq
	else
		apt-get upgrade tmux -yqq
	fi
SCRIPT
}
