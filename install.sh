#!/usr/bin/env bash
# Frontmatter-driven dotfiles installer.
#   1) run scripts/setup.d/<tool>.sh children in phase order (idempotent, isolated)
#   2) apply all maps: via scripts/link.sh (os/when gated) — linking happens only there
# Usage: install.sh [--only <name>[,<name>...]] [--skip <name>[,<name>...]] [--link-only] [--force] [--dry-run]

set -euo pipefail

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPTS_DIR=${DOTFILES_SCRIPTS_DIR:-$DOTFILES_DIR/scripts}
export DOTFILES_DIR
. "$SCRIPTS_DIR/lib.sh"
. "${DOTFILES_PHASES_FILE:-$SCRIPTS_DIR/phases.sh}"
path_setup
export BACKUP_DIR="$DOTFILES_DIR/dotfiles.old/$(date +%Y-%m-%d_%H-%M-%S)"
LOGS_DIR="$DOTFILES_DIR/scripts/logs"; export LOGS_DIR
mkdir -p "$LOGS_DIR"

usage() {
  sed -n '2,6s/^# //p' "${BASH_SOURCE[0]}"
  exit "${1:-1}"
}

ONLY=""; SKIP=""; LINK_ONLY=0; ONLY_SET=0; SKIP_SET=0
while [ $# -ne 0 ]; do
  case $1 in
    --only)      [ $# -ge 2 ] || usage; ONLY=$2; ONLY_SET=1; shift 2 ;;
    --skip)      [ $# -ge 2 ] || usage; SKIP=$2; SKIP_SET=1; shift 2 ;;
    --link-only) LINK_ONLY=1; shift ;;
    --force)     DOTFILES_FORCE=1; export DOTFILES_FORCE; shift ;;
    --dry-run)   DOTFILES_DRY_RUN=1; export DOTFILES_DRY_RUN; shift ;;
    --)          shift; break ;;
    -?*)         echo "Invalid argument: $1" 1>&2; usage ;;
    *)           break ;;
  esac
done

ALL=(${PHASE_SYSTEM[@]+"${PHASE_SYSTEM[@]}"} ${PHASE_MANAGERS[@]+"${PHASE_MANAGERS[@]}"} ${PHASE_TOOLS[@]+"${PHASE_TOOLS[@]}"})

split_words() { # split_words <raw> — fills SPLIT: comma-split, trimmed, empties dropped
  SPLIT=()
  local item rest=$1
  while [ -n "$rest" ]; do
    item=${rest%%,*}
    if [ "$rest" = "$item" ]; then rest=""; else rest=${rest#*,}; fi
    item=${item#"${item%%[![:space:]]*}"}
    item=${item%"${item##*[![:space:]]}"}
    [ -n "$item" ] && SPLIT+=("$item")
  done
  return 0
}

in_list() { # in_list <needle> [<hay>...]
  local needle=$1 x
  shift
  for x in "$@"; do [ "$x" = "$needle" ] && return 0; done
  return 1
}

split_words "$ONLY"
[ "$ONLY_SET" -eq 1 ] && [ "${#SPLIT[@]}" -eq 0 ] && usage
ONLY_LIST=(${SPLIT[@]+"${SPLIT[@]}"})
split_words "$SKIP"
[ "$SKIP_SET" -eq 1 ] && [ "${#SPLIT[@]}" -eq 0 ] && usage
SKIP_LIST=(${SPLIT[@]+"${SPLIT[@]}"})

for _name in ${ONLY_LIST[@]+"${ONLY_LIST[@]}"} ${SKIP_LIST[@]+"${SKIP_LIST[@]}"}; do
  in_list "$_name" ${ALL[@]+"${ALL[@]}"} || { echo "unknown tool: $_name" >&2; exit 1; }
done
unset _name

trap 'echo; _c "$c_inf" "interrupted — backups (if any): ${BACKUP_DIR}"; printf "\n"; exit 130' INT TERM

FAILED=()
ok_count=0
run_phase() { # run_phase <label> <names...>
  local label="$1"; shift
  [ $# -eq 0 ] && return 0
  printf '\n== %s ==\n' "$label"

  local name

  for name in "$@"; do
    [ "${#SKIP_LIST[@]}" -gt 0 ] && in_list "$name" ${SKIP_LIST[@]+"${SKIP_LIST[@]}"} && { echo "  skipped (--skip): $name"; continue; }
    [ "${#ONLY_LIST[@]}" -gt 0 ] && ! in_list "$name" ${ONLY_LIST[@]+"${ONLY_LIST[@]}"} && continue

    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
      echo "  would run: setup.d/$name.sh"
      continue
    fi

    DOTFILES_SETUP_LOG="$LOGS_DIR/setup-$name.txt"; export DOTFILES_SETUP_LOG
    : > "$DOTFILES_SETUP_LOG"   # fresh log per child per run

    if bash "$SCRIPTS_DIR/setup.d/$name.sh"; then
      ok_count=$((ok_count+1))
    else
      msg_hint "$DOTFILES_SETUP_LOG"
      FAILED+=("$name")
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
_c "$c_suc" 'Everything is done ✔'
printf '\n'
