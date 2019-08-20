#!/usr/bin/env bash

set -e

. ./scripts/util.sh

my_pwd="$PWD"
now=`date +'%Y-%m-%d_%H-%M-%S'`
backup_dir=$my_pwd/dotfiles.old/$now

# Create backup dir if not exists
[[ ! -d $backup_dir ]] && mkdir -p $backup_dir

_resque() {
	if [ -f $1 ]; then
		if [ -L $1 ]; then
			rm -f $1
		else
			mv -f $1 $backup_dir/
		fi
	fi
}

# Initialize
e $c_inf 'Configure'
# . $my_pwd/scripts/init.sh > /dev/null 2>&1
e $c_suc $' ✔ Done\n'

cd $HOME

# ------------------------------------------------------------------------------
# Basic
# ------------------------------------------------------------------------------

e $c_inf 'Setup dotfiles'

# Setup
dotfiles="aliases profile bash_prompt bashrc exports functions"
for dotfile in $dotfiles; do
	_resque ~/.$dotfile
	ln -sf $my_pwd/.$dotfile .
done

# Cleanup
unset dotfile dorfiles

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# ENV
# ------------------------------------------------------------------------------

e $c_inf 'Setup .env'

envContent="`cat $my_pwd/.env.sample`"

if [ -f ~/.env ]; then
	mv -f ~/.env $backup_dir/
	envContent="$envContent"$'\n\n'"$(cat $backup_dir/.env)"
fi

echo "$envContent" | sed -i "s/export DOTFILES_DIR=/export DOTFILES_DIR=$my_pwd/g" > ~/.env

# source ~/.bashrc

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# GIT
# ------------------------------------------------------------------------------

e $c_inf 'Setup git'

# Installing
# . $my_pwd/scripts/git.sh > /dev/null

if [ -f ~/.gitconfig ]; then
	git_email="`git config --global user.email`"
	git_name="`git config --global user.name`"
fi

# Backup
_resque ~/.gitconfig

# Setup
cp -f $my_pwd/.gitconfig ~/.gitconfig

# Restore default user name & email
[[ ! -z $git_email ]] && git config --global user.email "$git_email"
[[ ! -z $git_name ]] && git config --global user.name "$git_name"

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# TMUX
# ------------------------------------------------------------------------------

e $c_inf 'Setup TMUX'

# Installing
. $my_pwd/scripts/tmux.sh > /dev/null

# Backup
_resque ~/.tmux.conf

# Setup
ln -sf $my_pwd/.tmux.conf ~/.tmux.conf

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# ZSH
# ------------------------------------------------------------------------------

if _has_pkg 'zsh'; then
	e $c_inf 'Setup oh-my-zsh'

	zsh_dir=~/.oh-my-zsh
	[ ! -d $zsh_dir ] && git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $zsh_dir
	[ -d $zsh_dir/themes ] && ln -sf $my_pwd/zsh-themes/honukai.zsh-theme $zsh_dir/themes/
	_resque ~/.zshrc && ln -sf $my_pwd/.zshrc ~/.zshrc

	cd $zsh_dir && git add themes && git commit -q -m "Add honukai.zsh-theme"
	cd $HOME

	e $c_suc $' ✔ Done\n'
else
	e $c_inf 'Setup bash_profile'
	_resque ~/.bash_profile && ln -sf .profile .bash_profile
	e $c_suc $' ✔ Done\n'
fi

# ------------------------------------------------------------------------------
# VIM
# ------------------------------------------------------------------------------

e $c_inf 'Setup VIM'

# Setup
vim_dirs="swap undo backup"
for vim_dir in $vim_dirs; do
	[ -d ~/.cache/vim/$vim_dir ] || mkdir -p ~/.cache/vim/$vim_dir
done

if _has_pkg 'nvim'; then
	[ -d ~/.config/nvim ] || mkdir ~/.config/nvim

	vim_bin=`which nvim`
	plug_path='.local/share/nvim/site/autoload'
	vimrc_path='.config/nvim/init.vim'
else
	. $my_pwd/scripts/vim.sh > /dev/null

	vim_bin=`which vim`
	plug_path='.vim/autoload'
	vimrc_path='.vimrc'
fi

sudo update-alternatives --install /usr/bin/editor editor $vim_bin 60 > /dev/null

_resque ~/$vimrc_path && ln -sf $my_pwd/.vimrc ~/$vimrc_path
_resque ~/$plug_path/plug.vim && \
curl -LSso ~/$plug_path/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Clean up
unset plug_path vimrc_path vim_bin vim_dir vim_dirs

e $c_suc $' ✔ Done\n'

# ------------------------------------------------------------------------------
# DONE
# ------------------------------------------------------------------------------

cd $my_pwd
e $c_suc $'\nEverything is done ✔\n'
e $c_rst 'Your old files are backed up in '
e $c_inf "=> $backup_dir"$'\n'
e $c_rst 'Thank you'
[[ ! -z $git_name ]] && e $c_inf ' $git_name'
[[ ! -z $git_email ]] && e $c_inf ' <$git_email>'
echo $'\n'
