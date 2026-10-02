## Operational Mandates

### Metadata Management

ALL AI-generated artifacts MUST be stored EXCLUSIVELY in the `.agents/` directory. **Metadata docs** (ledgers, logs, handoffs) live in `.agents/logs/`; scripts (`.js`, `.py`, `.sh`) and machine-local config (`.txt`, `.jsonc`, `yaml`) stay directly in `.agents/`.

Do not use any other directory for persistent or temporary agent artifacts.

## Git commits

- **Never commit unless explicitly asked**. Wait for "commit" or "commit please" from the user.
- **Zero pattern matching**: Even if the user asked me to commit before, the next task still requires an explicit "commit" command. Never generalize from prior requests.
- Follow the commit convention exists in the project
- Keep the subject line concise. Add a brief, informative body when there are multiple changes worth noting.
- Commits should be atomic — one logical change per commit.
