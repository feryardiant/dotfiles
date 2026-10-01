#!/usr/bin/env bash
# Run: bash scripts/tests/setup_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$ROOT/scripts/tests/harness.sh"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT

bash -n "$ROOT/scripts/setup.d/system.sh"     && t syntax 'parses `system.sh`' 0 0     || t syntax 'parses `system.sh`' 0 1
bash -n "$ROOT/scripts/setup.d/oh-my-zsh.sh"  && t syntax 'parses `oh-my-zsh.sh`' 0 0  || t syntax 'parses `oh-my-zsh.sh`' 0 1

# system: seed dirs + .env, idempotent merge, user keys preserved
# (fixture repo holds .env.example/.env so the real $DOTFILES_DIR/.env is never touched)
mkdir -p "$FIX/repo"
cp "$ROOT/.env.example" "$FIX/repo/.env.example"
HOME="$FIX/h" DOTFILES_OS=Darwin DOTFILES_DIR="$FIX/repo" bash "$ROOT/scripts/setup.d/system.sh" >/dev/null
t system 'creates the XDG state dir' "1" "$([ -d "$FIX/h/.local/state" ] && echo 1)"
t system 'seeds `.env` from `.env.example`' "1" "$(grep -c "export DOTFILES_DIR='$FIX/repo'" "$FIX/repo/.env")"
echo "MY_KEY=preserved" >> "$FIX/repo/.env"
before=$(md5 -q "$FIX/repo/.env" 2>/dev/null || md5sum "$FIX/repo/.env" | cut -d' ' -f1)
HOME="$FIX/h" DOTFILES_OS=Darwin DOTFILES_DIR="$FIX/repo" bash "$ROOT/scripts/setup.d/system.sh" >/dev/null
after=$(md5 -q "$FIX/repo/.env" 2>/dev/null || md5sum "$FIX/repo/.env" | cut -d' ' -f1)
t system 'reruns leave `.env` byte-identical' "$before" "$after"
t system 'keeps user keys across the merge' "1" "$(grep -c 'MY_KEY=preserved' "$FIX/repo/.env")"

# system dry-run: nothing created
mkdir -p "$FIX/repo2"
cp "$ROOT/.env.example" "$FIX/repo2/.env.example"
HOME="$FIX/h2" DOTFILES_DIR="$FIX/repo2" DOTFILES_DRY_RUN=1 bash "$ROOT/scripts/setup.d/system.sh" >/dev/null
t system 'dry-run creates no `.env`' "0" "$([ -f "$FIX/repo2/.env" ] && echo 1 || echo 0)"

# oh-my-zsh: stub git (no network); ZSH= so the host's exported ZSH can't short-circuit
mkdir -p "$FIX/bin"
cat > "$FIX/bin/git" <<'STUB'
#!/usr/bin/env bash
[ "$1" = clone ] && { mkdir -p "$4/.git"; echo CLONED >> "$HOME/omz.log"; }
STUB
chmod +x "$FIX/bin/git"
HOME="$FIX/h3" ZSH='' PATH="$FIX/bin:$PATH" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/oh-my-zsh.sh" >/dev/null
t omz 'clones on first run' "1" "$(grep -c CLONED "$FIX/h3/omz.log")"
HOME="$FIX/h3" ZSH='' PATH="$FIX/bin:$PATH" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/oh-my-zsh.sh" | grep -qF "oh-my-zsh... done" && p=1 || p=0
t omz 'second run reports `done`' "1" "$p"
t omz 'does not clone again' "1" "$(grep -c CLONED "$FIX/h3/omz.log")"

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
t mise 'installs via `brew` on macOS' "1" "$(grep -c 'BREW mise' "$FIX/h5/mise.log" 2>/dev/null || echo 0)"
rm -f "$FIX/h5/.local/bin/mise"; : > "$FIX/h5/mise.log"
HOME="$FIX/h5" PATH="$CLEAN" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/mise.sh" >/dev/null
t mise 'runs the official installer on Linux' "1" "$(grep -c RAN "$FIX/h5/mise.log" 2>/dev/null || echo 0)"
HOME="$FIX/h5" PATH="$CLEAN" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/mise.sh" | grep -qF "mise... done" && p=1 || p=0
t mise 'second run reports `done`' "1" "$p"

# --- tmux/vim/nvim/lazygit ---
bash -n "$ROOT/scripts/setup.d/tmux.sh"     && t syntax 'parses `tmux.sh`' 0 0    || t syntax 'parses `tmux.sh`' 0 1
bash -n "$ROOT/scripts/setup.d/vim.sh"      && t syntax 'parses `vim.sh`' 0 0     || t syntax 'parses `vim.sh`' 0 1
bash -n "$ROOT/scripts/setup.d/nvim.sh"     && t syntax 'parses `nvim.sh`' 0 0    || t syntax 'parses `nvim.sh`' 0 1
bash -n "$ROOT/scripts/setup.d/lazygit.sh"  && t syntax 'parses `lazygit.sh`' 0 0 || t syntax 'parses `lazygit.sh`' 0 1

# nvim: cache dirs only, NO config links (deferred)
# PATH=$FIX/bin:/usr/bin:/bin — hides the host's real nvim, keeps the brew stub (else brew_install dies before the cache mkdir)
mkdir -p "$FIX/h8"
HOME="$FIX/h8" PATH="$FIX/bin:/usr/bin:/bin" DOTFILES_OS=Darwin DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/nvim.sh" >/dev/null 2>&1 || true
t nvim 'creates no config links (deferred)' "0" "$(find "$FIX/h8" -name 'init.vim' 2>/dev/null | wc -l | tr -d ' ')"
t nvim 'creates the cache dirs' "1" "$([ -d "$FIX/h8/.cache/nvim/swap" ] && echo 1)"

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
t vim 'fetches `plug.vim` exactly once' "$c1" "$c2"
t vim 'links `autoload/plug.vim`' "1" "$([ -L "$FIX/h6/.vim/autoload/plug.vim" ] && echo 1)"

# lazygit linux: apt package — fixture-only PATH (stubs + utils) hides any real install
mkdir -p "$FIX/h7" "$FIX/base"
cat > "$FIX/base/apt-get" <<'STUB'
#!/usr/bin/env bash
[ "$1" = install ] && echo APT_LAZYGIT "$*" >> "$HOME/l.log"
exit 0
STUB
cat > "$FIX/base/dpkg" <<'STUB'
#!/usr/bin/env bash
exit 1   # -s probe: not installed
STUB
cat > "$FIX/base/sudo" <<'STUB'
#!/usr/bin/env bash
exec "$@"
STUB
chmod +x "$FIX/base/"*
for u in bash sh env dirname uname mkdir rm cp ln chmod tar sed grep cat install touch; do
  ln -sf "$(command -v "$u")" "$FIX/base/$u"
done
HOME="$FIX/h7" PATH="$FIX/base" DOTFILES_OS=Linux DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/lazygit.sh" >/dev/null 2>&1 || true
t lazygit 'installs via `apt-get` on Linux' "1" "$(grep -c APT_LAZYGIT "$FIX/h7/l.log" 2>/dev/null || echo 0)"

finish setup_test
