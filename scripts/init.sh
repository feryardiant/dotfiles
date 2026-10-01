#!/usr/bin/env bash
# Unified first-boot bootstrap for Ubuntu — one file, four doors:
#   sudo ./scripts/init.sh [--profile lxc|vps] [--dry-run]
#   curl -fsSL <raw>/scripts/init.sh | sudo bash
#   curl -fsSL <raw>/scripts/init.sh | bash -s -- --profile vps
#   cloud-init user-data: paste this file as-is (it runs as root)
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: init.sh [--profile lxc|vps] [--dry-run] [-h|--help]

  --profile <p>   bootstrap profile: lxc or vps (default: auto-detect)
  --dry-run       print every step; never calls sudo, never changes anything
  -h, --help      show this help

Environment: PROFILE, DRY_RUN=1  (for cloud-init runcmd wrappers)
USAGE
}

LANG="${LANG:-en_US.UTF-8}"
LC_ALL="${LC_ALL:-en_US.UTF-8}"
PROFILE="${PROFILE:-}"
DRY_RUN="${DRY_RUN:-0}"

while [ $# -gt 0 ]; do
  case "$1" in
    --profile)
      [ $# -ge 2 ] || { echo 'init.sh: --profile requires a value' >&2; usage >&2; exit 2; }
      PROFILE=$2
      shift 2
      ;;
    --profile=*)
      PROFILE=${1#--profile=}
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "init.sh: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

printf 'Initializing...\n'
printf 'This might take a while, sit back and relax\n'
