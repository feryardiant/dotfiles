#!/bin/bash

set -e

# usage color "31;5" "string"
# 0 default
# 5 blink, 1 strong, 4 underlined
# fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
# bg: 40 black, 41 red, 44 blue, 45 purple
e() {
    printf '\033[%sm%s\033[m\n' "$@"
}

me() {
    git_name="$(git config --global user.name)"
    git_email="$(git config --global user.email)"
    [[ -n "${git_name}" && -n "${git_email}" ]] && echo "${git_name} <${git_email}>"
}

my_pwd="$PWD"
now=`date +'%Y-%m-%d'`
backup_dir="${my_pwd}/dotfiles.old/${now}"
dotfiles="aliases bash_profile profile bash_prompt bashrc exports functions gitconfig vimrc"

cd $HOME

for dotfile in $dotfiles; do
    [ ! -d "$backup_dir" ] && mkdir -p $backup_dir

    if [ -f "$HOME/.$dotfile" ]; then
        mv "$HOME/.$dotfile" "$backup_dir/.$dotfile"
        e "33;5" "Backing up your .$dotfile"
    fi

    if [[ $dotfile = 'gitconfig' ]]; then
        cp "$my_pwd/.$dotfile" .
    elif [[ $dotfile = 'profile' ]]; then
        ln -s .bash_profile .profile
    else
        ln -s "$my_pwd/.$dotfile" .
    fi
done
unset dotfile

source ~/.bashrc

e "32;5" 'Your dotfiles are ready!'

if [ -d ~/.vim ]; then
    mv ~/.vim $backup_dir/.vim
fi

mkdir ~/.vim && cd ~/.vim

e "32;5" "Begin setup your vim plugins using pathogen"
mkdir -p autoload bundle && \
curl -LSso autoload/pathogen.vim https://tpo.pe/pathogen.vim && \
git init && \
git a && git c "Initial commit && install autoload/pathogen"

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
    git submodule -q add github:$repo $plugin && git a && git c "~/.vim/$plugin plugin installed"
done
unset repo plugin

cd $my_pwd
e "32;5" "Everything's done!"
e "32;5" "Your old files are backed up in $backup_dir"

if [[ -n "$(me)" ]]; then
    e "32;5" "Thank you $(me)"
    unset git_name git_email
else
    e "33;5" "Don't forget to setup your git user.name and user.email, Please run"
    e "33;5" ' $ git config --global user.name <your name>'
    e "33;5" ' $ git config --global user.email <your email>'
fi
