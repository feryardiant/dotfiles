#!/usr/bin/env bash
{
    # clear any previous sudo permission
    sudo -k

    # run inside sudo
    sudo sh <<SCRIPT
    if ! command -v vim >/dev/null 2>&1; then
        apt-get install vim -yqq
    else
        apt-get upgrade vim -yqq
    fi
SCRIPT
}
