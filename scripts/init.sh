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

write_vimrc() {
  mkdir -p /etc/vim
  cat > /etc/vim/vimrc.local <<'VIMRC'
set nocompatible
filetype plugin indent on

set encoding=utf-8 nobomb  " BOM often causes trouble
set mouse=a                " Enable moouse in all in all modes
set noerrorbells           " Disable error bells
set ffs=unix,dos,mac       " Use Unix as the standard file type
set nohidden               " Close the buffer when tab is closed
set confirm                " Confirm before exit if file has changed
set nu relativenumber      " Enable line numbers

if has('wildmenu')
	set wildmenu
endif

set t_Co=256
hi! Comment ctermfg=240
hi! CursorLineNr ctermfg=255
hi! LineNr ctermfg=240
hi! StatusLine ctermbg=238
hi! Visual ctermbg=238

set wildmode=longest:full,full
set wildchar=<TAB>

" Searches
set hlsearch    " Highlight searches
set incsearch   " Highlight dynamically as pattern is typed
set ignorecase  " Ignore case of searches
set smartcase   " Ignore 'ignorecase' if search patter contains uppercase characters
set wrapscan    " Searches wrap around end of file

nnoremap <Esc><Esc> :noh<CR> " Double <esc> to clear search highlight
VIMRC
}

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

if [ "$PROFILE" = lxc ]; then
  PKGS='gpg vim htop tree curl net-tools git unzip zip'
else
  PKGS='gpg vim htop tree curl net-tools git unzip zip zsh bat eza fzf ripgrep starship'
fi
msg_begin INST "basic tools ($PROFILE)"
# shellcheck disable=SC2086 -- PKGS is deliberately word-split
run apt-get install -yqq --no-install-recommends $PKGS
msg_end done

msg_begin CONF 'default user'
TARGET=$(awk -F: '$3 >= 1000 && $3 < 65534 && $7 !~ /(nologin|false)$/ { print $3, $1 }' /etc/passwd | sort -n | head -1 | cut -d' ' -f2)
if [ -z "$TARGET" ]; then
  TARGET=admin
  run adduser --disabled-password --gecos '' admin
  run bash -c 'echo "admin:password" | chpasswd'
fi
run usermod -aG adm,root,sudo,www-data "$TARGET"
run sh -c "printf '%s ALL=(ALL) NOPASSWD: ALL\n' '$TARGET' > /etc/sudoers.d/90-admin-users"
KEYS_INSTALLED=0
KEYS_SRC=''
if [ -s /root/.ssh/authorized_keys ]; then
  KEYS_SRC=/root/.ssh/authorized_keys
elif [ -n "${SUDO_USER:-}" ]; then
  SUDO_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  [ -s "$SUDO_HOME/.ssh/authorized_keys" ] && KEYS_SRC="$SUDO_HOME/.ssh/authorized_keys"
fi
if [ -n "$KEYS_SRC" ]; then
  HOME_DIR=$(getent passwd "$TARGET" | cut -d: -f6)
  run mkdir -p "$HOME_DIR/.ssh"
  run cp "$KEYS_SRC" "$HOME_DIR/.ssh/authorized_keys"
  run chown -R "$TARGET:$TARGET" "$HOME_DIR/.ssh"
  run chmod 700 "$HOME_DIR/.ssh"
  run chmod 600 "$HOME_DIR/.ssh/authorized_keys"
  KEYS_INSTALLED=1
fi
msg_end done
msg_hint 'group changes apply at next login'

msg_begin CONF 'sshd hardening'
run sed -iE 's~#PermitRootLogin .*~PermitRootLogin prohibit-password~' /etc/ssh/sshd_config
run sed -iE 's~#PubkeyAuthentication .*~PubkeyAuthentication yes~' /etc/ssh/sshd_config
if [ "$KEYS_INSTALLED" = 1 ]; then
  run sed -iE 's~#PasswordAuthentication .*~PasswordAuthentication no~' /etc/ssh/sshd_config
fi
run sed -iE 's~#AllowAgentForwarding .*~AllowAgentForwarding yes~' /etc/ssh/sshd_config
run sed -iE 's~#AllowTcpForwarding .*~AllowTcpForwarding yes~' /etc/ssh/sshd_config
run sed -iE 's~#PermitTTY .*~PermitTTY yes~' /etc/ssh/sshd_config
run systemctl restart sshd
msg_end done
if [ "$KEYS_INSTALLED" != 1 ]; then
  msg_hint 'password authentication kept (no authorized_keys found)'
fi

msg_begin CONF 'vim defaults'
VIM_ALT=0
if [ -x /usr/bin/vim.basic ]; then
  run update-alternatives --set editor /usr/bin/vim.basic
  VIM_ALT=1
fi
run write_vimrc
msg_end done
if [ "$VIM_ALT" != 1 ]; then
  msg_hint 'editor alternatives skipped (vim.basic not found)'
fi

msg_begin UPDT cleanup
run apt-get clean
run apt-get autoclean
run apt-get autoremove -y
msg_end done
SCRIPT
)

bash -c "$FLOW"

if [ "$DRY_RUN" = 1 ]; then
  printf '    dry-run: no changes were made\n'
fi
printf 'All done\n'
