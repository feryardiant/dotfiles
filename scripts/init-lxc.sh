#!/usr/bin/env bash

{
# clear any previous sudo permission
sudo -k

LANG="id_ID.UTF-8"

clear

printf 'Initializing your lxc container...\n'
printf 'This might take a while, sit back and relax\n'

# run inside sudo
sudo sh <<SCRIPT
printf ' - Configuring locale settings...'
locale-gen $LANG > /dev/null 2>&1
update-locale LC_ALL="$LANG" LANG="$LANG" > /dev/null 2>&1
dpkg-reconfigure --frontend noninteractive locales > /dev/null 2>&1
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
printf ' done\n'

printf ' - Checking for updates...'
apt update -qq > /dev/null 2>&1
printf ' done\n'

printf ' - Updating packages...'
apt dist-upgrade -qqy > /dev/null 2>&1
printf ' done\n'

printf ' - Installing basic tools...'
apt install -qqy --no-install-recommends gpg vim htop tree curl net-tools git unzip zip > /dev/null 2>&1
printf ' done\n'

printf ' - Adding user admin...'
adduser --disabled-password --gecos "" admin > /dev/null 2>&1
echo "admin:password" | chpasswd
usermod -aG adm,root,sudo,www-data admin
echo "admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/90-admin-users
mkdir /home/admin/.ssh
cat .ssh/authorized_keys > /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
chmod 700 /home/admin/.ssh
chmod 600 /home/admin/.ssh/*
printf ' done\n'

printf ' - Updating SSH configs...'
sed -iE "s~#PermitRootLogin .*~PermitRootLogin prohibit-password~" /etc/ssh/sshd_config
sed -iE "s~#PubkeyAuthentication .*~PubkeyAuthentication yes~" /etc/ssh/sshd_config
sed -iE "s~#PasswordAuthentication .*~PasswordAuthentication no~" /etc/ssh/sshd_config
sed -iE "s~#AllowAgentForwarding .*~AllowAgentForwarding yes~" /etc/ssh/sshd_config
sed -iE "s~#AllowTcpForwarding .*~AllowTcpForwarding yes~" /etc/ssh/sshd_config
sed -iE "s~#PermitTTY .*~PermitTTY yes~" /etc/ssh/sshd_config
systemctl start sshd
printf ' done\n'

printf ' - Updating VIM configs...'
update-alternatives --set editor /usr/bin/vim.basic > /dev/null 2>&1
cat >> /etc/vim/vimrc.local<< VIMRC
set nocompatible
filetype plugin indent on

set encoding=utf-8 nobomb  " BOM often causes trouble
set mouse=a                " Enable moouse in all in all modes
set noerrorbells           " Disable error bells
set ffs=unix,dos,mac       " Use Unix as the standard file type
set nohidden               " Close the buffer when tab is closed
set confirm                " Confirm before exit if file has changed
set nu relativenumber      " Enable line numbers

if has('wildmenu')
	set wildmenu
endif

set t_Co=256
hi! Comment ctermfg=240
hi! CursorLineNr ctermfg=255
hi! LineNr ctermfg=240
hi! StatusLine ctermbg=238
hi! Visual ctermbg=238

set wildmode=longest:full,full
set wildchar=<TAB>

" Searches
set hlsearch    " Highlight searches
set incsearch   " Highlight dynamically as pattern is typed
set ignorecase  " Ignore case of searches
set smartcase   " Ignore 'ignorecase' if search patter contains uppercase characters
set wrapscan    " Searches wrap around end of file
VIMRC

printf ' done\n'
SCRIPT

printf 'All done\n'
}
