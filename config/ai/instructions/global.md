## Operational Mandates

- **Metadata Management**: ALL AI-generated metadata (plans, specs, and design documents) MUST be stored exclusively in the `.agents/` directory (e.g., `.agents/plans/`, `.agents/specs/`). Do not use any other directory for persistent or temporary agent artifacts.

## Git commits

- **Never commit unless explicitly asked**. Wait for "commit" or "commit please" from the user.
- **Zero pattern matching**: Even if the user asked me to commit before, the next task still requires an explicit "commit" command. Never generalize from prior requests.
- Use conventional commit format: `type(scope): short description` (e.g., `ci:`, `feat:`, `fix:`)
- Keep the subject line concise. Add a brief, informative body when there are multiple changes worth noting.
- Commits should be atomic — one logical change per commit.
