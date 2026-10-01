#!/usr/bin/env bash
# Run: bash scripts/tests/setup_test.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIX=$(mktemp -d); trap 'rm -rf "$FIX"' EXIT
FAILS=0
ck() { if [ "$2" = "$3" ]; then printf 'ok - %s\n' "$1"; else FAILS=$((FAILS+1)); printf 'NOT OK - %s (want [%s], got [%s])\n' "$1" "$2" "$3"; fi; }

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
HOME="$FIX/h3" ZSH= PATH="$FIX/bin:$PATH" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/oh-my-zsh.sh" >/dev/null
ck "omz: cloned once" "1" "$(grep -c CLONED "$FIX/h3/omz.log")"
HOME="$FIX/h3" ZSH= PATH="$FIX/bin:$PATH" DOTFILES_DIR="$ROOT" bash "$ROOT/scripts/setup.d/oh-my-zsh.sh" | grep -q present && p=1 || p=0
ck "omz: idempotent" "1" "$p"
ck "omz: no second clone" "1" "$(grep -c CLONED "$FIX/h3/omz.log")"

printf '\nsetup_test: %d failures\n' "$FAILS"
[ "$FAILS" -eq 0 ]
