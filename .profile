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

#[[ -z $SSL_CERT_DIR && -d /etc/ssl/certs ]] && export SSL_CERT_DIR=/etc/ssl/certs

# export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

# export TERM=screen-256color
# [ -z "$TMUX" ] && export TERM=tmux-256color

# Import basic utilities
[[ -s $HOME/.env ]] && source $HOME/.env

[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME=$HOME/.config
[ -z "$XDG_CACHE_HOME" ] && export XDG_CACHE_HOME=$HOME/.cache
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME=$HOME/.local/share

# Import basic utilities
if [ -d $DOTFILES_DIR ]; then
    [[ -s $DOTFILES_DIR/scripts/util.sh ]] && source $DOTFILES_DIR/scripts/util.sh
fi

for dotfile in ~/.{exports,aliases,functions}; do
    [[ -r $dotfile && -f $dotfile ]] && source $dotfile
done
unset dotfile

_shell_basename=`basename $SHELL`

export DYLD_FALLBACK_LIBRARY_PATH="`brew --prefix`/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# ==============================================================================
# FZF | https://github.com/junegunn/fzf
# ==============================================================================
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
    export FZF_ALT_T_OPTS="--preview 'eza --tree --color=always {} | head -200'"

    source <(fzf --$_shell_basename)

    # Credit: https://doronbehar.com/articles/ZSH-FZF-completion/
    source "`brew --prefix fzf`/shell/completion.$_shell_basename"
fi

# ==============================================================================
# TheFuck | https://github.com/nvbn/thefuck
# ==============================================================================
if command -v thefuck >/dev/null 2>&1; then
    eval `thefuck --alias`
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init $_shell_basename)"

    alias cd="z"
fi

# ==============================================================================
# StarShip | https://github.com/starship/starship
# ==============================================================================
if type starship &>/dev/null; then
    eval "$(starship init $_shell_basename)"
fi

unset _shell_basename
