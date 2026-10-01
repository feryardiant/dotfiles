#!/usr/bin/env bash
# mise version manager — PHASE_MANAGERS. mac: Homebrew; linux: official installer (never brew).

set -euo pipefail

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"
path_setup

if command -v mise >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then
  msg_begin mise
  msg_end "done"
  exit 0
fi

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would install mise"; exit 0; }

if is_macos; then
  brew_install mise
else
  # official one-liner — installs to ~/.local/bin; installer output to log
  msg_begin mise
  { curl -fsSL https://mise.run | sh; } >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || { msg_end "fail"; exit 1; }
  msg_end "done"
fi
