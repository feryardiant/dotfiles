#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install nodejs
SCRIPT
}
