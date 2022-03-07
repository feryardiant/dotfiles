# Import basic utilities
[[ -s $HOME/.env ]] && source $HOME/.env

eval "$(/opt/homebrew/bin/brew shellenv)"

# Import basic utilities
if [ -d $DOTFILES_DIR ]; then
    [[ -s $DOTFILES_DIR/scripts/util.sh ]] && source $DOTFILES_DIR/scripts/util.sh
fi

# ==============================================================================
# ASDF-VM
# ==============================================================================
# soruce /opt/homebrew/opt/asdf/asdf.sh

# ==============================================================================
# This litle helper when /sbin, /usr/sbin & /usr/local/sbin dir
# doesn't included in $PATH, I found this issue on WSL
# ==============================================================================
# for sbin_dir in {/sbin,/usr/sbin,/usr/local/sbin,$HOME/.local/bin}; do
#     [[ -d $sbin_dir && -z "${PATH##*$sbin_dir*}" ]] && PATH=$sbin_dir:$PATH
# done
# unset sbin_dir

export PATH="$HOME/.local/bin:$HOME/Library/Python/3.9/bin:$PATH"

# ==============================================================================
# Git Prompt
# see: https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# ==============================================================================

# [ -f ~/.local/tools/git-prompt.sh ] && . ~/.local/tools/git-prompt.sh

for dotfile in ~/.{exports,aliases,functions}; do
    [[ -r $dotfile && -f $dotfile ]] && source $dotfile
done
unset dotfile
