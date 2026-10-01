#!/usr/bin/env bash
# Unified first-boot bootstrap for Ubuntu - one file
# Usage: init.sh [--profile lxc|vps] [--dry-run] [-h|--help]
#
#   --profile <p>   bootstrap profile: lxc or vps (default: auto-detect)
#   --dry-run       print every step; never calls sudo, never changes anything
#   -h, --help      show this help
#
# Environment: PROFILE, DRY_RUN=1  (for cloud-init runcmd wrappers)
#
# Examples:
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
OS_RELEASE="${OS_RELEASE:-/etc/os-release}"

while [ $# -gt 0 ]; do
  case "$1" in
    --profile)
      if [ $# -lt 2 ]; then
        echo 'init.sh: --profile requires a value' >&2
        usage >&2
        exit 2
      fi
      PROFILE=$2
      if [ -z "$PROFILE" ]; then
        echo 'init.sh: --profile requires a value' >&2
        usage >&2
        exit 2
      fi
      shift 2
      ;;
    --profile=*)
      PROFILE=${1#--profile=}
      if [ -z "$PROFILE" ]; then
        echo 'init.sh: --profile requires a value' >&2
        usage >&2
        exit 2
      fi
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

if [ -z "$PROFILE" ]; then
  if command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt --quiet --container; then
    PROFILE=lxc
  else
    PROFILE=vps
  fi
fi
case "$PROFILE" in
  lxc|vps) ;;
  *)
    echo "init.sh: unknown profile: $PROFILE (want lxc or vps)" >&2
    usage >&2
    exit 2
    ;;
esac
export LANG LC_ALL PROFILE DRY_RUN

# Ubuntu-only: every step below (locale-gen, the git PPA) assumes an Ubuntu release
if [ "$DRY_RUN" != 1 ] && ! grep -qsE '^ID="?ubuntu"?$' "$OS_RELEASE"; then
  echo 'init.sh: requires Ubuntu (os-release ID=ubuntu)' >&2
  exit 1
fi

printf 'Initializing...\n'
printf 'This might take a while, sit back and relax\n'

IFS= read -r -d '' FLOW <<'SCRIPT' || true
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

# inlined util.sh-style helpers — self-contained: no repo checkout when piped
c_suc='32'
c_red='31'
c_hl='1;33'
_c() {
  if [ -t 1 ]; then
    printf '\e[%sm%s\e[0m' "$1" "$2"
  else
    printf '%s' "$2"
  fi
}
msg_begin() {
  printf '  [%s] ' "$1"
  _c "$c_hl" "$2"
  printf '... '
}
msg_end() {
  if [ "$1" = done ]; then
    _c "$c_suc" done
  else
    _c "$c_red" error
  fi
  printf '\n'
}
msg_hint() {
  printf '    %s\n' "$1"
}
on_err() {
  trap - ERR
  msg_end error
  msg_hint "${RUN_CMD:-$BASH_COMMAND} failed (line ${RUN_LINE:-?})"
  if [ -n "${OUT:-}" ]; then
    printf '%s\n' "$OUT" | sed 's/^/    /'
  fi
  exit 1
}
trap on_err ERR
# run: execute a step command with both streams captured, so chatty commands
# (locale-gen, dpkg-reconfigure, adduser, apt …) can never split a protocol line
# (`  [TYPE] step... status`). On success the capture is dropped; on failure
# on_err replays it indented after the status and names the exact command with
# its call-site line. The ERR trap is suspended during the capture so it cannot
# fire inside the command substitution.
run() {
  if [ "${DRY_RUN:-0}" = 1 ]; then
    return 0
  fi
  RUN_CMD="$*"
  RUN_LINE=${BASH_LINENO[0]:-?}
  trap - ERR
  OUT=$("$@" 2>&1) && rc=0 || rc=$?
  trap on_err ERR
  if [ "$rc" -ne 0 ]; then
    return "$rc"
  fi
  RUN_CMD=''
  RUN_LINE=''
  OUT=''
}

