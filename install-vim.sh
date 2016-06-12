#!/bin/bash

set -e

# usage color "31;0" "string"
# 0 default, 1 strong, 4 underlined, 5 blink
# fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
# bg: 40 black, 41 red, 44 blue, 45 purple
e() {
    printf '\033[%sm%s\033[m\n' "$@"
}

my_pwd="$PWD"
now=`date +'%Y-%m-%d'`
backup_dir="${my_pwd}/dotfiles.old/${now}"
dotfiles="aliases profile bash_prompt bashrc exports functions vimrc"

[ ! -d $backup_dir ] && mkdir -p $backup_dir

e "32;0" "Begin setup your VIM"

[ -d ~/.vim ] && mv ~/.vim $backup_dir/.vim
mkdir ~/.vim && cd ~/.vim

vim_dirs="swap undo backup"
for vim_dir in $vim_dirs; do
    [ ! -d ~/.cache/vim/$vim_dir ] && mkdir -p ~/.cache/vim/$vim_dir
done
unset vim_dir vim_dirs

e "32;0" "Begin installing pathogen"
mkdir -p autoload bundle && \
curl -LSso autoload/pathogen.vim https://tpo.pe/pathogen.vim && \
git init && \
git a && git c "Initial commit && install autoload/pathogen"

e "32;0" "Begin installing VIM plugins"
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
plugins[vim-airline/vim-airline]=bundle/vim-airline
plugins[vim-airline/vim-airline-themes]=bundle/vim-airline-themes

for repo in ${!plugins[@]}; do
    plugin=${plugins[$repo]}
    git submodule -q add github:$repo $plugin && git a && git c "~/.vim/$plugin plugin installed"
done
unset repo plugin

cd $my_pwd
e "32;0" "Everything's done!"
e "32;0" "Your old files are backed up in $backup_dir"
