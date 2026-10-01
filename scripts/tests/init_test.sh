#!/usr/bin/env bash
# Run: bash scripts/tests/init_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$ROOT/scripts/tests/harness.sh"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT
INIT="$ROOT/scripts/init.sh"
printf 'ID=ubuntu\n' > "$FIX/os-release-ubuntu"

bash -n "$INIT" && t syntax 'parses `init.sh`' 0 0 || t syntax 'parses `init.sh`' 0 1
if [ -x /bin/bash ]; then
  /bin/bash -n "$INIT" && t syntax 'parses under /bin/bash' 0 0 || t syntax 'parses under /bin/bash' 0 1
fi

out=$("$INIT" --help 2>&1); rc=$?
t init 'usage: `--help` exits 0' "0" "$rc"
t init 'usage: `--help` prints the usage line' "1" "$(printf '%s' "$out" | grep -c '^Usage:')"

x init 'usage: unknown flag exits 2' 2 "$INIT" --bogus
err=$("$INIT" --bogus 2>&1 >/dev/null)
t init 'usage: unknown flag explains on stderr' "1" "$(printf '%s' "$err" | grep -c 'unknown option')"

# piped door: the script arrives on stdin ($0 = `bash`), usage must not read $0
out=$(cat "$INIT" | bash -s -- --help 2>&1); rc=$?
t init 'usage: piped `--help` exits 0' "0" "$rc"
t init 'usage: piped `--help` prints the usage line' "1" "$(printf '%s' "$out" | grep -c '^Usage:')"
cat "$INIT" | bash -s -- --bogus >/dev/null 2>&1; rc=$?
t init 'usage: piped unknown flag exits 2' "2" "$rc"

# DRY_RUN=1 keeps this banner check harmless (the script executes for real otherwise)
out=$(DRY_RUN=1 bash "$INIT" 2>&1); rc=$?
t init 'banner: dry run starts with the initializing banner' "1" "$(printf '%s' "$out" | grep -c '^Initializing\.\.\.$')"

# --- step protocol + dry-run flow ---
x init 'dry-run: exits 0' 0 env DRY_RUN=1 bash "$INIT"
out=$(DRY_RUN=1 bash "$INIT" 2>&1)
steps=$(printf '%s\n' "$out" | grep -E '^  \[[A-Z]+\]' | sed -E 's/^  //')
want=$'[CONF] locale settings... done\n[CONF] timezone... done\n[UPDT] repositories... done\n[UPDT] system packages... done'
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
out=$(DRY_RUN=1 PROFILE=vps bash "$INIT" 2>&1)
steps=$(printf '%s\n' "$out" | grep -E '^  \[[A-Z]+\]' | sed -E 's/^  //')
want=$'[CONF] locale settings... done\n[CONF] timezone... done\n[UPDT] repositories... done\n[UPDT] system packages... done\n[INST] basic tools (vps)... done\n[CONF] default user... done\n[CONF] sshd hardening... done\n[CONF] vim defaults... done\n[UPDT] cleanup... done'
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

x profile 'empty `--profile=` exits 2' 2 env DRY_RUN=1 bash "$INIT" --profile=
x profile 'empty `--profile ""` exits 2' 2 env DRY_RUN=1 bash "$INIT" --profile ""
err=$(DRY_RUN=1 bash "$INIT" --profile= 2>&1 >/dev/null)
t profile 'empty `--profile=` explains on stderr' "1" "$(printf '%s' "$err" | grep -c 'requires a value')"

x profile 'unknown profile value exits 2' 2 env DRY_RUN=1 bash "$INIT" --profile windows
err=$(DRY_RUN=1 bash "$INIT" --profile windows 2>&1 >/dev/null)
t profile 'unknown profile value explains on stderr' "1" "$(printf '%s' "$err" | grep -c 'unknown profile')"

# --- distro guard: non-Ubuntu fails before the banner; dry run previews anywhere ---
printf 'ID=debian\n' > "$FIX/os-debian"
out=$(OS_RELEASE="$FIX/os-debian" DRY_RUN=0 bash "$INIT" 2>&1 </dev/null); rc=$?
t guard 'non-Ubuntu release exits 1' "1" "$rc"
t guard 'non-Ubuntu release names the requirement' "1" "$(printf '%s' "$out" | grep -c 'requires Ubuntu')"
t guard 'non-Ubuntu release fails before the banner' "0" "$(printf '%s' "$out" | grep -c '^Initializing\.\.\.$')"

