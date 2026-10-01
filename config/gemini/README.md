---
when: agy
maps:
  ~/.gemini/antigravity-cli/settings.json: antigravity-cli/settings.json
  ~/.gemini/config/mcp_config.json: config/mcp_config.json
---

# Gemini CLI & Antigravity Config

antigravity-cli and MCP entries below are the active ones (gated on `agy`), installed via their `curl | sh` installer. gemini-cli itself is no longer used, so `settings.json` and `policies/` stay unmapped. `projects.json` / `trustedFolders.json` are local state (gitignored).
