#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
add-apt-repository ppa:ondrej/apache2 -y > /dev/null 2>&1
apt-get update -qq
SCRIPT
}
