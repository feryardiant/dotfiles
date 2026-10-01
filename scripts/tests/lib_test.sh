#!/usr/bin/env bash
# Test runner for scripts/lib.sh — run: bash scripts/tests/lib_test.sh
set -u
TDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$TDIR/../lib.sh"
. "$LIB"
. "$TDIR/harness.sh"

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
t fm 'accepts string **maps** entry `~/.vimrc: vimrc`' "$(printf '~/.vimrc\tvimrc\t\t\t')" "$(fm_entries "$FIX/string.md")"
t fm 'reads the root-level `when` key' "ghostty" "$(fm_read "$FIX/blocks.md" when)"
t fm 'optional key `copy` can be missing' "" "$(fm_read "$FIX/blocks.md" copy)"
t fm 'expands a multi-key **maps** block to one row per entry' "3" "$(fm_entries "$FIX/blocks.md" | wc -l | tr -d ' ')"
t fm 'captures a per-entry `when` gate' "ghostty" "$(fm_entries "$FIX/blocks.md" | sed -n 2p | cut -f5)"
t fm 'captures a per-entry `os` filter' "[linux]" "$(fm_entries "$FIX/blocks.md" | sed -n 2p | cut -f3)"
t fm 'captures a per-entry `copy: true` flag' "true" "$(fm_entries "$FIX/blocks.md" | sed -n 3p | cut -f4)"
t fm 'ignores the body below frontmatter' "1" "$(fm_entries "$FIX/string.md" | wc -l | tr -d ' ')"
printf -- '---\nmaps: {}\n---\n' > "$FIX/emptymaps.md"
t fm 'accepts an empty `maps: {}`' "0" "$(fm_entries "$FIX/emptymaps.md" | wc -l | tr -d ' ')"

# --- fm_entries: violations → exit 1 ---
x fm 'rejects the inline object form' 1 fm_entries "$FIX/inline.md"
x fm 'rejects unknown root keys' 1 fm_entries "$FIX/badkey.md"
x fm 'requires `maps` alongside `when`' 1 fm_entries "$FIX/nomaps.md"
x fm 'requires `~/`-prefixed destinations' 1 fm_entries "$FIX/baddest.md"
x fm 'rejects list-valued `when`' 1 fm_entries "$FIX/badwhen.md"
x fm 'rejects duplicate destinations' 1 fm_entries "$FIX/dup.md"
x fm 'rejects an entry without `src`' 1 fm_entries "$FIX/nosrc.md"
x fm 'fails when the file does not exist' 1 fm_entries "$FIX/nope.md"

HOME_SAVE="$HOME"; ROOT_DIR="${DOTFILES_DIR:-}"

# --- predicates ---
x platform 'detects Linux from the `DOTFILES_OS` override' 0 bash -c 'DOTFILES_OS=Linux; . "$1"; is_linux' bash "$LIB"
x platform 'detects macOS from the `DOTFILES_OS` override' 0 bash -c 'DOTFILES_OS=Darwin; . "$1"; is_macos' bash "$LIB"
x when 'passes when no gate is set' 0 has_when ""
x when 'fails when the gate command is missing' 1 has_when nosuchcmd-$$
x when 'passes when the gate command exists' 0 has_when sh

# --- path_setup puts ~/.local/bin on PATH (Review Focus 2) ---
mkdir -p "$FIX/home/.local/bin"; printf '#!/bin/sh\n' > "$FIX/home/.local/bin/fakecmd"; chmod +x "$FIX/home/.local/bin/fakecmd"
x path 'puts `~/.local/bin` on **PATH**' 0 bash -c 'HOME="$1"; PATH=/usr/bin:/bin; . "$2"; path_setup; command -v fakecmd >/dev/null' bash "$FIX/home" "$LIB"

# --- link_apply in a sandbox ---
export HOME="$FIX/home" LINK_ROOT="$FIX/home" BACKUP_DIR="$FIX/bak"
export DOTFILES_DIR="$FIX/repo" LOGS_DIR="$FIX/logs"
mkdir -p "$FIX/src"; echo "content-v1" > "$FIX/src/a.txt"

link_apply "~/a.txt" "$FIX/src/a.txt" "" "" "" ""
t link 'creates a symlink at the destination' "linked" "$LINK_RESULT"
t link 'symlink points at the source file' "$FIX/src/a.txt" "$(readlink "$FIX/home/a.txt")"

