#!/usr/bin/env bash

set -e

# usage color "31;0" "string"
# 0 default, 1 strong, 4 underlined, 5 blink
# fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
# bg: 40 black, 41 red, 44 blue, 45 purple
c_err='41'
c_inf='33'
c_suc='32'
c_rst='37'

my_pwd="$PWD"
now=`date +'%Y-%m-%d_%H-%M-%S'`
backup_dir=$my_pwd/dotfiles.old/$now

e() {
    printf '\e[%sm%s\e[0m' "$@"
}

_err() {
   e $c_err $@ | cat - 1>&2
}

_resque() {
    if [ -f $1 ] && [ ! -L $1 ]; then
        mv -f $1 $backup_dir/
    elif [ -f $1 ] && [ -L $1 ]; then
        rm -f $1
    fi
}

requirements="git curl vim"
for program in $requirements; do
    if ! command -v $program >/dev/null 2>&1; then
        _err " We need $program but it's not installed. "$'\n'
        exit 1
    fi
done
unset requirements program

git_email=`git config --global user.email`
git_name=`git config --global user.name`

if [[ -z $git_email || -z $git_name ]]; then
    _err $' Please setup your git config email and name first \n'
    _err $' Use:                                              \n'
    _err $'   - git config --global user.email <your-email>   \n'
    _err $'   - git config --global user.name <your-name>     \n'
    exit 1
fi

[[ ! -d $backup_dir ]] && mkdir -p $backup_dir

if command -v zsh >/dev/null 2>&1; then
    e $c_inf 'Setup oh-my-zsh'

    zsh_dir=~/.oh-my-zsh
    [ ! -d $zsh_dir ] && git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $zsh_dir
    [ -d $zsh_dir/themes ] && ln -sf $my_pwd/zsh-themes/honukai.zsh-theme $zsh_dir/themes/
    _resque ~/.zshrc && ln -sf $my_pwd/.zshrc ~/.zshrc

    cd $zsh_dir && git checkout -q -b local && \
    git add themes && git commit -q -m "Add honukai.zsh-theme"

    e $c_suc $' ✔ Done\n'
fi

e $c_inf 'Setup dotfiles'

cd $HOME

dotfiles="aliases profile bash_prompt bashrc exports functions hyper.js"
for dotfile in $dotfiles; do
    _resque ~/.$dotfile

    ln -sf $my_pwd/.$dotfile .

    if [[ -z $ZSH_VERSION && $dotfile = 'profile' ]]; then
        _resque ~/.bash_profile && ln -sf .profile .bash_profile
    fi
done
unset dotfile dorfiles

e $c_suc $' ✔ Done\n'

if command -v tmux >/dev/null 2>&1; then
    e $c_inf 'Setup tmux config'

    _resque ~/.tmux.conf
    ln -sf $my_pwd/.tmux.conf ~/.tmux.conf

    e $c_suc $' ✔ Done\n'
fi

. ~/.bashrc

e $c_inf 'Setup git config'

_resque ~/.gitconfig
cp -f $my_pwd/.gitconfig ~/.gitconfig

git config --global user.email "$git_email"
git config --global user.name "$git_name"

e $c_suc $' ✔ Done\n'
e $c_inf 'Setup Powerline Fonts'

declare -A powerline
powerline[PowerlineSymbols.otf]=~/.local/share/fonts
powerline[10-powerline-symbols.conf]=~/.config/fontconfig/conf.d

for font in ${!powerline[@]}; do
    installdir=${powerline[$font]}

    [ -d $installdir ] || mkdir -p $installdir
    [ -f $installdir/$font ] || curl -LSso $installdir/$font https://github.com/powerline/powerline/raw/develop/font/$font

    command -v fc-cache >/dev/null 2>&1 && fc-cache -f $installdir
done
unset powerline font installdir

e $c_suc $' ✔ Done\n'
e $c_inf 'Setup VIM'

vim_dirs="swap undo backup"
for vim_dir in $vim_dirs; do
    [ -d ~/.cache/vim/$vim_dir ] || mkdir -p ~/.cache/vim/$vim_dir
done
unset vim_dir vim_dirs

if command -v nvim >/dev/null 2>&1; then
    plug_path='.local/share/nvim/site/autoload'
    vimrc_path='.config/nvim/init.vim'
    mkdir ~/.config/nvim
else
    plug_path='.vim/autoload'
    vimrc_path='.vimrc'
fi

_resque ~/$vimrc_path && ln -sf $my_pwd/.vimrc ~/$vimrc_path
_resque ~/$plug_path/plug.vim && \
curl -LSso ~/$plug_path/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
unset plug_path vimrc_path

e $c_suc $' ✔ Done\n'

cd $my_pwd
e $c_suc $'\nEverything is done ✔\n'
e $c_rst 'Your old files are backed up in '
e $c_inf "$backup_dir"$'\n'
e $c_rst 'Thank you '
e $c_inf "$git_name <$git_email>"$'\n'
