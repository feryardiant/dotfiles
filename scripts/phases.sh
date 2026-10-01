#!/usr/bin/env bash
# Phase membership — name maps to scripts/setup.d/<name>.sh.
# Adding a tool = create the script + add its name here. Phases run in order
# system → managers → tools → link (link always last, after all deps exist).
PHASE_SYSTEM=(system oh-my-zsh vim nvim tmux)
PHASE_MANAGERS=(mise)
PHASE_TOOLS=(starship eza fzf zoxide lazygit)
