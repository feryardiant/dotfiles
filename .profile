# Import basic utilities
[[ -r $HOME/.env && -f $HOME/.env ]] && source $HOME/.env

# Import basic utilities
if [ -d $DOTFILES_DIR ]; then
    [[ -f $DOTFILES_DIR/scripts/util.sh ]] && source $DOTFILES_DIR/scripts/util.sh
fi

# ==============================================================================
# This litle helper when /sbin, /usr/sbin & /usr/local/sbin dir
# doesn't included in $PATH, I found this issue on WSL
# ==============================================================================

for sbin_dir in {$HOME/.local/bin,/sbin,/usr/sbin,/usr/local/sbin}; do
	[[ -d $sbin_dir && -z "${PATH##*$sbin_dir*}" ]] || PATH=$sbin_dir:$PATH
done
unset sbin_dir

# ==============================================================================
# ASDF
# https://github.com/asdf-vm/asdf
# ==============================================================================

if [ -d ~/.asdf ]; then
	[ -f ~/.asdf/asdf.sh ] && . ~/.asdf/asdf.sh
	[ -f ~/.asdf/completions/asdf.bash ] && . ~/.asdf/completions/asdf.bash
fi

# ==============================================================================
# added by travis gem
# ==============================================================================

# [ -f ~/.travis/travis.sh ] && . ~/.travis/travis.sh

# ==============================================================================
# Git Prompt
# see: https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# ==============================================================================

# [ -f ~/.local/tools/git-prompt.sh ] && . ~/.local/tools/git-prompt.sh

for dotfile in ~/.{exports,aliases,functions}; do
    [[ -r $dotfile && -f $dotfile ]] && source $dotfile
done
unset dotfile
