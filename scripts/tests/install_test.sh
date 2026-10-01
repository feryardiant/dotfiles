#!/usr/bin/env bash
# Run: bash scripts/tests/install_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$ROOT/scripts/tests/harness.sh"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT

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
t run 'exits nonzero when a phase tool fails' "1" "$([ "$RC" -ne 0 ] && echo 1 || echo 0)"
t run 'runs the passing tool' "1" "$([ -f "$FIX/h1/ran-ok" ] && echo 1 || echo 0)"
t run 'keeps going after a failing tool' "1" "$([ -f "$FIX/h1/ran-fail" ] && echo 1 || echo 0)"
printf '%s' "$OUT" | grep -q "See .*setup-fail.txt for more info" && f=1 || f=0
t run 'hints at the setup log on failure' "1" "$f"
printf '%s' "$OUT" | grep -q "failed: fail" && fl=1 || fl=0
t run 'names the failed tool in the summary' "1" "$fl"
printf '%s' "$OUT" | grep -q "== link ==" && l=1 || l=0
t run 'link phase still runs after tool failures' "1" "$l"

# 2) --only
run "$FIX/h2" --only ok
t --only 'exits zero when the selected tool passes' "0" "$RC"
t --only 'leaves unselected tools alone' "0" "$([ -f "$FIX/h2/ran-fail" ] && echo 1 || echo 0)"

# 3) --skip
run "$FIX/h3" --skip fail
t --skip 'exits zero with the failing tool skipped' "0" "$RC"
t --skip 'never runs the skipped tool' "0" "$([ -f "$FIX/h3/ran-fail" ] && echo 1 || echo 0)"

# 4) --dry-run: nothing executed
run "$FIX/h4" --dry-run
t dry-run 'exits zero' "0" "$RC"
printf '%s' "$OUT" | grep -q "would run: setup.d/ok.sh" && w=1 || w=0
t dry-run 'announces `would run` per tool' "1" "$w"
t dry-run 'executes no child script' "0" "$([ -f "$FIX/h4/ran-ok" ] && echo 1 || echo 0)"

# 5) invalid input
run "$FIX/h5" --nope
t usage 'rejects unknown flags' "1" "$RC"
run "$FIX/h6" --only nope
t usage 'rejects unknown tool names' "1" "$RC"

# 6) --link-only: no tool phases
run "$FIX/h7" --link-only
t link-only 'exits zero' "0" "$RC"
t link-only 'runs no setup tool' "0" "$([ -f "$FIX/h7/ran-ok" ] && echo 1 || echo 0)"

# 7) comma-separated --only/--skip
run "$FIX/h8" --only ok,fail
t --only 'runs every tool in a comma list' "1" "$([ -f "$FIX/h8/ran-ok" ] && [ -f "$FIX/h8/ran-fail" ] && echo 1 || echo 0)"
t --only 'still exits nonzero when a listed tool fails' "1" "$([ "$RC" -ne 0 ] && echo 1 || echo 0)"

run "$FIX/h9" --only "ok, fail"
t --only 'splits even a space-padded list' "1" "$([ -f "$FIX/h9/ran-ok" ] && [ -f "$FIX/h9/ran-fail" ] && echo 1 || echo 0)"
t --only 'still exits nonzero via a spaced list' "1" "$([ "$RC" -ne 0 ] && echo 1 || echo 0)"

run "$FIX/h10" --skip ok,fail
t --skip 'skips every tool in a comma list' "0" "$RC"
t --skip 'executes neither listed tool' "0" "$([ -f "$FIX/h10/ran-ok" ] || [ -f "$FIX/h10/ran-fail" ] && echo 1 || echo 0)"

run "$FIX/h11" --only ok,nope
t --only 'exits 1 when a list element is unknown' "1" "$RC"
printf '%s' "$OUT" | grep -q "unknown tool: nope" && u=1 || u=0
t --only 'names the unknown element `nope`' "1" "$u"

run "$FIX/h12" --only ,
t --only 'rejects an empty list (`--only ,`)' "1" "$RC"
printf '%s' "$OUT" | grep -q "Usage: install.sh" && g=1 || g=0
t --only 'prints usage for an empty list' "1" "$g"

run "$FIX/h13" --only ok,
t --only 'tolerates a trailing comma' "0" "$RC"
t --only 'runs the listed tool' "1" "$([ -f "$FIX/h13/ran-ok" ] && echo 1 || echo 0)"
t --only 'leaves other tools untouched' "0" "$([ -f "$FIX/h13/ran-fail" ] && echo 1 || echo 0)"

finish install_test