write_vimrc() {
  mkdir -p /etc/vim
  cat > /etc/vim/vimrc.local <<'VIMRC'
set nocompatible
filetype plugin indent on

set encoding=utf-8 nobomb  " BOM often causes trouble
set ffs=unix,dos,mac       " Use Unix as the standard file type
set nu relativenumber      " Enable line numbers

set mouse=a       " Enable mouse in all modes
set noerrorbells  " Disable error bells
set nohidden      " Close the buffer when tab is closed
set confirm       " Confirm before exit if file has changed

set t_Co=256
hi! Comment ctermfg=240
hi! CursorLineNr ctermfg=255
hi! LineNr ctermfg=240
hi! StatusLine ctermbg=238
hi! Visual ctermbg=238

if has('wildmenu')
  set wildmenu
endif

set wildmode=longest:full,full
set wildchar=<TAB>
set completeopt=menu,menuone,noselect

" Auto/Smart/Copy indent from last line when starting new line
set autoindent smartindent copyindent
set backspace=indent,eol,start

" Searches
set hlsearch    " Highlight searches
set incsearch   " Highlight dynamically as pattern is typed
set ignorecase  " Ignore case of searches
set smartcase   " Ignore 'ignorecase' if search pattern contains uppercase characters
set wrapscan    " Searches wrap around end of file

" Better indenting and dedenting in visual mode
vmap < <gv
vmap > >gv

" Keep cursor in the middle while scrolling
nmap <C-d> <C-d>zz
nmap <C-u> <C-u>zz

" Keep cursor in the middle while navigating through search results
nnoremap n nzzzv
nnoremap N Nzzzv

nnoremap <Esc><Esc> :noh<CR> " Double <esc> to clear search highlight

nnoremap <Tab> :bnext<CR>       " Next buffer
nnoremap <S-Tab> :bprevious<CR> " Prev buffer

" Move lines - use ALT+J/K to move line up and down
nnoremap <A-j> :m .+1<CR>==         " Move lines down
nnoremap <A-k> :m .-2<CR>==         " Move lines up
inoremap <A-j> <Esc>:m .+1<CR>==gi  " Move lines down
inoremap <A-k> <Esc>:m .-2<CR>==gi  " Move lines up
vnoremap <A-j> :m '>+1<CR>gv=gv     " Move lines down
vnoremap <A-k> :m '<-2<CR>gv=gv     " Move lines up
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
# stock images ship no add-apt-repository (it lives in software-properties-common)
run apt-get install -qq --no-install-recommends software-properties-common
run add-apt-repository -y ppa:git-core/ppa
run apt-get update -qq
msg_end done

msg_begin UPDT 'system packages'
run apt-get dist-upgrade -yqq
msg_end done

if [ "$PROFILE" = lxc ]; then
  PKGS='gpg vim htop tree curl openssh-server openssl net-tools git unzip zip'
else
  PKGS='gpg vim htop tree curl openssh-server openssl net-tools git unzip zip zsh bat eza fzf ripgrep starship'
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
  # known-credential backdoor (CWE-798) removed: random per-bootstrap secret,
  # hinted below and kept mode 600 in the account's home as an emergency copy
  ADMIN_PW=''
  if command -v openssl >/dev/null 2>&1; then
    ADMIN_PW=$(openssl rand -base64 12)
  fi
  if [ -n "$ADMIN_PW" ]; then
    run bash -c "printf '%s:%s\n' '$TARGET' '$ADMIN_PW' | chpasswd"
    ADMIN_HOME=''
    if command -v getent >/dev/null 2>&1; then
      ADMIN_HOME=$(getent passwd "$TARGET" | cut -d: -f6)
    fi
    run bash -c "umask 177 && printf '%s\n' '$ADMIN_PW' > '$ADMIN_HOME/.init-password' && chown '$TARGET:' '$ADMIN_HOME/.init-password'"
  fi
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
  if [ "$KEYS_SRC" != "$HOME_DIR/.ssh/authorized_keys" ]; then
    run cp "$KEYS_SRC" "$HOME_DIR/.ssh/authorized_keys"
  fi
  run chown -R "$TARGET:$TARGET" "$HOME_DIR/.ssh"
  run chmod 700 "$HOME_DIR/.ssh"
  run chmod 600 "$HOME_DIR/.ssh/authorized_keys"
  KEYS_INSTALLED=1
fi
msg_end done
msg_hint 'group changes apply at next login'
if [ -n "${ADMIN_PW:-}" ]; then
  msg_hint "initial password: $ADMIN_PW (saved to $ADMIN_HOME/.init-password)"
fi

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

if [ "$DRY_RUN" = 1 ] || [ "$(id -u)" -eq 0 ]; then
  bash -c "$FLOW"
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo 'root required: sudo not found' >&2
    exit 1
  fi
  sudo -k || true
  if ! sudo -v; then
    echo 'root required — run via sudo or "curl … | sudo bash"' >&2
    exit 1
  fi
  sudo env "LANG=$LANG" "LC_ALL=$LC_ALL" "PROFILE=$PROFILE" "DRY_RUN=$DRY_RUN" bash -c "$FLOW"
fi

if [ "$DRY_RUN" = 1 ]; then
  printf '    dry-run: no changes were made\n'
fi
printf 'All done\n'
