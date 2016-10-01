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

cd $HOME

if [ ! -f $HOME/.gitconfig ]; then
    cp -f $my_pwd/.gitconfig $HOME/.gitconfig
fi

for dotfile in $dotfiles; do
    [ ! -d "$backup_dir" ] && mkdir -p $backup_dir

    if [ -f "$HOME/.$dotfile" ]; then
        mv "$HOME/.$dotfile" "$backup_dir/.$dotfile"
        e "33;0" "Backing up your .$dotfile"
    fi

    ln -s "$my_pwd/.$dotfile" .
    
    if [[ $dotfile = 'profile' ]]; then
        [ ! -f $HOME/.bash_profile ] || rm $HOME/.bash_profile
        ln -s .profile .bash_profile
    fi
done
unset dotfile

if [ zsh >/dev/null 2>&1 ]; then
    e "32;0" "Installing Oh-my-ZSH"
    [ ! -d ~/.oh-my-zsh  ] && curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh -
    [ -f ~/.oh-my-zsh/themes/honukai.zsh-theme ] && rm ~/.oh-my-zsh/themes/honukai.zsh-theme
    ln -s  $my_pwd/.zsh-themes/honukai.zsh-theme ~/.oh-my-zsh/themes/
    [ -f ~/.zshrc ] && mv ~/.zshrc $backup_dir/
    ln -s $my_pwd/.zshrc ~/.zshrc
fi


if [ tmux >/dev/null 2>&1 ]; then
    [ -f ~/.tmux.conf ] && mv ~/.tmux.conf $backup_dir/
    ln -s $my_pwd/.tmux.conf ~/.tmux.conf
fi

source ~/.bashrc

e "32;0" 'Your dotfiles are ready to use!'

e "32;0" "Begin setup your VIM"

[ -d ~/.vim ] && mv ~/.vim $backup_dir/.vim
mkdir ~/.vim && cd ~/.vim

[ ! -d ~/.local/share/fonts ] && mkdir -p ~/.local/share/fonts
curl -LSso ~/.local/share/fonts/PowerlineSymbols.otf https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
fc-cache -f ~/.local/share/fonts

[ ! -d ~/.config/fontconfig/conf.d ] && mkdir -p ~/.config/fontconfig/conf.d
curl -LSso ~/.config/fontconfig/conf.d/10-powerline-symbols.conf https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf

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

me() {
    git_name="$(git config --global user.name)"
    git_email="$(git config --global user.email)"
    [[ -n "$git_name" && -n "$git_email" ]] && echo "$git_name <$git_email>"
}

cd $my_pwd
e "32;0" "Everything's done!"
e "32;0" "Your old files are backed up in $backup_dir"

if [[ -n "$(me)" ]]; then
    e "32;0" "Thank you $(me)"
    unset git_name git_email
else
    e "33;0" "Don't forget to setup your git user.name and user.email, Please run"
    e "33;0" ' $ git config --global user.name <your name>'
    e "33;0" ' $ git config --global user.email <your email>'
fi
