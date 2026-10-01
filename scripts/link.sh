#!/usr/bin/env bash
# Applies every maps: entry from config/**/README.md.
# Usage: link.sh [--dry-run] [--force]
# Env: DOTFILES_DIR (repo root), LINK_ROOT (stands in for $HOME, for tests),
#      DOTFILES_FORCE, DOTFILES_DRY_RUN, BACKUP_DIR (lazy default: dotfiles.old/<ts>)
set -euo pipefail
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOTFILES_DIR=${DOTFILES_DIR:-$(dirname "$SCRIPTS_DIR")}
export DOTFILES_DIR
. "$SCRIPTS_DIR/lib.sh"
path_setup

while [ $# -ne 0 ]; do
  case $1 in
    --dry-run) DOTFILES_DRY_RUN=1; export DOTFILES_DRY_RUN; shift ;;
    --force)   DOTFILES_FORCE=1;   export DOTFILES_FORCE;   shift ;;
    *) echo "link.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done

linked=0; noop=0; gated=0; would=0; missing=0; failed=0

for readme in "$DOTFILES_DIR/config/README.md" "$DOTFILES_DIR/config"/*/README.md; do
  [ -f "$readme" ] || continue
  rel_dir=$(dirname "${readme#"$DOTFILES_DIR"/}")
  printf '%s\n' "$rel_dir/"
  if ! entries=$(fm_entries "$readme"); then
    echo "  parse failed: $readme" >&2; exit 1
  fi
  root_when=$(fm_read "$readme" when)
  [ -n "$entries" ] || continue
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    # manual TSV split — bash `read` collapses empty fields when IFS is tab
    dest=${line%%$'\t'*}; r1=${line#*$'\t'}
    src=${r1%%$'\t'*};    r2=${r1#*$'\t'}
    os=${r2%%$'\t'*};     r3=${r2#*$'\t'}
    copy=${r3%%$'\t'*};   when=${r3#*$'\t'}
    abs_src="$DOTFILES_DIR/$rel_dir/$src"
    if [ ! -e "$abs_src" ]; then
      printf '  missing %s (source not present: %s)\n' "$dest" "$rel_dir/$src"
      missing=$((missing+1)); continue
    fi
    if link_apply "$dest" "$abs_src" "$os" "$copy" "$when" "$root_when"; then
      case "$LINK_RESULT" in
        linked) linked=$((linked+1)) ;;
        noop)   noop=$((noop+1)) ;;
        gated)  gated=$((gated+1)) ;;
        would)  would=$((would+1)) ;;
      esac
    else
      failed=$((failed+1))
    fi
  done <<< "$entries"
done

printf '%d linked, %d in place, %d gated, %d would, %d missing, %d failed\n' \
  "$linked" "$noop" "$gated" "$would" "$missing" "$failed"
[ "$failed" -eq 0 ]
