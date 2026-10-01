#!/usr/bin/env bash
# Test runner for scripts/lib.sh — run: bash scripts/tests/lib_test.sh
set -u
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"
. "$LIB"

TESTS_RUN=0; TESTS_FAIL=0
t() { # t <name> <expected> <actual>
  TESTS_RUN=$((TESTS_RUN+1))

  if [ "$2" = "$3" ]; then
    printf 'ok %d - %s\n' "$TESTS_RUN" "$1"
  else
    TESTS_FAIL=$((TESTS_FAIL+1))
    printf 'NOT OK %d - %s\n  expected: [%s]\n  actual:   [%s]\n' "$TESTS_RUN" "$1" "$2" "$3"
  fi
}

x() { # x <name> <expected-exit> <cmd...>
  TESTS_RUN=$((TESTS_RUN+1))
  local name="$1"
  local want="$2"
  shift 2
  "$@" >/dev/null 2>&1
  local got=$?

  if [ "$want" = "$got" ]; then
    printf 'ok %d - %s\n' "$TESTS_RUN" "$name"
  else
    TESTS_FAIL=$((TESTS_FAIL+1))
    printf 'NOT OK %d - %s (want exit %s, got %s)\n' "$TESTS_RUN" "$name" "$want" "$got"
  fi
}

FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT

cat > "$FIX/string.md" <<'EOF'
---
maps:
  ~/.vimrc: vimrc
---

# Body — must be ignored even though it contains --- and dest: {src: x}
EOF

cat > "$FIX/blocks.md" <<'EOF'
---
when: ghostty
maps:
  ~/Library/Application Support/com.mitchellh.ghostty/config.ghostty:
    src: config.ghostty
    os: [macos]
  ~/.config/ghostty/config:
    src: config.ghostty
    os: [linux]
    when: ghostty
  ~/.gitconfig:
    src: gitconfig
    copy: true
---
EOF

cat > "$FIX/inline.md" <<'EOF'
---
maps:
  ~/.vimrc: {src: vimrc}
---
EOF

cat > "$FIX/badkey.md" <<'EOF'
---
maps:
  ~/.vimrc: vimrc
extra: nope
---
EOF

cat > "$FIX/nomaps.md" <<'EOF'
---
when: foo
---
EOF

cat > "$FIX/baddest.md" <<'EOF'
---
maps:
  .vimrc: vimrc
---
EOF

cat > "$FIX/badwhen.md" <<'EOF'
---
when: [a, b]
maps:
  ~/.vimrc: vimrc
---
EOF

cat > "$FIX/dup.md" <<'EOF'
---
maps:
  ~/.vimrc: vimrc
  ~/.vimrc: vimrc2
---
EOF

cat > "$FIX/nosrc.md" <<'EOF'
---
maps:
  ~/.x.conf:
    os: [macos]
---
EOF

# --- fm_entries: happy paths ---
t "string entry"  "$(printf '~/.vimrc\tvimrc\t\t\t')"  "$(fm_entries "$FIX/string.md")"
t "root when read" "ghostty" "$(fm_read "$FIX/blocks.md" when)"
t "fm_read absent key" "" "$(fm_read "$FIX/blocks.md" copy)"
t "block entries count" "3" "$(fm_entries "$FIX/blocks.md" | wc -l | tr -d ' ')"
t "block dest 2 when"  "ghostty" "$(fm_entries "$FIX/blocks.md" | sed -n 2p | cut -f5)"
t "block os list"   "[linux]" "$(fm_entries "$FIX/blocks.md" | sed -n 2p | cut -f3)"
t "copy flag"       "true"    "$(fm_entries "$FIX/blocks.md" | sed -n 3p | cut -f4)"
t "body not parsed" "1"       "$(fm_entries "$FIX/string.md" | wc -l | tr -d ' ')"
printf -- '---\nmaps: {}\n---\n' > "$FIX/emptymaps.md"
t "maps:{} accepted" "0"      "$(fm_entries "$FIX/emptymaps.md" | wc -l | tr -d ' ')"

