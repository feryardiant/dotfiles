---
maps: {}
---

# PHP Config

Nothing here is linked into `~`. `php.ini` and `conf.d/*.ini` are consumed by `scripts/php.sh`, a mise postinstall hook (gated on `MISE_TOOL_NAME=php`) that symlinks them into the mise-managed PHP prefix.
