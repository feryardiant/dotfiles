---
name: receiving-code-review
description: Use when receiving code review feedback, PR review comments, or suggestions - verify each finding's reachability before implementing, then prove the fix in-thread
---

# Code Review Reception

## Overview

Code review requires technical evaluation, not emotional performance.

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over 
social comfort. Be skeptical, but check carefully.

## Triage Gate

Before implementing a review suggestion, answer in the reply:

1. Which code path runs it? (callers, entry points)
2. Does the finding depend on something that exists here, and can the triggering state occur there? (file format,
   config key, schema, caller; environment, users, inputs)
3. If it occurs, what breaks? (data loss, partial writes, user-visible failure)

If (2) has no concrete answer, say whether the premise is false because the artifact does not exist here, or the
state is unreachable on the supported path; make no change. Fix only when (2) and (3) both have concrete answers.
Never apply a suggestion because it is small, and never add a guard for a state the supported path cannot produce.

## Asking the Reviewer

When the precondition is unclear, ask for it directly: "Under what condition does X happen?" A reviewer that
cannot name one has a hypothesis, not a defect. Post the question with the `leaving-github-comments` skill.

## Dispositions

Every finding ends in exactly one of these, and the reply says which:

- **Fix** — questions (2) and (3) both have concrete answers. Fix the root cause once and add the lowest test
  that fails before the change and passes after. Reply in-thread with the evidence — commit permalink, changed
  lines, test result — following `leaving-github-comments`. The commit gets the `Ref:` trailer below.
- **Reject** — question (2) has no concrete answer. State whether the artifact does not exist here (false premise)
  or the state is unreachable on the supported path; make no code change.
- **Defer** — real, but outside this change's scope. Acknowledge it, state the boundary, offer a follow-up issue,
  change nothing.

Never leave a thread without a disposition; an unanswered finding is not triaged.

## Review-fix commits

When a commit addresses review feedback, add one `Ref:` trailer per addressed comment, pointing at
that comment's permalink:

```text
chore(ci): pass bot configuration values through environment variables

Ref: https://github.com/{owner}/{repo}/pull/{number}#discussion_r{id}
```

Wrap body lines to the repo's commit-message rules, 100 characters when it has none. Do not add
`Ref:` for feedback that was triaged and left unchanged.
