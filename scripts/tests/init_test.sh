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

# --- error path: hermetic stubs, step 1 fails ---
mkdir -p "$FIX/bin"
cat > "$FIX/bin/sudo" <<'STUB'
#!/usr/bin/env bash
case "$1" in -k|-v) exit 0 ;; esac
exec "$@"
STUB
cat > "$FIX/bin/locale-gen" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB
chmod +x "$FIX/bin/sudo" "$FIX/bin/locale-gen"

x err 'step failure exits 1' 1 env DRY_RUN=0 HOME="$FIX/h" PATH="$FIX/bin:$PATH" bash "$INIT"
out=$(DRY_RUN=0 HOME="$FIX/h" PATH="$FIX/bin:$PATH" bash "$INIT" 2>&1)
t err 'step failure prints the `error` status' "1" "$(printf '%s' "$out" | grep -Fc 'locale settings... error')"
t err 'step failure hints the command and line' "1" "$(printf '%s' "$out" | grep -c "failed (line")"

# --- sudo credential failure: loud, zero steps ---
mkdir -p "$FIX/sudo_fail"
printf '#!/usr/bin/env bash\nexit 1\n' > "$FIX/sudo_fail/sudo"; chmod +x "$FIX/sudo_fail/sudo"
x priv 'sudo -v failure exits 1' 1 env DRY_RUN=0 HOME="$FIX/h" PATH="$FIX/sudo_fail:$PATH" bash "$INIT"
out=$(DRY_RUN=0 HOME="$FIX/h" PATH="$FIX/sudo_fail:$PATH" bash "$INIT" 2>&1)
t priv 'sudo -v failure prints the root-required message' "1" "$(printf '%s' "$out" | grep -c 'root required')"
t priv 'sudo -v failure runs zero steps' "0" "$(printf '%s' "$out" | grep -c '\[CONF\] locale')"

# --- protocol atomicity: chatty commands must not split the step line ---
mkdir -p "$FIX/chatty"
cat > "$FIX/chatty/sudo" <<'STUB'
#!/usr/bin/env bash
case "$1" in -k|-v) exit 0 ;; esac
exec "$@"
STUB
cat > "$FIX/chatty/locale-gen" <<'STUB'
#!/usr/bin/env bash
echo "Generating locales (this might take a while)..."
echo "  en_US.UTF-8... done"
echo "locale-gen: stderr chatter" >&2
exit 1
STUB
chmod +x "$FIX/chatty/sudo" "$FIX/chatty/locale-gen"
out=$(DRY_RUN=0 HOME="$FIX/h" PATH="$FIX/chatty:$PATH" bash "$INIT" 2>&1)
t protocol 'chatty stdout is suppressed' "0" "$(printf '%s' "$out" | grep -c 'Generating locales')"
t protocol 'chatty stderr is suppressed' "0" "$(printf '%s' "$out" | grep -c 'stderr chatter')"
t protocol 'step line stays atomic despite chatter' "1" "$(printf '%s' "$out" | grep -Fc 'locale settings... error')"

# apt's dpkg progress on fresh hosts must not split step lines either
mkdir -p "$FIX/apt"
for c in locale-gen update-locale dpkg-reconfigure ln; do printf '#!/bin/sh\nexit 0\n' > "$FIX/apt/$c"; done
cat > "$FIX/apt/sudo" <<'STUB'
#!/usr/bin/env bash
case "$1" in -k|-v) exit 0 ;; esac
exec "$@"
STUB
cat > "$FIX/apt/apt-get" <<'STUB'
#!/bin/sh
case "$1" in
  dist-upgrade|install)
    echo "(Reading database… 5%)"
    echo "Setting up package..." >&2
    ;;
esac
exit 0
STUB
chmod +x "$FIX/apt/"*
out=$(DRY_RUN=0 PROFILE=lxc HOME="$FIX/h" PATH="$FIX/apt:$PATH" bash "$INIT" 2>&1)
t protocol 'apt progress is suppressed' "0" "$(printf '%s' "$out" | grep -c 'Reading database')"
t protocol 'upgrade step line stays atomic' "1" "$(printf '%s' "$out" | grep -Fc 'system packages... done')"
t protocol 'install step line stays atomic' "1" "$(printf '%s' "$out" | grep -Fc 'basic tools (lxc)... done')"

finish init