link_apply "~/a.txt" "$FIX/src/a.txt" "" "" "" ""
t link 'second run reports noop' "noop" "$LINK_RESULT"
x link 'noop creates no backup' 1 test -d "$FIX/bak"

DOTFILES_FORCE=1 link_apply "~/a.txt" "$FIX/src/a.txt" "" "" "" ""
t link 'force re-links with `DOTFILES_FORCE=1`' "linked" "$LINK_RESULT"
unset DOTFILES_FORCE
rm -rf "$FIX/bak"

# os gate (against the platform this machine is not)
if is_macos; then
  OTHER_OS=linux
else
  OTHER_OS=macos
fi

link_apply "~/b.txt" "$FIX/src/a.txt" "$OTHER_OS" "" "" ""
t 'os gate' 'gates when `os` mismatches the platform' "gated" "$LINK_RESULT"
x 'os gate' 'creates no file while gated' 1 test -e "$FIX/home/b.txt"
link_apply "~/b.txt" "$FIX/src/a.txt" "macos,linux" "" "" ""
t 'os gate' 'any token in `os: [macos,linux]` matches' "linked" "$LINK_RESULT"
rm -f "$FIX/home/b.txt"

# when gates
link_apply "~/c.txt" "$FIX/src/a.txt" "" "" "nosuchcmd-$$" ""
t when 'gates on a failing destination `when`' "gated" "$LINK_RESULT"
link_apply "~/c.txt" "$FIX/src/a.txt" "" "" "" "nosuchcmd-$$"
t when 'gates on a failing root `when`' "gated" "$LINK_RESULT"
link_apply "~/c.txt" "$FIX/src/a.txt" "" "" "sh" "sh"
t when 'links when both gates pass' "linked" "$LINK_RESULT"
rm -f "$FIX/home/c.txt"

# dry run
DOTFILES_DRY_RUN=1 link_apply "~/d.txt" "$FIX/src/a.txt" "" "" "" ""
t dry-run 'reports the would-run result' "would" "$LINK_RESULT"
x dry-run 'writes nothing' 1 test -e "$FIX/home/d.txt"
unset DOTFILES_DRY_RUN

# copy + git identity preservation + backup (Review Focus 3)
printf '[user]\n\tname = Fery\n\temail = old@example.com\n' > "$FIX/home/.gitconfig"
echo "src-identity" > "$FIX/src/gitconfig"
link_apply "~/.gitconfig" "$FIX/src/gitconfig" "" "true" "" ""
t copy 'copies instead of symlinking' "linked" "$LINK_RESULT"
t copy 'destination content comes from the source' "src-identity" "$(head -1 "$FIX/home/.gitconfig")"
t copy 'keeps `user.name` from the old file' "Fery" "$(git config --file "$FIX/home/.gitconfig" user.name)"
t copy 'keeps `user.email` from the old file' "old@example.com" "$(git config --file "$FIX/home/.gitconfig" user.email)"
t copy 'backs up the old file' "1" "$(grep -c '\[user\]' "$FIX/bak/.gitconfig" 2>/dev/null || echo 0)"

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
if [ "$1" = update ] && [ -f "${PPA_MARKER:-/nonexistent}" ]; then
  exit 100
fi
STUB
cat > "$FIX/bin/sudo" <<'STUB'
#!/usr/bin/env bash
exec "$@"
STUB
cat > "$FIX/bin/add-apt-repository" <<'STUB'
#!/usr/bin/env bash
echo "PPA_CALL $*" >> "${PPA_LOG:?}"
case " $* " in
  *" -r "*)
    rm -f "${PPA_MARKER:?}"
    ;;
  *)
    if [ "${PPA_BROKEN:-0}" = 1 ]; then
      touch "${PPA_MARKER:?}"
    fi
    ;;
esac
exit 0
STUB
chmod +x "$FIX/bin/"*
PATH_SAVE2="$PATH"

# macOS branch
PATH="$FIX/bin:$PATH_SAVE2"
out=$(DOTFILES_OS=Darwin brew_install haveform); t brew 'skips when the package is installed' "  haveform... done" "$out"
: > "$FIX/brew.log"
out=$(DOTFILES_OS=Darwin DOTFILES_SETUP_LOG="$FIX/brew.log" brew_install newform)
t brew 'installs a missing package' "  installing (brew): newform... done" "$out"
t brew 'raw output goes to the setup log' "1" "$(grep -c 'BREW_INSTALL -y newform' "$FIX/brew.log")"
x  brew 'refuses to run on Linux' 1 bash -c 'DOTFILES_OS=Linux; . "$1"; brew_install haveform' bash "$LIB"