out=$(OS_RELEASE="$FIX/os-debian" DRY_RUN=1 bash "$INIT" 2>&1); rc=$?
t guard 'dry run skips the distro guard' "0" "$rc"
t guard 'dry run previews on a non-Ubuntu release' "1" "$(printf '%s' "$out" | grep -c '^All done$')"

# Non-dry-run fixtures execute real commands behind their stubs (EACCES being
# the non-root backstop); as root those commands would touch the host system,
# so the whole section is skipped instead of run.
if [ "$(id -u)" -eq 0 ]; then
  printf '    hint: non-dry-run fixtures skipped when running as root\n'
fi
if [ "$(id -u)" -ne 0 ]; then

  # --- error path: hermetic stubs, step 1's second command fails chatty ---
  mkdir -p "$FIX/bin"
  cat > "$FIX/bin/sudo" <<'STUB'
#!/usr/bin/env bash
case "$1" in -k|-v) exit 0 ;; esac
exec "$@"
STUB
  printf '#!/bin/sh\nexit 0\n' > "$FIX/bin/locale-gen"
  cat > "$FIX/bin/update-locale" <<'STUB'
#!/usr/bin/env bash
echo "update-locale: cannot open /etc/default/locale" >&2
exit 1
STUB
  chmod +x "$FIX/bin/sudo" "$FIX/bin/locale-gen" "$FIX/bin/update-locale"

  x err 'step failure exits 1' 1 env DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" HOME="$FIX/h" PATH="$FIX/bin:$PATH" bash "$INIT"
  out=$(DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" HOME="$FIX/h" PATH="$FIX/bin:$PATH" bash "$INIT" 2>&1)
  t err 'step failure prints the `error` status' "1" "$(printf '%s' "$out" | grep -Fc 'locale settings... error')"
  t err 'step failure hints the command and line' "1" "$(printf '%s' "$out" | grep -c "failed (line")"
  t err 'hint names the actual failing command' "1" "$(printf '%s' "$out" | grep -c 'update-locale LC_ALL')"
  t err 'hint contains no wrapper garbage' "0" "$(printf '%s' "$out" | grep -c '"$@"')"
  t err 'failure reason is replayed below the status' "1" "$(printf '%s' "$out" | grep -c 'cannot open /etc/default/locale')"

  # --- sudo credential failure: loud, zero steps ---
  mkdir -p "$FIX/sudo_fail"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$FIX/sudo_fail/sudo"; chmod +x "$FIX/sudo_fail/sudo"
  x priv 'sudo -v failure exits 1' 1 env DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" HOME="$FIX/h" PATH="$FIX/sudo_fail:$PATH" bash "$INIT"
  out=$(DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" HOME="$FIX/h" PATH="$FIX/sudo_fail:$PATH" bash "$INIT" 2>&1)
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
  out=$(DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" HOME="$FIX/h" PATH="$FIX/chatty:$PATH" bash "$INIT" 2>&1)
  t protocol 'step line stays atomic despite chatter' "1" "$(printf '%s' "$out" | grep -Fc 'locale settings... error')"
  t protocol 'failing command stdout is replayed' "1" "$(printf '%s' "$out" | grep -c 'Generating locales')"
  t protocol 'failing command stderr is replayed' "1" "$(printf '%s' "$out" | grep -c 'stderr chatter')"
  t protocol 'chatter never lands on the status line' "0" "$(printf '%s' "$out" | grep -cE 'locale settings\.\.\..*(Generating|stderr chatter)')"

  # apt's dpkg progress on fresh hosts must not split step lines either
  mkdir -p "$FIX/apt"
  for c in locale-gen update-locale dpkg-reconfigure ln add-apt-repository; do printf '#!/bin/sh\nexit 0\n' > "$FIX/apt/$c"; done
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
  out=$(DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" PROFILE=lxc HOME="$FIX/h" PATH="$FIX/apt:$PATH" bash "$INIT" 2>&1)
  t protocol 'apt progress is suppressed' "0" "$(printf '%s' "$out" | grep -c 'Reading database')"
  t protocol 'upgrade step line stays atomic' "1" "$(printf '%s' "$out" | grep -Fc 'system packages... done')"
  t protocol 'install step line stays atomic' "1" "$(printf '%s' "$out" | grep -Fc 'basic tools (lxc)... done')"

  # --- adoption: the adopted user's own keys must not be copied onto themselves ---
  mkdir -p "$FIX/adopt" "$FIX/h/.ssh"
  printf 'ssh-ed25519 adopt-test-key\n' > "$FIX/h/.ssh/authorized_keys"
  cat > "$FIX/adopt/sudo" <<'STUB'
#!/usr/bin/env bash
case "$1" in -k|-v) exit 0 ;; esac
exec "$@"
STUB
  printf '#!/bin/sh\necho "1000 testuser"\n' > "$FIX/adopt/awk"
  printf '#!/bin/sh\necho "testuser:x:1000:1000::%s:/bin/bash"\n' "$FIX/h" > "$FIX/adopt/getent"
  for c in locale-gen update-locale dpkg-reconfigure ln apt-get systemctl timedatectl \
    usermod sh chown chmod add-apt-repository; do
    printf '#!/bin/sh\nexit 0\n' > "$FIX/adopt/$c"
  done
  chmod +x "$FIX/adopt/"*
  out=$(DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" SUDO_USER=testuser HOME="$FIX/h" PATH="$FIX/adopt:$PATH" bash "$INIT" 2>&1)
  t adopt 'adopted user keys: step completes' "1" "$(printf '%s' "$out" | grep -Fc 'default user... done')"
  t adopt 'adopted user keys: no identical-file copy error' "0" "$(printf '%s' "$out" | grep -cE 'identical|same file')"

  # --- admin fallback: openssl-random password, hinted and stored mode 600 ---
  mkdir -p "$FIX/adm/h"
  printf '#!/bin/sh\nexit 0\n' > "$FIX/adm/awk"
  printf '#!/bin/sh\necho "admin:x:1001:1001::%s:/bin/bash"\n' "$FIX/adm/h" > "$FIX/adm/getent"
  printf '#!/bin/sh\nprintf called > "%s/adduser.called"\n' "$FIX/adm" > "$FIX/adm/adduser"
  printf '#!/bin/sh\ncat > "%s/chpasswd.stdin"\n' "$FIX/adm" > "$FIX/adm/chpasswd"
  printf '#!/bin/sh\nprintf %%s "TestPW+abc123xyz"\n' > "$FIX/adm/openssl"
  for c in locale-gen update-locale dpkg-reconfigure ln apt-get timedatectl usermod sh \
    chown chmod add-apt-repository sed update-alternatives; do
    printf '#!/bin/sh\nexit 0\n' > "$FIX/adm/$c"
  done
  cat > "$FIX/adm/sudo" <<'STUB'
#!/usr/bin/env bash
case "$1" in -k|-v) exit 0 ;; esac
exec "$@"
STUB
  chmod +x "$FIX/adm/"*
  out=$(DRY_RUN=0 OS_RELEASE="$FIX/os-release-ubuntu" HOME="$FIX/adm/h" PATH="$FIX/adm:$PATH" bash "$INIT" 2>&1)
  t admin 'admin fallback: creates the account' "1" "$(grep -c called "$FIX/adm/adduser.called" 2>/dev/null || true)"
  t admin 'admin fallback: step completes' "1" "$(printf '%s' "$out" | grep -Fc 'default user... done')"
  t admin 'admin fallback: chpasswd receives the generated password' "1" "$(grep -c '^admin:TestPW+abc123xyz$' "$FIX/adm/chpasswd.stdin" 2>/dev/null || true)"
  t admin 'admin fallback: hint prints the generated password' "1" "$(printf '%s' "$out" | grep -c 'initial password: TestPW+abc123xyz')"
  t admin 'admin fallback: hint names the store file' "1" "$(printf '%s' "$out" | grep -c '\.init-password')"
  t admin 'admin fallback: store file is mode 600' "1" "$(ls -l "$FIX/adm/h/.init-password" 2>/dev/null | grep -c '^-rw-------')"
  t admin 'admin fallback: store file holds the password' "1" "$(grep -c '^TestPW+abc123xyz$' "$FIX/adm/h/.init-password" 2>/dev/null || true)"

fi

finish init
