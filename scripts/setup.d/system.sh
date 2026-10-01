#!/usr/bin/env bash
# Machine base: XDG dirs + $DOTFILES_DIR/.env seed/merge (the .env that config/profile sources).

set -euo pipefail

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"
: "${DOTFILES_DIR:?DOTFILES_DIR must be set}"
path_setup

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would run: system setup (dirs + $DOTFILES_DIR/.env)"; exit 0; }

msg_begin system
mkdir -p "$HOME/.cache" "$HOME/.config" "$HOME/.local/"{bin,share,state}

# $DOTFILES_DIR/.env: seed from sample; merge never duplicates and never drops user keys.
env_file="$DOTFILES_DIR/.env"

if [ ! -f "$env_file" ]; then
  sed "s@export DOTFILES_DIR=''@export DOTFILES_DIR='$DOTFILES_DIR'@g" \
    "$DOTFILES_DIR/.env.example" > "$env_file"
  echo "  created $env_file from .env.example" >>"${DOTFILES_SETUP_LOG:-/dev/null}"
else
  # append any sample line not already present
  while IFS= read -r line; do
    [ -n "$line" ] || continue

    case "$line" in
      "export DOTFILES_DIR="*) continue ;;
    esac

    key="${line%%=*}"
    grep -qF "$key" "$env_file" || printf '%s\n' "$line" >> "$env_file"
  done < "$DOTFILES_DIR/.env.example"

  # refresh the DOTFILES_DIR export
  if grep -q "^export DOTFILES_DIR=" "$env_file"; then
    sed -i.bak "s@^export DOTFILES_DIR=.*@export DOTFILES_DIR='$DOTFILES_DIR'@g" "$env_file"
    rm -f "$env_file.bak"
  else
    printf "export DOTFILES_DIR='%s'\n" "$DOTFILES_DIR" >> "$env_file"
  fi

  echo "  $env_file merged (existing keys preserved)" >>"${DOTFILES_SETUP_LOG:-/dev/null}"
fi

msg_end "done"

# Base packages (Ubuntu only — macOS ships curl/git/zsh); git from the git-core PPA
if is_linux; then
  ppa_install ppa:git-core/ppa curl git zsh build-essential
fi
