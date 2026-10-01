# dotfiles

Personal dotfiles managed via `install.sh`. Cross-platform (macOS via Homebrew, Linux via apt).

## Structure

- `install.sh` — frontmatter-driven installer: runs `scripts/phases.sh` bootstrappers, then applies all `maps:` via `scripts/link.sh`. Flags: `--only <tool>`, `--skip <tool>`, `--link-only`, `--force`, `--dry-run`.
- `config/` — everything mappable: tool configs, plus the shell files (`zshrc`, `bashrc`, `profile`) and repo-sourced `aliases.sh` / `exports.sh` / `functions.sh`. Every dir has a `README.md` whose `maps:` frontmatter defines its mappings — schema: [`config/README.md`](config/README.md).
- `scripts/` — bootstrappers (`setup.d/<tool>.sh`, orchestrated via `phases.sh`), `lib.sh` (shared parser/linker), `link.sh`, `util.sh` (colors + one-line status helpers shared by shell rc, installer, and tests), plus hooks (e.g. `php.sh` is a mise postinstall hook).
- Output: one status line per tool — `installing (brew|apt): <tool>... done|warn|fail` (colored on a TTY, plain when piped); raw installer output goes to `scripts/logs/setup-{tool}.txt`, and a failed tool prints `See <log> for more info`.
- Shell style: `if`/`case`/loop bodies always on their own lines (one statement per line — never `if …; then cmd; fi`), a blank line between top-level blocks, 2-space indent. Reference shape: `scripts/setup.d/fzf.sh`.
- Repo-only, never mapped: `.editorconfig`, `.gitignore`, `.gitmodules`, `.env.sample`.
- `.env` — **contains real API keys. Do not commit or expose.** In gitignore. Uses `.env.sample` as template.

### Config Index

Mappings live in each config's `README.md` frontmatter; schema: [`config/README.md`](config/README.md).

- `config/{zshrc,bashrc,profile}` → `~/`
- `config/agents/` → `~/.agents/global-instructions.md`, `~/.config/zed/AGENTS.md`; `skills/` → `~/.config/{kilo,opencode}/skills`, `~/.agents/skills`
- `config/gemini/` → `~/.gemini/` (antigravity-cli + MCP; gemini-cli unused, `settings.json`/`policies/` unmapped)
- `config/ghostty/` → `~/Library/...` (macOS) / `~/.config/ghostty/config` (Linux)
- `config/git/` → `~/.gitconfig` (`copy: true`, per-machine name/email preserved)
- `config/kilocode/` → `~/.config/kilo/kilo.jsonc`
- `config/lazygit/` → `~/.config/lazygit/config.yml`
- `config/mise/` → `~/.config/mise/config.toml`
- `config/opencode/` → `~/.config/opencode/opencode.jsonc`
- `config/php/` → none (mise postinstall hook via `scripts/php.sh`)
- `config/starship/` → `~/.config/starship.toml`
- `config/tmux/` → `~/.config/tmux/tmux.conf`
- `config/vim/` → `~/.vimrc`
- `config/wakatime/` → `~/.wakatime.cfg` (source `private.cfg` gitignored, local-only)
- `config/zed/` → `~/.config/zed/`

## Shell Config Flow

1. `.zshrc` — loads oh-my-zsh and plugins (fzf, eza, mise, starship, zoxide, …)
2. `.profile` (login shells; `.bashrc` sources `~/.profile`) — sets XDG vars, sources `scripts/util.sh`, then `config/*.sh` (`aliases`, `exports`, `functions`), then `$DOTFILES_DIR/.env`

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
- `agents`, `skills`, and `instructions` are managed in `./config/agents` (mappings in its README frontmatter). `skills/` contents are ignored from git (local-only).
- gemini-cli is no longer used; antigravity-cli reads the shared `~/.agents/` directory.
- Tool permissions are configured per-agent (`plan` vs `build`/`code`): read-only in plan mode, full access with command confirmations in build/write mode.

## Platform Notes

- macOS: Homebrew at `/opt/homebrew`. `.exports` handles brew shellenv and completions.
- Linux/WSL: `scripts/*.sh` install via apt. `.profile` handles WSL-specific path setup.
