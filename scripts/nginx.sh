#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
add-apt-repository ppa:ondrej/nginx -y > /dev/null 2>&1
apt-get update -qq

if ! command -v nginx >/dev/null 2>&1; then
	apt-get install nginx -yqq
else
	apt-get upgrade nginx -yqq
fi
SCRIPT
}
