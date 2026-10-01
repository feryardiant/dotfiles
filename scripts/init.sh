#!/usr/bin/env bash

# clear any previous sudo permission
sudo -k

clear

printf 'Initializing...\n'
printf 'This might take a while, sit back and relax\n'

# run inside sudo
(
    # sudo bash <<SCRIPT
    printf ' - Configure Localization...'
    locale-gen $LANG > /dev/null 2>&1
    update-locale LC_ALL="$LANG" LANG="$LANG" > /dev/null 2>&1
    dpkg-reconfigure --frontend noninteractive locales > /dev/null 2>&1
    ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
    printf ' done\n'

    export DEBIAN_FRONTEND=noninteractive

    # Apply changes
    printf ' - Update repositories...'
    apt update -qq > /dev/null 2>&1
    apt dist-upgrade -yqq > /dev/null 2>&1
    printf ' done\n'

    # Update
    # printf ' - Installing basic tools...'
    # apt install -yq --no-install-recommends git gpg vim tree net-tools unzip zip zsh
    # apt install -yq --no-install-recommends bat eza fzf ripgrep starship
    # printf ' done\n'

    # SCRIPT

    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
)
