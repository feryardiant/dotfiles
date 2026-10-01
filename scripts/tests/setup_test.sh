#!/usr/bin/env bash
# Run: bash scripts/tests/setup_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT
FAILS=0
ck() {
  if [ "$2" = "$3" ]; then
    printf 'ok - %s\n' "$1"
  else
    FAILS=$((FAILS+1))
    printf 'NOT OK - %s (want [%s], got [%s])\n' "$1" "$2" "$3"
  fi
}

bash -n "$ROOT/scripts/setup.d/system.sh"    && ck "bash -n system" 0 0 || ck "bash -n system" 0 1
bash -n "$ROOT/scripts/setup.d/oh-my-zsh.sh" && ck "bash -n omz" 0 0 || ck "bash -n omz" 0 1

# system: seed dirs + .env, idempotent merge, user keys preserved
HOME="$FIX/h" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/system.sh" >/dev/null
ck "system: XDG dir" "1" "$([ -d "$FIX/h/.local/state" ] && echo 1)"
ck "system: env seeded" "1" "$(grep -c "export DOTFILES_DIR='$ROOT'" "$FIX/h/.env")"
echo "MY_KEY=preserved" >> "$FIX/h/.env"
before=$(md5 -q "$FIX/h/.env" 2>/dev/null || md5sum "$FIX/h/.env" | cut -d' ' -f1)
HOME="$FIX/h" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/system.sh" >/dev/null
after=$(md5 -q "$FIX/h/.env" 2>/dev/null || md5sum "$FIX/h/.env" | cut -d' ' -f1)
ck "system: env merge idempotent" "$before" "$after"
ck "system: user key survives" "1" "$(grep -c 'MY_KEY=preserved' "$FIX/h/.env")"

# system dry-run: nothing created
HOME="$FIX/h2" DOTFILES_DIR="$ROOT" DOTFILES_DRY_RUN=1 bash "$ROOT/scripts/setup.d/system.sh" >/dev/null
ck "system dry-run: no env" "0" "$([ -f "$FIX/h2/.env" ] && echo 1 || echo 0)"

# oh-my-zsh: stub git (no network); ZSH= so the host's exported ZSH can't short-circuit
mkdir -p "$FIX/bin"
cat > "$FIX/bin/git" <<'STUB'
#!/usr/bin/env bash
[ "$1" = clone ] && { mkdir -p "$4/.git"; echo CLONED >> "$HOME/omz.log"; }
STUB
chmod +x "$FIX/bin/git"
HOME="$FIX/h3" ZSH='' PATH="$FIX/bin:$PATH" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/oh-my-zsh.sh" >/dev/null
ck "omz: cloned once" "1" "$(grep -c CLONED "$FIX/h3/omz.log")"
HOME="$FIX/h3" ZSH='' PATH="$FIX/bin:$PATH" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/oh-my-zsh.sh" | grep -qF "oh-my-zsh... done" && p=1 || p=0
ck "omz: idempotent" "1" "$p"
ck "omz: no second clone" "1" "$(grep -c CLONED "$FIX/h3/omz.log")"

# mise — stub brew (mac) and curl|sh (linux); CLEAN PATH hides the host's real mise
CLEAN="$FIX/bin:/usr/bin:/bin"
cat > "$FIX/bin/brew" <<'STUB'
#!/usr/bin/env bash
[ "$1" = list ] && exit 1
[ "$1" = install ] && { shift; [ "$1" = -y ] && shift; echo "BREW $*" >> "$HOME/mise.log"; mkdir -p "$HOME/.local/bin"; printf '#!/bin/sh\n' > "$HOME/.local/bin/mise"; chmod +x "$HOME/.local/bin/mise"; }
STUB
cat > "$FIX/bin/curl" <<'STUB'
#!/usr/bin/env bash
echo 'mkdir -p "$HOME/.local/bin"; printf "#!/bin/sh\n" > "$HOME/.local/bin/mise"; chmod +x "$HOME/.local/bin/mise"; echo RAN >> "$HOME/mise.log"'
STUB
chmod +x "$FIX/bin/brew" "$FIX/bin/curl"
mkdir -p "$FIX/h5"
HOME="$FIX/h5" PATH="$CLEAN" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/mise.sh" >/dev/null
ck "mise mac: via brew" "1" "$(grep -c 'BREW mise' "$FIX/h5/mise.log" 2>/dev/null || echo 0)"
rm -f "$FIX/h5/.local/bin/mise"; : > "$FIX/h5/mise.log"
HOME="$FIX/h5" PATH="$CLEAN" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/mise.sh" >/dev/null
ck "mise linux: official installer" "1" "$(grep -c RAN "$FIX/h5/mise.log" 2>/dev/null || echo 0)"
HOME="$FIX/h5" PATH="$CLEAN" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/mise.sh" | grep -qF "mise... done" && p=1 || p=0
ck "mise: idempotent" "1" "$p"

