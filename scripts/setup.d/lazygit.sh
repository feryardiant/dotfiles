#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"; path_setup
if command -v lazygit >/dev/null 2>&1 && [ "${DOTFILES_FORCE:-0}" != 1 ]; then msg_begin lazygit; msg_end "done"; exit 0; fi
[ "${DOTFILES_DRY_RUN:-0}" = 1 ] && { echo "would install lazygit"; exit 0; }
if is_macos; then
  brew_install lazygit
else
  ver=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    2>>"${DOTFILES_SETUP_LOG:-/dev/null}" | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
  [ -n "$ver" ] || { echo "lazygit: cannot detect version" >&2; exit 1; }
  case "$(uname -m)" in x86_64) arch=x86_64 ;; aarch64|arm64) arch=arm64 ;; *) echo "unsupported arch" >&2; exit 1 ;; esac
  # release tarball — download/extract output to log
  msg_begin lazygit
  { curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v$ver/lazygit_${ver}_Linux_${arch}.tar.gz" -o /tmp/lazygit.tgz \
    && tar -xzf /tmp/lazygit.tgz -C /tmp lazygit \
    && mkdir -p "$HOME/.local/bin" \
    && install -m 755 /tmp/lazygit "$HOME/.local/bin/lazygit" \
    && rm -f /tmp/lazygit /tmp/lazygit.tgz; } \
    >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || { msg_end "fail"; exit 1; }
  msg_end "done"
fi