# --- fm_entries: violations → exit 1 ---
x "inline form rejected"     1 fm_entries "$FIX/inline.md"
x "unknown root key"         1 fm_entries "$FIX/badkey.md"
x "when without maps"        1 fm_entries "$FIX/nomaps.md"
x "dest must be ~/..."       1 fm_entries "$FIX/baddest.md"
x "when must be scalar"      1 fm_entries "$FIX/badwhen.md"
x "duplicate dest"           1 fm_entries "$FIX/dup.md"
x "block missing src"        1 fm_entries "$FIX/nosrc.md"
x "missing file"             1 fm_entries "$FIX/nope.md"

HOME_SAVE="$HOME"; ROOT_DIR="${DOTFILES_DIR:-}"

# --- predicates ---
x "is_linux via override" 0 bash -c 'DOTFILES_OS=Linux; . "$1"; is_linux' bash "$LIB"
x "is_macos via override" 0 bash -c 'DOTFILES_OS=Darwin; . "$1"; is_macos' bash "$LIB"
x "has_when empty = pass" 0 has_when ""
x "has_when missing cmd" 1 has_when nosuchcmd-$$
x "has_when present cmd" 0 has_when sh

# --- path_setup puts ~/.local/bin on PATH (Review Focus 2) ---
mkdir -p "$FIX/home/.local/bin"; printf '#!/bin/sh\n' > "$FIX/home/.local/bin/fakecmd"; chmod +x "$FIX/home/.local/bin/fakecmd"
x "path_setup exposes ~/.local/bin" 0 bash -c 'HOME="$1"; PATH=/usr/bin:/bin; . "$2"; path_setup; command -v fakecmd >/dev/null' bash "$FIX/home" "$LIB"

# --- link_apply in a sandbox ---
export HOME="$FIX/home" LINK_ROOT="$FIX/home" BACKUP_DIR="$FIX/bak"
export DOTFILES_DIR="$FIX/repo" LOGS_DIR="$FIX/logs"
mkdir -p "$FIX/src"; echo "content-v1" > "$FIX/src/a.txt"

link_apply "~/a.txt" "$FIX/src/a.txt" "" "" "" ""
t "link: result" "linked" "$LINK_RESULT"
t "link: target" "$FIX/src/a.txt" "$(readlink "$FIX/home/a.txt")"

link_apply "~/a.txt" "$FIX/src/a.txt" "" "" "" ""
t "link: idempotent noop" "noop" "$LINK_RESULT"
x "noop creates no backup dir" 1 test -d "$FIX/bak"

DOTFILES_FORCE=1 link_apply "~/a.txt" "$FIX/src/a.txt" "" "" "" ""
t "link: force re-links" "linked" "$LINK_RESULT"
unset DOTFILES_FORCE
rm -rf "$FIX/bak"

# os gate (against the platform this machine is not)
if is_macos; then
  OTHER_OS=linux
else
  OTHER_OS=macos
fi

link_apply "~/b.txt" "$FIX/src/a.txt" "$OTHER_OS" "" "" ""
t "os gate: result" "gated" "$LINK_RESULT"
x "os gate: no file" 1 test -e "$FIX/home/b.txt"
link_apply "~/b.txt" "$FIX/src/a.txt" "macos,linux" "" "" ""
t "os multi-token matches" "linked" "$LINK_RESULT"
rm -f "$FIX/home/b.txt"

# when gates
link_apply "~/c.txt" "$FIX/src/a.txt" "" "" "nosuchcmd-$$" ""
t "dest when: gated" "gated" "$LINK_RESULT"
link_apply "~/c.txt" "$FIX/src/a.txt" "" "" "" "nosuchcmd-$$"
t "root when: gated" "gated" "$LINK_RESULT"
link_apply "~/c.txt" "$FIX/src/a.txt" "" "" "sh" "sh"
t "both when pass" "linked" "$LINK_RESULT"
rm -f "$FIX/home/c.txt"

