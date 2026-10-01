#!/usr/bin/env bash
# Frontmatter-driven dotfiles installer.
#   1) run scripts/setup.d/<tool>.sh children in phase order (idempotent, isolated)
#   2) apply all maps: via scripts/link.sh (os/when gated) — linking happens only there
# Usage: install.sh [--only <name>] [--skip <name>] [--link-only] [--force] [--dry-run]
set -euo pipefail

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPTS_DIR=${DOTFILES_SCRIPTS_DIR:-$DOTFILES_DIR/scripts}
export DOTFILES_DIR
. "$SCRIPTS_DIR/lib.sh"
. "${DOTFILES_PHASES_FILE:-$SCRIPTS_DIR/phases.sh}"
path_setup
export BACKUP_DIR="$DOTFILES_DIR/dotfiles.old/$(date +%Y-%m-%d_%H-%M-%S)"
LOGS_DIR="$DOTFILES_DIR/logs"; export LOGS_DIR

usage() {
  sed -n '2,6s/^# //p' "${BASH_SOURCE[0]}"
  exit "${1:-1}"
}

ONLY=""; SKIP=""; LINK_ONLY=0
while [ $# -ne 0 ]; do
  case $1 in
    --only)      [ $# -ge 2 ] || usage; ONLY=$2; shift 2 ;;
    --skip)      [ $# -ge 2 ] || usage; SKIP=$2; shift 2 ;;
    --link-only) LINK_ONLY=1; shift ;;
    --force)     DOTFILES_FORCE=1; export DOTFILES_FORCE; shift ;;
    --dry-run)   DOTFILES_DRY_RUN=1; export DOTFILES_DRY_RUN; shift ;;
    --)          shift; break ;;
    -?*)         echo "Invalid argument: $1" 1>&2; usage ;;
    *)           break ;;
  esac
done

ALL_TOOLS=" ${PHASE_SYSTEM[*]-} ${PHASE_MANAGERS[*]-} ${PHASE_TOOLS[*]-} "
if [ -n "$ONLY" ]; then
  case "$ALL_TOOLS" in *" $ONLY "*) ;; *) echo "unknown tool: $ONLY" >&2; exit 1 ;; esac
fi
if [ -n "$SKIP" ]; then
  case "$ALL_TOOLS" in *" $SKIP "*) ;; *) echo "unknown tool: $SKIP" >&2; exit 1 ;; esac
fi

trap 'echo; e "$c_inf" "interrupted — backups (if any): ${BACKUP_DIR}"; exit 130' INT TERM

FAILED=()
ok_count=0
run_phase() { # run_phase <label> <names...>
  local label="$1"; shift
  [ $# -eq 0 ] && return 0
  printf '\n== %s ==\n' "$label"
  local name
  for name in "$@"; do
    [ -n "$SKIP" ] && [ "$name" = "$SKIP" ] && { echo "  skipped (--skip): $name"; continue; }
    [ -n "$ONLY" ] && [ "$name" != "$ONLY" ] && continue
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then echo "  would run: setup.d/$name.sh"; continue; fi
    if bash "$SCRIPTS_DIR/setup.d/$name.sh"; then
      echo "  ok: $name"; ok_count=$((ok_count+1))
    else
      echo "  FAILED: $name"; FAILED+=("$name")
    fi
  done
}

if [ "$LINK_ONLY" -eq 0 ]; then
  run_phase "system"   ${PHASE_SYSTEM[@]+"${PHASE_SYSTEM[@]}"}
  run_phase "managers" ${PHASE_MANAGERS[@]+"${PHASE_MANAGERS[@]}"}
  run_phase "tools"    ${PHASE_TOOLS[@]+"${PHASE_TOOLS[@]}"}
fi

printf '\n== link ==\n'
LINK_ARGS=()
[ "${DOTFILES_FORCE:-0}" = 1 ] && LINK_ARGS+=(--force)
[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && LINK_ARGS+=(--dry-run)
if ! bash "$SCRIPTS_DIR/link.sh" ${LINK_ARGS[@]+"${LINK_ARGS[@]}"}; then
  FAILED+=(link)
fi

printf '\n== summary ==\n'
nfail=${#FAILED[@]}
printf 'tools: %d ok, %d failed\n' "$ok_count" "$nfail"
if [ "$nfail" -gt 0 ]; then
  printf 'failed: %s\n' "${FAILED[*]}"
  [ -d "$BACKUP_DIR" ] && printf 'backups: %s\n' "$BACKUP_DIR"
  exit 1
fi
e "$c_suc" 'Everything is done ✔'
printf '\n'
