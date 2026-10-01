#!/usr/bin/env bash
# Run: bash scripts/tests/plugin_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT
FAILS=0
ck() { if [ "$2" = "$3" ]; then printf 'ok - %s\n' "$1"; else FAILS=$((FAILS+1)); printf 'NOT OK - %s (want [%s], got [%s])\n' "$1" "$2" "$3"; fi; }

mkdir -p "$FIX/bin"
cat > "$FIX/bin/brew" <<'STUB'
#!/usr/bin/env bash
case "$1" in
  list) exit 1 ;;
  install) shift; [ "$1" = -y ] && shift; echo "BREW $*" >> "$HOME/p.log" ;;
esac
STUB
cat > "$FIX/bin/apt-get" <<'STUB'
#!/usr/bin/env bash
[ "$1" = install ] && echo "APT_CALL_MARKER $*" >> "$HOME/p.log"
exit 0
STUB
cat > "$FIX/bin/dpkg" <<'STUB'
#!/usr/bin/env bash
[ "$1" = -i ] && exit 0   # .deb install succeeds
exit 1                    # -s probe: not installed
STUB
cat > "$FIX/bin/sudo" <<'STUB'
#!/usr/bin/env bash
exec "$@"
STUB
chmod +x "$FIX/bin/"*

for t in starship eza fzf zoxide; do
  bash -n "$ROOT/scripts/setup.d/$t.sh" && ck "bash -n $t" 0 0 || ck "bash -n $t" 0 1
done

# mac path: all four via brew (CLEAN PATH hides host's real installs)
CLEAN="$FIX/bin:/usr/bin:/bin"
mkdir -p "$FIX/h"
HOME="$FIX/h" PATH="$CLEAN" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" \
  bash -c 'for t in starship eza fzf zoxide; do bash "'"$ROOT"'/scripts/setup.d/$t.sh"; done' >/dev/null
ck "mac: all four via brew" "4" "$(grep -c '^BREW ' "$FIX/h/p.log" 2>/dev/null || echo 0)"

# presence check: fake installed binary -> no install attempt
mkdir -p "$FIX/h2/.local/bin"
for t in starship eza fzf zoxide; do printf '#!/bin/sh\n' > "$FIX/h2/.local/bin/$t"; chmod +x "$FIX/h2/.local/bin/$t"; done
out=$(HOME="$FIX/h2" PATH="$FIX/h2/.local/bin:$CLEAN" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" \
  bash "$ROOT/scripts/setup.d/starship.sh")
ck "present: skip" "  starship... done" "$out"

# linux path: fzf + zoxide via apt (2 markers), starship + eza via curl installers
mkdir -p "$FIX/h3"
cat > "$FIX/bin/curl" <<'STUB'
#!/usr/bin/env bash
# piped installers execute our stdout; -o downloads are recorded directly
out=""; prev=""
for a in "$@"; do
  if [ "$prev" = "-o" ]; then out="$a"; fi
  prev="$a"
done
if [ -n "$out" ]; then
  printf 'stub payload\n' > "$out"
  echo SHERAN >> "$HOME/p.log"
else
  echo 'echo SHERAN >> "$HOME/p.log"'
fi
STUB
chmod +x "$FIX/bin/curl"
HOME="$FIX/h3" PATH="$CLEAN" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" \
  bash -c 'for t in starship eza fzf zoxide; do bash "'"$ROOT"'/scripts/setup.d/$t.sh"; done' >/dev/null 2>&1 || true
ck "linux: apt install calls (fzf+zoxide)" "2" "$(grep -c 'APT_CALL_MARKER' "$FIX/h3/p.log" 2>/dev/null || echo 0)"
ck "linux: curl installers ran (starship+eza)" "2" "$(grep -c SHERAN "$FIX/h3/p.log" 2>/dev/null || echo 0)"

printf '\nplugin_test: %d failures\n' "$FAILS"
[ "$FAILS" -eq 0 ]
