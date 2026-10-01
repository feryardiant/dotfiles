#!/usr/bin/env bash
# Shared library for install.sh, link.sh, and scripts/setup.d/*.sh.
# Sourced, never executed. bash >= 3.2 compatible. No `set -e` here — callers set their own.

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/util.sh"   # colors + one-line status helpers

# ---------------------------------------------------------------------------
# Frontmatter (schema v2: root maps/when; dest = string | block src/os/copy/when)
# ---------------------------------------------------------------------------

# fm_read <readme> <key> — print root scalar value for <key> ("" if absent)
fm_read() {
  [ -f "$1" ] || return 1
  awk -v want="$2" '
    NR==1 && $0=="---" { f=1; next }
    f && $0=="---" { exit }
    f && index($0, want ":")==1 { sub(/^[^:]*:[ \t]*/, ""); print; exit }
  ' "$1"
}

# fm_entries <readme> — one mapping per line, TAB-separated:
#   dest <TAB> src <TAB> os <TAB> copy <TAB> when      (empty field = unset)
# Exit 1 + "file: reason" on stderr for any schema violation.
fm_entries() {
  [ -f "$1" ] || { echo "$1: not found" >&2; return 1; }
  awk -v FN="$1" '
    function e(msg) { printf "%s: %s\n", FN, msg > "/dev/stderr"; bad=1; exit 1 }
    function flush() {
      if (pend != "") {
        if (bsrc == "") e("block entry missing src: " pend)
        printf "%s\t%s\t%s\t%s\t%s\n", pend, bsrc, bos, bcopy, bwhen
        pend=""; bsrc=""; bos=""; bcopy=""; bwhen=""
      }
    }
    NR==1 {
      if ($0 != "---") e("frontmatter must start with --- on line 1")
      infm=1; next
    }
    infm && $0=="---" { infm=0; closed=1; exit }
    infm {
      line=$0
      if (line ~ /^  ~/) {                       # dest line (2-space indent)
        flush()
        rest=substr(line,3)
        if (rest ~ /\{/) e("inline object form forbidden: " rest)
        i=index(rest, ":")
        if (i==0) e("dest line missing colon: " line)
        dest=substr(rest,1,i-1); val=substr(rest,i+1); sub(/^[ \t]+/,"",val)
        if (dest !~ /^~\//) e("dest must start with ~/.: " dest)
        if (dest in seen) e("duplicate dest: " dest)
        seen[dest]=1
        if (val=="") pend=dest                   # block entry begins
        else printf "%s\t%s\t\t\t\n", dest, val  # string entry
      } else if (line ~ /^    /) {               # 4-space: block qualifier
        if (pend=="") e("qualifier outside a block entry: " line)
        rest=substr(line,5)
        i=index(rest,":")
        if (i==0) e("malformed qualifier line: " line)
        key=substr(rest,1,i-1); val=substr(rest,i+1); sub(/^[ \t]+/,"",val)
        if (key=="src") bsrc=val
        else if (key=="os") {
          if (val !~ /^\[(macos|linux|windows)(, *(macos|linux|windows))*\]$/) e("bad os list: " val)
          bos=val
        } else if (key=="copy") {
          if (val!="true" && val!="false") e("copy must be true|false: " val)
          bcopy=val
        } else if (key=="when") {
          if (val=="" || val ~ /[][]/) e("when must be a scalar command: " val)
          bwhen=val
        } else e("unknown block key: " key)
      } else if (line ~ /^[A-Za-z_][A-Za-z0-9_]*:/) {   # root key
        flush()
        i=index(line,":"); key=substr(line,1,i-1); val=substr(line,i+1); sub(/^[ \t]+/,"",val)
        if (key=="maps") { if (val!="" && val!="{}") e("maps: takes no inline value (or {})"); hasmaps=1 }
        else if (key=="when") {
          if (val=="" || val ~ /[][]/) e("root when must be a scalar command: " val)
          rootwhen=1
        } else e("unknown root key: " key)
      } else if (line ~ /^[ \t]*$/) next
      else e("unrecognized frontmatter line: " line)
    }
    END {
      if (bad) exit 1
      if (!closed) e("unterminated frontmatter (missing closing ---)")
      flush()
      if (!hasmaps) e("maps: section required (root when is only valid alongside maps)")
    }
  ' "$1"
}

# ---------------------------------------------------------------------------
# Predicates, output, backup, linking
# ---------------------------------------------------------------------------

is_macos() { [ "${DOTFILES_OS:-$(uname -s)}" = "Darwin" ]; }
is_linux() { [ "${DOTFILES_OS:-$(uname -s)}" = "Linux" ]; }

# has_when <cmd> — empty = unconditional pass; else command -v probe
has_when() { [ -z "$1" ] || command -v "$1" >/dev/null 2>&1; }

# Non-login shells miss ~/.local/bin (agy, kilo, mise live there) — fix PATH once.
path_setup() {
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH"; export PATH ;;
  esac
}

log() { # log <tool> <message>
  mkdir -p "${LOGS_DIR:-$DOTFILES_DIR/scripts/logs}"
  printf '%s %s\n' "$(date '+%F %T')" "$2" >> "${LOGS_DIR:-$DOTFILES_DIR/scripts/logs}/$1.log"
}

# _resque <abs path> — move existing file/symlink aside, mirroring its path
# under $BACKUP_DIR (created lazily, once per run).
_resque() {
  { [ -e "$1" ] || [ -L "$1" ]; } || return 0
  BACKUP_DIR="${BACKUP_DIR:-$DOTFILES_DIR/dotfiles.old/$(date +%Y-%m-%d_%H-%M-%S)}"
  local root="${LINK_ROOT:-$HOME}" rel="$1" target

  case "$rel" in
    "$root"/*) rel="${rel#"$root"}" ;;
  esac

  target="$BACKUP_DIR$rel"
  mkdir -p "$(dirname "$target")"
  mv -f "$1" "$target"
}

# _cfg_ignoring_user <a> <b> — equal modulo the machine-local [user] section
# (identity is per-machine state; only the rest counts as file drift)
_cfg_ignoring_user() {
  [ "$(awk '/^\[user\][ \t]*$/ {skip=1; next} skip && /^\[/ {skip=0} !skip' "$1")" = \
    "$(awk '/^\[user\][ \t]*$/ {skip=1; next} skip && /^\[/ {skip=0} !skip' "$2")" ]
}

# link_apply <dest> <abs_src> <os> <copy> <when> <root_when>
#   gates: os → root when → dest when → dry-run → noop → backup → apply
#   sets LINK_RESULT=linked|noop|gated|would|failed ; returns 1 only on failed
link_apply() {
  local dest="$1" src="$2" os="$3" copy="$4" when="$5" root_when="$6"
  local full="${LINK_ROOT:-$HOME}${dest#\~}" cur="" name="" email=""

  if [ -n "$os" ]; then
    os=${os#\[}
    os=${os%\]}
    os=${os// /}   # fm_entries keeps "[macos, linux]" raw

    if is_macos; then
      cur=macos
    else
      cur=linux
    fi

    case ",$os," in
      *",$cur,"*) ;;
      *)
        LINK_RESULT=gated
        printf '  gated   %s (os: %s, this: %s)\n' "$dest" "$os" "$cur"
        return 0
        ;;
    esac
  fi

  if ! has_when "$root_when"; then
    LINK_RESULT=gated
    printf '  gated   %s (when: %s)\n' "$dest" "$root_when"
    return 0
  fi

  if ! has_when "$when"; then
    LINK_RESULT=gated
    printf '  gated   %s (when: %s)\n' "$dest" "$when"
    return 0
  fi

  if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
    LINK_RESULT=would
    printf '  would   %s\n' "$dest"
    return 0
  fi

  if [ "${DOTFILES_FORCE:-0}" != 1 ]; then
    if [ -L "$full" ] && [ "$(readlink "$full")" = "$src" ]; then
      LINK_RESULT=noop
      printf '  in place %s\n' "$dest"
      return 0
    fi

    # copy dest: equal modulo [user] → true no-op (no backup churn per run)
    if [ "$copy" = "true" ] && [ -f "$full" ] && _cfg_ignoring_user "$src" "$full"; then
      LINK_RESULT=noop
      printf '  in place %s\n' "$dest"
      return 0
    fi
  fi

  # capture git identity from a file we are about to replace (copy: true)
  if [ "$copy" = "true" ] && [ -f "$full" ]; then
    name=$(git config --file "$full" user.name 2>/dev/null || true)
    email=$(git config --file "$full" user.email 2>/dev/null || true)
  fi

  _resque "$full"
  mkdir -p "$(dirname "$full")"

  if [ "$copy" = "true" ]; then
    cp -f "$src" "$full" || { LINK_RESULT=failed; printf '  FAILED  %s\n' "$dest"; return 1; }
    [ -n "$name" ] && git config --file "$full" user.name "$name"
    [ -n "$email" ] && git config --file "$full" user.email "$email"
    LINK_RESULT=linked
    printf '  copied  %s\n' "$dest"
    return 0
  fi

  ln -sf "$src" "$full" || { LINK_RESULT=failed; printf '  FAILED  %s\n' "$dest"; return 1; }
  LINK_RESULT=linked
  printf '  linked  %s\n' "$dest"
  return 0
}

# ---------------------------------------------------------------------------
# Package mechanism wrappers — the CALLER supplies per-platform package names
# ---------------------------------------------------------------------------

# brew_install <formula...> — macOS only; status line to console,
# raw brew output to $DOTFILES_SETUP_LOG (silent fallback: /dev/null)
brew_install() {
  if ! is_macos; then
    echo "brew_install: not macOS ($*), refusing" >&2
    return 1
  fi

  local f miss=()
  for f in "$@"; do
    brew list --versions "$f" >/dev/null 2>&1 || miss+=("$f")
  done

  if [ ${#miss[@]} -eq 0 ]; then
    msg_begin "$*"
    msg_end "done"
    return 0
  fi

  msg_begin "installing (brew):" "${miss[*]}"

  # -y: never block on brew's ask-mode confirmation (mirrors apt -y)
  if brew install -y "${miss[@]}" >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1; then
    msg_end "done"
  else
    msg_end "fail"
    return 1
  fi
}

# apt_install <pkg...> — Linux only; one `apt-get update` per run
apt_install() {
  if ! is_linux; then
    echo "apt_install: not Linux ($*), refusing" >&2
    return 1
  fi

  local p miss=()
  for p in "$@"; do
    dpkg -s "$p" >/dev/null 2>&1 || miss+=("$p")
  done

  if [ ${#miss[@]} -eq 0 ]; then
    msg_begin "$*"
    msg_end "done"
    return 0
  fi

  msg_begin "installing (apt):" "${miss[*]}"

  if [ "${APT_UPDATED:-0}" != 1 ]; then
    sudo apt-get update -qq >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || { msg_end "fail"; return 1; }
    APT_UPDATED=1
    export APT_UPDATED
  fi

  if sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${miss[@]}" >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1; then
    msg_end "done"
  else
    msg_end "fail"
    return 1
  fi
}

# ppa_install <ppa> <pkg...> — Linux only; prefer <ppa>, fall back to the OS repo.
# A PPA without a build for this release breaks apt itself (refresh rc=100), so a
# failed refresh drops the repo again before installing.
ppa_install() {
  if ! is_linux; then
    echo "ppa_install: not Linux ($*), refusing" >&2
    return 1
  fi

  local ppa="$1"
  shift

  # stock images ship no add-apt-repository (it lives in software-properties-common)
  command -v add-apt-repository >/dev/null 2>&1 || apt_install software-properties-common

  if sudo add-apt-repository -y "$ppa" >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 &&
    sudo apt-get update -qq >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1; then
    APT_UPDATED=1
    export APT_UPDATED
  else
    sudo add-apt-repository -r -y "$ppa" >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || true

    if sudo apt-get update -qq >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1; then
      APT_UPDATED=1
      export APT_UPDATED
    fi

    echo "  $ppa has no build for this release — using the OS repo" >>"${DOTFILES_SETUP_LOG:-/dev/null}"
  fi

  apt_install "$@"
}
