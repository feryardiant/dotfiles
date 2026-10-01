#!/usr/bin/env bash
# Run: bash scripts/tests/install_test.sh
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

# fixture scripts dir: real lib + link, stub children + phases
mkdir -p "$FIX/scripts/setup.d" "$FIX/repo/config" "$FIX/h1" "$FIX/h2" "$FIX/h3" "$FIX/h4" "$FIX/h5" "$FIX/h6" "$FIX/h7" "$FIX/h8" "$FIX/h9" "$FIX/h10" "$FIX/h11" "$FIX/h12" "$FIX/h13"
ln -s "$ROOT/scripts/lib.sh" "$FIX/scripts/lib.sh"
ln -s "$ROOT/scripts/util.sh" "$FIX/scripts/util.sh"
ln -s "$ROOT/scripts/link.sh" "$FIX/scripts/link.sh"
cat > "$FIX/scripts/setup.d/ok.sh" <<'STUB'
#!/usr/bin/env bash
touch "$HOME/ran-ok"
exit 0
STUB
cat > "$FIX/scripts/setup.d/fail.sh" <<'STUB'
#!/usr/bin/env bash
touch "$HOME/ran-fail"
exit 3
STUB
chmod +x "$FIX/scripts/setup.d/"*.sh
cat > "$FIX/phases.sh" <<'STUB'
PHASE_SYSTEM=(ok fail)
PHASE_MANAGERS=()
PHASE_TOOLS=()
STUB

run() { # run <home> [args...] — captures output in $OUT, code in $RC
  local h="$1"; shift
  OUT=$(HOME="$h" DOTFILES_DIR="$FIX/repo" DOTFILES_SCRIPTS_DIR="$FIX/scripts" \
        DOTFILES_PHASES_FILE="$FIX/phases.sh" bash "$ROOT/install.sh" "$@" 2>&1)
  RC=$?
}

# 1) failure isolation (Review Focus 5)
run "$FIX/h1"
ck "run: exit nonzero" "1" "$([ "$RC" -ne 0 ] && echo 1 || echo 0)"
ck "run: ok executed" "1" "$([ -f "$FIX/h1/ran-ok" ] && echo 1 || echo 0)"
ck "run: fail executed (continues)" "1" "$([ -f "$FIX/h1/ran-fail" ] && echo 1 || echo 0)"
printf '%s' "$OUT" | grep -q "See .*setup-fail.txt for more info" && f=1 || f=0
ck "run: failure shows log hint" "1" "$f"
printf '%s' "$OUT" | grep -q "failed: fail" && fl=1 || fl=0
ck "run: failure named in summary" "1" "$fl"
printf '%s' "$OUT" | grep -q "== link ==" && l=1 || l=0
ck "run: link phase still ran" "1" "$l"

# 2) --only
run "$FIX/h2" --only ok
ck "--only ok: exit 0" "0" "$RC"
ck "--only ok: fail skipped" "0" "$([ -f "$FIX/h2/ran-fail" ] && echo 1 || echo 0)"

# 3) --skip
run "$FIX/h3" --skip fail
ck "--skip fail: exit 0" "0" "$RC"
ck "--skip fail: not run" "0" "$([ -f "$FIX/h3/ran-fail" ] && echo 1 || echo 0)"

# 4) --dry-run: nothing executed
run "$FIX/h4" --dry-run
ck "dry-run: exit 0" "0" "$RC"
printf '%s' "$OUT" | grep -q "would run: setup.d/ok.sh" && w=1 || w=0
ck "dry-run: announced" "1" "$w"
ck "dry-run: no child ran" "0" "$([ -f "$FIX/h4/ran-ok" ] && echo 1 || echo 0)"

# 5) invalid input
run "$FIX/h5" --nope
ck "unknown flag: exit 1" "1" "$RC"
run "$FIX/h6" --only nope
ck "unknown --only name: exit 1" "1" "$RC"

# 6) --link-only: no tool phases
run "$FIX/h7" --link-only
ck "link-only: exit 0" "0" "$RC"
ck "link-only: no child ran" "0" "$([ -f "$FIX/h7/ran-ok" ] && echo 1 || echo 0)"

# 7) comma-separated --only/--skip
run "$FIX/h8" --only ok,fail
ck "--only ok,fail: both ran (list parsed)" "1" "$([ -f "$FIX/h8/ran-ok" ] && [ -f "$FIX/h8/ran-fail" ] && echo 1 || echo 0)"
ck "--only ok,fail: exit nonzero (fail tool ran)" "1" "$([ "$RC" -ne 0 ] && echo 1 || echo 0)"

run "$FIX/h9" --only "ok, fail"
ck "--only with spaces: both ran (list parsed)" "1" "$([ -f "$FIX/h9/ran-ok" ] && [ -f "$FIX/h9/ran-fail" ] && echo 1 || echo 0)"
ck "--only with spaces: exit nonzero (fail tool ran)" "1" "$([ "$RC" -ne 0 ] && echo 1 || echo 0)"

run "$FIX/h10" --skip ok,fail
ck "--skip ok,fail: exit 0" "0" "$RC"
ck "--skip ok,fail: none ran" "0" "$([ -f "$FIX/h10/ran-ok" ] || [ -f "$FIX/h10/ran-fail" ] && echo 1 || echo 0)"

run "$FIX/h11" --only ok,nope
ck "--only unknown element: exit 1" "1" "$RC"
printf '%s' "$OUT" | grep -q "unknown tool: nope" && u=1 || u=0
ck "--only unknown element names it" "1" "$u"

run "$FIX/h12" --only ,
ck "--only empty list: exit 1" "1" "$RC"
printf '%s' "$OUT" | grep -q "Usage: install.sh" && g=1 || g=0
ck "--only empty list: shows usage" "1" "$g"

run "$FIX/h13" --only ok,
ck "--only trailing comma: exit 0" "0" "$RC"
ck "--only trailing comma: ok ran" "1" "$([ -f "$FIX/h13/ran-ok" ] && echo 1 || echo 0)"
ck "--only trailing comma: fail not run" "0" "$([ -f "$FIX/h13/ran-fail" ] && echo 1 || echo 0)"

printf '\ninstall_test: %d failures\n' "$FAILS"
[ "$FAILS" -eq 0 ]
