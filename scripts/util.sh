#!/usr/bin/env bash

# usage color "31;0" "string"
# 0 default, 1 strong, 4 underlined, 5 blink
# fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
# bg: 40 black, 41 red, 44 blue, 45 purple
c_err='41'
c_inf='33'
c_suc='32'
c_rst='37'
c_red='31'    # fail status
c_hl='1;33'   # yellow-bold highlight for names

e() {
	printf '\e[%sm%s\e[0m' "$@"
}

_err() {
	e $c_err "$1" | cat - 1>&2
}

# _c <color> <text> — colored on a TTY, plain otherwise (keeps test captures assertion-friendly)
_c() {
	if [ -t 1 ]; then e "$1" "$2"; else printf '%s' "$2"; fi
}

# One-line status protocol (console):
#   msg_begin [label] <name>  ->  '  [label ]<name>... '   (yellow-bold name, no newline)
#   msg_end   done|warn|fail  ->  colored status + newline
#   msg_hint  <file>          ->  '    See <file> for more info'
msg_begin() {
	if [ $# -eq 1 ]; then
		printf '  %s... ' "$(_c "$c_hl" "$1")"
	else
		printf '  %s %s... ' "$1" "$(_c "$c_hl" "$2")"
	fi
}

msg_end() {
	case "$1" in
		done) printf '%s\n' "$(_c "$c_suc" "done")" ;;
		warn) printf '%s\n' "$(_c "$c_inf" warn)" ;;
		fail) printf '%s\n' "$(_c "$c_red" fail)" ;;
		*)    printf '%s\n' "$1" ;;
	esac
}

msg_hint() {
	printf '    See %s for more info\n' "$1"
}
