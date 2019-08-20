#!/usr/bin/env bash

# usage color "31;0" "string"
# 0 default, 1 strong, 4 underlined, 5 blink
# fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
# bg: 40 black, 41 red, 44 blue, 45 purple
c_err='41'
c_inf='33'
c_suc='32'
c_rst='37'

e() {
    printf '\e[%sm%s\e[0m' "$@"
}

_err() {
   e $c_err "$1" | cat - 1>&2
}

_has_pkg() {
    command -v $1 >/dev/null 2>&1
}
