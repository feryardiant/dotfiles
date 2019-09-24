#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

for userlocal in ~/.local/{bin,lib,share}; do
	[ ! -d $userlocal ] && mkdir -p $userlocal
done

# run inside sudo
sudo sh <<SCRIPT
printf ' - Localization...'
locale-gen $LANG > /dev/null 2>&1
update-locale LC_ALL="$LANG" LANG="$LANG"
dpkg-reconfigure --frontend noninteractive locales > /dev/null 2>&1
printf ' done\n'

printf ' - Add repositories...'
# Latest GIT
add-apt-repository ppa:git-core/ppa -y > /dev/null 2>&1

# Latest TMUX & VIM 8
add-apt-repository ppa:pi-rho/dev -y > /dev/null 2>&1

# Latest NeoVIM
add-apt-repository ppa:neovim-ppa/stable -y > /dev/null 2>&1
printf ' done\n'

# Apply changes
printf ' - Update repositories...'
apt-key update > /dev/null 2>&1
apt-get update -qq
printf ' done\n'

# Update
printf ' - Install dependencies...'
apt-get install python-pip python3-pip -y > /dev/null

printf ' done\n'
SCRIPT
}
