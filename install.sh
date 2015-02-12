#!/bin/bash

set -e

# usage color "31;5" "string"
# 0 default
# 5 blink, 1 strong, 4 underlined
# fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
# bg: 40 black, 41 red, 44 blue, 45 purple
cetak() {
    printf '\033[%sm%s\033[m\n' "$@"
}

my_pwd="$PWD"

cd $HOME

for dotfile in aliases bash_profile bash_prompt bashrc exports functions gitconfig vimrc; do
    [ ! -d "dotfiles.old" ] && mkdir dotfiles.old

    if [ -f "$HOME/.$dotfile" ]; then
        mv "$HOME/.$dotfile" "dotfiles.old/.$dotfile"
        cetak "33;5" "Backing up your .$dotfile to dotfiles.old/.$dotfile"
    fi

    ln -s "$my_pwd/.$dotfile" .
done
unset dotfile

if [ -f ~/.profile ]; then
    mv ~/.profile dotfiles.old/.profile
fi

ln -s .bash_profile .profile
source ~/.bashrc
cetak "32;5" 'Your dotfiles are ready!'

if [ -d ~/.vim ]; then
    mv ~/.vim dotfiles.old/.vim
    cetak "33;5" "Backing up your .vim directory to dotfiles.old/.vim"
fi

mkdir ~/.vim && cd ~/.vim

cetak "32;5" "Begin setup your vim plugins using pathogen"
mkdir -p autoload bundle && \
curl -LSso autoload/pathogen.vim https://tpo.pe/pathogen.vim && \
git init && \
git add -A && git commit -m "Initial commit && install autoload/pathogen"

declare -A plugins
plugins[mattn/emmet-vim]=bundle/emmet
plugins[scrooloose/nerdtree]=bundle/nerdtree
plugins[tpope/vim-fugitive]=bundle/fugitive
plugins[tpope/vim-surround]=bundle/surround
plugins[scrooloose/syntastic]=bundle/syntastic
plugins[kien/ctrlp.vim]=bundle/ctrlp
plugins[Lokaltog/vim-easymotion]=bundle/easymotion
plugins[ervandew/supertab]=bundle/supertab
plugins[reedes/vim-pencil]=bundle/pencil
plugins[Shougo/neocomplcache.vim]=bundle/neocomplcache
plugins[terryma/vim-multiple-cursors]=bundle/multiple-cursors

for repo in ${!plugins[@]}; do
    plugin=${plugins[$repo]}
    cetak "33;5" "Installing $plugin"
    git submodule --quiet add github:$repo $plugin && git add -A && git commit -m "$plugin Installed"
done
unset repo plugin

cd $my_pwd
cetak "32;5" 'Done!'
