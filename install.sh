#!/usr/bin/env bash

set -e

sudo -k

DOTFILES_DIR=`dirname ${BASH_SOURCE[0]}`
CONFIG_DIR="$DOTFILES_DIR/config"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
LOGS_DIR="$DOTFILES_DIR/logs"

echo "Current directory: $DOTFILES_DIR"
exit 0

source $SCRIPTS_DIR/util.sh

export LANG=${LANG:-"en_US.UTF-8"}

now=`date +'%Y-%m-%d_%H-%M-%S'`
BACKUP_DIR=$DOTFILES_DIR/dotfiles.old/$now

# Create backup dir if not exists
[[ ! -d $BACKUP_DIR ]] && mkdir -p $BACKUP_DIR

with_zsh='0'
with_neovim='0'
export _LOG_FILE=$LOGS_DIR/install.log

while [ $# -ne 0 ]; do
    case $1 in
        --with-zsh)
            with_zsh='1'
            shift
        ;;
        --with-neovim)
            with_neovim='1'
            shift
        ;;
        --)
            shift
            break
        ;;
        -?*)
            echo "Invalid argument: $1" 1>&2
            exit 1
        ;;
        *)
            break
        ;;
    esac
done

mkdir -p ~/.{cache,config,local} ~/.local/{bin,share,state}

# e $c_inf $'Configure (this might take a while)...\n'
# . $SCRIPTS_DIR/init.sh

cd $HOME

# ------------------------------------------------------------------------------
# Basic
# ------------------------------------------------------------------------------

e $c_inf 'Setup dotfiles'

# Setup
_resque ~/.profile && ln -sf $DOTFILES_DIR/.profile .

# Cleanup
unset dotfile dotfiles

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# ENV
# ------------------------------------------------------------------------------

e $c_inf 'Setup dotenv'

envContent="`cat $DOTFILES_DIR/.env.sample`"

if [ -f ~/.env ]; then
    mv -f ~/.env $BACKUP_DIR/
    envContent="$envContent"$'\n\n'"$(cat $BACKUP_DIR/.env)"
fi

echo "$envContent" > ~/.env
sed -i "s@export DOTFILES_DIR=''@export DOTFILES_DIR='$DOTFILES_DIR'@g" ~/.env

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# GIT
# ------------------------------------------------------------------------------

e $c_inf 'Setup git'

# Installing
. $SCRIPTS_DIR/git.sh > $_LOG_FILE

# Backup
if [ -f ~/.gitconfig ]; then
    git_email="`git config --global user.email`"
    git_name="`git config --global user.name`"

    _resque ~/.gitconfig
fi

# Setup
cp -f $DOTFILES_DIR/.gitconfig ~/.gitconfig

# Restore default user name & email
[[ ! -z $git_email ]] && git config --global user.email "$git_email"
[[ ! -z $git_name ]] && git config --global user.name "$git_name"

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# TMUX
# ------------------------------------------------------------------------------

e $c_inf 'Setup TMUX'

# Installing
. $SCRIPTS_DIR/tmux.sh > $_LOG_FILE

# Backup
_resque ~/.tmux.conf

# Setup
ln -sf $DOTFILES_DIR/.tmux.conf ~/.tmux.conf

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# VIM & NeoVIM
# ------------------------------------------------------------------------------

plug_dir=~/.local/share/vim-plug

if [[ ! -d $plug_dir ]]; then
    curl -LSso $plug_dir/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    [ ! -d $plug_dir/plugged ] && mkdir $plug_dir/plugged
fi

if _has_pkg 'vim'; then
    e $c_inf 'Setup VIM'

    # Setup
    mkdir -p ~/.cache/vim/{swap,undo}

    [ -d ~/.vim ] || mkdir -p ~/.vim/autoload
    ln -sf $DOTFILES_DIR/.vimrc ~/.vimrc
    ln -sf $plug_dir/plug.vim ~/.vim/autoload/plug.vim

    e $c_suc $' ✔ Done\n'
fi

if _has_pkg 'nvim'; then
    e $c_inf 'Setup NeoVIM'

    # Setup
    for vim_dir in {swap,undo,backup}; do
        [ -d ~/.cache/nvim/$vim_dir ] || mkdir -p ~/.cache/nvim/$vim_dir
    done
    unset vim_dir

    [ -d ~/.config/nvim ] || mkdir -p ~/.config/nvim/autoload
    ln -sf $DOTFILES_DIR/.vimrc ~/.config/nvim/init.vim
    ln -sf $plug_dir/plug.vim ~/.config/nvim/autoload/plug.vim

    # sudo update-alternatives --install /usr/bin/editor editor $vim_bin 60 > $_LOG_FILE

    e $c_suc $' ✔ Done\n'
fi

# Clean up
unset plug_dir

# ------------------------------------------------------------------------------
# DONE
# ------------------------------------------------------------------------------

# Reload shell
cd $DOTFILES_DIR

e $c_suc $'\nEverything is done ✔\n'
e $c_rst 'Your old files are backed up in '
e $c_inf "=> $BACKUP_DIR"$'\n'

e $c_rst 'Thank you'
[[ ! -z $git_name ]] && e $c_inf ' $git_name'
[[ ! -z $git_email ]] && e $c_inf ' <$git_email>'
echo $'\n'
