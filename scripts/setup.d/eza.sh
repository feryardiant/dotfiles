#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"; path_setup
if command -v eza >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then echo "  present eza"; exit 0; fi
[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would install eza"; exit 0; }
if is_macos; then
  brew_install eza
else
  # eza is not in stock apt — official .deb from GitHub releases
  case "$(uname -m)" in x86_64) deb=eza_amd64.deb ;; aarch64|arm64) deb=eza_aarch64.deb ;; *) echo "unsupported arch" >&2; exit 1 ;; esac
  curl -fsSL "https://github.com/eza-community/eza/releases/latest/download/$deb" -o /tmp/eza.deb
  sudo dpkg -i /tmp/eza.deb && rm -f /tmp/eza.deb
fi
echo "  eza installed"
