# Dotfiles Config Structure & Path-Mapping Schema — Design

**Date:** 2026-10-01
**Status:** Approved in discussion; pending spec review

## Problem

The "Paths Mapping" sections in root `README.md` and `AGENTS.md` are hand-maintained and obsolete: `config/ai/` became `config/agents/`, root shell files moved toward `config/`, `home/` appeared, and several tool dirs (`mise`, `lazygit`, `starship`, `php`) were never documented. Meanwhile per-config `README.md` frontmatter (`maps:`) has emerged as the de facto executable mapping doc, and `install.sh` is disabled (`exit 0`) while still referencing files that no longer exist. Documentation and reality drift because there are two sources of truth.

## Goals

- **One source of truth** for every symlink/copy in the repo: `maps:` YAML frontmatter in config READMEs. The future init script reads it; humans browse it.
- **Docs cannot drift on mapping details** — the script and the docs consume the same frontmatter.
- **Uniform structure**: every mappable file lives under `config/`; repo-only files stay at root and are never mapped.

## Non-goals (out of scope)

- **The init script itself** — a future task. This spec defines the contract it must consume.
- **`install.sh` rewrite** — already disabled; untouched here.
- **`.env` templating** (sed `DOTFILES_DIR` substitution + merge with existing `~/.env`) and **package installation** (`--with-zsh` etc.) — hardcoded steps in the future script, never frontmatter.
- **Deleting unused files** — `config/gemini/{settings.json,policies/}` stay on disk, simply unmapped.

## Decisions (with rationale)

1. **Frontmatter is the single source of truth for ALL links**, including former root dotfiles — the script learns exactly one mechanism. (Supersedes an interim "config/ only" answer, reversed when the user chose to move root symlinks under `config/`.)
2. **Schema has two value forms**: plain string = symlink (the common case, stays a one-liner); mapping object = qualified entry (`src`, `copy`, `os`).
3. **Root `README.md`/`AGENTS.md` become thin indexes** — Paths Mapping removed; a one-line-per-dir summary table is kept despite possible drift (user accepted that granularity of drift).
4. **Per-config README = frontmatter + H1 + short notes** — not full tool documentation.
5. **The schema is documented in `config/README.md`** — the convention lives beside the thing it describes.
6. **Shell files go directly into `config/`** (no `config/shell/` subdir), absorbing `home/`; **`.gitconfig` goes to `config/git/`** with `copy: true`.
7. **`.env.sample` stays at root**; its template nature stays a hardcoded script step (a symlink/copy schema cannot express sed+merge).
8. **`aliases.sh`/`exports.sh`/`functions.sh` are repo-sourced only, no maps** — `.profile` already sources them from `$DOTFILES_DIR`, not from `~`.
9. **Source filenames drop the leading dot** (`config/zshrc`, `config/profile`, `config/git/gitconfig`) — destinations are explicit in maps, and files stop being hidden.
10. **`os` uses a YAML flow-list** (`os: [macos, linux]`); no `os` key = universal. Verified to need no external tools (bracket-strip + comma-split in awk/bash).

## Target structure

```
dotfiles/
├── README.md              # thin index (humans) — Paths Mapping removed
├── AGENTS.md              # thin index (agents) — same treatment
├── LICENSE
├── .gitignore             # repo-only, never mapped
├── .gitmodules            # repo-only, never mapped
├── .editorconfig          # repo-only, never mapped
├── .env.sample            # template — hardcoded init step, never in maps
├── install.sh             # disabled; future script replaces it
├── scripts/               # installers + util (unchanged here)
├── docs/superpowers/specs/
└── config/
    ├── README.md          # schema doc + index + maps for the loose files below
    ├── zshrc              # → ~/.zshrc
    ├── bashrc             # → ~/.bashrc
    ├── profile            # → ~/.profile
    ├── aliases.sh         # repo-sourced only (no map)
    ├── exports.sh         # repo-sourced only (no map)
    ├── functions.sh       # repo-sourced only (no map)
    ├── git/               # README + gitconfig → ~/.gitconfig (copy: true)
    ├── agents/  gemini/  ghostty/  kilocode/  lazygit/  mise/
    ├── opencode/  php/  starship/  tmux/  vim/  wakatime/  zed/
    └── (every dir: README.md with maps frontmatter + short notes)
```

`home/` is deleted (absorbed). Rule of thumb stated in `config/README.md`: *a file in `config/` is linked iff some README's frontmatter names it.*

## Schema spec

**Location:** YAML frontmatter of `config/README.md` and every `config/*/README.md`. One README = one scope: `src` values are relative to that README's own directory.

**Value forms:**

```yaml
---
maps:
  # string form — plain symlink
  ~/.config/tmux/tmux.conf: tmux.conf

  # object form — block form is canonical (multi-line, one key per line)
  ~/.gitconfig:
    src: gitconfig
    copy: true
  ~/.config/ghostty/config:
    src: config.ghostty
    os: [linux]
---
```

**Qualifiers:**

| Key | Meaning |
|---|---|
| `src` | Required in object form. Source path relative to the README's directory. String form is `src` shorthand. |
| `copy: true` | Copy the file instead of symlinking (only `.gitconfig` today). |
| `os: [tokens]` | Allowed platforms: `macos`, `linux`, `windows` (flow-list, comma-separated). Absent = universal. |

**Semantics (the contract the init script obeys):**

