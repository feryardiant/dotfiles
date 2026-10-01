---
maps:
  ~/.agents/global-instructions.md: global-instructions.md
  ~/.config/zed/AGENTS.md:
    src: global-instructions.md
    when: zed
  ~/.config/kilo/skills:
    src: skills
    when: kilo
  ~/.config/opencode/skills:
    src: skills
    when: opencode
  ~/.agents/skills: skills
---

# Common AI Agents Config

Instructions and skills shared by AI agents. `skills/` contents are local-only (gitignored except `.gitignore`), so a fresh clone skips those entries with a warning until populated.
