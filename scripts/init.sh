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

PROFILE="${PROFILE:-vps}"    # default when neither --profile nor PROFILE env is set
export LANG LC_ALL PROFILE DRY_RUN

printf 'Initializing...\n'
printf 'This might take a while, sit back and relax\n'

FLOW=$(cat <<'SCRIPT'
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

# inlined util.sh-style helpers — self-contained: no repo checkout when piped
c_suc='32'; c_red='31'; c_hl='1;33'
_c() { if [ -t 1 ]; then printf '\e[%sm%s\e[0m' "$1" "$2"; else printf '%s' "$2"; fi; }
msg_begin() { printf '  [%s] ' "$1"; _c "$c_hl" "$2"; printf '... '; }
msg_end() { case "$1" in done) _c "$c_suc" done ;; error) _c "$c_red" error ;; esac; printf '\n'; }
msg_hint() { printf '    %s\n' "$1"; }
on_err() { msg_end error; msg_hint "$BASH_COMMAND failed (line $LINENO)"; exit 1; }
trap on_err ERR
run() { [ "${DRY_RUN:-0}" = 1 ] && return 0; "$@"; }

msg_begin CONF 'locale settings'
run locale-gen "$LANG"
run update-locale "LC_ALL=$LC_ALL" "LANG=$LANG"
run dpkg-reconfigure --frontend noninteractive locales
msg_end done

msg_begin CONF timezone
run ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
run dpkg-reconfigure --frontend noninteractive tzdata
msg_end done

msg_begin UPDT repositories
run apt-get update -qq
msg_end done

msg_begin UPDT 'system packages'
run apt-get dist-upgrade -yqq
msg_end done
SCRIPT
)

bash -c "$FLOW"

if [ "$DRY_RUN" = 1 ]; then
  printf '    dry-run: no changes were made\n'
fi
printf 'All done\n'
