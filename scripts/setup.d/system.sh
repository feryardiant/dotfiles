#!/usr/bin/env bash
# Machine base: XDG dirs + ~/.env seed/merge (spec §8).
set -euo pipefail
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"
: "${DOTFILES_DIR:?DOTFILES_DIR must be set}"
path_setup

if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then echo "would run: system setup (dirs + ~/.env)"; exit 0; fi

mkdir -p "$HOME/.cache" "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.local/state"

# ~/.env: seed from sample; merge never duplicates and never drops user keys.
if [ ! -f "$HOME/.env" ]; then
  sed "s@export DOTFILES_DIR=''@export DOTFILES_DIR='$DOTFILES_DIR'@g" \
    "$DOTFILES_DIR/.env.sample" > "$HOME/.env"
  echo "  created ~/.env from .env.sample"
else
  # append any sample line not already present
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    case "$line" in "export DOTFILES_DIR="*) continue ;; esac
    key="${line%%=*}"
    grep -qF "$key" "$HOME/.env" || printf '%s\n' "$line" >> "$HOME/.env"
  done < "$DOTFILES_DIR/.env.sample"
  # refresh the DOTFILES_DIR export
  if grep -q "^export DOTFILES_DIR=" "$HOME/.env"; then
    sed -i.bak "s@^export DOTFILES_DIR=.*@export DOTFILES_DIR='$DOTFILES_DIR'@g" "$HOME/.env"
    rm -f "$HOME/.env.bak"
  else
    printf "export DOTFILES_DIR='%s'\n" "$DOTFILES_DIR" >> "$HOME/.env"
  fi
  echo "  ~/.env merged (existing keys preserved)"
fi

# Base packages (Ubuntu only — macOS ships curl/git/zsh)
if is_linux; then
  apt_install curl git zsh build-essential
fi
echo "  system setup done"
