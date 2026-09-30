---
maps:
  ~/.zshrc: zshrc
  ~/.bashrc: bashrc
  ~/.profile: profile
---

# Config

Everything mappable lives under this directory. **A file in `config/` is linked iff some README's frontmatter names it.** Anything not in frontmatter is repo-local.

## Schema

Each `config/**/README.md` opens with YAML frontmatter containing a `maps:` block. One README = one scope: `src` values are relative to that README's own directory.

Two value forms:

```yaml
---
maps:
  # string form — plain symlink (the common case)
  ~/.config/tmux/tmux.conf: tmux.conf

  # object form — block form only (multi-line, one key per line)
  ~/.gitconfig:
    src: gitconfig
    copy: true
  ~/.config/ghostty/config:
    src: config.ghostty
    os: [linux]
---
```

Qualifiers (object form requires `src`):

| Key | Meaning |
|---|---|
| `src` | Source path relative to the README's directory. String form is `src` shorthand. |
| `copy: true` | Copy the file instead of symlinking. |
| `os: [tokens]` | Allowed platforms: `macos`, `linux`, `windows`. Absent = universal. |

Semantics:

| Rule | Behavior |
|---|---|
| Dest keys | `~` expands to `$HOME`; parent dirs are created as needed |
| Source missing | Skip with warning, never an error (e.g. gitignored sources) |
| Source is a directory | Symlinked as a whole directory |
| Platform mismatch | Entry skipped with a note |
| Detection | `uname`: `Darwin`→macos, `Linux`→linux, `MINGW/MSYS/CYGWIN`→windows; WSL = linux |
| Re-run | Already-correct link/copy is a no-op; conflicting target → backup (script phase) |
| `maps: {}` or absent | No mappings (e.g. `php/`) |

Validation (fail fast): unknown `os` token, duplicate dest key in one README, object entry without `src`, unknown qualifier key, and inline flow-map object form (`dest: {src: x}`) are all errors.

Deliberately **not** in the schema: `.env` templating, package installation, repo-only files, and files sourced from this repo (`config/*.sh` below).

## Loose files

| File | Mapped? |
|---|---|
| `zshrc`, `bashrc`, `profile` | yes — see frontmatter above |
| `aliases.sh`, `exports.sh`, `functions.sh` | no — sourced from the repo by `.profile`'s `config/*.sh` glob, never linked |

## Index

| Dir | Target | Notes |
|---|---|---|
| [`agents/`](agents/README.md) | `~/.agents/`, `~/.config/zed/` | shared instructions; skills → kilo, opencode, `~/.agents/skills` |
| [`gemini/`](gemini/README.md) | `~/.gemini/` | antigravity-cli + MCP config; gemini-cli itself unused |
| [`ghostty/`](ghostty/README.md) | `~/Library/...` (macOS), `~/.config/ghostty/config` (Linux) | `os`-split |
| [`git/`](git/README.md) | `~/.gitconfig` | `copy: true` — per-machine name/email preserved |
| [`kilocode/`](kilocode/README.md) | `~/.config/kilo/kilo.jsonc` | |
| [`lazygit/`](lazygit/README.md) | `~/.config/lazygit/config.yml` | |
| [`mise/`](mise/README.md) | `~/.config/mise/config.toml` | |
| [`opencode/`](opencode/README.md) | `~/.config/opencode/opencode.jsonc` | |
| [`php/`](php/README.md) | — | mise postinstall hook; nothing linked into `~` |
| [`starship/`](starship/README.md) | `~/.config/starship.toml` | |
| [`tmux/`](tmux/README.md) | `~/.config/tmux/tmux.conf` | |
| [`vim/`](vim/README.md) | `~/.vimrc` | |
| [`wakatime/`](wakatime/README.md) | `~/.wakatime.cfg` | source `private.cfg` is gitignored — local only |
| [`zed/`](zed/README.md) | `~/.config/zed/` | keymap + settings |