# --- tmux/vim/nvim/lazygit ---
bash -n "$ROOT/scripts/setup.d/tmux.sh"     && ck "bash -n tmux" 0 0 || ck "bash -n tmux" 0 1
bash -n "$ROOT/scripts/setup.d/vim.sh"      && ck "bash -n vim" 0 0 || ck "bash -n vim" 0 1
bash -n "$ROOT/scripts/setup.d/nvim.sh"     && ck "bash -n nvim" 0 0 || ck "bash -n nvim" 0 1
bash -n "$ROOT/scripts/setup.d/lazygit.sh"  && ck "bash -n lazygit" 0 0 || ck "bash -n lazygit" 0 1

# nvim: cache dirs only, NO config links (deferred)
# PATH=$FIX/bin:/usr/bin:/bin — hides the host's real nvim, keeps the brew stub (else brew_install dies before the cache mkdir)
mkdir -p "$FIX/h8"
HOME="$FIX/h8" PATH="$FIX/bin:/usr/bin:/bin" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/nvim.sh" >/dev/null 2>&1 || true
ck "nvim: no config links created" "0" "$(find "$FIX/h8" -name 'init.vim' 2>/dev/null | wc -l | tr -d ' ')"
ck "nvim: cache dirs made" "1" "$([ -d "$FIX/h8/.cache/nvim/swap" ] && echo 1)"

# vim-plug: fetched once (stub curl), autoload linked — h6 must exist so v.log actually records (else both counts are 0 = vacuous pass)
mkdir -p "$FIX/bin2" "$FIX/h6"
cat > "$FIX/bin2/curl" <<'STUB'
#!/usr/bin/env bash
echo CURL >> "$HOME/v.log"
p=""
while [ $# -gt 0 ]; do
  case $1 in
    -o|--output) p="$2"; shift 2 ;;
    -LSso)       p="$2"; shift 2 ;;
    --create-dirs) shift ;;
    *)           shift ;;
  esac
done
[ -n "$p" ] && { mkdir -p "$(dirname "$p")"; echo plug > "$p"; }
STUB
chmod +x "$FIX/bin2/curl"
HOME="$FIX/h6" PATH="$FIX/bin2:$PATH" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/vim.sh" >/dev/null 2>&1 || true
c1=$(grep -c CURL "$FIX/h6/v.log" 2>/dev/null || echo 0)
HOME="$FIX/h6" PATH="$FIX/bin2:$PATH" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/vim.sh" >/dev/null 2>&1 || true
c2=$(grep -c CURL "$FIX/h6/v.log" 2>/dev/null || echo 0)
ck "vim-plug: fetched once" "$c1" "$c2"
ck "vim-plug: autoload linked" "1" "$([ -L "$FIX/h6/.vim/autoload/plug.vim" ] && echo 1)"

# lazygit linux: stub curl (version JSON + tarball via -o position) + tar (extracts to -C dir)
mkdir -p "$FIX/h7"
cat > "$FIX/bin2/curl" <<'STUB'
#!/usr/bin/env bash
echo CURL_LAZYGIT >> "$HOME/l.log"
prev=""
for a in "$@"; do
  case $prev in
    -o) echo FAKE > "$a" ;;
  esac
  prev="$a"
done
echo '{"tag_name": "v0.44.0"}'
STUB
cat > "$FIX/bin2/tar" <<'STUB'
#!/usr/bin/env bash
dir=""
out=""
while [ $# -gt 0 ]; do
  case $1 in
    -C)    dir="$2"; shift 2 ;;
    -*)    shift ;;
    *)     out="$1"; shift ;;
  esac
done
if [ -n "$out" ]; then
  dir="${dir:-/tmp}"
  mkdir -p "$dir"
  echo lg > "$dir/$out"; chmod +x "$dir/$out"
fi
STUB
chmod +x "$FIX/bin2/curl" "$FIX/bin2/tar"
# clean base PATH — the host's real lazygit would trip the present-check
HOME="$FIX/h7" PATH="$FIX/bin2:/usr/bin:/bin" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/lazygit.sh" >/dev/null 2>&1 || true
ck "lazygit linux: binary installed" "1" "$([ -x "$FIX/h7/.local/bin/lazygit" ] && echo 1)"

printf '\nsetup_test: %d failures\n' "$FAILS"
[ "$FAILS" -eq 0 ]
