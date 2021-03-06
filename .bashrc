# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

if test -t 1; then
    exec "$SHELL" -l
fi

# If not running interactively, don't do anything
case $- in
	*i*) ;;
		*) return;;
esac

# append to the history file, dont overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	elif [ -f ~/.bash_completion ]; then
		. ~/.bash_completion
	fi
fi

# [ -z "$TMUX" ] && { tmux attach || exec tmux new-session && exit; }

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

source ~/.profile

# Bash Prompt
PS1="\n\$ \[$blue\]\u \[$yellow\]\w\[\033[m\]\[$magenta\]\$(__git_ps1)\n\[$white\]→ "
