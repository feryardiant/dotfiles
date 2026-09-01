# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export GPG_TTY=$(tty)
export EDITOR='nvim'

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"
# export MANPATH="/usr/local/man:$MANPATH"

# Larger bash history (allow 32³ entries; default is 500)
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=2048
export HISTFILESIZE=61440

# timestamps for bash history. www.debian-administration.org/users/rossen/weblog/1
# saved for later analysis
export HISTTIMEFORMAT='%F %T → '

# Make some commands not show up in history
export HISTIGNORE="&:h:history:pwd:exit:clear:[ \t]*"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# Limit path length in promt (e.g. ~/.../current/path/name)
# export PROMPT_DIRTRIM=3

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Fix OBJC initialization issue
# see: https://github.com/rails/rails/issues/38560
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export DYLD_FALLBACK_LIBRARY_PATH="`brew --prefix`/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# ==============================================================================
# DOTFILE DIRECTORY
# ==============================================================================
export DOTFILES_DIR=~/Config/dotfiles

# Import basic utilities
if [[ -d $DOTFILES_DIR ]]; then
    [[ -s $DOTFILES_DIR/scripts/util.sh ]] && source $DOTFILES_DIR/scripts/util.sh

    for _base in $DOTFILES_DIR/home/*.sh; do
        [[ -r $_base ]] && source $_base
    done
    unset _base
fi
