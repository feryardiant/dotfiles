# dotfiles

Personal dotfiles managed via `install.sh`. Cross-platform (macOS via Homebrew, Linux via apt).

## Structure

- `install.sh` — main installer. Flags: `--with-zsh`, `--with-neovim`. Symlinks shell dotfiles, copies `.gitconfig`, backs up existing files to `dotfiles.old/<timestamp>`. Sources `scripts/util.sh`.
- Root-level: `.aliases`, `.exports`, `.functions`, `.profile`, `.zshrc`, `.bashrc`, `.gitconfig`, `.gitignore`, `.editorconfig`
- `config/` — tool configs (vim, zed, ghostty, tmux, lazygit, starship, opencode, kilocode, gemini)
- `scripts/` — apt-based tool installers (git, tmux, zsh, nginx, php, etc.)
- `.env` — **contains real API keys. Do not commit or expose. In gitignore.** Uses `.env.sample` as template.

### Paths Mapping

For `.aliases`, `.bashrc`, `.exports`, `.functions`, `.profile` and `.zshrc` symlinked to `~/` directly

- `./config/ai/` — shared AI directory across multiple agents.
  - `agents/` — symlinked to `~/.config/kilo/agents/`, `~/.config/opencode/agents/`
  - `instructions/global.md` — shared global instructions. Referenced via:
    - OpenCode: `"instructions"` in `config.json`
    - KiloCode: `"instructions"` in `config.json`
    - Gemini: `"context.fileName"` in `settings.json`
    - Zed: symlinked to `~/.config/zed/AGENTS.md`
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
- `./config/wakatime/` — WakaTime config directory.
  - `config.cfg` — symlinked to `~/.wakatime.cfg`
- `./config/zed/` — Zed config directory.
  - `keymap.json` — symlinked to `~/.config/zed/keymap.json`
  - `settings.json` — symlinked to `~/.config/zed/settings.json`

## Shell Config Flow

1. `.zshrc` sources `~/.env`, sets XDG vars, loads oh-my-zsh, then sources `~/.profile`
2. `.profile` loads `scripts/util.sh` via `$DOTFILES_DIR`, then sources `~/.{exports,aliases,functions}`

## Key Tools

- Prompt: oh-my-zsh + starship prompt
- Plugins: fzf, per-directory-history, starship, zsh-autosuggestions, zsh-interactive-cd
- Navigation: zoxide (`z` command)
- Version mgmt: asdf
- Git pager: delta. External diff: difft. Editor: nvim
- `ls` → `eza --color --icons --group-directories-first`
- `bat` with OneHalfDark theme

## Git Config Highlights

URL shorthands: `gh:` → `git@github.com:`, `gl:` → `git@gitlab.com:`, `gst:` → `git@gist.github.com:`

Aliases: `s` (status -s), `a` (add -A), `c` (commit -sm), `p` (push origin), `co` (checkout), `go` (checkout -b), `lg` (pretty graph log), `reb` (rebase -i HEAD~n), `amend`, `undo` (reset HEAD~), `release` (signed tag).

## AI Tool Configs

- All AI Tools should share similar `permissions`, `policies`, `agents`, `skills`, `instructions`, `extensions` or `plugins` (if supported)
- `agents`, `skills`, and `instructions` managed within `./config/ai` directory. `agents` and `skills` contents should be ignored from git.
- Tool permissions are configured per-agent (`plan` vs `build`/`code`): read-only in plan mode, full access with command confirmations in build/write mode.

## Platform Notes

- macOS: Homebrew at `/opt/homebrew`. `.exports` handles brew shellenv and completions.
- Linux/WSL: `scripts/*.sh` install via apt. `.profile` handles WSL-specific path setup.
