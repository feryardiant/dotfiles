#!/usr/bin/env bash
{
	# clear any previous sudo permission
	sudo -k

	# run inside sudo
	sudo sh <<SCRIPT
	if [ "$(lsb_release -cs)" = 'xenial' ]; then
		if command -v tmux >/dev/null 2>&1; then
			apt-get purge tmux -yqq
		fi

		if ! command -v tmux-next >/dev/null 2>&1; then
			apt-get install tmux-next -yqq
		else
			apt-get upgrade tmux-next -yqq
		fi

		sudo update-alternatives --install /usr/bin/tmux tmux /usr/bin/tmux-next 60
	else
		if ! command -v tmux >/dev/null 2>&1; then
			apt-get install tmux -yqq
		else
			apt-get upgrade tmux -yqq
		fi
	fi
SCRIPT
}
