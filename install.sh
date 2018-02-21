#!/usr/bin/env bash

set -e

e() {
    printf '\e[%sm%s\e[0m' "$@"
}

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
        e $c_err " We need $program but it's not installed. "$'\n'
        exit 1
    fi
done
unset requirements program

git_email=`git config --global user.email`
git_name=`git config --global user.name`

if [[ -z $git_email || -z $git_name ]]; then
    e $c_err $' Please setup your git config email and name first \n'
    e $c_err $' Use:                                              \n'
    e $c_err $'   - git config --global user.email <your-email>   \n'
    e $c_err $'   - git config --global user.name <your-name>     \n'
    exit 1
fi

[[ ! -d $backup_dir ]] && mkdir -p $backup_dir

if command -v zsh >/dev/null 2>&1; then
    e $c_inf 'Setup oh-my-zsh'

    zsh_dir=~/.oh-my-zsh
    [ ! -d $zsh_dir ] && git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $zsh_dir
    [ -d $zsh_dir/themes ] && ln -sf $my_pwd/zsh-themes/honukai.zsh-theme $zsh_dir/themes/
    [ -f ~/.zshrc ] && mv -f ~/.zshrc $backup_dir/
    ln -s $my_pwd/.zshrc ~/.zshrc

    cd $zsh_dir && git checkout -q -b local && \
    git add themes && git commit -q -m "Add honukai.zsh-theme"

    e $c_suc $' ✔ Done\n'
fi

e $c_inf 'Setup dotfiles'

cd $HOME

dotfiles="aliases profile bash_prompt bashrc exports functions vimrc"
for dotfile in $dotfiles; do
    _resque ~/.$dotfile

    ln -s $my_pwd/.$dotfile .

    if [[ -z $ZSH_VERSION && $dotfile = 'profile' ]]; then
        [ ! -f ~/.bash_profile ] || mv -f ~/.bash_profile $backup_dir/
        ln -s .profile .bash_profile
    fi
done
unset dotfile dorfiles

e $c_suc $' ✔ Done\n'

if command -v tmux >/dev/null 2>&1; then
    e $c_inf 'Setup tmux config'

    _resque ~/.tmux.conf
    ln -s $my_pwd/.tmux.conf ~/.tmux.conf

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
e $c_inf $'Setup VIM\n'

[ -d ~/.vim ] && mv -f ~/.vim $backup_dir/
mkdir ~/.vim && cd ~/.vim

vim_dirs="swap undo backup"
for vim_dir in $vim_dirs; do
    [ -d ~/.cache/vim/$vim_dir ] || mkdir -p ~/.cache/vim/$vim_dir
done
unset vim_dir vim_dirs

e $c_rst '- Installing pathogen'

mkdir -p autoload bundle && curl -LSso autoload/pathogen.vim https://tpo.pe/pathogen.vim && \
git init -q && git a && git c "Initial commit && install autoload/pathogen" -q

e $c_suc $' ✔ Done\n'

declare -A plugins
plugins[mattn/emmet-vim]=emmet
plugins[scrooloose/nerdtree]=nerdtree
plugins[tpope/vim-fugitive]=fugitive
plugins[gregsexton/gitv]=gitv
plugins[tpope/vim-surround]=surround
plugins[w0rp/ale]=ale
plugins[kien/ctrlp.vim]=ctrlp
plugins[Lokaltog/vim-easymotion]=easymotion
plugins[godlygeek/tabular]=tabular
plugins[ervandew/supertab]=supertab
plugins[reedes/vim-pencil]=pencil
plugins[roxma/nvim-yarp]=nvim-yarp
plugins[roxma/vim-hug-neovim-rpc]=vim-hug-neovim-rpc
plugins[Shougo/deoplete.nvim]=deoplete
plugins[shawncplus/phpcomplete.vim]=phpcomplete
plugins[terryma/vim-multiple-cursors]=multiple-cursors
plugins[vim-airline/vim-airline]=airline
plugins[vim-airline/vim-airline-themes]=airline-themes
plugins[joonty/vdebug]=vdebug
plugins[Yggdroot/indentLine]=indent-lint
plugins[ayu-theme/ayu-vim]=ayu-vim
plugins[matze/vim-move]=vim-move
plugins[posva/vim-vue]=vim-vue

if [[ -f ~/wakatime.cfg ]]; then
    plugins[wakatime/vim-wakatime]=wakatime
fi

for repo in ${!plugins[@]}; do
    plugin=${plugins[$repo]}

    # still can't found it working
    #len=$((20 - ${#plugin}))
    #spaces=`printf '%.0s ' {1..$len}`

    e $c_rst "- Installing $plugin"
    git submodule -q add github:$repo bundle/$plugin
    git a && git c "$plugin plugin is installed" -q
    e $c_suc $' ✔ Done\n'
done
unset repo plugin

e $c_inf "Finishing VIM setup"
cd ~/.vim/ && git submodule update --init --recursive -q
e $c_suc $' ✔ Done\n'
# cd ~/.vim/bundle/completeme && python3 install.py --js-completer --clang-completer > /dev/null

cd $my_pwd
e $c_suc $'\nEverything is done ✔\n'
e $c_rst 'Your old files are backed up in '
e $c_inf "$backup_dir"$'\n'
e $c_rst 'Thank you '
e $c_inf "$git_name <$git_email>"$'\n'
