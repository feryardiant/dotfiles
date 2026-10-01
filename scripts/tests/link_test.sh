#!/usr/bin/env bash
# Run: bash scripts/tests/link_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LINK="$ROOT/scripts/link.sh"
. "$ROOT/scripts/tests/harness.sh"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT

# 1) Real corpus in a sandbox HOME — every mapping visited, none failed (Review Focus 4)
mkdir -p "$FIX/home1"
out1=$(LINK_ROOT="$FIX/home1" DOTFILES_DIR="$ROOT" bash "$LINK" 2>&1); rc1=$?
t corpus 'exits zero on the real corpus' "0" "$rc1"
sum=$(printf '%s\n' "$out1" | tail -1)
t corpus 'reports zero failed links' "0" "$(printf '%s' "$sum" | sed -n 's/.* \([0-9][0-9]*\) failed.*/\1/p')"
total=$(printf '%s\n' "$out1" | grep -cE '^  (linked|in place|gated|would|copied|missing) ')
t corpus 'visits all 23 mappings' "23" "$total"
gated=$(printf '%s' "$sum" | sed -n 's/.* \([0-9][0-9]*\) gated.*/\1/p')
[ "${gated:-0}" -gt 0 ] && g=1 || g=0
t corpus 'gates `wakatime-cli` (not installed here)' "1" "$g"

# 2) Idempotency: second run links nothing
out2=$(LINK_ROOT="$FIX/home1" DOTFILES_DIR="$ROOT" bash "$LINK" 2>&1); rc2=$?
t rerun 'exits zero on the second run' "0" "$rc2"
t rerun 'links nothing on the second run' "0" "$(printf '%s\n' "$out2" | tail -1 | sed -n 's/^\([0-9][0-9]*\) linked.*/\1/p')"

# 3) Parse failure propagates
mkdir -p "$FIX/repo/config/bad"
printf -- '---\nmaps:\n  ~/.x: {src: y}\n---\n' > "$FIX/repo/config/bad/README.md"
out3=$(LINK_ROOT="$FIX/home2" DOTFILES_DIR="$FIX/repo" bash "$LINK" 2>&1); rc3=$?
t parse 'inline object form fails the run' "1" "$rc3"
printf '%s' "$out3" | grep -q "inline object form" && m=1 || m=0
t parse 'explains the parse error' "1" "$m"

# 4) Missing source = warning, not failure (schema rule)
mkdir -p "$FIX/repo2/config/gone"
printf -- '---\nmaps:\n  ~/.gone: private.cfg\n---\n' > "$FIX/repo2/config/gone/README.md"
out4=$(LINK_ROOT="$FIX/home3" DOTFILES_DIR="$FIX/repo2" bash "$LINK" 2>&1); rc4=$?
t missing 'missing source warns but exits zero' "0" "$rc4"
printf '%s\n' "$out4" | grep -q "missing ~/.gone" && m=1 || m=0
t missing 'names the missing destination' "1" "$m"

# 5) Dry-run writes nothing
mkdir -p "$FIX/home4"
LINK_ROOT="$FIX/home4" DOTFILES_DIR="$ROOT" bash "$LINK" --dry-run >/dev/null 2>&1; rc5=$?
t dry-run 'exits zero' "0" "$rc5"
n=$(find "$FIX/home4" \( -type l -o -type f \) | wc -l | tr -d ' ')
t dry-run 'writes nothing to the sandbox' "0" "$n"

finish link_test
