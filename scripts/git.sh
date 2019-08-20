#!/usr/bin/env bash
{
    # clear any previous sudo permission
    sudo -k

    # run inside sudo
    sudo sh <<SCRIPT
    if ! command -v git >/dev/null 2>&1; then
        apt-get install git -yqq
    else
        apt-get upgrade git -yqq
    fi
SCRIPT
}
