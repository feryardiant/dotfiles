#!/usr/bin/env bash
# oh-my-zsh itself (spec §2 gap: nothing installed it before).

set -euo pipefail

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"
path_setup

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

if [ -d "$ZSH_DIR/.git" ]; then
  msg_begin oh-my-zsh
  msg_end "done"
  exit 0
fi

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would clone oh-my-zsh -> $ZSH_DIR"; exit 0; }

msg_begin oh-my-zsh
command -v git >/dev/null 2>&1 || { echo "oh-my-zsh: git required" >&2; msg_end "fail"; exit 1; }

# official install.sh is interactive — clone directly (unattended); output to log
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR" \
  >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || { msg_end "fail"; exit 1; }
msg_end "done"
