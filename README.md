# My Personal Dotfiles

Personal dotfiles managed via `install.sh`. Cross-platform (macOS via Homebrew, Linux via apt).

## Structure

- `install.sh` — main installer. Flags: `--with-zsh`, `--with-neovim`. Symlinks shell dotfiles, copies `.gitconfig`, backs up existing files to `dotfiles.old/<timestamp>`. Sources `scripts/util.sh`.
- Root-level: `.aliases`, `.exports`, `.functions`, `.profile`, `.zshrc`, `.bashrc`, `.gitconfig`, `.gitignore`, `.editorconfig`
- `config/` — tool configs (vim, zed, ghostty, tmux, lazygit, starship, opencode, kilocode, gemini)
- `scripts/` — apt-based tool installers (git, tmux, zsh, nginx, php, etc.)
- `.env` — **contains real API keys. Do not commit or expose. In gitignore.** Uses `.env.sample` as template.

### Paths Mapping

For `.aliases`, `.bashrc`, `.exports`, `.functions`, `.profile` and `.zshrc` symlinked to `~/` directly

- `./config/ai/` — shared AI directory across multiple agents, currently only `gemini`, `kilocode` and `opencode`.
  - `agents/` — symlinked to `~/.config/kilo/agents/`, `~/.config/opencode/agents/`
  - `skills/` — symlinked to `~/.config/kilo/skills/`, `~/.config/opencode/skills/`, `~/.gemini/skills/`
- `./config/gemini/` — Google Gemini CLI config directory.
  - `policies/` — symlinked to `~/.gemini/policies/`
  - `settings.json` — symlinked to `~/.gemini/settings.json`
- `./config/ghostty/` — Ghostty config directory.
  - `config/` — symlinked to `~/.config/ghostty/config/`
- `./config/kilocode/` — KiloCode CLI config directory.
  - `config.json` — symlinked to `~/.config/kilo/kilo.json`
- `./config/tmux/` — TMUX config directory.
  - `tmux.conf` — symlinked to `~/.config/tmux/tmux.conf`
- `./config/vim/` — VIM config directory.
  - `vimrc` — symlinked to `~/.config/vim/vimrc`
- `./config/zed/` — Zed config directory.
  - `keymap.json` — symlinked to `~/.config/zed/keymap.json`
  - `settings.json` — symlinked to `~/.config/zed/settings.json`
