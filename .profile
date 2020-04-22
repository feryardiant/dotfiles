# Import basic utilities
[[ -r ~/.env && -f ~/.env ]] && source ~/.env

# Import basic utilities
. $DOTFILES_DIR/scripts/util.sh

for dotfile in ~/.{exports,aliases,functions}; do
    [[ -r $dotfile && -f $dotfile ]] && source $dotfile
done
unset dotfile
