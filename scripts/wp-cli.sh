#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sh <<SCRIPT
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v1.5.1/utils/wp-completion.bash

chmod +x wp-cli.phar

sudo mv wp-cli.phar /usr/local/bin/wp

[ ! -d $HOME/.wp-cli ] && mkdir $HOME/.wp-cli

touch $HOME/.wp-cli/config.yml
SCRIPT
}
