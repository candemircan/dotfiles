---
name: handoff
description: "Write or refresh a project handoff snapshot so the user can clear the context safely. Use when the user types /handoff, asks to reset or clear the chat, asks whether you need your context cleared, asks you to note the state down, or ends a long session. The file records the goal, the last decision and its path, git-derived changes, unverified claims, the next 3 steps, and exact reproduce commands. Works in Claude Code and in pi."
---

# handoff

Write one snapshot file per project. The user reads it after a context reset. Another agent
reads it to continue the work.

## Where the file goes

Apply this rule in order:

1. If `docs/project/` exists, write `docs/project/HANDOFF.md`.
2. Otherwise write `HANDOFF.md` in the repository root.

Never keep two handoff files. If both paths hold one, keep the `docs/project/` file. Tell the
user about the other file. Do not delete it without permission.

## What to read first

Read the facts before you write. Run these commands:

```sh
git status --porcelain
git log --oneline -15
git diff --stat
git diff --cached --stat
```

Then find the project state file:

- `docs/project/01-roadmap.md`, or any `*roadmap*` file under `docs/project/`.
- `plan.md` or `ROADMAP.md` in the repository root.
- If none exists, write "no roadmap file, git log is the only record" in the handoff.

Read the existing handoff file if there is one. You need its last commit reference.

## Sections to write, in this order

Use these six headings, always in this order. The fixed order keeps the diff between two
handoffs readable.

1. **Goal now.** One sentence. Write the current target, not the whole project thesis.
2. **Last decision, and where it is recorded.** Give a path, and a heading anchor if one
   exists. Example: `docs/project/02-decisions.md#library-learning-m4`. Do not summarise the
   decision. The path is the deliverable.
3. **What changed since the last handoff.** Take every item from the git output. Name the
   commits. Give the count of uncommitted files.
4. **What is not verified.** List tests not run, results not reproduced, and claims not
   checked. This section is mandatory. If nothing is outstanding, write "Nothing outstanding".
5. **Next 3 steps.** Three at most. One action per step.
6. **Commands to reproduce the current state.** Exact and runnable. Include the test command.

## Hard rules

- Rewrite the whole file each time. Never append. The file is a snapshot, not a log.
- Cap the file at 400 words. If the state does not fit, it belongs in the roadmap or plan file.
  Link that file instead.
- Never invent progress. Every item in "What changed" must come from git output.
- Record uncommitted work explicitly, and give the modified-file count. A working tree with 20 or
  more modified files is normal here, so treat it as state to report, not a problem to fix.
- Do not copy the roadmap into the handoff. Link to it.
- Write no em dashes.

## Worked example

````markdown
# Handoff

## Goal now
Run the Phase 4 held-out-task transfer sweep on the full 13-task corpus.

## Last decision, and where it is recorded
docs/project/02-decisions.md#library-learning-m4

## What changed since the last handoff
- 3 commits since 9bf901f: run-viewer publish, primitive annotation, viewer refresh.
- 38 uncommitted files, including cognitiondotpy/eval/transfer.py and CLAUDE.md.

## What is not verified
- The full test suite was not run after the transfer.py edit.
- The 13-task corpus run has not started, so no Phase 4 numbers exist.

## Next 3 steps
1. Run the test suite and record the pass count.
2. Commit the transfer.py and config.py changes.
3. Launch the Phase 4 sweep over the full corpus.

## Commands to reproduce the current state
```sh
git -C ~/Projects/cpi/cognitiondotpy log --oneline -3
uv run pytest
uv run python scripts/transfer.py --source real --proposer agentic
```
````

## Report to the user

State the file path. State the word count. State whether the unverified section is empty. Then
tell the user that a context reset is safe.
