## Operational Mandates

### Metadata Management

- ALL AI-generated artifacts **MUST be stored EXCLUSIVELY** in the `.agents/` directory **at the root of the current working copy** (repo root — in a monorepo the repository root, not the package; each worktree gets its own). **No project root → no `.agents/`**: durable output belongs in the tool's own location (a skill → its skills dir), ephemeral → OS temp.
  - Metadata docs → `.agents/logs/` (chronological) **or a topic subdir as mandated (`plans/`, `specs/`, `sdd/<task>/`)**; scripts + machine config → `.agents/` root; per-task material → the topic subdir (e.g. `sdd/<task>/`).
- Artifacts = anything you generate *for the work*: ledgers, logs, handoffs, plans, specs, reports, exports, fixtures, scratch scripts. **Not artifacts**: project files being edited, project config the user requested (`AGENTS.md`, rules), global tool config (skills, dotfiles), harness internals. Session-ephemeral scratch → `.agents/tmp/` (delete when done) or the harness temp dir for single-command throwaways. **`git commit`/`commit everything` never stages `.agents/`** unless the user names content inside it.
- **Do NOT** use any other directory for persistent or multi-step agent artifacts (single-command throwaways as defined above excepted).
- **Local-Only Scope**: Local-only is enforced by an ignore file: on first write, run `git check-ignore .agents` — if unprotected, create `.agents/.gitignore` containing `*` and `!.gitignore` (house pattern; the guard file is the one tracked file under `.agents/` — committing it waits for an explicit request). **Sharing is per-project and per-path**: default everything stays ignored; to share specific dirs (e.g. `specs/`, `plans/`) carve negations into the guard file (`!specs/`, `!specs/**`) — the ignore file makes sharing *possible*, an explicit commit makes it *actual*; a skill mandating commits is not by itself authorization.

## Git commits

- **Execution Control:** Do NOT run `git commit` unless the user explicitly requests it in the current turn (e.g., "commit", "commit please").
- **Single-Execution Scope:** Treat commit authorization as **strictly one-time** and **single-execution**. Prior authorization or commit requests in previous turns **NEVER imply permission for subsequent changes**.
- **Retries vs. Rewrites:** A retry after a hook rejects the commit (pre-commit formatting, commitlint) belongs to the same authorization — fix the issue and commit again. History rewrites (`--amend`, rebase, fixup, `reset`) are **new** actions requiring fresh authorization.
- **Push & PR Are Separate:** `git commit` authorization never covers `git push` (tag pushes can trigger releases), force-push, or opening a PR — each needs its own explicit request in the current turn.
- **Staging Scope:** Authorization covers exactly the discussed change: stage deliberately — explicit paths or `git add -p` — never `git add -A` or `git commit -a` when the tree may hold unrelated work. `.agents/` content is never staged unless the user names it as shared (see Metadata Management).
- **Atomicity:** Keep commits atomic — exactly one logical change per commit.
- **Convention:** Strict compliance with the Conventional Commits specification is required.
- **User-Supplied Messages:** When the user provides the exact message, use it verbatim; if hooks reject it, report the rejection and ask — never rewrite it silently.
- **Structure:** Write a clear, concise subject line using the imperative mood (e.g., `add`, `fix`, `change`). Include a brief body explaining the *why* and *what* if the change covers noteworthy details.
- **Line Length Restriction:** Applies to **commit messages only** — keep body lines hard-wrapped under **100 characters** (per `body-max-line-length`). Long URLs in footers or breaking change explanations that cannot be cleanly broken are exempt.
- **USE backticks:** For symbols/classes/functions/variables/`@`-tags **plus file paths (`src/Container.php`), commands (`composer lint`), and flags (`--no-verify`)**.
- **NO backticks:** For hashes/issue/PR refs or prose. commitlint won't catch violations — **self-audit the body against this list before committing**.
- Subject: imperative, lowercase start, **≤100 chars**; types per config-conventional (`feat fix docs chore refactor perf test build ci revert style`). **The repo's commitlint is the structure authority: if hooks reject, fix the message — never `--no-verify` silently**.

### Footer Requirements
- Use `Ref:` for external context (e.g., `Ref: https://github.com/owner/repo/pull/123#discussion_r456`).
- Prefix breaking changes with `BREAKING CHANGE:` followed by a comprehensive, single paragraph of at most ~6 lines explaining the impact and required migration.

### Pull Requests & Issues

- **No line wrapping:** PR titles/descriptions, issue titles/bodies, and all comments are **unwrapped prose** — write normal long lines and let the platform wrap them. Never hard-wrap or format them like commit messages; the 100-character wrap is commit-body-only.
