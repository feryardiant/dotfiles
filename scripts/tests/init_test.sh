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

finish init
