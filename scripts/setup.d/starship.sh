#!/usr/bin/env bash

set -euo pipefail

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"; path_setup

if command -v starship >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then
  msg_begin starship
  msg_end "done"
  exit 0
fi

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would install starship"; exit 0; }

if is_macos; then
  brew_install starship
else
  # official installer (never brew on Linux) — installer output to log
  msg_begin starship
  { curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"; } \
    >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || { msg_end "fail"; exit 1; }
  msg_end "done"
fi