| Rule | Behavior |
|---|---|
| Dest keys | `~` expands to `$HOME`; parent dirs created as needed |
| Source missing | Skip with warning, never an error (gitignored sources such as `wakatime/private.cfg`) |
| Source is a directory | Symlinked as a whole directory (`ln -s` semantics) |
| Platform mismatch | Entry skipped with a note |
| Platform detection | `uname`: `Darwin`→macos, `Linux`→linux, `MINGW/MSYS/CYGWIN`→windows; WSL reports Linux → linux |
| Idempotent re-run | Already-correct link/copy → no-op; conflicting existing target → backup-and-replace (script phase) |
| `maps: {}` or absent | Dir has no mappings (e.g. `php/`) |
| Same src, two dests | Two entries (the `agents` pattern) |

**Validation (fail fast at parse time):**

- Unknown `os` token (e.g. `macOS`, `linus`) → error
- Duplicate dest key within one README → error
- Object entry without `src` → error
- Unknown qualifier key → error
- Inline flow-map object form (`dest: {src: x}`) → error; block form is canonical, keeps line-based parsing trivial

**Deliberately not in the schema:** `.env` templating, package installation, repo-only files, files sourced from the repo (`config/*.sh`).

## File moves & knock-on edits

| Old | New |
|---|---|
| `/.zshrc` | `config/zshrc` |
| `/.bashrc` | `config/bashrc` |
| `/.profile` | `config/profile` |
| `/.gitconfig` | `config/git/gitconfig` |
| `home/aliases.sh` | `config/aliases.sh` |
| `home/exports.sh` | `config/exports.sh` |
| `home/functions.sh` | `config/functions.sh` |
| `home/` | removed |

- `.profile` line 50: `$DOTFILES_DIR/home/*.sh` → `$DOTFILES_DIR/config/*.sh` (glob still matches only loose `.sh` files; tool subdirs unaffected).
- **Live symlinks must be relinked after the move:** `~/.zshrc` and `~/.profile` currently point at the old root paths and would dangle. (`~/.bashrc` has no symlink today; `~/.gitconfig` is a real file, consistent with copy semantics.)
- Grep must find no remaining references to `dotfiles/home` or `config/ai`.

## Documentation rewrites

**Root `README.md` / `AGENTS.md`:**

- Remove: the entire `### Paths Mapping` section.
- Update: `## Structure` (new file list, `home/` gone, repo-only files called out), `## Shell Config Flow` (`.profile` sources `$DOTFILES_DIR/config/*.sh`), `## AI Tool Configs` (`config/agents/`, `~/.agents/`, no gemini skills).
- Add: a **Config Index** table — one line per tool dir with a summary destination column, linking to each `config/<dir>/README.md`, plus a pointer line: mappings live in frontmatter, schema in `config/README.md`.

**`config/README.md`** (three jobs):

1. Frontmatter maps for the loose files: `~/.zshrc: zshrc`, `~/.bashrc: bashrc`, `~/.profile: profile`.
2. Body: **Schema** section (the contract above), **Loose files** section (three mapped, three repo-sourced only), **Index** table of all `config/*` subdirs.

**Per-config READMEs:** frontmatter + H1 + short notes only (conventions such as wakatime bootstrap, php install path, gemini unused files).

## Frontmatter fix list

1. **`starship/`** — broken mapping: src `startship.toml` doesn't exist (actual: `starship.toml`), dest `~/.config/startship.toml` misspelled (correct: `~/.config/starship.toml`), title "Startship Config" → "Starship Config".
2. **`ghostty/`** — split single macOS entry into `os: [macos]` entry for `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` and `os: [linux]` entry for `~/.config/ghostty/config`, same src.
3. **`agents/`** — add `skills/` maps with three dests: `~/.config/kilo/skills`, `~/.config/opencode/skills`, `~/.agents/skills`. **Not** `~/.gemini/skills` — gemini-cli is gone; antigravity-cli uses `~/.agents/` by default (consistent with the existing `global-instructions.md` → `~/.agents/global-instructions.md` mapping). Existing `global-instructions.md` entries stay.
4. **`gemini/`** — `settings.json` and `policies/` remain **unmapped** (unused per user); README note explains: antigravity entries are the active ones, local state (`projects.json`, `trustedFolders.json`) is gitignored.
5. **`wakatime/`** — keep `~/.wakatime.cfg: private.cfg`; README note: `private.cfg` is gitignored, bootstrap = `cp config.cfg private.cfg` + add api key; fresh clone skips gracefully (missing-source rule).
6. **`php/`** — keep `maps: {}`; README note: `php.ini`/`conf.d/` are installed by `scripts/php.sh`, not symlinked.

All other declared srcs were verified to exist on disk.

## Verification

- Every non-gitignored `src` in every frontmatter exists (shell loop over parsed frontmatter).
- No dangling links after moves: `readlink ~/.zshrc ~/.profile` point at existing files.
- `grep -r` finds no references to `dotfiles/home`, `config/ai`, or root `.zshrc`/`.profile` paths inside the repo (except this spec and git history).
- Frontmatter parses under the validation rules (interim: manual review; permanent: the future script's `--dry-run`).

## Open items (future work)

- **Init script design**: backup/overwrite policy, CLI flags (`--dry-run`, selective tool install), ordering, `.env` step, package installs — consumes the schema defined here. Separate brainstorm before implementation.
