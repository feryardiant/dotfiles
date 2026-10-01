#!/usr/bin/env bash

set -euo pipefail

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"; path_setup

if command -v zoxide >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then
  msg_begin zoxide
  msg_end "done"
  exit 0
fi

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would install zoxide"; exit 0; }

if is_macos; then
  brew_install zoxide
else
  apt_install zoxide
fi
