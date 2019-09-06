#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sh <<SCRIPT
curl -L https://phar.io/releases/phive.phar > phive.phar
curl -L https://phar.io/releases/phive.phar.asc > phive.phar.asc

gpg --keyserver pool.sks-keyservers.net --recv-keys 0x9D8A98B29B2D5D79
gpg --verify phive.phar.asc phive.phar

chmod +x phive.phar

mv phive.phar /usr/local/bin/phive
SCRIPT
}
