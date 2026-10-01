#!/usr/bin/env bash
# Shared assertion harness for scripts/tests/*_test.sh:
#   t <scope> <aspect> <expected> <actual>    value assertion (scope may be "")
#   x <scope> <aspect> <want-exit> <cmd...>   exit-code assertion
#   finish <suite>                            summary line; script exits 0/1
# Output on every assertion:  [PASS|FAIL] scope - aspect
# Aspect markup — rendered on a TTY, stripped when piped:
#   **text**  bold key term
#   `text`    yellow-bold literal

H_RUN=0
H_FAIL=0

_H_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_H_DIR/../util.sh"
unset _H_DIR

# _emit <text> — expand (TTY) or strip (pipe) **bold** / `literal` markup
_emit() {
  local esc=$'\033'
  if [ -t 1 ]; then
    printf '%s' "$1" | sed -E \
      -e 's/\*\*([^*]+)\*\*/'"$esc"'[1m\1'"$esc"'[0m/g' \
      -e 's/`([^`]+)`/'"$esc"'[1;33m\1'"$esc"'[0m/g'
  else
    printf '%s' "$1" | sed -E -e 's/\*\*//g' -e 's/`//g'
  fi
}

# _line <PASS|FAIL> <scope> <aspect>
_line() {
  printf '['
  if [ "$1" = PASS ]; then _c "$c_suc" PASS; else _c "$c_red" FAIL; fi
  printf '] '
  if [ -n "$2" ]; then
    _c 1 "$2"
    printf ' - '
  fi
  _emit "$3"
  printf '\n'
}

# t <scope> <aspect> <expected> <actual>
t() {
  H_RUN=$((H_RUN + 1))
  if [ "$3" = "$4" ]; then
    _line PASS "$1" "$2"
  else
    H_FAIL=$((H_FAIL + 1))
    _line FAIL "$1" "$2"
    printf '  want: [%s]\n  got:  [%s]\n' "$3" "$4"
  fi
}

# x <scope> <aspect> <want-exit> <cmd...>
x() {
  H_RUN=$((H_RUN + 1))
  local scope=$1 aspect=$2 want=$3 got
  shift 3
  "$@" >/dev/null 2>&1
  got=$?
  if [ "$want" = "$got" ]; then
    _line PASS "$scope" "$aspect"
  else
    H_FAIL=$((H_FAIL + 1))
    _line FAIL "$scope" "$aspect"
    printf '  want: [%s]\n  got:  [%s]\n' "$want" "$got"
  fi
}

# finish <suite> — summary line; returns 0 when everything passed
finish() {
  printf '\n%s: %d tests, %d failures\n' "$1" "$H_RUN" "$H_FAIL"
  [ "$H_FAIL" -eq 0 ]
}
