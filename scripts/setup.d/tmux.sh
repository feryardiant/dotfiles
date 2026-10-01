#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"; path_setup
if command -v tmux >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then echo "  present tmux"; exit 0; fi
[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would install tmux"; exit 0; }
if is_macos; then brew_install tmux; else apt_install tmux; fi
echo "  tmux installed"
