# My Personal Dotfiles

Personal dotfiles managed via `install.sh`. Cross-platform (macOS via Homebrew, Linux via apt).

## Structure

- `install.sh` — frontmatter-driven installer: runs `scripts/phases.sh` bootstrappers, then applies all `maps:` via `scripts/link.sh`. Flags: `--only <tool[,tool…]>`, `--skip <tool[,tool…]>`, `--link-only`, `--force`, `--dry-run`.
- `config/` — everything mappable: tool configs, plus the shell files (`zshrc`, `bashrc`, `profile`) and repo-sourced `aliases.sh` / `exports.sh` / `functions.sh`. Every dir has a `README.md` whose `maps:` frontmatter defines its mappings — schema: [`config/README.md`](config/README.md).
- `scripts/` — bootstrappers (`setup.d/<tool>.sh`, orchestrated via `phases.sh`), `lib.sh` (shared parser/linker), `link.sh`, `util.sh` (colors + one-line status helpers shared by shell rc, installer, and tests), plus hooks (e.g. `php.sh` is a mise postinstall hook).
- Output: one status line per tool — `installing (brew|apt): <tool>... done|warn|fail` (colored on a TTY, plain when piped); raw installer output goes to `scripts/logs/setup-{tool}.txt`, and a failed tool prints `See <log> for more info`.
- Repo-only, never mapped: `.editorconfig`, `.gitignore`, `.gitmodules`, `.env.sample`.
- `.env` — **contains real API keys. Do not commit or expose.** In gitignore. Uses `.env.sample` as template.

### Config Index

Mappings live in each config's `README.md` frontmatter; schema: [`config/README.md`](config/README.md).

| Config | Target |
|---|---|
| `config/zshrc`, `config/bashrc`, `config/profile` | `~/` |
| [`config/agents/`](config/agents/README.md) | `~/.agents/` + Zed `AGENTS.md`; skills → kilo, opencode, `~/.agents/skills` |
| [`config/gemini/`](config/gemini/README.md) | `~/.gemini/` (antigravity-cli + MCP) |
| [`config/ghostty/`](config/ghostty/README.md) | `~/Library/...` (macOS) / `~/.config/ghostty/config` (Linux) |
| [`config/git/`](config/git/README.md) | `~/.gitconfig` (`copy: true`) |
| [`config/kilocode/`](config/kilocode/README.md) | `~/.config/kilo/kilo.jsonc` |
| [`config/lazygit/`](config/lazygit/README.md) | `~/.config/lazygit/config.yml` |
| [`config/mise/`](config/mise/README.md) | `~/.config/mise/config.toml` |
| [`config/opencode/`](config/opencode/README.md) | `~/.config/opencode/opencode.jsonc` |
| [`config/php/`](config/php/README.md) | — (mise postinstall hook) |
| [`config/starship/`](config/starship/README.md) | `~/.config/starship.toml` |
| [`config/tmux/`](config/tmux/README.md) | `~/.config/tmux/tmux.conf` |
| [`config/vim/`](config/vim/README.md) | `~/.vimrc` |
| [`config/wakatime/`](config/wakatime/README.md) | `~/.wakatime.cfg` (local `private.cfg`) |
| [`config/zed/`](config/zed/README.md) | `~/.config/zed/` |
