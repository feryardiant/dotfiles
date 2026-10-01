#!/usr/bin/env bash
# mise version manager — PHASE_MANAGERS. mac: Homebrew; linux: official installer (never brew).
set -euo pipefail
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"
path_setup

if command -v mise >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then
  echo "  present mise"; exit 0
fi
if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then echo "would install mise"; exit 0; fi
if is_macos; then
  brew_install mise
else
  # official one-liner — installs to ~/.local/bin
  curl -fsSL https://mise.run | sh
fi
echo "  mise installed"
