#!/usr/bin/env bash
# Run: bash scripts/tests/init_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$ROOT/scripts/tests/harness.sh"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT
INIT="$ROOT/scripts/init.sh"

bash -n "$INIT" && t syntax 'parses `init.sh`' 0 0 || t syntax 'parses `init.sh`' 0 1

out=$("$INIT" --help 2>&1); rc=$?
t init 'usage: `--help` exits 0' "0" "$rc"
t init 'usage: `--help` prints the usage line' "1" "$(printf '%s' "$out" | grep -c '^Usage:')"

x init 'usage: unknown flag exits 2' 2 "$INIT" --bogus
err=$("$INIT" --bogus 2>&1 >/dev/null)
t init 'usage: unknown flag explains on stderr' "1" "$(printf '%s' "$err" | grep -c 'unknown option')"

# DRY_RUN=1 keeps this banner check harmless once Task 5 adds real execution
out=$(DRY_RUN=1 bash "$INIT" 2>&1); rc=$?
t init 'banner: dry run starts with the initializing banner' "1" "$(printf '%s' "$out" | grep -c '^Initializing\.\.\.$')"

# --- step protocol + dry-run flow ---
x init 'dry-run: exits 0' 0 env DRY_RUN=1 bash "$INIT"
out=$(DRY_RUN=1 bash "$INIT" 2>&1)
steps=$(printf '%s\n' "$out" | grep -E '^  \[[A-Z]+\]' | sed -E 's/^  (\[[A-Z]+\]) (.*)\.\.\..*$/\1 \2/')
want=$'[CONF] locale settings\n[CONF] timezone\n[UPDT] repositories\n[UPDT] system packages'
t init 'dry-run: prints the upgrade steps in order' "$want" "$(printf '%s\n' "$steps" | head -4)"
t init 'dry-run: closes with `All done`' "1" "$(printf '%s' "$out" | grep -c '^All done$')"
t init 'dry-run: prints the no-changes hint' "1" "$(printf '%s' "$out" | grep -c 'dry-run: no changes were made')"

# tripwire: sudo must never be reachable from a dry run
mkdir -p "$FIX/tw"
cat > "$FIX/tw/sudo" <<'STUB'
#!/usr/bin/env bash
printf called > "$INIT_TW"
exit 99
STUB
chmod +x "$FIX/tw/sudo"
INIT_TW="$FIX/tw.called" DRY_RUN=1 PATH="$FIX/tw:$PATH" bash "$INIT" >/dev/null 2>&1
t init 'dry-run: never invokes sudo' "0" "$([ -f "$FIX/tw.called" ] && echo 1 || echo 0)"

# --- full protocol sequence ---
out=$(DRY_RUN=1 bash "$INIT" 2>&1)
steps=$(printf '%s\n' "$out" | grep -E '^  \[[A-Z]+\]' | sed -E 's/^  (\[[A-Z]+\]) (.*)\.\.\..*$/\1 \2/')
want=$'[CONF] locale settings\n[CONF] timezone\n[UPDT] repositories\n[UPDT] system packages\n[INST] basic tools (vps)\n[CONF] default user\n[CONF] sshd hardening\n[CONF] vim defaults\n[UPDT] cleanup'
t init 'dry-run: prints every step in order' "$want" "$steps"
t init 'dry-run: hints that groups apply next login' "1" "$(printf '%s' "$out" | grep -c 'group changes apply at next login')"

# --- profile resolution (flag > env > detect) ---
mkdir -p "$FIX/vt"
printf '#!/bin/sh\nexit 0\n' > "$FIX/vt/systemd-detect-virt"; chmod +x "$FIX/vt/systemd-detect-virt"
prof() { printf '%s' "$1" | sed -nE 's/.*basic tools \((lxc|vps)\).*/\1/p'; }

out=$(DRY_RUN=1 PATH="$FIX/vt:$PATH" bash "$INIT" 2>&1)
t profile 'detect: container selects `lxc`' "lxc" "$(prof "$out")"

printf '#!/bin/sh\nexit 1\n' > "$FIX/vt/systemd-detect-virt"
out=$(DRY_RUN=1 PATH="$FIX/vt:$PATH" bash "$INIT" 2>&1)
t profile 'detect: no container selects `vps`' "vps" "$(prof "$out")"

out=$(DRY_RUN=1 PROFILE=lxc PATH="$FIX/vt:$PATH" bash "$INIT" 2>&1)
t profile '`PROFILE` env beats detection' "lxc" "$(prof "$out")"

out=$(DRY_RUN=1 PROFILE=lxc PATH="$FIX/vt:$PATH" bash "$INIT" --profile vps 2>&1)
t profile '`--profile` flag beats `PROFILE` env' "vps" "$(prof "$out")"

out=$(DRY_RUN=1 PATH="$FIX/vt:$PATH" bash "$INIT" --profile=lxc 2>&1)
t profile '`--profile=` equals form is accepted' "lxc" "$(prof "$out")"

x profile 'unknown profile value exits 2' 2 env DRY_RUN=1 bash "$INIT" --profile windows
err=$(DRY_RUN=1 bash "$INIT" --profile windows 2>&1 >/dev/null)
t profile 'unknown profile value explains on stderr' "1" "$(printf '%s' "$err" | grep -c 'unknown profile')"

finish init
