# scripts/

Installer internals behind [`install.sh`](../install.sh): shared library, per-tool
bootstrappers, the mapping applier, and the test suite. Nothing here is mappable —
mappings live in each `config/**/README.md`.

## Layout

Directories first, then files, alphabetical.

| Path | Purpose |
|---|---|
| `logs/` | Raw installer output — one `setup-{tool}.txt` per tool, fresh each run |
| `setup.d/` | One bootstrapper per tool: `system`, `oh-my-zsh`, `vim`, `nvim`, `tmux`, `fzf`, `zoxide`, `eza`, `starship`, `lazygit`, `mise`. Present-check + dry-run guard, then `brew` on macOS / `apt_install` on Linux |
| `tests/` | Self-contained test suites — see [Tests](#tests) |
| `init-lxc.sh` | One-shot system bootstrap inside an LXC container (locale, timezone, `apt update && dist-upgrade`) |
| `init.sh` | One-shot system bootstrap for a fresh Linux machine (locale, timezone, `apt update && dist-upgrade`), runs under sudo |
| `lib.sh` | Shared library sourced by `install.sh`, `link.sh`, and every `setup.d/` script: `when:`/`maps:` frontmatter parser, `is_macos`/`is_linux`, `link_apply`, `brew_install`/`apt_install`/`ppa_install` |
| `link.sh` | Standalone applier of every `maps:` entry (os/`when:` gated) — what `--link-only` runs |
| `phases.sh` | Phase membership and order; each name maps to `setup.d/<name>.sh` |
| `php.sh` | `mise` postinstall hook for PHP (skips unless `MISE_TOOL_NAME=php`) |
| `util.sh` | Colors + one-line status helpers (`msg_begin`/`msg_end`), shared by shell rc, installer, and tests; sourced by `lib.sh` |

## Flow

```mermaid
flowchart TD
    install["install.sh<br/>flags: --only, --skip, --link-only, --force, --dry-run"] --> phases["phases.sh<br/>phase order and membership"]
    install --> link["link.sh<br/>applies every maps entry (os/when gated)"]
    install --> lib["lib.sh<br/>parser, predicates, install wrappers"]
    phases --> setup["setup.d/*.sh<br/>per-tool bootstrappers"]
    setup --> lib
    link --> lib
    lib --> util["util.sh<br/>colors + status helpers"]
    docs["config/**/README.md<br/>when / maps frontmatter"] --> link
    install -.->|DOTFILES_SETUP_LOG| log["logs/setup-{tool}.txt<br/>raw output per tool"]
```

Each bootstrapper prints one status line to the console (`installing (brew|apt):
<tool>... done|warn|fail`); its raw output goes to `scripts/logs/setup-{tool}.txt`,
and a failure prints `See <log> for more info`.

## Tests

Run a single suite:

```bash
bash scripts/tests/lib_test.sh
```

Run all five:

```bash
for t in lib link setup plugin install; do
  bash "scripts/tests/${t}_test.sh" || echo "FAILED: $t"
done
```

| Suite | Covers |
|---|---|
| `lib_test.sh` | `lib.sh`: frontmatter parser rules, predicates, `link_apply`, install wrappers (`brew`/`apt`/`ppa`) |
| `link_test.sh` | `link.sh`: full-corpus run with gating, idempotent rerun, parse-error handling |
| `setup_test.sh` | `setup.d/*`: `bash -n` on every script plus behavior (`.env` seed/merge, nvim caches, vim-plug, lazygit apt path) |
| `plugin_test.sh` | starship, eza, fzf, zoxide install paths: `brew` on macOS, apt markers on Linux, present-check skip |
| `install_test.sh` | `install.sh` end-to-end with stubbed phases: failure handling + log hint, `--only`/`--skip` (single or comma lists), `--dry-run`, `--link-only`, unknown flags |

A passing suite prints `ok - ...` lines and ends with `N tests, 0 failures` (exit 0);
failures are `NOT OK - ...` lines and a non-zero exit.

Suites are hermetic: fixtures in `mktemp -d` directories, stubbed `brew`/`apt-get`/`curl`,
and a fixture-only `PATH` — no network, no writes outside the fixture, safe to run on
macOS and Linux at any time.
