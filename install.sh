#!/usr/bin/env bash

set -e

# usage color "31;0" "string"
# 0 default, 1 strong, 4 underlined, 5 blink
# fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
# bg: 40 black, 41 red, 44 blue, 45 purple
e() {
    printf '\033[%sm%s\033' "$@"
}

my_pwd="$PWD"
now=`date +'%Y-%m-%d_%H-%M-%S'`
backup_dir=~/dotfiles.old/$now

requirements="git curl vim"
for program in $requirements; do
    if ! command -v $program >/dev/null 2>&1; then
        e '31' "We need $program but it's not installed."
        exit 1
    fi
done
unset requirements program

e '33' 'Setup dotfiles'

cd $HOME

dotfiles="aliases profile bash_prompt bashrc exports functions vimrc"
for dotfile in $dotfiles; do
    [[ ! -d $backup_dir ]] && mkdir -p $backup_dir

    if [ -f ~/.$dotfile ]; then
        mv -f ~/.$dotfile $backup_dir/
    fi

    ln -s $my_pwd/.$dotfile .

    if [[ $dotfile = 'profile' ]]; then
        [ ! -f ~/.bash_profile ] || mv -f ~/.bash_profile $backup_dir/
        ln -s .profile .bash_profile
    fi
done
unset dotfile dorfiles

e '32' $' ✔ Done\n'

if command -v zsh >/dev/null 2>&1; then
    e '33' 'Setup oh-my-zsh'
    [ -d ~/.oh-my-zsh ] || curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh -
    [ -f ~/.oh-my-zsh/themes/honukai.zsh-theme ] && rm ~/.oh-my-zsh/themes/honukai.zsh-theme
    ln -s  $my_pwd/.zsh-themes/honukai.zsh-theme ~/.oh-my-zsh/themes/
    [ -f ~/.zshrc ] && mv -f ~/.zshrc $backup_dir/
    ln -s $my_pwd/.zshrc ~/.zshrc
    e '32' $' ✔ Done\n'
fi

if command -v tmux >/dev/null 2>&1; then
    e '33' 'Setup tmux config'
    [ -f ~/.tmux.conf ] && mv -f ~/.tmux.conf $backup_dir/
    ln -s $my_pwd/.tmux.conf ~/.tmux.conf
    e '32' $' ✔ Done\n'
fi

source ~/.bashrc

e '33' 'Setup git config'

if [ -f $HOME/.gitconfig ]; then
    git_email=`git config --global user.email`
    git_name=`git config --global user.name`
    mv -f ~/.gitconfig $backup_dir/
fi

cp -f $my_pwd/.gitconfig ~/.gitconfig

if [[ ! -n "$git_email" && ! -n "$git_name" ]]; then
    git config --global user.email "$git_email"
    git config --global user.name "$git_name"
fi

e '32' $' ✔ Done\n'
e '33' 'Setup Powerline Fonts'

declare -A powerline
powerline[PowerlineSymbols.otf]=~/.local/share/fonts
powerline[10-powerline-symbols.conf]=~/.config/fontconfig/conf.d

for font in ${!powerline[@]}; do
    installdir=${powerline[$font]}

    [ -d $installdir ] || mkdir -p $installdir
    [ -f $installdir/$font ] || curl -LSso $installdir/$font https://github.com/powerline/powerline/raw/develop/font/$font
done
unset powerline font installdir

command -v fc-cache >/dev/null 2>&1 && fc-cache -f ~/.local/share/fonts

e '32' $' ✔ Done\n'
e '33' $'Setup VIM\n'

[ -d ~/.vim ] && mv -f ~/.vim $backup_dir/
mkdir ~/.vim && cd ~/.vim

vim_dirs="swap undo backup"
for vim_dir in $vim_dirs; do
    [ -d ~/.cache/vim/$vim_dir ] || mkdir -p ~/.cache/vim/$vim_dir
done
unset vim_dir vim_dirs

e "37" '- Installing pathogen'

mkdir -p autoload bundle && curl -LSso autoload/pathogen.vim https://tpo.pe/pathogen.vim && \
git init > /dev/null && git a && git c "Initial commit && install autoload/pathogen" > /dev/null

e '32' $' ✔ Done\n'

declare -A plugins
plugins[mattn/emmet-vim]=emmet
plugins[scrooloose/nerdtree]=nerdtree
plugins[tpope/vim-fugitive]=fugitive
plugins[tpope/vim-surround]=surround
plugins[scrooloose/syntastic]=syntastic
plugins[kien/ctrlp.vim]=ctrlp
plugins[Lokaltog/vim-easymotion]=easymotion
plugins[ervandew/supertab]=supertab
plugins[reedes/vim-pencil]=pencil
plugins[Shougo/neocomplcache.vim]=neocomplcache
plugins[terryma/vim-multiple-cursors]=multiple-cursors
plugins[vim-airline/vim-airline]=vim-airline
plugins[vim-airline/vim-airline-themes]=vim-airline-themes

for repo in ${!plugins[@]}; do
    plugin=${plugins[$repo]}

    # still can't found it working
    #len=$((20 - ${#plugin}))
    #spaces=`printf '%.0s ' {1..$len}`

    e '37' "- Installing $plugin"
    git submodule -q add github:$repo bundle/$plugin
    git a && git c "$plugin plugin is installed" > /dev/null
    e '32' $' ✔ Done\n'
done
unset repo plugin message

cd $my_pwd
e '32' '✔ Everything is done! '
e '37' 'Your old files are backed up in '
e '33' "$backup_dir"$'\n'
e '37' 'Thank you '
e '33' "$git_name <$git_email>"$'\n'
