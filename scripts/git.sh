#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
# Latest GIT
add-apt-repository ppa:git-core/ppa -y > /dev/null 2>&1

if ! command -v git >/dev/null 2>&1; then
	apt-get install git -yqq
else
	apt-get upgrade git -yqq
fi

curl -LSso ~/.local/tools/git-prompt.sh --create-dirs \
https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
SCRIPT
}
