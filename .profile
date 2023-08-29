# Import basic utilities
[[ -s $HOME/.env ]] && source $HOME/.env

# Import basic utilities
if [ -d $DOTFILES_DIR ]; then
    [[ -s $DOTFILES_DIR/scripts/util.sh ]] && source $DOTFILES_DIR/scripts/util.sh
fi

# ==============================================================================
# This litle helper when /sbin, /usr/sbin & /usr/local/sbin dir
# doesn't included in $PATH, I found this issue on WSL
# ==============================================================================
# for sbin_dir in {/sbin,/usr/sbin,/usr/local/sbin,$HOME/.local/bin}; do
#     [[ -d $sbin_dir && -z "${PATH##*$sbin_dir*}" ]] && PATH=$sbin_dir:$PATH
# done
# unset sbin_dir

# ==============================================================================
# HomeBrew
# ==============================================================================
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # ==============================================================================
    # Ruby
    # ==============================================================================
    if [[ -d $HOMEBREW_PREFIX/opt/ruby ]]; then
       PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
       PATH="$HOMEBREW_PREFIX/lib/ruby/gems/3.1.0/bin:$PATH"
    fi

    # ==============================================================================
    # ASDF-VM
    # ==============================================================================
    [[ -f "`brew --prefix asdf`/libexec/asdf.sh" ]] && source "`brew --prefix asdf`/libexec/asdf.sh"
fi

# ==============================================================================
# Android SDK
# ==============================================================================
if [[ -z $ANDROID_SDK_ROOT && -d ~/.local/share/android ]]; then
    export ANDROID_SDK_ROOT="$HOME/.local/share/android"

    # for sdk_path in {tools,platform-tools,emulator}; do
    #     [[ -d $ANDROID_SDK_ROOT/$sdk_path ]] && PATH="$ANDROID_SDK_ROOT/$sdk_path:$PATH"
    # done
    # unset sdk_path
fi

# ==============================================================================
# User Local
# ==============================================================================
if [[ -d $HOME/.local/bin ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Prevent Duplicate Path
# Credit: https://askubuntu.com/a/1349910/10706
export PATH=`printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ {if (NR > 1) printf RS; printf $1}'`

# ==============================================================================
# Git Prompt
# see: https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# ==============================================================================

# [ -f ~/.local/tools/git-prompt.sh ] && . ~/.local/tools/git-prompt.sh

for dotfile in ~/.{exports,aliases,functions}; do
    [[ -r $dotfile && -f $dotfile ]] && source $dotfile
done
unset dotfile

# export PATH="$(consolidate_path $PATH)"