# Linux branch, single apt update per run
export APT_LOG="$FIX/apt.log"; : > "$APT_LOG"
PATH="$FIX/bin:$PATH_SAVE2"
out=$(DOTFILES_OS=Linux apt_install havepkg);    t apt 'skips when the package is installed' "  havepkg... done" "$out"
DOTFILES_OS=Linux apt_install pkg-a >/dev/null
DOTFILES_OS=Linux apt_install pkg-b >/dev/null
t apt 'runs a single `update` per invocation' "1" "$(grep -c 'APT_CALL update' "$APT_LOG")"
t apt 'installs each missing package'    "2" "$(grep -c 'APT_CALL install' "$APT_LOG")"
t apt 'installs with `DEBIAN_FRONTEND=noninteractive`'     "2" "$(grep -c 'APT_CALL install.*DEBIAN_FRONTEND=noninteractive' "$APT_LOG")"
x  apt 'refuses to run on macOS' 1 bash -c 'DOTFILES_OS=Darwin; . "$1"; apt_install havepkg' bash "$LIB"
PATH="$PATH_SAVE2"; unset APT_LOG

# ppa_install: prefer the PPA; drop it and use the OS repo when it can't be used
export APT_LOG="$FIX/apt.log" PPA_LOG="$FIX/ppa.log" PPA_MARKER="$FIX/ppa.marker"
: > "$APT_LOG"; : > "$PPA_LOG"; rm -f "$PPA_MARKER"
PATH="$FIX/bin:$PATH_SAVE2"

# happy path: repo added, nothing removed, package installed
out=$(DOTFILES_OS=Linux DOTFILES_SETUP_LOG="$FIX/ppa.out" ppa_install ppa:good/ppa pkg-ppa-good)
t ppa 'adds the repository with `-y`'        "1" "$(grep -c 'PPA_CALL -y ppa:good/ppa' "$PPA_LOG")"
t ppa 'never removes a healthy repository'     "0" "$(grep -c 'PPA_CALL -r' "$PPA_LOG")"
t ppa 'installs the package from the PPA' "  installing (apt): pkg-ppa-good... done" "$out"

# no build for this release: refresh fails rc=100 -> repo dropped, install continues
: > "$APT_LOG"; : > "$PPA_LOG"; rm -f "$PPA_MARKER"
export PPA_BROKEN=1
out=$(DOTFILES_OS=Linux DOTFILES_SETUP_LOG="$FIX/ppa.out" ppa_install ppa:dead/ppa pkg-ppa-dead)
unset PPA_BROKEN
t ppa 'drops the repo when `update` fails (rc 100)'   "1" "$(grep -c 'PPA_CALL -r -y ppa:dead/ppa' "$PPA_LOG")"
t ppa 'falls back to the OS package install' "1" "$(grep -c 'installing (apt): pkg-ppa-dead... done' <<<"$out")"
t ppa 'notes the fallback in the setup log' "1" "$(grep -c 'no build for this release' "$FIX/ppa.out")"

# no add-apt-repository on the box: install the machinery first, never die
# (hermetic hosts only — skipped where the real tool exists in the system PATH)
if ! ( PATH="$PATH_SAVE2"; command -v add-apt-repository >/dev/null 2>&1 ); then
  mv "$FIX/bin/add-apt-repository" "$FIX/bin/_apr.hidden"
  : > "$APT_LOG"; : > "$PPA_LOG"
  out=$(DOTFILES_OS=Linux DOTFILES_SETUP_LOG="$FIX/ppa.out" ppa_install ppa:good/ppa pkg-ppa-notool)
  mv "$FIX/bin/_apr.hidden" "$FIX/bin/add-apt-repository"
  t ppa 'bootstraps `software-properties-common` when missing' "1" "$(grep -c 'APT_CALL install.*software-properties-common' "$APT_LOG")"
  t ppa 'installs the package after bootstrapping'   "1" "$(grep -c 'installing (apt): pkg-ppa-notool... done' <<<"$out")"
fi

x  ppa 'refuses to run on macOS' 1 bash -c 'DOTFILES_OS=Darwin; . "$1"; ppa_install ppa:x/y pkg' bash "$LIB"
PATH="$PATH_SAVE2"; unset APT_LOG PPA_LOG PPA_MARKER

finish lib_test