# dry run
DOTFILES_DRY_RUN=1 link_apply "~/d.txt" "$FIX/src/a.txt" "" "" "" ""
t "dry-run result" "would" "$LINK_RESULT"
x "dry-run writes nothing" 1 test -e "$FIX/home/d.txt"
unset DOTFILES_DRY_RUN

# copy + git identity preservation + backup (Review Focus 3)
printf '[user]\n\tname = Fery\n\temail = old@example.com\n' > "$FIX/home/.gitconfig"
echo "src-identity" > "$FIX/src/gitconfig"
link_apply "~/.gitconfig" "$FIX/src/gitconfig" "" "true" "" ""
t "copy: result" "linked" "$LINK_RESULT"
t "copy: content replaced" "src-identity" "$(head -1 "$FIX/home/.gitconfig")"
t "copy: name preserved" "Fery" "$(git config --file "$FIX/home/.gitconfig" user.name)"
t "copy: email preserved" "old@example.com" "$(git config --file "$FIX/home/.gitconfig" user.email)"
t "copy: old file backed up" "1" "$(grep -c '\[user\]' "$FIX/bak/.gitconfig" 2>/dev/null || echo 0)"

unset LINK_ROOT BACKUP_DIR
export HOME="$HOME_SAVE" DOTFILES_DIR="$ROOT_DIR"

# --- wrappers (stubbed package managers) ---
mkdir -p "$FIX/bin"
cat > "$FIX/bin/brew" <<'STUB'
#!/usr/bin/env bash
case "$1" in
  list) [ "$2" = "--versions" ] && [ "$3" = "haveform" ] ;;
  install) shift; echo "BREW_INSTALL $*" ;;
esac
STUB
cat > "$FIX/bin/dpkg" <<'STUB'
#!/usr/bin/env bash
[ "$2" = "havepkg" ]
STUB
cat > "$FIX/bin/apt-get" <<'STUB'
#!/usr/bin/env bash
echo "APT_CALL $* DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-}" >> "${APT_LOG:?}"
STUB
cat > "$FIX/bin/sudo" <<'STUB'
#!/usr/bin/env bash
exec "$@"
STUB
chmod +x "$FIX/bin/"*
PATH_SAVE2="$PATH"

# macOS branch
PATH="$FIX/bin:$PATH_SAVE2"
out=$(DOTFILES_OS=Darwin brew_install haveform); t "brew: skip installed" "  haveform... done" "$out"
: > "$FIX/brew.log"
out=$(DOTFILES_OS=Darwin DOTFILES_SETUP_LOG="$FIX/brew.log" brew_install newform)
t "brew: installs missing" "  installing (brew): newform... done" "$out"
t "brew: raw output to log (-y)" "1" "$(grep -c 'BREW_INSTALL -y newform' "$FIX/brew.log")"
x  "brew guard on linux" 1 bash -c 'DOTFILES_OS=Linux; . "$1"; brew_install haveform' bash "$LIB"

# Linux branch, single apt update per run
export APT_LOG="$FIX/apt.log"; : > "$APT_LOG"
PATH="$FIX/bin:$PATH_SAVE2"
out=$(DOTFILES_OS=Linux apt_install havepkg);    t "apt: skip installed" "  havepkg... done" "$out"
DOTFILES_OS=Linux apt_install pkg-a >/dev/null
DOTFILES_OS=Linux apt_install pkg-b >/dev/null
t "apt: one update per run" "1" "$(grep -c 'APT_CALL update' "$APT_LOG")"
t "apt: installs issued"    "2" "$(grep -c 'APT_CALL install' "$APT_LOG")"
t "apt: noninteractive"     "2" "$(grep -c 'APT_CALL install.*DEBIAN_FRONTEND=noninteractive' "$APT_LOG")"
x  "apt guard on macos" 1 bash -c 'DOTFILES_OS=Darwin; . "$1"; apt_install havepkg' bash "$LIB"
PATH="$PATH_SAVE2"; unset APT_LOG

printf '\n%d tests, %d failures\n' "$TESTS_RUN" "$TESTS_FAIL"
[ "$TESTS_FAIL" -eq 0 ]
