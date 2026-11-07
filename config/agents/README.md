---
maps:
  ~/.agents/global-instructions.md: global-instructions.md
  ~/.config/zed/AGENTS.md:
    src: global-instructions.md
    when: zed
  ~/.config/kilo/skills:
    src: skills
    when: kilo
  ~/.config/opencode/AGENTS.md:
    src: global-instructions.md
    when: opencode
  ~/.config/opencode/skills:
    src: skills
    when: opencode
  ~/.agents/skills: skills
---

# Common AI Agents Config

Instructions and skills shared by AI agents. Some `skills/` contents are local-only (gitignored except `.gitignore`).

## Credits

- `receiving-code-review` adapted from [`receiving-code-review`](https://github.com/obra/superpowers/tree/main/skills/receiving-code-review) by Jesse Vincent ([@obra](https://github.com/obra)), MIT.
- `leaving-github-comments` adapted from [`leaving-pr-comments`](https://github.com/t3dotgg/tstack/tree/main/skills/leaving-pr-comments) by Theo Browne ([@t3dotgg](https://github.com/t3dotgg)), MIT.
