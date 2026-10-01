#!/usr/bin/env bash
# Test runner for scripts/lib.sh — run: bash scripts/tests/lib_test.sh
set -u
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"
. "$LIB"

TESTS_RUN=0; TESTS_FAIL=0
t() { # t <name> <expected> <actual>
  TESTS_RUN=$((TESTS_RUN+1))
  if [ "$2" = "$3" ]; then printf 'ok %d - %s\n' "$TESTS_RUN" "$1"
  else TESTS_FAIL=$((TESTS_FAIL+1)); printf 'NOT OK %d - %s\n  expected: [%s]\n  actual:   [%s]\n' "$TESTS_RUN" "$1" "$2" "$3"; fi
}
x() { # x <name> <expected-exit> <cmd...>
  TESTS_RUN=$((TESTS_RUN+1)); local want="$2"; shift 2
  "$@" >/dev/null 2>&1; local got=$?
  if [ "$want" = "$got" ]; then printf 'ok %d - %s\n' "$TESTS_RUN" "$1"
  else TESTS_FAIL=$((TESTS_FAIL+1)); printf 'NOT OK %d - %s (want exit %s, got %s)\n' "$TESTS_RUN" "$1" "$want" "$got"; fi
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

# --- fm_entries: violations → exit 1 ---
x "inline form rejected"     1 fm_entries "$FIX/inline.md"
x "unknown root key"         1 fm_entries "$FIX/badkey.md"
x "when without maps"        1 fm_entries "$FIX/nomaps.md"
x "dest must be ~/..."       1 fm_entries "$FIX/baddest.md"
x "when must be scalar"      1 fm_entries "$FIX/badwhen.md"
x "duplicate dest"           1 fm_entries "$FIX/dup.md"
x "block missing src"        1 fm_entries "$FIX/nosrc.md"
x "missing file"             1 fm_entries "$FIX/nope.md"

printf '\n%d tests, %d failures\n' "$TESTS_RUN" "$TESTS_FAIL"
[ "$TESTS_FAIL" -eq 0 ]
