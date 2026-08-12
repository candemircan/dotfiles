---
name: next
description: "Report where a project stands and what to do next, then stop. Use when the user types /next, asks what is next, says carry on, asks what should be next in the pipeline, or asks what to work on now. Reads the handoff file, the roadmap or plan file, git status, git log, and the last recorded test result. Reports the changes, the unverified items, then at most two options with a named recommendation. Does not start the work. Works in Claude Code and in pi."
---

# next

Read the project state, then report it. This skill reports. It does not work.

## What to read

Read all of these before you report:

1. The handoff file. Find it with the rule in the `handoff` skill: `docs/project/HANDOFF.md`
   first, else `HANDOFF.md` in the repository root.
2. The roadmap or plan file: `docs/project/01-roadmap.md`, else `plan.md`, else `ROADMAP.md`. If
   none exists, say so, and report from git alone.
3. The git state:

```sh
git status --porcelain
git log --oneline -15
git diff --stat
```

4. The last recorded test result. Look in the handoff file, then in the roadmap file.

## Report, in this order

Use these three parts, always in this order.

1. **What changed since the last handoff.** Compare the handoff file against `git log`. Name the
   commits made after the handoff's last commit. Give the count of uncommitted files. If no
   handoff file exists, say so, and report the last 5 commits instead.
2. **What is unverified right now.** Copy the handoff's unverified items. Add any changed file
   that no test covered since the change. Never claim a test passed.
3. **Two options at most.** For each option give the work, the cost, and the risk. Then write one
   line that starts with "Recommendation:".

## Staleness check

Compare the roadmap's last commit date against the code's last commit date:

```sh
git log -1 --format=%ad --date=short -- docs/project/01-roadmap.md
git log -1 --format=%ad --date=short
```

If the roadmap is older, report the gap in days. Staleness is the common case here, not a fault.
Offer refreshing the roadmap as one of the two options when the gap is large.

## Hard rules

- Give two options at most. Never give a menu.
- Always name the recommendation. Never leave the choice to the user alone.
- Keep the whole report under 200 words.
- Stop at the recommendation. Do not edit a file. Do not run a test. Do not start the work.
- Wait for the user to choose before you act.
- If no handoff file exists, suggest `/handoff` after the recommendation.
- Write no em dashes.

## Shape of the decision part

```markdown
Option A. Run the Phase 4 sweep now. Cost: hours of compute. Risk: 38 uncommitted files, so a
failed run is hard to attribute.
Option B. Run the test suite and commit first. Cost: minutes. Risk: the sweep starts later.
Recommendation: option B. The commit gives the run a provenance point.
```
