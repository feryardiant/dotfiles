#!/usr/bin/env bash

set -euo pipefail

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"; path_setup

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would install tmux + tpm"; exit 0; }

if command -v tmux >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then
  msg_begin tmux
  msg_end "done"
else
  if is_macos; then
    brew_install tmux
  else
    apt_install tmux
  fi
fi

# TPM — cloned where tmux.conf runs it (run '~/.config/tmux/plugins/tpm/tpm')
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ -d "$TPM_DIR/.git" ]; then
  msg_begin tpm
  msg_end "done"
else
  msg_begin tpm
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR" \
    >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || { msg_end "fail"; exit 1; }
  msg_end "done"
fi
