#!/usr/bin/env bash
# Run: bash scripts/tests/plugin_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT
FAILS=0
ck() {
  if [ "$2" = "$3" ]; then
    printf 'ok - %s\n' "$1"
  else
    FAILS=$((FAILS+1))
    printf 'NOT OK - %s (want [%s], got [%s])\n' "$1" "$2" "$3"
  fi
}

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

# fixture-only PATH: the utilities scripts need (shebang env resolves bash here),
# but no real installs — hides the host's tools and anything apt put in /usr/bin
for u in bash sh env dirname uname mkdir rm cp ln chmod tar sed grep cat install touch; do
  ln -sf "$(command -v "$u")" "$FIX/bin/$u"
done

for t in starship eza fzf zoxide; do
  bash -n "$ROOT/scripts/setup.d/$t.sh" && ck "bash -n $t" 0 0 || ck "bash -n $t" 0 1
done

# mac path: all four via brew
CLEAN="$FIX/bin"
mkdir -p "$FIX/h"
HOME="$FIX/h" PATH="$CLEAN" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" \
  bash -c 'for t in starship eza fzf zoxide; do bash "'"$ROOT"'/scripts/setup.d/$t.sh"; done' >/dev/null
ck "mac: all four via brew" "4" "$(grep -c '^BREW ' "$FIX/h/p.log" 2>/dev/null || echo 0)"

# presence check: fake installed binary -> no install attempt
mkdir -p "$FIX/h2/.local/bin"
for t in starship eza fzf zoxide; do
  printf '#!/bin/sh\n' > "$FIX/h2/.local/bin/$t"
  chmod +x "$FIX/h2/.local/bin/$t"
done
out=$(HOME="$FIX/h2" PATH="$FIX/h2/.local/bin:$CLEAN" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" \
  bash "$ROOT/scripts/setup.d/starship.sh")
ck "present: skip" "  starship... done" "$out"

# linux path: all four via apt (starship, eza, fzf, zoxide)
mkdir -p "$FIX/h3"
HOME="$FIX/h3" PATH="$CLEAN" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" \
  bash -c 'for t in starship eza fzf zoxide; do bash "'"$ROOT"'/scripts/setup.d/$t.sh"; done' >/dev/null 2>&1 || true
ck "linux: apt install calls (all four)" "4" "$(grep -c 'APT_CALL_MARKER' "$FIX/h3/p.log" 2>/dev/null || echo 0)"

printf '\nplugin_test: %d failures\n' "$FAILS"
[ "$FAILS" -eq 0 ]
