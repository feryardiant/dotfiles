#!/usr/bin/env bash
# Run: bash scripts/tests/link_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LINK="$ROOT/scripts/link.sh"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT
FAILS=0
ck() { # ck <name> <expected> <actual>
  if [ "$2" = "$3" ]; then printf 'ok - %s\n' "$1"
  else FAILS=$((FAILS+1)); printf 'NOT OK - %s (want [%s], got [%s])\n' "$1" "$2" "$3"; fi
}

# 1) Real corpus in a sandbox HOME — every mapping visited, none failed (Review Focus 4)
mkdir -p "$FIX/home1"
out1=$(LINK_ROOT="$FIX/home1" DOTFILES_DIR="$ROOT" bash "$LINK" 2>&1); rc1=$?
ck "corpus: exit 0" "0" "$rc1"
sum=$(printf '%s\n' "$out1" | tail -1)
ck "corpus: 0 failed" "0" "$(printf '%s' "$sum" | sed -n 's/.* \([0-9][0-9]*\) failed.*/\1/p')"
total=$(printf '%s\n' "$out1" | grep -cE '^  (linked|in place|gated|would|copied|missing) ')
ck "corpus: all 23 mappings visited" "23" "$total"
gated=$(printf '%s' "$sum" | sed -n 's/.* \([0-9][0-9]*\) gated.*/\1/p')
[ "${gated:-0}" -gt 0 ] && g=1 || g=0
ck "corpus: gated>0 (wakatime-cli absent here)" "1" "$g"

# 2) Idempotency: second run links nothing
out2=$(LINK_ROOT="$FIX/home1" DOTFILES_DIR="$ROOT" bash "$LINK" 2>&1); rc2=$?
ck "rerun: exit 0" "0" "$rc2"
ck "rerun: 0 linked" "0" "$(printf '%s\n' "$out2" | tail -1 | sed -n 's/^\([0-9][0-9]*\) linked.*/\1/p')"

# 3) Parse failure propagates
mkdir -p "$FIX/repo/config/bad"
printf -- '---\nmaps:\n  ~/.x: {src: y}\n---\n' > "$FIX/repo/config/bad/README.md"
out3=$(LINK_ROOT="$FIX/home2" DOTFILES_DIR="$FIX/repo" bash "$LINK" 2>&1); rc3=$?
ck "parse error: exit 1" "1" "$rc3"
printf '%s' "$out3" | grep -q "inline object form" && m=1 || m=0
ck "parse error: message shown" "1" "$m"

# 4) Missing source = warning, not failure (schema rule)
mkdir -p "$FIX/repo2/config/gone"
printf -- '---\nmaps:\n  ~/.gone: private.cfg\n---\n' > "$FIX/repo2/config/gone/README.md"
out4=$(LINK_ROOT="$FIX/home3" DOTFILES_DIR="$FIX/repo2" bash "$LINK" 2>&1); rc4=$?
ck "missing src: exit 0" "0" "$rc4"
printf '%s\n' "$out4" | grep -q "missing ~/.gone" && m=1 || m=0
ck "missing src: warned" "1" "$m"

# 5) Dry-run writes nothing
mkdir -p "$FIX/home4"
LINK_ROOT="$FIX/home4" DOTFILES_DIR="$ROOT" bash "$LINK" --dry-run >/dev/null 2>&1; rc5=$?
ck "dry-run: exit 0" "0" "$rc5"
n=$(find "$FIX/home4" \( -type l -o -type f \) | wc -l | tr -d ' ')
ck "dry-run: sandbox untouched" "0" "$n"

printf '\nlink_test: %d failures\n' "$FAILS"
[ "$FAILS" -eq 0 ]
