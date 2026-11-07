---
name: leaving-github-comments
description: Use before posting, replying to, or resolving any GitHub issue, pull request, review, or discussion comment, including when another skill asks for a reply - covers quoting the claim under discussion, agent attribution, and the Ref trailer on review-fix commits.
---

# Leaving GitHub Comments

## Ground the comment

Open with the text you are answering, so the thread reads without prior context. Use whichever fits:

- Quote it: prefix the exact sentence with `>`.
- Cite it: a permalink, or `path` plus a line range such as `path-to-file#L33-L37`.
- Embed it: the code, diff, or output being discussed.

```md
> The reviewer assumption quoted here

Under what condition does X happen, given the workflow at

https://github.com/{owner}/{repo}/blob/{commit-sha}/path-to-file#L33-L37
```

Link a file name with markdown:
[`path-to-file`](https://github.com/{owner}/{repo}/blob/{commit-sha}/path-to-file).

A line-range URL embeds a code preview only when it is the entire paragraph: own line, blank line
before and after, no text on the same line. It must be a permalink pinned to a commit SHA.

Never ask about "this" or "that" without pointing at the exact file(s) or line(s).

## Attribution

Suffix every agent-authored comment left on the user's behalf with this format:

```md
Actual comment here.

###### 🤖 _{model} responding on behalf of {user}_
```

Use the verified public name of the model that wrote the comment, and the user's name or
GitHub login.

If the harness does not expose a model name, use the harness name. Do not guess.

Before posting, check the entire comment, including quoted text and attachments, for secrets and
private details.

Keep the attribution as the final line, separated by a blank line. It must start with the robot
emoji within a `#######` block (`<h6 />` tag). Do not add a horizontal rule, Setext underline,
heading, signature block, or a second attribution.

Apply this format to top-level PR comments, inline review comments, replies to bots or reviewers,
and written explanations used before resolving or dismissing feedback. Do not add it to
PR descriptions, commit messages, or text the user explicitly asked to post verbatim without
attribution.

## Style

- Lead with the conclusion.
- Cite the relevant code, behavior, check, or reproduction.
- Keep it concise and avoid filler, canned thanks, or status narration.
- Distinguish verified facts from judgment.

Preview the final Markdown before posting so quoting and blank lines render as shown. After posting,
verify that GitHub returned the comment or review URL. Resolve a review thread only after its
response was posted successfully.

## Where to post

- Top-level PR comment: `gh pr comment <pr> --body-file -`
- Inline review reply: `gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies -F body=@-`
- Discussion reply: GraphQL `addDiscussionComment` with the discussion id, plus `replyToId` for a
  threaded reply.

Never post a review reply as a top-level PR comment; it loses the thread context.
