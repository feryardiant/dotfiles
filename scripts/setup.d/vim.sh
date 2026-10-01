#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # scripts/ — children live one level deep in setup.d/
. "$SCRIPTS_DIR/lib.sh"; path_setup
if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then echo "would install vim + vim-plug"; exit 0; fi

if ! command -v vim >/dev/null 2>&1 || [ "${DOTFILES_FORCE:-0}" = 1 ]; then
  if is_macos; then brew_install vim; else apt_install vim; fi
fi

msg_begin vim
plug_dir="$HOME/.local/share/vim-plug"
if [ ! -f "$plug_dir/plug.vim" ]; then
  curl -LSso "$plug_dir/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    >>"${DOTFILES_SETUP_LOG:-/dev/null}" 2>&1 || { msg_end "fail"; exit 1; }
fi
mkdir -p "$HOME/.cache/vim/swap" "$HOME/.cache/vim/undo" "$HOME/.vim/autoload"
ln -sf "$plug_dir/plug.vim" "$HOME/.vim/autoload/plug.vim"
msg_end "done"
